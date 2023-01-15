# defmodule UdpServer.Server do
#   defstruct [
#     start_link: nil,
#     init: nil,
#     closed: nil,
#   ]
# end

defmodule UdpServer.ServersAgent do
  use Agent
  alias UdpServer.ServersAgent

  defstruct [
    servers: %{},
  ]

  def start_link(_args) do
    Agent.start_link(fn -> %ServersAgent{} end, name: __MODULE__)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def servers() do
    Agent.get(__MODULE__, fn state -> state.servers end)
  end

  def active() do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.filter(state.servers, fn {_server_uid, server} -> server.active == true end)
      end
    )
  end

  def inactive() do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.filter(state.servers, fn {_server_uid, server} -> server.active == false end)
      end
    )
  end

  def event_boot_udp_server(event) do
    Agent.update(__MODULE__, fn state -> add_or_update_server(state, event) end)
  end

  def event_update_udp_server(event) do
    Agent.update(__MODULE__, fn state -> add_or_update_server(state, event) end)
  end

  def event_close_udp_server(event) do
    Agent.update(__MODULE__, fn state -> add_or_update_server(state, event) end)
  end

  defp add_or_update_server(state, event) do
    {_old_state, updated_state } = Map.get_and_update(state, :servers, fn servers -> {servers, Map.put(servers, event.uid, event)} end)
    updated_state
  end

end
