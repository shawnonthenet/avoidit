defmodule Avoidit.Accounts do
  use Ash.Domain,
    otp_app: :avoidit

  resources do
    resource Avoidit.Accounts.Token
    resource Avoidit.Accounts.User
  end
end
