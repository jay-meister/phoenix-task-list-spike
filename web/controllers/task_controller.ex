defmodule Spike.TaskController do
  use Spike.Web, :controller

  alias Spike.Task

  def action(conn, _) do
    # adds the user as the third argument of the function
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def user_tasks(user) do
    assoc(user, :tasks)
  end

  def index(conn, _params, user) do
    tasks = user |> user_tasks |> Repo.all
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params, user) do
    changeset = Task.changeset(%Task{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"task" => task_params}, user) do
    changeset =
      user
      |> build_assoc(:tasks)
      |> Task.changeset(task_params)

    case Repo.insert(changeset) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: task_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    task = user |> user_tasks |> Repo.get!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}, user) do
    task = user |> user_tasks |> Repo.get!(id)
    changeset = Task.changeset(task)
    render(conn, "edit.html", task: task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}, user) do
    task = user |> user_tasks |> Repo.get!(id)
    changeset = Task.changeset(task, task_params)

    case Repo.update(changeset) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: task_path(conn, :show, task))
      {:error, changeset} ->
        render(conn, "edit.html", task: task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    task = user |> user_tasks |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: task_path(conn, :index))
  end
end
