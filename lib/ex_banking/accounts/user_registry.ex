defmodule ExBanking.Accounts.UserRegistry do
  @moduledoc """
  This module has functions which help us to interact with Registry function.
  """

  alias ExBanking.Types

  @spec create_user(Types.user()) :: any()
  def create_user(user) do
    DynamicSupervisor.start_child(
      ExBanking.Accounts.UserSupervisor,
      {ExBanking.Banking.BalanceAgent, user}
    )
  end

  @spec delete_user(Types.user_pid()) :: :ok | {:error, :not_found}
  def delete_user(pid) do
    DynamicSupervisor.terminate_child(ExBanking.Accounts.UserSupervisor, pid)
  end

  @spec lookup_user(Types.user()) ::
          {:ok, Types.user_pid()}
          | {:error}
  @spec lookup_user(Types.user(), atom()) ::
          {:ok, Types.user_pid()} | {:error, lookup_user_error()}
  def lookup_user(user, type \\ nil) do
    case Registry.lookup(__MODULE__, user) do
      [{pid, _value}] -> {:ok, pid}
      _ -> {:error, lookup_user_error(type)}
    end
  end

  @spec check_user_existence(Types.user()) :: {:error, lookup_user_error() | :user_already_exists}
  def check_user_existence(user) do
    with {:ok, _pid} <- lookup_user(user), do: {:error, :user_already_exists}
  end

  @type lookup_user_error() ::
          :sender_does_not_exist | :receiver_does_not_exist | :user_does_not_exist

  @spec lookup_user_error(atom()) :: lookup_user_error()
  defp lookup_user_error(type)
  defp lookup_user_error(:sender), do: :sender_does_not_exist
  defp lookup_user_error(:receiver), do: :receiver_does_not_exist
  defp lookup_user_error(_), do: :user_does_not_exist
end
