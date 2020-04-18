defmodule CodenamexWeb.RoomChannel do
  use Phoenix.Channel

  alias Codenamex.GameRegistry
  alias Codenamex.GameServer

  intercept ["game_started"]

  def join("room:" <> room_name, %{"player_name" => player_name}, socket) do
    game_pid = GameRegistry.fetch(room_name)

    socket =
      socket
      |> assign(:game_pid, game_pid)
      |> assign(:room_name, room_name)
      |> assign(:player_name, player_name)
      |> assign(:team, "guest")

    case GameServer.add_player(game_pid, player_name) do
      {:ok, {players, serialized_state}} ->
        send(self(), :joined_room)
        {:ok, %{status: :ongoing, players: players, state: serialized_state}, socket}
      {:ok, players} ->
        send(self(), :joined_room)
        {:ok, %{status: :lobby, players: players}, socket}
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

  def handle_in("start_game", _opts, socket) do
    game_pid = socket.assigns.game_pid

    case GameServer.start_game(game_pid) do
      {:ok, _} ->
        broadcast! socket, "game_started", %{}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end

    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("touch_card", %{"word" => word}, socket) do
    game_pid = socket.assigns.game_pid
    player_name = socket.assigns.player_name

    case GameServer.touch_card(game_pid, word, player_name) do
      {:ok, serialized_state} ->
        broadcast! socket, "touched_card", %{state: serialized_state}
        {:reply, {:ok, %{}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  # TODO: Might be possible to move this to the original function
  def handle_info(:joined_room, socket) do
    game_pid = socket.assigns.game_pid

    {:ok, players} = GameServer.fetch_players(game_pid)
    broadcast! socket, "joined_room", %{players: players}

    {:noreply, socket}
  end

  # TODO: Might be possible to move this to the original function
  def handle_info(:picked_team, socket) do
    game_pid = socket.assigns.game_pid

    {:ok, players} = GameServer.fetch_players(game_pid)
    broadcast! socket, "team_change", %{players: players}

    {:noreply, socket}
  end

  # Intercepting the broadcast to forward the right game state
  # based on the type of player
  def handle_out("game_started", _data, socket) do
    game_pid = socket.assigns.game_pid
    type = socket.assigns.type

    {:ok, serialized_state} = GameServer.serialize_state(game_pid, type)
    push(socket, "game_started", %{state: serialized_state})

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
        socket =
          socket
          |> assign(:team, team)
          |> assign(:type, type)

        send(self(), :picked_team)
        {:reply, {:ok, %{result: :ok, team: team, type: type}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{result: :error, reason: reason}}, socket}
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
