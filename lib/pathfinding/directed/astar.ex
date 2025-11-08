defmodule Pathfinding.Directed.Astar do
  @moduledoc """
  Compute shortest paths using the A* search algorithm with a heuristic.

  See [Wikipedia: A* search algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm).
  """

  @doc """
  Compute a shortest path using the A* search algorithm.

  The shortest path starting from `start` up to a node for which `success` returns `true` is
  computed and returned along with its total cost in `{:ok, {path, cost}}`. If no path can be
  found, `:error` is returned instead.

  - `start` is the starting node.
  - `successors` returns a list of `{successor, cost}` tuples for a given node.
  - `heuristic` returns an estimate of the cost from a node to the goal. This estimate must not
    be greater than the real cost, or a wrong shortest path may be returned.
  - `success` checks whether the goal has been reached.

  A node will never be included twice in the path.

  The returned path comprises both the start and end node.

  ## Example

  We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only
  knight moves, using Manhattan distance divided by 3 as a heuristic.

  ```elixir
  successors = fn {x, y} ->
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
    |> Enum.map(fn pos -> {pos, 1} end)
  end

  goal = {4, 6}
  heuristic = fn {x, y} ->
    div(abs(goal |> elem(0) - x) + abs(goal |> elem(1) - y), 3)
  end

  result = Pathfinding.Directed.Astar.astar({1, 1}, successors, heuristic, fn p -> p == goal end)
  {:ok, {_path, cost}} = result
  assert cost == 4
  ```
  """
  def astar(start, successors, heuristic, success)
      when is_function(successors, 1) and is_function(heuristic, 1) and is_function(success, 1) do
    if success.(start) do
      {:ok, {[start], 0}}
    else
      astar_core(start, successors, heuristic, success)
    end
  end

  defp astar_core(start, successors, heuristic, success) do
    # Priority queue: list of {estimated_total_cost, actual_cost, node}
    # The estimated_total_cost = actual_cost + heuristic(node)
    h_start = heuristic.(start)
    queue = [{h_start, 0, start}]
    costs = %{start => 0}
    parents = %{}
    visited = MapSet.new()

    astar_loop(queue, costs, parents, visited, successors, heuristic, success)
  end

  defp astar_loop([], _costs, _parents, _visited, _successors, _heuristic, _success), do: :error

  defp astar_loop(queue, costs, parents, visited, successors, heuristic, success) do
    # Get node with minimum estimated cost
    {_estimated_cost, current_cost, current_node, rest_queue} = extract_min(queue)

    if MapSet.member?(visited, current_node) do
      # Already processed this node
      astar_loop(rest_queue, costs, parents, visited, successors, heuristic, success)
    else
      # Check if we already found a better path to this node
      case Map.get(costs, current_node) do
        ^current_cost ->
          # This is the best known path to this node
          process_node(
            current_node,
            current_cost,
            rest_queue,
            costs,
            parents,
            visited,
            successors,
            heuristic,
            success
          )

        better_cost when better_cost < current_cost ->
          # We already found a better path, skip this one
          astar_loop(rest_queue, costs, parents, visited, successors, heuristic, success)

        _ ->
          # This shouldn't happen, but handle it gracefully
          process_node(
            current_node,
            current_cost,
            rest_queue,
            costs,
            parents,
            visited,
            successors,
            heuristic,
            success
          )
      end
    end
  end

  defp process_node(
         current_node,
         current_cost,
         rest_queue,
         costs,
         parents,
         visited,
         successors,
         heuristic,
         success
       ) do
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
              h = heuristic.(neighbor)
              estimated_cost = new_cost + h

              {
                insert_queue(q_acc, {estimated_cost, new_cost, neighbor}),
                Map.put(c_acc, neighbor, new_cost),
                Map.put(p_acc, neighbor, current_node)
              }

            old_cost when new_cost < old_cost ->
              # Found a better path
              h = heuristic.(neighbor)
              estimated_cost = new_cost + h

              {
                insert_queue(q_acc, {estimated_cost, new_cost, neighbor}),
                Map.put(c_acc, neighbor, new_cost),
                Map.put(p_acc, neighbor, current_node)
              }

            _ ->
              # Existing path is better or equal
              {q_acc, c_acc, p_acc}
          end
        end)

      astar_loop(new_queue, new_costs, new_parents, new_visited, successors, heuristic, success)
    end
  end

  # Extract minimum priority item from queue
  defp extract_min([{est_cost, cost, node} | rest]), do: {est_cost, cost, node, rest}

  # Insert into priority queue (maintain sorted order by estimated cost)
  defp insert_queue(queue, {est_cost, _cost, _node} = item) do
    insert_queue_sorted(queue, item, est_cost, [])
  end

  defp insert_queue_sorted([], item, _est_cost, acc) do
    Enum.reverse([item | acc])
  end

  defp insert_queue_sorted([{q_est_cost, _, _} = head | tail], item, est_cost, acc)
       when est_cost <= q_est_cost do
    Enum.reverse(acc, [item, head | tail])
  end

  defp insert_queue_sorted([head | tail], item, est_cost, acc) do
    insert_queue_sorted(tail, item, est_cost, [head | acc])
  end

  defp build_path_from_parents(parents, node, acc \\ []) do
    case Map.get(parents, node) do
      nil ->
        [node | acc]

      parent ->
        build_path_from_parents(parents, parent, [node | acc])
    end
  end
end
