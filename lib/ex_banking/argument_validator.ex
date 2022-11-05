defmodule ExBanking.ArgumentValidator do
  def validate_create_user_args(user) do
    with false <- is_valid_user_arg?(user), do: argument_error()
  end

  def validate_deposit_args(user, amount, currency) do
    with false <-
           is_valid_user_arg?(user) and is_valid_amount_arg?(amount) and
             is_valid_currency_arg?(currency),
         do: argument_error()
  end

  def validate_withdraw_args(user, amount, currency) do
    with false <-
           is_valid_user_arg?(user) and is_valid_amount_arg?(amount) and
             is_valid_currency_arg?(currency),
         do: argument_error()
  end

  def validate_get_balance(user, currency) do
    with false <- is_valid_user_arg?(user) and is_valid_currency_arg?(currency),
         do: argument_error()
  end

  def validate_send(from_user, to_user, amount, currency) do
    with false <-
           is_valid_user_arg?(from_user) and is_valid_user_arg?(to_user) and
             is_valid_amount_arg?(amount) and is_valid_currency_arg?(currency),
         do: argument_error()
  end

  defp is_valid_user_arg?(user), do: is_bitstring(user)
  defp is_valid_amount_arg?(number), do: is_number(number) and is_not_negative(number)
  defp is_valid_currency_arg?(currency), do: is_bitstring(currency)

  defp is_not_negative(number), do: number >= 0

  defp argument_error, do: {:error, :wrong_arguments}
end
