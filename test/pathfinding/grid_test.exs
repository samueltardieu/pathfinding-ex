defmodule Pathfinding.GridTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Grid

  describe "new/2" do
    test "creates a grid with given dimensions" do
      grid = Grid.new(10, 10)
      assert grid.width == 10
      assert grid.height == 10
      assert MapSet.size(grid.obstacles) == 0
      assert grid.diagonal == false
    end
  end

  describe "add_obstacle/2 and has_obstacle?/2" do
    test "adds and checks obstacles" do
      grid = Grid.new(10, 10)
      refute Grid.has_obstacle?(grid, {5, 5})

      grid = Grid.add_obstacle(grid, {5, 5})
      assert Grid.has_obstacle?(grid, {5, 5})
    end

    test "ignores obstacles outside grid" do
      grid = Grid.new(10, 10)
      grid = Grid.add_obstacle(grid, {15, 15})
      refute Grid.has_obstacle?(grid, {15, 15})
    end
  end

  describe "remove_obstacle/2" do
    test "removes obstacles" do
      grid = Grid.new(10, 10)
      grid = Grid.add_obstacle(grid, {5, 5})
      assert Grid.has_obstacle?(grid, {5, 5})

      grid = Grid.remove_obstacle(grid, {5, 5})
      refute Grid.has_obstacle?(grid, {5, 5})
    end
  end

  describe "inside?/2" do
    test "checks if position is inside grid" do
      grid = Grid.new(10, 10)
      assert Grid.inside?(grid, {0, 0})
      assert Grid.inside?(grid, {9, 9})
      refute Grid.inside?(grid, {10, 10})
      refute Grid.inside?(grid, {-1, 5})
    end
  end

  describe "neighbors/2" do
    test "returns 4 neighbors in non-diagonal mode" do
      grid = Grid.new(10, 10)
      neighbors = Grid.neighbors(grid, {5, 5})

      assert length(neighbors) == 4
      assert {4, 5} in neighbors
      assert {6, 5} in neighbors
      assert {5, 4} in neighbors
      assert {5, 6} in neighbors
    end

    test "returns 8 neighbors in diagonal mode" do
      grid = Grid.new(10, 10) |> Grid.enable_diagonal()
      neighbors = Grid.neighbors(grid, {5, 5})

      assert length(neighbors) == 8
    end

    test "excludes neighbors with obstacles" do
      grid = Grid.new(10, 10)
      grid = Grid.add_obstacle(grid, {6, 5})
      neighbors = Grid.neighbors(grid, {5, 5})

      assert length(neighbors) == 3
      refute {6, 5} in neighbors
    end

    test "handles corner positions" do
      grid = Grid.new(10, 10)
      neighbors = Grid.neighbors(grid, {0, 0})

      assert length(neighbors) == 2
      assert {1, 0} in neighbors
      assert {0, 1} in neighbors
    end
  end

  describe "neighbors_with_cost/2" do
    test "returns neighbors with cost 1" do
      grid = Grid.new(10, 10)
      neighbors = Grid.neighbors_with_cost(grid, {5, 5})

      assert length(neighbors) == 4
      assert Enum.all?(neighbors, fn {_pos, cost} -> cost == 1 end)
    end
  end

  describe "add_borders/1" do
    test "adds obstacles around the entire grid" do
      grid = Grid.new(5, 5) |> Grid.add_borders()

      # Check all border positions
      assert Grid.has_obstacle?(grid, {0, 0})
      assert Grid.has_obstacle?(grid, {4, 0})
      assert Grid.has_obstacle?(grid, {0, 4})
      assert Grid.has_obstacle?(grid, {4, 4})

      # Check center is not obstacle
      refute Grid.has_obstacle?(grid, {2, 2})
    end
  end

  describe "from_obstacles/3" do
    test "creates grid from obstacle list" do
      obstacles = [{1, 1}, {2, 2}, {3, 3}]
      grid = Grid.from_obstacles(obstacles, 5, 5)

      assert grid.width == 5
      assert grid.height == 5
      assert Grid.has_obstacle?(grid, {1, 1})
      assert Grid.has_obstacle?(grid, {2, 2})
      assert Grid.has_obstacle?(grid, {3, 3})
      refute Grid.has_obstacle?(grid, {0, 0})
    end
  end

  describe "enable_diagonal/1 and disable_diagonal/1" do
    test "toggles diagonal mode" do
      grid = Grid.new(10, 10)
      refute grid.diagonal

      grid = Grid.enable_diagonal(grid)
      assert grid.diagonal

      grid = Grid.disable_diagonal(grid)
      refute grid.diagonal
    end
  end
end
