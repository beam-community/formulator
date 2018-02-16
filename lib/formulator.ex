defmodule Formulator do
  use Phoenix.HTML
  alias Formulator.HtmlError

  @doc  """
  Returns an html input with an associated label.
  If there are errors associated with the field, it will also output a span
  tag with the errors.

  ## Options

    * `:label` - When given a keyword list, the keyword `text` is extracted to
    use as the label text. All other options are passed along to the label.
    When given `false`, does not create a label tag. Instead, an `aria-label`
    attribute is added to the input to improve accessibility.

    * `:validate` - Defaults to application config. When provided a form created with an
    Ecto changeset that contains validations, then Formulator will add HTML5
    validation attributes (except regex).

    * `:validate_regex` - Defaults to application config. Like option `:validate`, except
    this will add a pattern HTML5 validation. This should work with most simple
    regex patterns, but the browser's regex engine may differ from Erlang's.

  * `:wrapper_class` - This allows you to add a class to the div
    that wraps the input and label. This can also be set in your config:
    `config :formulator, wrapper_class: "input-wrapper"


  ## Examples

  Basic input:
      <%= input form, :name %>
      #=> <div>
      #=>   <label for="user_name">Name</label>
      #=>   <input id="user_name" name="user[name]" type="text" value="">
      #=> </div>

  Without a label:
      <%= input form, :name, label: false %>
      #=> <div>
      #=>   <input id="user_name" name="user[name]" aria-label="name" type="text" value="">
      #=> </div>

  Passing other options:
      <%= input form, :name, label: [class: "control-label"] %>
      #=> <div>
      #=>   <label class="control-label" for="user_name">Name</label>
      #=>   <input id="user_name" type="text" name="user[name]" value="">
      #=> </div>

  Using different input types:
      <%= input form, :email_address,
          as: :email,
          placeholder: "your@email.com",
          class: "my-email-class",
          label: [class: "my-email-label-class"] %>
      #=> <div>
      #=>   <label
             class="my-email-label-class"
             for="user_email_address">Email Address</label>
      #=>   <input
             id="user_email_address"
             type="email"
             name="user[email_address]"
             placeholder: "your@email.com"
             value=""
             class="my-email-class">
      #=> </div>

  Or a number input:
      <%= input form, :count, as: :number %>
      #=> <div>
      #=>   <label for="asset_count">Count</label>
      #=>   <input id="asset_count" type="number" name="asset[count]" value="">
      #=> <div>

  If your form is using a changeset with validations (eg, with `Ecto` and `phoenix_ecto`),
  then Formulator will add HTML5 validation attributes:
      <%= input form, :email, as: :email %>
      #=> <div>
      #=>   <label for="user_email">Email</label>
      #=>   <input id="user_email" type="email" name="user[email]" required="required" pattern=".+@.+" %>
      #=> <div>

  If you would rather not add HTML5 validation attributes, you can opt out
  by supplying `validate: false`:
      <%= input form, :email, as: :email, validate: false %>
      #=> <div>
      #=>   <label for="user_email">Email</label>
      #=>   <input id="user_email" type="email" name="user[email]" %>
      #=> </div>

  You may want HTML5 validations, but the browser's regex engine is not
  working with Elixir's regex engine. You can opt-out of regex validation
  with `validate_regex: false`:
      <%= input form, :email, as: :email, validate_regex: false %>
      #=> <div>
      #=>   <label for="user_email">Email</label>
      #=>   <input id="user_email" type="email" name="user[email]" required="required" %>
      #=> </div>
  """

  @spec input(Phoenix.HTML.Form.t, atom, []) :: binary
  def input(form, field, options \\ []) do
    form
    |> build_input_and_associated_tags(field, options)
    |> add_wrapper(options)
  end

  defp build_input_and_associated_tags(form, field, options) do
    {label_options, options} = extract_label_options(options)
    case label_options do
      false -> input_without_label(form, field, options)
      _ -> input_with_label(form, field, label_options, options)
    end
  end

  defp add_wrapper(html, options) do
    [content_tag(:div, html, class: wrapper_class(options))]
  end

  defp wrapper_class(options) do
    options[:wrapper_class] || Application.get_env(:formulator, :wrapper_class)
  end

  defp extract_label_options(options) do
    label_options = options |> Keyword.get(:label, [])
    options = options |> Keyword.delete(:label)

    {label_options, options}
  end

  defp input_without_label(form, field, options) do
    options = options ++ build_aria_label(field)
    error = HtmlError.html_error(form, field)
    [
      build_input(form, field, options, error)
    ] ++ error.html
  end

  defp input_with_label(form, field, label_options, options) do
    error = HtmlError.html_error(form, field)
    build_html(form, field, label_options, options, error)
  end

  defp build_aria_label(field) do
    ["aria-label": format_label(field)]
  end

  defp format_label(field) do
    field |> to_string |> String.replace("_", " ") |> String.capitalize
  end

  defp build_html(form, field, label_options, options, error) do
    [
      build_label(form, field, label_options),
      build_input(form, field, options, error)
    ] ++ error.html
  end

  defp build_input(form, field, options, error) do
    input_type = options[:as] || :text
    input_class = options[:class] || ""

    options =
      options
      |> add_validation_attributes(form, field)
      |> add_format_validation_attribute(form, field)
      |> Keyword.delete(:as)
      |> Keyword.put(:class, add_error_class(input_class, error.class))

    apply(Phoenix.HTML.Form, input_function(input_type), [form, field, options])
  end

  defp add_validation_attributes(options, %{impl: impl, source: %{validations: _}} = form, field) when is_atom(impl) do
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

  defp add_format_validation_attribute(options, %{impl: impl, source: %{validations: _}} = form, field) when is_atom(impl) do
    with true <- option_enabled?(options, :validate_regex, true),
      {:format, regex} <- form.source.validations[field]
    do
      options
      |> Keyword.put_new(:pattern, Regex.source(regex))
      |> Keyword.delete(:validate_regex)
    else
      _ -> options
    end
  end
  defp add_format_validation_attribute(options, _, _), do: options

  defp option_enabled?(options, field, default) do
    Enum.any?([
      options[field] == true,
      Application.get_env(:formulator, field, default) == true,
    ])
  end

  defp add_error_class(input_class, error_class) do
    [input_class, error_class]
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.join(" ")
    |> String.trim
  end

  def build_label(form, field, label_text) when is_binary(label_text) do
    build_label(form, field, [text: label_text])
  end

  def build_label(form, field, label_options) do
    case label_options[:text] do
      nil -> label(form, field, label_options)
      text -> label(form, field, text, label_options |> Keyword.delete(:text))
    end
  end

  defp input_function(:checkbox), do: :checkbox
  defp input_function(:date), do: :date_select
  defp input_function(:datetime), do: :datetime_select
  defp input_function(:time), do: :time_select
  defp input_function(:textarea), do: :textarea
  defp input_function(input_type), do: :"#{input_type}_input"
end
