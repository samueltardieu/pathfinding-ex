defmodule Pathfinding.Directed.StronglyConnectedComponentsTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.StronglyConnectedComponents, as: SCC

  describe "strongly_connected_component/2" do
    test "finds component containing a single node in a cycle" do
      # Graph: 1 -> 2 -> 3 -> 1 (cycle)
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [1]
        _ -> []
      end

      component = SCC.strongly_connected_component(1, successors)
      assert MapSet.new(component) == MapSet.new([1, 2, 3])
    end

    test "finds component for node with self-loop" do
      successors = fn
        1 -> [1]
        _ -> []
      end

      component = SCC.strongly_connected_component(1, successors)
      assert component == [1]
    end

    test "finds component in graph with multiple SCCs" do
      # Graph: 1 -> 2 -> 3 -> 1 (cycle), 3 -> 4, 4 -> 5 -> 4 (another cycle)
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [1, 4]
        4 -> [5]
        5 -> [4]
        _ -> []
      end

      component1 = SCC.strongly_connected_component(1, successors)
      assert MapSet.new(component1) == MapSet.new([1, 2, 3])

      component4 = SCC.strongly_connected_component(4, successors)
      assert MapSet.new(component4) == MapSet.new([4, 5])
    end
  end

  describe "strongly_connected_components_from/2" do
    test "finds all SCCs reachable from start" do
      # Graph: 1 -> 2 -> 3 -> 1, 3 -> 4 -> 5 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [1, 4]
        4 -> [5]
        5 -> [4]
        _ -> []
      end

      sccs = SCC.strongly_connected_components_from(1, successors)

      # Should find 2 SCCs: [1,2,3] and [4,5]
      assert length(sccs) == 2
      scc_sets = Enum.map(sccs, &MapSet.new/1)
      assert MapSet.new([4, 5]) in scc_sets
      assert MapSet.new([1, 2, 3]) in scc_sets
    end

    test "handles single node graph" do
      successors = fn _ -> [] end
      sccs = SCC.strongly_connected_components_from(1, successors)

      assert sccs == [[1]]
    end
  end

  describe "strongly_connected_components/2" do
    test "finds all SCCs in disconnected graph" do
      # Two separate cycles: 1 <-> 2, and 3 <-> 4
      successors = fn
        1 -> [2]
        2 -> [1]
        3 -> [4]
        4 -> [3]
        _ -> []
      end

      sccs = SCC.strongly_connected_components([1, 2, 3, 4], successors)

      assert length(sccs) == 2
      scc_sets = Enum.map(sccs, &MapSet.new/1)
      assert MapSet.new([1, 2]) in scc_sets
      assert MapSet.new([3, 4]) in scc_sets
    end

    test "handles DAG (each node is its own SCC)" do
      # DAG: 1 -> 2 -> 3 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> []
        _ -> []
      end

      sccs = SCC.strongly_connected_components([1, 2, 3, 4], successors)

      # In a DAG, each node is its own SCC
      assert length(sccs) == 4
      scc_sets = Enum.map(sccs, &MapSet.new/1)
      assert MapSet.new([1]) in scc_sets
      assert MapSet.new([2]) in scc_sets
      assert MapSet.new([3]) in scc_sets
      assert MapSet.new([4]) in scc_sets
    end

    test "handles single large SCC" do
      # Complete cycle: 1 -> 2 -> 3 -> 4 -> 1
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> [1]
        _ -> []
      end

      sccs = SCC.strongly_connected_components([1, 2, 3, 4], successors)

      assert length(sccs) == 1
      assert MapSet.new(hd(sccs)) == MapSet.new([1, 2, 3, 4])
    end
  end
end
