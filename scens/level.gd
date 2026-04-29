extends Node2D

@export var score_panel_scene: PackedScene
@export var main_scene: PackedScene

var score_panel_instance: Node = null
var level_main_scene_instance: Node = null


func setup(_score_panel_scene: Node, _main_scene: Node) -> void:
    score_panel_instance = _score_panel_scene
    level_main_scene_instance = _main_scene
    level_main_scene_instance.name = "LevelMainScene"
    level_main_scene_instance.position = Vector2.ZERO
    add_child(score_panel_instance)


func start() -> void:
    get_tree().create_timer(3).timeout.connect(enter_scene, CONNECT_ONE_SHOT)


func enter_scene() -> void:
    score_panel_instance.queue_free()
    add_child(level_main_scene_instance)
    $AnimationPlayer.play("enter")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "enter":
        level_main_scene_instance.start()