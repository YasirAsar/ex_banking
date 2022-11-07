defmodule ExBanking.Accounts.UserRequestManager do
  alias ExBanking.Accounts.UserRequestCounter
  alias ExBanking.Accounts.UserRegistry

  @maximum_allowed_request Application.compile_env!(:ex_banking, :maximum_allowed_request)

  def manage_request(user, fun) do
    with true <- restrict_user_request(user) do
      UserRequestCounter.check_out(user)

      try do
        fun.()
      rescue
        e ->
          reraise e, __STACKTRACE__
      after
        UserRequestCounter.check_in(user)
      end
    end
  end

  def manage_request(user, currency, fun) do
    with {:ok, user_pid} <- UserRegistry.lookup_user(user) do
      manage_request(user, fn ->
        fun.(user_pid, currency)
      end)
    end
  end

  def manage_request(user, amount, currency, fun) do
    with {:ok, user_pid} <- UserRegistry.lookup_user(user) do
      manage_request(user, fn ->
        fun.(user_pid, amount, currency)
      end)
    end
  end

  def manage_request(from_user, to_user, amount, currency, fun) do
    with {:ok, sender_pid} <- UserRegistry.lookup_user(from_user, :sender),
         {:ok, receiver_pid} <- UserRegistry.lookup_user(to_user, :receiver),
         true <- restrict_user_request(from_user, :sender),
         true <- restrict_user_request(to_user, :receiver) do
      UserRequestCounter.check_out(from_user)
      UserRequestCounter.check_out(to_user)

      try do
        fun.(sender_pid, receiver_pid, amount, currency)
      rescue
        e ->
          reraise e, __STACKTRACE__
      after
        UserRequestCounter.check_in(from_user)
        UserRequestCounter.check_in(to_user)
      end
    end
  end

  defp restrict_user_request(user, type \\ nil) do
    user
    |> UserRequestCounter.get_user_request_count()
    |> restrict_user_request_count(type)
  end

  defp restrict_user_request_count(count, type) do
    with false <- count < @maximum_allowed_request do
      {:error, user_request_count_error(type)}
    end
  end

  defp user_request_count_error(:sender), do: :too_many_requests_to_sender
  defp user_request_count_error(:receiver), do: :too_many_requests_to_receiver
  defp user_request_count_error(_), do: :too_many_requests_to_user
end
