defmodule AvoiditWeb.SourcesLive.Show do
  use AvoiditWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"subreddit" => subreddit, "post_id" => post_id}, _uri, socket) do
    {:noreply, get_post(socket, subreddit, post_id)}
  end

  def handle_params(%{"subreddit" => subreddit}, _uri, socket) do
    {:noreply, get_subreddit(socket, subreddit)}
  end

  def handle_params(_params, _uri, socket) do
    socket = socket |> assign(form: to_form(%{"url" => ""})) |> assign(data: nil)
    {:noreply, socket}
  end

  def handle_event("get_subreddit", %{"subreddit" => subreddit}, socket) do
    {:noreply, get_subreddit(socket, subreddit)}
  end

  def handle_event("get_post", %{"subreddit" => subreddit, "post_id" => post_id}, socket) do
    {:noreply, get_post(socket, subreddit, post_id)}
  end

  def get_subreddit(socket, subreddit) do
    socket
    |> assign(subreddit: subreddit)
    |> assign(data: Avoidit.Sources.Reddit.get_posts(subreddit))
    |> assign(type: "subreddit")
  end

  def get_post(socket, subreddit, post_id) do
    socket
    |> assign(subreddit: subreddit)
    |> assign(data: Avoidit.Sources.Reddit.get_post_comments(subreddit, post_id))
    |> assign(type: "post")
  end
end
