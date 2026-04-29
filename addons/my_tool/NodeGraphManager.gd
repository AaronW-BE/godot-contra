@tool

# NodeGraphManager.gd - 节点面板核心控制器
extends GraphEdit

var context_menu: PopupMenu
var _last_click_position: Vector2 = Vector2.ZERO

func _ready() -> void:
    # 1. 基础面板配置
    right_disconnects = true # 允许拖拽输出端口的连线到空白处以断开连接
    minimap_enabled = true   # 开启右下角小地图
    
    _setup_context_menu()
    popup_request.connect(_on_graph_popup_request)

    # 2. 绑定核心连线信号 (Godot 4.x 语法)
    connection_request.connect(_on_connection_request)
    disconnection_request.connect(_on_disconnection_request)
    
    print("[Graph System] NodeGraphManager initialized.")
    # 3. 初始化测试节点
    _build_test_graph()


# 构建一个包含交互控件的复杂节点
func _create_math_node(id_name: String, pos: Vector2) -> GraphNode:
    var node = GraphNode.new()
    node.name = id_name
    node.title = "数学运算 (Math Op)"
    node.position_offset = pos
    
    # ---------------------------------------------------
    # Row 0: 标题与输入端口 (Slot 0)
    # ---------------------------------------------------
    var row_0 = HBoxContainer.new()
    var label_in = Label.new()
    label_in.text = "输入 A (Float)"
    row_0.add_child(label_in)
    node.add_child(row_0)
    
    # 激活 Slot 0 的左侧输入端口
    node.set_slot(0, true, 0, Color.AQUA, false, 0, Color.WHITE)

    # ---------------------------------------------------
    # Row 1: 下拉菜单 (Slot 1) - 不带任何连线端口
    # ---------------------------------------------------
    var row_1 = HBoxContainer.new()
    var operator_dropdown = OptionButton.new()
    operator_dropdown.add_item("相加 (+)", 0)
    operator_dropdown.add_item("相减 (-)", 1)
    operator_dropdown.add_item("相乘 (*)", 2)
    # 充满水平空间
    operator_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row_1.add_child(operator_dropdown)
    node.add_child(row_1)
    
    # Slot 1 两侧都不开启端口 (均为 false)
    node.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
    
    # ---------------------------------------------------
    # Row 2: 数值滑动条与输出端口 (Slot 2)
    # ---------------------------------------------------
    var row_2 = HBoxContainer.new()
    
    # 内部控件：数值输入框
    var spin_box = SpinBox.new()
    spin_box.min_value = 0.0
    spin_box.max_value = 100.0
    spin_box.step = 0.1
    spin_box.value = 1.0
    
    # 内部控件：靠右对齐的标签
    var label_out = Label.new()
    label_out.text = "输出"
    label_out.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    label_out.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    row_2.add_child(spin_box)
    row_2.add_child(label_out)
    node.add_child(row_2)
    
    # 激活 Slot 2 的右侧输出端口
    node.set_slot(2, false, 0, Color.WHITE, true, 0, Color.ORANGE_RED)

    # ---------------------------------------------------
    # 生命周期与内存管理
    # ---------------------------------------------------
    node.delete_request.connect(func():
        clear_connections_to_node(node.name)
        node.queue_free()
    )
    
    # 数据变动事件绑定示例
    operator_dropdown.item_selected.connect(func(idx: int):
        print("[Graph] %s 操作符变更为: %d" % [node.name, idx])
        # 此处可以触发图表重编译或数据刷新信号
    )
    
    return node

# ==========================================
# 节点工厂与初始化
# ==========================================

func _build_test_graph() -> void:
    print("[Graph System] Building test graph...")  
    # 创建一个输出节点
    var node_out = _create_custom_node("Generator", "数据生成节点", Vector2(100, 100))
    # 为第 0 行启用右侧输出端口 (参数：行索引, 左开启, 左类型, 左颜色, 右开启, 右类型, 右颜色)
    node_out.set_slot(0, false, 0, Color.WHITE, true, 0, Color.CYAN)
    
    # 创建一个输入节点
    var node_in = _create_custom_node("Processor", "数据处理节点", Vector2(500, 150))
    # 为第 0 行启用左侧输入端口
    node_in.set_slot(0, true, 0, Color.CYAN, false, 0, Color.WHITE)
    
    # 将节点添加到画布中
    add_child(node_out)
    add_child(node_in)

