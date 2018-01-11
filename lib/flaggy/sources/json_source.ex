defmodule Flaggy.JSONSource do
  @moduledoc false

  use GenServer
  alias Flaggy.Source

  def start_link(opts \\ []) do
    definition = if Keyword.get(opts, :eager_load), do: load_definition()
    GenServer.start_link(__MODULE__, definition, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def update(_update_func) do
    raise("This source cannot be updated")
  end

  def log(_feature, _meta, _resolution) do
    nil
  end

  def handle_call(:get, _from, definition_or_nil) do
    definition = ensure_definition(definition_or_nil)
    {:reply, definition, definition}
  end
  def handle_call(request, from, state) do
    super(request, from, state)
  end

  defp ensure_definition(nil), do: load_definition()
  defp ensure_definition(definition), do: definition

  defp load_definition do
    Source.get_opts()
    |> Keyword.fetch!(:file)
    |> File.read!
    |> Poison.decode!
  end
end
