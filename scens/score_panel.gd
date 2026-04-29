extends Node2D

@export var t_1p_lifes: Label
@export var t_1p_scores: Label
@export var t_2p_lifes: Label
@export var t_2p_scores: Label
@export var t_stage: Label
@export var t_level_name: Label
@export var t_high_score: Label


func _ready() -> void:
    pass # Replace with function body.


func setup(player_1_data: PlayerData, player_2_data: PlayerData) -> void:
    t_1p_lifes.text = str(player_1_data.life)
    t_1p_scores.text = str(player_1_data.score)

    if player_2_data == null:
        $CanvasLayer/VBoxContainer2.hide()
        t_2p_lifes.hide()
        t_2p_scores.hide()
    else:
        $CanvasLayer/VBoxContainer2.show()
        t_2p_scores.show()
        t_2p_scores.text = str(player_2_data.score)


func setup_level(stage: int, level_name: String, high_score: int = 0) -> void:
    t_stage.text = str(stage)
    t_level_name.text = level_name
    t_high_score.text = str(high_score)
