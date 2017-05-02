defmodule Spike.ListController do
  use Spike.Web, :controller

  alias Ecto.DateTime, as: EDT
  alias Spike.DatesDue, as: DatesDue
  alias Date, as: D
  alias NaiveDateTime, as: N
  alias DateTime, as: DT
  alias Timex, as: T


  def naive_to_readable(naive), do: naive |> N.to_date |> D.to_string |> toggle_ymd_to_dmy

  # "22-03-2017" -> "2017-03-22"
  def toggle_ymd_to_dmy(format), do: format |> String.split("-") |> Enum.reverse |> Enum.join("-")

  # "22-03-2017" -> ~N[2017-03-22 12:00:00]
  def readable_to_naive(date_string) do
    res = date_string
    |> String.split("-")
    |> Enum.reverse
    |> parse_to_integers
    |> List.to_tuple
    |> (&({&1, {12, 0, 0}})).()
    |> N.from_erl
    |> (fn({:ok, ndt}) -> ndt end).()
  end
  def naive_beg_and_end(naive), do: {T.beginning_of_day(naive), T.end_of_day(naive)}
  def naive_to_ecto(naive), do: naive |> N.to_erl |> EDT.from_erl
  def ecto_to_naive(ectodt), do: ectodt |> EDT.to_erl |> N.from_erl!
  def ecto_to_date(ectodt), do: ectodt |> EDT.to_erl |> (fn({date, time}) -> date end).() |> D.from_erl!

  def parse_to_integers(list), do: list |> Enum.map(&Integer.parse/1) |> Enum.map(fn({i, _}) -> i end)

  # view helpers
  def today_readable, do: Date.utc_today |> Date.to_string |> String.split("-") |> Enum.reverse |> Enum.join("-")



  def index(conn, params) do
    user_id = conn.assigns.current_user.id

    # get all dates that this user has created a list
    dates =
      Repo.all from d in DatesDue,
      join: t in assoc(d, :task),
      where: t.user_id == ^user_id,
      order_by: [desc: d.date_due]

    # format dates and remove duplicates
    dates =
      dates
      |> Enum.map(fn(map) -> ecto_to_naive(map.date_due) end)
      |> Enum.map(&naive_to_readable/1)
      |> Enum.uniq


    render conn, "index.html", dates: dates
  end

  def show(conn, %{"date" => date}) do
    user_id = conn.assigns.current_user.id
    {day_start, day_end} = date |> readable_to_naive |> naive_beg_and_end

    IO.inspect day_start
    IO.inspect day_end
    IO.inspect user_id
    tasks = Repo.all from t in Spike.Task,
      join: d in assoc(t, :datesdue),
      preload: [datesdue: d],
      where: d.date_due <= ^day_end
      and d.date_due >= ^day_start
      and t.user_id == ^user_id

    IO.inspect tasks

    render conn, "show.html", tasks: tasks, date: date
  end

  def create(conn, %{"date" => date, "tasks" => tasks}) do
    user_id = conn.assigns.current_user
    naive = date |> readable_to_naive |> naive_to_ecto
    tasks_int = tasks |> parse_to_integers

    IO.inspect naive
    IO.inspect tasks_int
    for task_id <- tasks_int do
      case Repo.insert(%DatesDue{task_id: task_id, date_due: naive} ) do
        {:ok, _} -> IO.inspect "OK inserted"
        {:error, _} -> IO.inspect "Error"
      end
    end

    conn
    |> put_flash(:info, "task added to list")
    |> redirect(to: task_path(conn, :index))
  end

  def delete(conn, %{"date" => date, "task" => task}) do
    {task_id, _} = Integer.parse(task)

    date_struct = Repo.get_by DatesDue, task_id: task_id

    case date_struct do
      %DatesDue{} ->
        Repo.delete! date_struct
        conn
        |> put_flash(:info, "Task removed from list")
        |> redirect(to: list_path(conn, :show, date))
      nil ->
        conn
        |> put_flash(:error, "Task couldn't be found")
        |> redirect(to: list_path(conn, :show, date))
    end
  end
end











#
