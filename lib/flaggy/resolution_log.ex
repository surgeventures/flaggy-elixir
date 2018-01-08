defmodule Flaggy.ResolutionLog do
  @moduledoc false

  alias Flaggy.Source

  def push(feature, meta, resolution) do
    source_mod = Source.get()
    source_mod.log(feature, meta, resolution)
  end
end
