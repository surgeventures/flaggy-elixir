defmodule Flaggy.ProteinSource.Client do
  @moduledoc false

  use Protein.Client

  proto :get_definition
  proto :log_resolution
end
