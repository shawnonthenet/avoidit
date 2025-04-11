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
    email.sources
    |> Task.async_stream(fn s ->
      case s.source do
        "reddit" ->
          data = Avoidit.Sources.Reddit.get_posts(s.sub_source)

          generate_html(%{data: data, subreddit: s.sub_source})
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()

        _ ->
          ""
      end
    end)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, html} -> html end)
    |> Enum.join("\n\n\n")
  end

  defp generate_html(assigns) do
    ~H"""
    <h1>Top posts from #{@subreddit}</h1>
    <table style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr>
          <th style="border-bottom: 1px solid #ddd; padding: 12px 8px;">Title</th>
          <th style="border-bottom: 1px solid #ddd; padding: 12px 8px;">Comments</th>
        </tr>
      </thead>
      <tbody>
        <tr :for={post <- @data} style="border-bottom: 1px solid #ddd;">
          <td style="padding: 12px 8px;">
            <.link href={"#{Application.get_env(:avoidit, Avoidit.Mailer)[:link_domain]}/r/#{@subreddit}/comments/#{post.post_id}"}>
              {post.title}
            </.link>
          </td>
          <td style="padding: 12px 8px;">{post.comments}</td>
        </tr>
      </tbody>
    </table>
    """
  end
end
