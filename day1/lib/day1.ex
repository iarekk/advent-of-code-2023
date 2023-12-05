defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day1.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(path) do
    File.stream!(path)
    # |> Stream.map(&String.trim/1)
    # |> Stream.with_index()
    |> Stream.map(&str_to_number(&1))
    # |> Stream.transform(0, fn acc, val -> acc + val end)
    |> Enum.sum()

    # Enum.sum(numbers)
  end

  @doc """
  Gets the calibration number out of the string.

  iex> Day1.str_to_number("1abc2")
  12
  iex> Day1.str_to_number("pqr3stu8vwx")
  38
  iex> Day1.str_to_number("treb7uchet")
  77
  iex> Day1.str_to_number("two1nine")
  29
  iex> Day1.str_to_number("abcone2threexyz")
  13

  """
  def str_to_number(str) do
    # IO.puts(digits)
    str_cleaned = clean_string(str)
    symbols = str_cleaned |> String.graphemes()
    numbers = symbols |> Enum.filter(fn s -> s in digits() end)

    first = List.first(numbers) |> String.to_integer()
    last = List.last(numbers) |> String.to_integer()

    first * 10 + last
  end

  @doc """
  Replaces string representations of digits with actual digits in the string.

  ## Examples

    iex> Day1.clean_string("two1nine")
    "219"

    iex> Day1.clean_string("abcone2threexyz")
    "abc123xyz"

  """
  def clean_string(str) do
    str
    |> String.replace("one", "1")
    |> String.replace("two", "2")
    |> String.replace("three", "3")
    |> String.replace("four", "4")
    |> String.replace("five", "5")
    |> String.replace("six", "6")
    |> String.replace("seven", "7")
    |> String.replace("eight", "8")
    |> String.replace("nine", "9")
  end

  defp digits, do: 0..9 |> Enum.to_list() |> Enum.map(&Integer.to_string(&1))

  def lookups, do: ["one", "two"]
  def lookup_map, do: %{"one" => "1", "two" => "2"}

  def replace_lookahead(str) do
    symbols = String.graphemes(str)

    replaced_symbols = repl_rec([], symbols)

    Enum.join(replaced_symbols)
  end

  def repl_rec(acc, []) do
    IO.puts("repl_rec called: (#{acc}, [])")
    word_in_acc = Enum.join(acc)

    if(Map.has_key?(lookup_map(), word_in_acc)) do
      [Map.get(lookup_map(), word_in_acc)]
    else
      acc
    end
  end

  # acc has partial match on matches
  def repl_rec([f | rem_acc] = acc, [next | remaining] = remstr) do
    IO.puts("repl_rec called: (#{acc}, #{remstr})")

    new_candidate_word = acc ++ [next]
  end

  # def repl_rec(acc, symbols) do
  # end
end
