defmodule Pathfinding.Directed.DijkstraTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.Dijkstra

  describe "dijkstra/3" do
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
        |> Enum.map(fn pos -> {pos, 1} end)
      end

      result = Dijkstra.dijkstra({1, 1}, successors, fn p -> p == {4, 6} end)

      assert {:ok, {path, cost}} = result
      assert cost == 4
      assert hd(path) == {1, 1}
      assert List.last(path) == {4, 6}
    end

    test "finds shortest path in weighted graph" do
      # Graph: 1 --(1)--> 2 --(2)--> 3 --(3)--> 4
      #        1 --(10)-------------> 4
      successors = fn
        1 -> [{2, 1}, {4, 10}]
        2 -> [{3, 2}]
        3 -> [{4, 3}]
        4 -> []
        _ -> []
      end

      result = Dijkstra.dijkstra(1, successors, fn n -> n == 4 end)

      assert {:ok, {path, cost}} = result
      # Best path is 1 -> 2 -> 3 -> 4 with cost 6 (not 1 -> 4 with cost 10)
      assert path == [1, 2, 3, 4]
      assert cost == 6
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 5, do: [{n + 1, 1}], else: [] end
      result = Dijkstra.dijkstra(1, successors, fn n -> n == 10 end)

      assert result == :error
    end

    test "start node is goal" do
      successors = fn n -> [{n + 1, 1}] end
      result = Dijkstra.dijkstra(5, successors, fn n -> n == 5 end)

      assert {:ok, {[5], 0}} = result
    end

    test "handles graph with multiple paths" do
      # Graph with two paths: 1 -> 2 -> 4 (cost 2) and 1 -> 3 -> 4 (cost 5)
      successors = fn
        1 -> [{2, 1}, {3, 3}]
        2 -> [{4, 1}]
        3 -> [{4, 2}]
        4 -> []
        _ -> []
      end

      result = Dijkstra.dijkstra(1, successors, fn n -> n == 4 end)

      assert {:ok, {path, cost}} = result
      # Should take the shorter path
      assert path == [1, 2, 4]
      assert cost == 2
    end

    test "handles cycles correctly" do
      # Graph with cycle: 1 -> 2 -> 3 -> 2
      successors = fn
        1 -> [{2, 1}]
        2 -> [{3, 1}]
        3 -> [{2, 1}, {4, 1}]
        4 -> []
        _ -> []
      end

      result = Dijkstra.dijkstra(1, successors, fn n -> n == 4 end)

      assert {:ok, {path, _cost}} = result
      assert hd(path) == 1
      assert List.last(path) == 4
      # Should visit each node at most once in the path
      assert length(path) == length(Enum.uniq(path))
    end
  end

  describe "dijkstra_all/2" do
    test "finds all reachable nodes with costs" do
      successors = fn n ->
        if n <= 4 do
          [{n * 2, 10}, {n * 2 + 1, 10}]
        else
          []
        end
      end

      reachables = Dijkstra.dijkstra_all(1, successors)

      assert map_size(reachables) == 8
      # 1 -> 2
      assert reachables[2] == {1, 10}
      # 1 -> 3
      assert reachables[3] == {1, 10}
      # 1 -> 2 -> 4
      assert reachables[4] == {2, 20}
      # 1 -> 2 -> 5
      assert reachables[5] == {2, 20}
      # 1 -> 3 -> 6
      assert reachables[6] == {3, 20}
      # 1 -> 3 -> 7
      assert reachables[7] == {3, 20}
      # 1 -> 2 -> 4 -> 8
      assert reachables[8] == {4, 30}
      # 1 -> 2 -> 4 -> 9
      assert reachables[9] == {4, 30}
    end

    test "handles disconnected graph" do
      successors = fn
        1 -> [{2, 1}]
        2 -> []
        3 -> [{4, 1}]
        _ -> []
      end

      reachables = Dijkstra.dijkstra_all(1, successors)

      # Should only find nodes reachable from 1
      assert Map.has_key?(reachables, 2)
      refute Map.has_key?(reachables, 3)
      refute Map.has_key?(reachables, 4)
    end

    test "handles single node graph" do
      successors = fn _ -> [] end

      reachables = Dijkstra.dijkstra_all(1, successors)

      # No reachable nodes except start
      assert reachables == %{}
    end
  end
end
