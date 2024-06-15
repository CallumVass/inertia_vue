defmodule InertiaVue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InertiaVueWeb.Telemetry,
      InertiaVue.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:inertia_vue, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:inertia_vue, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: InertiaVue.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: InertiaVue.Finch},
      # Start a worker by calling: InertiaVue.Worker.start_link(arg)
      # {InertiaVue.Worker, arg},
      # Start to serve requests, typically the last entry
      {Inertia.SSR, path: Path.join([Application.app_dir(:inertia_vue), "priv"])},
      InertiaVueWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InertiaVue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InertiaVueWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
