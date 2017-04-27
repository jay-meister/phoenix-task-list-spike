defmodule Spike.ListController do
  use Spike.Web, :controller

  def index(conn, params) do
    IO.inspect params
    render conn, "index.html"
  end
end
