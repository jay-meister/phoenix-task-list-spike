defmodule Spike.SessionController do
  use Spike.Web, :controller

  def new(conn, params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => given_pass}}) do
    case Spike.Auth.attempt_login(conn, email, given_pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You are now logged in")
        |> redirect(to: user_path(conn, :index))
      {:error, conn} ->
        conn
        |> put_flash(:error, "incorrect user/password combination")
        |> render("new.html")

    end
  end

  def delete(conn, _params) do
    conn
    |> Spike.Auth.logout
    |> put_flash(:info, "You have logged out")
    |> redirect(to: page_path(conn, :index))
  end

end
