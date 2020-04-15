let Game = {
  init(socket, element) {
    let codenamex = window.codenamex || {};
    if(!codenamex.roomName) { return }

    socket.connect();

    console.log(`room:${codenamex.roomName}`);
    let roomChannel = socket.channel(
      `room:${codenamex.roomName}`,
      { player_name: codenamex.playerName }
    );

    roomChannel.join()
     .receive("ok", resp => console.log("game", resp))
     .receive("error", e => console.log("error joining channel", e))

    roomChannel.on(`${codenamex.roomName}:joined`, (resp) => {
      console.log(resp);
    })
  }
};

export default Game