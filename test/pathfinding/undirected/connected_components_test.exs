defmodule Pathfinding.Undirected.ConnectedComponentsTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Undirected.ConnectedComponents

  describe "connected_components/2" do
    test "finds three components in disconnected graph" do
      # Graph: 1-2-3  4-5  6
      neighbors = fn
        1 -> [2]
        2 -> [1, 3]
        3 -> [2]
        4 -> [5]
        5 -> [4]
        6 -> []
        _ -> []
      end

      components = ConnectedComponents.connected_components([1, 2, 3, 4, 5, 6], neighbors)

      assert length(components) == 3

      # Check that each component contains the expected vertices
      component_lists = Enum.map(components, &MapSet.to_list/1) |> Enum.sort()
      assert [1, 2, 3] in component_lists
      assert [4, 5] in component_lists
      assert [6] in component_lists
    end

    test "finds single component in connected graph" do
      # Graph: 1-2-3-4
      neighbors = fn
        1 -> [2]
        2 -> [1, 3]
        3 -> [2, 4]
        4 -> [3]
        _ -> []
      end

      components = ConnectedComponents.connected_components([1, 2, 3, 4], neighbors)

      assert length(components) == 1
      assert MapSet.to_list(hd(components)) |> Enum.sort() == [1, 2, 3, 4]
    end

    test "handles fully disconnected graph" do
      neighbors = fn _ -> [] end

      components = ConnectedComponents.connected_components([1, 2, 3], neighbors)

      assert length(components) == 3
      # Each node is its own component
      assert Enum.all?(components, fn comp -> MapSet.size(comp) == 1 end)
    end

    test "handles empty graph" do
      neighbors = fn _ -> [] end

      components = ConnectedComponents.connected_components([], neighbors)

      assert components == []
    end

    test "handles complex graph with multiple components" do
      # Graph:  1-2    3-4-5
      #          \      |
      #           6     7
      neighbors = fn
        1 -> [2, 6]
        2 -> [1]
        3 -> [4, 7]
        4 -> [3, 5]
        5 -> [4]
        6 -> [1]
        7 -> [3]
        _ -> []
      end

      components = ConnectedComponents.connected_components([1, 2, 3, 4, 5, 6, 7], neighbors)

      assert length(components) == 2

      component_lists =
        Enum.map(components, &MapSet.to_list/1) |> Enum.map(&Enum.sort/1) |> Enum.sort()

      assert [1, 2, 6] in component_lists
      assert [3, 4, 5, 7] in component_lists
    end
  end

  describe "components_count/2" do
    test "counts components correctly" do
      neighbors = fn
        1 -> [2]
        2 -> [1]
        3 -> [4]
        4 -> [3]
        5 -> []
        _ -> []
      end

      count = ConnectedComponents.components_count([1, 2, 3, 4, 5], neighbors)

      assert count == 3
    end

    test "counts single component" do
      neighbors = fn
        1 -> [2, 3]
        2 -> [1]
        3 -> [1]
        _ -> []
      end

      count = ConnectedComponents.components_count([1, 2, 3], neighbors)

      assert count == 1
    end

    test "counts fully disconnected graph" do
      neighbors = fn _ -> [] end

      count = ConnectedComponents.components_count([1, 2, 3, 4], neighbors)

      assert count == 4
    end

    test "counts empty graph" do
      neighbors = fn _ -> [] end

      count = ConnectedComponents.components_count([], neighbors)

      assert count == 0
    end
  end
end
