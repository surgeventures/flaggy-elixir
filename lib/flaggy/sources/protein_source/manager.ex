defmodule Flaggy.ProteinSource.Manager do
  @moduledoc false

  use GenServer
  require Logger
  alias Flaggy.Source
  alias Flaggy.ProteinSource.{Client, Storage}
  alias Client.GetFeatures.{Request, Response}
  defdelegate get_opts(), to: Source

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Process.send(__MODULE__, :load, [])
    {:ok, nil}
  end

  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_info(:load, _state) do
    try do
      %Response{features: encoded_features} = Client.call!(%Request{app: get_app()})
      features = Poison.decode!(encoded_features)
      Storage.set_features(features)
      Process.send_after(__MODULE__, :load, get_refresh_interval())
      {:noreply, nil}
    rescue
      e in Protein.TransportError ->
        Logger.error("Failed to load features due to Protein transport error (#{Exception.message(e)})")
        Process.send_after(__MODULE__, :load, get_retry_interval())
        {:noreply, nil}
    end
  end

  defp get_refresh_interval do
    Keyword.get(get_opts(), :refresh_interval, 60_000)
  end

  defp get_retry_interval do
    Keyword.get(get_opts(), :retry_interval, 5_000)
  end

  defp get_app do
    get_opts()
    |> Keyword.fetch!(:app)
    |> to_string()
  end
end
