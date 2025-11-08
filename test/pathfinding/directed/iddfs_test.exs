defmodule Pathfinding.Directed.IDDFSTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.IDDFS

  describe "iddfs/3" do
    test "finds path in simple linear graph" do
      # Graph: 1 -> 2 -> 3 -> 4
      successors = fn
        1 -> [2]
        2 -> [3]
        3 -> [4]
        4 -> []
        _ -> []
      end

      result = IDDFS.iddfs(1, successors, fn n -> n == 4 end)

      assert {:ok, [1, 2, 3, 4]} = result
    end

    test "start node is goal" do
      successors = fn n -> [n + 1] end
      result = IDDFS.iddfs(5, successors, fn n -> n == 5 end)

      assert {:ok, [5]} = result
    end

    test "finds short path" do
      successors = fn
        1 -> [2, 3]
        2 -> [4]
        3 -> [4]
        4 -> []
        _ -> []
      end

      result = IDDFS.iddfs(1, successors, fn n -> n == 4 end)

      assert {:ok, path} = result
      assert hd(path) == 1
      assert List.last(path) == 4
      assert length(path) == 3
    end

    test "returns error when no path exists" do
      successors = fn n -> if n < 3, do: [n + 1], else: [] end
      result = IDDFS.iddfs(1, successors, fn n -> n == 10 end)

      assert result == :error
    end
  end
end
