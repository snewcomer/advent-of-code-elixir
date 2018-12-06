defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    if data != %{} do
      Enum.max_by(data, fn {_, count} -> count end)
    else
      :error
    end
  end

  defimpl Collectable do
    def into(%FrequencyMap{data: data}) do
      collector_fun = fn
        data, {:cont, elem} -> Map.update(data, elem, 1, & &1 + 1)
        data, :done -> %FrequencyMap{data: data}
        _, :halt -> :ok
      end

    {data, collector_fun}
    end
  end
end

defmodule Day4 do
  import NimbleParsec

  defparsecp :parsec_log,
            ignore(string("["))
            |> integer(4)
            |> ignore(string("-"))
            |> integer(2)
            |> ignore(string("-"))
            |> integer(2)
            |> ignore(string(" "))
            |> integer(2)
            |> ignore(string(":"))
            |> integer(2)
            |> ignore(string("] "))
            |> choice([
              ignore(string("Guard #")) |> integer(min: 1) |> ignore(string(" begins shift")) |> unwrap_and_tag(:shift),
              string("falls asleep") |> replace(:down),
              string("wakes up") |> replace(:up),
            ])


  @doc """
  Find guard who is sleeping the most and figure out which minute he is asleep the most
  So we basically create a list of all the minutes the guard is asleep and pass each one into
  a counter check.
  """
  def part1(input) do
    id =
      input
      |> group_by_id()
      |> find_total_sleep_by_id()
      |> id_asleep_the_most()

    {minute, _count} =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> group_by_id()
      |> minute_asleep_most_by_id(id)

    id * minute
  end

  @doc """
  Which guard is asleep the most on a specific minute. So need to loop through each minute, and create
  a data structure that holds the minute
  %{
    45 => [99, 99, 99, 10]
  }
  then find max for each guard
  %{
    99 => {45, 3}
    10 => {22, 2}
  }
  """
  def part2(input) do
    {id, min} =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> group_by_id()
      |> guards_with_max_minute_asleep()

    id * min
  end

  @doc """
  ## Examples

      iex> Day4.guards_with_max_minute_asleep([
      ...>    {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>    {99, {1518, 11, 1}, [40..49]},
      ...>    {10, {1518, 11, 3}, [24..28]},
      ...>    {99, {1518, 11, 4}, [36..45]},
      ...>    {99, {1518, 11, 5}, [45..54]}
      ...> ])
      {99, 45}
  """
  def guards_with_max_minute_asleep(grouped_input) do
    {current_id, current_minute, _, _} =
      Enum.reduce(grouped_input, {0, 0, 0, MapSet.new()}, fn {id, _, _}, acc ->
        {current_id, current_minute, current_count, seen_ids} = acc

        if id in seen_ids do
          acc
        else
          case minute_asleep_most_by_id(grouped_input, id) do
            {minute, count} when count > current_count ->
              {id, minute, count, MapSet.put(seen_ids, id)}

            _ ->
              {current_id, current_minute, current_count, MapSet.put(seen_ids, id)}
          end
        end
      end)

    {current_id, current_minute}
  end

  @doc """
  ## Examples

      iex> Day4.minute_asleep_most_by_id([
      ...>    {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>    {99, {1518, 11, 1}, [40..49]},
      ...>    {10, {1518, 11, 3}, [24..28]},
      ...>    {99, {1518, 11, 4}, [36..45]},
      ...>    {99, {1518, 11, 5}, [45..54]}
      ...> ], 10)
      {24, 2}
  """
  def minute_asleep_most_by_id(grouped_input, id) do
    all_minutes =
      for {^id, _, ranges} <- grouped_input,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    # avoid multiple data structures
    FrequencyMap.most_frequent(all_minutes)
    # minute_occurences =
    #   Enum.reduce(all_minutes, %{}, fn minute, acc ->
    #     Map.update(acc, minute, 1, & &1 + 1)
    #   end)
    # {minute, _} = Enum.max_by(minute_occurences, fn {_, count} -> count end)
    #
    # minute * id
  end

  @doc """
  ## Examples

      iex> Day4.id_asleep_the_most(%{10 => 50, 99 => 30})
      10
  """
  def id_asleep_the_most(map) do
    {id, _} = Enum.max_by(map, fn {_, time_asleep} -> time_asleep end)
    id
  end

  @doc """
  ## Examples

      iex> Day4.find_total_sleep_by_id([
      ...>    {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>    {99, {1518, 11, 1}, [40..49]},
      ...>    {10, {1518, 11, 3}, [24..28]},
      ...>    {99, {1518, 11, 4}, [36..45]},
      ...>    {99, {1518, 11, 5}, [45..54]}
      ...> ])
      %{
        10 => 50,
        99 => 30
      }
  """
  def find_total_sleep_by_id(parsed_input) do
    parsed_input
    |> Enum.reduce(%{}, fn {id, _, range}, acc ->
      total = total_sleep_time(range, 0)
      Map.update(acc, id, total, &(total_sleep_time(range, &1)))
      # total = range |> Enum.map(&Enum.count/1) |> Enum.sum()
      # Map.update(acc, id, total, &(&1 + total))
    end)
  end

  defp total_sleep_time([start..time_end | t], total_time) do
    total_time = total_time + (time_end + 1 - start)
    total_sleep_time(t, total_time)
  end
  defp total_sleep_time([], total_time), do: total_time

  @doc """
  ## Examples

      iex> Day4.group_by_id([
      ...>    "[1518-11-01 00:00] Guard #10 begins shift",
      ...>    "[1518-11-01 00:05] falls asleep",
      ...>    "[1518-11-01 00:25] wakes up",
      ...>    "[1518-11-01 00:30] falls asleep",
      ...>    "[1518-11-01 00:55] wakes up",
      ...>    "[1518-11-01 23:58] Guard #99 begins shift",
      ...>    "[1518-11-02 00:40] falls asleep",
      ...>    "[1518-11-02 00:50] wakes up",
      ...>    "[1518-11-03 00:05] Guard #10 begins shift",
      ...>    "[1518-11-03 00:24] falls asleep",
      ...>    "[1518-11-03 00:29] wakes up",
      ...>    "[1518-11-04 00:02] Guard #99 begins shift",
      ...>    "[1518-11-04 00:36] falls asleep",
      ...>    "[1518-11-04 00:46] wakes up",
      ...>    "[1518-11-05 00:03] Guard #99 begins shift",
      ...>    "[1518-11-05 00:45] falls asleep",
      ...>    "[1518-11-05 00:55] wakes up"
      ...> ])
      [
        {10, {1518, 11, 1}, [5..24, 30..54]},
        {99, {1518, 11, 1}, [40..49]},
        {10, {1518, 11, 3}, [24..28]},
        {99, {1518, 11, 4}, [36..45]},
        {99, {1518, 11, 5}, [45..54]}
      ]
  """
  def group_by_id(logs) do
    logs
    |> Enum.map(&parse_log/1)
    |> Enum.sort()
    |> group_by_id_date([])
  end

  defp group_by_id_date([{date, _hour, _minute, {:shift, id}} | rest], acc) do
    # first recursive
    {rest, asleep_range} = get_asleep_range(rest, [])
    # second recursive
    group_by_id_date(rest, [{id, date, asleep_range} | acc])
  end
  defp group_by_id_date([], acc) do
    # reverse b/c inserting at start of list
    Enum.reverse(acc)
  end

  defp get_asleep_range([{_, _, down_minute, :down}, {_, _, up_minute, :up} | tail], acc) do
    get_asleep_range(tail, [down_minute..(up_minute - 1) | acc])
  end
  defp get_asleep_range(rest, acc) do
    {rest, Enum.reverse(acc)}
  end

  @doc """
  ## Examples

      iex> Day4.parse_log("[1518-11-01 00:00] Guard #1543 begins shift")
      {{1518, 11, 01}, 00, 00, {:shift, 1543}}

      iex> Day4.parse_log("[1518-11-01 00:00] falls asleep")
      {{1518, 11, 01}, 00, 00, :down}

      iex> Day4.parse_log("[1518-11-01 00:00] wakes up")
      {{1518, 11, 01}, 00, 00, :up}

  """
  def parse_log(log) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(log)
    {{year, month, day}, hour, minute, id}
  end
end
