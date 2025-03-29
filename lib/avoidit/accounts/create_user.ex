defmodule Avoidit.Accounts.CreateUser do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(_arg) do
    if Ash.count!(Avoidit.Accounts.User, authorize?: false) == 0 do
      Ash.create(
        Ash.Changeset.for_create(Avoidit.Accounts.User, :register_with_password, %{
          email: Application.get_env(:avoidit, :admin_email),
          password: Application.get_env(:avoidit, :admin_password),
          password_confirmation: Application.get_env(:avoidit, :admin_password)
        }),
        authorize?: false
      )
    end
  end
end
