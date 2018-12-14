defmodule Day12 do

  def part1() do
    row =
      File.read!("day12-input.txt")
      |> String.trim_trailing()
      |> build_row()

    rule_set =
      File.read!("day12-notes.txt")
      |> String.trim_trailing()
      |> String.split("\n", trim: true)
      |> parse_notes()

    Enum.reduce_while(0..19, row, fn i, row ->
      if i > 19, do: {:halt, row}, else: {:cont, walk_row(row, rule_set)}
    end)
    |> Enum.reduce(0, fn {step, indx}, acc ->
      cond do
        step == 1 -> indx + acc
        true -> 0 + acc
      end
    end)
  end

  @doc """
  Represent each row by [1, 0, 0, 1....]

  ## Examples

      iex> Day12.build_row("initial state: #..#.#..##......###...###")
      [1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1]

  """
  def build_row(<<"initial state: ", rest::binary>>), do: build(rest)
  def build_row(input), do: build(input)

  defp build(input) do
    input
    |> String.replace(~r/#/, "1")
    |> String.replace(~r/\./, "0")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Represent each row by {[0, 0, 0, 1, 1], 1}

  ## Examples

      iex> Day12.parse_notes([
      ...> "...## => #",
      ...> "#..## => ."
      ...> ])
      [
        {[0, 0, 0, 1, 1], 1},
        {[1, 0, 0, 1, 1], 0}
      ]

  """
  def parse_notes(notes) do
    for note <- notes,
        note = parse_llcrr(note),
        do: note
  end

  @doc """
  Represent each row by {[0, 0, 0, 1, 1], 1}

  ## Examples

      iex> Day12.parse_llcrr("...## => #")
      {[0, 0, 0, 1, 1], 1}

  """
  def parse_llcrr(input) do
    [str, step] =
      input
      |> String.replace(~r/#/, "1")
      |> String.replace(~r/\./, "0")
      |> String.split(" => ")

    {String.graphemes(str) |> Enum.map(&String.to_integer/1), String.to_integer(step)}
  end

  @doc """
  Start at index 0, see if any rules match and replace, extending list if necessary
  Move to next index and repeat

  ## Examples

      iex> row = Day12.build_row("initial state: #..#.#..##......###...###")
      iex> rule_set = [
      ...>    {[0, 0, 0, 1, 1], 1},
      ...>    {[0, 0, 1, 0, 0], 1},
      ...>    {[0, 1, 0, 0, 0], 1},
      ...>    {[0, 1, 0, 1, 0], 1},
      ...>    {[0, 1, 0, 1, 1], 1},
      ...>    {[0, 1, 1, 0, 0], 1},
      ...>    {[0, 1, 1, 1, 1], 1},
      ...>    {[1, 0, 1, 0, 1], 1},
      ...>    {[1, 0, 1, 1, 1], 1},
      ...>    {[1, 1, 0, 1, 0], 1},
      ...>    {[1, 1, 0, 1, 1], 1},
      ...>    {[1, 1, 1, 0, 0], 1},
      ...>    {[1, 1, 1, 0, 1], 1},
      ...>    {[1, 1, 1, 1, 0], 1}
      ...> ]
      iex> result = Day12.walk_row(row, rule_set)
      iex> Enum.at(result, 2)
      {1, 0}
      iex> Enum.at(result, 11)
      {1, 9}

  """
  def walk_row(row, rule_set) do
    row
    |> pad()
    |> Enum.chunk_every(5, 1, :discard)
    |> Enum.map(fn chunk ->
      indexs = build_indices(chunk)

      steps =
        case item_matches_any_rule?(chunk, rule_set) do
          nil -> [0, 0, 0, 0, 0]
          rule -> process(chunk, rule)
        end

      Enum.zip(steps, indexs)
    end)
    |> Enum.map(fn chunk ->
      Enum.slice(chunk, 2..2) |> Enum.at(0)
    end)
  end

  @doc """

  ## Examples

      iex> Day12.process([0, 0, 1, 1, 1], {[0, 0, 0, 1, 1], 1})
      [0, 0, 1, 1, 1]

  """
  def process(chunk, {_rule, step}) do
    start =
      chunk
      |> Enum.slice(0..1)

    last =
      chunk
      |> Enum.slice(3..4)

    start ++ [step] ++ last
  end

  defp build_steps(chunk) do
    chunk
    |> Enum.reduce([], fn {step, _indx}, acc ->
      [step | acc]
    end)
    |> Enum.reverse()
  end

  defp build_indices(chunk) do
    chunk
    |> Enum.reduce([], fn {_step, indx}, acc ->
      [indx | acc]
    end)
    |> Enum.reverse()
  end

  defp pad(row) do
    case Enum.at(row, 0) do
      item when is_integer(item) -> [0, 0, 0, 0 | row] ++ [0, 0, 0, 0] |> Enum.with_index(-4)
      _ ->
        steps = build_steps(row)
        steps = [0, 0, 0, 0 | steps] ++ [0, 0, 0, 0]

        indexs = build_indices(row)
        {min, max} = Enum.min_max(indexs)
        indexs = min-4..max+4

        Enum.zip(steps, indexs)
    end
  end

  defp item_matches_any_rule?(chunk, rule_set) do
    steps = build_steps(chunk)

    Enum.find(rule_set, fn {rule, _change} -> rule == steps end)
  end
end
