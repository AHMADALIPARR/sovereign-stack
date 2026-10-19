defmodule Codex.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Codex.WorkerRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Codex.WorkerSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Codex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
