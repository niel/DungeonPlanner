extends Node3D

const PITCH_MIN = -1.0
const PITCH_MAX = 0.25
const ROTATE_SPEED = 0.005
const TRANSFORM_SPEED = 0.1
const ZOOM_COEFFICIENT = 0.0154
const ZOOM_MAX = 150.0
const ZOOM_MIN = 20.0
const ZOOM_PERCENT = 0.1

var middle_clicked = false
var right_clicked = false

@onready var camera = $Camera3D

func handle_mouse_button(event: InputEventMouseButton):
  var event_button = event.get_button_index()
  # Pan
  if event_button == MOUSE_BUTTON_RIGHT:
    right_clicked = event.is_pressed()
  #Rotate
  if event_button == MOUSE_BUTTON_MIDDLE:
    middle_clicked = event.is_pressed()
  # Zoom
  if event_button == MOUSE_BUTTON_WHEEL_DOWN:
    camera.size += camera.size * ZOOM_PERCENT
    if camera.size > ZOOM_MAX:
      camera.size = ZOOM_MAX
  if event_button == MOUSE_BUTTON_WHEEL_UP:
    camera.size -= camera.size * ZOOM_PERCENT
    if camera.size < ZOOM_MIN:
      camera.size = ZOOM_MIN

func handle_mouse_motion(event: InputEventMouseMotion):
  if right_clicked:
    var x_translation = -event.relative.x * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)
    var z_translation = -event.relative.y * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)
    transform = transform.translated_local(Vector3(x_translation, 0, z_translation))
  if middle_clicked:
    transform = transform.rotated(Vector3.UP, -event.relative.x * ROTATE_SPEED)
    var current_euler = transform.basis.get_euler()
    var rotation_amount = -event.relative.y * ROTATE_SPEED
    var pitch_result = current_euler.x + rotation_amount
    if pitch_result < PITCH_MIN:
      rotation_amount = PITCH_MIN - current_euler.x
    elif pitch_result > PITCH_MAX:
      rotation_amount = PITCH_MAX - current_euler.x
    transform = transform.rotated_local(Vector3.RIGHT, rotation_amount)

func _input(event):
  if event is InputEventMouseButton:
    handle_mouse_button(event as InputEventMouseButton)
  if event is InputEventMouseMotion:
    handle_mouse_motion(event as InputEventMouseMotion)
