defmodule AvoiditWeb.CommentComponent do
  use AvoiditWeb, :live_component

  def render(assigns) do
    ~H"""
    <div style="margin-bottom: 16px;">
      <div style={"margin-left: #{@depth * 24}px"}>
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
          <span style="font-weight: 600;">{@comment.author}</span>
          <span style="color: #666;">•</span>
          <span style="color: #666;">1 point</span>
        </div>
        <div style="margin-bottom: 8px; line-height: 1.5;">
          {@comment.body}
        </div>
        <div style="display: flex; gap: 16px;">
          <button style="background: none; border: none; color: #666; cursor: pointer; padding: 4px 8px; font-size: 14px;">
            Reply
          </button>
          <button style="background: none; border: none; color: #666; cursor: pointer; padding: 4px 8px; font-size: 14px;">
            Share
          </button>
          <button style="background: none; border: none; color: #666; cursor: pointer; padding: 4px 8px; font-size: 14px;">
            Report
          </button>
        </div>
      </div>
      <%= if @comment.children && length(@comment.children) > 0 do %>
        <div style="margin-top: 16px;">
          <div style={"width: 2px; background-color: #e5e7eb; margin-left: #{@depth * 24 + 12}px; height: 100%;"}>
          </div>
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
