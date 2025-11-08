#!/usr/bin/env elixir

# BFS Bidirectional Search Example
# Compares regular BFS with bidirectional BFS

defmodule BFSComparison do
  @moduledoc """
  Demonstrates the difference between regular BFS and bidirectional BFS.
  """

  @doc "Knight move successors"
  def knight_successors({x, y}) do
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
    |> Enum.filter(fn {nx, ny} -> nx >= 1 and nx <= 8 and ny >= 1 and ny <= 8 end)
  end

  @doc "Find path using regular BFS"
  def find_with_bfs(start, goal) do
    start_time = System.monotonic_time(:millisecond)

    result =
      Pathfinding.Directed.BFS.bfs(
        start,
        &knight_successors/1,
        fn pos -> pos == goal end
      )

    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time

    case result do
      {:ok, path} -> {:ok, path, duration}
      :error -> {:error, duration}
    end
  end

  @doc "Find path using bidirectional BFS"
  def find_with_bidirectional(start, goal) do
    start_time = System.monotonic_time(:millisecond)

    result =
      Pathfinding.Directed.BFS.bfs_bidirectional(
        start,
        goal,
        &knight_successors/1,
        &knight_successors/1
      )

    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time

    case result do
      {:ok, path} -> {:ok, path, duration}
      :error -> {:error, duration}
    end
  end

  @doc "Compare both algorithms"
  def compare(start, goal) do
    IO.puts("\n#{String.duplicate("=", 60)}")
    IO.puts("Finding path from #{inspect(start)} to #{inspect(goal)}")
    IO.puts(String.duplicate("=", 60))

    # Regular BFS
    IO.puts("\nRegular BFS:")
    {:ok, path1, time1} = find_with_bfs(start, goal)
    IO.puts("  ✓ Found path with #{length(path1)} nodes")
    IO.puts("  ⏱  Time: #{time1}ms")

    # Bidirectional BFS
    IO.puts("\nBidirectional BFS:")
    {:ok, path2, time2} = find_with_bidirectional(start, goal)
    IO.puts("  ✓ Found path with #{length(path2)} nodes")
    IO.puts("  ⏱  Time: #{time2}ms")

    # Show paths match
    if length(path1) == length(path2) do
      IO.puts("\n✓ Both algorithms found paths of the same length!")
    else
      IO.puts("\n⚠ Different path lengths: #{length(path1)} vs #{length(path2)}")
    end
  end
end

IO.puts("=== BFS vs Bidirectional BFS Comparison ===")

# Test with various distances
BFSComparison.compare({1, 1}, {2, 2})
BFSComparison.compare({1, 1}, {4, 6})
BFSComparison.compare({1, 1}, {8, 8})

IO.puts("\n#{String.duplicate("=", 60)}")
IO.puts("Note: Bidirectional search can be faster for long paths")
IO.puts("as it searches from both ends simultaneously!")
IO.puts(String.duplicate("=", 60))
