defmodule ExBanking do
  @moduledoc """
  This is the main module for the project.
  It has application main interface functions.
  """

  alias ExBanking.Accounts.UserRegistry
  alias ExBanking.Accounts.UserRequestManager
  alias ExBanking.ArgumentValidator
  alias ExBanking.Banking.Balance

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with true <- ArgumentValidator.validate_create_user_args(user),
         {:error, :user_does_not_exist} <- UserRegistry.check_user_existence(user),
         {:ok, _pid} <- UserRegistry.create_user(user) do
      :ok
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    UserRequestManager.manage_request(user, fn pid ->
      Balance.deposit(pid, amount, currency)
    end)
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}

  def withdraw(user, amount, currency) do
    with true <- ArgumentValidator.validate_withdraw_args(user, amount, currency) do
      UserRequestManager.manage_request(user, fn pid ->
        Balance.withdraw(pid, amount, currency)
      end)
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with true <- ArgumentValidator.validate_get_balance(user, currency) do
      UserRequestManager.manage_request(user, fn pid ->
        Balance.get_balance(pid, currency)
      end)
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with true <- ArgumentValidator.validate_send(from_user, to_user, amount, currency) do
      UserRequestManager.manage_request(from_user, to_user, fn sender_pid, receiver_pid ->
        Balance.send(sender_pid, receiver_pid, amount, currency)
      end)
    end
  end
end
