defmodule Codenamex.Game do
  alias Codenamex.Game.Board

 defstruct [
   id: nil,
   board: nil,
   blue_team: nil,
   red_team: nil,
   winner: nil,
   turn: nil,
   over: false,
 ]

  def setup(id) do
    board = Board.setup()

    %__MODULE__{
      id: id,
      board: board,
      turn: board.first_team
    }
  end

  def touch_card(game, word) do
    {touched_color, updated_board} = Board.touch_card(game.board, word)
    {touched_color, update_state(game, updated_board, touched_color)}
  end

  defp update_state(game, updated_board, "black") do
    %{game | board: updated_board, winner: next_team(game.turn), over: true}
  end

  defp update_state(game, updated_board, "yellow") do
    %{game | board: updated_board, turn: next_team(game.turn)}
  end

  defp update_state(game = %{turn: "red"}, updated_board, "red") do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, winner: "red", over: true}
      _ ->
        %{game | board: updated_board}
    end
  end

  defp update_state(game = %{turn: "red"}, updated_board, "blue") do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, winner: "blue", over: true}
      _ ->
        %{game | board: updated_board, turn: "blue"}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, "blue") do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, winner: "blue", over: true}
      _ ->
        %{game | board: updated_board}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, "red") do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, winner: "red", over: true}
      _ ->
        %{game | board: updated_board, turn: "red"}
    end
  end

  defp next_team("red"), do: "blue"
  defp next_team("blue"), do: "red"
end
