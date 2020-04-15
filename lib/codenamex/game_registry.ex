defmodule Codenamex.GameRegistry do
  @moduledoc """
  This module manages all the rooms.
  Each room is a GameState process that is supervised by the GameSupervisor
  module.
  """

  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> Map.new end, opts)
  end

  def fetch(room_name, agent_name \\ @name) do
    case find(room_name, agent_name) do
      :undefined -> register(room_name, agent_name)
      game_pid -> game_pid
    end
  end

  def find(room_name, agent_name \\ @name) do
    Agent.get(agent_name, &Map.get(&1, room_name, :undefined))
  end

  def unregister(room_name, agent_name \\ @name) do
    game_pid = find(room_name, agent_name)

    if (game_pid != :undefined) do
      Codenamex.GameSupervisor.stop_game(game_pid)
      Agent.update(agent_name, &Map.delete(&1, room_name))
    end
  end

  def registered_rooms(agent_name \\ @name) do
    Agent.get(agent_name, &Map.keys(&1))
  end

  def register(room_name, agent_name \\ @name) do
    {:ok, game_pid} = Codenamex.GameSupervisor.start_game
    Agent.update(agent_name, &Map.put_new(&1, room_name, game_pid))

    game_pid
  end
end
