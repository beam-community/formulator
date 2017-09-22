defmodule Formulator.Test.SampleSchema do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :email_address, :string
    field :number, :integer
  end

  def validation_changeset(schema \\ %__MODULE__{}, attrs) do
    schema
    |> cast(attrs, [:name, :email_address, :number])
    |> validate_required([:name])
    |> validate_number(:number, greater_than: 0)
    |> validate_format(:email_address, ~r(/.+@.+/))
  end

  def no_validation_changeset(schema \\ %__MODULE__{}, attrs) do
    schema
    |> cast(attrs, [:name, :email_address, :number])
  end
end
