defmodule ExBanking.ArgumentValidator do
  @moduledoc """
  This module has functions for validating function arguments type.
  """

  @doc """
  Validate create user function arguments.

  ## Examples

  Returns error when passing wrong arguments.

    iex> ExBanking.ArgumentValidator.validate_create_user_args(1)
    {:error, :wrong_arguments}

  Valid arguments

    iex> ExBanking.ArgumentValidator.validate_create_user_args("user")
    true
  """
  def validate_create_user_args(user) do
    with false <- is_valid_user_arg?(user), do: argument_error()
  end

  @doc """
  Validate deposit function arguments.

  ## Examples

  Returns error when passing wrong arguments.

    iex> ExBanking.ArgumentValidator.validate_deposit_args(1, 10, "euro")
    {:error, :wrong_arguments}

    iex> ExBanking.ArgumentValidator.validate_deposit_args("user", "10", "euro")
    {:error, :wrong_arguments}

    iex> ExBanking.ArgumentValidator.validate_deposit_args("user", "10", 1)
    {:error, :wrong_arguments}

  Valid arguments

    iex> ExBanking.ArgumentValidator.validate_deposit_args("user", 10, "euro")
    true
  """
  def validate_deposit_args(user, amount, currency) do
    with false <-
           is_valid_user_arg?(user) and is_valid_amount_arg?(amount) and
             is_valid_currency_arg?(currency),
         do: argument_error()
  end

  @doc """
  Validate withdraw function arguments.

  ## Examples

  Returns error when passing wrong arguments.

    iex> ExBanking.ArgumentValidator.validate_withdraw_args(1, 10, "euro")
    {:error, :wrong_arguments}

    iex> ExBanking.ArgumentValidator.validate_withdraw_args("user", "10", "euro")
    {:error, :wrong_arguments}

    iex> ExBanking.ArgumentValidator.validate_withdraw_args("user", "10", 1)
    {:error, :wrong_arguments}

  Valid arguments

    iex> ExBanking.ArgumentValidator.validate_withdraw_args("user", 10, "euro")
    true
  """
  def validate_withdraw_args(user, amount, currency) do
    with false <-
           is_valid_user_arg?(user) and is_valid_amount_arg?(amount) and
             is_valid_currency_arg?(currency),
         do: argument_error()
  end

  @doc """
  Validate get balance function arguments.

  ## Examples

  Returns error when passing wrong arguments.

    iex> ExBanking.ArgumentValidator.validate_get_balance(1, "euro")
    {:error, :wrong_arguments}

    iex> ExBanking.ArgumentValidator.validate_get_balance("user", 1)
    {:error, :wrong_arguments}

  Valid arguments

    iex> ExBanking.ArgumentValidator.validate_get_balance("user", "euro")
    true
  """
  def validate_get_balance(user, currency) do
    with false <- is_valid_user_arg?(user) and is_valid_currency_arg?(currency),
         do: argument_error()
  end

  @doc """
  Validate send function arguments.

  ## Examples

  Return error when passing wrong arguments.

    iex> ExBanking.ArgumentValidator.validate_send(1, 2, "10", 3)
    {:error, :wrong_arguments}

  Valid arguments

    iex> ExBanking.ArgumentValidator.validate_send("user 1", "user 2", 10, "euro")
    true
  """
  def validate_send(from_user, to_user, amount, currency) do
    with false <-
           is_valid_user_arg?(from_user) and is_valid_user_arg?(to_user) and
             is_valid_amount_arg?(amount) and is_valid_currency_arg?(currency),
         do: argument_error()
  end

  @doc """
  Check user argument type.

  ## Examples

    iex> ExBanking.ArgumentValidator.is_valid_user_arg?(1)
    false

    iex> ExBanking.ArgumentValidator.is_valid_user_arg?("user")
    true
  """
  def is_valid_user_arg?(user), do: is_bitstring(user)

  @doc """
  Check amount argument type.

  ## Examples

    iex> ExBanking.ArgumentValidator.is_valid_amount_arg?("1")
    false

    iex> ExBanking.ArgumentValidator.is_valid_amount_arg?(-1)
    false

    iex> ExBanking.ArgumentValidator.is_valid_amount_arg?(1)
    true
  """
  def is_valid_amount_arg?(number), do: is_number(number) and is_not_negative(number)

  @doc """
  Check currency argument type.

  ## Examples

    iex> ExBanking.ArgumentValidator.is_valid_currency_arg?(1)
    false

    iex> ExBanking.ArgumentValidator.is_valid_currency_arg?("euro")
    true
  """
  def is_valid_currency_arg?(currency), do: is_bitstring(currency)

  defp is_not_negative(number), do: number >= 0
  defp argument_error, do: {:error, :wrong_arguments}
end
