defmodule Formulator do
  use Phoenix.HTML
  alias Formulator.HtmlError

  @doc  """
  Returns an html input with an associated label.
  If there are errors associated with the field, it will also output a span
  tag with the errors.

  ## Options

    * `:label` - When given a string, that string is used as the label text.
    When false, does not create a label tag. Instead, an `aria-label`
    attribute is added to the input to improve accessibility.

  ## Examples

  Basic input:
      <%= input form, :email %>
      #=> <label for="user_email">Email</label>
      #=> <input id="user_name" name="user[email]" type="text" value="">

  Without a label:
      <%= input form, :email, label: false %>
      #=> <input id="user_name" name="user[email]" aria-label="email" type="text" value="">
  """

  @spec input(Phoenix.HTML.Form.t, atom, []) :: binary
  def input(form, field, options \\ []) do
    cond do
      {:label, false} in options -> input_without_label(form, field, options)
      true -> input_with_label(form, field, options)
    end
  end

  defp input_without_label(form, field, options) do
    options = options ++ build_aria_label(field)
    error = html_error(form, field)
    [
      build_input(form, field, options, error)
    ] ++ error.html
  end

  defp input_with_label(form, field, options) do
    error = html_error(form, field)
    build_html(form, field, options, error)
  end

  defp build_aria_label(field) do
    ["aria-label": format_label(field)]
  end

  defp format_label(field) do
    field |> to_string |> String.replace("_", " ") |> String.capitalize
  end

  defp build_html(form, field, options, error) do
    [
      build_label(form, field, options),
      build_input(form, field, options, error)
    ] ++ error.html
  end

  defp build_input(form, field, options, error) do
    input_type = options[:as] || :text
    input_class = options[:class] || ""
    options = options
    |> Dict.delete(:as)
    |> Dict.put(:class, add_error_class(input_class, error.class))

    apply(Phoenix.HTML.Form, input_function(input_type), [form, field, options])
  end

  defp add_error_class(input_class, error_class) do
    "#{input_class} #{error_class}"
  end

  def build_label(form, field, options) do
    case options[:label] do
      nil -> label(form, field)
      label_text -> label(form, field, label_text)
    end
  end

  defp html_error(form, field) do
    case form.errors[field] do
      nil ->
        %HtmlError{}
      error ->
        %HtmlError{class: "has-error", html: build_html(error, field)}
    end
  end

  defp build_html(error, field) do
    content_tag :span,
    translate_error(error),
    class: "field-error",
    "data-role": "#{field}-error"
  end

  def translate_error({msg, opts}) do
    case opts[:count] do
      nil -> Gettext.dgettext(gettext, "errors", msg, opts)
      count -> Gettext.dngettext(gettext, "errors", msg, msg, count, opts)
    end
  end

  defp input_function(:textarea), do: :textarea
  defp input_function(input_type), do: :"#{input_type}_input"

  defp gettext do
    Application.get_env(:formulator, :gettext)
  end
end
