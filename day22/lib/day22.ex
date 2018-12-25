defmodule Day22 do
  @moduledoc """
  The region at 0,0 (the mouth of the cave) has a geologic index of 0.
  The region at the coordinates of the target has a geologic index of 0.
  If the region's Y coordinate is 0, the geologic index is its X coordinate times 16807.
  If the region's X coordinate is 0, the geologic index is its Y coordinate times 48271.
  Otherwise, the region's geologic index is the result of multiplying the erosion levels of the regions at X-1,Y and X,Y-1.

  erosion level = geo index + depth % 20183
  erosion level % 3
  """

  @depth 5913

  def part1() do
    build_grid()
    |> find_risk_level()
  end

  @doc """

  ## Examples

      # iex> Day22.part2()
      # 235

  """
  def part2() do
     TODO
    grid = build_grid()

    dfs(grid, [{0, 0}], MapSet.new([{0, 0}]), [])
    |> process_paths()
    |> Enum.reject(& !Enum.member?(&1, {3, 3}))
    |> Enum.map(fn paths ->
      Enum.reduce(paths, {0, 0}, fn coord, {time, current_type} ->
        {_, state_type} = Map.get(grid, coord)
        case state_type == current_type do
          true -> {1 + time, state_type}
          false -> {7 + time, state_type}
        end
      end)
    end)
    |> Enum.max_by(fn {time, _} -> time end)
    |> elem(0)
  end

  @doc """

  ## Examples

      iex> graph = Day22.build_grid()
      iex> Map.get(graph, {0, 0})
      {5913, 0}
      iex> Map.get(graph, {1, 0})
      {2537, 2}

  """
  def build_grid do
    0..3
    |> Enum.reduce(%{}, fn x, acc ->
      0..3
      |> Enum.reduce(acc, fn y, acc ->
        Map.put(acc, {x, y}, calculate_erosion_level_region_type({x, y}, acc))
      end)
    end)
  end

  @doc """
  :torch
  :climbing_gear
  :neither

  . -> {:climbing_gear, :torch}
  = -> {:climbing_gear, :neither}
  | -> {:torch, :neither}

  1min -> no tool change
  7min -> change tools
  end with :torch

  dfs algorithm queue each adjacent node as long as within the graph.
  Keep processing until can no longer process in grid
  keep queuing {x, y} to internal array and updating time
  add new node (queue to outer array) when branch off
  [
    [{0, 0}, [{1, 0}, [{2, 0}]]]
  ]
  |> Enum.reduce and find lowest

  ## Examples

      # iex> graph = Day22.build_grid()
      # iex> seen = Day22.dfs(graph, [{0, 0}], MapSet.new([{0, 0}]))
      # iex> Day22.process_paths(seen) |> Enum.at(0)
      # [{1, 111}, {7, 602}, {3, 3}, {6, 90}, {1, 67}]

  """
  def process_paths(seen) do
    seen
    |> Enum.chunk_while([], fn item, acc ->
      if item > List.last(acc) do
        {:cont, [item | acc]}
      else
        {:cont, Enum.reverse([item | acc]), []}
      end
    end, fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end
    )
  end

  @doc """
  We are going to build an array that we can walk over later to calculate the times
  However, the first thing we need to do is walk to the Target, then filter out ones that
  dont reach, then find lowest common denominator

  ## Examples

      iex> graph = Day22.build_grid()
      iex> Day22.dfs(graph, [{0, 0}], MapSet.new([{0, 0}]), [])
      []

  """
  def dfs(_graph, [], seen, acc), do: acc
  def dfs(graph, unseen, seen, acc) do
    set_of_neighbors =
      for coord <- unseen do
        expand_nodes(coord) |> MapSet.new()
      end
      |> prune_seen(seen)

    # move through each neighbor and process their child_nodes until no child nodes
    child_nodes = Enum.reduce(set_of_neighbors, [], fn coord, acc ->
      dfs(
        graph,
        [coord],
        MapSet.union(seen, MapSet.new(set_of_neighbors)),
        [coord | acc]
      )
    end)

    [child_nodes | acc]
  end

  @doc """

  ## Examples

      # iex> unseen = Day22.expand_nodes({3, 3}) |> MapSet.new()
      # iex> Day22.prune_seen([unseen], MapSet.new([{3, 2}, {1, 2}]))
      # [{2, 3}, {3, 4}, {4, 3}]

  """
  def prune_seen(unseen, seen) do
    unseen
    |> Enum.reduce(MapSet.new(), &MapSet.union/2)
    |> MapSet.difference(seen)
    |> MapSet.to_list()
  end

  @doc """

  ## Examples

      iex> Day22.expand_nodes({0, 0})
      [{0, 1}, {1, 0}]
      iex> Day22.expand_nodes({2, 1})
      [{2, 0}, {2, 2}, {1, 1}, {3, 1}]

  """
  def expand_nodes({x, y}) do
    Enum.filter([{x, y-1}, {x, y+1}, {x-1, y}, {x+1, y}], fn {x, y} -> x >=0 and y >= 0 and x <= 3 and y <= 3 end)
  end

  @doc """
  ## Examples

      iex> Day22.concat_lists([{2, 1}], [{3, 4}])
      [{3, 4}, {2, 1}]
      iex> Day22.concat_lists([{2, 1}], [])
      [{2, 1}]

  """
  def concat_lists(list1, list2) do
    Enum.reduce(list1, list2, fn coord, acc ->
      [coord | acc] |> Enum.reverse()
    end)
    |> Enum.reject(& &1 == [])
  end

  @doc """

  ## Examples

      iex> grid = Day22.build_grid()
      iex> Day22.calculate_erosion_level_region_type({0, 0}, grid)
      {5913, 0}

  """
  def calculate_erosion_level_region_type({x, y}, graph) do
    erosion_level =
      case {x, y} do
        {0, 0} -> erosion_level(0)
        {x, 0} -> geo_index_1(x) |> erosion_level()
        {0, y} -> geo_index_2(y) |> erosion_level()
        {x, y} -> geo_index_3({x, y}, graph) |> erosion_level()
      end

    case determine_region_type(erosion_level) do
      0 -> {erosion_level, 0}
      1 -> {erosion_level, 1}
      2 -> {erosion_level, 2}
    end
  end

  @doc """

  ## Examples

      # iex> grid = Day22.build_grid()
      # iex> Day22.find_risk_level(grid)
      # 6256

  """
  def find_risk_level(graph) do
    Enum.reduce(graph, 0, fn {_, {_, risk_type}}, acc ->
      acc + risk_type
    end)
  end

  @doc """

  ## Examples

      iex> Day22.erosion_level(0)
      5913
      iex> Day22.erosion_level(48271)
      13818

  """
  def erosion_level(geo_index) do
    rem(geo_index + @depth, 20183)
  end

  @doc """

  ## Examples

      iex> Day22.determine_region_type(510)
      0
      iex> Day22.determine_region_type(8415)
      0

  """
  def determine_region_type(erosion_level) do
    rem(erosion_level, 3)
  end

  defp geo_index_1(x) do
    x * 16807
  end

  defp geo_index_2(y) do
    y * 48271
  end

  defp geo_index_3({x, y}, graph) do
    {erosion_1, _} = Map.get(graph, {x-1, y})
    {erosion_2, _} = Map.get(graph, {x, y-1})
    erosion_1 * erosion_2
  end
end
