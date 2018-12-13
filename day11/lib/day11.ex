defmodule Day11 do

  @doc """
  ## Examples

      iex> Day11.part1(7857)
      {243, 16}

  """
  def part1(input) do
    build_grid(input)
    |> find_largest_area()
    |> elem(0)
  end

  @doc """
  300x300 grid of {x, y} coordinates

  ## Examples

      iex> Day11.build_grid(29) |> Enum.sort() |> Enum.at(0)
      {{1, 1}, -1}

  """
  def build_grid(power_level) do
    for x <- 1..300,
        y <- 1..300,
        into: %{},
        do: {{x, y}, calc_power_level({x, y}, power_level)}
  end

  @doc """
  Note grid is already sorted b/c we built it that way

  ## Examples

      iex> grid = Day11.build_grid(18)
      iex> Day11.find_largest_area(grid)
      {{33, 45}, 29}

  """
  def find_largest_area(grid) do
    Enum.reduce(grid, %{}, fn {{x, y}, _power_level}, acc ->
      sum =
        find_3x3(grid, {x, y})
        |> Enum.sum()

      Map.put(acc, {x, y}, sum)
    end)
    |> Enum.max_by(&elem(&1, 1))
  end

  defp find_3x3(grid, {x, y}) do
    higher_x = min(x + 2, 300)
    higher_y = min(y + 2, 300)

    for x <- x..higher_x,
        y <- y..higher_y,
        do: Map.fetch!(grid, {x, y})
  end

  @doc """

  ## Examples

      iex> Day11.calc_power_level({3, 5}, 8)
      4
      iex> Day11.calc_power_level({122, 79}, 57)
      -5
      iex> Day11.calc_power_level({217, 196}, 39)
      0

  """
  def calc_power_level({x, y}, serial_number) do
    rack_id =
      x
      |> Kernel.+(10)

    rack_id
    |> Kernel.*(y)
    |> Kernel.+(serial_number)
    |> Kernel.*(rack_id)
    |> rem(1000) # find hundreds digit with modulo operator and division
    |> div(100)
    |> trunc()
    |> Kernel.-(5)
  end

  # defp parse_int(num) do
  #   case num >= 1 do
  #     true -> parse_int(num / 10)
  #     false -> num |> Kernel.trunc()
  #   end
  # end
end
