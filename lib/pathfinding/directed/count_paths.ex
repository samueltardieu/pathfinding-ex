defmodule Pathfinding.Directed.CountPaths do
  @moduledoc """
  Count the total number of possible paths to reach a destination.

  **Warning:** There must be no loops in the graph, or the function may not terminate.
  """

  @doc """
  Count the total number of possible paths to reach a destination.

  - `start` is the starting node.
  - `successors` returns a list of successors for a given node.
  - `success` checks whether the goal has been reached.

  Returns the total number of paths from start to any goal node.

  **Warning:** There must be no loops in the graph, or the function may not terminate.

  ## Example

  On a 8x8 board, find the total paths from the bottom-left square to the top-right square:

  ```elixir
  successors = fn {x, y} ->
    [{x + 1, y}, {x, y + 1}]
    |> Enum.filter(fn {x, y} -> x < 8 and y < 8 end)
  end

  n = Pathfinding.Directed.CountPaths.count_paths({0, 0}, successors, fn c -> c == {7, 7} end)
  assert n == 3432
  ```
  """
  def count_paths(start, successors, success)
      when is_function(successors, 1) and is_function(success, 1) do
    cache = %{}
    {count, _cache} = cached_count_paths(start, successors, success, cache)
    count
  end

  defp cached_count_paths(node, successors, success, cache) do
    case Map.get(cache, node) do
      nil ->
        # Not in cache, compute it
        {count, new_cache} =
          if success.(node) do
            {1, cache}
          else
            # Count paths through all successors
            successors.(node)
            |> Enum.reduce({0, cache}, fn successor, {acc_count, acc_cache} ->
              {succ_count, updated_cache} =
                cached_count_paths(successor, successors, success, acc_cache)

              {acc_count + succ_count, updated_cache}
            end)
          end

        # Store in cache
        {count, Map.put(new_cache, node, count)}

      cached_count ->
        # Return cached value
        {cached_count, cache}
    end
  end
end
