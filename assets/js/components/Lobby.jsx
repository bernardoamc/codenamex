import React from "react";
import {observer} from "mobx-react";


const Lobby = observer(function({ gameState }) {
  const { playerName, roomName } = window.codenamex;

  return (
    <h1>
      Welcome to {roomName}, {playerName}
      <pre>{JSON.stringify(gameState.players, null, "  ")}</pre>
    </h1>
  );
});

export default Lobby;
