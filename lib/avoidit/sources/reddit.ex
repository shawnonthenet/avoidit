defmodule Avoidit.Sources.Reddit do
  def get_posts(subreddit, limit \\ 10) do
    url = "https://old.reddit.com/r/#{subreddit}/top.json?limit=#{limit}"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    res = Jason.decode!(body)

    posts =
      Enum.map(res["data"]["children"], fn child ->
        %{
          title: child["data"]["title"],
          url: child["data"]["url"],
          post_id: child["data"]["id"],
          url_overridden_by_dest: child["data"]["url_overridden_by_dest"],
          comments: child["data"]["num_comments"]
        }
      end)

    posts
  end

  def get_post_comments(subreddit, post_id) do
    url = "https://www.reddit.com/r/#{subreddit}/comments/#{post_id}.json"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    [_post_data, comments] = Jason.decode!(body)
    build_comment_tree(comments["data"]["children"])
  end

  defp build_comment_tree(comments) do
    Enum.map(comments, fn comment ->
      case comment do
        %{"kind" => "t1", "data" => data} ->
          replies =
            case data["replies"] do
              "" -> []
              nil -> []
              replies -> replies["data"]["children"] || []
            end

          %{
            body: data["body"],
            author: data["author"],
            children: build_comment_tree(replies)
          }

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end
