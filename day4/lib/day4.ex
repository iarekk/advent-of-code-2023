defmodule Day4 do
  @moduledoc """
  Documentation for `Day4`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day4.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(path) do
    File.stream!(path)
    |> Stream.map(&parse_card(&1))
    |> Stream.map(&IO.inspect(&1))
    |> Stream.map(&compute_winnings(&1))
    |> Enum.sum()
  end

  def parse_card(str) do
    [_title, winning, card] = String.split(str, [":", "|"])

    {String.split(winning |> String.trim(), " ", trim: true) |> Enum.map(&String.to_integer(&1)),
     String.split(card |> String.trim(), " ", trim: true) |> Enum.map(&String.to_integer(&1))}
  end

  def compute_winnings({winning_numbers, card_numbers}) do
    win_count = Enum.filter(card_numbers, &(&1 in winning_numbers)) |> Enum.count()
    make_win_number(win_count)
  end

  def make_win_number(0), do: 0
  def make_win_number(1), do: 1
  def make_win_number(k), do: :math.pow(2, k - 1) |> round
end
