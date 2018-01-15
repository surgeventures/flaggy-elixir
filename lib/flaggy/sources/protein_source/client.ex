defmodule Flaggy.ProteinSource.Client do
  @moduledoc false

  use Protein.Client

  proto :get_features
  proto :log_resolution
end
