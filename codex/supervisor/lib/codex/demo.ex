defmodule Codex.Demo do
  @moduledoc """
  Final integration gate demonstration (3 concurrent workers).
  """

  def run do
    {:ok, _} = Codex.Supervisor.start_link()

    tasks = ["validate-ast-1", "validate-ast-2", "validate-ast-3"]

    pids =
      for task <- tasks do
        case Codex.Admission.admit(task, depth: 0, budget_tokens: 32, deadline_ms: 1000) do
          {:admitted, pid} -> pid
          other -> other
        end
      end

    Process.sleep(50)
    Codex.Supervisor.cancel_all()
    %{spawned: length(pids), active_after: Codex.Supervisor.active_count()}
  end
end
