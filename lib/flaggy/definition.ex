defmodule Flaggy.Definition do
  @moduledoc false

  alias Flaggy.Source

  def get do
    source_mod = Source.get()
    source_mod.get()
  end

  def update(update_func) do
    source_mod = Source.get()
    source_mod.update(update_func)
  end
end
