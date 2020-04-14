defmodule Codenamex.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :player, :string
  end

  @required_fields [:name, :player]

  @doc false
  def changeset(room, params) do
    room
    |> cast(params, @required_fields)
    |> validate_length(:name, min: 4, max: 20)
    |> validate_length(:player, min: 4, max: 20)
  end
end

