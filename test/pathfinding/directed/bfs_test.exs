defmodule Pathfinding.Directed.BFSTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.BFS

  describe "bfs/3" do
    test "finds shortest path for knight moves on chess board" do
      successors = fn {x, y} ->
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
      end

      goal = {4, 6}
      result = BFS.bfs({1, 1}, successors, fn p -> p == goal end)

      assert {:ok, path} = result
      assert length(path) == 5
      assert hd(path) == {1, 1}
      assert List.last(path) == {4, 6}
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 5, do: [n + 1], else: [] end
      result = BFS.bfs(1, successors, fn n -> n == 10 end)

      assert result == :error
    end

    test "finds path in simple graph" do
      # Graph: 1 -> 2 -> 3 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> []
        _ -> []
      end

      result = BFS.bfs(1, successors, fn n -> n == 4 end)

      assert {:ok, [1, 2, 3, 4]} = result
    end

    test "start node is goal" do
      successors = fn n -> [n + 1] end
      result = BFS.bfs(5, successors, fn n -> n == 5 end)

      assert {:ok, [5]} = result
    end

    test "handles cycles without infinite loop" do
      # Graph with cycle: 1 -> 2 -> 3 -> 2
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [2, 4]
        4 -> []
        _ -> []
      end

      result = BFS.bfs(1, successors, fn n -> n == 4 end)

      assert {:ok, path} = result
      assert hd(path) == 1
      assert List.last(path) == 4
    end
  end

  describe "bfs_bidirectional/4" do
    test "finds shortest path for knight moves" do
      successors = fn {x, y} ->
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
      end

      result = BFS.bfs_bidirectional({1, 1}, {4, 6}, successors, successors)

      assert {:ok, path} = result
      assert length(path) == 5
      assert hd(path) == {1, 1}
      assert List.last(path) == {4, 6}
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 5, do: [n + 1], else: [] end
      result = BFS.bfs_bidirectional(1, 10, successors, successors)

      assert result == :error
    end

    test "finds path in simple directed graph" do
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        _ -> []
      end

      predecessors = fn
        4 -> [3]
        3 -> [2]
        2 -> [1]
        _ -> []
      end

      result = BFS.bfs_bidirectional(1, 4, successors, predecessors)

      assert {:ok, path} = result
      assert hd(path) == 1
      assert List.last(path) == 4
    end
  end

  describe "bfs_reach/2" do
    test "visits all reachable nodes" do
      all_nodes = BFS.bfs_reach(3, fn _ -> 1..5 end) |> Enum.to_list()

      assert all_nodes == [3, 1, 2, 4, 5]
    end

    test "generates multiples correctly" do
      result =
        BFS.bfs_reach(1, fn n -> [n * 2, n * 3] end)
        |> Stream.drop(1)
        |> Enum.take(7)

      assert result == [2, 3, 4, 6, 9, 8, 12]
    end

    test "handles nodes with no successors" do
      result = BFS.bfs_reach(1, fn _ -> [] end) |> Enum.to_list()

      assert result == [1]
    end

    test "stops when no new nodes to visit" do
      successors = fn n -> if n < 5, do: [n + 1], else: [] end
      result = BFS.bfs_reach(1, successors) |> Enum.to_list()

      assert result == [1, 2, 3, 4, 5]
    end
  end
end
