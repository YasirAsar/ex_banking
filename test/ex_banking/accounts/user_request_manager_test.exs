defmodule ExBanking.Accounts.UserRequestManagerTest do
  use ExUnit.Case

  alias ExBanking.Accounts.UserRegistry
  alias ExBanking.Accounts.UserRequestManager
  alias ExBanking.Banking.Balance

  @user_1 "user_1"
  @user_2 "user_2"

  @currency "euro"
  @amount 10

  setup do
    {:ok, pid} = UserRegistry.create_user(@user_1)

    on_exit(fn -> UserRegistry.delete_user(pid) end)
  end

  describe "manage_request/2" do
    test "if user request more than allowed request limit, return too_many_requests_to_user error" do
      task_1 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, fn pid ->
            Balance.get_balance(pid, @currency)
          end)
        end)

      task_2 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, fn pid ->
            Balance.get_balance(pid, @currency)
          end)
        end)

      Process.sleep(100)

      task_3 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, fn pid ->
            Balance.get_balance(pid, @currency)
          end)
        end)

      assert {:ok, 0.0} == Task.await(task_1)
      assert {:ok, 0.0} == Task.await(task_2)
      assert {:error, :too_many_requests_to_user} == Task.await(task_3)
    end
  end

  describe "manage_request/3" do
    setup do
      {:ok, pid} = UserRegistry.create_user(@user_2)

      on_exit(fn -> UserRegistry.delete_user(pid) end)
    end

    test "if sender request more than allowed request limit, return too_many_requests_to_sender error" do
      task_1 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, fn pid ->
            Balance.deposit(pid, @amount, @currency)
          end)
        end)

      task_2 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, fn pid ->
            Balance.deposit(pid, @amount, @currency)
          end)
        end)

      Process.sleep(100)

      task_3 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, @user_2, fn sender_id, receiver_id ->
            Balance.send(sender_id, receiver_id, @amount, @currency)
          end)
        end)

      assert {:ok, _amount} = Task.await(task_1)
      assert {:ok, _amount} = Task.await(task_2)
      assert {:error, :too_many_requests_to_sender} == Task.await(task_3)
    end

    test "if receiver request more than allowed request limit, return too_many_requests_to_receiver error" do
      UserRequestManager.manage_request(@user_1, fn pid ->
        Balance.deposit(pid, @amount, @currency)
      end)

      task_1 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_2, fn pid ->
            Balance.deposit(pid, @amount, @currency)
          end)
        end)

      task_2 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_2, fn pid ->
            Balance.deposit(pid, @amount, @currency)
          end)
        end)

      Process.sleep(200)

      task_3 =
        Task.async(fn ->
          UserRequestManager.manage_request(@user_1, @user_2, fn sender_id, receiver_id ->
            Balance.send(sender_id, receiver_id, @amount, @currency)
          end)
        end)

      assert {:ok, _amount} = Task.await(task_1)
      assert {:ok, _amount} = Task.await(task_2)
      assert {:error, :too_many_requests_to_receiver} == Task.await(task_3)
    end
  end
end
