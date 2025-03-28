defmodule Avoidit.Sources.Reddit do

  def get_posts(subreddit, limit \\ 10) do
    url = "https://www.reddit.com/r/#{subreddit}/top.json?limit=#{limit}"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    body
  end

  def get_post_comments(subreddit, post_id) do
    url = "https://www.reddit.com/r/#{subreddit}/comments/#{post_id}.json"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    body
  end

end
