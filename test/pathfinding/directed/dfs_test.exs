defmodule Pathfinding.Directed.DFSTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.DFS

  describe "dfs/3" do
    test "finds path with adder first" do
      successors = fn n -> [n + 1, n * n] |> Enum.filter(fn x -> x <= 17 end) end
      result = DFS.dfs(1, successors, fn n -> n == 17 end)

      assert {:ok, path} = result
      assert path == Enum.to_list(1..17)
    end

    test "finds shorter path with multiplier first" do
      successors = fn n -> [n * n, n + 1] |> Enum.filter(fn x -> x <= 17 end) end
      result = DFS.dfs(1, successors, fn n -> n == 17 end)

      assert {:ok, path} = result
      assert path == [1, 2, 4, 16, 17]
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 5, do: [n + 1], else: [] end
      result = DFS.dfs(1, successors, fn n -> n == 10 end)

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

      result = DFS.dfs(1, successors, fn n -> n == 4 end)

      assert {:ok, [1, 2, 3, 4]} = result
    end

    test "start node is goal" do
      successors = fn n -> [n + 1] end
      result = DFS.dfs(5, successors, fn n -> n == 5 end)

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

      result = DFS.dfs(1, successors, fn n -> n == 4 end)

      assert {:ok, path} = result
      assert hd(path) == 1
      assert List.last(path) == 4
    end

    test "explores in depth-first order" do
      # Graph with branches
      successors = fn
        1 -> [2, 3]
        2 -> [4, 5]
        3 -> [6, 7]
        _ -> []
      end

      result = DFS.dfs(1, successors, fn n -> n == 7 end)

      # DFS should explore 1 -> 2 -> 4, 5 before trying 3 -> 6, 7
      assert {:ok, [1, 3, 7]} = result
    end
  end

  describe "dfs_reach/2" do
    test "visits all reachable nodes in DFS order" do
      all_nodes = DFS.dfs_reach(3, fn _ -> 1..5 end) |> Enum.to_list()

      assert all_nodes == [3, 1, 2, 4, 5]
    end

    test "generates multiples correctly in DFS order" do
      result =
        DFS.dfs_reach(1, fn n -> [n * 2, n * 3] |> Enum.filter(&(&1 < 15)) end)
        |> Stream.drop(1)
        |> Enum.take(7)

      assert result == [2, 4, 8, 12, 6, 3, 9]
    end

    test "handles nodes with no successors" do
      result = DFS.dfs_reach(1, fn _ -> [] end) |> Enum.to_list()

      assert result == [1]
    end

    test "stops when no new nodes to visit" do
      successors = fn n -> if n < 5, do: [n + 1], else: [] end
      result = DFS.dfs_reach(1, successors) |> Enum.to_list()

      assert result == [1, 2, 3, 4, 5]
    end

    test "handles graph with multiple branches" do
      successors = fn
        1 -> [2, 3]
        2 -> [4]
        3 -> [5]
        _ -> []
      end

      result = DFS.dfs_reach(1, successors) |> Enum.to_list()

      # DFS explores depth-first: 1 -> 2 -> 4 -> (backtrack) -> 3 -> 5
      assert result == [1, 2, 4, 3, 5]
    end
  end
end
