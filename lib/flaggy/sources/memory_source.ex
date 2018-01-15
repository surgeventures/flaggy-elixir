defmodule Flaggy.MemorySource do
  @moduledoc false

  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def update(update_func) do
    GenServer.cast(__MODULE__, {:update, update_func})
  end

  def log(_feature, _meta, _resolution) do
    nil
  end

  def handle_call(:get, _from, definition) do
    {:reply, definition, definition}
  end
  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_cast({:update, update_func}, definition) do
    updated_definition = update_func.(definition)
    {:noreply, updated_definition}
  end
end
