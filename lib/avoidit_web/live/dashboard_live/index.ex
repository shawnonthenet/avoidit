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
end
