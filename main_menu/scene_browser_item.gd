extends VBoxContainer

const AUTHOR_STRING_TEMPLATE = "by: %s"

@onready var name_label = $Name
@onready var author_label = $Author

var scene_name: String
var author_value: String

func _ready() -> void:
  name_label.text = scene_name
  author_label.text = author_value

func set_scene_info(name_value: String, author: String) -> void:
  scene_name = name_value
  if name_label != null:
      name_label.text = name_value
  author_value = AUTHOR_STRING_TEMPLATE % author
  if author_label != null:
    author_label.text = author_value
