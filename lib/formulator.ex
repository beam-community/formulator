defmodule Formulator do
  use Phoenix.HTML
  alias Formulator.HtmlError

  def input(form, field, options \\ []) do
    error = html_error(form, field)
    build_html(form, field, options, error)
  end

  defp build_html(form, field, options, error) do
    input_type = options[:as] || :text
    input_class = options[:class] || ""
    options = options
    |> Dict.delete(:as)
    |> Dict.put(:class, add_error_class(input_class, error.class))

    [
      build_label(form, field, options[:label_text]),
      apply(Phoenix.HTML.Form, input_function(input_type), [form, field, options]),
    ] ++ error.html
  end

  defp add_error_class(input_class, error_class) do
    "#{input_class} #{error_class}"
  end

  def build_label(form, field, nil), do: label(form, field)
  def build_label(_, _, false), do: ""
  def build_label(form, field, label_text), do: label(form, field, label_text)

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
