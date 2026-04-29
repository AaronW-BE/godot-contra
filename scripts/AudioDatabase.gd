extends Resource

class_name AudioDatabase

@export var bank_name : String = "Default Bank"
@export var sfx_library : Dictionary[String, AudioStream] = {}


func get_library() -> Dictionary[String, AudioStream]:
    return sfx_library

func has_sound(sound_name: String) -> bool:
    return sfx_library.has(sound_name)

func get_sound(sound_name: String) -> AudioStream:
    if sfx_library.has(sound_name):
        return sfx_library[sound_name]
    else:
        print("Sound not found in database: ", sound_name)
        return null