defmodule PollutiondbPhx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PollutiondbPhxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:pollutiondb_phx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PollutiondbPhx.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PollutiondbPhx.Finch},
      # Start a worker by calling: PollutiondbPhx.Worker.start_link(arg)
      # {PollutiondbPhx.Worker, arg},
      # Start to serve requests, typically the last entry
      PollutiondbPhxWeb.Endpoint,
      PollutiondbPhx.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollutiondbPhx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PollutiondbPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
