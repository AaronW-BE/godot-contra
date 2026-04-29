extends Node2D

@export var speed: float = 100.0
@export var health: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.is_in_group("player_bullets"):
        health -= 10
        if health <= 0:
            queue_free()

    if body.is_in_group("player"):
        print("Player hit!")
        # get player node and call a method to damage the player
        var player = body
        player.take_damage(1)  # Assuming the player has a take_damage method
