defmodule Day5 do
  @moduledoc """
  Documentation for `Day5`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day5.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(file_path) do
    fstream = File.stream!(file_path)

    seeds =
      fstream
      |> Stream.take(1)
      |> Enum.at(0)
      |> String.trim()
      # |> IO.inspect(label: "seeds")
      |> parse_seeds()

    # IO.puts("Seeds: #{inspect(seeds)}")

    final_map =
      fstream
      |> Stream.drop(2)
      |> Stream.chunk_while(
        [],
        fn x, acc ->
          case x do
            "\n" -> {:cont, acc, []}
            _ -> {:cont, acc ++ [String.trim(x)]}
          end
        end,
        fn _ -> {:cont, []} end
      )
      # |> Stream.map(&(&1 |> IO.inspect(label: "line")))
      |> Stream.map(&parse_map(&1))
      # |> Stream.map(&(&1 |> IO.inspect(label: "parsed map")))
      |> Map.new()

    {seeds |> IO.inspect(label: "seeds"), final_map |> IO.inspect(label: "final map")}
  end

  def parse_seeds("seeds: " <> seed_str) do
    seed_str |> String.split() |> Enum.map(&String.to_integer(&1))
  end

  def parse_map([map_name | inputs]) do
    [new_map_name, _] = map_name |> String.split()
    {new_map_name, inputs |> Enum.map(&transform_input(&1))}
  end

  def transform_input(range_str) do
    [dest_range_start, source_range_start, range_length] =
      String.split(range_str) |> Enum.map(&String.to_integer(&1))

    [
      dest_range_start: dest_range_start,
      source_range_start: source_range_start,
      range_length: range_length
    ]
  end
end
