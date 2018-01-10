defmodule Flaggy.Protein.Client do
  @moduledoc false

  use Protein.Client

  proto :get_definition
  proto :push_resolution_log
end
