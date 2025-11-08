defmodule Pathfinding.Directed.IDDFS do
  @moduledoc """
  Compute shortest paths using iterative deepening depth-first search.

  See [Wikipedia: IDDFS](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search).
  """

  @doc """
  Compute a shortest path using the iterative deepening depth-first search algorithm.

  The shortest path starting from `start` up to a node for which `success` returns `true` is
  computed and returned in `{:ok, path}`. If no path can be found, `:error` is returned.

  - `start` is the starting node.
  - `successors` returns a list of successors for a given node.
  - `success` checks whether the goal has been reached.

  A node will never be included twice in the path.

  The returned path comprises both the start and end node.

  ## Example

  We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only
  knight moves.

  ```elixir
  successors = fn {x, y} ->
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
  end

  result = Pathfinding.Directed.IDDFS.iddfs({1, 1}, successors, fn p -> p == {4, 6} end)
  {:ok, path} = result
  assert length(path) == 5
  ```
  """
  def iddfs(start, successors, success)
      when is_function(successors, 1) and is_function(success, 1) do
    path = [start]
    iddfs_loop(path, successors, success, 1)
  end

  defp iddfs_loop(path, successors, success, max_depth) do
    case step(path, successors, success, max_depth) do
      {:found, final_path} ->
        {:ok, final_path}

      :none_at_depth ->
        iddfs_loop(path, successors, success, max_depth + 1)

      :impossible ->
        :error
    end
  end

  defp step(path, successors, success, depth) do
    current = List.last(path)

    cond do
      depth == 0 ->
        :none_at_depth

      success.(current) ->
        {:found, path}

      true ->
        node_successors = successors.(current)
        explore_successors(path, node_successors, successors, success, depth)
    end
  end

  defp explore_successors(path, [], _successors, _success, _depth) do
    :impossible
  end

  defp explore_successors(path, [succ | rest], successors, success, depth) do
    if succ in path do
      # Skip nodes already in path
      explore_successors(path, rest, successors, success, depth)
    else
      new_path = path ++ [succ]

      case step(new_path, successors, success, depth - 1) do
        {:found, final_path} ->
          {:found, final_path}

        :none_at_depth ->
          # Continue exploring, but remember we found something at this depth
          case explore_successors(path, rest, successors, success, depth) do
            :impossible -> :none_at_depth
            other -> other
          end

        :impossible ->
          explore_successors(path, rest, successors, success, depth)
      end
    end
  end
end
