defmodule Day8 do
  @moduledoc """
  Documentation for `Day8`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day8.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(file_path) do
    fstream = File.stream!(file_path)

    [path] = Stream.take(fstream, 1) |> Enum.to_list()

    tree_defs = Stream.drop(fstream, 2) |> Stream.map(&parse_node/1) |> Map.new()

    {path |> String.trim(), tree_defs}
  end

  def solve(file_path) do
    {path, tree} = read_file(file_path)

    commands = path |> String.graphemes() |> Stream.cycle()

    # commands |> Enum.reduce_while({@start_node, 0, tree}, &perform_step/2)

    start_nodes =
      tree |> Map.keys() |> Enum.filter(&is_start_node?/1) |> IO.inspect(label: "start nodes")

    # commands |> Enum.reduce_while({start_nodes, 0, tree}, &perform_step/2)

    lengths =
      start_nodes
      |> Enum.map(fn node -> find_length_for_start_node(commands, node, tree) end)
      |> IO.inspect(label: "lengths")

    # solution owed to this thread: https://elixirforum.com/t/advent-of-code-2023-day-8/60244

    lowest_common_multiplier(lengths)
  end

  def lowest_common_multiplier([a]), do: a

  def lowest_common_multiplier([a, b | rest]),
    do: lowest_common_multiplier([Math.lcm(a, b) | rest])

  def find_length_for_start_node(command_stream, start_node, tree) do
    command_stream |> Enum.reduce_while({start_node, 0, tree}, &perform_step/2)
  end

  def is_start_node?(str) do
    [_, _, last] = str |> String.graphemes()

    last == "A"
  end

  def is_end_node?(str) do
    [_, _, last] = str |> String.graphemes()

    last == "Z"
  end

  #  def perform_step(_, {node, step_count, _}) when is_end_step(node), do: {:halt, step_count}

  def perform_step_batch(command, {node_keys, step_count, tree}) do
    if(Enum.all?(node_keys, &is_end_node?/1)) do
      {:halt, step_count}
    else
      next_node_keys =
        Enum.map(node_keys, fn nkey -> get_next_node(command, tree[nkey]) end)

      if(rem(step_count, 1_000_000) == 0) do
        IO.puts(
          "steps: #{step_count} nodes: #{inspect(node_keys)} command: #{command} next: #{inspect(next_node_keys)}"
        )
      end

      {:cont, {next_node_keys, step_count + 1, tree}}
    end
  end

  def perform_step(command, {node_key, step_count, tree}) do
    if(is_end_node?(node_key)) do
      {:halt, step_count}
    else
      next_node_key =
        get_next_node(command, tree[node_key])

      if(rem(step_count, 1000) == 0) do
        IO.puts(
          "steps: #{step_count} node: #{node_key} command: #{command} next: #{next_node_key}"
        )
      end

      {:cont, {next_node_key, step_count + 1, tree}}
    end
  end

  def get_next_node("R", {_, node_right}), do: node_right
  def get_next_node("L", {node_left, _}), do: node_left

  @doc """
  Splits the input node def into a tuple.

  ### Examples

  iex> Day8.parse_node("AAA = (BBB, CCC)")
  {"AAA", {"BBB", "CCC"}}
  """
  def parse_node(str) do
    [node_key, s2] = String.split(str, "=", trim: true)

    [left_key, right_key] =
      s2 |> String.replace("(", "") |> String.replace(")", "") |> String.split(",", trim: true)

    {node_key |> String.trim(), {left_key |> String.trim(), right_key |> String.trim()}}
  end
end
