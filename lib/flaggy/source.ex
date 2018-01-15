defmodule Flaggy.Source do
  @moduledoc false

  use Supervisor
  alias Flaggy.{MemorySource, ProteinSource, JSONSource}

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    type_spec = worker(get_type_mod(), [])

    Supervisor.init([type_spec], strategy: :one_for_one)
  end

  def get_features do
    get_type_mod().get_features()
  end

  def get_type do
    Keyword.get(get_opts(), :type, :memory)
  end

  def get_type_mod do
    case get_type() do
      :memory -> MemorySource
      :protein -> ProteinSource
      :json -> JSONSource
    end
  end

  def get_opts do
    Application.get_env(:flaggy, :source, [])
  end

  def log_resolution(feature, meta, resolution) do
    get_type_mod().log_resolution(feature, meta, resolution)
  end

  def update_features(update_func) do
    get_type_mod().update_features(update_func)
  end
end
