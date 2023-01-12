defmodule UdpServer do
  # Our module is going to use the DSL (Domain Specific Language) for Gen(eric) Servers
  use GenServer

  # We need a factory method to create our server process
  # it takes a single parameter `port` which defaults to `2052`
  # This runs in the caller's context
  def start_link(port \\ 2052) do
    process = GenServer.start_link(__MODULE__, port, name: __MODULE__) # Start 'er up

    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:start_link, process})

    process
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  @impl true
  def init(port) do
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}
    server = :gen_udp.open(port, [:binary, active: true])

    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:init, server})

    server
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  @impl true
  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:packet, data})

    # IRL: do something more interesting...

    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end

  ### ALERT: you may not want to support the quit message in a production UDP server ###
  # pattern match the "quit" message
  def handle_call(:stop, _from, socket) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:close, "quit"})

    # IO.puts("Received: quit. Closing down...")

    # close the socket
    :gen_udp.close(socket)

    # GenServer will understand this to mean we want to stop the server
    # action: :stop
    # reason: :normal
    # new_state: nil, it doesn't matter since we're shutting down :(
    {:stop, :normal, nil}
  end

end
