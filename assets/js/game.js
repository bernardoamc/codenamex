let Game = {
  init(socket, element) {
    let codenamex = window.codenamex || {};
    if(!codenamex.roomName) { return }

    socket.connect();

    let roomChannel = socket.channel(
      `room:${codenamex.roomName}`,
      { player_name: codenamex.playerName }
    );

    roomChannel.join()
     .receive("ok", resp => console.log("game", resp))
     .receive("error", e => console.log("error joining channel", e))

    roomChannel.on("joined_room", (resp) => {
      console.log("broadcasted_joined_room", resp);
    })

    roomChannel.on("team_change", (resp) => {
      console.log("broadcasted_team_change", resp);
    })

    roomChannel.on("game_started", (resp) => {
      console.log("broadcasted_game_started", resp);
      let cards = resp.state.board.cards
      let words = Object.keys(cards)

      console.log("word", currentCard)
      roomChannel.push("touch_card", {word: words[0]})
        .receive("ok", (resp) => console.log("touch_card:", resp))
    })

    roomChannel.on("touched_card", (resp) => {
      console.log("touched_card", resp);
    })

    roomChannel.push("pick_team", {type: "regular", team: "red"})
      .receive("ok", (resp) => console.log("pick_team:", resp))

    roomChannel.push("start_game", {})
      .receive("ok", (resp) => console.log("start_game:", resp))
  }
};

export default Game
