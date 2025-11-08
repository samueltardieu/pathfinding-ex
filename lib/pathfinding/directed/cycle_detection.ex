defmodule Pathfinding.Directed.CycleDetection do
  @moduledoc """
  Identify cycles in infinite sequences using Floyd's and Brent's algorithms.

  See [Wikipedia: Cycle detection](https://en.wikipedia.org/wiki/Cycle_detection).
  """

  @doc """
  Identify a cycle using Floyd's algorithm (tortoise and hare).

  Returns `{cycle_length, first_element_in_cycle, index_of_first_element}`.

  ## Example

      # Sequence: 1 -> 2 -> 4 -> 1 (cycle of length 3 starting at index 0)
      successor = fn x -> rem(x * 2, 7) end
      {lam, _elem, mu} = Pathfinding.Directed.CycleDetection.floyd(1, successor)
      assert lam == 3  # Cycle length
      assert mu == 0   # Cycle starts at index 0

  ## Warning

  If no cycle exists, this function loops forever.
  """
  def floyd(start, successor) when is_function(successor, 1) do
    # Phase 1: Find a point in the cycle
    {tortoise, hare, _steps} = floyd_detect(start, successor)

    # Phase 2: Find cycle length
    lam = floyd_cycle_length(tortoise, hare, successor)

    # Phase 3: Find the start of the cycle
    {mu, cycle_start} = floyd_find_start(start, tortoise, hare, lam, successor)

    {lam, cycle_start, mu}
  end

  defp floyd_detect(start, successor) do
    tortoise = successor.(start)
    hare = successor.(successor.(start))
    floyd_detect_loop(tortoise, hare, successor, 1)
  end

  defp floyd_detect_loop(tortoise, hare, successor, steps) do
    if tortoise == hare do
      {tortoise, hare, steps}
    else
      new_tortoise = successor.(tortoise)
      new_hare = successor.(successor.(hare))
      floyd_detect_loop(new_tortoise, new_hare, successor, steps + 1)
    end
  end

  defp floyd_cycle_length(tortoise, hare, successor) do
    new_hare = successor.(hare)
    floyd_cycle_length_loop(tortoise, new_hare, successor, 1)
  end

  defp floyd_cycle_length_loop(tortoise, hare, successor, lam) do
    if tortoise == hare do
      lam
    else
      new_hare = successor.(hare)
      floyd_cycle_length_loop(tortoise, new_hare, successor, lam + 1)
    end
  end

  defp floyd_find_start(start, tortoise, hare, lam, successor) do
    # Move hare to position lam ahead of start
    hare_at_lam = Enum.reduce(1..lam, start, fn _, acc -> successor.(acc) end)
    floyd_find_start_loop(start, hare_at_lam, successor, 0)
  end

  defp floyd_find_start_loop(tortoise, hare, successor, mu) do
    if tortoise == hare do
      {mu, tortoise}
    else
      new_tortoise = successor.(tortoise)
      new_hare = successor.(hare)
      floyd_find_start_loop(new_tortoise, new_hare, successor, mu + 1)
    end
  end

  @doc """
  Identify a cycle using Brent's algorithm.

  Returns `{cycle_length, first_element_in_cycle, index_of_first_element}`.

  This is typically faster than Floyd's algorithm.

  ## Example

      successor = fn x -> rem(x * 2, 7) end
      {lam, _elem, mu} = Pathfinding.Directed.CycleDetection.brent(1, successor)
      assert lam == 3  # Cycle length

  ## Warning

  If no cycle exists, this function loops forever.
  """
  def brent(start, successor) when is_function(successor, 1) do
    # Phase 1: Find cycle length
    {lam, _hare} = brent_find_cycle(start, successor)

    # Phase 2: Find the start of the cycle
    {mu, cycle_start} = brent_find_start(start, lam, successor)

    {lam, cycle_start, mu}
  end

  defp brent_find_cycle(start, successor) do
    tortoise = start
    hare = successor.(start)
    brent_find_cycle_loop(tortoise, hare, successor, 1, 1)
  end

  defp brent_find_cycle_loop(tortoise, hare, successor, power, lam) do
    if tortoise == hare do
      {lam, hare}
    else
      if power == lam do
        # Move tortoise to hare position and double the power
        brent_find_cycle_loop(hare, successor.(hare), successor, power * 2, 1)
      else
        brent_find_cycle_loop(tortoise, successor.(hare), successor, power, lam + 1)
      end
    end
  end

  defp brent_find_start(start, lam, successor) do
    # Move hare lam steps ahead
    hare = Enum.reduce(1..lam, start, fn _, acc -> successor.(acc) end)
    brent_find_start_loop(start, hare, successor, 0)
  end

  defp brent_find_start_loop(tortoise, hare, successor, mu) do
    if tortoise == hare do
      {mu, tortoise}
    else
      new_tortoise = successor.(tortoise)
      new_hare = successor.(hare)
      brent_find_start_loop(new_tortoise, new_hare, successor, mu + 1)
    end
  end
end
