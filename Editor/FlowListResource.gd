extends Resource
class_name FlowListResource

@export var ListName : String

@export var ListItems : Array[Dictionary]

signal ListChanged()
signal NameChanged()

var LastChangeInstance : int = -1

func Save(NewPath : String = ""):
	if NewPath != "":
		ResourceSaver.save(self,NewPath)
	else:
		ResourceSaver.save(self,"res://addons/SmartDialogue/SavedFlowMaps/%s.tres" % ListName)

func SetData(NewName : String, NewList : Array, FromInstance : int = -1):
	LastChangeInstance = FromInstance
	ListName = NewName
	ListItems = NewList
	NameChanged.emit()
	ListChanged.emit()

func SetName(NewName : String, FromInstance : int = -1):
	LastChangeInstance = FromInstance
	ListName = NewName
	NameChanged.emit()
