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

  @serialization_keys [
    :red_cards,
    :blue_cards
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

  def serialize_state(board, "regular") do
    Map.take(board, @serialization_keys)
    |> Map.put_new(:cards, board.regular_cards)
  end

  def serialize_state(board, "spymaster") do
    Map.take(board, @serialization_keys)
    |> Map.put_new(:cards, board.spymaster_cards)
  end

  def touch_card(board, word) do
    selected_regular_card = Map.fetch!(board.regular_cards, word)

    case Card.touchable?(selected_regular_card) do
      true ->
        selected_spymaster_card = Map.fetch!(board.spymaster_cards, word)
        updated_board = update_state(board, word, selected_spymaster_card)
        {:ok, {selected_spymaster_card.color, updated_board}}
      false ->
        {:error, board}
    end
  end

  defp update_state(board, word, selected_spymaster_card) do
    updated_spymaster_card = Card.touch(selected_spymaster_card)
    spymaster_cards = Map.replace!(board.spymaster_cards, word, updated_spymaster_card)
    regular_cards = Map.replace!(board.regular_cards, word, updated_spymaster_card)


    case updated_spymaster_card.color do
      "red" ->
        red_cards = board.red_cards - 1
        %{board | spymaster_cards: spymaster_cards, regular_cards: regular_cards, red_cards: red_cards}
      "blue" ->
        blue_cards = board.blue_cards - 1
        %{board | spymaster_cards: spymaster_cards, regular_cards: regular_cards, blue_cards: blue_cards}
      "yellow" ->
        yellow_cards = board.yellow_cards - 1
        %{board | spymaster_cards: spymaster_cards, regular_cards: regular_cards, yellow_cards: yellow_cards}
      "black" ->
        black_cards = board.black_cards - 1
        %{board | spymaster_cards: spymaster_cards, regular_cards: regular_cards, black_cards: black_cards}
    end
  end

  defp setup_board(words, first_team, second_team) do
    {first_regular_cards, first_sypermaster_cards} = setup_cards(
      words,
      first_team,
      @first_team_cards_count,
      0
    )

    {second_regular_cards, second_sypermaster_cards} = setup_cards(
      words,
      second_team,
      @second_team_cards_count,
      @first_team_cards_count
    )

    {black_regular_cards, black_spymaster_cards} = setup_cards(
      words,
      "black",
      @black_cards_count,
      @first_team_cards_count + @second_team_cards_count
    )

    {neutral_regular_cards, neutral_spymaster_cards} = setup_cards(
      words,
      "yellow",
      @yellow_cards_count,
      @first_team_cards_count + @second_team_cards_count + @black_cards_count
    )

    regular_cards = first_regular_cards
                    ++ second_regular_cards
                    ++ black_regular_cards
                    ++ neutral_regular_cards


    spymaster_cards = first_sypermaster_cards
                      ++ second_sypermaster_cards
                      ++ black_spymaster_cards
                      ++ neutral_spymaster_cards

    {Enum.into(regular_cards, %{}), Enum.into(spymaster_cards, %{})}
  end

  defp setup_cards(words, color, amount_of_cards, skip_cards) do
    selected_words = select_words(words, amount_of_cards, skip_cards)

    {setup_regular_cards(selected_words), setup_spymaster_cards(selected_words, color)}
  end

  defp select_words(words, skip_cards, amount_of_cards) do
    Enum.slice(words, skip_cards, amount_of_cards)
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
