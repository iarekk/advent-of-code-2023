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

  @start_node "AAA"
  @end_node "ZZZ"

  def read_file(file_path) do
    fstream = File.stream!(file_path)

    [path] = Stream.take(fstream, 1) |> Enum.to_list()

    tree_defs = Stream.drop(fstream, 2) |> Stream.map(&parse_node/1) |> Map.new()

    {path |> String.trim(), tree_defs}
  end

  def solve(file_path) do
    {path, tree} = read_file(file_path)

    commands = path |> String.graphemes() |> Stream.cycle()

    commands |> Enum.reduce_while({@start_node, 0, tree}, &perform_step/2)
  end

  def perform_step(_, {@end_node, step_count, _}), do: {:halt, step_count}

  def perform_step(command, {node_key, step_count, tree}) do
    next_node_key =
      get_next_node(command, tree[node_key])

    if(rem(step_count, 1000) == 0) do
      IO.puts("steps: #{step_count} node: #{node_key} command: #{command} next: #{next_node_key}")
    end

    {:cont, {next_node_key, step_count + 1, tree}}
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
