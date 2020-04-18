defmodule Codenamex.Game.Board do
  @moduledoc """
  This module manages the board logic.
  All the functions besides setup/0 expect a board state.
  A state is a variation of what was created by the setup/0 function.
  """

  alias Codenamex.Game.Card
  alias Codenamex.Game.Dictionary
  alias Codenamex.Game.Team

  @cards_count 25
  @first_team_cards_count 9
  @second_team_cards_count 8
  @black_cards_count 1
  @yellow_cards_count 7

  defstruct [
    words: nil,
    regular_cards: nil,
    spymaster_cards: nil,
    first_team: nil,
    red_cards: nil,
    blue_cards: nil,
    black_cards: @black_cards_count,
    yellow_cards: @yellow_cards_count
  ]

  def setup() do
    [first_team, second_team] = Team.pick_order()
    words = Dictionary.fetch(@cards_count)
    {regular_cards, spymaster_cards} = setup_board(words, first_team, second_team)

    %__MODULE__{
      words: words |> Enum.shuffle,
      regular_cards: regular_cards,
      spymaster_cards: spymaster_cards,
      first_team: first_team,
      red_cards: red_cards_start(:first_team, first_team),
      blue_cards: blue_cards_start(:first_team, first_team)
    }
  end

  def touch_card(board, word) do
    selected_regular_card = Map.fetch!(board.regular_cards, word)

    case Card.touchable?(selected_regular_card) do
      true ->
        selected_spymaster_card = Map.fetch!(board.spymaster_cards, word)
        {:ok, update_state(board, word, selected_spymaster_card)}
      false ->
        {:error, :card_already_touched}
    end
  end

  defp update_state(board, word, selected_spymaster_card) do
    updated_spymaster_card = Card.touch(selected_spymaster_card)
    spymaster_cards = Map.replace!(board.spymaster_cards, word, updated_spymaster_card)
    regular_cards = Map.replace!(board.regular_cards, word, updated_spymaster_card)
    updated_board = %{board | spymaster_cards: spymaster_cards, regular_cards: regular_cards}

    case updated_spymaster_card.color do
      "red"    -> {updated_spymaster_card, %{updated_board | red_cards: board.red_cards - 1}}
      "blue"   -> {updated_spymaster_card, %{updated_board | blue_cards: board.blue_cards - 1}}
      "yellow" -> {updated_spymaster_card, %{updated_board | yellow_cards: board.yellow_cards - 1}}
      "black"  -> {updated_spymaster_card, %{updated_board | black_cards: board.black_cards - 1}}
    end
  end

  defp setup_board(words, first_team, second_team) do
    red_offset = 0
    {first_regular_cards, first_sypermaster_cards} =
      setup_cards(words, first_team, @first_team_cards_count, red_offset)

    blue_offset = @first_team_cards_count
    {second_regular_cards, second_sypermaster_cards} =
      setup_cards(words, second_team, @second_team_cards_count, blue_offset)

    black_offset = @first_team_cards_count + @second_team_cards_count
    {black_regular_cards, black_spymaster_cards} =
      setup_cards(words, "black", @black_cards_count, black_offset)

    yellow_offset = @first_team_cards_count + @second_team_cards_count + @black_cards_count
    {yellow_regular_cards, yellow_spymaster_cards} =
      setup_cards(words, "yellow", @yellow_cards_count, yellow_offset)

    regular_cards = first_regular_cards
                    ++ second_regular_cards
                    ++ black_regular_cards
                    ++ yellow_regular_cards

    spymaster_cards = first_sypermaster_cards
                      ++ second_sypermaster_cards
                      ++ black_spymaster_cards
                      ++ yellow_spymaster_cards

    {Enum.into(regular_cards, %{}), Enum.into(spymaster_cards, %{})}
  end

  defp setup_cards(words, color, amount, start_from) do
    selected_words = select_words(words, amount, start_from)

    {setup_regular_cards(selected_words), setup_spymaster_cards(selected_words, color)}
  end

  defp select_words(words, amount, start_from) do
    Enum.slice(words, start_from, amount)
  end

  defp setup_regular_cards(words) do
    Enum.map(words, fn word ->
      {word, Card.setup(word)}
    end)
  end

  defp setup_spymaster_cards(words, color) do
    Enum.map(words, fn word ->
      {word, Card.setup(word, color)}
    end)
  end

  defp red_cards_start(:first_team, "red"), do: @first_team_cards_count
  defp red_cards_start(:first_team, "blue"), do: @second_team_cards_count
  defp blue_cards_start(:first_team, "blue"), do: @first_team_cards_count
  defp blue_cards_start(:first_team, "red"), do: @second_team_cards_count
end
