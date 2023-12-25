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
end
