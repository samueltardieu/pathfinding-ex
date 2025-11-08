defmodule Pathfinding.Matrix do
  @moduledoc """
  A 2D matrix data structure for storing arbitrary data.

  Provides convenient access to elements and neighbor operations.
  """

  defstruct data: %{}, width: 0, height: 0

  @type t :: %__MODULE__{
          data: map(),
          width: non_neg_integer(),
          height: non_neg_integer()
        }

  @doc """
  Create a new matrix with the given dimensions, filling with initial value.

  ## Example

      matrix = Pathfinding.Matrix.new(3, 3, 0)
      assert matrix.width == 3
      assert matrix.height == 3
  """
  def new(width, height, initial_value \\ nil)
      when is_integer(width) and is_integer(height) and width > 0 and height > 0 do
    data =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, initial_value}
      end

    %__MODULE__{data: data, width: width, height: height}
  end

  @doc """
  Create a matrix from a list of lists.

  ## Example

      matrix = Pathfinding.Matrix.from_rows([[1, 2, 3], [4, 5, 6]])
      assert Pathfinding.Matrix.get(matrix, {0, 0}) == 1
      assert Pathfinding.Matrix.get(matrix, {2, 1}) == 6
  """
  def from_rows(rows) when is_list(rows) and length(rows) > 0 do
    height = length(rows)
    width = length(hd(rows))

    data =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {value, x} -> {{x, y}, value} end)
      end)
      |> Map.new()

    %__MODULE__{data: data, width: width, height: height}
  end

  @doc """
  Get the value at a specific position.

  Returns `nil` if the position is out of bounds.

  ## Example

      matrix = Pathfinding.Matrix.new(3, 3, 0)
      assert Pathfinding.Matrix.get(matrix, {1, 1}) == 0
  """
  def get(%__MODULE__{data: data}, {_x, _y} = pos) do
    Map.get(data, pos)
  end

  @doc """
  Set the value at a specific position.

  Returns the updated matrix.

  ## Example

      matrix = Pathfinding.Matrix.new(3, 3, 0)
      matrix = Pathfinding.Matrix.put(matrix, {1, 1}, 42)
      assert Pathfinding.Matrix.get(matrix, {1, 1}) == 42
  """
  def put(%__MODULE__{data: data, width: w, height: h} = matrix, {x, y} = pos, value)
      when x >= 0 and x < w and y >= 0 and y < h do
    %{matrix | data: Map.put(data, pos, value)}
  end

  def put(matrix, _pos, _value), do: matrix

  @doc """
  Check if a position is inside the matrix bounds.
  """
  def inside?(%__MODULE__{width: w, height: h}, {x, y}) do
    x >= 0 and x < w and y >= 0 and y < h
  end

  @doc """
  Get the neighbors of a position (4-directional).

  ## Example

      matrix = Pathfinding.Matrix.new(3, 3, 0)
      neighbors = Pathfinding.Matrix.neighbors(matrix, {1, 1})
      assert length(neighbors) == 4
  """
  def neighbors(%__MODULE__{} = matrix, {x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(&inside?(matrix, &1))
  end

  @doc """
  Get the neighbors of a position including diagonals (8-directional).

  ## Example

      matrix = Pathfinding.Matrix.new(3, 3, 0)
      neighbors = Pathfinding.Matrix.neighbors_including_diagonals(matrix, {1, 1})
      assert length(neighbors) == 8
  """
  def neighbors_including_diagonals(%__MODULE__{} = matrix, {x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1},
      {x - 1, y - 1},
      {x - 1, y + 1},
      {x + 1, y - 1},
      {x + 1, y + 1}
    ]
    |> Enum.filter(&inside?(matrix, &1))
  end

  @doc """
  Get all positions in the matrix.
  """
  def positions(%__MODULE__{width: w, height: h}) do
    for x <- 0..(w - 1), y <- 0..(h - 1), do: {x, y}
  end

  @doc """
  Convert matrix to list of rows.

  ## Example

      matrix = Pathfinding.Matrix.from_rows([[1, 2], [3, 4]])
      rows = Pathfinding.Matrix.to_rows(matrix)
      assert rows == [[1, 2], [3, 4]]
  """
  def to_rows(%__MODULE__{width: w, height: h, data: data}) do
    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        Map.get(data, {x, y})
      end
    end
  end

  @doc """
  Map over all values in the matrix.

  ## Example

      matrix = Pathfinding.Matrix.new(2, 2, 1)
      matrix = Pathfinding.Matrix.map(matrix, fn _pos, val -> val * 2 end)
      assert Pathfinding.Matrix.get(matrix, {0, 0}) == 2
  """
  def map(%__MODULE__{data: data} = matrix, fun) when is_function(fun, 2) do
    new_data =
      data
      |> Enum.map(fn {pos, val} -> {pos, fun.(pos, val)} end)
      |> Map.new()

    %{matrix | data: new_data}
  end
end
