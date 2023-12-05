defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day2.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(path) do
    File.stream!(path)
    |> Stream.map(&parse_game(&1))
    |> Stream.map(&find_minimum_set(&1))
    |> Stream.map(&find_power(&1))
    |> Enum.sum()

    # Enum.map(&IO.puts(&1))
  end

  @doc """
  Parse a game

  ## Examples

    iex> Day2.parse_game("Game 96: 8 blue, 9 red; 9 red, 10 blue; 5 blue, 1 green, 2 red; 2 blue, 2 red")
    [
      %{"blue" => 8, "red" => 9},
      %{"blue" => 10, "red" => 9},
      %{"blue" => 5, "green" => 1, "red" => 2},
      %{"blue" => 2, "red" => 2}
    ]

  """
  def parse_game(str) do
    [_, game_portion] = String.split(str, ":")

    game_records =
      game_portion
      |> String.split(";")
      |> Enum.map(&parse_single_set(&1))

    # |> IO.inspect(label: "game recs")

    # game_records =
    game_records
  end

  def parse_single_set(str) do
    # ["8 blue", "9 red"]
    cols = str |> String.split(",")
    # |> IO.inspect(label: "cols")

    cols |> Map.new(&parse_col_tuple(&1))
  end

  def parse_col_tuple(s) do
    [count, col] = String.split(s)
    {col, count |> String.to_integer()}
  end

  def find_minimum_set([first | remsets] = sets), do: find_minimum_set_rec(first, remsets)

  def find_minimum_set_rec(acc, []), do: acc

  def find_minimum_set_rec(acc, [set | rem]) do
    new_acc = Map.merge(acc, set, fn _k, v1, v2 -> max(v1, v2) end)
    find_minimum_set_rec(new_acc, rem)
  end

  def find_power(min_set) do
    min_set |> Map.keys() |> Enum.map(&Map.get(min_set, &1)) |> Enum.product()
  end
end
