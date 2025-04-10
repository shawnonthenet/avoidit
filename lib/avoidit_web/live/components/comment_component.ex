defmodule AvoiditWeb.CommentComponent do
  use AvoiditWeb, :live_component

  def render(assigns) do
    ~H"""
    <div style="margin-bottom: 16px;">
      <div style={"margin-left: #{@depth * 24}px; position: relative;"}>
        <%= if @depth > 0 do %>
          <%= for i <- 1..@depth do %>
            <div style={"position: absolute; width: 2px; background-color: #e5e7eb; left: #{-24 * (@depth - i + 1)}px; top: 0; bottom: 0;"}>
            </div>
          <% end %>
        <% end %>
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
          <span
            style="font-weight: 600; filter: blur(4px); transition: filter 0.2s;"
            onmouseover="this.style.filter='none'"
            onmouseout="this.style.filter='blur(4px)'"
          >
            {@comment.author}
          </span>
        </div>
        <div style="margin-bottom: 8px; line-height: 1.5;">
          {@comment.body}
        </div>
      </div>
      <%= if @comment.children && length(@comment.children) > 0 do %>
        <div style="margin-top: 16px;">
          <%= for child <- @comment.children do %>
            <.live_component
              module={__MODULE__}
              id={"comment-#{child.author}-#{System.unique_integer()}"}
              comment={child}
              depth={@depth + 1}
            />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
