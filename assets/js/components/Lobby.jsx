import React from "react";
import { observer, inject } from "mobx-react";

const Team = inject("gameState")(
  observer(function ({ teamColor, title, gameState, team }) {
    const handleSpymasterClick = () => {
      gameState.pickTeam(teamColor, "spymaster");
    };

    const handleRegularClick = () => {
      gameState.pickTeam(teamColor, "regular");
    };

    return (
      <div className={`lobby__team lobby__team--${teamColor}`}>
        <h2>{title}</h2>
        <div className="lobby__team-spymaster">
          <h3>Spymaster</h3>
          {team.spymaster ? (
            <ul>
              <li>{team.spymaster.name}</li>
            </ul>
          ) : (
            <button onClick={handleSpymasterClick}>Select</button>
          )}
        </div>
        <h3>Players</h3>
        <ul>
          {team.players.map((player) => (
            <li key={player.name}>{player.name}</li>
          ))}
        </ul>
        <button onClick={handleRegularClick}>Select</button>
      </div>
    );
  })
);

const Lobby = inject("gameState")(
  observer(function ({ gameState }) {
    const handleStartGameClick = () => {
      gameState.startGame();
    };

    return (
      <div>
        <h1>
          Welcome to {gameState.roomName}, {gameState.playerName}
        </h1>
        <div className="lobby__container">
          <div className="lobby__guests">
            <h2>Guests</h2>
            <ul>
              {gameState.guests.map((player) => (
                <li key={player.name}>{player.name}</li>
              ))}
            </ul>
          </div>
          <Team
            teamColor="red"
            title="Red Team"
            team={gameState.redTeam}
          />
          <Team
            teamColor="blue"
            title="Blue Team"
            team={gameState.blueTeam}
          />
        </div>
        <button onClick={handleStartGameClick}>Start game</button>
      </div>
    );
  })
);

export default Lobby;
