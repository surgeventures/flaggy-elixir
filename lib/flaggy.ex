defmodule Flaggy do
  @moduledoc """
  Multi-source Elixir client for managing feature flags.
  """

  alias __MODULE__.{Definition, ResolutionLog, Rule, Source}

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [supervisor(Source, [])]
    opts = [strategy: :one_for_one, name: Flaggy.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Checks if specific feature is enabled with given client metadata.

  ## Examples

      iex> Flaggy.active?(:new_ui, %{"country" => "PL", "user_id" => 123})
      false

  """
  def active?(feature_atom, meta) when is_atom(feature_atom) do
    feature_string = to_string(feature_atom)

    with {:ok, definition} <- Definition.get(),
         {:ok, feature_def} <- Map.fetch(definition, feature_string),
         :error <- Map.fetch(feature_def, "enabled"),
         {:ok, base_rule} <- Map.fetch(feature_def, "rules")
    do
      resolution = Rule.satisfied?(base_rule, meta)
      ResolutionLog.push(feature_atom, meta, resolution)
      resolution
    else
      {:ok, true} -> true
      _ -> false
    end
  end

  @doc """
  Updates the current definition by putting a new feature's definition into it.

  ## Examples

      iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"attribute" => "country", "is" => "PL"}})
      iex> Flaggy.active?(:my_feature, %{"country" => "PL"})
      true
      iex> Flaggy.active?(:my_feature, %{"country" => "EN"})
      false

  """
  def put_feature(feature_atom, feature_definition) do
    feature_string = to_string(feature_atom)
    Definition.update(fn definition ->
      Map.put(definition, feature_string, feature_definition)
    end)
  end
end
