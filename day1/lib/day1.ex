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
    first_digit = find_first(str)
    last_digit = find_last(str)
    first = Map.get(lookup_map(), first_digit, first_digit) |> String.to_integer()
    last = Map.get(lookup_map(), last_digit, last_digit) |> String.to_integer()

    first * 10 + last
  end

  defp digits, do: 0..9 |> Enum.to_list() |> Enum.map(&Integer.to_string(&1))
  defp word_digits, do: ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  defp all_digits, do: digits() ++ word_digits()

  def lookup_map,
    do: %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

  def find_first(str) do
    find_first_rec(str, starts_with_any_digit(str))
  end

  def find_first_rec("", last_match), do: last_match

  def find_first_rec(str, :nope) do
    new_string = String.slice(str, 1..-1)
    find_first_rec(new_string, starts_with_any_digit(new_string))
  end

  def find_first_rec(_, match), do: match

  def starts_with_any_digit(str) do
    all_digits() |> Enum.find(:nope, fn digit -> String.starts_with?(str, digit) end)
  end

  def find_last(str), do: find_last_rec(str, ends_with_any_digit(str))

  def find_last_rec("", last_match), do: last_match

  def find_last_rec(str, :nope) do
    new_string = String.slice(str, 0, String.length(str) - 1)
    find_last_rec(new_string, ends_with_any_digit(new_string))
  end

  def find_last_rec(_, match), do: match

  def ends_with_any_digit(str) do
    all_digits() |> Enum.find(:nope, fn digit -> String.ends_with?(str, digit) end)
  end
end
