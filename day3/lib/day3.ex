defmodule Day3 do
  @moduledoc """
  Documentation for Day3.

  End result if square inches that are shared by two or more claims.

  So we can build an accumulator that checks each entry and the corresponding
  x,y coordinate in whatever data structure we use.  Likely a map

  If the Elves all proceed with their own plans, none of them will have enough fabric.
  How many square inches of fabric are within two or more claims?
  """

  @type claim :: String.t
  @type parsed_claim :: list
  @type coordinate :: {pos_integer, pos_integer}
  @type id :: integer

  @spec unique_claim([claim]) :: id
  def unique_claim(lines) do
    map =
      lines
      |> total_claimed_inches()

    all_ids = MapSet.new(1..length(lines))

    remaining_ids =
      Enum.reduce(map, all_ids, fn {{_x, _y}, ids}, all_ids ->
        remaining_ids =
          case ids do
            [_unique_id] -> all_ids
            [_ | _] -> delete_ids(ids, all_ids)
            nil -> all_ids
          end

        remaining_ids
      end)

    [id] = MapSet.to_list(remaining_ids)
    id
  end

  defp delete_ids([head | tail], all_ids) do
    remaining_ids = MapSet.delete(all_ids, head)
    delete_ids(tail, remaining_ids)
  end
  defp delete_ids([], all_ids), do: all_ids

  @spec total_square_inches([claim]) :: integer
  def total_square_inches(lines) do
    lines
    |> overlapping_inches()
    |> length()
  end

  @doc """
  Now that we have all the x,y coordinates, then we can see which coordinates
  share with ids
  [{4, 4}, {4, 5}, {5, 4}]
  """
  @spec overlapping_inches([claim]) :: [coordinate]
  def overlapping_inches(lines) do
    map =
      lines
      |> total_claimed_inches()

    for {coordinate, [_, _ | _]} <- map do
      coordinate
    end
  end

  @doc """
  here we are going to build a Map to hold each coordinate
  with the corresonding id
  %{
    {2, 6} => [1]
    {4, 4} => [2, 1]
  }
  """
  @spec total_claimed_inches([claim]) :: %{coordinate => [id]}
  def total_claimed_inches(lines) do
    lines
    |> parse_input()
    |> Enum.reduce(%{}, fn {id, {left, top}, {w, h}}, acc ->
      Enum.reduce((left + 1)..(left + w), acc, fn x, acc ->
        Enum.reduce((top + 1)..(top + h), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  @doc """
  returns
    [
      {1, {100,366}, {24,27}}
      {2, {726,271}, {11,15}}
    ]
  """
  @spec parse_input([claim]) :: parsed_claim
  def parse_input(lines) do
    lines
    |> Enum.map(&convert_to_tuple(&1))
  end

  defp convert_to_tuple(line) when is_binary(line) do
    [id, left, top, w, h] =
      line
      |> String.split(["#", " @ ", ",", ": ", "x"], trim: true)
      |> Enum.map(&String.to_integer/1)

    {id, {left, top}, {w, h}}
  end
end
