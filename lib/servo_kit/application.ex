defmodule ServoKit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.debug("#{__MODULE__} starting")

    children = [
      {ServoKit.ProcessRegistry, nil},
      {ServoKit.ServoSupervisor, nil}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ServoKit.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
