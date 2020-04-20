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

const Card = inject("gameState")(
  observer(({ card, gameState }) => {
    const classNames = ["game-board__card"];

    if (card.color) {
      classNames.push(`game-board__card--${card.color}`);
    }

    if (card.touched) {
      classNames.push("game-board__card--touched");
    }

    const handleOnClick = () => {
      gameState.touchCard(card.word);
    };

    return (
      <button
        className={classNames.join(" ")}
        onClick={handleOnClick}
        disabled={card.touched || !gameState.playerCanTouchCard}
      >
        <div className="game-board__card-word">{card.word}</div>
      </button>
    );
  })
);

const Game = inject("gameState")(
  observer(function ({ gameState }) {
    const cells = Object.values(gameState.cards).map((card, cardIndex) => (
      <Card key={cardIndex} card={card} />
    ));

    const rows = chunk(cells, ROW_LENGTH).map((cards, rowIndex) => (
      <div key={rowIndex} className="game-board__card-row">
        {cards}
      </div>
    ));

    const handleNextTurn = () => {
      gameState.nextTurn();
    };

    return (
      <div>
        <h1>
          Team {gameState.playerStatus.team}
          {gameState.playerStatus.isSpymaster ? " (Spymaster)" : null}
        </h1>
        <table>
          <tbody>
            <tr>
              <td>Current turn</td>
              <td>{gameState.currentTurn}</td>
            </tr>
            <tr>
              <td>Blue cards</td>
              <td>
                {gameState.blueCardsFound} / {gameState.blueCards}
              </td>
            </tr>
            <tr>
              <td>Red cards</td>
              <td>
                {gameState.redCardsFound} / {gameState.redCards}
              </td>
            </tr>
            <tr>
              <td>Is over?</td>
              <td>{gameState.isOver ? "Yes" : "No"}</td>
            </tr>
            <tr>
              <td>Winner</td>
              <td>{gameState.winner ?? "None"}</td>
            </tr>
          </tbody>
        </table>
        <div className="game-board">{rows}</div>
        <button onClick={handleNextTurn} disabled={!gameState.playerCanEndTurn}>
          Next turn
        </button>
      </div>
    );
  })
);

export default Game;
