defmodule Day6 do
  @moduledoc """
  Documentation for `Day6`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day6.hello()
      :world

  """
  def hello do
    :world
  end

  def get_input(file_path) do
    ["Time:" <> time_str, "Distance:" <> dist_str] =
      File.read!(file_path) |> IO.inspect(label: "file content") |> String.split("\n")

    times = time_str |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    distances = dist_str |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    List.zip([times, distances]) |> IO.inspect(label: "races")
  end
end
