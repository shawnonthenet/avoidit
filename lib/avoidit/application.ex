defmodule Avoidit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AvoiditWeb.Telemetry,
      Avoidit.Repo,
      {DNSCluster, query: Application.get_env(:avoidit, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:avoidit, :ash_domains),
         Application.fetch_env!(:avoidit, Oban)
       )},
      # Start the Finch HTTP client for sending emails
      # Start a worker by calling: Avoidit.Worker.start_link(arg)
      # {Avoidit.Worker, arg},
      # Start to serve requests, typically the last entry
      {Phoenix.PubSub, name: Avoidit.PubSub},
      {Finch, name: Avoidit.Finch},
      AvoiditWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :avoidit]},
      {Avoidit.Accounts.CreateUser, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Avoidit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AvoiditWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
