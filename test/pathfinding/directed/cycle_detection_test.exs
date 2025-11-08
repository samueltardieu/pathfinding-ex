defmodule Pathfinding.Directed.CycleDetectionTest do
  use ExUnit.Case, async: true
  alias Pathfinding.Directed.CycleDetection

  describe "floyd/2" do
    test "detects simple cycle" do
      # Sequence: 1 -> 2 -> 4 -> 1 (mod 7)
      successor = fn x -> rem(x * 2, 7) end
      {lam, _elem, mu} = CycleDetection.floyd(1, successor)

      # Cycle length
      assert lam == 3
      # Starts immediately
      assert mu == 0
    end

    test "detects cycle with lead-in" do
      # Sequence: 0 -> 1 -> 2 -> 3 -> 2 -> 3 -> ...
      successor = fn
        0 -> 1
        1 -> 2
        2 -> 3
        3 -> 2
        n -> n
      end

      {lam, elem, mu} = CycleDetection.floyd(0, successor)

      # Cycle 2 -> 3 -> 2
      assert lam == 2
      # Element in cycle
      assert elem in [2, 3]
      # Cycle starts at index 2
      assert mu == 2
    end

    test "detects cycle in modular arithmetic" do
      # x -> (x + 1) mod 5
      successor = fn x -> rem(x + 1, 5) end
      {lam, _elem, mu} = CycleDetection.floyd(0, successor)

      # Full cycle through 0,1,2,3,4
      assert lam == 5
      # Immediate cycle
      assert mu == 0
    end
  end

  describe "brent/2" do
    test "detects simple cycle" do
      successor = fn x -> rem(x * 2, 7) end
      {lam, _elem, mu} = CycleDetection.brent(1, successor)

      # Cycle length
      assert lam == 3
      # Starts immediately
      assert mu == 0
    end

    test "detects cycle with lead-in" do
      successor = fn
        0 -> 1
        1 -> 2
        2 -> 3
        3 -> 2
        n -> n
      end

      {lam, elem, mu} = CycleDetection.brent(0, successor)

      # Cycle 2 -> 3 -> 2
      assert lam == 2
      # Element in cycle
      assert elem in [2, 3]
      # Cycle starts at index 2
      assert mu == 2
    end

    test "detects cycle in modular arithmetic" do
      successor = fn x -> rem(x + 1, 5) end
      {lam, _elem, mu} = CycleDetection.brent(0, successor)

      # Full cycle
      assert lam == 5
      # Immediate cycle
      assert mu == 0
    end

    test "both algorithms agree" do
      successor = fn x -> rem(x * 3 + 1, 11) end

      {lam_floyd, _, mu_floyd} = CycleDetection.floyd(1, successor)
      {lam_brent, _, mu_brent} = CycleDetection.brent(1, successor)

      assert lam_floyd == lam_brent
      assert mu_floyd == mu_brent
    end
  end
end
