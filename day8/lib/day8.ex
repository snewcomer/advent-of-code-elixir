defmodule Day8 do

  defmodule Tree do
    defstruct [:root]
    @type metadata :: integer
    @type tree_node :: {[tree_node], [metadata]}
    @type t :: %Tree{root: tree_node}

    defimpl Enumerable do
      def member?(_coll, _value), do: {:error, __MODULE__}
      def count(_coll), do: {:error, __MODULE__}
      def slice(_coll), do: {:error, __MODULE__}
      def reduce(%Three{root: root}, acc, fun) do
        node_reduce(root, acc, fun)
      end

      defp node_reduce({[child | children], metadata}, acc, fun) do
        Enum.reduce(metadata, acc, fun)
      end
    end
  end


  def part1(input) do
  {root, []} =
    input
    |> File.read!()
    |> String.trim_trailing()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> build_tree()

    sum_metadata(root)
  end

  def part2(input) do
  {root, []} =
    input
    |> File.read!()
    |> String.trim_trailing()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> build_tree()

    # get the root node meta data entries, take each one as an indx, then at each indx
    # sum the meta data entries recursively
    root_metadata_sum(root)
  end

  @doc """

  ## Examples
      iex> Day8.build_tree([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2])
      {
        { # A
          [
            { # B
              [],
              [10, 11, 12]
            },
            { # C
              [
                { # D
                  [],
                  [99]
                }
              ],
              [2]
            }
          ],
          [1, 1, 2]
      },
      []}


  """
  def build_tree([num_children, num_metadata | rest]) do
    # children(0, [10, 11, 12, 1, 1...])
    {child_nodes, rest} = children(num_children, rest, [])
    {metadata, rest} = Enum.split(rest, num_metadata)
    # {[], [10, 11, 12], [1, 1, 0, 1, 99, 2, 1, 1, 2]}
    {{child_nodes, metadata}, rest}
  end

  def children(0, rest, acc) do
    {Enum.reverse(acc), rest}
  end
  def children(num_children, rest, acc) do
    # rest includes trailing metadata references, so lets recursively find children of current node
    # until get to leaf with no child nodes.  Then build metadata items
    # build_tree([0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2], [])
    {node_items, rest} = build_tree(rest)
    # children(1, [1, 1, 0, 1, 99, 2, 1, 1, 2], node_items)
    children(num_children - 1, rest, [node_items | acc])
  end

  @doc """
  ## Examples

    iex> {tree, []} = Day8.build_tree([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2])
    iex> Day8.sum_metadata(tree)
    138

  """
  def sum_metadata({children, metadata}) do
    # might be empty array
    # {[children], [1, 1, 2]}
    build_acc(children, metadata, 0)
  end

  @doc """
  ## Examples

    iex> {tree, []} = Day8.build_tree([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2])
    iex> Day8.root_metadata_sum(tree)
    66

  """
  def root_metadata_sum({children, metadata}) do
    sum_root_indexed(children, metadata)
  end

  defp sum_root_indexed([], metadata) do
    # only occurs if parent metadata has an indx for it
    Enum.sum(metadata)
  end
  defp sum_root_indexed(children, metadata) do
    indexed_sums =
      for indx <- metadata,
          child = Enum.at(children, indx - 1),
          do: root_metadata_sum(child)

    Enum.sum(indexed_sums)

    # def indexed_sum({[], metadata}) do
    #   Enum.sum(metadata)
    # end
    # indexed_sum = Enum.map(children, &indexed_sum/1)
    # Enum.reduce(metadata, 0, &Enum.at(indexed_sums, &1 -1, 0) + &2)
  end

  def build_acc([], metadata, acc) do
    # leaf node
    Enum.sum(metadata) + acc
  end
  def build_acc(children, metadata, acc) do
    Enum.reduce(children, acc, fn child, acc ->
      sum_metadata(child) + acc
    end)
    |> Kernel.+(Enum.sum(metadata))
  end
end
