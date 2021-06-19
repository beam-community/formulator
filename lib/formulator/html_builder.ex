defmodule Formulator.HtmlBuilder do
  use Phoenix.HTML

  def build_error_span(error, field) do
    content_tag(
      :span,
      translate_error(error),
      class: "field-error",
      "data-role": "#{field}-error",
      id: "#{field}-error"
    )
  end

  @error_message """
    Missing translate_error_module config. Add the following to your config/config.exe

    config :formulator, translate_error_module: YourAppName.Gettext
  """

  defp translate_error(error) do
    if module = Application.get_env(:formulator, :translate_error_module) do
      module.translate_error(error)
    else
      raise ArgumentError, message: @error_message
    end
  end
end
