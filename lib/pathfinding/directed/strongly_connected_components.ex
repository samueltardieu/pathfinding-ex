defmodule Pathfinding.Directed.StronglyConnectedComponents do
  @moduledoc """
  Separate nodes of a directed graph into strongly connected components.

  A path-based strong component algorithm is used.

  See [Wikipedia: Strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component).
  """

  @doc """
  Compute the strongly connected component containing a given node.

  - `node` is the node we want the strongly connected component for.
  - `successors` returns a list of successors for a given node.

  Returns the strongly connected component containing the node as a list,
  which is guaranteed to contain at least `node`.

  ## Example

  ```elixir
  # Graph: 1 -> 2 -> 3 -> 1 (cycle), 3 -> 4
  successors = fn
    1 -> [2]
    2 -> [3]
    3 -> [1, 4]
    4 -> []
    _ -> []
  end

  scc = Pathfinding.Directed.StronglyConnectedComponents.strongly_connected_component(1, successors)
  # Returns [1, 2, 3] (nodes in the cycle)
  ```
  """
  def strongly_connected_component(node, successors) when is_function(successors, 1) do
    # Get all SCCs starting from this node, find the one containing our node
    sccs = strongly_connected_components_from(node, successors)
    Enum.find(sccs, fn scc -> node in scc end)
  end

  @doc """
  Partition nodes reachable from a starting point into strongly connected components.

  - `start` is the node we want to explore the graph from.
  - `successors` returns a list of successors for a given node.

  Returns a list of strongly connected component sets.
  It will contain at least one component (the one containing the `start` node).

  ## Example

  ```elixir
  successors = fn
    1 -> [2]
    2 -> [3]
    3 -> [1, 4]
    4 -> [5]
    5 -> [4]
    _ -> []
  end

  sccs = Pathfinding.Directed.StronglyConnectedComponents.strongly_connected_components_from(1, successors)
  # Returns [[4, 5], [1, 2, 3]] - two SCCs
  ```
  """
  def strongly_connected_components_from(start, successors) when is_function(successors, 1) do
    params = %{
      preorders: %{},
      c: 0,
      p: [],
      s: [],
      scc: [],
      scca: MapSet.new()
    }

    params = recurse_onto(start, params, successors)
    params.scc
  end

  @doc """
  Partition all strongly connected components in a graph.

  - `nodes` is a list of nodes.
  - `successors` returns a list of successors for a given node.

  Returns a list of strongly connected component sets.

  ## Example

  ```elixir
  successors = fn
    1 -> [2]
    2 -> [1]
    3 -> [4]
    4 -> [3]
    _ -> []
  end

  sccs = Pathfinding.Directed.StronglyConnectedComponents.strongly_connected_components([1, 2, 3, 4], successors)
  # Returns [[3, 4], [1, 2]] - two separate SCCs
  ```
  """
  def strongly_connected_components(nodes, successors)
      when is_list(nodes) and is_function(successors, 1) do
    initial_preorders = Enum.into(nodes, %{}, fn n -> {n, nil} end)

    params = %{
      preorders: initial_preorders,
      c: 0,
      p: [],
      s: [],
      scc: [],
      scca: MapSet.new()
    }

    process_all_nodes(params, successors)
  end

  defp process_all_nodes(params, successors) do
    case find_unvisited_node(params) do
      nil ->
        params.scc

      node ->
        new_params = recurse_onto(node, params, successors)
        process_all_nodes(new_params, successors)
    end
  end

  defp find_unvisited_node(params) do
    Enum.find_value(params.preorders, fn
      {node, nil} -> node
      _ -> nil
    end)
  end

  defp recurse_onto(v, params, successors) do
    params = %{
      params
      | preorders: Map.put(params.preorders, v, params.c),
        c: params.c + 1,
        s: [v | params.s],
        p: [v | params.p]
    }

    process_successors(successors.(v), v, params, successors)
  end

  defp process_successors([], v, params, _successors) do
    finalize_component(v, params)
  end

  defp process_successors([w | rest], v, params, successors) do
    params =
      if not MapSet.member?(params.scca, w) do
        case Map.get(params.preorders, w) do
          nil ->
            # w hasn't been visited, recurse
            recurse_onto(w, params, successors)

          pw when is_integer(pw) ->
            # w has been visited, update p stack
            update_p_stack(params, pw)

          _other ->
            params
        end
      else
        params
      end

    process_successors(rest, v, params, successors)
  end

  defp update_p_stack(params, pw) do
    new_p = drop_while_greater(params.p, params.preorders, pw)
    %{params | p: new_p}
  end

  defp drop_while_greater([], _preorders, _pw), do: []

  defp drop_while_greater([h | t] = list, preorders, pw) do
    case Map.get(preorders, h) do
      preorder when is_integer(preorder) and preorder > pw ->
        drop_while_greater(t, preorders, pw)

      _ ->
        list
    end
  end

  defp finalize_component(v, params) do
    case params.p do
      [^v | rest_p] ->
        # v is the root of an SCC, collect the component
        {component, new_s, new_scca, new_preorders} =
          collect_component(v, params.s, [], params.scca, params.preorders)

        %{
          params
          | p: rest_p,
            s: new_s,
            scc: [component | params.scc],
            scca: new_scca,
            preorders: new_preorders
        }

      _ ->
        params
    end
  end

  defp collect_component(v, [node | rest_s], component, scca, preorders) do
    new_component = [node | component]
    new_scca = MapSet.put(scca, node)
    new_preorders = Map.delete(preorders, node)

    if node == v do
      {new_component, rest_s, new_scca, new_preorders}
    else
      collect_component(v, rest_s, new_component, new_scca, new_preorders)
    end
  end

  defp collect_component(_v, [], component, scca, preorders) do
    {component, [], scca, preorders}
  end
end
