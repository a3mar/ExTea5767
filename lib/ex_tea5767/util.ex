defmodule ExTea5767.Util do
  @spec freq_to_bits(float) :: integer
  def freq_to_bits(freq) do
    ((freq * 1000000 + 225000) / 8192) |> Kernel.trunc
  end

  @spec bits_to_freq(number) :: float
  def bits_to_freq(bits) do
    ((bits * 8192 - 225000) / 1000000) |> Float.round(1)
  end

  @spec unpack(<<_::32>>) :: %{adc_level: byte, band_limit: 0 | 1, frequency: float, if_counter: byte, ready: 0 | 1, stereo: 0 | 1}
  def unpack( <<
    ready       ::  1,   # 1 station found or band limit reached
    band_limit  ::  1,   # 1 band limit reached
    frequency   :: 14,   #
    stereo      ::  1,   # 1 stereo station, 0 mono
    if_counter  ::  7,   # IF counter result (?)
    adc_level   ::  4,   # Signal level
    _chip_id    ::  4    # Actually not used
  >> ) do

  %{
    ready: ready,
    band_limit: band_limit,
    frequency: bits_to_freq(frequency),
    stereo: stereo,
    if_counter: if_counter,
    adc_level: adc_level
  }
  end

  @spec pack([]) :: bitstring
  def pack( data ) do
    List.foldr( data, [], fn( param, acc ) ->
      { _name, [bits: bits, value: value] } = param
      [ int_to_bitstring(value, bits) | acc ]
    end )
    |> :erlang.list_to_bitstring
  end

  @spec int_to_bitstring(integer, integer) :: bitstring
  defp int_to_bitstring(n, bits), do: << n :: size(bits) >>
end
