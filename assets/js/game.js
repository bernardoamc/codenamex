import { observable, action, computed } from "mobx";

export class GameState {
  @observable status = "uninitialized";
  @observable players = null;
  @observable state = null;

  @computed get guests() {
    return this.players ? this.players.guests : [];
  }

  @computed get redTeam() {
    if (!this.players) {
      return { spyMaster: null, players: [] };
    }

    return {
      players: this.players.red_team.filter((player) => player.regular),
      spyMaster: this.players.red_team.find((player) => player.spymaster),
    };
  }

  @computed get blueTeam() {
    if (!this.players) {
      return { spyMaster: null, players: [] };
    }

    return {
      players: this.players.blue_team.filter((player) => player.regular),
      spyMaster: this.players.blue_team.find((player) => player.spymaster),
    };
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
  }

  @action.bound
  _handleJoinRoom(payload) {
    this.status = payload.status;
    this.players = payload.players;
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
    this.players = payload.players;
  }

  @action.bound
  _handleGameStarted(payload) {
    this.status = "game";
    this.state = payload.state;
  }

  @action.bound
  _handleTouchedCard(payload) {
    console.log("touched_card", payload);
  }

  @action
  touchCard(word) {
    this.roomChannel
      .push("touch_card", { word })
      .receive("ok", (payload) => console.log("touch_card", payload));
  }

  @action
  pickTeam(team, role) {
    this.roomChannel
      .push("pick_team", { type: role, team })
      .receive("ok", (resp) => console.log("pick_team", resp));
  }

  @action
  startGame() {
    this.roomChannel
      .push("start_game", {})
      .receive("ok", (resp) => console.log("start_game", resp));
  }
}
