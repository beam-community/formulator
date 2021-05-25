defmodule Formulator.InputTest do
  use ExUnit.Case
  doctest Formulator.Input
  alias Formulator.Input
  import Formulator.Test.Helpers

  describe "build_input - form input" do
    test "passing classes adds them to the input" do
      input =
        %{name: ""}
        |> prepare_form
        |> Input.build_input(:name, [class: "customer_name"], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(class="customer_name")
    end

    test ":as option allows choosing an input other than text" do
      input =
        %{name: ""}
        |> prepare_form
        |> Input.build_input(:name, [as: :hidden], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(type="hidden")
    end

    test ":as works with checkbox" do
      input =
        %{admin: ""}
        |> prepare_form()
        |> Input.build_input(:admin, [as: :checkbox, class: "foo"], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(type="checkbox")
      assert input =~ ~s(class="foo")
    end

    test ":as works with date" do
      input =
        %{date: DateTime.utc_now}
        |> prepare_form()
        |> Input.build_input(:date, [as: :date, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(id="_date_year")
      assert input =~ ~s(class="foo")
    end

    test ":as works with datetime" do
      input =
        %{datetime: DateTime.utc_now}
        |> prepare_form()
        |> Input.build_input(:datetime, [as: :datetime, builder: fn b ->
          b.(:year, [options: 2017..2021, class: "foo"])
        end], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(id="_datetime_year")
      assert input =~ ~s(class="foo")
    end

    test ":as works with time" do
      input =
        %{time: DateTime.utc_now}
        |> prepare_form()
        |> Input.build_input(:time, [as: :time, builder: fn b ->
          b.(:hour, [options: 1..2, class: "foo"])
        end], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(id="_time_hour")
      assert input =~ ~s(class="foo")
    end

    test ":as works with textarea" do
      input =
        %{name: ""}
        |> prepare_form()
        |> Input.build_input(:name, [as: :textarea, class: "foo"], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(textarea)
      assert input =~ ~s(class="foo")
    end
  end

  describe "build_input - validation - required" do
    test "when there is a validation, adds 'required' validation option for given form" do
      input =
        %{name: "Fluff"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:name, [validate: true], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(required)
    end

    test "when there's not a validation, does not add 'required' validation option for given form" do
      input =
        %{name: "Fluff"}
        |> prepare_changeset_form(:novalidate)
        |> Input.build_input(:name, [validate: true], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(required)
    end
  end

  describe "build_input - validation - number" do
    test "when there is a validation, and the application config is false, do not add validation to input" do
      Application.put_env(:formulator, :validate, false)
      input =
        %{number: "321"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:number, [], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(min)

      Application.delete_env(:formulator, :validate)
    end

    test "when there is a validation, adds 'min' validation option for given form" do
      input =
        %{number: "321"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:number, [validate: true], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(min)
    end

    test "when there's not a validation, does not add 'min' validation option for given form" do
      input =
        %{number: "321"}
        |> prepare_changeset_form(:novalidate)
        |> Input.build_input(:number, [validate: true], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(min)
    end
  end

  describe "build_input - validation - format" do
    test "when there is a validation, and the application config is false, do not add validation to input" do
      Application.put_env(:formulator, :validate_regex, false)
      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:email_address, [], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(pattern)

      Application.delete_env(:formulator, :validate_regex)
    end

    test "when there is a validation, adds 'format' validation option for given form" do
      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:email_address, [validate_regex: true], [])
        |> extract_html
        |> to_string

      assert input =~ ~s(pattern)
    end

    test "when there is a validation, but validate_regex is false, does not add 'format' validation option for given form" do
      Application.put_env(:formulator, :validate_regex, true)

      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:validate)
        |> Input.build_input(:email_address, [validate_regex: false], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(pattern)

      Application.delete_env(:formulator, :validate_regex)
    end

    test "when there's not a validation, does not add 'format' validation option for given form" do
      input =
        %{email: "test@domain.com"}
        |> prepare_changeset_form(:novalidate)
        |> Input.build_input(:email_address, [validate_regex: true], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(pattern)
    end
  end

  describe "build_input - validation - conn" do
    test "ignores validations for conn sourced forms" do
      input =
        %{email: "test_domain.com"}
        |> prepare_conn_form
        |> Input.build_input(:email_address, [validate_regex: true], [])
        |> extract_html
        |> to_string

      refute input =~ ~s(pattern)
    end
  end
end
