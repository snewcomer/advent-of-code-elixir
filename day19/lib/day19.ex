defmodule Day19 do
  use Bitwise

  def part1(input) do
    [ip | instructions] =
      input
      |> File.read!()
      |> String.trim_trailing()
      |> String.split("\n", trim: true)

    [_h, ip] = ip |> String.split(" ")
    ip = String.to_integer(ip)

    execute(ip, ip, {0, 0, 0, 0, 0, 0}, parse_instructions(instructions))
    |> elem(0)
  end

  @doc """

  ## Examples

      iex> Day19.execute(0, 0, {0, 0, 0, 0, 0, 0}, [[9, 5, 0, 1], [9, 3, 0, 2]])
      {2, 5, 3, 0, 0, 0}
      iex> Day19.execute(0, 0, {0, 0, 0, 0, 0, 0}, [[1, 5, 0, 1]])
      {1, 0, 0, 0, 0, 0}
      iex> Day19.execute(0, 0, {0, 0, 0, 0, 0, 0}, [[2, 5, 0, 1]])
      {1, 0, 0, 0, 0, 0}
      iex> Day19.execute(0, 0, {0, 0, 0, 0, 0, 0}, [[8, 5, 0, 1]])
      {1, 0, 0, 0, 0, 0}

  """
  def execute(original_ip, ip, register, instructions) do
    # update register at indx of original
    # create new register
    case read_instructions(instructions, ip) do
      :none ->
        register
      instruction ->
        register = put_elem(register, original_ip, ip)
        new_register = Machine.execute(register, instruction)
        IO.inspect {register, instruction, new_register, ip}
        new_ip = read_back(new_register, original_ip) + 1
        execute(original_ip, new_ip, new_register, instructions)
    end
  end

  defp read_back(register, ip) do
    elem(register, ip)
  end

  defp read_instructions(instructions, ip) do
    Enum.at(instructions, ip, :none)
  end

  @doc """

  ## Examples

      iex> Day19.parse_instructions(["addi 2 16 2"])
      [[1, 2, 16, 2]]

  """
  def parse_instructions(instructions) do
    Enum.map(instructions, fn inst ->
      [inst | rest] = String.split(inst, " ", trim: true)
      [Machine.determine_method(inst) | rest |> Enum.map(&String.to_integer/1)]
    end)
  end
end

