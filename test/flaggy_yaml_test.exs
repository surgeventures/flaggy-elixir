defmodule FlaggyYAMLTest do
  use ExUnit.Case

  setup do
    Application.put_env :flaggy, :source, type: :yaml, file: "test/support/sample.yml"
    Flaggy.YAMLSource.start_link()
    :ok
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

    test "returns true on enabled" do
      assert Flaggy.active?(:my_feature_3, %{}) == true
    end

    test "returns true on proper any + is" do
      assert Flaggy.active?(:my_feature_5, %{"country_code" => "AE"}) == true
    end

    test "returns false on proper any + is with no any match" do
      assert Flaggy.active?(:my_feature_5, %{"country_code" => "XX"}) == false
    end

    test "returns true on proper any + all + in + not" do
      assert Flaggy.active?(:my_feature_5, %{"country_code" => "PL", "provider_id" => 1}) == true
    end

    test "returns false on proper any + all + in + not with invalid not" do
      assert Flaggy.active?(:my_feature_5, %{"country_code" => "PL", "provider_id" => 0}) == false
    end
  end
end
