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
    |> String.trim_trailing()
    |> blow_up()
  end

  def part2(input) do
    input
    |> File.read!()
    |> String.trim_trailing()
    |> find_problematic_unit()
  end

  @doc """
  So here we want to take a string, traverse the string, store the codepoint, then analyze the size
  after blow_up and store the length.  Need to keep track of position in string

  ## Examples

      iex> Day5.find_problematic_unit("dabAcCaCBAcCcaDA")
      4
  """
  def find_problematic_unit(str) do
    l =
      for letter <- ?A..?Z do
        str
        |> remove_letter(letter)
        |> blow_up()
      end

    Enum.min(l)
  end

  defp remove_letter(str, letter) do
    letter = List.to_string([letter])

    str
    |> String.replace(String.upcase(letter), "")
    |> String.replace(String.downcase(letter), "")
  end
end
