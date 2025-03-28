defmodule Avoidit.Outbound do
  use Ash.Domain,
    otp_app: :avoidit,
    extensions: [AshPhoenix]

  resources do
    resource Avoidit.Outbound.Email do
      define :create_email, action: :create
      define :update_email, action: :update
      define :read_emails, action: :read
      define :get_email_by_id, action: :read, get_by: :id
    end
  end
end
