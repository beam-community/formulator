defmodule Formulator.HtmlError do
  defstruct class: "",
            html: ""

  @doc """
  Returns a struct with the appropriate error class and html for a form error.

  If there are errors on the given field,
  it will have a class to use in the form field in the `:class` field
  and an appropriate html tag to display the error message
  in the `:html` field.
  """

  @spec html_error(Phoenix.HTML.Form.t(), atom) :: %__MODULE__{}
  def html_error(form, field) do
    case form.errors[field] do
      nil ->
        %__MODULE__{}

      error ->
        %__MODULE__{
          class: "has-error",
          html: Formulator.HtmlBuilder.build_error_span(error, field)
        }
    end
  end
end
