defmodule Spike.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Spike.Router.Helpers


  def init(ops) do
  end

  def call(conn, ops) do
    # if session is there, look up user and add them to assigns
    user_id = get_session(conn, :user_id)
    user = user_id && true

    assign(conn, :current_user, user)
  end

  def authenticate_user(conn, ops) do
    # if password and email match, then log them in
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
end
