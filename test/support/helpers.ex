defmodule Formulator.Test.Helpers do
  alias Phoenix.HTML.Form
  alias Formulator.Test.SampleSchema

  def prepare_form(attrs) do
    %Form{id: :fake, data: attrs}
  end

  def extract_html(element) when not is_list(element) do
    extract_html([element])
  end
  def extract_html(form) do
    [{:safe, element} | _] = form
    element
  end

  def prepare_changeset_form(attrs, :validate), do: prepare_changeset_form(attrs, :validation_changeset)
  def prepare_changeset_form(attrs, :novalidate), do: prepare_changeset_form(attrs, :no_validation_changeset)
  def prepare_changeset_form(attrs, changeset) do
    %Form{
      data: %SampleSchema{},
      impl: Phoenix.HTML.FormData.Ecto.Changeset,
      name: SampleSchema,
      source: apply(SampleSchema, changeset, [%SampleSchema{}, attrs])
    }
  end

  def prepare_conn_form(attrs) do
    %Form{
      data: attrs,
      impl: Phoenix.HTML.FormData.Plug.Conn,
      name: :conn_form,
      source: %Plug.Conn{}
    }
  end
end
