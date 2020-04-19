import { observable, action, computed } from "mobx";

export class GameState {
  @observable status = "uninitialized";
  @observable _players = null;
  @observable _state = null;

  @computed get guests() {
    return this._players ? this._players.guests : [];
  }

  @computed get redTeam() {
    if (!this._players) {
      return { spymaster: null, players: [] };
    }

    return {
      players: this._players.red_team.filter((player) => player.regular),
      spymaster: this._players.red_team.find((player) => player.spymaster),
    };
  }

  @computed get blueTeam() {
    if (!this._players) {
      return { spymaster: null, players: [] };
    }

    return {
      players: this._players.blue_team.filter((player) => player.regular),
      spymaster: this._players.blue_team.find((player) => player.spymaster),
    };
  }

  @computed get cards() {
    if (this.status !== "game" || !this._state) {
      return {};
    }

    return this._state.board.cards;
  }

  @computed get isOver() {
    if (!this._state) return false;

    return this._state.over;
  }

  @computed get currentTurn() {
    if (!this._state) return "red";

    return this._state.turn;
  }

  @computed get blueCards() {
    if (!this._state) return 0;

    return this._state.board.blue_cards;
  }

  @computed get blueCardsFound() {
    if (!this._state) return 0;

    return Object.values(this._state.board.cards).filter(
      (card) => card.color === "blue"
    ).length;
  }

  @computed get redCardsFound() {
    if (!this._state) return 0;

    return Object.values(this._state.board.cards).filter(
      (card) => card.color === "red"
    ).length;
  }

  @computed get redCards() {
    if (!this._state) return 0;

    return this._state.board.red_cards;
  }

  @computed get winner() {
    if (!this._state) return null;

    return this._state.winner;
  }

  @computed get playerStatus() {
    const guest = { team: "guest", isSpymaster: false };

    if (!this._players) return guest;

    const { blue_team, red_team } = this._players;

    let player = blue_team.find((player) => player.name === this.playerName);
    if (player) {
      return { team: "blue", isSpymaster: player.spymaster };
    }

    player = red_team.find((player) => player.name === this.playerName);
    if (player) {
      return { team: "red", isSpymaster: player.spymaster };
    }

    return guest;
  }

  @computed get playerCanPlay() {
    const status = this.playerStatus;

    return status.team === this.currentTurn && (!this.isOver);
  }

  constructor({ roomName, playerName, socket }) {
    this.roomName = roomName;
    this.playerName = playerName;
    this.socket = socket;
  }

  connect() {
    this.socket.connect();

    this.roomChannel = this.socket.channel(`room:${this.roomName}`, {
      player_name: this.playerName,
    });

    this.roomChannel
      .join()
      .receive("ok", this._handleJoinRoom)
      .receive("error", this._handleError);

    this.roomChannel.on("joined_room", this._handleJoinedRoom);
    this.roomChannel.on("team_change", this._handleTeamChange);
    this.roomChannel.on("game_started", this._handleGameStarted);
    this.roomChannel.on("touched_card", this._handleTouchedCard);
    this.roomChannel.on("new_turn", this._handleNewTurn);
  }

  @action.bound
  _handleJoinRoom(payload) {
    this.status = payload.status;
    this._players = payload.players;
  }

  @action.bound
  _handleError(error) {
    console.error("error", error);
  }

  @action.bound
  _handleJoinedRoom(payload) {
    console.log("joined_room", payload);
  }

  @action.bound
  _handleTeamChange(payload) {
    this._players = payload.players;
  }

  @action.bound
  _handleGameStarted(payload) {
    this.status = "game";
    this._state = payload.state;
  }

  @action.bound
  _handleTouchedCard(payload) {
    const { over, status, touched_card, turn, winner } = payload.state;

    this._state.over = over;
    this._state.status = status;
    this._state.turn = turn;
    this._state.winner = winner;

    const { color, touched, word } = touched_card;

    const card = this._state.board.cards[word];
    card.color = color;
    card.touched = touched;
  }

  @action.bound
  _handleNewTurn(payload) {
    const { over, status, turn, winner } = payload.state;
    this._state.over = over;
    this._state.status = status;
    this._state.turn = turn;
    this._state.winner = winner;
  }

  @action
  touchCard(word) {
    this.roomChannel
      .push("touch_card", { word })
      .receive("ok", (payload) => console.log("touch_card", payload));
  }

  pickTeam(team, role) {
    this.roomChannel
      .push("pick_team", { type: role, team })
      .receive("error", this._handleError);
  }

  startGame() {
    this.roomChannel.push("start_game", {}).receive("error", this._handleError);
  }

  nextTurn() {
    this.roomChannel.push("next_turn", {}).receive("error", this._handleError);
  }
}
