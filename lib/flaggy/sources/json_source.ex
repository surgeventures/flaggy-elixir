defmodule Flaggy.JSONSource do
  @moduledoc false

  use GenServer
  alias Flaggy.Source
  defdelegate get_opts(), to: Source

  def start_link(opts \\ []) do
    features = if Keyword.get(opts, :eager_load), do: load_features()
    GenServer.start_link(__MODULE__, features, name: __MODULE__)
  end

  def get_features do
    GenServer.call(__MODULE__, :get_features)
  end

  def update_features(_update_func) do
    raise("This source cannot be updated")
  end

  def log_resolution(_feature, _meta, _resolution) do
    nil
  end

  def handle_call(:get_features, _from, features_or_nil) do
    features = ensure_features(features_or_nil)
    {:reply, features, features}
  end
  def handle_call(request, from, state) do
    super(request, from, state)
  end

  defp ensure_features(nil), do: load_features()
  defp ensure_features(features), do: features

  defp load_features do
    get_opts()
    |> Keyword.fetch!(:file)
    |> File.read!
    |> Poison.decode!
  end
end
