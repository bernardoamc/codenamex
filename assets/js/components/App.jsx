import React from "react";
import { observer, Provider, inject } from "mobx-react";
import Lobby from "./Lobby";
import Game from "./Game";

function Loading() {
  return <h1>Loading</h1>;
}

const Route = inject("gameState")(
  observer(function ({ gameState }) {
    switch (gameState.status) {
      case "uninitialized":
        return <Loading />;
      case "lobby":
        return <Lobby />;
      case "game":
        return <Game />;
      default:
        return <h1>Something went wrong</h1>;
    }
  })
);

const App = observer(function ({ gameState }) {
  return (
    <Provider gameState={gameState}>
      <Route />
    </Provider>
  );
});

export default App;
