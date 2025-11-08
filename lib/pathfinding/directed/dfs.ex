defmodule Pathfinding.Directed.DFS do
  @moduledoc """
  Compute paths using the depth-first search algorithm.

  See [Wikipedia: Depth-first search](https://en.wikipedia.org/wiki/Depth-first_search).
  """

  @doc """
  Compute a path using the depth-first search algorithm.

  The path starting from `start` up to a node for which `success` returns `true` is
  computed and returned in an `{:ok, path}`. If no path can be found, `:error`
  is returned instead.

  - `start` is the starting node.
  - `successors` returns a list of successors for a given node, which will be tried in order.
  - `success` checks whether the goal has been reached.

  A node will never be included twice in the path.

  The returned path comprises both the start and end node.

  ## Example

  We will search a way to get from 1 to 17 while only adding 1 or multiplying the number by itself.

  If we put the adder first, an adder-only solution will be found:

  ```elixir
  successors = fn n -> [n + 1, n * n] |> Enum.filter(fn x -> x <= 17 end) end
  result = Pathfinding.Directed.DFS.dfs(1, successors, fn n -> n == 17 end)
  {:ok, path} = result
  assert path == Enum.to_list(1..17)
  ```

  However, if we put the multiplier first, a shorter solution will be explored first:

  ```elixir
  successors = fn n -> [n * n, n + 1] |> Enum.filter(fn x -> x <= 17 end) end
  result = Pathfinding.Directed.DFS.dfs(1, successors, fn n -> n == 17 end)
  {:ok, path} = result
  assert path == [1, 2, 4, 16, 17]
  ```
  """
  def dfs(start, successors, success)
      when is_function(successors, 1) and is_function(success, 1) do
    if success.(start) do
      {:ok, [start]}
    else
      dfs_core(start, successors, success)
    end
  end

  defp dfs_core(start, successors, success) do
    # DFS uses a stack (list) for to_visit, parents maps node -> parent
    to_visit = [start]
    visited = MapSet.new()
    parents = %{}

    dfs_loop(to_visit, visited, parents, successors, success)
  end

  defp dfs_loop([], _visited, _parents, _successors, _success), do: :error

  defp dfs_loop([node | rest], visited, parents, successors, success) do
    if MapSet.member?(visited, node) do
      # Already visited, skip
      dfs_loop(rest, visited, parents, successors, success)
    else
      # Mark as visited
      new_visited = MapSet.put(visited, node)

      if success.(node) do
        # Found goal, build path
        path = build_path_from_parents(parents, node)
        {:ok, path}
      else
        # Get successors and add them to the stack
        # We reverse the successors so that the first one is explored first (DFS order)
        node_successors = successors.(node) |> Enum.reverse()

        {new_stack, new_parents} =
          Enum.reduce(node_successors, {rest, parents}, fn succ, {stack_acc, parents_acc} ->
            if MapSet.member?(new_visited, succ) do
              {stack_acc, parents_acc}
            else
              {[succ | stack_acc], Map.put(parents_acc, succ, node)}
            end
          end)

        dfs_loop(new_stack, new_visited, new_parents, successors, success)
      end
    end
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

  The nodes will be visited in DFS order, starting from the `start` node and
  following the order returned by the `successors` function.

  Returns a stream of reachable nodes.

  ## Examples

  The stream stops when there are no new nodes to visit:

  ```elixir
  all_nodes = Pathfinding.Directed.DFS.dfs_reach(3, fn _ -> 1..5 end) |> Enum.to_list()
  assert all_nodes == [3, 1, 2, 4, 5]
  ```

  The stream can be used as a generator. Here are the multiples of 2 and 3 smaller than 15
  (although not in natural order but in the order they are discovered by the DFS algorithm):

  ```elixir
  stream = Pathfinding.Directed.DFS.dfs_reach(1, fn n -> [n * 2, n * 3] |> Enum.filter(&(&1 < 15)) end)
  result = stream |> Stream.drop(1) |> Enum.take(7)
  assert result == [2, 4, 8, 12, 6, 3, 9]
  ```
  """
  def dfs_reach(start, successors) when is_function(successors, 1) do
    Stream.resource(
      fn -> {[start], MapSet.new()} end,
      fn {to_see, visited} ->
        case to_see do
          [] ->
            {:halt, nil}

          [node | rest] ->
            if MapSet.member?(visited, node) do
              # Already visited, skip
              {[], {rest, visited}}
            else
              # Visit node
              new_visited = MapSet.put(visited, node)
              new_successors = successors.(node) |> Enum.reject(&MapSet.member?(new_visited, &1))
              # Add new successors to the front of the stack (DFS)
              new_to_see = new_successors ++ rest

              {[node], {new_to_see, new_visited}}
            end
        end
      end,
      fn _ -> :ok end
    )
  end
end
