defmodule AvoiditWeb.DashboardLive.Index do
  use AvoiditWeb, :live_view

  on_mount {AvoiditWeb.LiveUserAuth, :live_user_required}

  def mount(_params, _session, socket) do
    emails = Avoidit.Outbound.read_emails!(load: [:sources])

    socket =
      socket
      |> assign(:emails, emails)

    {:ok, socket}
  end

  def handle_event("send_test_email", %{"email_id" => email_id}, socket) do
    Avoidit.Outbound.EmailSender.send_email(email_id)

    socket =
      socket
      |> put_flash(:info, "Test email sent")

    {:noreply, socket}
  end
end
