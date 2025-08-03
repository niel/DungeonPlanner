extends Node3D

signal rotate_left()
signal rotate_right()

func _input(event: InputEvent):
  if event is InputEventKey && event.is_pressed():
    if event.keycode == KEY_Q:
      SceneContext.left_rotation()
      rotate_left.emit()
    if event.keycode == KEY_E:
      SceneContext.right_rotation()
      rotate_right.emit()
