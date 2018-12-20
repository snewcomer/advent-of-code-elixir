defmodule Day17 do
  defmodule Position do
    alias __MODULE__

    @enforce_keys [:x, :y]
    defstruct [:x, :y]

    def new(x, y), do: %Position{x: x, y: y}

    def left(pos), do: %Position{pos | x: pos.x - 1}
    def right(pos), do: %Position{pos | x: pos.x + 1}
    def up(pos), do: %Position{pos | y: pos.y - 1}
    def down(pos), do: %Position{pos | y: pos.y + 1}
  end

  @doc """
    ## Examples

      iex> Day17.part1()
      57

  """
  def part1(day \\ "17-test") do
    starting = Position.new(500, 0)
    map = Aoc.input_lines(2018, day) |> build_clay()
    bounds = y_boundary(map)

    expand_water(map, starting, bounds)
    |> Map.values()
    |> Enum.filter(& &1 == :water or &1 == :flow)
    |> Enum.count()
  end

  @doc """
    ## Examples

      iex> %{%Day17.Position{x: 301, y: 708} => type} = Day17.build_clay(["x=301, y=708..728"])
      iex> type
      :clay

  """
  def build_clay(input) do
    Stream.flat_map(input, &positions/1)
    |> MapSet.new()
    |> Stream.map(&{&1, :clay})
    |> Map.new()
  end

  @doc """
    ## Examples

      iex> clay = Day17.build_clay(["x=301, y=708..728"])
      iex> bounds = Day17.y_boundary(clay)
      iex> %{%Day17.Position{x: 301, y: 708} => state} = Day17.expand_water(clay, %Day17.Position{x: 302, y: 707}, bounds)
      iex> state
      :clay

  """
  def expand_water(map, %Day17.Position{x: _x, y: bottom}, {_top, bottom}) do
    map
  end
  def expand_water(map, new_pos, bottom) do
    {placed_pos, new_state} =
      new_pos
      |> determine_next_pos(map)

    expand_water(Map.put(map, placed_pos, new_state), placed_pos, bottom)
  end

  @doc """
    ## Examples

      iex> clay = Day17.build_clay(["x=301, y=708..728"])
      iex> Day17.determine_next_pos(%Day17.Position{x: 301, y: 709}, clay)
      {%Day17.Position{x: 302, y: 709}, :flow}

  """
  def determine_next_pos(pos, map) do
    down = Position.down(pos)
    right = Position.right(pos)
    left = Position.left(pos)
    up = Position.up(pos)

    down_state = Map.get(map, down)
    right_state = Map.get(map, right)
    left_state = Map.get(map, left)
    up_state = Map.get(map, up, :flow)

    cond do
      is_moveable(down_state) -> {down, place_in_sand(down_state)}
      is_moveable(right_state) -> {right, place_in_sand(right_state)}
      is_moveable(left_state) -> {left, place_in_sand(left_state)}
      true -> {up, place_in_sand(up_state)}
    end
  end

  defp place_in_sand(:flow), do: :water
  defp place_in_sand(_), do: :flow

  defp is_moveable(:water), do: false
  defp is_moveable(:clay), do: false
  defp is_moveable(:flow), do: true
  defp is_moveable(_), do: true

  defp positions(line) do
    %{"value_dimension" => value_dimension, "value" => value, "range_dimension" => range_dimension, "from" => from, "to" => to} =
      Regex.named_captures(~r/(?<value_dimension>[xy])=(?<value>\d+),\s*(?<range_dimension>[xy])=(?<from>\d+)\.\.(?<to>\d+)$/, line)

    value = String.to_integer(value)

    String.to_integer(from)..String.to_integer(to)
    |> Stream.map(&%{value_dimension => value, range_dimension => &1})
    |> Stream.map(&Position.new(Map.fetch!(&1, "x"), Map.fetch!(&1, "y")))
  end

  def y_boundary(map) do
    Enum.map(map, fn {pos, _} ->
      pos.y
    end)
    |> Enum.min_max()
  end

end
