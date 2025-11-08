defmodule Pathfinding.MatrixTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Matrix

  describe "new/3" do
    test "creates a matrix with given dimensions and initial value" do
      matrix = Matrix.new(3, 3, 0)
      assert matrix.width == 3
      assert matrix.height == 3
      assert Matrix.get(matrix, {0, 0}) == 0
      assert Matrix.get(matrix, {2, 2}) == 0
    end
  end

  describe "from_rows/1" do
    test "creates a matrix from list of lists" do
      matrix = Matrix.from_rows([[1, 2, 3], [4, 5, 6]])
      assert matrix.width == 3
      assert matrix.height == 2
      assert Matrix.get(matrix, {0, 0}) == 1
      assert Matrix.get(matrix, {2, 0}) == 3
      assert Matrix.get(matrix, {0, 1}) == 4
      assert Matrix.get(matrix, {2, 1}) == 6
    end
  end

  describe "get/2 and put/3" do
    test "gets and sets values" do
      matrix = Matrix.new(3, 3, 0)
      assert Matrix.get(matrix, {1, 1}) == 0

      matrix = Matrix.put(matrix, {1, 1}, 42)
      assert Matrix.get(matrix, {1, 1}) == 42
    end

    test "returns nil for out of bounds get" do
      matrix = Matrix.new(3, 3, 0)
      assert Matrix.get(matrix, {10, 10}) == nil
    end

    test "ignores out of bounds put" do
      matrix = Matrix.new(3, 3, 0)
      matrix2 = Matrix.put(matrix, {10, 10}, 42)
      assert matrix == matrix2
    end
  end

  describe "inside?/2" do
    test "checks if position is inside matrix" do
      matrix = Matrix.new(3, 3, 0)
      assert Matrix.inside?(matrix, {0, 0})
      assert Matrix.inside?(matrix, {2, 2})
      refute Matrix.inside?(matrix, {3, 3})
      refute Matrix.inside?(matrix, {-1, 0})
    end
  end

  describe "neighbors/2" do
    test "returns 4 neighbors for interior position" do
      matrix = Matrix.new(5, 5, 0)
      neighbors = Matrix.neighbors(matrix, {2, 2})

      assert length(neighbors) == 4
      assert {1, 2} in neighbors
      assert {3, 2} in neighbors
      assert {2, 1} in neighbors
      assert {2, 3} in neighbors
    end

    test "returns 2 neighbors for corner position" do
      matrix = Matrix.new(5, 5, 0)
      neighbors = Matrix.neighbors(matrix, {0, 0})

      assert length(neighbors) == 2
      assert {1, 0} in neighbors
      assert {0, 1} in neighbors
    end
  end

  describe "neighbors_including_diagonals/2" do
    test "returns 8 neighbors for interior position" do
      matrix = Matrix.new(5, 5, 0)
      neighbors = Matrix.neighbors_including_diagonals(matrix, {2, 2})

      assert length(neighbors) == 8
    end

    test "returns 3 neighbors for corner position" do
      matrix = Matrix.new(5, 5, 0)
      neighbors = Matrix.neighbors_including_diagonals(matrix, {0, 0})

      assert length(neighbors) == 3
      assert {1, 0} in neighbors
      assert {0, 1} in neighbors
      assert {1, 1} in neighbors
    end
  end

  describe "positions/1" do
    test "returns all positions" do
      matrix = Matrix.new(2, 2, 0)
      positions = Matrix.positions(matrix)

      assert length(positions) == 4
      assert {0, 0} in positions
      assert {1, 0} in positions
      assert {0, 1} in positions
      assert {1, 1} in positions
    end
  end

  describe "to_rows/1" do
    test "converts matrix back to rows" do
      original = [[1, 2], [3, 4]]
      matrix = Matrix.from_rows(original)
      rows = Matrix.to_rows(matrix)

      assert rows == original
    end
  end

  describe "map/2" do
    test "maps over all values" do
      matrix = Matrix.new(2, 2, 1)
      matrix = Matrix.map(matrix, fn _pos, val -> val * 2 end)

      assert Matrix.get(matrix, {0, 0}) == 2
      assert Matrix.get(matrix, {1, 1}) == 2
    end

    test "has access to positions in map" do
      matrix = Matrix.new(2, 2, 0)
      matrix = Matrix.map(matrix, fn {x, y}, _val -> x + y end)

      assert Matrix.get(matrix, {0, 0}) == 0
      assert Matrix.get(matrix, {1, 0}) == 1
      assert Matrix.get(matrix, {0, 1}) == 1
      assert Matrix.get(matrix, {1, 1}) == 2
    end
  end
end
