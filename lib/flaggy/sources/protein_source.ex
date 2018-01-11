defmodule Flaggy.ProteinSource do
  @moduledoc false

  use Supervisor
  require Logger
  alias __MODULE__.{Client, Manager}
  alias Client.LogResolution.Request, as: LogRequest

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    client_spec = supervisor(Client, [])
    manager_spec = worker(Manager, [])

    Supervisor.init([client_spec, manager_spec], strategy: :one_for_one)
  end

  def get do
    Manager.get()
  end

  def update(_update_func) do
    raise("This source cannot be updated")
  end

  def log(feature, meta, resolution) do
    Client.push(%LogRequest{
      app: get_app(),
      feature: feature,
      meta: meta,
      resolution: resolution
    })
  end

  defp get_app do
    :flaggy
    |> Application.get_env(:source, [])
    |> Keyword.fetch!(:app)
  end
end
