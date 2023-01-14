defmodule UdpServer.PacketsAgent do
  use Agent
  alias UdpServer.PacketsAgent

  defstruct [
    start: nil,
    init: nil,
    packets: [],
    closed: [],
  ]

  def start_link(_args) do
    Agent.start_link(fn -> %PacketsAgent{} end, name: __MODULE__)
  end

  def packets() do
    Agent.get(__MODULE__, & &1)
  end

  def event_start_udp_server(event) do
    Agent.update(__MODULE__, fn state -> Map.put(state, :start, event) end)
  end

  def event_init_udp_server(event) do
    Agent.update(__MODULE__, fn state -> Map.put(state, :init, event) end)
    # Agent.update(__MODULE__, fn state -> [data | state] end)
  end

  def event_udp_packet(event) do
    Agent.update(__MODULE__, fn state -> add_packet(state, event) end)
    # Agent.update(__MODULE__, fn state -> [packet | state] end)
  end

  def event_close_udp_server(event) do
    Agent.update(__MODULE__, fn state -> Map.put(state, :closed, event) end)
    # Agent.update(__MODULE__, fn state -> [packet | state] end)
  end

  defp add_packet(state, event) do
    {_old_state, updated_state } = Map.get_and_update(state, :packets, fn packets -> {packets, [event | packets]} end)
    updated_state
  end

  # Map.get_and_update(%{a: 1}, :a, fn current_value -> {current_value, "new value!"} end)

end
