defmodule Day3 do
  @moduledoc """
  Documentation for `Day3`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day3.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(path) do
    # Stream.zip_with([Stream.concat([0],source), source, Stream.concat( Stream.drop(source,1), [0])], fn [a, b, c] -> {a,b,c} end) |> Enum.map(&(&1))

    file_stream = File.stream!(path) |> Stream.map(&String.trim(&1))

    thruple_stream =
      Stream.zip_with(
        [
          Stream.concat([""], file_stream),
          file_stream,
          Stream.concat(Stream.drop(file_stream, 1), [""])
        ],
        fn [a, b, c] -> {a, b, c} end
      )

    thruple_stream
    |> Enum.map(&sum_on_line(&1))
    |> Enum.sum()

    # Stream.map(&IO.puts("#{inspect(&1)}")) |> Stream.run()
  end

  def digits, do: 0..9 |> Enum.map(&Integer.to_string(&1))

  def has_part_at_position(_, ""), do: false
  def has_part_at_position(pos, _) when pos < 0, do: false

  def has_part_at_position(pos, str) do
    if(pos >= String.length(str)) do
      false
    else
      sym = String.at(str, pos)
      is_symbol(sym)
    end
  end

  def is_symbol(s) when s in [".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], do: false
  def is_symbol(_), do: true

  @doc """
  Splits a string of symbols/numbers into number and non-number portions.

  ## Examples

    iex> Day3.split_numbers_and_nonnumbers(".........*.............897..*.....*....628..*")
    [".........*.............", "897", "..*.....*....", "628", "..*"]
  """
  def split_numbers_and_nonnumbers(str) do
    String.split(str, ~r/\d+/, include_captures: true, trim: true)
  end

  @doc """
  Counts the start/end of the chunks, and emits the chunks and the metadata in a list of tuples.

  ## Examples

    iex> Day3.chunkify(["..", "897", "..*.....*....", "628"]) # "..897..*.....*....628"
    [{"..", 0, 2, 2}, {"897", 2, 3, 5}, {"..*.....*....", 5, 13, 18}, {"628", 18, 3, 21}]

  """
  def chunkify(chunks) do
    chunks
    |> Enum.scan({"", 0, 0, 0}, fn chunk, {_, _, _, total} ->
      {chunk, total, String.length(chunk), String.length(chunk) + total}
    end)
  end

  def filter_integer_chunks(chunks) do
    Enum.filter(chunks, fn {s, _, _, _} -> Integer.parse(s) != :error end)
  end

  def is_integer_chunk_part_number?({s, start, length, _}, line_above, current_line, line_below) do
    range = (start - 1)..(start + length)

    on_line_above = range |> Enum.map(&has_part_at_position(&1, line_above)) |> Enum.any?()
    on_current_line = range |> Enum.map(&has_part_at_position(&1, current_line)) |> Enum.any?()
    on_line_below = range |> Enum.map(&has_part_at_position(&1, line_below)) |> Enum.any?()

    if Enum.any?([on_line_above, on_current_line, on_line_below]) do
      String.to_integer(s)
    else
      0
    end
  end

  def sum_on_line({up, cur, down}) do
    cur
    |> split_numbers_and_nonnumbers()
    |> chunkify()
    |> filter_integer_chunks()
    |> Enum.map(&is_integer_chunk_part_number?(&1, up, cur, down))
    |> Enum.sum()
  end
end
