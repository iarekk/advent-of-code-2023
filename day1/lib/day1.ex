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

  """
  def str_to_number(str) do
    # IO.puts(digits)
    symbols = str |> String.graphemes()
    numbers = symbols |> Enum.filter(fn s -> s in digits() end)

    first = List.first(numbers) |> String.to_integer()
    last = List.last(numbers) |> String.to_integer()

    first * 10 + last
  end

  defp digits, do: 0..9 |> Enum.to_list() |> Enum.map(&Integer.to_string(&1))
end
