defmodule Day20 do

  @type cardinality :: :east | :west | :south | :north
  @type branch :: [cardinality]
  @type path :: [cardinality | branch]

  def part1(input) do
      input
      |> File.read!()
      |> String.trim_trailing()
      |> parse_routes()
      |> walk_map(0)
  end

  @doc """

  ## Examples

      iex> Day20.parse_routes("^ENW(NEEE|SS|)$")
      [:east, :north, :west]

      iex> Day20.parse_routes("^ENWWW(NEEE|SSE(EE|))$")
      [:east, :north, :west, :west, :west, [
        [:north, :east, :east, :east],
        [:south, :south, :east]
      ]]

  """
  def parse_routes(input) when is_binary(input) do
    size = byte_size(input) - 2
    <<"^", string::binary-size(size), "$">> = input
    parse_routes(string, [], [], [])
  end

  def parse_routes(<<?N, rest::binary>>, acc, branches, stack), do: parse_routes(rest, [:north | acc], branches, stack)
  def parse_routes(<<?W, rest::binary>>, acc, branches, stack), do: parse_routes(rest, [:west | acc], branches, stack)
  def parse_routes(<<?E, rest::binary>>, acc, branches, stack), do: parse_routes(rest, [:east | acc], branches, stack)
  def parse_routes(<<?S, rest::binary>>, acc, branches, stack), do: parse_routes(rest, [:south | acc], branches, stack)

  def parse_routes(<<?(, rest::binary>>, acc, branches, stack) do
    parse_routes(rest, [], [], [{acc, branches} | stack])
  end
  def parse_routes(<<?|, rest::binary>>, acc, branches, stack) do
    parse_routes(rest, [], [Enum.reverse(acc) | branches], stack)
  end
  def parse_routes(<<?), rest::binary>>, [], _branches, [{prev_acc, prev_branches} | stack]) do
    parse_routes(rest, prev_acc, prev_branches, stack)
  end
  def parse_routes(<<?), rest::binary>>, acc, branches, [{prev_acc, prev_branches} | stack]) do
    branches = [Enum.reverse(acc) | branches]
    parse_routes(rest, [Enum.reverse(branches) | prev_acc], prev_branches, stack)
  end
  def parse_routes(<<>>, acc, _branches, _stack), do: Enum.reverse(acc)

  @doc """
  ## Examples

    iex> routes = Day20.parse_routes("^WNE$")
    iex> Day20.walk_map(routes, 0)
    3

    iex> routes = Day20.parse_routes("^ENWWW(NEEE|SSE(EE|N))$")
    iex> Day20.walk_map(routes, 0)
    10

    iex> routes = Day20.parse_routes("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
    iex> Day20.walk_map(routes, 0)
    18

  """
  def walk_map([cardinality | routes], acc) when is_atom(cardinality) do
    # add one for a new door
    walk_map(routes, acc + 1)
  end

  def walk_map([branches], acc) when is_list(branches) do
    Enum.map(branches, &walk_map(&1, acc)) |> Enum.max()
  end

  def walk_map([], acc), do: acc
end
