defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "count_characters" do
    assert Day2.count_characters("aabbccb") == %{
      ?a => 2,
      ?b => 3,
      ?c => 2
    }
  end

  test "checksum" do
    assert Day2.checksum([
      "lsrivfotzgdxpkefaqmuiygjjj",
      "lsrivfotzqdxpkeraqmewygchj",
      "lsrivfotzbdepkenarjuwygchj",
      "lsrivfotwbdxpkeoaqmunygchj",
      "lsrijfotzbdxpkenwqmuyygchj"
    ]) == 5
  end

  test "closests" do
    assert Day2.closest([
      "abcde",
      "fghij",
      "klmno",
      "pqrst",
      "fguij",
      "axcye",
      "wvxyz"
    ]) == "fgij"
  end
end
