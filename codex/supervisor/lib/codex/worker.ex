defmodule Codex.Worker do
  @moduledoc """
  Short-lived GenServer worker.
  Receives immutable context slice, runs inference (via Port to Rust), validates, reports, terminates.
  """

  use GenServer
  require Logger

  def start_link({task, depth, budget, deadline_ms}) do
    GenServer.start_link(__MODULE__, {task, depth, budget, deadline_ms})
  end

  @impl true
  def init({task, depth, budget, deadline_ms}) do
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
      deadline_ref: deadline_ref,
      status: :created,
      ref: make_ref()
    }

    {:ok, state, {:continue, :admit}}
  end

  @impl true
  def handle_continue(:admit, state) do
    # Admission control / backpressure hook
    new_state = %{state | status: :admitted}
    {:noreply, new_state, {:continue, :run}}
  end

  def handle_continue(:run, state) do
    # In production: open Port to Rust runtime
    # For now: mock result that passes validation
    result = %{
      output: "READ /opt/sovereign/bin/tool",
      token_count: 4,
      valid: true
    }

    new_state = %{state | status: :validating}
    send(self(), {:result, result, state.ref})
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:result, result, ref}, %{ref: ref} = state) do
    if state.deadline_ref, do: Process.cancel_timer(state.deadline_ref)

    # I5: invalid output never enters approved channel
    if result.valid do
      # report to parent
      Logger.info("Worker completed valid result")
    else
      Logger.warning("Worker rejected invalid output")
    end

    {:stop, :normal, %{state | status: :completed}}
  end

  def handle_info(:deadline, state) do
    Logger.warning("Worker deadline exceeded")
    {:stop, :normal, %{state | status: :failed}}
  end

  def handle_info(:cancel, state) do
    if state.deadline_ref, do: Process.cancel_timer(state.deadline_ref)
    {:stop, :normal, %{state | status: :cancelled}}
  end

  # I4: discard stale messages
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
