#!/usr/bin/env elixir

# Knight Moves Example
# This example demonstrates using BFS to find the shortest path
# for a knight on a chess board

defmodule KnightMoves do
  @moduledoc """
  Find the shortest path for a knight moving on a chess board.
  
  A knight can move in an L-shape: 2 squares in one direction and 1 square perpendicular.
  """

  @doc "Get all valid knight moves from a position"
  def successors({x, y}) do
    [
      {x + 1, y + 2},
      {x + 1, y - 2},
      {x - 1, y + 2},
      {x - 1, y - 2},
      {x + 2, y + 1},
      {x + 2, y - 1},
      {x - 2, y + 1},
      {x - 2, y - 1}
    ]
    # Filter to stay on an 8x8 chess board
    |> Enum.filter(fn {nx, ny} -> nx >= 1 and nx <= 8 and ny >= 1 and ny <= 8 end)
  end

  @doc "Find shortest path from start to goal"
  def find_path(start, goal) do
    IO.puts("Finding path from #{inspect(start)} to #{inspect(goal)}...")

    case Pathfinding.Directed.BFS.bfs(start, &successors/1, fn pos -> pos == goal end) do
      {:ok, path} ->
        IO.puts("✓ Path found in #{length(path) - 1} moves!")
        IO.puts("\nPath:")

        path
        |> Enum.with_index()
        |> Enum.each(fn {pos, i} ->
          IO.puts("  #{i}. #{inspect(pos)}")
        end)

        {:ok, path}

      :error ->
        IO.puts("✗ No path found!")
        :error
    end
  end
end

# Run examples
IO.puts("=== Knight Moves on Chess Board ===\n")

# Example 1: Classic problem from README
IO.puts("Example 1: From (1,1) to (4,6)")
{:ok, path1} = KnightMoves.find_path({1, 1}, {4, 6})
IO.puts("")

# Example 2: Opposite corners
IO.puts("Example 2: From (1,1) to (8,8)")
{:ok, path2} = KnightMoves.find_path({1, 1}, {8, 8})
IO.puts("")

# Example 3: Adjacent squares (surprisingly needs multiple moves!)
IO.puts("Example 3: From (1,1) to (2,2)")
{:ok, path3} = KnightMoves.find_path({1, 1}, {2, 2})
IO.puts("")

IO.puts("Summary:")
IO.puts("  (1,1) → (4,6): #{length(path1) - 1} moves")
IO.puts("  (1,1) → (8,8): #{length(path2) - 1} moves")
IO.puts("  (1,1) → (2,2): #{length(path3) - 1} moves")
