defmodule ExBanking.Accounts.UserRequestManager do
  def initialize_user_request_counter(user) do
    create_user_request_manager_table()
    insert_user(user)
  end

  def check_out(user), do: :ets.update_counter(__MODULE__, user, {2, 1})

  def check_in(user), do: :ets.update_counter(__MODULE__, user, {2, -1})

  def manage_request(user, fun) do
    if get_user_request_counter(user) < 10 do
      check_out(user)

      try do
        fun.()
      rescue
        e ->
          reraise e, __STACKTRACE__
      after
        check_in(user)
      end
    else
      {:error, :too_many_requests_to_user}
    end
  end

  defp get_user_request_counter(user) do
    with [{_, counter}] <- :ets.lookup(__MODULE__, user) do
      counter
    end
  end

  defp create_user_request_manager_table do
    with :undefined <- :ets.whereis(__MODULE__) do
      :ets.new(__MODULE__, [:public, :named_table, read_concurrency: true])
    end
  end

  defp insert_user(user), do: :ets.insert(__MODULE__, {user, 0})
end
