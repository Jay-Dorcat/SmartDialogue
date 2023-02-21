extends Control

var Name : String = "NewVariable"
var Value = 0

func _ready():
	%Name.text = Name
	
	if Value is int:
		%NumberEdit.value = Value
		%Values.selected = 0
	elif Value is float:
		%NumberEdit.value = Value
		%Values.selected = 1
	elif Value is String:
		%StringEdit.text = Value
		%Values.selected = 2
	elif Value is bool:
		%BoolEdit.button_pressed = Value
		%Values.selected = 3
	
	UpdateEdits()

func UpdateEdits():
	if Value is int:
		%NumberEdit.visible = true
		%StringEdit.visible = false
		%BoolEdit.visible = false
		%NumberEdit.step = 1.0
	elif Value is float:
		%NumberEdit.visible = true
		%StringEdit.visible = false
		%BoolEdit.visible = false
		%NumberEdit.step = 0.01
	elif Value is String:
		%NumberEdit.visible = false
		%StringEdit.visible = true
		%BoolEdit.visible = false
	elif Value is bool:
		%NumberEdit.visible = false
		%StringEdit.visible = false
		%BoolEdit.visible = true

func SetType(Type : int):
	match Type:
		0:
			Value = 0
		1:
			Value = 0.0
		2:
			Value = ""
		3:
			Value = false
	UpdateEdits()

func Remove():
	queue_free()

func SetValue(NewValue):
	Value = NewValue
	%BoolEdit.text = "True" if NewValue else "False"

func NameChange(NewName : String):
	Name = NewName
