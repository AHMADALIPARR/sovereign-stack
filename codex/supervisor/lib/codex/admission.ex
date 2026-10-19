defmodule Codex.Admission do
  @moduledoc """
  Admission control and backpressure.
  Returns {:admitted, pid} or {:rejected, reason}.
  I2: no parent exceeds its child fan-out budget.
  """

  @max_active 32

  def admit(task, opts \\ []) do
    active = Codex.Supervisor.active_count()
    depth = Keyword.get(opts, :depth, 0)
    max_depth = Keyword.get(opts, :max_depth, 4)

    cond do
      active >= @max_active ->
        {:rejected, :max_active_exceeded}

      depth >= max_depth ->
        {:rejected, :max_depth_exceeded}

      true ->
        case Codex.Supervisor.spawn_worker(task, opts) do
          {:ok, pid} -> {:admitted, pid}
          {:error, reason} -> {:rejected, reason}
        end
    end
  end

  def max_active, do: @max_active
end
