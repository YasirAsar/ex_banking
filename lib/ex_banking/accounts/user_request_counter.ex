defmodule ExBanking.Accounts.UserRequestCounter do
  def initialize_user_request_counter(user) do
    create_user_request_counter_table()
    insert_user(user)
  end

  def check_out(user), do: :ets.update_counter(__MODULE__, user, {2, 1})

  def check_in(user), do: :ets.update_counter(__MODULE__, user, {2, -1})

  def get_user_request_count(user) do
    case lookup(user) do
      [{_, count}] ->
        count

      [] ->
        initialize_user_request_counter(user)
        0
    end
  end

  defp create_user_request_counter_table do
    with :undefined <- :ets.whereis(__MODULE__) do
      :ets.new(__MODULE__, [:public, :named_table, read_concurrency: true])
    end
  end

  defp insert_user(user) do
    case lookup(user) do
      [] -> :ets.insert(__MODULE__, {user, 0})
      _ -> :ets.update_counter(__MODULE__, user, {2, 0})
    end
  end

  defp lookup(user), do: :ets.lookup(__MODULE__, user)
end
