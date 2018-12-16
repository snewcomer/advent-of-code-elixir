defmodule Day13 do

  @carts [">", "<", "v", "^"]

  def part1(input) do
    lines =
      input
      |> File.read!()
      |> String.trim_trailing()
      |> String.split("\n", trim: true)

    point_map =
      lines
      |> register_points_in_grid()

    carts =
      lines
      |> build_cart_positions(point_map)
      |> Enum.sort()

    [h | _t] = cycle_carts(carts, point_map)
    h
  end

  @doc """

  ## Examples

      iex> point_map = Day13.register_points_in_grid(["/--->-------------<\"])
      iex> carts = Day13.build_cart_positions(["/--->-------------<\"], point_map)
      iex> Day13.cycle_carts(carts, point_map)
      [{11, 0, ">", :left, "-"}]

  """
  def cycle_carts(carts, point_map) do
    new_carts =
      Enum.reduce(carts, [], fn {x, y, cart_dir, next_move, _old}, acc ->
        cart = move({x, y, cart_dir, next_move}, point_map)
        [cart | acc]
      end)
      |> Enum.reverse()

    point_map =
      Enum.reduce(carts, point_map, fn {x, y, _, _, old}, acc ->
        # put back old value
        Map.put(acc, {x, y}, old)
      end)

    point_map =
      Enum.reduce(new_carts, point_map, fn {x, y, cart_dir, _, _}, acc ->
        # put new value
        Map.put(acc, {x, y}, cart_dir)
      end)

    new_carts = Enum.reduce(new_carts, [], fn {x, y, _, _, _} = cart, acc ->
      new_x_y = Enum.reduce(acc, [], fn {x, y, _, _, _}, acc -> [{x, y} | acc] end)
      case {x, y} not in new_x_y do
        true -> [cart | acc]
        false -> acc
      end
    end)
    |> Enum.reverse()

    if Enum.count(new_carts) == Enum.count(carts) do
      # have yet to collide
      cycle_carts(new_carts, point_map)
    else
      # means they are both at the same point
      new_carts
    end
  end

  @doc """
  Plan is to register each point in the graph in a map.  Also register
  where the car is at.  As the car moves, it looks into the former map

  ## Examples

      iex> Day13.register_points_in_grid(["/->- "])
      %{{0, 0} => "/", {1, 0} => "-", {2, 0} => ">", {3, 0} => "-"}

  """
  def register_points_in_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc -> # y-index
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {track, x}, acc ->
        if track == " " do
          acc
        else
          Map.put(acc, {x, y}, track)
        end
      end)
    end)
  end

  @doc """

  ## Examples

      iex> Day13.build_cart_positions(["/- > v"], %{{3, 0} => "-", {5, 0} => "-"})
      [{3, 0, ">", :left, "-"}, {5, 0, "v", :left, "-"}]

  """
  def build_cart_positions(lines, point_map) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, y}, acc -> # y-index
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {track, x}, acc ->
        case track in @carts do
          true -> [{x, y, track, :left, point_map[{x, y}]} | acc]
          _ -> acc
        end
      end)
    end)
    |> Enum.reverse()
  end

  @doc """

  ## Examples

      iex> Day13.move({0, 0, ">", :left}, %{{0, 0} => "-", {1, 0} => "-"})
      {1, 0, ">", :left, "-"}
      iex> Day13.move({0, 0, "v", :left}, %{{0, 0} => "|", {0, 1} => "+"})
      {0, 1, ">", :straight, "+"}
      iex> Day13.move({2, 0, "v", :right}, %{{0, 0} => "|", {2, 1} => "+"})
      {2, 1, "<", :left, "+"}
      iex> Day13.move({2, 3, "^", :straight}, %{{2, 2} => "/"})
      {2, 2, ">", :straight, "/"}
      iex> Day13.move({2, 3, "<", :right}, %{{1, 3} => "+"})
      {1, 3, "^", :left, "+"}
      iex> Day13.move({2, 3, ">", :right}, %{{3, 3} => "+"})
      {3, 3, "v", :left, "+"}

  """
  def move({x, y, "v" = cart_dir, turn}, point_map) do
    track = point_map[{x, y+1}]

    {new_cart_dir, turn} =
      cond do
        track == "|" -> {cart_dir, turn}
        track == "\\" -> {">", turn}
        track == "/" -> {"<", turn}
        track == "+" -> next(turn, cart_dir)
        true -> {cart_dir, turn}
      end

    {x, y+1, new_cart_dir, turn, track}
  end
  def move({x, y, "^" = cart_dir, turn}, point_map) do
    track = point_map[{x, y-1}]

    {new_cart_dir, turn} =
      cond do
        track == "|" -> {cart_dir, turn}
        track == "\\" -> {"<", turn}
        track == "/" -> {">", turn}
        track == "+" -> next(turn, cart_dir)
        true -> {cart_dir, turn}
      end

    {x, y-1, new_cart_dir, turn, track}
  end
  def move({x, y, ">" = cart_dir, turn}, point_map) do
    track = point_map[{x+1, y}]

    {new_cart_dir, turn} =
      cond do
        track == "|" -> {cart_dir, turn}
        track == "\\" -> {"v", turn}
        track == "/" -> {"^", turn}
        track == "+" -> next(turn, cart_dir)
        true -> {cart_dir, turn}
      end

    {x+1, y, new_cart_dir, turn, track}
  end
  def move({x, y, "<" = cart_dir, turn}, point_map) do
    track = point_map[{x-1, y}]

    {new_cart_dir, turn} =
      cond do
        track == "|" -> {cart_dir, turn}
        track == "\\" -> {"^", turn}
        track == "/" -> {"v", turn}
        track == "+" -> next(turn, cart_dir)
        true -> {cart_dir, turn}
      end

    {x-1, y, new_cart_dir, turn, track}
  end

  defp next(turn, "v" = cart_dir) do
    case turn do
      :left -> {">", :straight}
      :straight -> {cart_dir, :right}
      :right -> {"<", :left}
    end
  end
  defp next(turn, "^" = cart_dir) do
    case turn do
      :left -> {"<", :straight}
      :straight -> {cart_dir, :right}
      :right -> {">", :left}
    end
  end
  defp next(turn, ">" = cart_dir) do
    case turn do
      :left -> {"^", :straight}
      :straight -> {cart_dir, :right}
      :right -> {"v", :left}
    end
  end
  defp next(turn, "<" = cart_dir) do
    case turn do
      :left -> {"v", :straight}
      :straight -> {cart_dir, :right}
      :right -> {"^", :left}
    end
  end
end
