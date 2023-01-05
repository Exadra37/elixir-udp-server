defmodule HamMessageParser do

  defstruct [
      call_sign: nil,
      band: nil,
      mode: nil,
  ]

  def parse(message) do

    {_message, %HamMessageParser{} = ham_message} =
      {message, %HamMessageParser{}}
      |> _parse_call_sign()
      |> _parse_band()
      |> _parse_mode()

    ham_message
  end

  def _parse_call_sign({"<call:" <> <<call_sign_length::bytes-size(1)>> <> ">" <> message, ham_message}) do

    call_sign_length = String.to_integer(call_sign_length)
    call_sign = String.slice(message, 0, call_sign_length)

    ham_message = Map.put(ham_message, :call_sign, call_sign)

    message = String.slice(message, call_sign_length, String.length(message))

    {message, ham_message}
  end

  def _parse_band({"<band:" <> <<band_length::bytes-size(1)>> <> ">" <> message, ham_message}) do
    band_length = String.to_integer(band_length)
    band = String.slice(message, 0, band_length)

    ham_message = Map.put(ham_message, :band, band)

    message = String.slice(message, band_length, String.length(message))

    {message, ham_message}
  end

  def _parse_mode({"<mode:" <> <<mode_length::bytes-size(1)>> <> ">" <> message, ham_message}) do
    mode_length = String.to_integer(mode_length)
    mode = String.slice(message, 0, mode_length)

    ham_message = Map.put(ham_message, :mode, mode)

    message = String.slice(message, mode_length, String.length(message))

    {message, ham_message}
  end

end
