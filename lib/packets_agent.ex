# defmodule UdpServer.Server do
#   defstruct [
#     start_link: nil,
#     init: nil,
#     closed: nil,
#   ]
# end

defmodule UdpServer.PacketsAgent do
  use Agent
  alias UdpServer.PacketsAgent

  defstruct [
    servers: %{},
    packets: [],
  ]

  def start_link(_args) do
    Agent.start_link(fn -> %PacketsAgent{} end, name: __MODULE__)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def packets() do
    Agent.get(__MODULE__, fn state -> state.packets end)
  end

  def packets_head() do
    [head | _tail] = Agent.get(__MODULE__, fn state -> state.packets end)
    head
  end

  def servers() do
    Agent.get(__MODULE__, fn state -> state.servers end)
  end

  # def event_start_udp_server(event) do
  #   Agent.update(__MODULE__, fn state -> Map.put(state, :start, event) end)
  # end

  # def event_init_udp_server(event) do
  #   Agent.update(__MODULE__, fn state -> Map.put(state, :init, event) end)
  #   # Agent.update(__MODULE__, fn state -> [data | state] end)
  # end

  def event_boot_udp_server(event) do
    # Agent.update(__MODULE__, fn state -> Map.put(state, :server, event) end)
    Agent.update(__MODULE__, fn state -> add_server(state, event) end)
  end

  def event_udp_packet(event) do
    Agent.update(__MODULE__, fn state -> add_packet(state, event) end)
    # Agent.update(__MODULE__, fn state -> [packet | state] end)
  end

  def event_close_udp_server(event) do
    # Agent.update(__MODULE__, fn state -> Map.put(state, :closed, event) end)
    Agent.update(__MODULE__, fn state -> add_server(state, event) end)
    # Agent.update(__MODULE__, fn state -> [packet | state] end)
  end

  defp add_server(state, event) do
    # {_old_state, updated_state } = Map.get_and_update(state, :servers, fn servers -> {servers, [event | servers]} end)
    {_old_state, updated_state } = Map.get_and_update(state, :servers, fn servers -> {servers, Map.put(servers, event.uid, event)} end)
    updated_state
  end

  defp add_packet(state, event) do
    {_old_state, updated_state } = Map.get_and_update(state, :packets, fn packets -> {packets, [event | packets]} end)
    # {_old_state, updated_state } = Map.get_and_update(state, :packets, fn packets -> {packets, Map.put(packets, event.uid, event)} end)
    updated_state
  end

  # Map.get_and_update(%{a: 1}, :a, fn current_value -> {current_value, "new value!"} end)

end
