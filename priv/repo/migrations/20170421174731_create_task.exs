defmodule Spike.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :duration, :integer
      add :complete, :boolean, default: false, null: false
      add :completed_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:tasks, [:user_id])

  end
end
