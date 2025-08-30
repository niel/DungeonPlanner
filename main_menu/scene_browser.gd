extends VBoxContainer

signal scene_import_request(scene_id: String)

const SCENE_BROWSER_ITEM_SCENE = preload("res://main_menu/SceneBrowserItem.tscn")

func set_scene_items(scenes: Array) -> void:
    for scene: Scene in scenes:
        var item = SCENE_BROWSER_ITEM_SCENE.instantiate()
        item.set_scene(scene)
        add_child(item)
        item.on_pressed.connect(_on_scene_browser_item_pressed)

func _on_scene_browser_item_pressed(scene_id: String) -> void:
    scene_import_request.emit(scene_id)
