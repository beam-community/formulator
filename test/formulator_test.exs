defmodule FormulatorTest do
  use ExUnit.Case
  doctest Formulator
  alias Phoenix.HTML.Form

  describe "input - label" do
    test "a label is created with the field name" do
      [{:safe, label} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name)

      assert label |> to_string == ~s(<label for="_name">Name</label>)
    end

    test "passing the label text option allows for overring the label" do
      [{:safe, label} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, label_text: "Customer Name")

      assert label |> to_string == ~s(<label for="_name">Customer Name</label>)
    end
  end

  describe "input - form input" do
    test "passing classes adds them to the input" do
      [_, {:safe, input} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, class: "customer_name")

        assert input =~ ~s(class="customer_name ")
    end

    test "the :as option allows choosing an input other than text" do
      [_, {:safe, input} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, as: :hidden)

        assert input =~ ~s(type="hidden")
    end
  end
end
