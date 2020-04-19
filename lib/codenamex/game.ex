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
    guests: nil,
    blue_team: nil,
    red_team: nil,
    board: nil,
    winner: nil,
    turn: nil,
    touched_card: nil,
    over: false,
    status: :pending
  ]

  def setup do
    board = Board.setup()

    %__MODULE__{
      board: board,
      turn: board.first_team,
      guests: Team.setup(),
      blue_team: Team.setup(),
      red_team: Team.setup()
    }
  end

  def start(game) do
    case game do
      %{status: :started} -> {:error, :already_in_progress}
      _ -> {:ok, %{game | status: :started}}
    end
  end

  def next_turn(game, player_name) do
    case allowed_to_finish_turn?(game, player_name) do
      true ->  {:ok, %{game | turn: next_team(game.turn)}}
      false -> {:error, :wrong_turn}
    end
  end

  def touch_card(game, word, player_name) do
    case allowed_to_touch_card?(game, player_name) do
      true -> touch_card(game, word)
      false -> {:error, :wrong_turn}
    end
  end

  def next_team("red"), do: "blue"
  def next_team("blue"), do: "red"

  def fetch_players(game) do
    guests = Team.fetch_players(game.guests)
    red = Team.fetch_players(game.red_team)
    blue = Team.fetch_players(game.blue_team)

    %{guests: guests, red_team: red, blue_team: blue}
  end

   def add_player(game, player_name)  do
     player = Player.setup(player_name, "regular")

     case Team.add_player(game.guests, player, "regular") do
       {:ok, team} -> {:ok, %{game | guests: team}}
       error -> error
     end
   end

  def pick_team(game, player_name, "red", type) do
    player = Player.setup(player_name, type)
    current_team = find_team(game, player_name)
    updated_game = remove_from_team(game, player_name, current_team)

    case Team.add_player(updated_game.red_team, player, type) do
      {:ok, team} -> {:ok, %{updated_game | red_team: team}}
      error -> error
    end
  end

  def pick_team(game, player_name, "blue", type) do
    player = Player.setup(player_name, type)
    current_team = find_team(game, player_name)
    updated_game = remove_from_team(game, player_name, current_team)

    case Team.add_player(updated_game.blue_team, player, type) do
      {:ok, team} -> {:ok, %{updated_game | blue_team: team}}
      error -> error
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

  defp touch_card(game, word) do
    case Board.touch_card(game.board, word) do
      {:ok, {touched_card, updated_board}} ->
        {:ok, update_state(game, updated_board, touched_card)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp update_state(game, updated_board, %{color: "black"} = touched_card) do
    %{game | board: updated_board, touched_card: touched_card, winner: next_team(game.turn), over: true}
  end

  defp update_state(game, updated_board, %{color: "yellow"} = touched_card) do
    %{game | board: updated_board, touched_card: touched_card, turn: next_team(game.turn)}
  end

  defp update_state(%{turn: "red"} = game, updated_board, %{color: "red"} = touched_card) do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, touched_card: touched_card, winner: "red", over: true}
      _ ->
        %{game | board: updated_board, touched_card: touched_card}
    end
  end

  defp update_state(game = %{turn: "red"}, updated_board, %{color: "blue"} = touched_card) do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, touched_card: touched_card, winner: "blue", over: true}
      _ ->
        %{game | board: updated_board, touched_card: touched_card, turn: "blue"}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, %{color: "blue"} = touched_card) do
    case updated_board.blue_cards do
      0 ->
        %{game | board: updated_board, touched_card: touched_card, winner: "blue", over: true}
      _ ->
        %{game | board: updated_board, touched_card: touched_card}
    end
  end

  defp update_state(game = %{turn: "blue"}, updated_board, %{color: "red"} = touched_card) do
    case updated_board.red_cards do
      0 ->
        %{game | board: updated_board, touched_card: touched_card, winner: "red", over: true}
      _ ->
        %{game | board: updated_board, touched_card: touched_card, turn: "red"}
    end
  end

  defp allowed_to_touch_card?(game, player_name) do
    player_team_color = find_team(game, player_name)
    team = fetch_team(game, player_team_color)
    player = Team.fetch_player(team, player_name)

    (player_team_color == game.turn) && Player.can_select_word?(player)
  end

  defp allowed_to_finish_turn?(game, player_name)  do
    find_team(game, player_name) == game.turn
  end

  defp find_team(game, player_name) do
    cond do
      Team.has_player?(game.guests, player_name) -> "guest"
      Team.has_player?(game.red_team, player_name) -> "red"
      Team.has_player?(game.blue_team, player_name) -> "blue"
      true -> nil
    end
  end

  defp fetch_team(game, "red") do
    game.red_team
  end

  defp fetch_team(game, "blue") do
    game.blue_team
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
