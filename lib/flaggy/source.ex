defmodule Flaggy.Source do
  @moduledoc false

  use Supervisor
  alias Flaggy.{MemorySource, YAMLSource}

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    source_mod = get()
    source_spec = worker(source_mod, [])

    Supervisor.init([source_spec], strategy: :one_for_one)
  end

  def get do
    source = Application.get_env(:flaggy, :source, [])
    source_type = Keyword.get(source, :type, :memory)

    case source_type do
      :memory -> MemorySource
      :yaml -> YAMLSource
    end
  end
end
