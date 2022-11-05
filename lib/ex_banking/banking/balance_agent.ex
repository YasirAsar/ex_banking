defmodule ExBanking.Banking.BalanceAgent do
  @moduledoc """
  This module has base functions for performing account balance curd operations
  like withdraw, deposits and balance enquiry.
  """
  use Agent, restart: :temporary

  alias ExBanking.Banking.BalanceState

  def start_link(_opts) do
    Agent.start_link(fn -> [] end)
  end

  def get_balance(user, currency) do
    Agent.get(user, fn state ->
      Enum.find_value(state, 0.0, fn object ->
        if object.currency == currency, do: object.amount
      end)
    end)
  end

  def deposit(user, amount, currency) do
    Agent.update(user, fn state ->
      state
      |> Enum.split_with(&(&1.currency == currency))
      |> case do
        {[], _} ->
          amount = set_precision(amount)

          [%BalanceState{currency: currency, amount: amount} | state]

        {[object], remaining_state} ->
          amount = set_precision(object.amount + amount)

          [%{object | amount: amount} | remaining_state]
      end
    end)
  end

  def withdraw(user, amount, currency) do
    Agent.update(user, fn state ->
      {[object], remaining_state} = Enum.split_with(state, &(&1.currency == currency))
      amount = set_precision(object.amount - amount)
      [%{object | amount: amount} | remaining_state]
    end)
  end

  defp set_precision(amount), do: Float.round(amount, 2)
end
