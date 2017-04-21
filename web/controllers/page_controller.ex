defmodule Spike.PageController do
  use Spike.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
