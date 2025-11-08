defmodule Pathfinding do
  @moduledoc """
  # Pathfinding

  This library implements several pathfinding, flow, and graph algorithms in Elixir.

  ## Algorithms

  The algorithms are generic over their arguments.

  ### Directed graphs

  - `Pathfinding.Directed.BFS.bfs/3`: find the shortest path using breadth-first search
  - `Pathfinding.Directed.BFS.bfs_bidirectional/4`: simultaneously explore paths forwards from the start and backwards from the goal
  - `Pathfinding.Directed.BFS.bfs_reach/2`: visit all reachable nodes in BFS order
  - `Pathfinding.Directed.DFS.dfs/3`: explore a graph by going as far as possible, then backtrack
  - `Pathfinding.Directed.DFS.dfs_reach/2`: visit all reachable nodes in DFS order
  - `Pathfinding.Directed.Astar.astar/4`: find the shortest path using A* with a heuristic
  - `Pathfinding.Directed.Dijkstra.dijkstra/3`: find the shortest path in a weighted graph

  ### Undirected graphs

  - `Pathfinding.Undirected.ConnectedComponents.connected_components/2`: find disjoint connected sets of vertices

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

  ## License

  This code is released under a dual Apache 2.0 / MIT free software license.
  """
end
