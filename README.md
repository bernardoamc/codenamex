# Codenamex

To start your Phoenix server in `iex`:

  * iex -S mix phx.server

## Initializing a Game

```ex
game = Codenamex.Game.setup(:game_id)
%Codenamex.Game{
  blue_team: nil,
  board: %Codenamex.Game.Board{
    black_cards: 1,
    blue_cards: 8,
    cards: %{
      "Bite" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Broken" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Cape" => %Codenamex.Game.Card{color: "red", touched: false},
      "Chime" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Crisp" => %Codenamex.Game.Card{color: "red", touched: false},
      "Ebony" => %Codenamex.Game.Card{color: "red", touched: false},
      "Garbage" => %Codenamex.Game.Card{color: "red", touched: false},
      "Girl" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Gumball" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Kite" => %Codenamex.Game.Card{color: "red", touched: false},
      "Lag" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Lightsaber" => %Codenamex.Game.Card{color: "black", touched: false},
      "Money" => %Codenamex.Game.Card{color: "red", touched: false},
      "Paper" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Plate" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Pong" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Post" => %Codenamex.Game.Card{color: "red", touched: false},
      "Quarantine" => %Codenamex.Game.Card{color: "red", touched: false},
      "Queen" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Rainwater" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Roundabout" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Smith" => %Codenamex.Game.Card{color: "blue", touched: false},
      "Snow" => %Codenamex.Game.Card{color: "red", touched: false},
      "Stowaway" => %Codenamex.Game.Card{color: "yellow", touched: false},
      "Toast" => %Codenamex.Game.Card{color: "blue", touched: false}
    },
    first_team: "red",
    red_cards: 9,
    words: ["Smith", "Stowaway", "Paper", "Cape", "Ebony", "Rainwater",
     "Garbage", "Broken", "Lag", "Plate", "Queen", "Bite", "Kite", "Lightsaber",
     "Toast", "Roundabout", "Crisp", "Quarantine", "Chime", "Pong", "Girl",
     "Post", "Money", "Gumball", "Snow"],
    yellow_cards: 7
  },
  id: :foo,
  over: false,
  red_team: nil,
  turn: "red",
  winner: nil
}
```

## Touching a card

```ex
iex(2)> Codenamex.Game.touch_card(game, "Bite")
{"blue",
 %Codenamex.Game{
   blue_team: nil,
   board: %Codenamex.Game.Board{
     black_cards: 1,
     blue_cards: 7,
     cards: %{
       "Bite" => %Codenamex.Game.Card{color: "blue", touched: true},
       "Broken" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Cape" => %Codenamex.Game.Card{color: "red", touched: false},
       "Chime" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Crisp" => %Codenamex.Game.Card{color: "red", touched: false},
       "Ebony" => %Codenamex.Game.Card{color: "red", touched: false},
       "Garbage" => %Codenamex.Game.Card{color: "red", touched: false},
       "Girl" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Gumball" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Kite" => %Codenamex.Game.Card{color: "red", touched: false},
       "Lag" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Lightsaber" => %Codenamex.Game.Card{color: "black", touched: false},
       "Money" => %Codenamex.Game.Card{color: "red", touched: false},
       "Paper" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Plate" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Pong" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Post" => %Codenamex.Game.Card{color: "red", touched: false},
       "Quarantine" => %Codenamex.Game.Card{color: "red", touched: false},
       "Queen" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Rainwater" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Roundabout" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Smith" => %Codenamex.Game.Card{color: "blue", touched: false},
       "Snow" => %Codenamex.Game.Card{color: "red", touched: false},
       "Stowaway" => %Codenamex.Game.Card{color: "yellow", touched: false},
       "Toast" => %Codenamex.Game.Card{color: "blue", touched: false}
     },
     first_team: "red",
     red_cards: 9,
     words: ["Smith", "Stowaway", "Paper", "Cape", "Ebony", "Rainwater",
      "Garbage", "Broken", "Lag", "Plate", "Queen", "Bite", "Kite",
      "Lightsaber", "Toast", "Roundabout", "Crisp", "Quarantine", "Chime",
      "Pong", "Girl", "Post", "Money", "Gumball", "Snow"],
     yellow_cards: 7
   },
   id: :game_id,
   over: false,
   red_team: nil,
   turn: "blue",
   winner: nil
 }}
```
