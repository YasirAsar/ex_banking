defmodule ExBanking.Accounts.UserRegistry do
  def create_user(user) do
    DynamicSupervisor.start_child(
      ExBanking.Accounts.UserSupervisor,
      {ExBanking.Banking.BalanceAgent, user}
    )
  end

  def delete_user(pid) do
    DynamicSupervisor.terminate_child(ExBanking.Accounts.UserSupervisor, pid)
  end

  def lookup_user(user, type \\ nil) do
    case Registry.lookup(__MODULE__, user) do
      [{pid, _value}] -> {:ok, pid}
      _ -> {:error, lookup_user_error(type)}
    end
  end

  def check_user_existence(user),
    do: with({:ok, _pid} <- lookup_user(user), do: {:error, :user_already_exists})

  def lookup_user_error(type)
  def lookup_user_error(:sender), do: :sender_does_not_exist
  def lookup_user_error(:receiver), do: :receiver_does_not_exist
  def lookup_user_error(_), do: :user_does_not_exist
end
