@tool
extends EditorPlugin

# 预加载图表编辑器的 UI 场景
const GRAPH_UI_SCENE = preload("res://addons/my_tool/dock_ui.tscn")

# 持有 UI 实例的引用，用于在卸载时清理内存
var graph_panel_instance: Control




func _enter_tree() -> void:

    # 1. 实例化图表管理器
    graph_panel_instance = GRAPH_UI_SCENE.instantiate()
    
    # 可选：设置控件在底部的最小高度，防止被挤压
    graph_panel_instance.custom_minimum_size.y = 300 
    
    # 2. 将实例化后的 UI 注入到 Godot 编辑器的底部面板
    # 参数 1: UI 控件实例
    # 参数 2: 底部面板标签页上显示的文本
    var bottom_panel_button = add_control_to_bottom_panel(graph_panel_instance, "流程节点编辑 (Flow Graph)")
    
    # 可选：通过代码控制默认隐藏或强制显示
    # make_bottom_panel_item_visible(graph_panel_instance)

func _exit_tree() -> void:
    # 1. 清理底部面板 (你原有的逻辑)
    if is_instance_valid(graph_panel_instance):
        remove_control_from_bottom_panel(graph_panel_instance)
        graph_panel_instance.queue_free()
        graph_panel_instance = null
    