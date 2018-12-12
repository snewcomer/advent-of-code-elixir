defmodule Day10 do
  def part1(input) do
    input
    |> File.read!()
    |> String.trim_trailing()
    |> String.split("\n", trim: true)
    |> build_stars()
    |> move_until_align([])
    |> print_grid()
  end

  @doc """
  move points by velocity until figure total area is not expanding

  ## Examples

      iex> Day10.build_stars([
      ...>   "position=< 9,  1> velocity=< 0,  2>",
      ...>   "position=< 7,  0> velocity=<-1,  0>",
      ...>   "position=< 3, -2> velocity=<-1,  1>",
      ...> ])
      [
        [9, 1, 0, 2],
        [7, 0, -1, 0],
        [3, -2, -1, 1]
      ]

  """
  def build_stars(input) do
    Enum.map(input, fn star ->
      Regex.run(
        ~r{\Aposition=<\s*(-?\d+),\s+(-?\d+)>\s+velocity=<\s*(-?\d+),\s+(-?\d+)>},
        star,
        capture: :all_but_first
      )
      |> Enum.map(&String.to_integer/1)
    end)
  end

  @doc """
  move points by velocity until figure total area is not expanding

  ## Examples

      iex> stars = Day10.build_stars([
      ...>   "position=< 9,  1> velocity=< 0,  2>",
      ...>   "position=< 7,  0> velocity=<-1,  0>",
      ...>   "position=< 3, -2> velocity=<-1,  1>",
      ...>   "position=< 6, 10> velocity=<-2, -1>",
      ...>   "position=< 2, -4> velocity=< 2,  2>",
      ...>   "position=<-6, 10> velocity=< 2, -2>",
      ...>   "position=< 1,  8> velocity=< 1, -1>",
      ...>   "position=< 1,  7> velocity=< 1,  0>",
      ...>   "position=<-3, 11> velocity=< 1, -2>",
      ...>   "position=< 7,  6> velocity=<-1, -1>",
      ...>   "position=<-2,  3> velocity=< 1,  0>",
      ...>   "position=<-4,  3> velocity=< 2,  0>",
      ...>   "position=<10, -3> velocity=<-1,  1>",
      ...>   "position=< 5, 11> velocity=< 1, -2>",
      ...>   "position=< 4,  7> velocity=< 0, -1>",
      ...>   "position=< 8, -2> velocity=< 0,  1>",
      ...>   "position=<15,  0> velocity=<-2,  0>",
      ...>   "position=< 1,  6> velocity=< 1,  0>",
      ...>   "position=< 8,  9> velocity=< 0, -1>",
      ...>   "position=< 3,  3> velocity=<-1,  1>",
      ...>   "position=< 0,  5> velocity=< 0, -1>",
      ...>   "position=<-2,  2> velocity=< 2,  0>",
      ...>   "position=< 5, -2> velocity=< 1,  2>",
      ...>   "position=< 1,  4> velocity=< 2,  1>",
      ...>   "position=<-2,  7> velocity=< 2, -2>",
      ...>   "position=< 3,  6> velocity=<-1, -1>",
      ...>   "position=< 5,  0> velocity=< 1,  0>",
      ...>   "position=<-6,  0> velocity=< 2,  0>",
      ...>   "position=< 5,  9> velocity=< 1, -2>",
      ...>   "position=<14,  7> velocity=<-2,  0>",
      ...>   "position=<-3,  6> velocity=< 2, -1>"
      ...> ])
      iex> Day10.move_until_align(stars, [])
      [
        [9, 7, 0, 2],
        [4, 0, -1, 0],
        [0, 1, -1, 1],
        [0, 7, -2, -1],
        [8, 2, 2, 2],
        [0, 4, 2, -2],
        [4, 5, 1, -1],
        [4, 7, 1, 0],
        [0, 5, 1, -2],
        [4, 3, -1, -1],
        [1, 3, 1, 0],
        [2, 3, 2, 0],
        [7, 0, -1, 1],
        [8, 5, 1, -2],
        [4, 4, 0, -1],
        [8, 1, 0, 1],
        [9, 0, -2, 0],
        [4, 6, 1, 0],
        [8, 6, 0, -1],
        [0, 6, -1, 1],
        [0, 2, 0, -1],
        [4, 2, 2, 0],
        [8, 4, 1, 2],
        [7, 7, 2, 1],
        [4, 1, 2, -2],
        [0, 3, -1, -1],
        [8, 0, 1, 0],
        [0, 0, 2, 0],
        [8, 3, 1, -2],
        [8, 7, -2, 0],
        [3, 3, 2, -1]
      ]

  """
  def move_until_align(stars, acc) do
    new_stars =
      stars
      |> move_once()

    area = area_of_stars(new_stars)
    last_area = acc |> Enum.at(0)

    acc = put_area(area, acc)

    area
    |> is_area_larger_than_last?(last_area)
    |> case do
      false -> move_until_align(new_stars, acc)
      true -> stars
    end
  end

  @doc """
  move points by velocity until figure total area is not expanding

  ## Examples

      iex> Day10.move_once([[9, 1, 0, 2], [7, 0, -1, 0], [3, -2, -1, 1]])
      [
        [9, 3, 0, 2],
        [6, 0, -1, 0],
        [2, -1, -1, 1]
      ]

  """
  def move_once(stars) do
    Enum.map(stars, fn [x, y, x_speed, y_speed] ->
      [x + x_speed, y + y_speed, x_speed, y_speed]
    end)
  end

  @doc """
  move points by velocity until figure total area is not expanding

  ## Examples

      iex> Day10.area_of_stars([[9, 1, 0, 2], [7, 0, -1, 0], [3, -2, -1, 1]])
      18

  """
  def area_of_stars(stars) do
    {{low_x, low_y}, {high_x, high_y}} = build_bounding_box(stars)

    (high_x - low_x) * (high_y - low_y)
  end

  @doc """

  ## Examples

      iex> Day10.build_bounding_box([[9, 1, 0, 2], [7, 0, -1, 0], [3, -2, -1, 1]])
      {{3, -2}, {9, 1}}

  """
  def build_bounding_box(stars) do
    {low_x, high_x} = Enum.map(stars, fn [x, _, _, _] -> x end) |> Enum.min_max()
    {low_y, high_y} = Enum.map(stars, fn [_, y, _, _] -> y end) |> Enum.min_max()

    {{low_x, low_y}, {high_x, high_y}}
  end

  @doc """

  ## Examples

      iex> Day10.is_area_larger_than_last?(10, 11)
      false

      iex> Day10.is_area_larger_than_last?(10, 9)
      true

  """
  def is_area_larger_than_last?(_area, nil), do: false
  def is_area_larger_than_last?(area, last_area) do
    area > last_area
  end

  def put_area(area, acc), do: [area | acc]

  def print_grid(stars) do
    map_of_x_y =
      for [x, y, x_speed, y_speed] <- stars,
          do: {{x, y}, {x_speed, y_speed}},
          into: %{}

    {{low_x, low_y}, {high_x, high_y}} = build_bounding_box(stars)

    Enum.map(low_y..high_y, fn y ->
      Enum.reduce(low_x..high_x, "", fn x, row ->
        row <>
          case map_of_x_y[{x, y}] do
            nil -> "."
            _star -> "#"
          end
      end)
    end)
  end
end
