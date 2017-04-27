defmodule Spike.DatesDueTest do
  use Spike.ModelCase

  alias Spike.DatesDue

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DatesDue.changeset(%DatesDue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DatesDue.changeset(%DatesDue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
