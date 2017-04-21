defmodule Spike.TaskTest do
  use Spike.ModelCase

  alias Spike.Task

  @valid_attrs %{complete: true, completed_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, duration: 42, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end
end
