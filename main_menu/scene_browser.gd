extends VBoxContainer

const SCENE_BROWSER_ITEM_SCENE = preload("res://main_menu/SceneBrowserItem.tscn")

func set_scene_items(scenes: Array) -> void:
    for scene in scenes:
        var item = SCENE_BROWSER_ITEM_SCENE.instantiate()
        item.set_scene_info(scene.scene_name, scene.author)
        add_child(item)
