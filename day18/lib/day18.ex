defmodule Day18 do

  @types [:trees, :lumberyard, :open]

  def part1() do
    area =
      File.read!("priv/day18.in")
      |> String.trim_trailing()
      |> String.split("\n", trim: true)
      |> parse_area()
      |> evolve_many()

    count_types(area, :lumberyard) * count_types(area, :trees)
  end

  @doc """

  ## Examples

      iex> Day18.parse_area([
      ...> "|#.",
      ...> "|..",
      ...> "||."
      ...> ])
      %{
        {0, 0} => :trees,
        {0, 1} => :lumberyard,
        {0, 2} => :open,
        {1, 0} => :trees,
        {1, 1} => :open,
        {1, 2} => :open,
        {2, 0} => :trees,
        {2, 1} => :trees,
        {2, 2} => :open
      }

  """
  def parse_area(lines) do
    {area, _} =
      Enum.reduce(lines, {%{}, 0}, fn line, {area, row} ->
        {parse_line(line, area, row), row + 1}
      end)
    area
  end

  def parse_line(line, area, row) do
    {area, _column} =
      Enum.reduce(String.to_charlist(line), {area, 0}, fn point, {area, column} ->
        area = Map.put(area, {row, column}, classify_point(point))
        {area, column + 1}
      end)
      area
  end

  @doc """

      iex> Day18.find_adjacent({0, 0})
      [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]

  """
  def find_adjacent({x, y}) do
    [
      {x-1, y-1},
      {x, y-1},
      {x+1, y-1},
      {x-1, y},
      {x+1, y},
      {x-1, y+1},
      {x, y+1},
      {x+1, y+1}
    ]
  end

  def evolve(area) do
    for {point, type} <- area,
        do: {point, evolve_to(type, find_adjacent(point), area)},
        into: %{}
  end

  def evolve_to(:open, candidates, area) do
    if Enum.count(candidates, &(Map.get(area, &1) == :trees)) >= 3 do
      :trees
    else
      :open
    end
  end

  def evolve_to(:trees, candidates, area) do
    if Enum.count(candidates, &(Map.get(area, &1) == :lumberyard)) >= 3 do
      :lumberyard
    else
      :trees
    end
  end

  def evolve_to(:lumberyard, candidates, area) do
    if Enum.any?(candidates, &(Map.get(area, &1) == :lumberyard)) and
       Enum.any?(candidates, &(Map.get(area, &1) == :trees)) do
      :lumberyard
    else
      :open
    end
  end

  def evolve_many(area) do
    Enum.reduce(1..10, area, fn _, area -> evolve(area) end)
  end

  @doc """
  ## Examples

      iex> area = Day18.parse_area([
      ...> "|#.",
      ...> "|..",
      ...> "||."
      ...> ])
      iex> Day18.count_types(area, :lumberyard)
      1
      iex> Day18.count_types(area, :trees)
      4
      iex> Day18.count_types(area, :open)
      4
  """
  def count_types(area, type) when type in @types do
    Enum.count(area, fn {_, point_type} -> point_type == type end)
  end

  defp classify_point(?#), do: :lumberyard
  defp classify_point(?|), do: :trees
  defp classify_point(?.), do: :open
end
