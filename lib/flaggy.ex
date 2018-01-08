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

      Flaggy.active?(:new_ui, %{"country_code" => "PL", user_id => 123})

  """
  def active?(feature_atom, meta) when is_atom(feature_atom) do
    feature_string = to_string(feature_atom)

    with {:ok, definition} <- Definition.get(),
         {:ok, feature_def} when is_map(feature_def) <- Map.fetch(definition, feature_string),
         {:ok, base_rule} <- Map.fetch(feature_def, "rules")
    do
      resolution = Rule.satisfied?(base_rule, meta)
      ResolutionLog.push(feature_atom, meta, resolution)
      resolution
    else
      _ -> false
    end
  end
end
