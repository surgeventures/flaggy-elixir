defmodule Flaggy.ProteinSource.Client.GetFeaturesMock do
  @moduledoc false

  alias Flaggy.ProteinSource.Client.GetFeatures.{Request, Response}

  def call(%Request{app: "my_app"}) do
    {:ok, %Response{
      features: """
      {
        "my_feature": {
          "rules": {
            "attribute": "country_code",
            "in": ["AE", "PL"]
          }
        }
      }
      """
    }}
  end
end
