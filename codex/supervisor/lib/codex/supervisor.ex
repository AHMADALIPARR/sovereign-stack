defmodule Codex.Supervisor do
  @moduledoc """
  DynamicSupervisor for ephemeral inference workers.
  Enforces recursion depth, fan-out budgets, deadlines, and cancellation.
  Lifecycle: CREATED → ADMITTED → RUNNING → VALIDATING → COMPLETED → TERMINATED
  """

  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def spawn_worker(task, opts \\ []) do
    depth = Keyword.get(opts, :depth, 0)
    max_depth = Keyword.get(opts, :max_depth, 3)
    budget = Keyword.get(opts, :budget_tokens, 256)
    deadline_ms = Keyword.get(opts, :deadline_ms, 5000)

    if depth >= max_depth do
      {:error, :max_depth_exceeded}
    else
      spec = {Codex.Worker, {task, depth, budget, deadline_ms}}
      DynamicSupervisor.start_child(__MODULE__, spec)
    end
  end
end
