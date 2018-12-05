defmodule Day2 do
  """
  Produce a counter that is stored through enumerating over each line
  Only match once; i.e. if two sets occur, only one counts towards to global counter
  """
  def checksum(list) do
    {twices, thrices} =
      Enum.reduce(list, {0, 0}, fn(id, {total_twices, total_thrices}) ->
        graphemes = String.graphemes(id)
        {twos, threes} =
          Enum.reduce(graphemes, {0, 0}, fn letter, acc2 ->
            build_accumulator(letter, graphemes, acc2)
          end)
        {total_twices + twos, total_thrices + threes}
      end)

    twices * thrices
  end

  defp build_accumulator(letter, graphemes, {two, three}) do
    case graphemes |> Enum.count(&(&1 == letter)) do
      2 -> {1, three}
      3 -> {two, 1}
      _ -> {two, three}
    end
  end
end
