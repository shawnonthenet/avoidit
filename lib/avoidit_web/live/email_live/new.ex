defmodule AvoiditWeb.EmailLive.New do
  use AvoiditWeb, :live_view

  on_mount {AvoiditWeb.LiveUserAuth, :live_user_required}

  def mount(_params, _session, socket) do
    form = Avoidit.Outbound.form_to_create_email()

    socket =
      socket
      |> assign(:form, to_form(form))

    {:ok, socket}
  end

  def source_inputs(assigns) do
    ~H"""
    <h2>Sources</h2>
    <table class="w-full">
      <thead>
        <tr>
          <th></th>
          <th>Source</th>
          <th>Sub Source</th>
          <th></th>
        </tr>
      </thead>
      <tbody phx-hook="sourceSort" id="sourceSort">
        <.inputs_for :let={source_form} field={@form[:sources]}>
          <tr data-id={source_form.index}>
            <td><span class="hero-bars-3 handle cursor-pointer" /></td>
            <td>
              <.input field={source_form[:source]} type="select" options={[{"Reddit", "reddit"}]} />
            </td>
            <td><.input field={source_form[:sub_source]} /></td>
            <td><.link phx-click="remove_source" phx-value-path={source_form.name}>Remove</.link></td>
          </tr>
        </.inputs_for>
      </tbody>
    </table>
    <.link phx-click="add_source">Add Source</.link>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.validate(form, form_data)
      end)

    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Email created successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to create email")

        {:noreply, socket}
    end
  end

  def handle_event("add_source", _params, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.add_form(form, :sources)
      end)

    {:noreply, socket}
  end

  def handle_event("remove_source", %{"path" => path}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.remove_form(form, path)
      end)

    {:noreply, socket}
  end

  def handle_event("reorder_sources", %{"order" => order}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.sort_forms(form, [:sources], order)
      end)

    {:noreply, socket}
  end
end
