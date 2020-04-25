defmodule UltimateTttWeb.PageController do
  use UltimateTttWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
