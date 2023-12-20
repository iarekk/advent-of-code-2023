defmodule Day7 do
  @moduledoc """
  Documentation for `Day7`.
  """

  @cards ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]

  def cards_positions(),
    do: Enum.with_index(@cards) |> Map.new() |> IO.inspect(label: "card positions invoked")

  def compare_cards(a, b) do
    comp_map = cards_positions()

    compare(comp_map[a], comp_map[b])
  end

  defp compare(a, b) when a == b, do: :eq
  defp compare(a, b) when a < b, do: :gt
  defp compare(a, b) when a > b, do: :lt

  @doc """
  Hello world.

  ## Examples

      iex> Day7.hello()
      :world

  """
  def hello do
    :world
  end
end
