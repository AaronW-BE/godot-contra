extends Node2D

@onready var player = $Player
@onready var camera = $MainCamera
@onready var left_wall = $LeftWall

var is_player_dead: bool = false

func _ready() -> void:
    player.player_life_changed.connect(_on_player_life_changed)

func _process(_delta):
    if is_instance_valid(player) and is_instance_valid(camera):
        # 固定Y轴高度，符合经典横版设定
        camera.position.y = 120
        
        # 强制只向右推移
        var target_x = player.position.x
        if target_x > camera.position.x:
            camera.position.x = target_x
            
        # 更新阻拦墙边界
        left_wall.position.x = camera.position.x - 128
        
        # 确保玩家无法穿过屏幕左侧
        if player.position.x < left_wall.position.x + 8:
            player.position.x = left_wall.position.x + 8

    if not is_player_dead:
        check_player_fallen()
    


func check_player_fallen():
    var camera_bottom_y = camera.global_position.y + (get_viewport_rect().size.y / 2.0)
    if is_instance_valid(player):
        var shape = player.get_node("CollisionShape2D").shape as RectangleShape2D
        var visual_margin = shape.size.y / 2.0
        if player.position.y > camera_bottom_y - visual_margin:
            player.die()
            is_player_dead = true

            get_tree().create_timer(1.0).connect("timeout", _on_death_timeout)

func start():
    print("Level main scene started")


func _on_player_life_changed(_name, new_life_count):
    print("Player ", _name, ", life changed: ", new_life_count)

func _on_death_timeout():
    pass