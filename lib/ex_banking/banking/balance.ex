defmodule ExBanking.Banking.Balance do
  alias ExBanking.Banking.BalanceAgent

  def get_balance(user, currency), do: {:ok, BalanceAgent.get_balance(user, currency)}

  def deposit(user, amount, currency), do: BalanceAgent.deposit(user, amount, currency)

  def withdraw(user, amount, currency) do
    with true <- can_withdraw_amount(user, amount, currency) do
      withdraw(user, amount, currency)
    end
  end

  def send(from_user, to_user, amount, currency) do
    with :ok <- withdraw(from_user, amount, currency) do
      deposit(to_user, amount, currency)
    end
  end

  defp can_withdraw_amount(user, amount, currency) do
    with false <- get_balance(user, currency) >= amount do
      {:error, :not_enough_money}
    end
  end
end
