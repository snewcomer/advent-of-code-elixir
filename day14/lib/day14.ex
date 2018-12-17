defmodule Day14 do
  @input 9
  @start [3, 7]
  @chef_indices [0, 1]

  def part1 do
    circulate_recipes(@start, @chef_indices)
  end

  @doc """
  recipes = [3, 7, 1, 0]
  chefs = {indx, indx}

  1. sum total
  2. create new recipe and add to scoreboard
  3. move chefs equal to 1 + current recipe score

  ## Examples

      iex> Day14.circulate_recipes([3, 7], [0, 1])
      [5, 1, 5, 8, 9, 1, 6, 7, 7, 9]

  """
  def circulate_recipes(recipes, chef_indices) do
    recipes = append(recipes, chef_indices)
    chef_indices = assign_index_to_chef(recipes, chef_indices)

    case @input + 10 < length(recipes) do
      true -> Enum.slice(recipes, @input, 10)
      false -> circulate_recipes(recipes, chef_indices)
    end
  end

  @doc """

  ## Examples

      iex> Day14.assign_index_to_chef([3, 7], [0, 1])
      [0, 1]
      iex> Day14.assign_index_to_chef([3, 7, 1, 0, 1, 0], [0, 1])
      [4, 3]
      iex> Day14.assign_index_to_chef([3, 7, 1, 0, 1, 0, 1], [4, 3])
      [6, 4]
      iex> Day14.assign_index_to_chef([3, 7, 1, 0, 1, 0, 1, 2], [6, 4])
      [0, 6]
      iex> Day14.assign_index_to_chef([3, 7, 1, 0, 1, 0, 1, 2, 4], [0, 6])
      [4, 8]
      iex> Day14.assign_index_to_chef([3, 7, 1, 0, 1, 0, 1, 2, 4, 5], [4, 8])
      [6, 3]

  """
  def assign_index_to_chef([3, 7], _chef_indices), do: [0, 1]
  def assign_index_to_chef(recipes, [first, second]) do
    forward_1 = Enum.at(recipes, first) + 1
    forward_2 = Enum.at(recipes, second) + 1

    recipe_length = length(recipes)

    # how many can I fit in the array?
    remainder_1 = rem(forward_1, recipe_length)
    remainder_2 = rem(forward_2, recipe_length)

    # where am I at in the array after trying to fit?
    [rem((first + remainder_1), recipe_length), rem((second + remainder_2), recipe_length)]
  end

  @doc """

  ## Examples

      iex> Day14.append([3, 7], [0, 1])
      [3, 7, 1, 0]

  """
  def append(recipes, [first, second]) do
    score_1 = Enum.at(recipes, first)
    score_2 = Enum.at(recipes, second)

    [h | t] =
      score_1 + score_2
      |> Integer.to_string()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    case t != [] do
      true -> [t |> Enum.at(0), h | recipes |> Enum.reverse()] |> Enum.reverse()
      false -> [h | recipes |> Enum.reverse()] |> Enum.reverse()
    end
  end
end
