defmodule Avoidit.Sources do
  use Ash.Domain,
    otp_app: :avoidit

  resources do
    resource Avoidit.Sources.Source
  end
end
