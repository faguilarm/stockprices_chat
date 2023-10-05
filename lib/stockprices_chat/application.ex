defmodule StockpricesChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      StockpricesChatWeb.Telemetry,
      # Start the Ecto repository
      StockpricesChat.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: StockpricesChat.PubSub},
      # Start the Endpoint (http/https)
      StockpricesChatWeb.Endpoint
      # Start a worker by calling: StockpricesChat.Worker.start_link(arg)
      # {StockpricesChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockpricesChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockpricesChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
