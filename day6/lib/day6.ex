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

  def solve(file_path) do
    race_list = get_input(file_path)

    ways_to_beat_the_record = race_list |> Enum.map(&find_ways_to_beat/1)

    Enum.product(ways_to_beat_the_record)
  end

  def find_ways_to_beat({record_time, distance_to_beat}) do
    1..(record_time - 1)
    |> Enum.count(fn time_held -> distance_attained(record_time, time_held) > distance_to_beat end)
  end

  def distance_attained(time_to_beat, time_held) do
    time_moving = time_to_beat - time_held

    # increased linearly by 1 mm/s
    speed = time_held

    distance = speed * time_moving

    distance
  end

  def solve_part2(file_path) do
    race = get_input_part2(file_path)
    ways = find_ways_to_beat(race)
    ways
  end

  def get_input_part2(file_path) do
    ["Time:" <> time_str, "Distance:" <> dist_str] =
      File.read!(file_path) |> IO.inspect(label: "file content") |> String.split("\n")

    time = time_str |> String.replace(~r/\s+/, "") |> String.to_integer()
    distance = dist_str |> String.replace(~r/\s+/, "") |> String.to_integer()

    {time, distance}
  end
end
