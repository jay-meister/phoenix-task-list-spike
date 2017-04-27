defmodule Spike.Repo.Migrations.CreateDatesDue do
  use Ecto.Migration

  def change do
    create table(:datesdue) do
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :date_due, :naive_datetime

      timestamps()
    end
    create index(:datesdue, [:task_id])

  end
end
