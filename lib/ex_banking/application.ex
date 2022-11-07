defmodule ExBanking.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ExBanking.Accounts.UserRegistry},
      {DynamicSupervisor, name: ExBanking.Accounts.UserSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :rest_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
