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
    |> Stream.map(&is_possible(&1))
    |> Enum.sum()

    # Enum.map(&IO.puts(&1))
  end

  @doc """
  Parse a game

  ## Examples

    iex> Day2.parse_game("Game 96: 8 blue, 9 red; 9 red, 10 blue; 5 blue, 1 green, 2 red; 2 blue, 2 red")
    {
      96,
      [
        %{"blue" => "8", "red" => "9"},
        %{"blue" => "10", "red" => "9"},
        %{"blue" => "5", "green" => "1", "red" => "2"},
        %{"blue" => "2", "red" => "2"}
      ]
    }
  """
  def parse_game(str) do
    [title, game_portion] = String.split(str, ":")

    [_, num_str] = String.split(title)
    num = String.to_integer(num_str)

    game_records =
      game_portion
      |> String.split(";")
      |> Enum.map(&parse_single_set(&1))

    # |> IO.inspect(label: "game recs")

    # game_records =
    {num, game_records}
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

  def is_game_possible(sets, max_set) do
    Enum.all?(sets, &is_set_possible(&1, max_set))
  end

  def is_set_possible(set, max_set) do
    IO.puts("set: #{inspect(set)}, max set: #{inspect(max_set)}")

    Enum.all?(Map.keys(set), fn colour ->
      Map.get(set, colour, 0) <= Map.get(max_set, colour, :kaboom)
    end)
    |> IO.inspect(label: "is possible")
  end

  def available_cubes(), do: %{"red" => 12, "green" => 13, "blue" => 14}

  def is_possible({game_number, sets}) do
    if(is_game_possible(sets, available_cubes())) do
      game_number
    else
      0
    end
  end
end
