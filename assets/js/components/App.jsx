import React from 'react';
import {observer} from 'mobx-react';
import Lobby from "./Lobby";
import Game from "./Game";

const App = observer(function({ gameState }){
  switch (gameState.status) {
    case "uninitialized":
      return <h1>Loading</h1>;
    case "lobby":
      return <Lobby gameState={gameState}/>;
    default:
      return <Game/>;
  }
});

export default App;

