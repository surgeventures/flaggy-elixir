defmodule FlaggyJSONTest do
  use ExUnit.Case
  alias Flaggy.JSONSource

  @sample_file "test/support/flaggy/json_source/sample.json"

  setup do
    Application.put_env(:flaggy, :source, type: :json, file: @sample_file)
    JSONSource.start_link()
    :ok
  end

  describe "active?/2" do
    test "returns true/false depending on rules from JSON file" do
      assert Flaggy.active?(:my_feature, %{"country_code" => "PL"}) == true
      assert Flaggy.active?(:my_feature, %{"country_code" => "AE"}) == true
      assert Flaggy.active?(:my_feature, %{"country_code" => "US"}) == false
    end
  end

  describe "put_feature/2" do
    test "raises" do
      assert_raise RuntimeError, "This source cannot be updated", fn ->
        Flaggy.put_feature(:feature, %{})
      end
    end
  end
end
