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

    test "passing the label: [text:] option allows for overriding the label" do
      [{:safe, label} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, label: [text: "Customer Name"])

      assert label |> to_string == ~s(<label for="_name">Customer Name</label>)
    end

    test "passing `label: false` will add `aria-label` to the input" do
      [{:safe, input} | _] = %Form{data: %{last_name: ""}}
        |> Formulator.input(:last_name, label: false)

      assert input |> to_string =~ ~s(aria-label="Last name")
    end

    test "any options passed to `label` are passed along to the label" do
      [{:safe, label} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, label: [class: "control-label"])

      assert label |> to_string == ~s(<label class="control-label" for="_name">Name</label>)
    end

    test "passing the label: 'text' option allows for overriding the label" do
      [{:safe, label} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, label: "Customer Name")

      assert label |> to_string == ~s(<label for="_name">Customer Name</label>)
    end
  end

  describe "input - form input" do
    test "passing classes adds them to the input" do
      [_, {:safe, input} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, class: "customer_name")

      assert input |> to_string =~ ~s(class="customer_name ")
    end

    test "the :as option allows choosing an input other than text" do
      [_, {:safe, input} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, as: :hidden)

      assert input |> to_string =~ ~s(type="hidden")
    end

    test ":as works with checkbox" do
      [_, {:safe, input} | _] = %Form{data: %{admin: ""}}
        |> Formulator.input(:admin, as: :checkbox, class: "foo")

      assert input |> to_string =~ ~s(type="checkbox")
      assert input |> to_string =~ ~s(class="foo ")
    end

    test ":as works with date" do
      [_, {:safe, input} | _] = %Form{data: %{date: DateTime.utc_now}}
        |> Formulator.input(:date, as: :date, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end)

      assert input |> to_string =~ ~s(id="_date_year")
      assert input |> to_string =~ ~s(class="foo")
    end

    test ":as works with datetime" do
      [_, {:safe, input} | _] = %Form{data: %{datetime: DateTime.utc_now}}
        |> Formulator.input(:datetime, as: :datetime, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end)

      input_string = input |> to_string

      assert input_string =~ ~s(id="_datetime_year")
      assert input |> to_string =~ ~s(class="foo")
    end

    test ":as works with time" do
      [_, {:safe, input} | _] = %Form{data: %{time: DateTime.utc_now}}
        |> Formulator.input(:time, as: :time, builder: fn b ->
          b.(:hour, [options: 1..2, class: "foo"])
        end)

      assert input |> to_string =~ ~s(id="_time_hour")
      assert input |> to_string =~ ~s(class="foo")
    end

    test ":as works with textarea" do
      [_, {:safe, input} | _] = %Form{data: %{name: ""}}
        |> Formulator.input(:name, as: :textarea, class: "foo")

      assert input |> to_string =~ ~s(textarea)
      assert input |> to_string =~ ~s(class="foo ")
    end
  end
end
