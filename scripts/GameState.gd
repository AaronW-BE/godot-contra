extends Resource

class_name GameState

@export var highest_score: int = 10000

@export var playerMode: Types.PlayerMode = Types.PlayerMode.SINGLE_PLAYER

@export var player_1_data: PlayerData = null
@export var player_2_data: PlayerData = null