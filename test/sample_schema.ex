defmodule Formulator.Test.SampleSchema do
  use Ecto.Schema

 embedded_schema do
   field :name
   field :email
   field :number
 end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:name, :email, :number])
    |> validate_required(:name)
    |> validate_number(:number, greater_than: 0)
    |> validate_format(:email, ~r(/.+@.+/))
  end
end
