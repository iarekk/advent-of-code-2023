defmodule Day5OptimisedTest do
  use ExUnit.Case
  doctest Day5Optimised

  test "transform_range_with_single_range" do
    map_def =
      [dest_range_start: 50, source_range_start: 98, range_length: 2]

    map_def1 =
      [dest_range_start: 52, source_range_start: 50, range_length: 48]

    map_def2 = [dest_range_start: 10, source_range_start: 1000, range_length: 100]

    # not in range
    assert Day5Optimised.transform_range_with_single_range(1..10, map_def) == {[], [1..10]}
    assert Day5Optimised.transform_range_with_single_range(100..150, map_def) == {[], [100..150]}
    assert Day5Optimised.transform_range_with_single_range(98..99, map_def) == {[50..51], []}

    # produces 2 new ranges

    assert Day5Optimised.transform_range_with_single_range(45..54, map_def1) ==
             {[52..56], [45..49]}

    assert Day5Optimised.transform_range_with_single_range(95..104, map_def1) ==
             {
               [97..99],
               [98..104]
             }

    assert Day5Optimised.transform_range_with_single_range(950..1149, map_def2) ==
             {[10..109],
              [
                950..999,
                1100..1149
              ]}

    # produces 3 new ranges

    # # boundary lower and upper
    # assert Day5Optimised.transform_number(98, map_def) == 50
    # assert Day5Optimised.transform_number(99, map_def) == 51

    # # more cases
    # assert Day5Optimised.transform_number(50, map_def) == 52
    # assert Day5Optimised.transform_number(97, map_def) == 99

    # # example data from the problem statement
    # assert Day5Optimised.transform_number(79, map_def) == 81
    # assert Day5Optimised.transform_number(14, map_def) == 14
    # assert Day5Optimised.transform_number(55, map_def) == 57
    # assert Day5Optimised.transform_number(13, map_def) == 13
  end

  # test "seed to location" do
  #   assert Day5Optimised.seed_to_location(79, mega_map()) == 82
  #   assert Day5Optimised.seed_to_location(14, mega_map()) == 43
  #   assert Day5Optimised.seed_to_location(55, mega_map()) == 86
  #   assert Day5Optimised.seed_to_location(13, mega_map()) == 35
  # end

  test "seed to location with ranges" do
    assert Day5Optimised.seed_range_to_location(79..79, mega_map()) == [82..82]
    assert Day5Optimised.seed_range_to_location(82..82, mega_map()) == [46..46]

    assert Day5Optimised.seed_range_to_location(79..92, mega_map())
           |> IO.inspect(label: "seed79..92", charlists: :as_lists)
           |> Enum.map(fn a.._ -> a end)
           |> IO.inspect(label: "seed79..92 mins", charlists: :as_lists)
           |> Enum.min() == 46

    assert Day5Optimised.seed_range_to_location(55..67, mega_map())
           |> Enum.map(fn a.._ -> a end)
           |> Enum.min() == 56
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
