defmodule ExBanking.Banking.BalanceAgent do
  @moduledoc """
  This module has base functions for performing account balance curd operations
  like withdraw, deposits and balance enquiry.
  """
  use Agent, restart: :temporary

  alias ExBanking.Accounts.UserRequestCounter
  alias ExBanking.Banking.BalanceState
  alias ExBanking.Types

  @enable_user_request_delay Application.compile_env!(:ex_banking, :enable_user_request_delay)

  @spec start_link(Types.user()) ::
          {:ok, Types.user_pid()} | {:error, {:already_started, Types.user_pid()} | term}
  def start_link(user) do
    UserRequestCounter.initialize_user_request_counter(user)
    Agent.start_link(fn -> [] end, name: via_tuple(user))
  end

  @spec get_balance(Types.user_pid(), Types.currency()) :: Types.amount()
  def get_balance(user, currency) do
    enable_user_request_delay()

    Agent.get(user, fn state ->
      Enum.find_value(state, 0.0, fn object ->
        if object.currency == currency, do: object.amount
      end)
    end)
  end

  @spec deposit(Types.user_pid(), Types.amount(), Types.currency()) :: {:ok, Types.amount()}
  def deposit(user, amount, currency) do
    enable_user_request_delay()

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

  @spec withdraw(Types.user_pid(), Types.amount(), Types.currency()) :: {:ok, Types.amount()}
  def withdraw(user, amount, currency) do
    enable_user_request_delay()

    Agent.get_and_update(user, fn state ->
      {[object], remaining_state} = Enum.split_with(state, &(&1.currency == currency))
      amount = set_precision(object.amount - amount)
      balance = %{object | amount: amount}
      state = [balance | remaining_state]

      {{:ok, balance.amount}, state}
    end)
  end

  @spec set_precision(Types.amount()) :: float()
  defp set_precision(amount) when is_integer(amount), do: amount + 0.0
  defp set_precision(amount), do: Float.round(amount, 2)

  @spec via_tuple(Types.user()) :: tuple()
  defp via_tuple(user), do: {:via, Registry, {ExBanking.Accounts.UserRegistry, user}}

  @spec enable_user_request_delay() :: :ok
  defp enable_user_request_delay do
    if @enable_user_request_delay do
      Process.sleep(2000)
    else
      :ok
    end
  end
end
