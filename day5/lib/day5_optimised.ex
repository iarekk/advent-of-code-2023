# Solution inspired by <https://elixirforum.com/t/advent-of-code-2023-day-5/60170/2>

defmodule Day5Optimised do
  def get_input(file_path) do
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
            "\n" -> {:cont, Enum.reverse(acc), []}
            _ -> {:cont, [String.trim(x) | acc]}
          end
        end,
        fn
          [] -> {:cont, []}
          acc -> {:cont, Enum.reverse(acc), []}
        end
      )
      # |> Stream.map(&(&1 |> IO.inspect(label: "line")))
      |> Stream.map(&parse_map(&1))
      # |> Stream.map(&(&1 |> IO.inspect(label: "parsed map")))
      |> Map.new()

    {seeds |> IO.inspect(label: "seeds"), final_map |> IO.inspect(label: "final map")}

    seed_ranges = get_seed_ranges(seeds) |> IO.inspect(label: "seed ranges")

    # {seed_ranges, final_map}

    seed_ranges
    |> Enum.map(fn range -> seed_range_to_location(range, final_map) end)
    |> List.flatten()
    |> IO.inspect(label: "flat list", charlists: :as_lists)
    |> Enum.map(fn a.._ -> a end)
    |> Enum.min()

    # Day5Optimised.seed_range_to_location(79..92, mega_map())
  end

  @doc """


   The values on the initial seeds: line come in pairs.


   Within each pair, the first value is the start of the range and the second value is the length of the range.

   ## Examples

   iex> Day5Optimised.get_seed_ranges([1,2,3,4])
   [1..2, 3..6]
  """
  def get_seed_ranges([]), do: []

  def get_seed_ranges([start, len | rem]) do
    [start..(start + len - 1) | get_seed_ranges(rem)]
  end

  def parse_seeds("seeds: " <> seed_str) do
    seed_str |> String.split() |> Enum.map(&String.to_integer(&1))
  end

  def parse_map([map_name | inputs]) do
    [new_map_name, _] = map_name |> String.split()
    {new_map_name, inputs |> Enum.map(&transform_range_definition(&1))}
  end

  def transform_range_definition(range_str) do
    [dest_range_start, source_range_start, range_length] =
      String.split(range_str) |> Enum.map(&String.to_integer(&1))

    [
      dest_range_start: dest_range_start,
      source_range_start: source_range_start,
      range_length: range_length
    ]
  end

  def transform_range_with_single_range(is..ie,
        dest_range_start: dest_range_start,
        source_range_start: source_range_start,
        range_length: range_length
      ) do
    source_range_end = source_range_start + range_length - 1

    transform_range_internal(
      is..ie,
      source_range_start,
      source_range_end,
      dest_range_start,
      range_length
    )
  end

  # is..ie fully outside, single range
  def transform_range_internal(is..ie, source_range_start, source_range_end, _, _)
      when ie < source_range_start or is > source_range_end,
      # 0 matched ranges, 1 unmatched
      do: {[], [is..ie]}

  # fully inside, single range
  def transform_range_internal(
        is..ie,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )
      when is >= source_range_start and ie <= source_range_end do
    ts =
      transform_number_single_range(
        is,
        source_range_start,
        dest_range_start,
        range_length
      )

    te =
      transform_number_single_range(
        ie,
        source_range_start,
        dest_range_start,
        range_length
      )

    {[ts..te], []}
  end

  # overlap - input left end inside, right end outside the transformation

  def transform_range_internal(
        is..ie,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )
      when is >= source_range_start and ie > source_range_end do
    range1 = is..source_range_end
    range2 = (source_range_end + 1)..ie

    {[range1_transformed], []} =
      transform_range_internal(
        range1,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )

    # range2 needs no transformation
    {[range1_transformed], [range2]}
  end

  # overlap - input right end inside, left end outside the transformation

  def transform_range_internal(
        is..ie,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )
      when is < source_range_start and ie <= source_range_end do
    range1 = is..(source_range_start - 1)
    range2 = source_range_start..ie

    {[range2_transformed], []} =
      transform_range_internal(
        range2,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )

    # range1 needs no transformation
    {[range2_transformed], [range1]}
  end

  def transform_range_internal(
        is..ie,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )
      when is < source_range_start and ie > source_range_end do
    range1 = is..(source_range_start - 1)
    range2 = source_range_start..source_range_end
    range3 = (source_range_end + 1)..ie

    {[range2_transformed], []} =
      transform_range_internal(
        range2,
        source_range_start,
        source_range_end,
        dest_range_start,
        range_length
      )

    # range1/3 need no transformation
    {[range2_transformed], [range1, range3]}
  end

  def transform_number_single_range(
        number,
        source_range_start,
        dest_range_start,
        range_length
      )
      when number >= source_range_start and number < source_range_start + range_length do
    offset = number - source_range_start
    dest_range_start + offset
  end

  def transform_number_single_range(number, _), do: number

  def seed_range_to_location(range, mega_map) do
    [range]
    |> transform_ranges(mega_map["seed-to-soil"])
    |> transform_ranges(mega_map["soil-to-fertilizer"])
    |> transform_ranges(mega_map["fertilizer-to-water"])
    |> transform_ranges(mega_map["water-to-light"])
    |> transform_ranges(mega_map["light-to-temperature"])
    |> transform_ranges(mega_map["temperature-to-humidity"])
    |> transform_ranges(mega_map["humidity-to-location"])
  end

  def transform_ranges(input_range_list, []) do
    input_range_list |> IO.inspect(label: "transform_range final list", charlists: :as_lists)
  end

  def transform_ranges(input_range_list, [trans_range | remaining_transforms]) do
    # take list of ranges, and transform them all through each trans_range_list
    IO.inspect(input_range_list, label: "transform_ranges input")
    IO.inspect(trans_range, label: "transform_range active transformation")

    {matched_list, unmatched_list} =
      Enum.map(input_range_list, &transform_range_with_single_range(&1, trans_range))
      |> IO.inspect(label: "transform_range transformed", charlists: :as_lists)
      |> Enum.unzip()

    {matched_flat, unmatched_flat} =
      {matched_list |> List.flatten(), unmatched_list |> List.flatten()}

    matched_flat ++ transform_ranges(unmatched_flat, remaining_transforms)
  end
end
