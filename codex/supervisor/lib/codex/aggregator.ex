defmodule Codex.Aggregator do
  @moduledoc """
  Collects worker results without blocking the supervisor.
  Only validated results enter the approved list (I5, I10).
  """

  defstruct approved: [], rejected: [], pending: MapSet.new()

  def new(task_ids) when is_list(task_ids) do
    %__MODULE__{pending: MapSet.new(task_ids)}
  end

  def handle_result(%__MODULE__{} = agg, task_id, status, result, evidence) do
    agg = %{agg | pending: MapSet.delete(agg.pending, task_id)}

    case {status, evidence} do
      {:completed, %{valid: true}} ->
        %{agg | approved: [{task_id, result, evidence} | agg.approved]}

      _ ->
        %{agg | rejected: [{task_id, status, evidence} | agg.rejected]}
    end
  end

  def done?(%__MODULE__{pending: pending}), do: MapSet.size(pending) == 0

  def summary(%__MODULE__{} = agg) do
    %{
      approved: Enum.reverse(agg.approved),
      rejected: Enum.reverse(agg.rejected),
      pending: MapSet.to_list(agg.pending)
    }
  end
end
