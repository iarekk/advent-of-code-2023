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
    compare(@cards_positions[a], @cards_positions[b])
  end

  defp compare(a, b) when a == b, do: :eq
  # lower number means 'higher' rank and vice versa
  defp compare(a, b) when a < b, do: :gt
  defp compare(a, b) when a > b, do: :lt
end
