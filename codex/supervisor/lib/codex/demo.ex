# SnapKitty Opaque License
# Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
# Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

defmodule Codex.Demo do
  @moduledoc """
  Representative three-worker workload.
  Admits three workers, waits for completion or timeout, cancels leftovers, returns summary.
  """

  def run(opts \\ []) do
    unless Process.whereis(Codex.Supervisor) do
      {:ok, _} = Codex.Supervisor.start_link()
    end

    tasks = Keyword.get(opts, :tasks, ["validate-ast-1", "validate-ast-2", "validate-ast-3"])
    timeout = Keyword.get(opts, :timeout, 500)

    pids =
      for task <- tasks do
        case Codex.Admission.admit(task, depth: 0, budget_tokens: 32, deadline_ms: timeout, parent: self()) do
          {:admitted, pid} -> {task, pid}
          other -> {task, other}
        end
      end

    agg =
      tasks
      |> Codex.Aggregator.new()
      |> collect(timeout)

    Codex.Supervisor.cancel_all()

    %{
      spawned: pids,
      summary: Codex.Aggregator.summary(agg),
      active_after: Codex.Supervisor.active_count()
    }
  end

  defp collect(agg, timeout) do
    if Codex.Aggregator.done?(agg) do
      agg
    else
      receive do
        {:worker_done, task, status, result, evidence} ->
          agg
          |> Codex.Aggregator.handle_result(task, status, result, evidence)
          |> collect(timeout)
      after
        timeout -> agg
      end
    end
  end
end
