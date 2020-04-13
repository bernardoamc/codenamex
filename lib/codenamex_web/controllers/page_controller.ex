defmodule CodenamexWeb.PageController do
  use CodenamexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
