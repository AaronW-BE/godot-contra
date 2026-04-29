extends Control

@export var p1_medal_texture: Texture2D
@export var p2_medal_texture: Texture2D

@export var max_quantity: int = 30

@export var max_display_quantity: int = 4

@export var quantity: int = 3

@onready var player_1_models = get_node("player_1_medals")
@onready var player_2_models = get_node("player_2_medals")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for i in range(max_display_quantity):
        var medal = TextureRect.new()
        medal.texture = p1_medal_texture
        medal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
        player_1_models.add_child(medal)
        medal.position = Vector2(i * (medal.texture.get_width() + 5), 0)

    for i in range(max_display_quantity):
        var medal = TextureRect.new()
        medal.texture = p2_medal_texture
        medal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
        player_2_models.add_child(medal)
        medal.position = Vector2(i * (medal.texture.get_width() + 5), 0)


func update_model(count: int) -> void:
    self.quantity = count
    for i in range(max_display_quantity):
        var medal = get_child(i) as TextureRect
        medal.visible = i < quantity
    
    # redraw the control to reflect changes
    queue_redraw()
