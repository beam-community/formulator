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

  ## Examples

  Basic input:
      <%= input form, :email %>
      #=> <label for="user_email">Email</label>
      #=> <input id="user_email" name="user[email]" type="text" value="">

  Without a label:
      <%= input form, :email, label: false %>
      #=> <input id="user_name" name="user[email]" aria-label="email" type="text" value="">

  Passing other options:
      <%= input form, :email, label: [class: "control-label"] %>
      #=> <label class="control-label" for="user_email">Email</label>
      #=> <input id="user_email" name="user[email]" type="text" value="">

      <%= input form, :email, class: "my-email-class", label: [class: "my-email-label-class"] %>
      #=> <label class="my-email-label-class" for="user_email">Email</label>
      #=> <input id="user_email" name="user[email]" type="text" value="" class="my-email-class">
  """

  @spec input(Phoenix.HTML.Form.t, atom, []) :: binary
  def input(form, field, options \\ []) do
    {label_options, options} = extract_label_options(options)

    case label_options do
      false -> input_without_label(form, field, options)
      _ -> input_with_label(form, field, label_options, options)
    end
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
      |> Keyword.delete(:as)
      |> Keyword.put(:class, add_error_class(input_class, error.class))

    apply(Phoenix.HTML.Form, input_function(input_type), [form, field, options])
  end

  defp add_error_class(input_class, error_class) do
    "#{input_class} #{error_class}"
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
