defmodule Aoc do
  def input_file(),
    do: Path.join([Application.app_dir(:day25, "priv"), "day25.in"])

  def input_lines() do
    input_file()
    |> File.read!()
  end
end

