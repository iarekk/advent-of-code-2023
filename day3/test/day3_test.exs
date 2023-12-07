defmodule Day3Test do
  use ExUnit.Case
  doctest Day3

  test "greets the world" do
    assert Day3.hello() == :world
  end

  test "chunking" do
    input = "..897..*.....*....628"

    [_, chunk897, _, chunk628] = input |> Day3.split_numbers_and_nonnumbers() |> Day3.chunkify()

    {num, st, len, _} = chunk897
    assert String.slice(input, st, len) == "897"
    assert num == "897"

    {num1, st1, len1, _} = chunk628
    assert String.slice(input, st1, len1) == "628"
    assert num1 == "628"
  end
end
