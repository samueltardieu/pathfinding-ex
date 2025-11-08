defmodule Pathfinding.Undirected.KruskalTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Undirected.Kruskal

  describe "kruskal/1" do
    test "finds minimum spanning tree" do
      edges = [
        {:a, :b, 7},
        {:a, :d, 5},
        {:b, :c, 8},
        {:b, :d, 9},
        {:b, :e, 7},
        {:c, :e, 5},
        {:d, :e, 15},
        {:d, :f, 6},
        {:e, :f, 8},
        {:e, :g, 9},
        {:f, :g, 11}
      ]

      mst = Kruskal.kruskal(edges)

      # MST should have n-1 edges where n is number of nodes
      # We have 7 nodes (a-g), so MST should have 6 edges
      assert length(mst) == 6

      # Calculate total weight
      total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
      assert total_weight == 39
    end

    test "handles simple tree" do
      edges = [
        {1, 2, 1},
        {2, 3, 2},
        {3, 4, 3}
      ]

      mst = Kruskal.kruskal(edges)

      assert length(mst) == 3
      total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
      assert total_weight == 6
    end

    test "selects minimum weight edges" do
      edges = [
        {:a, :b, 1},
        {:b, :c, 2},
        # This edge should not be in MST
        {:a, :c, 10}
      ]

      mst = Kruskal.kruskal(edges)

      assert length(mst) == 2
      total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
      assert total_weight == 3
    end

    test "handles single edge" do
      edges = [{:a, :b, 5}]
      mst = Kruskal.kruskal(edges)

      assert mst == [{:a, :b, 5}]
    end

    test "handles complete graph with 4 nodes" do
      # Complete graph K4
      edges = [
        {1, 2, 1},
        {1, 3, 2},
        {1, 4, 3},
        {2, 3, 4},
        {2, 4, 5},
        {3, 4, 6}
      ]

      mst = Kruskal.kruskal(edges)

      # Should have 3 edges (n-1 for 4 nodes)
      assert length(mst) == 3

      # Should select the 3 smallest edges: 1, 2, 3
      total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
      assert total_weight == 6
    end
  end
end
