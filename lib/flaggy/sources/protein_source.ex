defmodule Flaggy.ProteinSource do
  @moduledoc false

  use Supervisor
  require Logger
  alias Flaggy.Source
  alias __MODULE__.{Client, Manager, Storage}
  alias Client.LogResolution.Request, as: LogResolutionRequest
  defdelegate get_features(), to: Storage
  defdelegate get_opts(), to: Source

  def start_link(_opts \\ []) do
    Application.put_env(:flaggy, Flaggy.ProteinSource.Client, get_opts())
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([Storage, Client, Manager], strategy: :one_for_one)
  end

  def update_features(_update_func) do
    raise("This source cannot be updated")
  end

  def log_resolution(feature, meta, resolution) do
    Client.push(%LogResolutionRequest{
      app: get_app(),
      feature: to_string(feature),
      meta: Poison.encode!(meta),
      resolution: resolution
    })
  end

  defp get_app do
    get_opts()
    |> Keyword.fetch!(:app)
    |> to_string()
  end
end
