defmodule FormulatorTest do
  use ExUnit.Case
  doctest Formulator
  import Formulator.Test.Helpers

  describe "input - label" do
    test "a wrapping div is adding for the fields" do
      div_element =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:name, wrapper_class: "my-wrapper")
        |> extract_html
        |> to_string

      assert div_element =~ ~s(<div class="my-wrapper">)
    end

    test "allows configuring the wrapping class in the config" do
      Application.put_env(:formulator, :wrapper_class, "config-wrapper")

      div_element =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:name)
        |> extract_html
        |> to_string

      assert div_element =~ ~s(<div class="config-wrapper">)

      Application.delete_env(:formulator, :wrapper_class)
    end

    test "a label is created with the field name" do
      label =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:name)
        |> extract_html
        |> to_string

      assert label =~ ~s(<label for="fake_name">Name</label>)
    end

    test "passing the label: [text:] option allows for overriding the label" do
      label =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:name, label: [text: "Customer Name"])
        |> extract_html
        |> to_string

      assert label =~ ~s(<label for="fake_name">Customer Name</label>)
    end

    test "passing `label: false` will add `aria-label` to the input" do
      input =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:last_name, label: false)
        |> extract_html
        |> to_string

      assert input =~ ~s(aria-label="Last name")
    end

    test "any options passed to `label` are passed along to the label" do
      label =
        %{name: ""}
        |> prepare_form
        |> Formulator.input(:name, label: [class: "control-label"])
        |> extract_html
        |> to_string

      assert label =~ ~s(<label class="control-label" for="fake_name">Name</label>)
    end

    test "passing the label: 'text' option allows for overriding the label" do
      label =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, label: "Customer Name")
        |> extract_html
        |> to_string

      assert label =~ ~s(<label for="fake_name">Customer Name</label>)
    end
  end
end
