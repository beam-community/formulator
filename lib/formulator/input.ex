defmodule Formulator.Input do
  use Phoenix.HTML
  alias Formulator.HtmlError

  def build_input(form, field, options, label_options, error \\ %HtmlError{}) do
    options = options ++ build_aria_label(field, label_options)
    input_type = options[:as] || :text
    input_class = options[:class] || ""

    options =
      options
      |> add_validation_attributes(form, field)
      |> add_format_validation_attribute(form, field)
      |> Keyword.delete(:as)
      |> Keyword.put(:class, add_error_class(input_class, error.class))
      |> add_aria_describedby(form, field)

    apply(Phoenix.HTML.Form, input_function(input_type), [form, field, options])
  end

  defp add_validation_attributes(options, %{impl: impl, source: %{validations: _}} = form, field)
       when is_atom(impl) do
    if option_enabled?(options, :validate, true) do
      form
      |> Phoenix.HTML.Form.input_validations(field)
      |> Keyword.merge(options)
      |> Keyword.delete(:validate)
    else
      options
    end
  end

  defp add_validation_attributes(options, _, _), do: options

  defp add_format_validation_attribute(
         options,
         %{impl: impl, source: %{validations: _}} = form,
         field
       )
       when is_atom(impl) do
    with true <- option_enabled?(options, :validate_regex, true),
         {:format, regex} <- form.source.validations[field] do
      options
      |> Keyword.put_new(:pattern, Regex.source(regex))
      |> Keyword.delete(:validate_regex)
    else
      _ -> options
    end
  end

  defp add_format_validation_attribute(options, _, _), do: options

  defp option_enabled?(options, field, default) do
    cond do
      Keyword.get(options, field) == false -> false
      Keyword.get(options, field) == true -> true
      Application.get_env(:formulator, field, default) == true -> true
      true -> false
    end
  end

  defp add_error_class(input_class, error_class) do
    [input_class, error_class]
    |> Enum.reject(&is_nil(&1))
    |> Enum.join(" ")
    |> String.trim()
  end

  defp add_aria_describedby(options, form, field) do
    case form.errors[field] do
      nil -> options
      _error -> options |> Keyword.put(:aria_describedby, "#{field}-error")
    end
  end

  defp build_aria_label(field, label_options) do
    cond do
      label_options == false -> ["aria-label": format_label(field)]
      true -> []
    end
  end

  defp format_label(field) do
    field |> to_string |> String.replace("_", " ") |> String.capitalize()
  end

  defp input_function(:checkbox), do: :checkbox
  defp input_function(:date), do: :date_select
  defp input_function(:datetime), do: :datetime_select
  defp input_function(:time), do: :time_select
  defp input_function(:textarea), do: :textarea
  defp input_function(input_type), do: :"#{input_type}_input"
end
