defmodule ElixirTodoList.Repo.Migrations.AddPriorityAndCategoryToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :priority, :string, default: "medium"
      add :category, :string, default: "geral"
    end
  end
end
