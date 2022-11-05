defmodule ExBanking.Banking.Balance do
  alias ExBanking.Banking.BalanceAgent

  def get_balance(user, currency), do: {:ok, BalanceAgent.get_balance(user, currency)}

  def deposit(user, amount, currency), do: BalanceAgent.deposit(user, amount, currency)

  def withdraw(user, amount, currency) do
    with true <- can_withdraw_amount(user, amount, currency) do
      BalanceAgent.withdraw(user, amount, currency)
    end
  end

  def send(from_user, to_user, amount, currency) do
    with {:ok, from_user_balance} <- withdraw(from_user, amount, currency),
         {:ok, to_user_balance} <- deposit(to_user, amount, currency) do
      {:ok, from_user_balance, to_user_balance}
    end
  end

  defp can_withdraw_amount(user, amount, currency) do
    with {:ok, balance} <- get_balance(user, currency),
         false <- balance >= amount do
      {:error, :not_enough_money}
    end
  end
end
