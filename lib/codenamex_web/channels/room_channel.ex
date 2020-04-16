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

    case GameServer.add_player(game_pid, player_name) do
      {:ok, {players, cards}} ->
        send(self(), :joined_room)
        {:ok, %{message: "welcome", players: players, cards: cards}, socket}
      {:ok, players} ->
        send(self(), :joined_room)
        {:ok, %{message: "welcome", players: players}, socket}
    end
  end

  def handle_in("pick_team", %{"type" => "spymaster", "team" => "red"} = choice, socket) do
    pick_team(socket, choice)
  end

  def handle_in("pick_team", %{"type" => "regular", "team" => "red"} = choice, socket) do
    pick_team(socket, choice)
  end

  def handle_in("pick_team", %{"type" => "spymaster", "team" => "blue"} = choice, socket) do
    pick_team(socket, choice)
  end

  def handle_in("pick_team", %{"type" => "regular", "team" => "blue"} = choice, socket) do
    pick_team(socket, choice)
  end

  def handle_info(:joined_room, socket) do
    game_pid = socket.assigns.game_pid
    room_name = socket.assigns.room_name

    {:ok, players} = GameServer.fetch_players(game_pid)
    broadcast! socket, room_name <> ":joined", %{players: players}

    {:noreply, socket}
  end

  def handle_info(:picked_team, socket) do
    game_pid = socket.assigns.game_pid
    room_name = socket.assigns.room_name

    {:ok, players} = GameServer.fetch_players(game_pid)
    broadcast! socket, room_name <> ":team_change", %{players: players}

    {:noreply, socket}
  end

  def handle_in("remove_player", socket) do
    case remove_player(socket) do
      {:ok, :player_removed} -> broadcast_players(socket)
      _ -> nil
    end

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case remove_player(socket) do
      {:ok, :player_removed} -> broadcast_players(socket)
      _ -> nil
    end

    :ok
  end

  defp pick_team(socket, %{"type" => type, "team" => team}) do
    game_pid = socket.assigns.game_pid
    player_name = socket.assigns.player_name

    case GameServer.pick_team(game_pid, player_name, team, type) do
      {:ok, _state} ->
        assign(socket, :team, team)
        send(self(), :picked_team)
        {:reply, {:ok, %{message: "joined"}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{message: reason}}, socket}
    end
  end

  defp remove_player(socket) do
    game_pid = socket.assigns.game_pid
    player_name = socket.assigns.player_name

    case GameServer.remove_player(game_pid, player_name) do
      {:ok, _state} -> {:ok, :player_removed}
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end

  defp broadcast_players(socket) do
    game_pid = socket.assigns.game_pid

    case GameServer.fetch_players(game_pid) do
      {:ok, players} ->
        broadcast! socket, "player_left", %{players: players}
      {:empty, _} ->
        GameRegistry.unregister(socket.assigns.room_name)
    end
  end
end
