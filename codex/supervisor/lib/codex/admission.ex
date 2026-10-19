defmodule Codex.Admission do
  @moduledoc """
  Admission control and backpressure.
  Returns {:admitted, pid} or {:rejected, reason}.
  """

  @max_active 32

  def admit(task, opts \\ []) do
    active = DynamicSupervisor.count_children(Codex.Supervisor).active

    cond do
      active >= @max_active ->
        {:rejected, :max_active_exceeded}

      Keyword.get(opts, :depth, 0) >= Keyword.get(opts, :max_depth, 4) ->
        {:rejected, :max_depth_exceeded}

      true ->
        case Codex.Supervisor.spawn_worker(task, opts) do
          {:ok, pid} -> {:admitted, pid}
          err -> {:rejected, err}
        end
    end
  end
end
