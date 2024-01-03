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
    {{x, y}, _} = Enum.find(matrix, fn {_, sym} -> sym == @start_symbol end)

    {x, y}
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

  defp is_connected?(direction, connections) do
    Enum.member?(connections, direction)
  end

  def are_connected?(point1, point2, matrix) do
    connects_to?(point1, point2, matrix) and connects_to?(point2, point1, matrix)
  end

  def connects_to?(point1, point2, matrix) do
    connections1 = connections(matrix[point1])
    direction1to2 = point_direction(point1, point2)
    is_connected?(direction1to2, connections1)
  end

  def point_direction({x1, y1}, {x2, y2}) do
    direction(x2 - x1, y2 - y1)
  end

  def neighbours(point, directions, matrix) do
    Enum.map(directions, &move(point, &1)) |> Enum.filter(&is_valid_coord?(&1, matrix))
  end

  def connected_neighbours(point, directions, matrix) do
    neighbours(point, directions, matrix) |> Enum.filter(&are_connected?(point, &1, matrix))
  end

  def make_step(point, arrived_from, matrix) do
    directions = @directions -- [arrived_from]
    [next] = connected_neighbours(point, directions, matrix)
    next
  end

  def follow_path(stop_point, _, stop_point, path_so_far, _), do: [stop_point | path_so_far]

  def follow_path(
        current_point,
        forbidden_direction,
        stop_point,
        path_so_far,
        matrix
      ) do
    new_point =
      make_step(current_point, forbidden_direction, matrix)

    # no going back to current_point
    new_forbidden_direction = point_direction(new_point, current_point)

    follow_path(
      new_point,
      new_forbidden_direction,
      stop_point,
      [current_point | path_so_far],
      matrix
    )
  end

  def establish_start(matrix) do
    s_point = find_start(matrix)
    all_neighbours = neighbours(s_point, @directions, matrix)

    [start_point, stop_point] = Enum.filter(all_neighbours, &connects_to?(&1, s_point, matrix))

    first_prohibited_direction = point_direction(start_point, s_point)

    {start_point, first_prohibited_direction, stop_point, s_point}
  end
end
