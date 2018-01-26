defmodule Flaggy.MemorySource do
  @moduledoc false

  use GenServer
  alias Flaggy.Source
  defdelegate get_opts(), to: Source

  def start_link(_opts \\ []) do
    features = Keyword.get(get_opts(), :initial_features, %{})
    GenServer.start_link(__MODULE__, features, name: __MODULE__)
  end

  def init(features) do
    {:ok, features}
  end

  def get_features do
    GenServer.call(__MODULE__, :get_features)
  end

  def update_features(update_func) do
    GenServer.cast(__MODULE__, {:update, update_func})
  end

  def log_resolution(_feature, _meta, _resolution) do
    nil
  end

  def handle_call(:get_features, _from, features) do
    {:reply, features, features}
  end

  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_cast({:update, update_func}, features) do
    updated_features = update_func.(features)
    {:noreply, updated_features}
  end
end
