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

      iex> area = Day22.build_grid()
      iex> Map.get(area, {0, 0})
      {5913, 0}
      iex> Map.get(area, {1, 0})
      {2537, 2}

  """
  def build_grid do
    0..8
    |> Enum.reduce(%{}, fn x, acc ->
      0..701
      |> Enum.reduce(acc, fn y, acc ->
        Map.put(acc, {x, y}, calculate_erosion_level_region_type({x, y}, acc))
      end)
    end)
  end

  @doc """

  ## Examples

      iex> grid = Day22.build_grid()
      iex> Day22.calculate_erosion_level_region_type({0, 0}, grid)
      {5913, 0}

  """
  def calculate_erosion_level_region_type({x, y}, area) do
    erosion_level =
      case {x, y} do
        {0, 0} -> erosion_level(0)
        {x, 0} -> geo_index_1(x) |> erosion_level()
        {0, y} -> geo_index_2(y) |> erosion_level()
        {x, y} -> geo_index_3({x, y}, area) |> erosion_level()
      end

    case determine_region_type(erosion_level) do
      0 -> {erosion_level, 0}
      1 -> {erosion_level, 1}
      2 -> {erosion_level, 2}
    end
  end

  @doc """

  ## Examples

      iex> grid = Day22.build_grid()
      iex> Day22.find_risk_level(grid)
      6256

  """
  def find_risk_level(area) do
    Enum.reduce(area, 0, fn {_, {_, risk_type}}, acc ->
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

  defp geo_index_3({x, y}, area) do
    {erosion_1, _} = Map.get(area, {x-1, y})
    {erosion_2, _} = Map.get(area, {x, y-1})
    erosion_1 * erosion_2
  end
end
