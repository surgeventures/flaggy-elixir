defmodule Flaggy.Source do
  @moduledoc false

  use Supervisor
  alias Flaggy.{MemorySource, ProteinSource, JSONSource}

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    source_mod = get()
    source_spec = worker(source_mod, [])

    Supervisor.init([source_spec], strategy: :one_for_one)
  end

  def get_opts do
    Application.get_env(:flaggy, :source, [])
  end

  def get do
    source_type = Keyword.get(get_opts(), :type, :memory)

    case source_type do
      :memory -> MemorySource
      :protein -> ProteinSource
      :json -> JSONSource
    end
  end
end
