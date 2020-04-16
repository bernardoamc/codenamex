defmodule Codenamex.Game do
  @moduledoc """
  This module manages the game logic.
  All the functions besides setup/0 expect a game state.
  A state is a variation of what was created by the setup/0 function.
  """

  alias Codenamex.Game.Board
  alias Codenamex.Game.Player
  alias Codenamex.Game.Team

 defstruct [
   board: nil,
   winner: nil,
   turn: nil,
   touched_color: nil,
   over: false,
   status: :pending,
   guests: %Team{},
   blue_team: %Team{},
   red_team: %Team{}
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
    case Board.touch_card(game.board, word) do
      {:ok, {touched_color, updated_board}} ->
        {:ok, update_state(game, updated_board, touched_color)}
      {:error, _} ->
        {:error, game}
    end
  end

  defp next_team("red"), do: "blue"
  defp next_team("blue"), do: "red"

  def fetch_players(game) do
    guests = Team.fetch_players(game.guests)
    red = Team.fetch_players(game.red_team)
    blue = Team.fetch_players(game.blue_team)

    %{guests: guests, red_team: red, blue_team: blue}
  end

  def add_player(game, player_name, "guest")  do
    player = Player.setup(player_name, "regular")

    {:ok, team} = Team.add_player(game.guests, player, "regular")
    {:ok, %{game | guests: team}}
  end

  def pick_team(game, player_name, "red", type) do
    player = Player.setup(player_name, type)

    case Team.add_player(game.red_team, player, type) do
      {:ok, team} -> {:ok, %{game | red_team: team}}
      {:error, reason} -> {:error, reason}
    end
  end

  def pick_team(game, player_name, "blue", type) do
    player = Player.setup(player_name, type)

    case Team.add_player(game.blue_team, player, type) do
      {:ok, team} -> {:ok, %{game | blue_team: team}}
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_player(game, player_name) do
    case find_team(game, player_name) do
      nil -> {:error, :player_not_found}
      team -> {:ok, remove_from_team(game, player_name, team)}
    end
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

  defp find_team(game, player_name) do
    cond do
      Map.has_key?(game.guests, player_name) -> "guest"
      Map.has_key?(game.red_team, player_name) -> "red"
      Map.has_key?(game.blue_team, player_name) -> "blue"
      true -> nil
    end
  end

  defp remove_from_team(game, player_name, "guest") do
    %{game | guests: Team.remove_player(game.guests, player_name)}
  end

  defp remove_from_team(game, player_name, "red") do
    %{game | red_team: Team.remove_player(game.red_team, player_name)}
  end

  defp remove_from_team(game, player_name, "blue") do
    %{game | blue_team: Team.remove_player(game.blue_team, player_name)}
  end
end
