extends Area2D

const SPEED = 400.0

var direction := Vector2.RIGHT

func _process(delta):
	position += direction * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	# Placeholder: Delete bullet when hitting a wall or enemy.
	# We don't want it to instantly delete on player for now
	if body.name != "Player":
		queue_free()
