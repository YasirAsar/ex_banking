defmodule ExBanking.Types do
  @moduledoc false

  @type user_pid() :: pid()

  @type user() :: String.t()

  @type amount() :: integer() | float()

  @type currency() :: String.t()
end
