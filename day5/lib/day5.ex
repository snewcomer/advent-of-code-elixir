defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

  @doc """

  ## Examples

      iex> Day5.blow_up("dabAcCaCBAcCcaDA")
      10

  """
  def blow_up(str) do
    combust(str, [])
  end

  def combust(<<letter1, rest::binary>>, [letter2 | acc]) when abs(letter1 - letter2) == 32 do
    combust(rest, acc)
  end
  def combust(<<letter1, rest::binary>>, acc) do
    combust(rest, [letter1 | acc])
  end
  def combust(<<>>, acc) do
    acc |> List.to_string() |> byte_size()
  end

  def part1(input) do
    input
    |> File.read!()
    |> blow_up()
  end
end
