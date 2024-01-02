defmodule Day10 do
  @start_symbol "S"
  @directions [:north, :west, :south, :east]

  def read_file(file_path) do
    File.stream!(file_path)
    |> Stream.with_index()
    |> Stream.flat_map(&parse_line_to_row/1)
    |> Map.new()
  end

  def solve(file_path) do
    matrix = read_file(file_path)

    {start, first_forbidden_direction, stop, _} = establish_start(matrix)

    # step list excluding the 'S' point
    step_list = follow_path(start, first_forbidden_direction, stop, [], matrix)

    answer = determine_furthest_step_count(step_list |> length)

    answer
  end

  def determine_furthest_step_count(n) when rem(n, 2) == 0, do: div(n, 2) - 1
  def determine_furthest_step_count(n), do: div(n + 1, 2)

  def parse_line_to_row({str, row_index}) do
    str
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {sym, col_index} -> {{row_index, col_index}, sym} end)
  end

  def find_start(matrix) do
    [{x, y}] = Map.filter(matrix, fn {_, sym} -> sym == @start_symbol end) |> Map.keys()

    {x, y}
  end

  def find_rows_cols_count(matrix) do
    keys = Map.keys(matrix)

    row_indices = Enum.map(keys, fn {x, _} -> x end)
    col_indices = Enum.map(keys, fn {_, y} -> y end)

    {Enum.max(row_indices) + 1, Enum.max(col_indices) + 1}
  end

  def move({x, y}, :north), do: {x - 1, y}
  def move({x, y}, :south), do: {x + 1, y}
  def move({x, y}, :west), do: {x, y - 1}
  def move({x, y}, :east), do: {x, y + 1}

  def direction(-1, 0), do: :north
  def direction(1, 0), do: :south
  def direction(0, -1), do: :west
  def direction(0, 1), do: :east
  def direction(i, j), do: raise("invalid direction argument #{inspect({i, j})}")

  def is_valid_coord?({_, _} = coords, matrix) do
    Map.has_key?(matrix, coords)
  end

  # | is a vertical pipe connecting north and south.
  # - is a horizontal pipe connecting east and west.
  # L is a 90-degree bend connecting north and east.
  # J is a 90-degree bend connecting north and west.
  # 7 is a 90-degree bend connecting south and west.
  # F is a 90-degree bend connecting south and east.
  # . is ground; there is no pipe in this tile.

  # how to handle S? connected to everything? we are guaranteed only 2 connections
  def connections("|"), do: [:north, :south]
  def connections("-"), do: [:east, :west]
  def connections("L"), do: [:north, :east]
  def connections("J"), do: [:north, :west]
  def connections("7"), do: [:south, :west]
  def connections("F"), do: [:south, :east]
  def connections(_), do: []

  defp are_connected_p?({x1, y1}, sym1, {x2, y2}, sym2) do
    # direction point1 to point2
    # |> IO.inspect(label: "direction 1 -> 2")
    direction1to2 = direction(x2 - x1, y2 - y1)
    # |> IO.inspect(label: "connections 1")
    connections1 = connections(sym1)

    point1_connects_to2 = is_connected?(direction1to2, connections1)

    # |> IO.inspect(label: "direction 2 -> 1")
    direction2to1 = direction(x1 - x2, y1 - y2)
    # |> IO.inspect(label: "connections 2")
    connections2 = connections(sym2)

    point2_connects_to1 = is_connected?(direction2to1, connections2)

    point1_connects_to2 and point2_connects_to1

    # Enum.member?(connections1, direction1) and Enum.member?(connections2, direction2)
  end

  defp is_connected?(direction, connections) do
    Enum.member?(connections, direction)
  end

  def are_connected?({x1, y1}, {x2, y2}, matrix) do
    are_connected_p?({x1, y1}, matrix[{x1, y1}], {x2, y2}, matrix[{x2, y2}])
  end

  def neighbours({x, y}, directions, matrix) do
    Enum.map(directions, &move({x, y}, &1)) |> Enum.filter(&is_valid_coord?(&1, matrix))
  end

  def connected_neighbours({x, y}, directions, matrix) do
    neighbours({x, y}, directions, matrix) |> Enum.filter(&are_connected?({x, y}, &1, matrix))
  end

  def make_step({x, y}, arrived_from, matrix) do
    directions = List.delete(@directions, arrived_from)
    [next] = connected_neighbours({x, y}, directions, matrix)
    next
  end

  def follow_path({x, y}, forbidden_direction, {stop_x, stop_y}, path_so_far, matrix) do
    {x_new, y_new} =
      make_step({x, y}, forbidden_direction, matrix) |> IO.inspect(label: "new coords")

    if({x_new, y_new} == {stop_x, stop_y}) do
      [{x_new, y_new}, {x, y} | path_so_far]
    else
      # this is a 'return' direction that we can't be taking from this cell
      new_forbidden_direction =
        direction(x - x_new, y - y_new) |> IO.inspect(label: "new forbidden direction")

      follow_path(
        {x_new, y_new},
        new_forbidden_direction,
        {stop_x, stop_y},
        [{x, y} | path_so_far],
        matrix
      )
    end
  end

  def establish_start(matrix) do
    {s_x, s_y} = find_start(matrix)
    all_neighbours = neighbours({s_x, s_y}, @directions, matrix)

    [start, stop] = Enum.filter(all_neighbours, &is_connected_to_start?({s_x, s_y}, &1, matrix))

    {start_x, start_y} = start

    first_prohibited_direction =
      direction(s_x - start_x, s_y - start_y) |> IO.inspect(label: "prohibited direction start")

    {start, first_prohibited_direction, stop, {s_x, s_y}}
  end

  def is_connected_to_start?({s_x, s_y}, {x, y}, matrix) do
    directions_point = direction(s_x - x, s_y - y) |> IO.inspect(label: "direction s -> point")
    connections_point = connections(matrix[{x, y}]) |> IO.inspect(label: "connections point")

    is_connected?(directions_point, connections_point)
  end
end
