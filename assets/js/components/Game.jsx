import React from "react";
import { inject, observer } from "mobx-react";

const ROW_LENGTH = 5;

function chunk(array, size) {
  return array.reduce((result, current) => {
    let group = result[result.length - 1];

    if (!group || group.length === size) {
      group = [];
      result.push(group);
    }

    group.push(current);

    return result;
  }, []);
}

const Game = inject("gameState")(
  observer(function ({ gameState }) {
    const cells = Object.values(gameState.cards).map((card) => {
      return (
        <div key={card.word} className="game-board__card">
          <div className="game-board__card-word">{card.word}</div>
        </div>
      );
    });

    const rows = chunk(cells, ROW_LENGTH).map((cards, rowIndex) => (
      <div key={rowIndex} className="game-board__card-row">
        {cards}
      </div>
    ));

    return <div className="game-board">{rows}</div>;
  })
);

export default Game;
