defmodule Pathfinding.Directed.TopologicalSort do
  @moduledoc """
  Find a topological order in a directed graph if one exists.

  See [Wikipedia: Topological sorting](https://en.wikipedia.org/wiki/Topological_sorting).
  """

  @doc """
  Find a topological order in a directed graph if one exists.

  - `roots` is a list of nodes that ought to be explored.
  - `successors` returns a list of successors for a given node.

  The function returns an acceptable topological order of nodes given as roots or
  discovered in `{:ok, sorted_list}`, or an error `{:error, node}` if a cycle is detected,
  where `node` is an arbitrary node involved in a cycle.

  ## Examples

  We will sort integers from 1 to 9, each integer having its two immediate
  greater numbers as successors, starting with two roots 5 and 1:

  ```elixir
  successors = fn node ->
    cond do
      node <= 7 -> [node + 1, node + 2]
      node == 8 -> [9]
      true -> []
    end
  end

  result = Pathfinding.Directed.TopologicalSort.topological_sort([5, 1], successors)
  assert result == {:ok, [1, 2, 3, 4, 5, 6, 7, 8, 9]}
  ```

  If there is a loop in the graph, one of the nodes in the loop will be returned as an error:

  ```elixir
  successors = fn node ->
    cond do
      node <= 6 -> [node + 1, node + 2, 7]
      node == 7 -> [8, 9]
      node == 8 -> [7, 9]
      true -> [7]
    end
  end

  result = Pathfinding.Directed.TopologicalSort.topological_sort([5, 1], successors)
  assert {:error, _node} = result
  ```
  """
  def topological_sort(roots, successors) when is_list(roots) and is_function(successors, 1) do
    marked = MapSet.new()
    sorted = []
    unmarked = MapSet.new(roots)

    topological_sort_loop(unmarked, marked, sorted, successors)
  end

  defp topological_sort_loop(unmarked, marked, sorted, successors) do
    case Enum.take(unmarked, 1) do
      [] ->
        {:ok, sorted}

      [node] ->
        temp = MapSet.new()

        case visit(node, unmarked, marked, temp, sorted, successors) do
          {:ok, {new_unmarked, new_marked, new_sorted}} ->
            topological_sort_loop(new_unmarked, new_marked, new_sorted, successors)

          {:error, _} = error ->
            error
        end
    end
  end

  defp visit(node, unmarked, marked, temp, sorted, successors) do
    new_unmarked = MapSet.delete(unmarked, node)

    cond do
      MapSet.member?(marked, node) ->
        {:ok, {new_unmarked, marked, sorted}}

      MapSet.member?(temp, node) ->
        {:error, node}

      true ->
        new_temp = MapSet.put(temp, node)
        node_successors = successors.(node)

        case visit_successors(
               node_successors,
               new_unmarked,
               marked,
               new_temp,
               sorted,
               successors
             ) do
          {:ok, {final_unmarked, final_marked, final_sorted}} ->
            {:ok, {final_unmarked, MapSet.put(final_marked, node), [node | final_sorted]}}

          {:error, _} = error ->
            error
        end
    end
  end

  defp visit_successors([], unmarked, marked, _temp, sorted, _successors) do
    {:ok, {unmarked, marked, sorted}}
  end

  defp visit_successors([succ | rest], unmarked, marked, temp, sorted, successors) do
    case visit(succ, unmarked, marked, temp, sorted, successors) do
      {:ok, {new_unmarked, new_marked, new_sorted}} ->
        visit_successors(rest, new_unmarked, new_marked, temp, new_sorted, successors)

      {:error, _} = error ->
        error
    end
  end
end
