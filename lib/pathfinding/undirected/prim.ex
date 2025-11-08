defmodule Pathfinding.Undirected.Prim do
  @moduledoc """
  Find minimum-spanning-tree using Prim's algorithm.

  See [Wikipedia: Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm).
  """

  @doc """
  Find a minimum-spanning-tree from a collection of weighted edges.

  Returns a list of edges `{node_a, node_b, weight}` forming a minimum-spanning-tree.

  ## Example

  ```elixir
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

  mst = Pathfinding.Undirected.Prim.prim(edges)
  total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
  assert total_weight == 39
  ```
  """
  def prim([]), do: []

  def prim([{start, _, _} | _] = edges) do
    # Build adjacency list for undirected graph
    adjacency = build_adjacency(edges)

    # Initialize with edges connected to the start node
    initial_queue = Map.get(adjacency, start, [])

    visited = MapSet.new([start])
    mst = []

    prim_loop(initial_queue, visited, mst, adjacency)
  end

  defp build_adjacency(edges) do
    Enum.reduce(edges, %{}, fn {a, b, cost}, acc ->
      acc
      |> Map.update(a, [{cost, a, b}], fn list -> [{cost, a, b} | list] end)
      |> Map.update(b, [{cost, b, a}], fn list -> [{cost, b, a} | list] end)
    end)
  end

  defp prim_loop([], _visited, mst, _adjacency) do
    Enum.reverse(mst)
  end

  defp prim_loop(queue, visited, mst, adjacency) do
    # Sort queue by cost (min heap behavior)
    sorted_queue = Enum.sort_by(queue, fn {cost, _, _} -> cost end)

    case find_next_edge(sorted_queue, visited) do
      nil ->
        # No more reachable nodes
        Enum.reverse(mst)

      {{cost, from, to}, remaining_queue} ->
        # Add this edge to MST
        new_mst = [{from, to, cost} | mst]
        new_visited = MapSet.put(visited, to)

        # Add new edges from the newly visited node
        new_edges =
          adjacency
          |> Map.get(to, [])
          |> Enum.reject(fn {_cost, _from, node} -> MapSet.member?(new_visited, node) end)

        new_queue = remaining_queue ++ new_edges
        prim_loop(new_queue, new_visited, new_mst, adjacency)
    end
  end

  defp find_next_edge([], _visited), do: nil

  defp find_next_edge([{_cost, _from, to} = edge | rest], visited) do
    if MapSet.member?(visited, to) do
      # This node is already visited, skip it
      find_next_edge(rest, visited)
    else
      # Found an edge to an unvisited node
      {edge, rest}
    end
  end
end
