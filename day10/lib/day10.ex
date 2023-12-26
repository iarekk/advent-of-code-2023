defmodule Day10 do
  def read_file(file_path) do
    File.stream!(file_path) |> Stream.with_index() |> Stream.flat_map(&parse_line/1) |> Map.new()
  end

  def parse_line({str, row_index}) do
    str
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {sym, col_index} -> {{row_index, col_index}, sym} end)
  end

  def find_start(matrix) do
    [{x, y}] = Map.filter(matrix, fn {_, sym} -> sym == "S" end) |> Map.keys()

    {x, y}
  end

  def move({x, y}, :north), do: {x - 1, y}
  def move({x, y}, :south), do: {x + 1, y}
  def move({x, y}, :west), do: {x, y - 1}
  def move({x, y}, :east), do: {x, y + 1}

  def direction(-1, 0), do: :north
  def direction(1, 0), do: :south
  def direction(0, -1), do: :west
  def direction(0, 1), do: :east

  def is_valid_coord?({x, y}, num_cols, num_rows) do
    x >= 0 and y >= 0 and x < num_rows and y < num_cols
  end

  # | is a vertical pipe connecting north and south.
  # - is a horizontal pipe connecting east and west.
  # L is a 90-degree bend connecting north and east.
  # J is a 90-degree bend connecting north and west.
  # 7 is a 90-degree bend connecting south and west.
  # F is a 90-degree bend connecting south and east.
  # . is ground; there is no pipe in this tile.

  # how to handle S? connected to everything? we are guaranteed only 2 connections
  def connections("|"), do: [:north, :south]
  def connections("-"), do: [:east, :west]
  def connections("L"), do: [:north, :east]
  def connections("J"), do: [:north, :west]
  def connections("7"), do: [:south, :west]
  def connections("F"), do: [:south, :east]
  def connections(_), do: []

  def are_connected({x1, y1}, sym1, {x2, y2}, sym2) do
    # direction point1 to point2
    direction1 = direction(x2 - x1, y2 - y1) |> IO.inspect(label: "direction 1 -> 2")

    direction2 = direction(x1 - x2, y1 - y2) |> IO.inspect(label: "direction 2 -> 1")

    connections1 = connections(sym1) |> IO.inspect(label: "connections 1")

    connections2 = connections(sym2) |> IO.inspect(label: "connections 2")

    Enum.member?(connections1, direction1) and Enum.member?(connections2, direction2)
  end
end
