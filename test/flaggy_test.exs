defmodule FlaggyMemoryTest do
  use ExUnit.Case
  doctest Flaggy

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
    Application.put_env(:flaggy, :source, type: :memory)
    Flaggy.put_feature(:my_feature, @my_feature_definition)
    Flaggy.put_feature(:malformed_feature, @malformed_feature_definition)
  end

  describe "active?/2" do
    test "returns false on missing feature" do
      assert Flaggy.active?(:missing_feature, %{}) == false
    end

    test "returns false on malformed feature" do
      assert Flaggy.active?(:malformed_feature, %{}) == false
    end

    test "returns false on missing attribute" do
      assert Flaggy.active?(:my_feature, %{}) == false
    end

    test "returns true on enabled" do
      Flaggy.put_feature(:my_feature, %{"enabled" => true})
      assert Flaggy.active?(:my_feature, %{}) == true
    end

    test "returns true/false depending on 'is' rule" do
      Flaggy.put_feature(:my_feature, %{"rules" => %{"attribute" => "x", "is" => "y"}})
      assert Flaggy.active?(:my_feature, %{"x" => "y"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "z"}) == false
    end

    test "returns true/false depending on 'in' rule" do
      Flaggy.put_feature(:my_feature, %{"rules" => %{"attribute" => "x", "in" => ["y", "z"]}})
      assert Flaggy.active?(:my_feature, %{"x" => "y"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "z"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "x"}) == false
    end

    test "returns true/false depending on 'all' rule" do
      Flaggy.put_feature(:my_feature, %{"rules" => %{"all" => [
        %{
          "attribute" => "x",
          "is" => "y"
        },
        %{
          "attribute" => "a",
          "is" => "b"
        }
      ]}})
      assert Flaggy.active?(:my_feature, %{"x" => "y", "a" => "b"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "y"}) == false
      assert Flaggy.active?(:my_feature, %{"a" => "b"}) == false
      assert Flaggy.active?(:my_feature, %{"x" => "z", "a" => "b"}) == false
    end

    test "returns true/false depending on 'any' rule" do
      Flaggy.put_feature(:my_feature, %{"rules" => %{"any" => [
        %{
          "attribute" => "x",
          "is" => "y"
        },
        %{
          "attribute" => "a",
          "is" => "b"
        }
      ]}})
      assert Flaggy.active?(:my_feature, %{"x" => "y", "a" => "b"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "y"}) == true
      assert Flaggy.active?(:my_feature, %{"a" => "b"}) == true
      assert Flaggy.active?(:my_feature, %{"x" => "z", "a" => "c"}) == false
    end

    test "returns true/false depending on 'not' rule" do
      Flaggy.put_feature(:my_feature, %{"rules" => %{"not" => %{
        "attribute" => "x",
        "is" => "y"
      }}})
      assert Flaggy.active?(:my_feature, %{"x" => "y"}) == false
      assert Flaggy.active?(:my_feature, %{"x" => "z"}) == true
      assert Flaggy.active?(:my_feature, %{"a" => "b"}) == true
      assert Flaggy.active?(:my_feature, %{}) == true
    end
  end

  describe "put_feature/2" do
    test "creates new feature" do
      Flaggy.put_feature(:absolutely_unique_feature, %{"enabled" => true})
      assert Flaggy.active?(:absolutely_unique_feature, %{}) == true
    end

    test "updates existing feature" do
      Flaggy.put_feature(:my_feature, %{"enabled" => true})
      assert Flaggy.active?(:my_feature, %{}) == true
      Flaggy.put_feature(:my_feature, %{"enabled" => false})
      assert Flaggy.active?(:my_feature, %{}) == false
    end
  end
end
