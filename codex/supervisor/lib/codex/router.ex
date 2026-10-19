defmodule Codex.Router do
  @moduledoc """
  Message routing and envelope for parent → child dispatch.
  Discards stale messages for completed tasks (I4).
  """

  defstruct [:task_id, :sender_pid, :payload, :deadline, :reply_to]

  def new(task_id, payload, opts \\ []) do
    %__MODULE__{
      task_id: task_id,
      sender_pid: self(),
      payload: payload,
      deadline: Keyword.get(opts, :deadline),
      reply_to: Keyword.get(opts, :reply_to, self())
    }
  end

  def dispatch(%__MODULE__{} = msg, child_pid) do
    send(child_pid, {:envelope, msg})
  end
end
