defmodule Codex.Worker do
  @moduledoc """
  Short-lived GenServer worker.
  Lifecycle: CREATED → ADMITTED → RUNNING → VALIDATING → COMPLETED|FAILED → TERMINATED
  I3: exactly one terminal state. I4: stale messages discarded by ref. I5: invalid never approved.
  """

  use GenServer
  require Logger

  @type status :: :created | :admitted | :running | :validating | :completed | :failed | :cancelled | :terminated

  def start_link({task, depth, opts}) do
    GenServer.start_link(__MODULE__, {task, depth, opts})
  end

  @impl true
  def init({task, depth, opts}) do
    budget = Keyword.get(opts, :budget_tokens, 64)
    deadline_ms = Keyword.get(opts, :deadline_ms, 2000)
    parent = Keyword.get(opts, :parent, self())

    deadline_ref =
      if deadline_ms > 0 do
        Process.send_after(self(), :deadline, deadline_ms)
      else
        nil
      end

    state = %{
      task: task,
      depth: depth,
      budget: budget,
      deadline_ms: deadline_ms,
      deadline_ref: deadline_ref,
      status: :created,
      ref: make_ref(),
      parent: parent,
      started_at: System.monotonic_time(:millisecond)
    }

    {:ok, state, {:continue, :admit}}
  end

  @impl true
  def handle_continue(:admit, state) do
    {:noreply, %{state | status: :admitted}, {:continue, :run}}
  end

  def handle_continue(:run, %{status: :admitted} = state) do
    # Production path: open Port to Rust runtime.
    # Foundation path: produce a contract-valid result and validate it.
    result = %{
      output: "READ /opt/sovereign/bin/tool",
      token_count: 4,
      wall_ms: System.monotonic_time(:millisecond) - state.started_at
    }

    send(self(), {:result, result, state.ref})
    {:noreply, %{state | status: :running}}
  end

  @impl true
  def handle_info({:result, result, ref}, %{ref: ref, status: status} = state)
      when status in [:running, :validating] do
    cancel_deadline(state)

    evidence = Codex.Grammar.Validator.validate_command(result.output)
    final =
      if evidence.valid do
        :completed
      else
        :failed
      end

    notify_parent(state.parent, state.task, final, result, evidence)
    Logger.info("worker #{inspect(self())} #{final} task=#{inspect(state.task)}")

    {:stop, :normal, %{state | status: final}}
  end

  def handle_info(:deadline, state) do
    cancel_deadline(state)
    notify_parent(state.parent, state.task, :failed, nil, %{valid: false, reason: :deadline})
    Logger.warning("worker deadline task=#{inspect(state.task)}")
    {:stop, :normal, %{state | status: :failed}}
  end

  def handle_info(:cancel, state) do
    cancel_deadline(state)
    notify_parent(state.parent, state.task, :cancelled, nil, %{valid: false, reason: :cancelled})
    {:stop, :normal, %{state | status: :cancelled}}
  end

  # I4: discard anything that does not match the current ref or arrives after terminal
  def handle_info(_msg, state), do: {:noreply, state}

  defp cancel_deadline(%{deadline_ref: nil}), do: :ok
  defp cancel_deadline(%{deadline_ref: ref}), do: Process.cancel_timer(ref)

  defp notify_parent(parent, task, status, result, evidence) do
    if is_pid(parent) and Process.alive?(parent) do
      send(parent, {:worker_done, task, status, result, evidence})
    end
  end
end
