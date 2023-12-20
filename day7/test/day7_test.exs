defmodule Day7Test do
  use ExUnit.Case
  doctest Day7

  test "compare cards" do
    assert Day7.compare_cards("A", "K") == :gt
    assert Day7.compare_cards("Q", "K") == :lt
    assert Day7.compare_cards("2", "3") == :lt
    assert Day7.compare_cards("A", "2") == :gt
    assert Day7.compare_cards("A", "A") == :eq
  end

  test "get hand type" do
    assert Day7.get_hand_type("AAAAA") == :five_of_kind
    assert Day7.get_hand_type("AA8AA") == :four_of_kind
    assert Day7.get_hand_type("23332") == :full_house
    assert Day7.get_hand_type("TTT98") == :three_of_kind
    assert Day7.get_hand_type("23432") == :two_pairs
    assert Day7.get_hand_type("A23A4") == :one_pair
    assert Day7.get_hand_type("23456") == :high_card
  end
end
