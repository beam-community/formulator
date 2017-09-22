defmodule FormulatorTest do
  use ExUnit.Case
  doctest Formulator
  alias Phoenix.HTML.Form
  alias Formulator.Test.SampleSchema

  describe "input - label" do
    test "a label is created with the field name" do
      label =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name)
        |> extract_field(:first)
        |> to_string

      assert label == ~s(<label for="_name">Name</label>)
    end

    test "passing the label: [text:] option allows for overriding the label" do
      label =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, label: [text: "Customer Name"])
        |> extract_field(:first)
        |> to_string

      assert label == ~s(<label for="_name">Customer Name</label>)
    end

    test "passing `label: false` will add `aria-label` to the input" do
      input =
        %{last_name: ""}
        |> prepare_form()
        |> Formulator.input(:last_name, label: false)
        |> extract_field(:first)
        |> to_string

      assert input =~ ~s(aria-label="Last name")
    end

    test "any options passed to `label` are passed along to the label" do
      label =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, label: [class: "control-label"])
        |> extract_field(:first)
        |> to_string

      assert label == ~s(<label class="control-label" for="_name">Name</label>)
    end

    test "passing the label: 'text' option allows for overriding the label" do
      label =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, label: "Customer Name")
        |> extract_field(:first)
        |> to_string

      assert label == ~s(<label for="_name">Customer Name</label>)
    end
  end

  describe "input - form input" do
    test "passing classes adds them to the input" do
      input =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, class: "customer_name")
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(class="customer_name")
    end

    test ":as option allows choosing an input other than text" do
      input =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, as: :hidden)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(type="hidden")
    end

    test ":as works with checkbox" do
      input =
        %{admin: ""}
        |> prepare_form()
        |> Formulator.input(:admin, as: :checkbox, class: "foo")
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(type="checkbox")
      assert input =~ ~s(class="foo")
    end

    test ":as works with date" do
      input =
        %{date: DateTime.utc_now}
        |> prepare_form()
        |> Formulator.input(:date, as: :date, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(id="_date_year")
      assert input =~ ~s(class="foo")
    end

    test ":as works with datetime" do
      input =
        %{datetime: DateTime.utc_now}
        |> prepare_form()
        |> Formulator.input(:datetime, as: :datetime, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(id="_datetime_year")
      assert input =~ ~s(class="foo")
    end

    test ":as works with time" do
      input =
        %{time: DateTime.utc_now}
        |> prepare_form()
        |> Formulator.input(:time, as: :time, builder: fn b ->
          b.(:hour, [options: 1..2, class: "foo"])
        end)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(id="_time_hour")
      assert input =~ ~s(class="foo")
    end

    test ":as works with textarea" do
      input =
        %{name: ""}
        |> prepare_form()
        |> Formulator.input(:name, as: :textarea, class: "foo")
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(textarea)
      assert input =~ ~s(class="foo")
    end
  end

  describe "input - validation - required" do
    test "when there is a validation, adds 'required' validation option for given form" do
      input =
        %{name: "Fluff"}
        |> prepare_changeset_form(:validate)
        |> Formulator.input(:name, validate: true)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(required)
    end

    test "when there's not a validation, does not add 'required' validation option for given form" do
      input =
        %{name: "Fluff"}
        |> prepare_changeset_form(:novalidate)
        |> Formulator.input(:name, validate: true)
        |> extract_field(:second)
        |> to_string

      refute input =~ ~s(required)
    end
  end

  describe "input - validation - number" do
    test "when there is a validation, adds 'min' validation option for given form" do
      input =
        %{number: "321"}
        |> prepare_changeset_form(:validate)
        |> Formulator.input(:number, validate: true)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(min)
    end

    test "when there's not a validation, does not add 'min' validation option for given form" do
      input =
        %{number: "321"}
        |> prepare_changeset_form(:novalidate)
        |> Formulator.input(:number, validate: true)
        |> extract_field(:second)
        |> to_string

      refute input =~ ~s(min)
    end
  end

  describe "input - validation - format" do
    test "when there is a validation, adds 'format' validation option for given form" do
      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:validate)
        |> Formulator.input(:email_address, validate_regex: true)
        |> extract_field(:second)
        |> to_string

      assert input =~ ~s(pattern)
    end

    test "when there's not a validation, does not add 'min' validation option for given form" do
      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:novalidate)
        |> Formulator.input(:email_address, validate_regex: true)
        |> extract_field(:second)
        |> to_string

      refute input =~ ~s(pattern)
    end
  end

  defp prepare_form(attrs) do
    %Form{data: attrs}
  end

  defp extract_field(form, :second) do
    [_, {:safe, element} | _] = form
    element
  end
  defp extract_field(form, :first) do
    [{:safe, element} | _] = form
    element
  end

  defp prepare_changeset_form(attrs, :validate), do: prepare_changeset_form(attrs, :validation_changeset)
  defp prepare_changeset_form(attrs, :novalidate), do: prepare_changeset_form(attrs, :no_validation_changeset)
  defp prepare_changeset_form(attrs, changeset) do
    %Form{
      data: %SampleSchema{},
      impl: Phoenix.HTML.FormData.Ecto.Changeset,
      name: SampleSchema,
      source: apply(SampleSchema, changeset, [%SampleSchema{}, attrs])
    }
  end
end
