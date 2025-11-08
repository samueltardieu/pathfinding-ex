# pathfinding

This library implements pathfinding, flow, and graph algorithms in Elixir.

## Installation

Add `pathfinding` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pathfinding, "~> 4.14"}
  ]
end
```

## Algorithms

The algorithms are generic over their arguments.

### Directed graphs

- **BFS** (breadth-first search): find the shortest path in an unweighted graph ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Breadth-first_search))
- **Bidirectional search**: simultaneously explore paths forwards from the start and backwards from the goal ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Bidirectional_search))
- **DFS** (depth-first search): explore by going as far as possible, then backtrack ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Depth-first_search))
- **IDDFS** (iterative deepening DFS): find shortest paths by iteratively deepening the search ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search))
- **Dijkstra**: find the shortest path in a weighted graph ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm))
- **A\***: heuristic-guided shortest path search ([⇒ Wikipedia](https://en.wikipedia.org/wiki/A*_search_algorithm))
- **Cycle detection**: detect cycles using Floyd's or Brent's algorithm ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Cycle_detection))
- **Topological sort**: find a topological order in a DAG ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Topological_sorting))

### Undirected graphs

- **Connected components**: find disjoint connected sets of vertices ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Connected_component_(graph_theory)))
- **Kruskal**: find a minimum spanning tree ([⇒ Wikipedia](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm))

### Data Structures

- **Grid**: rectangular grid for pathfinding with obstacles and diagonal movement
- **Matrix**: 2D matrix for storing arbitrary data with neighbor queries

### Additional Algorithms (Available in Rust Version)

The following specialized algorithms from the Rust version could be added in future:
- IDA* (iterative deepening A*)
- Strongly connected components
- Yen's k-shortest paths algorithm
- Prim's MST algorithm
- Path counting in DAGs
- Edmonds-Karp (maximum flow)
- Fringe search
- Cliques (Bron-Kerbosch algorithm)

## Using this library

You can pull your preferred algorithm using:

```elixir
alias Pathfinding.Directed.BFS
```

## Example

We will search the shortest path on a chess board to go from `{1, 1}` to `{4, 6}` doing only knight moves.

```elixir
defmodule Knight do
  def successors({x, y}) do
    [
      {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
      {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
    ]
  end
end

goal = {4, 6}
{:ok, path} = Pathfinding.Directed.BFS.bfs({1, 1}, &Knight.successors/1, fn p -> p == goal end)
IO.inspect(length(path))  # Output: 5
```

You can also use an inline function:

```elixir
successors = fn {x, y} ->
  [
    {x + 1, y + 2}, {x + 1, y - 2}, {x - 1, y + 2}, {x - 1, y - 2},
    {x + 2, y + 1}, {x + 2, y - 1}, {x - 2, y + 1}, {x - 2, y - 1}
  ]
end

goal = {4, 6}
{:ok, path} = Pathfinding.Directed.BFS.bfs({1, 1}, successors, fn p -> p == goal end)
IO.inspect(length(path))  # Output: 5
```

## Working with Graphs

This library does not provide a fixed graph data structure. Instead, the algorithms accept a **successor function** that defines how to navigate from one node to its neighbors.

For comprehensive examples showing how to represent graphs (adjacency lists, adjacency matrices, edge lists, etc.), see the [Graph Guide](GRAPH_GUIDE.md).

## License

This code is released under a dual Apache 2.0 / MIT free software license.

## Contributing

You are welcome to contribute by opening [issues](https://github.com/samueltardieu/pathfinding-ex/issues) or submitting [pull requests](https://github.com/samueltardieu/pathfinding-ex/pulls).

In order to pass the continuous integration tests, your code must be formatted using `mix format` and pass all tests with `mix test`.

## Migration from Rust

This library is a partial port of the original Rust `pathfinding` crate. The API has been adapted to follow Elixir conventions:

- Functions return `{:ok, result}` or `:error` instead of `Some(result)` or `None`
- Closures are replaced with anonymous functions
- Type constraints are handled through guards and pattern matching

More algorithms will be ported in future releases.

