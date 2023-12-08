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
    # |> Stream.map(&IO.inspect(&1))
    |> Stream.map(&compute_winnings(&1))
    |> Stream.map(&IO.inspect(&1, label: "after computing match count"))
    |> Enum.reverse()
    |> Enum.scan([], &tally_up(&1, &2))
    |> Enum.reverse()

    # |> IO.inspect(label: "after scan")
    |> Enum.at(0)
    |> Enum.sum()
  end

  def tally_up(current, tail) do
    IO.puts("c: #{current}, t: #{inspect(tail)}")
    won_cards = 1 + (Enum.take(tail, current) |> Enum.sum())
    [won_cards | tail]
  end

  def parse_card(str) do
    [_title, winning, card] = String.split(str, [":", "|"])

    {String.split(winning |> String.trim(), " ", trim: true) |> Enum.map(&String.to_integer(&1)),
     String.split(card |> String.trim(), " ", trim: true) |> Enum.map(&String.to_integer(&1))}
  end

  def compute_winnings({winning_numbers, card_numbers}) do
    Enum.filter(card_numbers, &(&1 in winning_numbers)) |> Enum.count()
  end
end
