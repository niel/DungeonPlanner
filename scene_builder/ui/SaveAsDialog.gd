extends ConfirmationDialog

signal saved_with_name(name: String)

@onready var name_input: TextEdit = $SaveNameInput

func _ready():
  self.confirmed.connect(self.on_save)

func on_save():
  saved_with_name.emit(name_input.text)