defmodule Formulator.HtmlErrorTest do
  use ExUnit.Case
  alias Phoenix.HTML.Form
  alias Formulator.HtmlError
  doctest Formulator.HtmlError

  describe "html_error" do
    test "when there are no errors it returns an empty struct" do
      form = %Form{errors: []}

      assert HtmlError.html_error(form, :name) == %HtmlError{}
    end

    test "when there are errors it returns a struct with a span tag and a class" do
      form = %Form{errors: [name: {"required", []}]}

      error = HtmlError.html_error(form, :name)

      assert error.class == "has-error"
      {:safe, html} = error.html

      span_tag = ~s(<span class="field-error" data-role="name-error" id="name-error">required</span>)
      assert html |> to_string =~ span_tag
    end
  end
end
