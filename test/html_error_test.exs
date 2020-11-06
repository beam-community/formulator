defmodule Formulator.HtmlErrorTest do
  use ExUnit.Case
  alias Phoenix.HTML.Form
  alias Formulator.HtmlError
  doctest Formulator.HtmlError

  describe "html_error" do
    test "when there are no errors it returns a struct with an empty span tag" do
      form = %Form{errors: []}

      error = HtmlError.html_error(form, :name)

      refute error.class == "has-error"
      {:safe, html} = error.html

      span_tag = ~s(<span id="name-error" class="field-error" data-role="name-error"></span>)
      assert html |> to_string =~ span_tag
    end

    test "when there are errors it returns a struct with a span tag and a class" do
      form = %Form{errors: [name: {"required", []}]}

      error = HtmlError.html_error(form, :name)

      assert error.class == "has-error"
      {:safe, html} = error.html

      span_tag = ~s(<span id="name-error" class="field-error" data-role="name-error">required</span>)
      assert html |> to_string =~ span_tag
    end
  end
end
