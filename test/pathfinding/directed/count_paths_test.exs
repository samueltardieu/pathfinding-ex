defmodule Pathfinding.Directed.CountPathsTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.CountPaths

  describe "count_paths/3" do
    test "counts paths on 8x8 grid" do
      # From bottom-left to top-right, only moving right or up
      successors = fn {x, y} ->
        [{x + 1, y}, {x, y + 1}]
        |> Enum.filter(fn {x, y} -> x < 8 and y < 8 end)
      end

      n = CountPaths.count_paths({0, 0}, successors, fn c -> c == {7, 7} end)
      assert n == 3432
    end

    test "counts paths in simple graph" do
      # Graph: 1 -> 2, 1 -> 3, 2 -> 4, 3 -> 4
      # Two paths from 1 to 4: 1->2->4 and 1->3->4
      successors = fn
        1 -> [2, 3]
        2 -> [4]
        3 -> [4]
        4 -> []
        _ -> []
      end

      n = CountPaths.count_paths(1, successors, fn node -> node == 4 end)
      assert n == 2
    end

    test "counts single path" do
      # Linear graph: 1 -> 2 -> 3 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> []
        _ -> []
      end

      n = CountPaths.count_paths(1, successors, fn node -> node == 4 end)
      assert n == 1
    end

    test "returns 0 when no path exists" do
      # Graph: 1 -> 2, but goal is 3 (unreachable)
      successors = fn
        1 -> [2]
        2 -> []
        _ -> []
      end

      n = CountPaths.count_paths(1, successors, fn node -> node == 3 end)
      assert n == 0
    end

    test "start node is goal" do
      successors = fn _ -> [] end
      n = CountPaths.count_paths(1, successors, fn node -> node == 1 end)
      assert n == 1
    end

    test "counts paths with diamond structure" do
      # Graph: 1 -> 2, 1 -> 3, 2 -> 4, 2 -> 5, 3 -> 4, 3 -> 5
      # Many paths from 1 to 4 or 5
      successors = fn
        1 -> [2, 3]
        2 -> [4, 5]
        3 -> [4, 5]
        4 -> []
        5 -> []
        _ -> []
      end

      # Paths to 4: 1->2->4, 1->3->4
      n4 = CountPaths.count_paths(1, successors, fn node -> node == 4 end)
      assert n4 == 2

      # Paths to 5: 1->2->5, 1->3->5
      n5 = CountPaths.count_paths(1, successors, fn node -> node == 5 end)
      assert n5 == 2
    end

    test "counts paths on small grid" do
      # 3x3 grid, bottom-left to top-right
      successors = fn {x, y} ->
        [{x + 1, y}, {x, y + 1}]
        |> Enum.filter(fn {x, y} -> x < 3 and y < 3 end)
      end

      n = CountPaths.count_paths({0, 0}, successors, fn c -> c == {2, 2} end)
      # Binomial coefficient C(4,2) = 6
      assert n == 6
    end
  end
end
