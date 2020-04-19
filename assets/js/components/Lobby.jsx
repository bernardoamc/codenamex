import React from "react";
import { observer } from "mobx-react";

const Lobby = observer(function ({ gameState }) {
  return (
    <div>
      <h1>
        Welcome to {gameState.roomName}, {gameState.playerName}
      </h1>

      <div className="lobby__guests">
        <h2>Guests</h2>
        <ul>
          {gameState.players.guests.map((player) => (
            <li>{player.name}</li>
          ))}
        </ul>
      </div>
      <div className="lobby__teams">
        <div className="lobby__team lobby__team--red">
          <h2>Red Team</h2>
          <div className="lobby__team-spymaster">
            <h3>Spymaster</h3>
            <button>Select</button>
          </div>
          <h3>Players</h3>
          <ul>
            {gameState.players.red_team.map((player) => (
              <li>{player.name}</li>
            ))}
          </ul>
          <button>Select</button>
        </div>
        <div className="lobby__team lobby__team--blue">
          <h2>Blue Team</h2>
          <div className="lobby__team-spymaster">
            <h3>Spymaster</h3>
            <button>Select</button>
          </div>
          <h3>Players</h3>
          <ul>
            {gameState.players.blue_team.map((player) => (
              <li>{player.name}</li>
            ))}
          </ul>
          <button>Select</button>
        </div>
      </div>
      <button>Start game</button>
    </div>
  );
});

export default Lobby;
