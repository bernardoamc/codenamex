defmodule CodenamexWeb.RoomChannel do
  use Phoenix.Channel

  alias Codenamex.GameRegistry
  alias Codenamex.GameServer

  def join("room:" <> room_name, %{"player_name" => player_name}, socket) do
    game_pid = GameRegistry.fetch(room_name)

    socket =
      socket
      |> assign(:game_pid, game_pid)
      |> assign(:room_name, room_name)
      |> assign(:player_name, player_name)

    case GameServer.add_player(game_pid, player_name, "guest") do
      {:ok, _state} ->
        send(self(), :player_joined)
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_info(:player_joined, socket) do
    game_pid = socket.assigns.game_pid
    room_name = socket.assigns.room_name

    {:ok, players} = GameServer.fetch_players(game_pid)
    broadcast! socket, room_name <> ":joined", %{players: players}

    {:noreply, socket}
  end

  def handle_in("remove_player", socket) do
    remove_player(socket)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    remove_player(socket)
    :ok
  end

  defp remove_player(socket) do
    game_pid = socket.assigns.game_pid
    player_name = socket.assigns.player_name

    {:ok, _state} = GameServer.remove_player(game_pid, player_name)

    case GameServer.fetch_players(game_pid) do
      {:ok, players} ->
        IO.inspect(players)
        broadcast! socket, "player_left", %{players: players}
      {:empty, _} ->
        GameRegistry.unregister(socket.assigns.room_name)
    end
  end
end
