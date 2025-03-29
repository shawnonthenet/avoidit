defmodule AvoiditWeb.RedditLive.Show do
  use AvoiditWeb, :live_view

  on_mount {AvoiditWeb.LiveUserAuth, :live_user_required}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"subreddit" => subreddit, "post_id" => post_id}, _uri, socket) do
    {:noreply, AvoiditWeb.SourcesLive.Show.get_post(socket, subreddit, post_id)}
  end

  def handle_params(%{"subreddit" => subreddit}, _uri, socket) do
    {:noreply, AvoiditWeb.SourcesLive.Show.get_subreddit(socket, subreddit)}
  end
end