func _create_custom_node(id_name: String, title_text: String, pos: Vector2) -> GraphNode:
    var node = GraphNode.new()
    node.name = id_name
    node.title = title_text
    node.position_offset = pos
    
    # 必须添加子节点以划分 Slot (行)
    var row_ui = HBoxContainer.new()
    var label = Label.new()
    label.text = "数据流 (Data Port)"
    row_ui.add_child(label)
    
    node.add_child(row_ui)
    
    # ==========================================
    # [核心修复] 适配 Godot 4 最新 API，使用 delete_request
    # ==========================================
    node.delete_request.connect(func():
        # 在销毁节点前，必须调用之前的辅助函数清理连线，防止空指针
        clear_connections_to_node(node.name)
        node.queue_free()
    )
    
    return node

# ==========================================
# 连线生命周期管理 (必须手动接管)
# ==========================================

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    # 可在此处拦截逻辑，例如：检查数据类型是否匹配 (类型检查由 port_type 决定，但仍需在此验证业务逻辑)
    
    # 调用底层 API 建立实际的可视化连线
    var error = connect_node(from_node, from_port, to_node, to_port)
    if error == OK:
        print("[Graph System] Connected: %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])
    else:
        printerr("[Graph System] Connection failed: ", error)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    # 调用底层 API 断开可视化连线
    disconnect_node(from_node, from_port, to_node, to_port)
    print("[Graph System] Disconnected: %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])

# 辅助工具：清理某个节点的所有连线 (在删除节点前必须调用)
func clear_connections_to_node(node_name: StringName) -> void:
    for conn in get_connection_list():
        if conn["from_node"] == node_name or conn["to_node"] == node_name:
            disconnect_node(conn["from_node"], conn["from_port"], conn["to_node"], conn["to_port"])



func _setup_context_menu() -> void:
    context_menu = PopupMenu.new()
    add_child(context_menu)
    
    context_menu.add_item("创建: 数据生成节点", 0)
    context_menu.add_item("创建: 数据处理节点", 1)
    
    # 新增数学节点的菜单项，绑定 ID = 2
    context_menu.add_item("创建: 数学运算节点", 2) 
    
    context_menu.add_separator() 
    context_menu.add_item("清空所有连线", 99)
    
    context_menu.id_pressed.connect(_on_context_menu_id_pressed)

# ==========================================
# 核心事件回调
# ==========================================

# 触发右键时执行 (p 参数是鼠标在 GraphEdit UI 控件上的局部坐标)
func _on_graph_popup_request(p: Vector2) -> void:
    # 保存当前的鼠标坐标，供后续创建节点使用
    _last_click_position = p
    
    # 将局部坐标转换为操作系统的屏幕坐标，以确保弹窗在正确的物理位置出现
    context_menu.position = get_screen_position() + p
    
    # 弹出菜单
    context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
    var canvas_world_pos = (_last_click_position + scroll_offset) / zoom
    var unique_id = str(Time.get_ticks_msec())
    
    match id:
        0:
            var node = _create_custom_node("Gen_" + unique_id, "生成节点", canvas_world_pos)
            node.set_slot(0, false, 0, Color.WHITE, true, 0, Color.CYAN)
            add_child(node)
        1:
            var node = _create_custom_node("Proc_" + unique_id, "处理节点", canvas_world_pos)
            node.set_slot(0, true, 0, Color.CYAN, true, 0, Color.CYAN)
            add_child(node)
        2:
            # 1. 调用工厂函数获取实例
            var math_node = _create_math_node("Math_" + unique_id, canvas_world_pos)
            # 2. 【核心】必须将实例挂载为 GraphEdit (也就是 self) 的子节点
            add_child(math_node) 
        99:
            clear_connections()
    # 【工程核心】坐标空间转换
    # 必须将 UI 控件坐标 -> 加上滚动偏移 -> 除以缩放比例，才能得到画布内的真实世界坐标
    canvas_world_pos = (_last_click_position + scroll_offset) / zoom
    
    # 为了避免重名导致节点冲突，引入时间戳或随机数作为节点唯一 ID
    unique_id = str(Time.get_ticks_msec())
    
    match id:
        0:
            var node = _create_custom_node("Gen_" + unique_id, "生成节点", canvas_world_pos)
            node.set_slot(0, false, 0, Color.WHITE, true, 0, Color.CYAN)
            add_child(node)
        1:
            var node = _create_custom_node("Proc_" + unique_id, "处理节点", canvas_world_pos)
            node.set_slot(0, true, 0, Color.CYAN, true, 0, Color.CYAN)
            add_child(node)
        99:
            # 清空所有连线
            clear_connections()