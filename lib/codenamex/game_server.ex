defmodule Codenamex.GameServer do
  @moduledoc """
  This module manages a single room.
  Each room has a state like the one in &Game.setup/0 module.
  """

  use GenServer
  alias Codenamex.Game

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    {:ok, Game.setup()}
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def restart_game(pid) do
    GenServer.call(pid, :restart_game)
  end

  def add_player(pid, player) do
    GenServer.call(pid, {:add_player, player})
  end

  def pick_team(pid, player, team, type) do
    GenServer.call(pid, {:pick_team, player, team, type})
  end

  def remove_player(pid, player) do
    GenServer.call(pid, {:remove_player, player})
  end

  def fetch_players(pid) do
    GenServer.call(pid, :fetch_players)
  end

  def serialize_state(pid, type) do
    GenServer.call(pid, {:serialize_state, type})
  end

  def touch_card(pid, word, player_name) do
    GenServer.call(pid, {:touch_card, word, player_name})
  end

  def handle_call(:start_game, _from, state) do
    case Game.start(state) do
      {:error, reason} ->  {:reply, {:error, reason}, state}
      {:ok, new_state} ->  {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call(:restart_game, _from, state) do
    new_state = Game.restart(state)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:touch_card, word, player_name}, _from, state) do
    case Game.touch_card(state, word, player_name) do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      {:error, _} -> {:reply, :error, state}
    end
  end

  def handle_call({:add_player, player_name}, _from, state) do
    {:ok, new_state} = Game.add_player(state, player_name)
    players = Game.fetch_players(new_state)

    case new_state do
      %{status: :pending} ->
        {:reply, {:ok, players}, new_state}
      %{status: :started} ->
        {:ok, regular_state} = Game.serialize_state(new_state, "regular")
        {:reply, {:ok, {players, regular_state}}, new_state}
    end
  end

  def handle_call({:pick_team, player_name, team, type}, _from, state) do
    case Game.pick_team(state, player_name, team, type) do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:remove_player, player_name}, _from, state) do
    case Game.remove_player(state, player_name) do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:fetch_players, _from, state) do
    players = Game.fetch_players(state)

    case players do
      %{guests: [], red_team: [], blue_team: []} ->
        {:reply, {:empty, nil}, state}
      players ->
        {:reply, {:ok, players}, state}
    end
  end

  def handle_call({:serialize_state, type}, _from, state) do
    {:ok, serialized_state} = Game.serialize_state(state, type)
    {:reply, {:ok, serialized_state}, state}
  end
end
