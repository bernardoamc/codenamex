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

  def start(pid) do
    GenServer.call(pid, :start_game)
  end

  def restart(pid) do
    GenServer.call(pid, :restart_game)
  end

  def fetch_cards(pid) do
    GenServer.call(pid, :fetch_cards)
  end

  def add_player(pid, player, team) do
    GenServer.call(pid, {:add_player, player, team})
  end

  def remove_player(pid, player) do
    GenServer.call(pid, {:remove_player, player})
  end

  def fetch_players(pid) do
    GenServer.call(pid, :fetch_players)
  end

  def touch_card(pid, word) do
    GenServer.call(pid, {:touch_card, word})
  end

  def handle_call(:start_game, _from, state) do
    new_state = Game.start(state)
    {:reply, :ok, new_state}
  end

  def handle_call(:restart_game, _from, state) do
    new_state = Game.restart(state)
    {:reply, :ok, new_state}
  end

  def handle_call(:fetch_cards, _from, state) do
    cards = Game.fetch_cards(state)
    {:reply, {:ok, cards}, state}
  end

  def handle_call({:touch_card, word}, _from, state) do
    new_state = Game.touch_card(state, word)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:add_player, player, team}, _from, state) do
    new_state = Game.add_player(state, player, team)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:remove_player, player}, _from, state) do
    new_state = Game.remove_player(state, player)
    {:reply, {:ok, new_state}, new_state}
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
end
