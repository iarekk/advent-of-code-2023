defmodule Day5Test do
  use ExUnit.Case
  doctest Day5

  test "greets the world" do
    assert Day5.hello() == :world
  end

  test "seed to soil" do
    map_def = [
      [dest_range_start: 50, source_range_start: 98, range_length: 2],
      [dest_range_start: 52, source_range_start: 50, range_length: 48]
    ]

    # not in range
    assert Day5.transform_number(10, map_def) == 10
    # boundary lower and upper
    assert Day5.transform_number(98, map_def) == 50
    assert Day5.transform_number(99, map_def) == 51

    # more cases
    assert Day5.transform_number(50, map_def) == 52
    assert Day5.transform_number(97, map_def) == 99

    # example data from the problem statement
    assert Day5.transform_number(79, map_def) == 81
    assert Day5.transform_number(14, map_def) == 14
    assert Day5.transform_number(55, map_def) == 57
    assert Day5.transform_number(13, map_def) == 13
  end

  test "seed to location" do
    assert Day5.seed_to_location(79, mega_map()) == 82
    assert Day5.seed_to_location(14, mega_map()) == 43
    assert Day5.seed_to_location(55, mega_map()) == 86
    assert Day5.seed_to_location(13, mega_map()) == 35
  end

  # from the problem statement
  def mega_map,
    do: %{
      "fertilizer-to-water" => [
        [dest_range_start: 49, source_range_start: 53, range_length: 8],
        [dest_range_start: 0, source_range_start: 11, range_length: 42],
        [dest_range_start: 42, source_range_start: 0, range_length: 7],
        [dest_range_start: 57, source_range_start: 7, range_length: 4]
      ],
      "light-to-temperature" => [
        [dest_range_start: 45, source_range_start: 77, range_length: 23],
        [dest_range_start: 81, source_range_start: 45, range_length: 19],
        [dest_range_start: 68, source_range_start: 64, range_length: 13]
      ],
      "seed-to-soil" => [
        [dest_range_start: 50, source_range_start: 98, range_length: 2],
        [dest_range_start: 52, source_range_start: 50, range_length: 48]
      ],
      "soil-to-fertilizer" => [
        [dest_range_start: 0, source_range_start: 15, range_length: 37],
        [dest_range_start: 37, source_range_start: 52, range_length: 2],
        [dest_range_start: 39, source_range_start: 0, range_length: 15]
      ],
      "temperature-to-humidity" => [
        [dest_range_start: 0, source_range_start: 69, range_length: 1],
        [dest_range_start: 1, source_range_start: 0, range_length: 69]
      ],
      "water-to-light" => [
        [dest_range_start: 88, source_range_start: 18, range_length: 7],
        [dest_range_start: 18, source_range_start: 25, range_length: 70]
      ],
      "humidity-to-location" => [
        [dest_range_start: 60, source_range_start: 56, range_length: 37],
        [dest_range_start: 56, source_range_start: 93, range_length: 4]
      ]
    }
end
