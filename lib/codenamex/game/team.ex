defmodule Codenamex.Game.Team do
  @moduledoc """
  This module manages the team logic.
  A team is composed of player with varied roles.
  """

  defstruct [
    spymaster: nil,
    players: %{},
  ]

  def setup() do
    %__MODULE__{}
  end

  def add_player(team, player, "regular") do
    updated_players = Map.put(team.players, player.name, player)
    {:ok, %{team | players: updated_players}}
  end

  def add_player(%{spymaster: nil} = team, player, "spymaster") do
    updated_players = Map.put(team.players, player.name, player)
    {:ok, %{team | spymaster: player.name, players: updated_players}}
  end

  def add_player(_team, _player, "spymaster") do
    {:error, :spymaster_taken}
  end

  def remove_player(team, player_name) do
    updated_players = Map.delete(team.players, player_name)
    %{team | players: updated_players}
  end

  def fetch_players(team) do
    Map.values(team.players)
  end

  def pick_order() do
    ["red", "blue"] |> Enum.shuffle
  end
end
