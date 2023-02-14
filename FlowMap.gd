extends Node2D
class_name MapCore

@export var SmallGrid : Texture2D
@export var MediumGrid : Texture2D
@export var LargeGrid : Texture2D

const SAVE_DIRECTORY : String = "res://FlowMaps/"

var FlowMapRes : FlowMapResource

func _ready():
	FlowMapRes = FlowMapResource.new()

func _process(delta):
	var Newrect : Rect2 = %WholeScreen.get_global_rect()
	var GlobalScale : Vector2 = Newrect.size / $Camera.zoom + Vector2.ONE * 1024
	if $Camera.zoom.x < 0.5:
		$MapBG.texture = MediumGrid
	else:
		$MapBG.texture = SmallGrid
	$MapBG.position = ($Camera.position - GlobalScale * 0.5).snapped(Vector2(256,256))
	$MapBG.size = GlobalScale

func NewEmptyFlowList():
	var Instance = FlowMapRes.CreateNewInstance({
		"Position": $Camera.position,
		"FlowList": FlowListResource.new()
	})
	add_child(FlowMapRes.CreateObjFromInstance(Instance))
	print(FlowMapRes)

func NewFlowListInstance(Index : int):
	var Instance = FlowMapRes.CreateNewInstance({
		"Position": $Camera.position,
		"FlowList": FlowMapRes.AllFlowLists[Index]
	})
	add_child(FlowMapRes.CreateObjFromInstance(Instance))

var InstanceIndex : int = -1

func OpenNewFlowListPanel():
	%FlowListBlock.visible = true
	
	var HasFlowLists : bool = len(FlowMapRes.AllFlowLists) != 0
	
	FlowMapRes.SetOptionsAsLists(%InstanceSelect)
	
	%InstanceCheck.disabled = !HasFlowLists
	%EmptyCheck.button_pressed = true
	InstanceIndex = -1

func SetInstanceIndex(Index : int = -1):
	InstanceIndex = Index
	%InstanceSelect.visible = InstanceIndex != -1

func CreateNewFlowList():
	CloseNewFlowListPanel()
	if InstanceIndex == -1:
		NewEmptyFlowList()
		return
	NewFlowListInstance(InstanceIndex)
	CloseNewFlowListPanel()

func CloseNewFlowListPanel():
	%FlowListBlock.visible = false

func Save():
	for c in get_children():
		if c.has_method("Save"):
			c.Save()
	FlowMapRes.SetName(%MapName.text)
	FlowMapRes.Save()

func GetSavedFlowMaps():
	var Files := DirAccess.get_files_at(SAVE_DIRECTORY)
	print(Files)
	return Files

func OpenFlowMapPanel():
	%FlowMapBlock.visible = true
	%MapSelect.clear()
	for i in GetSavedFlowMaps():
		%MapSelect.add_item(str(i))

func LoadSelected():
	var LoadIndex : int = %MapSelect.selected
	Load(SAVE_DIRECTORY + GetSavedFlowMaps()[LoadIndex])
	Reload()

func Reload():
	for c in get_children():
		if c == $Camera || c == $MapBG:
			continue
		c.queue_free()
	
	for n in FlowMapRes.CreateObjsFromInstances():
		add_child(n)
	CloseFlowMapPanel()

func CloseFlowMapPanel():
	%FlowMapBlock.visible = false

func Load(FilePath : String):
	FlowMapRes = FlowMapResource.Load(FilePath)
	%MapName.text = FlowMapRes.MapName
	Reload()

func FlowListInstanceCount():
	return len(FlowMapRes.FlowListInstances)

func GetFlowListNode(Instance : int = 0):
	for c in get_children():
		if c is FlowListNode:
			if c.InstanceID == Instance:
				return c
	return null
