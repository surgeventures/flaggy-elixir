defmodule FlaggyProteinTest do
  use ExUnit.Case
  alias Flaggy.ProteinSource

  setup do
    Application.put_env(:flaggy, :source, type: :protein, app: :my_app, transport: [adapter: :http])
    ProteinSource.start_link()
    :timer.sleep(100)
    :ok
  end

  describe "active?/2" do
    test "returns true/false depending on rules from Protein backend" do
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
