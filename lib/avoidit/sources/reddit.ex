defmodule Avoidit.Sources.Reddit do
  def get_posts(subreddit, limit \\ 10) do
    client_id = Application.get_env(:avoidit, :reddit_client_id)
    client_secret = Application.get_env(:avoidit, :reddit_client_secret)

    auth = Base.encode64("#{client_id}:#{client_secret}")

    # Get access token
    {:ok, %HTTPoison.Response{body: token_body}} =
      HTTPoison.post(
        "https://www.reddit.com/api/v1/access_token",
        "grant_type=client_credentials",
        [
          {"Authorization", "Basic #{auth}"},
          {"Content-Type", "application/x-www-form-urlencoded"}
        ]
      )

    %{"access_token" => access_token} = Jason.decode!(token_body)

    # Get posts
    url = "https://oauth.reddit.com/r/#{subreddit}/top?limit=#{limit}&t=day"

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        url,
        [
          {"Authorization", "Bearer #{access_token}"},
          {"User-Agent", "Avoidit/1.0"}
        ]
      )

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
    client_id = Application.get_env(:avoidit, :reddit_client_id)
    client_secret = Application.get_env(:avoidit, :reddit_client_secret)

    auth = Base.encode64("#{client_id}:#{client_secret}")

    # Get access token
    {:ok, %HTTPoison.Response{body: token_body}} =
      HTTPoison.post(
        "https://www.reddit.com/api/v1/access_token",
        "grant_type=client_credentials",
        [
          {"Authorization", "Basic #{auth}"},
          {"Content-Type", "application/x-www-form-urlencoded"}
        ]
      )

    %{"access_token" => access_token} = Jason.decode!(token_body)

    # Get post comments
    url = "https://oauth.reddit.com/r/#{subreddit}/comments/#{post_id}"

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        url,
        [
          {"Authorization", "Bearer #{access_token}"},
          {"User-Agent", "Avoidit/1.0"}
        ]
      )

    [post_data, comments] = Jason.decode!(body)
    [format_post_data(post_data), build_comment_tree(comments["data"]["children"])]
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

  def format_post_data(post_data) do
    post = post_data["data"]["children"] |> List.first() |> Map.get("data")

    %{
      title: post["title"],
      content: post["selftext"],
      url: post["url"],
      author: post["author"],
      score: post["score"],
      created_utc: post["created_utc"]
    }
  end
end
