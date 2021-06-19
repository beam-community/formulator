if Mix.env() == :test do
  defmodule Formulator.Test.Gettext do
    def translate_error({text, _}), do: text
  end
end
