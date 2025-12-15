defmodule ElixirTodoList.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name], message: "Nome da categoria é obrigatório")
    |> unique_constraint(:slug)
    |> generate_slug()
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        slug = name
          |> String.downcase()
          |> String.trim()
          |> String.replace(~r/[^\w\s-]/, "")
          |> String.replace(~r/\s+/, "-")
        put_change(changeset, :slug, slug)
    end
  end
end
