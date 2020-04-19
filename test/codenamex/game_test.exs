defmodule Codenamex.GameTest do
  use ExUnit.Case
  alias Codenamex.Game
  alias Codenamex.Game.BoardSerializer
  alias Codenamex.Game.Team
  alias Codenamex.Game.Card
  alias Codenamex.Game.Player

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

  test "add_player/2 returns an error when nickname already exists" do
    game = Game.setup()
    guest_name = "codenames"

    {:ok, new_state} = Game.add_player(game, guest_name)
    assert {:error, :player_already_exists} = Game.add_player(new_state, guest_name)
  end

  test "add_player/2 adds player to guests list" do
    game = Game.setup()
    new_guest = Player.setup("codenames", "regular")
    {:ok, guests_team} = Team.setup() |> Team.add_player(new_guest, "regular")

    assert {:ok, %Game{guests: ^guests_team}} = Game.add_player(game, new_guest.name)
  end

  test "pick_team/3 switch players from teams" do
    game = Game.setup()
    player = Player.setup("codenames", "regular")

    empty_team = Team.setup()
    {:ok, expected_red_team} = Team.setup() |> Team.add_player(player, "regular")
    {:ok, expected_blue_team} = Team.setup() |> Team.add_player(player, "regular")

    # Joining as a guest
    assert {:ok, updated_game} = Game.add_player(game, player.name)
    # Moving to the red team
    assert {:ok, %Game{red_team: ^expected_red_team, guests: ^empty_team} = updated_game}
      = Game.pick_team(updated_game, player.name, "red", "regular")
    # Moving from red to the blue team
    assert {:ok, %Game{red_team: ^empty_team, blue_team: ^expected_blue_team}}
      = Game.pick_team(updated_game, player.name, "blue", "regular")
  end

  test "next_turn/2 returns an error when its not players turn" do
    game = setup_game()
    opponent_team = Game.next_team(game.turn)
    opponent = pick_player(game, opponent_team, "regular")

    assert {:error, :wrong_turn} = Game.next_turn(game, opponent.name)
  end

  test "next_turn/2 updates the game turn" do
    game = setup_game()
    player = pick_player(game, game.turn, "regular")
    opponent_team = Game.next_team(game.turn)

    assert {:ok, %Game{turn: ^opponent_team}} = Game.next_turn(game, player.name)
  end

  test "touch_card/3 returns an error when it's not the players turn" do
    game = setup_game()
    opponent_team = Game.next_team(game.turn)
    opponent = pick_player(game, opponent_team, "regular")
    card = pick_untouched_card_from(game, opponent_team)

    assert {:error, :wrong_turn} = Game.touch_card(game, card.word, opponent.name)
  end

  test "touch_card/3 returns an error when player is a spymaster" do
    game = setup_game()
    player = pick_player(game, game.turn, "spymaster")
    card = pick_untouched_card_from(game, game.turn)

    assert {:error, :wrong_turn} = Game.touch_card(game, card.word, player.name)
  end

  test "touch_card/3 returns an error when card is already touched" do
    game = setup_game()
    player = pick_player(game, game.turn, "regular")
    card = pick_untouched_card_from(game, game.turn)

    assert {:ok, new_state} = Game.touch_card(game, card.word, player.name)
    assert {:error, :card_already_touched} = Game.touch_card(new_state, card.word, player.name)
  end

  test "touch_card/3 ends turn when touched card is yellow" do
    game = setup_game()
    player = pick_player(game, game.turn, "regular")
    yellow_card = pick_untouched_card_from(game, "yellow")

    assert {:ok, new_state} = Game.touch_card(game, yellow_card.word, player.name)
    assert %{turn: opponent_team} = new_state
  end

  test "touch_card/3 ends turn when touched card is from the opposite team" do
    game = setup_game()
    opponent_team = Game.next_team(game.turn)
    player = pick_player(game, game.turn, "regular")
    opponent_card = pick_untouched_card_from(game, opponent_team)

    assert {:ok, new_state} = Game.touch_card(game, opponent_card.word, player.name)
    assert %{turn: opponent_team} = new_state
  end

  test "touch_card/3 ends game when touched card is black" do
    game = setup_game()
    opponent_team = Game.next_team(game.turn)
    player = pick_player(game, game.turn, "regular")
    black_card = pick_untouched_card_from(game, "black")

    assert {:ok, new_state} = Game.touch_card(game, black_card.word, player.name)
    assert %{over: true, winner: ^opponent_team} = new_state
  end

  test "touch_card/3 ends game when team cards reach zero" do
    game = setup_game()
    current_team = game.turn
    player = pick_player(game, current_team, "regular")
    updated_game = touch_team_cards_except_one(game, current_team, current_team, player.name)
    last_card = pick_untouched_card_from(updated_game, current_team)

    assert {:ok, new_state} = Game.touch_card(updated_game, last_card.word, player.name)
    assert %{over: true, winner: ^current_team} = new_state
  end

  test "touch_card/3 ends game when opponents cards reach zero" do
    game = setup_game()
    current_team = game.turn
    opponent_team = Game.next_team(current_team)
    player = pick_player(game, current_team, "regular")
    updated_game = touch_team_cards_except_one(game, current_team, opponent_team, player.name)
    last_card = pick_untouched_card_from(updated_game, opponent_team)

    assert {:ok, new_state} = Game.touch_card(updated_game, last_card.word, player.name)
    assert %{over: true, winner: ^opponent_team} = new_state
  end

  defp setup_game() do
    {:ok, game} = Game.setup() |> Game.add_player("ish")
    {:ok, game} = game |> Game.add_player("be")
    {:ok, game} = game |> Game.add_player("david")
    {:ok, game} = game |> Game.add_player("chloe")

    {:ok, game} = game |> Game.pick_team("ish", "red", "regular")
    {:ok, game} = game |> Game.pick_team("be", "blue", "regular")
    {:ok, game} = game |> Game.pick_team("david", "red", "spymaster")
    {:ok, game} = game |> Game.pick_team("chloe", "blue", "spymaster")

    game
  end

  defp pick_player(game, "red", "regular"), do:
    game.red_team |> Team.fetch_players() |> Enum.find(&(&1.regular))

  defp pick_player(game, "red", "spymaster"), do:
    game.red_team |> Team.fetch_players() |> Enum.find(&(&1.spymaster))

  defp pick_player(game, "blue", "regular"), do:
    game.blue_team |> Team.fetch_players() |> Enum.find(&(&1.regular))

  defp pick_player(game, "blue", "spymaster"), do:
    game.blue_team |> Team.fetch_players() |> Enum.find(&(&1.spymaster))

  defp pick_untouched_card_from(game, color) do
    BoardSerializer.serialize(:state, game.board, "spymaster")
    |> Map.fetch!(:cards)
    |> Map.values()
    |> Enum.find(&(&1.color == color && Card.touchable?(&1)))
  end

  defp touch_team_cards_except_one(game, team_color, color_to_pick, player_name) do
    cards_count = case color_to_pick do
      "red" -> game.board.red_cards
      "blue" -> game.board.blue_cards
    end

    Enum.reduce((1..cards_count-1), game, fn(_, game_state) ->
      card = pick_untouched_card_from(game_state, color_to_pick)
      {:ok, new_state} = Game.touch_card(game_state, card.word, player_name)
      %{new_state | turn: team_color}
    end)
  end
end
