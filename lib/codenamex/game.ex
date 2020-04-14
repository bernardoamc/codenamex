defmodule Codenamex.Game do
  @moduledoc """
  This module manages the game logic.
  All the functions besides setup/0 expect a game state.
  A state is a variation of what was created by the setup/0 function.
  """

  alias Codenamex.Game.Board

 defstruct [
   board: nil,
   winner: nil,
   turn: nil,
   touched_color: nil,
   over: false,
   blue_team: [],
   red_team: []
 ]

  def setup do
    board = Board.setup()

    %__MODULE__{
      board: board,
      turn: board.first_team
    }
  end

  def touch_card(game, word) do
    {touched_color, updated_board} = Board.touch_card(game.board, word)
    update_state(game, updated_board, touched_color)
  end

  defp next_team("red"), do: "blue"
  defp next_team("blue"), do: "red"

  def add_player(game, player, "red") do
    %{game | red_team: [player | game.red_team]}
  end

  def add_player(game, player, "blue") do
    %{game | blue_team: [player | game.blue_team]}
  end

  def remove_player(game, player, "red") do
    %{game | red_team: List.delete(game.red_team, player)}
  end

  def remove_player(game, player, "blue") do
    %{game | blue_team: List.delete(game.blue_team, player)}
  end

  def restart(game) do
    new_board = Board.setup()

    if new_board.first_team == game.board.first_team do
      %{red_team: red_players, blue_team: blue_players} = game
      %{game | board: new_board, red_team: blue_players, blue_team: red_players, winner: nil, over: false}
    else
      %{game | board: new_board, winner: nil, over: false}
    end
  end

  defp update_state(game, updated_board, "black") do
    %{game | board: updated_board, touched_color: "black", winner: next_team(game.turn), over: true}
  end

  defp update_state(game, updated_board, "yellow") do
    %{game | board: updated_board, touched_color: "yellow", turn: next_team(game.turn)}
  end

  defp update_state(game = %{turn: "red"}, updated_board, "red") do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, touched_color: "red", winner: "red", over: true}
      _ ->
        %{game | board: updated_board, touched_color: "red"}
    end
  end

  defp update_state(game = %{turn: "red"}, updated_board, "blue") do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, touched_color: "blue", winner: "blue", over: true}
      _ ->
        %{game | board: updated_board, touched_color: "blue", turn: "blue"}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, "blue") do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, touched_color: "blue", winner: "blue", over: true}
      _ ->
        %{game | board: updated_board, touched_color: "blue"}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, "red") do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, touched_color: "red", winner: "red", over: true}
      _ ->
        %{game | board: updated_board, touched_color: "red", turn: "red"}
    end
  end
end
