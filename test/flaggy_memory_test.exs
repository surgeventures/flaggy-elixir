defmodule FlaggyMemoryTest do
  use ExUnit.Case
  import Flaggy.Definition

  @my_feature_definition %{
    "rules" => %{
      "attribute" => "country_code",
      "is" => "PL"
    }
  }

  @malformed_feature_definition %{
    "rulesx" => %{
      "attr" => "country_code",
      "yes" => "PL"
    }
  }

  setup do
    Application.put_env :flaggy, :source, type: :memory
    put_feature :my_feature, @my_feature_definition
    put_feature :malformed_feature, @malformed_feature_definition
  end

  describe "active?/2" do
    test "returns false on malformed feature" do
      assert Flaggy.active?(:malformed_feature, %{}) == false
    end

    test "returns false on missing feature" do
      assert Flaggy.active?(:missing_feature, %{}) == false
    end

    test "returns false on missing attribute" do
      assert Flaggy.active?(:my_feature, %{}) == false
    end

    test "returns false on is mismatch" do
      assert Flaggy.active?(:my_feature, %{"country_code" => "EN"}) == false
    end

    test "returns true on is match" do
      assert Flaggy.active?(:my_feature, %{"country_code" => "PL"}) == true
    end
  end
end
