defmodule Flaggy.Rule do
  @moduledoc false

  def satisfied?(%{"all" => nested_rules}, meta) do
    Enum.all?(nested_rules, &satisfied?(&1, meta))
  end

  def satisfied?(%{"any" => nested_rules}, meta) do
    Enum.any?(nested_rules, &satisfied?(&1, meta))
  end

  def satisfied?(%{"not" => nested_rule}, meta) do
    not satisfied?(nested_rule, meta)
  end

  def satisfied?(%{"is" => value, "attribute" => attribute}, meta) do
    fetch_or_false(meta, attribute, &(&1 == value))
  end

  def satisfied?(%{"in" => values, "attribute" => attribute}, meta) do
    fetch_or_false(meta, attribute, &(&1 in values))
  end

  def satisfied?(_invalid, _meta) do
    false
  end

  def fetch_or_false(meta, attribute, callback) do
    case Map.fetch(meta, attribute) do
      {:ok, value} ->
        callback.(value)

      :error ->
        false
    end
  end
end
