defmodule UdpServerTest do
  use ExUnit.Case
  doctest UdpServer

  test "greets the world" do
    assert UdpServer.hello() == :world
  end
end
