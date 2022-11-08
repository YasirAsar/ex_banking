defmodule ExBanking.Banking.Balance do
  @moduledoc """
  This module act has client functions for BalanceAgent server.
  """

  alias ExBanking.Banking.BalanceAgent
  alias ExBanking.Types

  @spec get_balance(Types.user_pid(), Types.currency()) :: {:ok, Types.amount()}
  def get_balance(user, currency), do: {:ok, BalanceAgent.get_balance(user, currency)}

  @spec deposit(Types.user_pid(), Types.amount(), Types.currency()) :: {:ok, Types.amount()}
  def deposit(user, amount, currency), do: BalanceAgent.deposit(user, amount, currency)

  @spec withdraw(Types.user_pid(), Types.amount(), Types.currency()) ::
          {:ok, Types.amount()} | {:error, :not_enough_money}
  def withdraw(user, amount, currency) do
    with true <- can_withdraw_amount(user, amount, currency) do
      BalanceAgent.withdraw(user, amount, currency)
    end
  end

  @spec send(Types.user_pid(), Types.user_pid(), Types.amount(), Types.currency()) ::
          {:ok, Types.amount(), Types.amount()} | {:error, :not_enough_money}
  def send(from_user, to_user, amount, currency) do
    with {:ok, from_user_balance} <- withdraw(from_user, amount, currency),
         {:ok, to_user_balance} <- deposit(to_user, amount, currency) do
      {:ok, from_user_balance, to_user_balance}
    end
  end

  @spec can_withdraw_amount(Types.user_pid(), Types.amount(), Types.currency()) ::
          true | {:error, :not_enough_money}
  def can_withdraw_amount(user, amount, currency) do
    with {:ok, balance} <- get_balance(user, currency),
         false <- balance >= amount do
      {:error, :not_enough_money}
    end
  end
end