defmodule Machine do
  use Bitwise

  def determine_method(method) do
    case method do
      "addr" -> 0
      "addi" -> 1
      "mulr" -> 2
      "muli" -> 3
      "banr" -> 4
      "bani" -> 5
      "borr" -> 6
      "bori" -> 7
      "setr" -> 8
      "seti" -> 9
      "gtir" -> 10
      "gtri" -> 11
      "gtrr" -> 12
      "eqir" -> 13
      "eqri" -> 14
      "eqrr" -> 15
    end
  end

  @doc """

  ## Examples

      iex> Machine.execute({0, 0, 1, 0, 3, 2}, [0, 1, 2, 3])
      [[1, "2", "16", "2"]]

  """
  def execute(register, [indx | instructions]) do
    fun = Enum.at(possibilities(), indx)
    fun.(register, instructions)
  end

  def possibilities do
    [&addr/2, &addi/2,
     &mulr/2, &muli/2,
     &banr/2, &bani/2,
     &borr/2, &bori/2,
     &setr/2, &seti/2,
     &gtir/2, &gtri/2, &gtrr/2,
     &eqir/2, &eqri/2, &eqrr/2]
  end

  @doc """

  ## Examples

      iex> Machine.addr({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 4, 2}
      iex> Machine.addr({1, 4, 5, 10}, [1, 2, 0])
      {9, 4, 5, 10}

  """
  def addr(reg, [a, b, c]) do
    put_elem(reg, c, elem(reg, a) + elem(reg, b))
  end

  @doc """

  ## Examples

      iex> Machine.addi({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 4, 2}
      iex> Machine.addi({1, 4, 5, 10}, [1, 42, 3])
      {1, 4, 5, 46}

  """
  def addi(reg, [a, b, c]) do
    put_elem(reg, c, elem(reg, a) + b)
  end

  @doc """

  ## Examples

      iex> Machine.mulr({2, 3, 3, 1}, [3, 2, 2])
      {2, 3, 3, 1}
      iex> Machine.mulr({1, 4, 5, 10}, [1, 2, 0])
      {20, 4, 5, 10}

  """
  def mulr(reg, [a, b, c]) do
    put_elem(reg, c, elem(reg, a) * elem(reg, b))
  end

  @doc """

  ## Examples

      iex> Machine.muli({2, 3, 3, 3}, [3, 4, 1])
      {2, 12, 3, 3}
      iex> Machine.muli({1, 4, 5, 10}, [1, 42, 3])
      {1, 4, 5, 168}

  """
  def muli(reg, [a, b, c]) do
    put_elem(reg, c, elem(reg, a) * b)
  end

  @doc """

  ## Examples

      iex> Machine.banr({2, 3, 3, 1}, [3, 2, 2])
      {2, 3, 1, 1}
      iex> Machine.banr({1, 5, 13, 10}, [1, 2, 0])
      {5, 5, 13, 10}

  """
  def banr(reg, [a, b, c]) do
    put_elem(reg, c, band(elem(reg, a), elem(reg, b)))
  end

  @doc """

  ## Examples

      iex> Machine.bani({2, 3, 3, 3}, [3, 4, 1])
      {2, 0, 3, 3}
      iex> Machine.bani({1, 4, 5, 10}, [3, 8, 0])
      {8, 4, 5, 10}

  """
  def bani(reg, [a, b, c]) do
    put_elem(reg, c, band(elem(reg, a), b))
  end

  @doc """

  ## Examples

      iex> Machine.borr({2, 3, 3, 1}, [3, 2, 2])
      {2, 3, 3, 1}
      iex> Machine.borr({1, 5, 9, 10}, [1, 2, 0])
      {13, 5, 9, 10}

  """
  def borr(reg, [a, b, c]) do
    put_elem(reg, c, bor(elem(reg, a), elem(reg, b)))
  end

  @doc """

  ## Examples

      iex> Machine.bori({2, 3, 3, 3}, [3, 4, 1])
      {2, 7, 3, 3}
      iex> Machine.bori({1, 4, 5, 10}, [3, 32, 0])
      {42, 4, 5, 10}

  """
  def bori(reg, [a, b, c]) do
    put_elem(reg, c, bor(elem(reg, a), b))
  end

  @doc """

  ## Examples

      iex> Machine.setr({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 2, 2}
      iex> Machine.setr({1, 4, 5, 10}, [3, 999, 1])
      {1, 10, 5, 10}

  """
  def setr(reg, [a, _b, c]) do
    put_elem(reg, c, elem(reg, a))
  end

  @doc """

  ## Examples

      iex> Machine.seti({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 3, 2}
      iex> Machine.seti({1, 4, 5, 10}, [777, 999, 0])
      {777, 4, 5, 10}

  """
  def seti(reg, [a, _b, c]) do
    put_elem(reg, c, a)
  end

  @doc """

  ## Examples

      iex> Machine.gtir({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 1, 2}
      iex> Machine.gtir({1, 4, 5, 10}, [0, 2, 0])
      {0, 4, 5, 10}

  """
  def gtir(reg, [a, b, c]) do
    put_elem(reg, c, (if a > elem(reg, b), do: 1, else: 0))
  end

  @doc """

  ## Examples

      iex> Machine.gtri({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 0, 2}
      iex> Machine.gtri({1, 4, 5, 10}, [2, 9, 0])
      {0, 4, 5, 10}

  """
  def gtri(reg, [a, b, c]) do
    put_elem(reg, c, (if elem(reg, a) > b, do: 1, else: 0))
  end

  @doc """

  ## Examples

      iex> Machine.gtrr({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 0, 2}
      iex> Machine.gtrr({1, 4, 5, 10}, [1, 2, 0])
      {0, 4, 5, 10}

  """
  def gtrr(reg, [a, b, c]) do
    put_elem(reg, c, (if elem(reg, a) > elem(reg, b), do: 1, else: 0))
  end

  @doc """

  ## Examples

      iex> Machine.eqir({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 0, 2}
      iex> Machine.eqir({1, 4, 5, 10}, [42, 1, 0])
      {0, 4, 5, 10}

  """
  def eqir(reg, [a, b, c]) do
    put_elem(reg, c, (if a == elem(reg, b), do: 1, else: 0))
  end

  @doc """

  ## Examples

      iex> Machine.eqri({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 1, 2}
      iex> Machine.eqri({1, 4, 5, 10}, [3, 19, 0])
      {0, 4, 5, 10}

  """
  def eqri(reg, [a, b, c]) do
    put_elem(reg, c, (if elem(reg, a) == b, do: 1, else: 0))
  end

  @doc """

  ## Examples

      iex> Machine.eqrr({2, 3, 2, 2}, [3, 2, 2])
      {2, 3, 1, 2}
      iex> Machine.eqrr({1, 4, 10, 10},  [3, 2, 0])
      {1, 4, 10, 10}

  """
  def eqrr(reg, [a, b, c]) do
    put_elem(reg, c, (if elem(reg, a) == elem(reg, b), do: 1, else: 0))
  end
end
