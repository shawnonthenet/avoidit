defmodule Avoidit.Outbound.DailyEmail do
  import Swoosh.Email
  use Phoenix.LiveView

  def daily_email(email) do
    new()
    |> to(email.email_address)
    |> from(Application.get_env(:avoidit, Avoidit.Mailer)[:from])
    |> subject(email.title)
    |> html_body(build_email_contents(email))
    |> Avoidit.Mailer.deliver!()
  end

  defp build_email_contents(email) do
    Enum.map(email.sources, fn s ->
      case s.source do
        "reddit" ->
          data = Avoidit.Sources.Reddit.get_posts(s.sub_source)
          generate_html(%{data: data, subreddit: s.sub_source}) |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()

        _ ->
          ""
      end
    end)
    |> Enum.join("\n\n\n")
  end

  defp generate_html(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Title</th>
          <th>Comments</th>
        </tr>
      </thead>
      <tbody>
        <tr :for={post <- @data}>
          <td>
            <.link href={"#{Application.get_env(:avoidit, Avoidit.Mailer)[:link_domain]}/sources/get/?subreddit=#{@subreddit}&post_id=#{post.post_id}"}>
              {post.title}
            </.link>
          </td>
          <td>{post.comments}</td>
        </tr>
      </tbody>
    </table>
    """
  end
end
