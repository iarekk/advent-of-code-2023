defmodule Day7Test do
  use ExUnit.Case
  doctest Day7

  test "greets the world" do
    assert Day7.hello() == :world
  end

  test "compare cards" do
    assert Day7.compare_cards("A", "K") == :gt
    assert Day7.compare_cards("Q", "K") == :lt
    assert Day7.compare_cards("2", "3") == :lt
    assert Day7.compare_cards("A", "2") == :gt
  end
end