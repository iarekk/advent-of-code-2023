defmodule Day10 do
  @start_symbol "S"
  @directions [:north, :west, :south, :east]
  @symbol_types [
    "|",
    "-",
    "L",
    "J",
    "7",
    "F"
  ]

  @up_corners ["L", "J"]
  @down_corners ["7", "F"]
  @vpipe "|"

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
    step_list =
      follow_path(start, first_forbidden_direction, stop, [], matrix)
      |> IO.inspect(label: "step_list")

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

  def determine_s_point_shape(s_point, [start_point, stop_point]) do
    direction1 = point_direction(s_point, start_point)
    direction2 = point_direction(s_point, stop_point)

    Enum.find(@symbol_types, &matches_directions?(&1, direction1, direction2))
  end

  def matches_directions?(symbol, direction1, direction2) do
    conns = connections(symbol)

    Enum.member?(conns, direction1) and Enum.member?(conns, direction2)
  end

  def solve_part_2(file_path) do
    matrix = read_file(file_path)

    {start, first_forbidden_direction, stop, s_point} = establish_start(matrix)

    # step list including the 'S' point
    step_list = follow_path(start, first_forbidden_direction, stop, [s_point], matrix)
    # |> IO.inspect(label: "step list")

    s_symbol = determine_s_point_shape(s_point, [start, stop])

    updated_matrix = %{matrix | s_point => s_symbol}
    # |> IO.inspect(label: "new matrix")

    max_row =
      Enum.map(step_list, &(&1 |> elem(0)))
      # |> IO.inspect(label: "step rows")
      |> Enum.max()

    max_col =
      Enum.map(step_list, &(&1 |> elem(1)))
      # |> IO.inspect(label: "step cols")
      |> Enum.max()

    0..max_row |> Enum.map(&horizontal_scan(&1, max_col, updated_matrix, step_list)) |> Enum.sum()
  end

  def horizontal_scan(row_number, max_col, matrix, loop_definition) do
    scan_step(false, {row_number, 0}, :none, {matrix, loop_definition, max_col}, 0)
    # |> IO.inspect(label: "found on row #{row_number}")
  end

  def scan_step(_, {_, max_col}, _, {_, _, max_col}, acc), do: acc

  def scan_step(
        is_inside?,
        {row_index, col_index},
        last_seen_corner_point,
        {matrix, loop_def, max_col},
        acc
      ) do
    sym =
      matrix[{row_index, col_index}]

    # IO.puts(
    #   "Scan Step #{inspect({row_index, col_index})}. Is inside: #{is_inside?}. Acc: #{acc}. Sym: #{sym}"
    # )

    on_loop? = Enum.member?(loop_def, {row_index, col_index})

    # TODO
    new_inside? =
      if should_change_sides?(last_seen_corner_point, sym, on_loop?),
        do: not is_inside?,
        else: is_inside?

    # TODO
    new_corner =
      if on_loop?,
        do: check_for_corner(get_corner_direction(sym), last_seen_corner_point),
        else: last_seen_corner_point

    # TODO
    new_acc = if is_inside? and not on_loop?, do: acc + 1, else: acc

    scan_step(
      new_inside?,
      {row_index, col_index + 1},
      new_corner,
      {matrix, loop_def, max_col},
      new_acc
    )
  end

  def should_change_sides?(last_seen_corner_direction, sym, is_on_loop?) do
    is_pipe? = sym == @vpipe

    corner_direction = get_corner_direction(sym)

    should_change?(is_on_loop?, is_pipe?, corner_direction, last_seen_corner_direction)
  end

  def get_corner_direction(sym) when sym in @up_corners, do: :up
  def get_corner_direction(sym) when sym in @down_corners, do: :down
  def get_corner_direction(_), do: :none

  # not on the loop
  def should_change?(false, _, _, _), do: false
  # found pipe on the loop, means we're crossing the boundary
  def should_change?(true, true, _, _), do: true

  # going left to right, we should hit a corner or a vertical pipe first, so this should be impossible
  def should_change?(true, false, :none, :none),
    do:
      raise(
        "on the loop, not a vertical pipe, not a corner, haven't seen a corner, should be impossible"
      )

  # rounding the corner with the same direction (e.g. L---J, so we don't cross the loop boundary)
  def should_change?(true, false, dir, dir) when dir in [:up, :down], do: false

  # we've traversed past opposite corners (e.g. L---7), which means we cross the loop boundary
  def should_change?(true, false, :up, :down), do: true
  def should_change?(true, false, :down, :up), do: true

  # on the loop, not a vertical pipe, and first time we're seeing a corner
  # not changing direction, but the corner will be remembered through the `check_for_corner` call
  def should_change?(true, false, :down, :none), do: false
  def should_change?(true, false, :up, :none), do: false

  # on the loop, not a vertical pipe, and not a corner - we're walking a horizontal boundary (somewhere in the middle of L---J)
  def should_change?(true, false, :none, :down), do: false
  def should_change?(true, false, :none, :up), do: false

  # reset corners after seeing two consecutive corners
  def check_for_corner(cur, :none), do: cur
  def check_for_corner(:none, prev), do: prev
  def check_for_corner(cur, prev) when cur in [:up, :down] and prev in [:up, :down], do: :none
end
