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

  def fetch(game_id, agent_name \\ @name) do
    case find(game_id, agent_name) do
      :undefined -> register(game_id, agent_name)
      pid -> pid
    end
  end

  def find(game_id, agent_name \\ @name) do
    Agent.get(agent_name, &Map.get(&1, game_id, :undefined))
  end

  def unregister(game_id, agent_name \\ @name) do
    pid = find(game_id, agent_name)

    if (pid != :undefined) do
      Codenamex.GameSupervisor.stop_game(pid)
      Agent.update(agent_name, &Map.delete(&1, game_id))
    end
  end

  def registered_rooms(agent_name \\ @name) do
    Agent.get(agent_name, &Map.keys(&1))
  end

  def register(game_id, agent_name \\ @name) do
    {:ok, pid} = Codenamex.GameSupervisor.start_game
    Agent.update(agent_name, &Map.put_new(&1, game_id, pid))

    pid
  end
end
