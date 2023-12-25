defmodule Day9 do
  @moduledoc """
  Documentation for `Day9`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day9.hello()
      :world

  """
  def hello do
    :world
  end

  def solve(file_path) do
    input_lines = read_file(file_path)

    input_lines |> Enum.map(&find_next_value/1) |> Enum.sum()
  end

  def solve_part_2(file_path) do
    input_lines = read_file(file_path)

    input_lines |> Enum.map(&find_prev_value/1) |> Enum.sum()
  end

  def find_prev_value(number_list) do
    derivatives = find_derivatives(number_list, [])

    find_prev_value(0, derivatives)
  end

  def find_prev_value(delta, []), do: delta

  def find_prev_value(delta, [list | rem]) do
    [a | _] = list

    find_prev_value(a - delta, rem)
  end

  def find_next_value(number_list) do
    derivatives = find_derivatives(number_list, [])

    find_next_value(0, derivatives)
  end

  def find_next_value(delta, []) do
    delta
  end

  def find_next_value(delta, [number_list | rest_of_lists]) do
    next_val = List.last(number_list) + delta
    find_next_value(next_val, rest_of_lists)
  end

  def find_derivatives(number_list, acc) do
    if(number_list |> Enum.all?(&(&1 == 0))) do
      acc
    else
      derivative_list = derive(number_list)
      find_derivatives(derivative_list, [number_list | acc])
    end
  end

  def derive([a, b]), do: [b - a]

  def derive([a, b | rest]) do
    [b - a | derive([b | rest])]
  end

  def read_file(file_path) do
    File.stream!(file_path)
    |> Stream.map(&process_line/1)
    |> Enum.to_list()
    |> IO.inspect(label: "input")
  end

  def process_line(str) do
    str |> String.trim() |> String.split() |> Enum.map(&String.to_integer/1)
  end
end
