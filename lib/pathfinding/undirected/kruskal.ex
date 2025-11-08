defmodule Pathfinding.Undirected.Kruskal do
  @moduledoc """
  Find minimum-spanning-tree using Kruskal's algorithm.

  See [Wikipedia: Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal's_algorithm).
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

  mst = Pathfinding.Undirected.Kruskal.kruskal(edges)
  total_weight = Enum.reduce(mst, 0, fn {_, _, w}, acc -> acc + w end)
  assert total_weight == 39
  ```
  """
  def kruskal(edges) when is_list(edges) do
    # Extract all unique nodes
    nodes =
      Enum.reduce(edges, MapSet.new(), fn {a, b, _w}, acc ->
        acc |> MapSet.put(a) |> MapSet.put(b)
      end)
      |> MapSet.to_list()

    # Create node to index mapping
    node_to_index = nodes |> Enum.with_index() |> Map.new()
    index_to_node = nodes |> Enum.with_index() |> Enum.map(fn {n, i} -> {i, n} end) |> Map.new()

    # Convert edges to indexed form
    indexed_edges =
      Enum.map(edges, fn {a, b, w} ->
        {Map.fetch!(node_to_index, a), Map.fetch!(node_to_index, b), w}
      end)

    # Sort edges by weight
    sorted_edges = Enum.sort_by(indexed_edges, fn {_, _, w} -> w end)

    # Initialize Union-Find
    parents = Enum.into(0..(length(nodes) - 1), %{}, fn i -> {i, i} end)
    ranks = Enum.into(0..(length(nodes) - 1), %{}, fn i -> {i, 1} end)

    # Process edges
    {mst_edges, _, _} =
      Enum.reduce(sorted_edges, {[], parents, ranks}, fn {ia, ib, w}, {mst, p, r} ->
        ra = find(p, ia)
        rb = find(p, ib)

        if ra == rb do
          # Same component, would create cycle
          {mst, p, r}
        else
          # Different components, add edge and union
          {new_p, new_r} = union(p, r, ra, rb)
          {[{ia, ib, w} | mst], new_p, new_r}
        end
      end)

    # Convert back to original nodes
    Enum.reverse(mst_edges)
    |> Enum.map(fn {ia, ib, w} ->
      {Map.fetch!(index_to_node, ia), Map.fetch!(index_to_node, ib), w}
    end)
  end

  # Find with path halving
  defp find(parents, node) do
    parent = Map.fetch!(parents, node)

    if parent == node do
      node
    else
      # Path halving: make node point to grandparent
      grandparent = Map.fetch!(parents, parent)
      find(Map.put(parents, node, grandparent), parent)
    end
  end

  # Union by rank
  defp union(parents, ranks, a, b) do
    rank_a = Map.fetch!(ranks, a)
    rank_b = Map.fetch!(ranks, b)

    cond do
      rank_a < rank_b ->
        {Map.put(parents, a, b), ranks}

      rank_a > rank_b ->
        {Map.put(parents, b, a), ranks}

      true ->
        # Equal ranks, choose a as parent and increment its rank
        {Map.put(parents, b, a), Map.put(ranks, a, rank_a + 1)}
    end
  end
end
