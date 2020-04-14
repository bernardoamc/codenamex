defmodule CodenamexWeb.RoomController do
  use CodenamexWeb, :controller

  alias Codenamex.Rooms
  alias Codenamex.Rooms.Room

  plug :authenticate, [] when action in [:show]

  def index(conn, _params) do
    changeset = Rooms.change_room(%Room{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"room" => room_params}) do
    changeset = Rooms.create_room(room_params)

    if changeset.valid? do
      conn
      |> register_player(room_params["player"])
      |> redirect(to: Routes.room_path(conn, :show, room_params["name"]))
    else
      changeset = %{changeset | action: :insert}
      render(conn, "index.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = get_session(conn, :player)

    conn
    |> assign(:room_name, id)
    |> assign(:player_name, player)
    |> render("show.html", room: id)
  end

  defp register_player(conn, player_name) do
    conn
      |> put_session(:player, player_name)
      |> configure_session(renew: true)
  end

  defp authenticate(conn, _options) do
    if get_session(conn, :player) do
      conn
    else
      conn |> redirect(to: "/") |> halt()
    end
  end
end
