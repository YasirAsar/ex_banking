defmodule ExBanking do
  alias ExBanking.ArgumentValidator
  alias ExBanking.Accounts.UserRegistry
  alias ExBanking.Banking.Balance

  def create_user(user) do
    with true <- ArgumentValidator.validate_create_user_args(user),
         {:error, :user_does_not_exist} <- UserRegistry.check_user_existence(user) do
      UserRegistry.create_user(user)
    end
  end

  def deposit(user, amount, currency) do
    with true <- ArgumentValidator.validate_deposit_args(user, amount, currency) do
      UserRegistry.lookup_user(user, amount, currency, &Balance.deposit/3)
    end
  end

  def withdraw(user, amount, currency) do
    with true <- ArgumentValidator.validate_withdraw_args(user, amount, currency) do
      UserRegistry.lookup_user(user, amount, currency, &Balance.withdraw/3)
    end
  end

  def get_balance(user, currency) do
    with true <- ArgumentValidator.validate_get_balance(user, currency),
         {:ok, pid} <- UserRegistry.lookup_user(user) do
      Balance.get_balance(pid, currency)
    end
  end

  def send(from_user, to_user, amount, currency) do
    with true <- ArgumentValidator.validate_send(from_user, to_user, amount, currency),
         {:ok, sender_pid} <- UserRegistry.lookup_user(from_user, :sender),
         {:ok, receiver_pid} <- UserRegistry.lookup_user(to_user, :receiver) do
      Balance.send(sender_pid, receiver_pid, amount, currency)
    end
  end
end
