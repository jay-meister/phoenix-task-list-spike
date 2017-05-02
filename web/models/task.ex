defmodule Spike.Task do
  use Spike.Web, :model

  schema "tasks" do
    field :title, :string, null: false
    field :duration, :integer
    field :complete, :boolean, default: false
    field :completed_at, Ecto.DateTime
    belongs_to :user, Spike.User
    has_many :datesdue, Spike.DatesDue

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :duration, :complete])
    |> validate_required([:title])
  end

  def complete_task_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:complete, :completed_at])
    |> validate_required([:complete])
  end
end
