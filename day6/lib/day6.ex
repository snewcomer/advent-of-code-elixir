defmodule Day6 do
  @moduledoc """
  With a grid, find min/max of grid with data.  Then parse the coordinates into a list of tuples for each coordinate.
  Distance between two points is (x2 - x1) or (y2 - y1) == (2 - 1) or (1 - 1)
  """

  @doc """

  ## Examples

    iex> Day6.parse_coordinate("1, 3")
    {1, 3}

  """
  def parse_coordinate(input) do
    [x, y] = String.split(input, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end

  @doc """
  find min max of && y coordinates to build box around
  all coordinates

  ## Examples

      iex> Day6.bounding_box([
      ...>    {1, 1},
      ...>    {1, 6},
      ...>    {8, 3},
      ...>    {3, 4},
      ...>    {5, 5},
      ...>    {8, 9},
      ...>    {0, 0}
      ...>  ])
      {{0, 8}, {0, 9}}

  """
  def bounding_box(coordinates) do
    # Enum.min_max(coordinates, fn {x, y} -> {x, y} end)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, &elem(&1, 1))
    {{min_x, max_x}, {min_y, max_y}}
  end

  @doc """
  ## Examples

      iex> Day6.build_grid({{1, 2}, {1, 2}})
      [{1, 1}, {1, 2}, {2, 1}, {2, 2}]

  """
  def build_grid({{min_x, max_x}, {min_y, max_y}}) do
    for x <- min_x..max_x,
        y <- min_y..max_y do
      {x, y}
    end
  end

  @doc """
  ## Examples

      iex> Day6.classify_coordinates([{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}], [{1, 1}, {3, 3}])
      %{
        {1, 1} => {1, 1},
        {1, 2} => {1, 1},
        {1, 3} => nil,
        {2, 1} => {1, 1},
        {2, 2} => nil,
        {2, 3} => {3, 3},
        {3, 1} => nil,
        {3, 2} => {3, 3},
        {3, 3} => {3, 3}
      }

  """
  def classify_coordinates(all_coordinates, main_points) do
    for point <- all_coordinates,
        do: {point, classify_each_coordinate(point, main_points)},
        into: %{}
  end

  @doc """
  Any coordinate that has the same mnahattan distance, we mark as nil

  ## Examples

      iex> Day6.classify_each_coordinate({1, 2}, [{1, 1}, {2, 2}])
      nil

      iex> Day6.classify_each_coordinate({1, 1}, [{1, 1}, {3, 3}])
      {1, 1}

      iex> Day6.classify_each_coordinate({3, 2}, [{1, 1}, {3, 3}])
      {3, 3}

  """
  def classify_each_coordinate(point, main_points) do
    main_points
    |> Enum.map(&{manhattan_distance(&1, point), &1})
    |> Enum.sort()
    |> case do
      [{distance, _}, {distance, _} | _] -> nil
      [{_, coordinate} | _] -> coordinate
    end
  end

  @doc """
  ## Examples

      iex> Day6.infinite_coordinates(%{
      ...>    {1, 1} => {1, 1},
      ...>    {1, 2} => {1, 1},
      ...>    {1, 3} => nil,
      ...>    {2, 1} => {1, 1},
      ...>    {2, 2} => nil,
      ...>    {2, 3} => {3, 3},
      ...>    {3, 1} => nil,
      ...>    {3, 2} => {3, 3},
      ...>    {3, 3} => {3, 3}}, [1, 3], [1, 3])
      MapSet.new([{1, 1}, {3, 3}])
  """
  def infinite_coordinates(classified_grid_points, [x1, x2], [y1, y2]) do
    infinite_for_x =
      for y <- [y1, y2],
          x <- x1..x2,
          closest = classified_grid_points[{x, y}],
          do: closest

    infinite_for_y =
      for x <- [x1, x2],
          y <- y1..y2,
          closest = classified_grid_points[{x, y}],
          do: closest

    MapSet.new(infinite_for_x ++ infinite_for_y)
  end

  # @doc """
  # ## Examples

  #     iex> Day6.finite_coordinates(
  #     ...>    MapSet.new([nil, {1, 1}, {3, 3}]),
  #     ...>    %{
  #     ...>    {1, 1} => {1, 1},
  #     ...>    {1, 2} => {1, 1},
  #     ...>    {1, 3} => nil,
  #     ...>    {2, 1} => {1, 1},
  #     ...>    {2, 2} => nil,
  #     ...>    {2, 3} => {3, 3},
  #     ...>    {3, 1} => nil,
  #     ...>    {3, 2} => {3, 3},
  #     ...>    {3, 3} => {3, 3}})
  #     %{}
  # """
  def finite_coordinates(infinite_coordinates, classified_coordinates) do
    Enum.reduce(classified_coordinates, %{}, fn {_, coordinate}, acc ->
      if coordinate == nil or coordinate in infinite_coordinates do
        acc
      else
        Map.update(acc, coordinate, 1, & &1 + 1)
      end
    end)
  end

  def part1(input) do
    input
    |> File.read!()
    |> String.trim_trailing()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_coordinate/1)
    |> largest_finite_area()
  end

  @doc """
  ## Examples

      iex> Day6.largest_finite_area([
      ...>    {1, 1},
      ...>    {1, 6},
      ...>    {8, 3},
      ...>    {3, 4},
      ...>    {5, 5},
      ...>    {8, 9}
      ...>  ])
      17

  """
  def largest_finite_area(main_coords) do
    box = {{x1, x2}, {y1, y2}} = main_coords |> bounding_box()

    grid = box |> build_grid()

    classified_coordinates =
      grid
      |> classify_coordinates(main_coords)

    finite_coordinates =
      infinite_coordinates(classified_coordinates, [x1, x2], [y1, y2])
      |> finite_coordinates(classified_coordinates)

    {_coord, count} =
      Enum.max_by(finite_coordinates, fn {_, count} -> count end)

    count
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
