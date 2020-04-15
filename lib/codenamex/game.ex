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
   status: :pending,
   guests: [],
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

  def start(game) do
    %{game | status: :started}
  end

  def fetch_cards(game) do
    Board.cards(game.board)
  end

  def touch_card(game, word) do
    {touched_color, updated_board} = Board.touch_card(game.board, word)
    update_state(game, updated_board, touched_color)
  end

  defp next_team("red"), do: "blue"
  defp next_team("blue"), do: "red"

  def fetch_players(game) do
    %{guests: game.guests, red_team: game.red_team, blue_team: game.blue_team}
  end

  def add_player(game, player, "guest")  do
    %{game | guests: [player | game.guests]}
  end

  def add_player(game, player, "red") do
    %{game | red_team: [player | game.red_team]}
  end

  def add_player(game, player, "blue") do
    %{game | blue_team: [player | game.blue_team]}
  end

  def remove_player(game, player) do
    team = find_team(game, player)
    remove_player(game, player, team)
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

  defp find_team(game, player) do
    cond do
      Enum.member?(game.guests, player) -> "guest"
      Enum.member?(game.red_team, player) -> "red"
      Enum.member?(game.blue_team, player) -> "blue"
    end
  end

  defp remove_player(game, player, "guest") do
    %{game | guests: List.delete(game.guests, player)}
  end

  defp remove_player(game, player, "red") do
    %{game | red_team: List.delete(game.red_team, player)}
  end

  defp remove_player(game, player, "blue") do
    %{game | blue_team: List.delete(game.blue_team, player)}
  end
end
