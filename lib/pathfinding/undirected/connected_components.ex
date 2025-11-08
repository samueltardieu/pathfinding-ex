defmodule Pathfinding.Undirected.ConnectedComponents do
  @moduledoc """
  Find connected components in an undirected graph.

  See [Wikipedia: Connected component](https://en.wikipedia.org/wiki/Connected_component_(graph_theory)).
  """

  @doc """
  Separate an undirected graph into disjoint connected components.

  - `vertices` is a list of all vertices in the graph
  - `neighbors` returns a list of neighbors for a given vertex

  Returns a list of components, where each component is a MapSet of vertices.

  ## Example

  ```elixir
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

  components = Pathfinding.Undirected.ConnectedComponents.connected_components([1, 2, 3, 4, 5, 6], neighbors)
  assert length(components) == 3
  ```
  """
  def connected_components(vertices, neighbors)
      when is_list(vertices) and is_function(neighbors, 1) do
    find_components(vertices, neighbors, MapSet.new(), [])
  end

  defp find_components([], _neighbors, _visited, components), do: Enum.reverse(components)

  defp find_components([vertex | rest], neighbors, visited, components) do
    if MapSet.member?(visited, vertex) do
      # Already visited this vertex
      find_components(rest, neighbors, visited, components)
    else
      # Start a new component from this vertex
      component = explore_component(vertex, neighbors, visited)
      new_visited = MapSet.union(visited, component)
      find_components(rest, neighbors, new_visited, [component | components])
    end
  end

  defp explore_component(start, neighbors, initial_visited) do
    explore_bfs([start], neighbors, initial_visited, MapSet.new([start]))
  end

  defp explore_bfs([], _neighbors, _visited, component), do: component

  defp explore_bfs([node | rest], neighbors, visited, component) do
    if MapSet.member?(visited, node) do
      explore_bfs(rest, neighbors, visited, component)
    else
      new_visited = MapSet.put(visited, node)
      new_component = MapSet.put(component, node)
      node_neighbors = neighbors.(node)

      # Add unvisited neighbors to queue
      new_queue = rest ++ Enum.reject(node_neighbors, &MapSet.member?(new_visited, &1))

      explore_bfs(new_queue, neighbors, new_visited, new_component)
    end
  end

  @doc """
  Count the number of connected components in an undirected graph.

  This is more efficient than `connected_components/2` if you only need the count.

  ## Example

  ```elixir
  neighbors = fn
    1 -> [2]
    2 -> [1]
    3 -> [4]
    4 -> [3]
    _ -> []
  end

  count = Pathfinding.Undirected.ConnectedComponents.components_count([1, 2, 3, 4], neighbors)
  assert count == 2
  ```
  """
  def components_count(vertices, neighbors)
      when is_list(vertices) and is_function(neighbors, 1) do
    count_components(vertices, neighbors, MapSet.new(), 0)
  end

  defp count_components([], _neighbors, _visited, count), do: count

  defp count_components([vertex | rest], neighbors, visited, count) do
    if MapSet.member?(visited, vertex) do
      count_components(rest, neighbors, visited, count)
    else
      component = explore_component(vertex, neighbors, visited)
      new_visited = MapSet.union(visited, component)
      count_components(rest, neighbors, new_visited, count + 1)
    end
  end
end
