defmodule Spike.DatesDue do
  use Spike.Web, :model

  alias Timex, as: T

  schema "datesdue" do
    field :date_due, Ecto.DateTime
    belongs_to :task, Spike.Task

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date_due, :task_id])
    |> validate_required([:date_due, :task_id])
  end
end

# get all tasks with dates due for a given user
# Repo.all from t in Task, where: t.user_id == 1,  preload: [:datesdue]

# get all a user's tasks for a given day
# Repo.all from t in Task, join: d in assoc(t, :datesdue), where: d.date_due <= ^today_end and d.date_due >= ^today_beg
# if for some reason we need the date loaded
# Repo.all from t in Task, join: d in assoc(t, :datesdue), where: d.date_due <= ^today_end and d.date_due >= ^today_beg, preload: [datesdue: d]
