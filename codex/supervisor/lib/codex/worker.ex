defmodule Codex.Worker do
  @moduledoc """
  Short-lived GenServer. Immutable context slice. Mock or Port to Rust.
  I3: exactly one terminal state. I4: stale messages discarded. I5: invalid never approved.
  """

  use GenServer
  require Logger

  def start_link({task, depth, opts}) do
    GenServer.start_link(__MODULE__, {task, depth, opts})
  end

  @impl true
  def init({task, depth, opts}) do
    budget = Keyword.get(opts, :budget_tokens, 64)
    deadline_ms = Keyword.get(opts, :deadline_ms, 2000)
    deadline_ref = if deadline_ms > 0, do: Process.send_after(self(), :deadline, deadline_ms), else: nil

    state = %{
      task: task,
      depth: depth,
      budget: budget,
      deadline_ref: deadline_ref,
      status: :created,
      ref: make_ref(),
      parent: self()
    }

    {:ok, state, {:continue, :admit}}
  end

  @impl true
  def handle_continue(:admit, state) do
    {:noreply, %{state | status: :admitted}, {:continue, :run}}
  end

  def handle_continue(:run, state) do
    result = %{
      output: "READ /opt/sovereign/bin/tool",
      token_count: 4,
      valid: true,
      wall_ms: 1
    }
    send(self(), {:result, result, state.ref})
    {:noreply, %{state | status: :running}}
  end

  @impl true
  def handle_info({:result, result, ref}, %{ref: ref} = state) do
    if state.deadline_ref, do: Process.cancel_timer(state.deadline_ref)

    evidence = Codex.Grammar.Validator.validate_command(result.output)
    final_status = if evidence.valid, do: :completed, else: :failed

    Logger.info("Worker #{inspect(self())} #{final_status}")
    {:stop, :normal, %{state | status: final_status}}
  end

  def handle_info(:deadline, state) do
    Logger.warning("deadline")
    {:stop, :normal, %{state | status: :failed}}
  end

  def handle_info(:cancel, state) do
    if state.deadline_ref, do: Process.cancel_timer(state.deadline_ref)
    {:stop, :normal, %{state | status: :cancelled}}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
