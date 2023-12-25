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

  def is_valid_coord?({x, y}, num_cols, num_rows) do
    x >= 0 and y >= 0 and x < num_rows and y < num_cols
  end
end
