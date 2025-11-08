defmodule Pathfinding.Directed.TopologicalSortTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.TopologicalSort

  describe "topological_sort/2" do
    test "sorts simple DAG" do
      successors = fn node ->
        cond do
          node <= 7 -> [node + 1, node + 2]
          node == 8 -> [9]
          true -> []
        end
      end

      result = TopologicalSort.topological_sort([5, 1], successors)

      assert {:ok, sorted} = result
      assert sorted == [1, 2, 3, 4, 5, 6, 7, 8, 9]
    end

    test "detects cycle in graph" do
      successors = fn node ->
        cond do
          node <= 6 -> [node + 1, node + 2, 7]
          node == 7 -> [8, 9]
          node == 8 -> [7, 9]
          true -> [7]
        end
      end

      result = TopologicalSort.topological_sort([5, 1], successors)

      assert {:error, _node} = result
    end

    test "handles single node" do
      successors = fn _ -> [] end
      result = TopologicalSort.topological_sort([1], successors)

      assert result == {:ok, [1]}
    end

    test "handles empty roots" do
      successors = fn _ -> [] end
      result = TopologicalSort.topological_sort([], successors)

      assert result == {:ok, []}
    end

    test "sorts linear dependency chain" do
      # 1 -> 2 -> 3 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> []
        _ -> []
      end

      result = TopologicalSort.topological_sort([1], successors)

      assert result == {:ok, [1, 2, 3, 4]}
    end

    test "sorts diamond dependency" do
      # 1 -> 2, 3
      # 2 -> 4
      # 3 -> 4
      successors = fn
        1 -> [2, 3]
        2 -> [4]
        3 -> [4]
        4 -> []
        _ -> []
      end

      result = TopologicalSort.topological_sort([1], successors)

      assert {:ok, sorted} = result
      # 1 must come before 2, 3
      # 2, 3 must come before 4
      assert hd(sorted) == 1
      assert List.last(sorted) == 4
      assert length(sorted) == 4
    end

    test "detects self-loop" do
      successors = fn
        1 -> [1]
        _ -> []
      end

      result = TopologicalSort.topological_sort([1], successors)

      assert {:error, 1} = result
    end
  end
end
