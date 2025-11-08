defmodule Pathfinding.Directed.Dijkstra do
  @moduledoc """
  Compute shortest paths using Dijkstra's algorithm for weighted graphs.

  See [Wikipedia: Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra's_algorithm).
  """

  @doc """
  Compute a shortest path using Dijkstra's algorithm.

  The shortest path starting from `start` up to a node for which `success` returns `true` is
  computed and returned along with its total cost in `{:ok, {path, cost}}`. If no path can be
  found, `:error` is returned instead.

  - `start` is the starting node.
  - `successors` returns a list of `{successor, cost}` tuples for a given node.
    The cost must be non-negative.
  - `success` checks whether the goal has been reached.

  A node will never be included twice in the path.

  The returned path comprises both the start and end node.

  ## Example

  We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only
  knight moves, with each move having a cost of 1.

  ```elixir
  successors = fn {x, y} ->
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
    |> Enum.map(fn pos -> {pos, 1} end)
  end

  result = Pathfinding.Directed.Dijkstra.dijkstra({1, 1}, successors, fn p -> p == {4, 6} end)
  {:ok, {path, cost}} = result
  assert cost == 4
  ```
  """
  def dijkstra(start, successors, success)
      when is_function(successors, 1) and is_function(success, 1) do
    if success.(start) do
      {:ok, {[start], 0}}
    else
      dijkstra_core(start, successors, success)
    end
  end

  defp dijkstra_core(start, successors, success) do
    # Priority queue: list of {priority (cost), node}
    # visited: MapSet of visited nodes
    # costs: Map of node -> best cost found so far
    # parents: Map of node -> parent node
    queue = [{0, start}]
    costs = %{start => 0}
    parents = %{}
    visited = MapSet.new()

    dijkstra_loop(queue, costs, parents, visited, successors, success)
  end

  defp dijkstra_loop([], _costs, _parents, _visited, _successors, _success), do: :error

  defp dijkstra_loop(queue, costs, parents, visited, successors, success) do
    # Get node with minimum cost
    {current_cost, current_node, rest_queue} = extract_min(queue)

    if MapSet.member?(visited, current_node) do
      # Already processed this node
      dijkstra_loop(rest_queue, costs, parents, visited, successors, success)
    else
      # Mark as visited
      new_visited = MapSet.put(visited, current_node)

      if success.(current_node) do
        # Found goal
        path = build_path_from_parents(parents, current_node)
        {:ok, {path, current_cost}}
      else
        # Process neighbors
        neighbors = successors.(current_node)

        {new_queue, new_costs, new_parents} =
          Enum.reduce(neighbors, {rest_queue, costs, parents}, fn {neighbor, edge_cost},
                                                                  {q_acc, c_acc, p_acc} ->
            new_cost = current_cost + edge_cost

            case Map.get(c_acc, neighbor) do
              nil ->
                # First time seeing this node
                {
                  insert_queue(q_acc, {new_cost, neighbor}),
                  Map.put(c_acc, neighbor, new_cost),
                  Map.put(p_acc, neighbor, current_node)
                }

              old_cost when new_cost < old_cost ->
                # Found a better path
                {
                  insert_queue(q_acc, {new_cost, neighbor}),
                  Map.put(c_acc, neighbor, new_cost),
                  Map.put(p_acc, neighbor, current_node)
                }

              _ ->
                # Existing path is better or equal
                {q_acc, c_acc, p_acc}
            end
          end)

        dijkstra_loop(new_queue, new_costs, new_parents, new_visited, successors, success)
      end
    end
  end

  # Extract minimum priority item from queue
  defp extract_min([{cost, node} | rest]), do: {cost, node, rest}

  # Insert into priority queue (maintain sorted order by cost)
  defp insert_queue(queue, {cost, _node} = item) do
    insert_queue_sorted(queue, item, cost, [])
  end

  defp insert_queue_sorted([], item, _cost, acc) do
    Enum.reverse([item | acc])
  end

  defp insert_queue_sorted([{qcost, _} = head | tail], item, cost, acc) when cost <= qcost do
    Enum.reverse(acc, [item, head | tail])
  end

  defp insert_queue_sorted([head | tail], item, cost, acc) do
    insert_queue_sorted(tail, item, cost, [head | acc])
  end

  defp build_path_from_parents(parents, node, acc \\ []) do
    case Map.get(parents, node) do
      nil ->
        [node | acc]

      parent ->
        build_path_from_parents(parents, parent, [node | acc])
    end
  end

  @doc """
  Determine all reachable nodes from a starting point as well as the minimum cost to reach them.

  Returns a map where every reachable node (not including `start`) is associated with a
  `{parent_node, cost}` tuple representing the optimal parent and the total cost from start.

  ## Example

  ```elixir
  successors = fn n ->
    if n <= 4 do
      [{n * 2, 10}, {n * 2 + 1, 10}]
    else
      []
    end
  end

  reachables = Pathfinding.Directed.Dijkstra.dijkstra_all(1, successors)
  assert reachables[2] == {1, 10}  # 1 -> 2
  assert reachables[3] == {1, 10}  # 1 -> 3
  assert reachables[4] == {2, 20}  # 1 -> 2 -> 4
  ```
  """
  def dijkstra_all(start, successors) when is_function(successors, 1) do
    queue = [{0, start}]
    costs = %{start => 0}
    parents = %{}
    visited = MapSet.new()

    dijkstra_all_loop(queue, costs, parents, visited, successors)
  end

  defp dijkstra_all_loop([], _costs, parents, _visited, _successors) do
    # Convert parents map to return format (node -> {parent, cost})
    parents
  end

  defp dijkstra_all_loop(queue, costs, parents, visited, successors) do
    {current_cost, current_node, rest_queue} = extract_min(queue)

    if MapSet.member?(visited, current_node) do
      dijkstra_all_loop(rest_queue, costs, parents, visited, successors)
    else
      new_visited = MapSet.put(visited, current_node)
      neighbors = successors.(current_node)

      {new_queue, new_costs, new_parents} =
        Enum.reduce(neighbors, {rest_queue, costs, parents}, fn {neighbor, edge_cost},
                                                                {q_acc, c_acc, p_acc} ->
          new_cost = current_cost + edge_cost

          case Map.get(c_acc, neighbor) do
            nil ->
              {
                insert_queue(q_acc, {new_cost, neighbor}),
                Map.put(c_acc, neighbor, new_cost),
                Map.put(p_acc, neighbor, {current_node, new_cost})
              }

            old_cost when new_cost < old_cost ->
              {
                insert_queue(q_acc, {new_cost, neighbor}),
                Map.put(c_acc, neighbor, new_cost),
                Map.put(p_acc, neighbor, {current_node, new_cost})
              }

            _ ->
              {q_acc, c_acc, p_acc}
          end
        end)

      dijkstra_all_loop(new_queue, new_costs, new_parents, new_visited, successors)
    end
  end
end
