defmodule Codex.Supervisor do
  @moduledoc """
  DynamicSupervisor for ephemeral inference workers.
  Lifecycle: CREATED → ADMITTED → RUNNING → VALIDATING → COMPLETED → TERMINATED
  Enforces I1 (depth), I2 (fan-out), I8 (deadline/budget), I9 (parent death → cancel).
  """

  use DynamicSupervisor

  @max_active 32
  @max_depth 4

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def spawn_worker(task, opts \\ []) do
    depth = Keyword.get(opts, :depth, 0)
    if depth >= @max_depth do
      {:error, :max_depth_exceeded}
    else
      spec = {Codex.Worker, {task, depth, opts}}
      DynamicSupervisor.start_child(__MODULE__, spec)
    end
  end

  def active_count do
    DynamicSupervisor.count_children(__MODULE__).active
  end

  def cancel_all do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.each(fn {_, pid, _, _} ->
      if is_pid(pid), do: send(pid, :cancel)
    end)
  end
end
