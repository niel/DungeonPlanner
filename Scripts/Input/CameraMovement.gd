extends Node3D

var rightClicked = false
const zoomPercent = 0.1
const zoomMin = 20.0
const zoomMax = 150.0
const transformSpeed = 0.1
const zoomCoefficient = 0.0154

@onready var camera = $Camera3D

func handle_mouse_button(event: InputEventMouseButton):
	var eventButton = event.get_button_index()
	if eventButton == MOUSE_BUTTON_RIGHT:
		rightClicked = event.is_pressed()
	if eventButton == MOUSE_BUTTON_WHEEL_DOWN:
		camera.size += camera.size * zoomPercent
		if camera.size > zoomMax:
			camera.size = zoomMax
	if eventButton == MOUSE_BUTTON_WHEEL_UP:
		camera.size -= camera.size * zoomPercent
		if camera.size < zoomMin:
			camera.size = zoomMin

func handle_mouse_motion(event: InputEventMouseMotion):
	if !rightClicked:
		return
	transform.origin.x -= event.relative.x * transformSpeed * (zoomCoefficient * camera.size)
	transform.origin.z -= event.relative.y * transformSpeed * (zoomCoefficient * camera.size)
	

func _input(event):
	if event is InputEventMouseButton:
		handle_mouse_button(event as InputEventMouseButton)
	if event is InputEventMouseMotion:
		handle_mouse_motion(event as InputEventMouseMotion)
