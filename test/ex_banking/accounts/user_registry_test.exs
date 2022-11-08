defmodule ExBanking.Accounts.UserRegistryTest do
  use ExUnit.Case

  alias ExBanking.Accounts.UserRegistry
  alias ExBanking.Accounts.UserSupervisor

  @user "user"

  describe "create_user/1" do
    test "if user created, return {ok, pid}" do
      assert {:ok, pid} = UserRegistry.create_user(@user)

      on_exit(fn ->
        DynamicSupervisor.terminate_child(UserSupervisor, pid)
      end)
    end
  end

  describe "delete_user/1" do
    test "if user existed, delete it" do
      {:ok, pid} = UserRegistry.create_user(@user)
      assert :ok == DynamicSupervisor.terminate_child(UserSupervisor, pid)

      # Check user deleted
      assert {:error, :not_found} == DynamicSupervisor.terminate_child(UserSupervisor, pid)
    end
  end

  describe "lookup_user/1/2" do
    setup do
      {:ok, pid} = UserRegistry.create_user(@user)

      on_exit(fn ->
        DynamicSupervisor.terminate_child(UserSupervisor, pid)
      end)
    end

    test "if user existed, return {:ok, pid}" do
      assert {:ok, _pid} = UserRegistry.lookup_user(@user)
    end

    test "if user not existed, return user not existed error" do
      assert {:error, :user_does_not_exist} == UserRegistry.lookup_user("123")
    end

    test "if sender not existed, return sender not existed error" do
      assert {:error, :sender_does_not_exist} == UserRegistry.lookup_user("123", :sender)
    end

    test "if receiver not existed, return receiver not existed error" do
      assert {:error, :receiver_does_not_exist} == UserRegistry.lookup_user("123", :receiver)
    end
  end

  describe "check_user_existence/1" do
    setup do
      {:ok, pid} = UserRegistry.create_user(@user)

      on_exit(fn ->
        DynamicSupervisor.terminate_child(UserSupervisor, pid)
      end)
    end

    test "if user already existed, return user does not exist error" do
      assert {:error, :user_already_exists} == UserRegistry.check_user_existence(@user)
    end

    test "if user not existed, return user not existed error" do
      assert {:error, :user_does_not_exist} == UserRegistry.check_user_existence("123")
    end
  end
end
