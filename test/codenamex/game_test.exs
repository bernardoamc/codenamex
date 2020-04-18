defmodule Codenamex.GameTest do
  use ExUnit.Case
  alias Codenamex.Game

  test "setup/0 setups the game state" do
    game = Game.setup()
    assert %Game{over: false, winner: nil, status: :pending, touched_card: nil} = game
  end

  test "start/1 changes the status when game has not started" do
    game = Game.setup()
    assert  {:ok, %{status: :started}} = Game.start(game)
  end

  test "start/1 returns an error when game has already started" do
    game = %{ Game.setup() | status: :started}
    assert  {:error, :already_in_progress} = Game.start(game)
  end
end
