defmodule Pathfinding.Directed.AstarTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.Astar

  describe "astar/4" do
    test "finds shortest path for knight moves with heuristic" do
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
        |> Enum.map(fn pos -> {pos, 1} end)
      end

      goal = {4, 6}

      heuristic = fn {x, y} ->
        div(abs(elem(goal, 0) - x) + abs(elem(goal, 1) - y), 3)
      end

      result = Astar.astar({1, 1}, successors, heuristic, fn p -> p == goal end)

      assert {:ok, {path, cost}} = result
      assert cost == 4
      assert hd(path) == {1, 1}
      assert List.last(path) == goal
    end

    test "finds optimal path with good heuristic" do
      # Simple graph where heuristic helps
      # 1 -> 2 (cost 1) -> 4 (cost 1) = total 2
      # 1 -> 3 (cost 1) -> 4 (cost 10) = total 11
      successors = fn
        1 -> [{2, 1}, {3, 1}]
        2 -> [{4, 1}]
        3 -> [{4, 10}]
        4 -> []
        _ -> []
      end

      # Heuristic that guides toward node 2
      heuristic = fn
        1 -> 2
        2 -> 1
        3 -> 10
        4 -> 0
        _ -> 0
      end

      result = Astar.astar(1, successors, heuristic, fn n -> n == 4 end)

      assert {:ok, {path, cost}} = result
      assert path == [1, 2, 4]
      assert cost == 2
    end

    test "works correctly with zero heuristic (becomes Dijkstra)" do
      successors = fn
        1 -> [{2, 1}, {3, 3}]
        2 -> [{4, 1}]
        3 -> [{4, 2}]
        4 -> []
        _ -> []
      end

      # Zero heuristic makes it behave like Dijkstra
      heuristic = fn _ -> 0 end

      result = Astar.astar(1, successors, heuristic, fn n -> n == 4 end)

      assert {:ok, {path, cost}} = result
      assert path == [1, 2, 4]
      assert cost == 2
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 5, do: [{n + 1, 1}], else: [] end
      heuristic = fn n -> abs(10 - n) end

      result = Astar.astar(1, successors, heuristic, fn n -> n == 10 end)

      assert result == :error
    end

    test "start node is goal" do
      successors = fn n -> [{n + 1, 1}] end
      heuristic = fn _ -> 0 end

      result = Astar.astar(5, successors, heuristic, fn n -> n == 5 end)

      assert {:ok, {[5], 0}} = result
    end

    test "handles graph with cycles" do
      successors = fn
        1 -> [{2, 1}]
        2 -> [{3, 1}]
        3 -> [{2, 1}, {4, 1}]
        4 -> []
        _ -> []
      end

      heuristic = fn
        1 -> 3
        2 -> 2
        3 -> 1
        4 -> 0
        _ -> 0
      end

      result = Astar.astar(1, successors, heuristic, fn n -> n == 4 end)

      assert {:ok, {path, _cost}} = result
      assert hd(path) == 1
      assert List.last(path) == 4
      # Should not visit nodes multiple times in the path
      assert length(path) == length(Enum.uniq(path))
    end

    test "heuristic improves search efficiency" do
      # Grid where A* with good heuristic should explore fewer nodes than Dijkstra
      # This test just checks correctness, not efficiency
      successors = fn {x, y} ->
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
        |> Enum.filter(fn {nx, ny} -> nx >= 0 and nx <= 10 and ny >= 0 and ny <= 10 end)
        |> Enum.map(fn pos -> {pos, 1} end)
      end

      goal = {10, 10}
      # Manhattan distance heuristic
      heuristic = fn {x, y} ->
        abs(elem(goal, 0) - x) + abs(elem(goal, 1) - y)
      end

      result = Astar.astar({0, 0}, successors, heuristic, fn p -> p == goal end)

      assert {:ok, {_path, cost}} = result
      # Manhattan distance from (0,0) to (10,10) is 20
      assert cost == 20
    end
  end
end
