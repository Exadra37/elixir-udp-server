defmodule UdpServer.PacketsAgent do
  use Agent
  alias UdpServer.PacketsAgent

  defstruct [
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

  def last_packet() do
    [head | _tail] = Agent.get(__MODULE__, fn state -> state.packets end)
    head
  end

  def pop_last_packet() do
    Agent.get_and_update(__MODULE__, fn state -> _pop_packet(state) end)
  end

  def event_udp_packet(event) do
    Agent.update(__MODULE__, fn state -> _add_packet(state, event) end)
  end

  defp _add_packet(state, event) do
    {_old_state, updated_state } = Map.get_and_update(state, :packets, fn packets -> {packets, [event | packets]} end)
    updated_state
  end

  defp _pop_packet(%{packets: []} = state) do
    {[], state}
  end

  defp _pop_packet(state) do
    Map.get_and_update(state, :packets, fn [head | tail] = _packets -> {head, tail} end)
  end

end
