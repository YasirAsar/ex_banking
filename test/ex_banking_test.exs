defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "test" do
      start_time = DateTime.utc_now()
      ExBanking.create_user("yasir")

      1..20
      |> Enum.map(fn _ ->
        Task.async(fn ->
          ExBanking.get_balance("yasir", "euro")
        end)
      end)
      |> Enum.each(fn task ->
        Task.await(task) |> IO.inspect()
      end)

      1..20
      |> Enum.map(fn _ ->
        Task.async(fn ->
          ExBanking.get_balance("yasir", "euro")
        end)
      end)
      |> Enum.each(fn task ->
        Task.await(task) |> IO.inspect()
      end)

      end_time = DateTime.utc_now()

      DateTime.diff(end_time, start_time) |> IO.inspect(label: "diff ->")
      assert true
    end
  end
end
