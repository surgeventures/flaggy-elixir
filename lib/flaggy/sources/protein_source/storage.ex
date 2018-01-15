defmodule Flaggy.ProteinSource.Storage do
  @moduledoc false

  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(__MODULE__, [:set, :named_table, {:keypos, 1}, :public, {:read_concurrency, true}])
    :ets.insert(__MODULE__, {:features, %{}})
    {:ok, nil}
  end

  def get_features do
    [{:features, features}] = :ets.lookup(__MODULE__, :features)
    features
  end

  def set_features(new_features) do
    :ets.insert(__MODULE__, {:features, new_features})
  end
end
