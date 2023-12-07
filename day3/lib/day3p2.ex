defmodule Day3P2 do
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
    |> Stream.map(&sum_of_gears(&1))
    |> Enum.sum()

    # Stream.map(&IO.puts("#{inspect(&1)}")) |> Stream.run()
  end

  def sum_of_gears({prev, cur, next}) do
    gears = find_gears(cur) |> IO.inspect(label: "gears")

    numbers =
      (find_nums(prev) ++ find_nums(cur) ++ find_nums(next)) |> IO.inspect(label: "numbers")

    gears
    |> IO.inspect(label: "passing gears")
    |> attach_numbers(numbers)
    |> IO.inspect(label: "attached numbers")
    |> Enum.map(&get_ratios(&1))
    |> IO.inspect(label: "got ratios")
    |> Enum.sum()
  end

  def find_gears(str) do
    str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {sym, _} -> sym == "*" end)
    |> Enum.map(fn {_, i} -> i end)
  end

  def find_nums(str) do
    str
    |> split_numbers_and_nonnumbers()
    |> chunkify()
    |> filter_integer_chunks()
    |> Enum.map(fn {s, start, len, _} -> {String.to_integer(s), start, start + len - 1} end)
  end

  def attach_numbers(gears, numbers) do
    gears
    |> Enum.map(fn g ->
      Enum.filter(numbers, fn {_, startpos, endpos} ->
        startpos in (g - 1)..(g + 1) or endpos in (g - 1)..(g + 1) or
          g in (endpos - 1)..(startpos + 1)
      end)
      |> IO.inspect(label: "attached gears to gear at position #{g}")
    end)
  end

  def get_ratios([{v1, _, _}, {v2, _, _}]), do: v1 * v2
  def get_ratios(_), do: 0

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

    iex> Day3P2.split_numbers_and_nonnumbers(".........*.............897..*.....*....628..*")
    [".........*.............", "897", "..*.....*....", "628", "..*"]
  """
  def split_numbers_and_nonnumbers(str) do
    String.split(str, ~r/\d+/, include_captures: true, trim: true)
  end

  @doc """
  Counts the start/end of the chunks, and emits the chunks and the metadata in a list of tuples.

  ## Examples

    iex> Day3P2.chunkify(["..", "897", "..*.....*....", "628"]) # "..897..*.....*....628"
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

  # def sum_on_line({up, cur, down}) do
  #   cur
  #   |> split_numbers_and_nonnumbers()
  #   |> chunkify()
  #   |> filter_integer_chunks()
  #   |> Enum.map(&is_integer_chunk_part_number?(&1, up, cur, down))
  #   |> Enum.sum()
  # end
end
