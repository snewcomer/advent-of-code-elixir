defmodule Day3Test do
  use ExUnit.Case
  doctest Day3

  test "parse_input" do
    assert Day3.parse_input([
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ]) == [{1, {1,3}, {4,4}}, {2, {3,1}, {4,4}}, {3, {5,5}, {2,2}}]
  end

  test "total_claimed_inches" do
    claims = Day3.total_claimed_inches([
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ])
    assert claims[{2, 4}] == [1]
    assert claims[{2, 5}] == [1]
    assert claims[{2, 5}] == [1]
    assert claims[{2, 6}] == [1]
    assert claims[{2, 7}] == [1]
    assert claims[{3, 4}] == [1]
    assert claims[{3, 5}] == [1]
    assert claims[{3, 6}] == [1]
    assert claims[{3, 7}] == [1]
    assert claims[{4, 2}] == [2]
    assert claims[{4, 3}] == [2]
    assert claims[{4, 4}] == [2, 1]
  end

  test "overlapping_inches" do
    assert Day3.overlapping_inches([
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ]) == [{4, 4}, {4, 5}, {5, 4}, {5, 5}]
  end

  test "total_square_inches" do
    assert Day3.total_square_inches([
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ]) == 4
  end

  test "unique_claim" do
    assert Day3.unique_claim([
      "#1 @ 1,3: 4x4",
      "#2 @ 3,1: 4x4",
      "#3 @ 5,5: 2x2"
    ]) == 3
  end
end
