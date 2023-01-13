defmodule UdpServer.PacketsAgent do
  use Agent

  def start_link(_args) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def packets() do
    Agent.get(__MODULE__, & &1)
  end

  def add_packet(packet) do
    Agent.update(__MODULE__, fn state -> [packet | state] end)
  end

end
