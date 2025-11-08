defmodule Pathfinding.Directed.BFS do
  @moduledoc """
  Compute shortest paths using the breadth-first search algorithm.

  See [Wikipedia: Breadth-first search](https://en.wikipedia.org/wiki/Breadth-first_search).
  """

  @doc """
  Compute a shortest path using the breadth-first search algorithm.

  The shortest path starting from `start` up to a node for which `success` returns `true` is
  computed and returned in an `{:ok, path}`. If no path can be found, `:error`
  is returned instead.

  - `start` is the starting node.
  - `successors` returns a list of successors for a given node.
  - `success` checks whether the goal has been reached. It is not a node as some problems require
    a dynamic solution instead of a fixed node.

  A node will never be included twice in the path.

  The returned path comprises both the start and end node.

  ## Example

  We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only knight moves.

  ```elixir
  successors = fn {x, y} ->
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
  end

  goal = {4, 6}
  result = Pathfinding.Directed.BFS.bfs({1, 1}, successors, fn p -> p == goal end)
  {:ok, path} = result
  assert length(path) == 5
  ```
  """
  def bfs(start, successors, success)
      when is_function(successors, 1) and is_function(success, 1) do
    if success.(start) do
      {:ok, [start]}
    else
      bfs_core(start, successors, success)
    end
  end

  defp bfs_core(start, successors, success) do
    # parents maps node -> parent_node
    parents = %{start => nil}
    queue = :queue.from_list([start])

    bfs_loop(queue, parents, successors, success)
  end

  defp bfs_loop(queue, parents, successors, success) do
    case :queue.out(queue) do
      {:empty, _} ->
        :error

      {{:value, node}, rest_queue} ->
        # Get successors for current node
        node_successors = successors.(node)

        # Check each successor
        case Enum.find(node_successors, fn succ -> success.(succ) end) do
          nil ->
            # No goal found, add new successors to queue and parents
            {new_queue, new_parents} =
              Enum.reduce(node_successors, {rest_queue, parents}, fn successor, {q_acc, p_acc} ->
                if Map.has_key?(p_acc, successor) do
                  {q_acc, p_acc}
                else
                  {:queue.in(successor, q_acc), Map.put(p_acc, successor, node)}
                end
              end)

            bfs_loop(new_queue, new_parents, successors, success)

          goal_node ->
            # Found goal, build path from start to current node, then add goal
            path = build_path_from_parents(parents, node)
            {:ok, path ++ [goal_node]}
        end
    end
  end

  @doc """
  Return one of the shortest loops from start to start if it exists, `:error` otherwise.

  - `start` is the starting node.
  - `successors` returns a list of successors for a given node.

  Except the start node which will be included both at the beginning and the end of
  the path, a node will never be included twice in the path.
  """
  def bfs_loop(start, successors) when is_function(successors, 1) do
    # Find a loop back to start, but don't check start itself as success initially
    parents = %{start => nil}
    queue = :queue.from_list([start])

    bfs_loop_core(queue, parents, successors, start)
  end

  defp bfs_loop_core(queue, parents, successors, start_node) do
    case :queue.out(queue) do
      {:empty, _} ->
        :error

      {{:value, node}, rest_queue} ->
        # Get successors for current node
        node_successors = successors.(node)

        # Check if any successor is the start node
        case Enum.find(node_successors, fn succ -> succ == start_node end) do
          nil ->
            # No loop found yet, add new successors to queue and parents
            {new_queue, new_parents} =
              Enum.reduce(node_successors, {rest_queue, parents}, fn successor, {q_acc, p_acc} ->
                if Map.has_key?(p_acc, successor) do
                  {q_acc, p_acc}
                else
                  {:queue.in(successor, q_acc), Map.put(p_acc, successor, node)}
                end
              end)

            bfs_loop_core(new_queue, new_parents, successors, start_node)

          _loop_node ->
            # Found loop back to start
            path = build_path_from_parents(parents, node)
            {:ok, path ++ [start_node]}
        end
    end
  end

  @doc """
  Compute a shortest path using breadth-first search with bidirectional search.

  Bidirectional search runs two simultaneous searches: one forward from the start,
  and one backward from the end, stopping when the two meet. In many cases this gives
  a faster result than searching only in a single direction.

  The shortest path starting from `start` to `goal` is computed and returned in an
  `{:ok, path}`. If no path can be found, `:error` is returned instead.

  - `start` is the starting node.
  - `goal` is the goal node.
  - `successors_fn` returns a list of successors for a given node.
  - `predecessors_fn` returns a list of predecessors for a given node. For an undirected graph
    this will be the same as `successors_fn`, however for a directed graph this will be different.

  A node will never be included twice in the path.

  The returned path comprises both the start and goal node.

  ## Example

  ```elixir
  successors = fn {x, y} ->
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
  end

  result = Pathfinding.Directed.BFS.bfs_bidirectional({1, 1}, {4, 6}, successors, successors)
  {:ok, path} = result
  assert length(path) == 5
  ```
  """
  def bfs_bidirectional(start, goal, successors_fn, predecessors_fn)
      when is_function(successors_fn, 1) and is_function(predecessors_fn, 1) do
    # Initialize forward and backward search
    forward = %{start => nil}
    backward = %{goal => nil}

    forward_queue = :queue.from_list([start])
    backward_queue = :queue.from_list([goal])

    bidirectional_search(
      forward_queue,
      backward_queue,
      forward,
      backward,
      successors_fn,
      predecessors_fn
    )
  end

  defp bidirectional_search(
         forward_queue,
         backward_queue,
         forward,
         backward,
         successors_fn,
         predecessors_fn
       ) do
    # Check if either queue is empty
    if :queue.is_empty(forward_queue) and :queue.is_empty(backward_queue) do
      :error
    else
      # Process forward direction if queue is not empty
      {forward_queue, forward, meeting_node} =
        if not :queue.is_empty(forward_queue) do
          process_direction(forward_queue, forward, backward, successors_fn)
        else
          {forward_queue, forward, nil}
        end

      if meeting_node do
        # Build complete path
        path = build_bidirectional_path(forward, backward, meeting_node)
        {:ok, path}
      else
        # Process backward direction if queue is not empty
        {backward_queue, backward, meeting_node} =
          if not :queue.is_empty(backward_queue) do
            process_direction(backward_queue, backward, forward, predecessors_fn)
          else
            {backward_queue, backward, nil}
          end

        if meeting_node do
          # Build complete path
          path = build_bidirectional_path(forward, backward, meeting_node)
          {:ok, path}
        else
          # Continue search
          bidirectional_search(
            forward_queue,
            backward_queue,
            forward,
            backward,
            successors_fn,
            predecessors_fn
          )
        end
      end
    end
  end

  defp process_direction(queue, visited, other_visited, next_fn) do
    case :queue.out(queue) do
      {:empty, _} ->
        {queue, visited, nil}

      {{:value, node}, rest_queue} ->
        neighbors = next_fn.(node)

        {new_queue, new_visited, meeting} =
          Enum.reduce(neighbors, {rest_queue, visited, nil}, fn neighbor,
                                                                {q_acc, v_acc, meet_acc} ->
            cond do
              meet_acc != nil ->
                # Already found meeting point
                {q_acc, v_acc, meet_acc}

              Map.has_key?(v_acc, neighbor) ->
                # Already visited in our direction
                {q_acc, v_acc, meet_acc}

              Map.has_key?(other_visited, neighbor) ->
                # Found meeting point! Add it to our map before returning
                {q_acc, Map.put(v_acc, neighbor, node), neighbor}

              true ->
                # New node to visit
                {:queue.in(neighbor, q_acc), Map.put(v_acc, neighbor, node), meet_acc}
            end
          end)

        {new_queue, new_visited, meeting}
    end
  end

  defp build_bidirectional_path(forward, backward, meeting_node) do
    # Build path from start to meeting node (forward search)
    forward_path = build_path_from_parents(forward, meeting_node)

    # Build path from goal to meeting node (backward search), then reverse it
    # and drop the meeting node since it's already in forward_path
    backward_path =
      build_path_from_parents(backward, meeting_node)
      |> Enum.reverse()
      |> Enum.drop(1)

    forward_path ++ backward_path
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
  Visit all nodes that are reachable from a start node.

  The nodes will be visited in BFS order, starting from the `start` node and
  following the order returned by the `successors` function.

  Returns a stream of reachable nodes.

  ## Examples

  The stream stops when there are no new nodes to visit:

  ```elixir
  all_nodes = Pathfinding.Directed.BFS.bfs_reach(3, fn _ -> 1..5 end) |> Enum.to_list()
  assert all_nodes == [3, 1, 2, 4, 5]
  ```

  The stream can be used as a generator. Here are the multiples of 2 and 3
  (although not in natural order but in the order they are discovered by the BFS algorithm):

  ```elixir
  stream = Pathfinding.Directed.BFS.bfs_reach(1, fn n -> [n * 2, n * 3] end)
  result = stream |> Stream.drop(1) |> Enum.take(7)
  assert result == [2, 3, 4, 6, 9, 8, 12]
  ```
  """
  def bfs_reach(start, successors) when is_function(successors, 1) do
    Stream.resource(
      fn -> {MapSet.new([start]), :queue.from_list([start])} end,
      fn {seen, queue} ->
        case :queue.out(queue) do
          {:empty, _} ->
            {:halt, nil}

          {{:value, node}, rest_queue} ->
            new_neighbors = successors.(node)

            actual_new = Enum.filter(new_neighbors, fn n -> not MapSet.member?(seen, n) end)

            new_seen = Enum.reduce(actual_new, seen, fn n, acc -> MapSet.put(acc, n) end)

            new_queue = Enum.reduce(actual_new, rest_queue, fn n, q -> :queue.in(n, q) end)

            {[node], {new_seen, new_queue}}
        end
      end,
      fn _ -> :ok end
    )
  end
end
