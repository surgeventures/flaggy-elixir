defmodule Flaggy.ProteinSource.Manager do
  @moduledoc false

  use GenServer
  require Logger
  alias Flaggy.Source
  alias Flaggy.ProteinSource.Client
  alias Client.GetDefinition.{Request, Response}

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(__MODULE__, [:set, :named_table, {:keypos, 1}, :public, {:read_concurrency, true}])
    :ets.insert(__MODULE__, {:definition, %{}})
    Process.send(__MODULE__, :load, [])

    {:ok, nil}
  end

  def get do
    [{:definition, definition}] = :ets.lookup(__MODULE__, :definition)
    definition
  end

  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_info(:load, _state) do
    %Response{definition: encoded_definition} = Client.call!(%Request{app: get_app()})
    definition = Poison.decode!(encoded_definition)
    :ets.insert(__MODULE__, {:definition, definition})
    Process.send_after(__MODULE__, :load, get_refresh_interval())

    {:noreply, nil}
  end

  defp get_source_opts do
    Source.get_opts()
  end

  defp get_refresh_interval do
    Keyword.get(get_source_opts(), :refresh_interval, 60_000)
  end

  defp get_app do
    get_source_opts()
    |> Keyword.fetch!(:app)
    |> to_string()
  end
end
