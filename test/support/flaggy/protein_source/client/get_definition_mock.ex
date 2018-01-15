defmodule Flaggy.ProteinSource.Client.GetDefinitionMock do
  @moduledoc false

  alias Flaggy.ProteinSource.Client.GetDefinition.{Request, Response}

  def call(%Request{app: "my_app"}) do
    {:ok, %Response{
      definition: """
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
