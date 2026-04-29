## Player.gd
extends CharacterBody2D


### *** Signals
signal player_life_changed(name, new_life_count)


var is_shooting: bool = false

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

const KNOCKBACK_FORCE_X = 100.0
const KNOCKBACK_FORCE_Y = -200.0



@export var bullet_scene:PackedScene

@onready var anim_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var muzzle_anchor = $Visuals/MuzzleAnchor


# Player state variables
var life_count: int = 3
var max_life: int = 30

var direction: Vector2 = Vector2.ZERO

var is_jumping: bool = false
var can_move: bool = true
var is_dead: bool = false

func _ready() -> void:
    anim_player.connect("animation_finished", _on_animation_finished)
    anim_player.play("idle")

func _physics_process(delta: float) -> void:
    # Add gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    if is_dead:
        if is_on_floor():
            velocity.x = move_toward(velocity.x, 0, SPEED * 3 * delta)
        move_and_slide()
        return

    # Jump start
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        is_jumping = true
        anim_player.play("jump")

    direction.x = Input.get_axis("move_left", "move_right")
    direction.y = Input.get_axis("move_up", "move_down")

    if direction.x != 0 and can_move:
        velocity.x = direction.x * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()

    if is_on_floor():
        if is_jumping:
            is_jumping = false
        if not is_shooting:
            if direction.x == 0 and direction.y == -1:
                can_move = false
                anim_player.play("up")
                direction.y = -1
            elif direction.x == 0 and direction.y == 1:
                can_move = false
                anim_player.play("down")
                direction.y = 1
            # elif direction.x < 0:
            #     can_move = true
            #     anim_player.play("run_right")
            #     visuals.scale.x = -1  # Flip the sprite to face left
            elif direction.x > 0 or direction.x < 0:
                can_move = true
                if direction.y == 1:
                    anim_player.play("run_right_down")
                elif direction.y == -1:
                    anim_player.play("run_right_up")
                elif direction.y == 0:
                    anim_player.play("run_right")
                

                visuals.scale.x = -1 if direction.x < 0 else 1
            else:
                anim_player.play("idle")
        else:
            print("Shooting animation, direction: ", direction.length() > 0)
            if direction.abs().x > 0 and direction.y == 0:
                anim_player.play("run_shoot")
            elif direction.abs().x > 0 and direction.abs().y > 0:
                anim_player.play("run_right_up")
            elif direction.x == 0 and direction.y == -1:
                anim_player.play("up")
            elif direction.x == 0 and direction.y == 1:
                anim_player.play("down")
            else:
                anim_player.play("stand_shoot")
    else:
        # 空中持续显示跳跃动画
        if anim_player.current_animation != "jump":
            anim_player.play("jump")


func _input(event: InputEvent) -> void:
    if is_dead:
        return
    if event.is_action_pressed("shoot") and not is_shooting:
        print("Pew! Pew!")
        is_shooting = true
        print("Direction: ", direction.abs().x)
        # if direction.abs().x > 0:
        #     anim_player.play("run_shoot")
        # else:
        #     anim_player.play("stand_shoot")

        var spawn_pos: Vector2 = muzzle_anchor.global_position

        # 如果跳跃并且向下射击
        if is_jumping and direction.abs().y == 1:
            var rect = Rect2(visuals.global_position, Vector2.ZERO)
            spawn_pos.x = rect.get_center().x
            print("direction y: ", direction.y)
            if direction.y > 0:
                spawn_pos.y = rect.position.y  # 向下射击，子弹从角色底部生成
            else:
                spawn_pos.y = rect.position.y - 10 # 向上射击，子弹从角色顶部生成

        shoot(spawn_pos)

        # 延迟0.5s后重置射击状态
        await get_tree().create_timer(0.25).timeout
        is_shooting = false

    elif event.is_action_released("jump") and not is_jumping:
        is_jumping = true
        anim_player.play("jump")
    elif event.is_action_pressed("move_up") and not is_jumping:
        print("Moving up!")
        anim_player.play("up")
    elif event.is_action_pressed("move_down") and not is_jumping:
        print("Moving down!")
        anim_player.play("down")


func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "stand_shoot":
        is_shooting = false


func _gen_shoot_direction() -> Vector2:
    if direction.y == 1 and is_on_floor():
        direction.y = 0
    if direction.length() == 0:
        var last_direction = Vector2.LEFT if visuals.scale.x < 0 else Vector2.RIGHT
        return last_direction

    return direction.normalized()


func spawn_player() -> void:
    # Spawn player at the start of the level or after death
    pass

func shoot(spawn_position: Vector2) -> void:
    var bullet = bullet_scene.instantiate()
    bullet.setup(spawn_position, _gen_shoot_direction())
    get_parent().add_child(bullet)


func die() -> void:
    life_count -= 1
    if life_count < 0:
        print("Game Over!")
        # Handle game over logic here (e.g., show game over screen, reset level, etc.)
        player_life_changed.emit("Player", life_count)
    else:
        print("Player died! Remaining lives: ", life_count)
        # Handle respawn logic here (e.g., reset player position, play death animation, etc.)
        player_life_changed.emit("Player", life_count)

    var is_need_respawn: bool = life_count >= 0


    is_dead = true
    anim_player.play("die")
    can_move = false
    velocity = Vector2.ZERO
    AudioManagerInstance.play_sfx_2d("death", global_position)

    var knockback_direction = -sign(visuals.scale.x)
    if knockback_direction == 0:
        knockback_direction = -1
    velocity.x = knockback_direction * KNOCKBACK_FORCE_X
    velocity.y = KNOCKBACK_FORCE_Y
    await anim_player.animation_finished
    await get_tree().create_timer(3.0).timeout

    if is_need_respawn:
        spawn_player()
        is_dead = false
        can_move = true
    else:
        queue_free()


func take_damage(amount: int) -> void:
    print("Player takes damage: ", amount)
    if anim_player.current_animation != "die":
        die()
        
