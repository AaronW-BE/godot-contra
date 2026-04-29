extends Area2D

class_name BulletBase

@export var speed: float = 400.0
@export var direction: Vector2 = Vector2.RIGHT
@export var damage: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
    body_entered.connect(_on_body_entered)


func setup(initial_position: Vector2, initial_direction: Vector2) -> void:
    self.position = initial_position
    self.set_direction(initial_direction)


func set_direction(new_direction: Vector2) -> void:
    direction = new_direction.normalized()


func _physics_process(delta: float) -> void:
    position += direction.normalized() * speed * delta


func _on_body_entered(body: Node) -> void:
    if body.is_in_group("enemies"):
        if body.has_method("take_damage"):
            body.take_damage(damage)
        queue_free()
