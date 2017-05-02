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

  defp date_or_today(params) do
    case params do
      %{"date" => date} = params ->
        Spike.ListController.readable_to_naive(date)
      _ ->
        NaiveDateTime.utc_now
    end
  end

  # set task as complete or incomplete
  def update(conn, %{"id" => id, "complete" => complete} = params, user) do
    task = user |> user_tasks |> Repo.get!(id)

    # if task is being completed, we want to add a completed_at date
    # if it is given in query, then set that to the date of completion, otherwise set today
    complete = if complete == "true", do: true, else: false
    completed_at = if complete do
      params |> date_or_today |> Spike.ListController.naive_to_ecto
    else
      nil
    end
    IO.inspect task
    update_params = %{complete: complete, completed_at: completed_at}
    IO.inspect update_params
    changeset = Task.complete_task_changeset(task, update_params)
    IO.inspect changeset
    case Repo.update(changeset) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: list_path(conn, :show, Spike.ListController.today_readable))
      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "There was an error")
        |> redirect(to: list_path(conn, :show, Spike.ListController.today_readable))
    end
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
