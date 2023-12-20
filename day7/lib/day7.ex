defmodule Day7 do
  @moduledoc """
  Documentation for `Day7`.
  """

  @cards ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]

  @cards_positions Enum.with_index(@cards) |> Map.new()

  @hand_types %{
    :five_of_kind => 0,
    :four_of_kind => 1,
    :full_house => 2,
    :three_of_kind => 3,
    :two_pairs => 4,
    :one_pair => 5,
    :high_card => 6
  }

  @doc """
  Compares two cards.

  ## Examples
  iex> Day7.compare_cards("A", "Q")
  :gt

  iex> Day7.compare_cards("J", "Q")
  :lt
  """
  def compare_cards(a, b) do
    compare_ranks(@cards_positions[a], @cards_positions[b])
  end

  @doc """
  Compare hands, first by rank, and then 'alphabetically'

  ## Examples

  iex> Day7.compare_hands("AAAAA", "KKKKK")
  :gt
  iex> Day7.compare_hands("AAAA8", "KKKKK")
  :lt
  """
  def compare_hands(hand1, hand2) do
    type1 = get_hand_type(hand1)
    type2 = get_hand_type(hand2)

    type_comparison = compare_ranks(@hand_types[type1], @hand_types[type2])

    # not implemented - comparison by cards in hand for equal rank

    case type_comparison do
      :eq -> alpha_comparison(String.graphemes(hand1), String.graphemes(hand2))
      _ -> type_comparison
    end
  end

  @doc """
  Compares the hands 'alphabetically', but using card ranks and not alphabet ordering

  ## Examples

  iex> Day7.alpha_comparison(["A","A"], ["A","K"])
  :gt
  iex> Day7.alpha_comparison(["A","Q"], ["A","K"])
  :lt
  iex(21)> Day7.alpha_comparison(["A","K"], ["A","K"])
  :eq
  """
  def alpha_comparison([], []), do: :eq

  def alpha_comparison([c1 | rem1], [c2 | rem2]) when c1 == c2, do: alpha_comparison(rem1, rem2)

  def alpha_comparison([c1 | _], [c2 | _]), do: compare_cards(c1, c2)

  def get_hand_type(hand_str) do
    cards = String.graphemes(hand_str)

    chunks =
      cards
      |> Enum.sort()
      |> Enum.chunk_by(& &1)
      |> Enum.sort_by(&length/1, :desc)

    # |> IO.inspect(label: "chunks")

    classify_hand(chunks)
    # AAAAA - AAAAA - all same
    # AA8AA - AAAA 8 - four of a kind
    # 23332 - 333 22 - full house (3+2)
    # TTT98 - TTT 9 8 - three of kind
    # 23432 - 4 33 22
    # A23A4 - AA 4 3 2
    # 23456 - 6 5 4 3 2
  end

  defp classify_hand([_]), do: :five_of_kind
  defp classify_hand([_, _, _, _, _]), do: :high_card
  defp classify_hand([l1, _]) when length(l1) == 4, do: :four_of_kind
  defp classify_hand([_, _]), do: :full_house
  defp classify_hand([l1, _, _]) when length(l1) == 3, do: :three_of_kind
  defp classify_hand([_, _, _]), do: :two_pairs
  defp classify_hand([_, _, _, _]), do: :one_pair
  defp classify_hand(_), do: :error

  defp compare_ranks(a, b) when a == b, do: :eq
  # lower number means 'higher' rank and vice versa
  defp compare_ranks(a, b) when a < b, do: :gt
  defp compare_ranks(a, b) when a > b, do: :lt
end
