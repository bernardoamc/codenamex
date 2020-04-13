defmodule Codenamex.Game.Board do
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
    cards: nil,
    first_team: nil,
    red_cards: nil,
    blue_cards: nil,
    black_cards: @black_cards_count,
    yellow_cards: @yellow_cards_count
  ]

  def setup() do
    [first_team, second_team] = Team.pick_order()
    words = Dictionary.fetch(@cards_count)

    %__MODULE__{
      words: words |> Enum.shuffle,
      cards: setup_board(words, first_team, second_team),
      first_team: first_team,
      red_cards: red_cards_start(:first_team, first_team),
      blue_cards: blue_cards_start(:first_team, first_team)
    }
  end

  def touch_card(board, word) do
    updated_card = Map.fetch!(board.cards, word) |> Card.touch
    cards = Map.replace!(board.cards, word, updated_card)

    updated_board = case updated_card.color do
      "red" -> %{board | cards: cards, red_cards: board.red_cards - 1}
      "blue" -> %{board | cards: cards, blue_cards: board.blue_cards - 1}
      "yellow" -> %{board | cards: cards, yellow_cards: board.yellow_cards - 1}
      "black" -> %{board | cards: cards, black_cards: 0}
    end

    {updated_card.color, updated_board}
  end

  defp setup_board(words, first_team, second_team) do
    first_team_cards = setup_cards(
      words,
      first_team,
      @first_team_cards_count,
      0
    )

    second_team_cards = setup_cards(
      words,
      second_team,
      @second_team_cards_count,
      @first_team_cards_count
    )

    black_cards = setup_cards(
      words,
      "black",
      @black_cards_count,
      @first_team_cards_count + @second_team_cards_count
    )

    neutral_cards = setup_cards(
      words,
      "yellow",
      @yellow_cards_count,
      @first_team_cards_count + @second_team_cards_count + @black_cards_count
    )

    first_team_cards ++ second_team_cards ++ black_cards ++ neutral_cards
    |> Enum.into(%{})
  end

  defp setup_cards(words, color, amount_of_cards, skip_cards) do
    words
    |> Enum.slice(skip_cards, amount_of_cards)
    |> Enum.map(fn word ->
      {word, %Card{color: color}}
    end)
  end

  defp red_cards_start(:first_team, "red"), do: @first_team_cards_count
  defp red_cards_start(:first_team, "blue"), do: @second_team_cards_count
  defp blue_cards_start(:first_team, "blue"), do: @first_team_cards_count
  defp blue_cards_start(:first_team, "red"), do: @second_team_cards_count
end
