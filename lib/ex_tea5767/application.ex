defmodule ExTea5767.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, i2c_bus_name \\ "i2c-0") do
    children = [
      # Starts a worker by calling: ExTea5756.Worker.start_link(arg)
      { ExTea5767.State, %{bus_name: i2c_bus_name} }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExTea5756.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
