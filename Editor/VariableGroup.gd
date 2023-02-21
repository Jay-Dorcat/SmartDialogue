extends VBoxContainer

var EditableName : bool = false
var GroupName : String = "GroupName"
var Variables : Dictionary

func _ready():
	$Name.text = GroupName + " Variables"
	for i in Variables:
		AddVariable(i, Variables[i])
	$Name.editable = EditableName
	if EditableName:
		$Name.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$Name.mouse_filter = Control.MOUSE_FILTER_IGNORE

func Return():
	return {
		"GroupName": GroupName,
		"Variables": Variables
	}

func AddVariable(Name : String = "NewVar", Value = 0):
	var NewGVar = preload("res://Editor/GroupVariable.tscn").instantiate()
	NewGVar.Name = Name
	NewGVar.Value = Value
	$Variables.add_child(NewGVar)

func GetVariables():
	var Vars : Dictionary
	for i in $Variables.get_children():
		Vars[i.Name] = i.Value
	return Vars

func SetName(NewName : String):
	GroupName = NewName
