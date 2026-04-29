@tool
extends HSplitContainer

@onready var _panel = $InspectorPanel/VBoxContainer/ScrollContainer

@export var plugin_setting_speed: float = 10.0
@export var plugin_enabled: bool = true


var inspector: EditorInspector
@onready var menu_button: MenuButton = $InspectorPanel/VBoxContainer/HBoxContainer/MenuButton


func _setup_menu() -> void:
    # 安全检查：防止路径写错导致后续代码崩溃
    if not is_instance_valid(menu_button):
        push_error("MenuButton 没找到！请检查 get_node() 里面的路径是否与 dock_ui.tscn 场景树完全一致。")
        return
        
    var popup: PopupMenu = menu_button.get_popup()
    
    # 清理可能存在的旧选项（防止插件重新加载时菜单项重复）
    popup.clear()
    
    popup.add_item("生成测试数据", 0)
    popup.add_item("清理缓存", 1)
    popup.add_separator() 
    popup.add_item("打开设置面板", 2)

    var input_event = InputEventKey.new()
    var keycode = Key.KEY_S
    var use_ctrl = true
    var use_shift = false
    input_event.keycode = keycode
    input_event.ctrl_pressed = use_ctrl
    input_event.shift_pressed = use_shift
    
    # 包装为 Shortcut 资源并赋予该选项
    var shortcut = Shortcut.new()
    shortcut.events.append(input_event)
    popup.set_item_shortcut(0, shortcut)
    
    # 确保信号只连接一次
    if not popup.id_pressed.is_connected(_on_menu_item_pressed):
        popup.id_pressed.connect(_on_menu_item_pressed)
        

func _on_menu_item_pressed(id: int):
    match id:
        0:
            print("正在生成数据...")
        1:
            print("缓存已清理！")
        2:
            print("...")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    _setup_menu()

    inspector = EditorInspector.new()
    inspector.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _panel.add_child(inspector)

    print("[FlowEditorMain] Ready. GraphEdit and PropertyBox are valid.")
    
    # 绑定之前的右键菜单和连线逻辑...
    # graph_edit.popup_request.connect(...)

