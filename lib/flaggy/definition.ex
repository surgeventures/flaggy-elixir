defmodule Flaggy.Definition do
  @moduledoc """
  Represents a definition of all features managed by configured or default source.
  """

  alias Flaggy.Source

  @doc """
  Returns the current definition.
  """
  def get do
    source_mod = Source.get()
    source_mod.get()
  end

  @doc """
  Updates the current definition by putting a new feature's definition into it.
  """
  def put_feature(feature_atom, feature_definition) do
    feature_string = to_string(feature_atom)
    update(fn definition ->
      Map.put(definition, feature_string, feature_definition)
    end)
  end

  @doc """
  Updates the current definition in arbitrary way.
  """
  def update(update_func) do
    source_mod = Source.get()
    source_mod.update(update_func)
  end
end
