defmodule UdpServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: UdpServer.Worker.start_link(arg)
      # {UdpServer.Worker, arg}
      {UdpServer, 2052},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UdpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
