defmodule Formulator do
  use Phoenix.HTML
  alias Formulator.HtmlError
  import Formulator.Input

  @doc """
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
    `config :formulator, wrapper_class: "input-wrapper"`


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

  @spec input(Phoenix.HTML.Form.t(), atom, []) :: binary
  def input(form, field, options \\ []) do
    {label_options, options} = extract_label_options(options)

    input_wrapper(form, field, options, label_options, fn error ->
      build_input(form, field, options, label_options, error)
    end)
  end

  defp input_wrapper(form, field, options, label_options, fun) do
    [
      content_tag(
        :div,
        build_input_and_associated_tags(form, field, label_options, fun),
        class: wrapper_class(options)
      )
    ]
  end

  defp build_input_and_associated_tags(form, field, label_options, fun) do
    error = HtmlError.html_error(form, field)

    [
      build_label(form, field, label_options),
      fun.(error),
      error.html
    ]
    |> Enum.reject(&is_nil(&1))
  end

  defp wrapper_class(options) do
    options[:wrapper_class] || Application.get_env(:formulator, :wrapper_class)
  end

  defp extract_label_options(options) do
    label_options = options |> Keyword.get(:label, [])
    options = options |> Keyword.delete(:label)

    {label_options, options}
  end

  def build_label(_form, _field, false), do: nil

  def build_label(form, field, label_text) when is_binary(label_text) do
    build_label(form, field, text: label_text)
  end

  def build_label(form, field, label_options) do
    case label_options[:text] do
      nil -> label(form, field, label_options)
      text -> label(form, field, text, label_options |> Keyword.delete(:text))
    end
  end
end
