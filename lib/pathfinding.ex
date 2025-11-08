defmodule Pathfinding do
  @moduledoc """
  # Pathfinding

  This library implements several pathfinding, flow, and graph algorithms in Elixir.

  ## Algorithms

  The algorithms are generic over their arguments.

  ### Directed graphs

  - `Pathfinding.Directed.BFS.bfs/3`: find the shortest path using breadth-first search
  - `Pathfinding.Directed.BFS.bfs_bidirectional/4`: bidirectional search from start and goal
  - `Pathfinding.Directed.BFS.bfs_reach/2`: visit all reachable nodes in BFS order
  - `Pathfinding.Directed.DFS.dfs/3`: explore depth-first, finding a path
  - `Pathfinding.Directed.DFS.dfs_reach/2`: visit all reachable nodes in DFS order
  - `Pathfinding.Directed.Dijkstra.dijkstra/3`: find shortest path in weighted graphs
  - `Pathfinding.Directed.Dijkstra.dijkstra_all/2`: find all reachable nodes with costs
  - `Pathfinding.Directed.Astar.astar/4`: heuristic-guided shortest path (A* algorithm)

  ### Undirected graphs

  - `Pathfinding.Undirected.ConnectedComponents.connected_components/2`: find all connected components
  - `Pathfinding.Undirected.ConnectedComponents.components_count/2`: count connected components

  ## Working with Graphs

  This library does not provide a fixed graph data structure. Instead, the algorithms accept
  a **successor function** that defines how to navigate from one node to its neighbors.

  ## Example

  We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only knight moves.

  ```elixir
  defmodule Knight do
    def successors({x, y}) do
      [
        {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
        {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
      ]
    end
  end

  goal = {4, 6}
  result = Pathfinding.Directed.BFS.bfs({1, 1}, &Knight.successors/1, fn p -> p == goal end)
  {:ok, path} = result
  assert length(path) == 5
  ```

  For weighted graphs, use Dijkstra or A*:

  ```elixir
  # Dijkstra for weighted graphs
  successors_with_cost = fn {x, y} ->
    Knight.successors({x, y}) |> Enum.map(fn pos -> {pos, 1} end)
  end

  result = Pathfinding.Directed.Dijkstra.dijkstra({1, 1}, successors_with_cost, fn p -> p == goal end)
  {:ok, {path, cost}} = result

  # A* with heuristic for better performance
  heuristic = fn {x, y} ->
    abs(elem(goal, 0) - x) + abs(elem(goal, 1) - y)
  end

  result = Pathfinding.Directed.Astar.astar({1, 1}, successors_with_cost, heuristic, fn p -> p == goal end)
  {:ok, {path, cost}} = result
  ```

  ## License

  This code is released under a dual Apache 2.0 / MIT free software license.
  """
end
