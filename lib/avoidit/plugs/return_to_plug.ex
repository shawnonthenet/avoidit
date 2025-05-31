defmodule AvoidIt.Plugs.ReturnToPlug do
  @moduledoc """
  Plug to capture the return_to query parameter and store it in the session.
  This allows for proper redirection after successful authentication while
  preventing redirect loops to authentication-related pages.

  ## Options

    * `:paths` - A list of paths where the plug should capture the return_to parameter
      default: ["/sign-in"]
    * `:param_name` - The name of the query parameter to capture
      default: "return_to"
    * `:session_key` - The session key where the return path will be stored
      default: :return_to
    * `:blocked_redirect_paths` - A list of paths that should be blocked as return destinations.  This is a starts_with? comparison.
      default: ["/auth", "/password-reset", "/reset", "/register", "/sign-in", "/sign-out"]

  ## Examples

  Using default options:

      # In your router.ex
      pipeline :browser do
        # ...other plugs
        plug YourAppWeb.Plugs.ReturnToPlug
      end

  With custom paths:

      # Capture return_to on multiple paths
      plug YourAppWeb.Plugs.ReturnToPlug, paths: ["/sign-in", "/login", "/register"]

  Fully customized configuration:

      # Custom parameter name, session key, and blocked paths
      plug YourAppWeb.Plugs.ReturnToPlug,
        paths: ["/sign-in", "/login"],
        param_name: "redirect_to",
        session_key: :redirect_after_login,
        blocked_redirect_paths: ["/auth", "/password-reset", "/reset", "/register", "/sign-in", "/sign-out"]
  """
  import Plug.Conn

  @default_options [
    paths: ["/sign-in"],
    param_name: "return_to",
    session_key: :return_to,
    blocked_redirect_paths: [
      "/auth",
      "/password-reset",
      "/reset",
      "/register",
      "/sign-in",
      "/sign-out"
    ]
  ]

  def init(opts) do
    Keyword.merge(@default_options, opts)
  end

  def call(conn, opts) do
    conn = fetch_query_params(conn)

    # Check if current path is in the configured paths
    if matching_path?(conn, opts[:paths]) && has_return_to_param?(conn, opts[:param_name]) do
      # Extract the return_to parameter
      return_to = get_return_to_param(conn, opts[:param_name])

      # Only store it if it's not pointing to a blocked path
      if blocked_return_path?(return_to, opts[:blocked_redirect_paths]) do
        # If blocked, we could either keep the conn unchanged or clear any existing return_to
        # Here we choose to clear it to be extra safe
        delete_session(conn, opts[:session_key])
      else
        put_session(conn, opts[:session_key], return_to)
      end
    else
      conn
    end
  end

  # Checks if the current path matches any of the configured paths
  defp matching_path?(conn, paths) do
    Enum.member?(paths, conn.request_path)
  end

  # Checks if the request has the configured query parameter
  defp has_return_to_param?(conn, param_name) do
    conn.query_params[param_name] != nil
  end

  # Gets the configured parameter value from the query parameters
  defp get_return_to_param(conn, param_name) do
    conn.query_params[param_name]
  end

  # Checks if the return path starts with any of the blocked prefixes
  defp blocked_return_path?(return_path, blocked_redirect_paths) do
    path_to_check = URI.parse(return_path).path

    Enum.any?(blocked_redirect_paths, fn prefix ->
      String.starts_with?(path_to_check, prefix)
    end)
  end
end
