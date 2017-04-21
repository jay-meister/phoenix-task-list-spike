defmodule Spike.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Spike.Router.Helpers


  def init(ops) do
    Keyword.fetch!(ops, :repo)
  end

  def call(conn, repo) do
    # if session is there, look up user and add them to assigns
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get_by(Spike.User, id: user_id)
    assign(conn, :current_user, user)
  end

  def authenticate_user(conn, ops) do
    # if user is logged in, let them pass
    cond do
      conn.assigns.current_user ->
        conn
      true ->
        conn
        |> Phoenix.Controller.put_flash(:error, "You are not logged in")
        |> Phoenix.Controller.redirect(to: Spike.Router.Helpers.page_path(conn, :index))
        |> halt
    end
  end

  def attempt_login(conn, email, given_pass, ops) do
    repo = Keyword.fetch!(ops, :repo)
    user = repo.get_by(Spike.User, email: email)
    IO.inspect user
    IO.inspect user.password_hash
    cond do
      user && user.password_hash == given_pass ->
        {:ok, login(conn, user)}
      true ->
        {:error, conn}
    end
  end

  def login(conn, user) do
    # Add the user id to the session cookie
    # Add user to the conn.assigns
    conn
    |> put_session(:user_id, user.id)
    |> assign(:current_user, user)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
