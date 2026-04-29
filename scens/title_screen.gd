extends Node2D

@export var texture_indicator_1p: TextureRect
@export var texture_indicator_2p: TextureRect
@export var title_bro_texture: TextureRect

@export var main_level_scene: PackedScene

var initialized: bool = false
var ready_change_scene: bool = false
var is_music_finished: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    texture_indicator_1p.visible = false
    texture_indicator_2p.visible = false
    title_bro_texture.visible = false

    $AnimationPlayer.play("push")
    $AnimationPlayer.animation_finished.connect(_initialized_title_screen)


func title_screen_audio_end() -> void:
    print("Audio finished, ready for input")
    initialized = true
    is_music_finished = true
    if ready_change_scene:
        # get_tree().change_scene_to_packed(main_level_scene)
        _start_game()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("select"):
        _toggle_indicators()
    
    if event.is_action_pressed("confirm"):
        if not initialized:
            # complete the push animation and audio before allowing confirmation
            var time_left = $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position
            $AnimationPlayer.advance(time_left)
        else:
            print("Selection confirmed")
            _confirm_selection()

func _initial_indicators() -> void:
    texture_indicator_1p.visible = true
    texture_indicator_2p.visible = false


func _toggle_indicators() -> void:
    texture_indicator_1p.visible = not texture_indicator_1p.visible
    texture_indicator_2p.visible = not texture_indicator_2p.visible


func _initialized_title_screen(anim_name: StringName = "") -> void:
    if anim_name == "push":
        print("Title screen animation finished, playing audio")
        AudioManagerInstance.play_sfx_2d("title_screen", global_position, 0, title_screen_audio_end)
        _initial_indicators()
        title_bro_texture.visible = true
        initialized = true


func _confirm_selection() -> void:
    print("Title screen animation finished, playing audio")
    # play confirmation animation or sound effect here if needed
    if texture_indicator_1p.visible:
        $AnimationPlayer.play("1p_selected")
    elif texture_indicator_2p.visible:
        $AnimationPlayer.play("2p_selected")

    await get_tree().create_timer(1.0).timeout
    ready_change_scene = true
    if is_music_finished:
        # get_tree().change_scene_to_packed(main_level_scene)
        # load the scene by game manager
        _start_game()

func _start_game() -> void:
    # This function can be called after the confirmation animation or sound effect is finished
    # to transition to the main level scene
    queue_free()
    GameManager._load_level(0)
