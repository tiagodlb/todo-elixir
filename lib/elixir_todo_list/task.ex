defmodule ElixirTodoList.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :completed, :boolean, default: false
    field :priority, :string, default: "medium"
    field :category, :string, default: "geral"

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :completed, :priority, :category])
    |> validate_required([:title],
       message: "Não existe tarefa sem nome. Tente adicionar um nome"
    )
    |> validate_inclusion(:priority, ["low", "medium", "high"])
  end

  def priority_color("high"), do: "bg-red-400"
  def priority_color("medium"), do: "bg-yellow-400"
  def priority_color("low"), do: "bg-green-400"
end
