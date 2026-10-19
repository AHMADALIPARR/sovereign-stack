defmodule Codex.Supervisor do
  @moduledoc """
  DynamicSupervisor for ephemeral inference workers.
  Enforces I1 (depth), I2 (fan-out via admission), I8 (deadline/budget), I9 (cancel_all).
  """

  use DynamicSupervisor

  @max_depth 4

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Spawn a worker. Returns {:ok, pid} or {:error, reason}.
  Depth is checked here; active-count is checked by Codex.Admission.
  """
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

  def which_children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  @doc """
  I9: parent termination / explicit cancel triggers defined child cancellation.
  """
  def cancel_all do
    which_children()
    |> Enum.each(fn
      {_, pid, _, _} when is_pid(pid) -> send(pid, :cancel)
      _ -> :ok
    end)

    :ok
  end

  def terminate_child(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
