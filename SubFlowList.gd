extends VBoxContainer
class_name SubListNode

@onready var TextScn : PackedScene = preload("res://Text.tscn")
@onready var SelectionScn : PackedScene = load("res://Selection.tscn")
@onready var JumpScn : PackedScene = preload("res://Jump.tscn")
@onready var OperateScn : PackedScene = preload("res://Operator.tscn")
@onready var BranchScn : PackedScene = load("res://Branch.tscn")
@onready var TriggerScn : PackedScene = preload("res://Trigger.tscn")

signal Changed()

var Depth : int = 0

func AddText():
	AddScene(TextScn)
	Changed.emit()

func AddSelection():
	AddScene(SelectionScn)
	Changed.emit()

func AddJump():
	AddScene(JumpScn)
	Changed.emit()

func AddOperator():
	AddScene(OperateScn)
	Changed.emit()

func AddBranch():
	AddScene(BranchScn)
	Changed.emit()

func AddTrigger():
	AddScene(TriggerScn)
	Changed.emit()

func AddScene(PckScn : PackedScene):
	var New = PckScn.instantiate()
	add_child(New)
	if New.has_signal("Changed"):
		New.Changed.connect(ChildChanged)
	return New

func ListFormats():
	var DicArr : Array[Dictionary]
	for c in get_children():
		if c.has_method("Format"):
			DicArr.append(c.Format())
	return DicArr

func Unpack(List : Array[Dictionary]):
	for i in get_children():
		i.queue_free()
	for i in List:
		var ItemScn : PackedScene
		match i.Type:
			"Text":
				ItemScn = TextScn
			"Selection":
				ItemScn = SelectionScn
			"Jump":
				ItemScn = JumpScn
			"Operator":
				ItemScn = OperateScn
			"Branch":
				ItemScn = BranchScn
			"Trigger":
				ItemScn = TriggerScn
		if ItemScn == null:
			push_error("No Matching Scene File Found for item:\n", i)
			continue
		var Item = AddScene(ItemScn)
		Item.Unpack(i)

func GetDepthColour():
	var Wrap : int = wrapi(Depth,0,5)
	return Color.from_hsv(Wrap / 5.0,0.6,1.0)

func IndentDepth():
	var Total : String = "	"
	for i in Depth:
		Total += "	"
	return Total

func ChildChanged():
	Changed.emit()

func TextFormat():
	var Str : String
	if get_child_count() == 1 && Depth > 0:
		return "; " + get_child(0).TextFormat()
	for i in get_children():
		Str += "\n" + IndentDepth() + i.TextFormat()
	return Str
