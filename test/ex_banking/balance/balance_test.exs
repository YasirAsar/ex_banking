defmodule ExBanking.Balance.BalanceTest do
  use ExUnit.Case

  alias ExBanking.Accounts.UserRegistry
  alias ExBanking.Accounts.UserSupervisor
  alias ExBanking.Banking.Balance

  @user "user"
  @amount 10
  @currency "euro"

  describe "can_withdraw_amount/3" do
    setup do
      {:ok, pid} = UserRegistry.create_user(@user)

      on_exit(fn ->
        DynamicSupervisor.terminate_child(UserSupervisor, pid)
      end)

      %{pid: pid}
    end

    test "if user doesn't have enough amount to withdraw, return not enough money error", %{
      pid: pid
    } do
      assert {:error, :not_enough_money} == Balance.can_withdraw_amount(pid, @amount, @currency)
    end

    test "if user has required balance in the account, return true", %{pid: pid} do
      Balance.deposit(pid, @amount, @currency)

      assert Balance.can_withdraw_amount(pid, @amount, @currency)
    end
  end
end
