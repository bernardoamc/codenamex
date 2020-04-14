defmodule Codenamex.GameSupervisor do
  @moduledoc """
  This module is responsible for supervising all the GameState processes.
  It is referenced from the GameRegistry module.
  """
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_game do
    spec = {Codenamex.GameServer, []}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_game(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: []
    )
  end
end
