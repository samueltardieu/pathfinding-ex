defmodule Pathfinding.Grid do
  @moduledoc """
  A rectangular grid for pathfinding.

  Provides a simple way to represent a 2D grid with obstacles.
  Coordinates are `{x, y}` where `{0, 0}` is the top-left corner.
  """

  defstruct width: 0, height: 0, obstacles: MapSet.new(), diagonal: false

  @type t :: %__MODULE__{
          width: non_neg_integer(),
          height: non_neg_integer(),
          obstacles: MapSet.t({non_neg_integer(), non_neg_integer()}),
          diagonal: boolean()
        }

  @doc """
  Create a new empty grid with the given dimensions.

  ## Example

      grid = Pathfinding.Grid.new(10, 10)
      assert grid.width == 10
      assert grid.height == 10
  """
  def new(width, height) when width > 0 and height > 0 do
    %__MODULE__{width: width, height: height, obstacles: MapSet.new(), diagonal: false}
  end

  @doc """
  Enable diagonal movement in the grid.
  """
  def enable_diagonal(%__MODULE__{} = grid) do
    %{grid | diagonal: true}
  end

  @doc """
  Disable diagonal movement in the grid.
  """
  def disable_diagonal(%__MODULE__{} = grid) do
    %{grid | diagonal: false}
  end

  @doc """
  Add an obstacle at the given position.

  Returns the updated grid.

  ## Example

      grid = Pathfinding.Grid.new(10, 10)
      grid = Pathfinding.Grid.add_obstacle(grid, {5, 5})
  """
  def add_obstacle(%__MODULE__{} = grid, {x, y} = pos)
      when x >= 0 and x < grid.width and y >= 0 and y < grid.height do
    %{grid | obstacles: MapSet.put(grid.obstacles, pos)}
  end

  def add_obstacle(grid, _pos), do: grid

  @doc """
  Remove an obstacle at the given position.

  Returns the updated grid.
  """
  def remove_obstacle(%__MODULE__{} = grid, pos) do
    %{grid | obstacles: MapSet.delete(grid.obstacles, pos)}
  end

  @doc """
  Check if a position has an obstacle.
  """
  def has_obstacle?(%__MODULE__{obstacles: obstacles}, pos) do
    MapSet.member?(obstacles, pos)
  end

  @doc """
  Check if a position is inside the grid bounds.
  """
  def inside?(%__MODULE__{width: w, height: h}, {x, y}) do
    x >= 0 and x < w and y >= 0 and y < h
  end

  @doc """
  Get the neighbors of a position.

  Returns a list of valid neighbor positions that are inside the grid and don't have obstacles.

  ## Example

      grid = Pathfinding.Grid.new(10, 10)
      neighbors = Pathfinding.Grid.neighbors(grid, {5, 5})
      # Returns up to 4 neighbors (or 8 if diagonal is enabled)
  """
  def neighbors(%__MODULE__{} = grid, {x, y}) do
    potential_neighbors =
      if grid.diagonal do
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
      else
        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      end

    potential_neighbors
    |> Enum.filter(fn pos ->
      inside?(grid, pos) and not has_obstacle?(grid, pos)
    end)
  end

  @doc """
  Get the neighbors of a position with their costs.

  All moves have a cost of 1. Diagonal moves cost sqrt(2) ≈ 1.414 if you want more precision,
  but for simplicity we use 1 for all moves.

  ## Example

      grid = Pathfinding.Grid.new(10, 10)
      neighbors = Pathfinding.Grid.neighbors_with_cost(grid, {5, 5})
      # Returns [{{4, 5}, 1}, {{6, 5}, 1}, ...]
  """
  def neighbors_with_cost(%__MODULE__{} = grid, pos) do
    neighbors(grid, pos) |> Enum.map(fn neighbor -> {neighbor, 1} end)
  end

  @doc """
  Add borders (obstacles) around the entire grid.

  ## Example

      grid = Pathfinding.Grid.new(10, 10)
      grid = Pathfinding.Grid.add_borders(grid)
  """
  def add_borders(%__MODULE__{width: w, height: h} = grid) do
    border_positions =
      for(x <- 0..(w - 1), do: {x, 0}) ++
        for(x <- 0..(w - 1), do: {x, h - 1}) ++
        for(y <- 1..(h - 2), do: {0, y}) ++
        for y <- 1..(h - 2), do: {w - 1, y}

    Enum.reduce(border_positions, grid, fn pos, acc -> add_obstacle(acc, pos) end)
  end

  @doc """
  Create a grid from a list of obstacle positions.

  The grid size is determined by the maximum x and y coordinates + 1.

  ## Example

      obstacles = [{1, 1}, {2, 2}, {3, 3}]
      grid = Pathfinding.Grid.from_obstacles(obstacles, 5, 5)
  """
  def from_obstacles(obstacles, width, height) do
    grid = new(width, height)
    Enum.reduce(obstacles, grid, fn pos, acc -> add_obstacle(acc, pos) end)
  end
end
