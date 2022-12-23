# Elixir UDP Server Example

A very simple UDP server example for Elixir that uses the code borrowed from [this gist](https://gist.github.com/joshnuss/08603e11615ee0de65724be4d6335475).


## Usage

Start an iex session with:

```console
iex -S mix
```

Now, send messages to the UDP server from another terminal:

```console
echo "hello world" | nc -u -w0 0.0.0.0 2052
```
