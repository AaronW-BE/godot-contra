extends Node

@export var score_scene: PackedScene = preload("res://scens/score_panel.tscn")
@export var game_levels: LevelList = preload("res://res/all_levels.tres")

@export var level_container: PackedScene = preload("res://scens/level.tscn")

var game_state: GameState = null

var score_screen_instance: Node = null
var level_container_instance: Node = null
var current_level_index: int = 0
var current_level_instance: Node = null

func _ready() -> void:
    game_state = GameState.new()
    game_state.player_1_data = PlayerData.new()



func set_player_mode(mode: Types.PlayerMode) -> void:
    game_state.playerMode = mode
    if mode == Types.PlayerMode.SINGLE_PLAYER:
        game_state.player_2_data = null
    else:
        game_state.player_2_data = PlayerData.new()
    pass


func _load_level(index: int) -> void:
    # Load the level scene from the LevelList resource
    # The level contains the score screen and the main gameplay scene
    if index < 0 or index >= game_levels.levels.size():
        print("Invalid level index: ", index)
        return

    var level_data = game_levels.levels[index]
    if current_level_instance:
        current_level_instance.queue_free()

    level_container_instance = level_container.instantiate()
    
    # Instantiate the score screen and main gameplay scene from the level data
    score_screen_instance = score_scene.instantiate()
    score_screen_instance.setup_level(level_data.stage, level_data.level_name, level_data.high_score)
    score_screen_instance.setup(
        game_state.player_1_data,
        game_state.player_2_data
    )

    current_level_instance = level_data.level_scene.instantiate()
    
    level_container_instance.setup(score_screen_instance, current_level_instance)
    add_child(level_container_instance)
    level_container_instance.start()
    pass

    
