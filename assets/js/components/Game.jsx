import React from "react";
import _ from "lodash";

// Codenamex.Game.Dictionary.fetch(25)
const SAMPLE_WORDS = [
  "Glass",
  "Plate",
  "Moscow",
  "Teacher",
  "Jupiter",
  "Battery",
  "Time",
  "Casino",
  "Bank",
  "Triangle",
  "Cold",
  "France",
  "Bill",
  "Draft",
  "Lap",
  "King",
  "Vet",
  "Bomb",
  "Undertaker",
  "Board",
  "Phoenix",
  "Night",
  "Hotel",
  "Gas",
  "Opera",
];

const ROW_LENGTH = 5;

export default function App() {
  const rows = _.chain(SAMPLE_WORDS)
    .map((word) => (
      <div className="game-board__card">
        <div className="game-board__card-word">{word}</div>
      </div>
    ))
    .chunk(5)
    .map((cards) => <div className="game-board__card-row">{cards}</div>)
    .value();

  return <div className="game-board">{rows}</div>;
}
