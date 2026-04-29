extends Node

class_name AudioManager

@export var audio_db: AudioDatabase = preload("res://res/core_sfx_db.tres")

const POOL_SIZE = 1
var pool_2d: Array[AudioStreamPlayer2D] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for i in range(POOL_SIZE):
        var player = AudioStreamPlayer2D.new()
        player.bus = "SFX"
        add_child(player)
        pool_2d.append(player)


func play_sfx_2d(sound_name: String, play_pos: Vector2, pitch_variance: float = 0.0, on_finished: Callable = Callable()) -> void:
    if not audio_db or not audio_db.has_sound(sound_name):
        print("Sound not found: ", sound_name)
        return

    var stream = audio_db.get_library().get(sound_name)

    var player = _get_free_player_2d()
    if player:
        player.stream = stream
        player.position = play_pos
        if pitch_variance > 0.0:
            player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
        else:
            player.pitch_scale = 1.0

        for conn in player.finished.get_connections():
            player.finished.disconnect(conn.callable)
            
        player.finished.connect(func():
            if on_finished.is_valid():
                on_finished.call()
        , CONNECT_ONE_SHOT)
        player.play()
    else:
        push_warning("No free audio player available to play: ", sound_name)

func _get_free_player_2d() -> AudioStreamPlayer2D:
    for player in pool_2d:
        if not player.playing:
            return player
    return null
