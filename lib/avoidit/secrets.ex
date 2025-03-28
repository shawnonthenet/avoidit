defmodule Avoidit.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Avoidit.Accounts.User, _opts) do
    Application.fetch_env(:avoidit, :token_signing_secret)
  end
end
