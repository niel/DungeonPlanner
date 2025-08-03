extends Node3D

const ZOOM_PERCENT = 0.1
const ZOOM_MIN = 20.0
const ZOOM_MAX = 150.0
const TRANSFORM_SPEED = 0.1
const ZOOM_COEFFICIENT = 0.0154

var right_clicked = false

@onready var camera = $Camera3D

func handle_mouse_button(event: InputEventMouseButton):
	var event_button = event.get_button_index()
	if event_button == MOUSE_BUTTON_RIGHT:
		right_clicked = event.is_pressed()
	if event_button == MOUSE_BUTTON_WHEEL_DOWN:
		camera.size += camera.size * ZOOM_PERCENT
		if camera.size > ZOOM_MAX:
			camera.size = ZOOM_MAX
	if event_button == MOUSE_BUTTON_WHEEL_UP:
		camera.size -= camera.size * ZOOM_PERCENT
		if camera.size < ZOOM_MIN:
			camera.size = ZOOM_MIN

func handle_mouse_motion(event: InputEventMouseMotion):
	if !right_clicked:
		return
	transform.origin.x -= event.relative.x * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)
	transform.origin.z -= event.relative.y * TRANSFORM_SPEED * (ZOOM_COEFFICIENT * camera.size)

func _input(event):
	if event is InputEventMouseButton:
		handle_mouse_button(event as InputEventMouseButton)
	if event is InputEventMouseMotion:
		handle_mouse_motion(event as InputEventMouseMotion)
