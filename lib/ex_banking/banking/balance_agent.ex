defmodule ExBanking.Banking.BalanceAgent do
  @moduledoc """
  This module has base functions for performing account balance curd operations
  like withdraw, deposits and balance enquiry.
  """
  use Agent, restart: :temporary

  alias ExBanking.Accounts.UserRequestCounter
  alias ExBanking.Banking.BalanceState

  @user_request_delay Application.compile_env!(:ex_banking, :user_request_delay)

  def start_link(user) do
    UserRequestCounter.initialize_user_request_counter(user)
    Agent.start_link(fn -> [] end, name: via_tuple(user))
  end

  def get_balance(user, currency) do
    Process.sleep(@user_request_delay)

    Agent.get(user, fn state ->
      Enum.find_value(state, 0.0, fn object ->
        if object.currency == currency, do: object.amount
      end)
    end)
  end

  def deposit(user, amount, currency) do
    Process.sleep(@user_request_delay)

    Agent.get_and_update(user, fn state ->
      state
      |> Enum.split_with(&(&1.currency == currency))
      |> case do
        {[], _} ->
          amount = set_precision(amount)
          balance = %BalanceState{currency: currency, amount: amount}

          {{:ok, balance.amount}, [balance | state]}

        {[object], remaining_state} ->
          amount = set_precision(object.amount + amount)
          balance = %{object | amount: amount}

          {{:ok, balance.amount}, [balance | remaining_state]}
      end
    end)
  end

  def withdraw(user, amount, currency) do
    Process.sleep(@user_request_delay)

    Agent.get_and_update(user, fn state ->
      {[object], remaining_state} = Enum.split_with(state, &(&1.currency == currency))
      amount = set_precision(object.amount - amount)
      balance = %{object | amount: amount}
      state = [balance | remaining_state]

      {{:ok, balance.amount}, state}
    end)
  end

  defp set_precision(amount) when is_integer(amount), do: amount
  defp set_precision(amount), do: Float.round(amount, 2)

  defp via_tuple(user), do: {:via, Registry, {ExBanking.Accounts.UserRegistry, user}}
end
