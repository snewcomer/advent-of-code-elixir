defmodule Day25 do
  def part1 do
    Aoc.input_lines() |> parse() |> find_constellation() |> length()
  end

  @doc """

    ## Examples

      iex> Day25.parse(\"""
      ...> -1,2,2,0
      ...> 0,0,2,-2
      ...> 0,0,0,-2
      ...> -1,2,0,0
      ...> -2,-2,-2,2
      ...> 3,0,2,-1
      ...> -1,3,2,2
      ...> -1,0,-1,0
      ...> 0,2,1,-2
      ...> 3,0,0,0
      ...> \""")
      [
        {-1, 2, 2, 0},
        {0, 0, 2, -2},
        {0, 0, 0, -2},
        {-1, 2, 0, 0},
        {-2, -2, -2, 2},
        {3, 0, 2, -1},
        {-1, 3, 2, 2},
        {-1, 0, -1, 0},
        {0, 2, 1, -2},
        {3, 0, 0, 0}
      ]
  """
  def parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end
  end

  @doc """
  Store constellation like so
  %{
    random_int => [{coord}, {coord}]
  }
  Store coordinate keys like so
  %{
    {1,1,1,1} => random_int
  }

    ## Examples

      iex> input = Day25.parse(\"""
      ...> -1,2,2,0
      ...> 0,0,2,-2
      ...> 0,0,0,-2
      ...> -1,2,0,0
      ...> -2,-2,-2,2
      ...> 3,0,2,-1
      ...> -1,3,2,2
      ...> -1,0,-1,0
      ...> 0,2,1,-2
      ...> 3,0,0,0
      ...> \""")
      iex> result = Day25.find_constellation(input)
      iex> length(result)
      4
  """
  def find_constellation(input) do
    find_constellation(input, %{}, %{})
  end

  def find_constellation([head | rest], coords, constellations) do
    {neighbors, constellations} =
      Enum.flat_map_reduce(rest, constellations, fn coord, acc ->
        if distance(coord, head) <= 3 do
          constellation = Map.get(coords, coord)
          # in case already known constellation with keys, then pop it off and
          # rebuild below
          Map.pop(acc, constellation, [coord])
        else
          {[], acc}
        end
      end)

    # get possible constellation or build new
    constellation = Map.get(coords, head) || make_ref()
    old_coords = Map.get(constellations, constellation, [head])
    new_coords = old_coords ++ neighbors

    coordinate_keys = Enum.reduce(new_coords, coords, &Map.put(&2, &1, constellation))
    constellations = Map.put(constellations, constellation, new_coords)

    find_constellation(rest, coordinate_keys, constellations)
  end

  def find_constellation([], _coord_keys, constellation_keys) do
    Map.values(constellation_keys)
  end

  defp distance({x, y, z, t}, {x2, y2, z2, t2}) do
    abs(x - x2) + abs(y - y2) + abs(z - z2) + abs(t - t2)
  end
end
