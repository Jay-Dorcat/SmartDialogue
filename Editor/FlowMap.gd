extends Node2D
class_name MapCore

@export var SmallGrid : Texture2D
@export var MediumGrid : Texture2D
@export var LargeGrid : Texture2D

var ExportDirectory : String = "res://DialogueExport/"

var ProjectRes : ProjectData
var FlowMapRes : FlowMapResource

signal TriggersChanged()
signal VariablesChanged()
signal FlowListsChanged()

func _ready():
	if FlowMapRes == null:
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
	var Index = FlowMapRes.CreateNewInstance({
		"Instance": FlowMapRes.NewUniqueInstanceID(),
		"Position": $Camera.position,
		"FlowList": FlowListResource.new()
	})
	add_child(FlowMapRes.CreateObjFromIndex(Index))

func NewFlowListInstance(Index : int):
	var InstIndex = FlowMapRes.CreateNewInstance({
		"Instance": FlowMapRes.NewUniqueInstanceID(),
		"Position": $Camera.position,
		"FlowList": FlowMapRes.AllFlowLists[Index]
	})
	add_child(FlowMapRes.CreateObjFromIndex(InstIndex))

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

func OpenFlowMapPanel():
	%FlowMapBlock.visible = true
	%MapSelect.clear()
	for i in ProjectRes.GetFlowMapPaths():
		var Formatted := ProjectRes.LocalPath(i).trim_prefix("/").replace("/"," > ").trim_suffix(".dg.tres")
		%MapSelect.add_item(Formatted)

func LoadSelected():
	var LoadIndex : int = %MapSelect.selected
	Load(ProjectRes.GetFlowMapPaths()[LoadIndex])

func Reload():
	for c in get_children():
		if c == $Camera || c == $MapBG:
			continue
		c.queue_free()
	
	%MapName.text = FlowMapRes.MapName
	
	for n in FlowMapRes.CreateObjsFromInstances():
		add_child(n)
	CloseFlowMapPanel()

func CloseFlowMapPanel():
	%FlowMapBlock.visible = false

func Load(FilePath : String):
	var NewFlowMap = ResourceLoader.load(FilePath)
	if NewFlowMap == null || !NewFlowMap is FlowMapResource:
		push_warning("Could Not Load File: ",FilePath)
	else:
		FlowMapRes = NewFlowMap
	Reload()

func FlowListInstanceCount():
	return len(FlowMapRes.FlowListInstances)

func GetFlowListNode(Instance : int = 0):
	for c in get_children():
		if c is FlowListNode:
			if c.InstanceID == Instance:
				return c
	return null

func OpenVariablesBlock():
	%VariablesBlock.visible = true
	%Groups.CreateFromFlowMap(FlowMapRes)

func CloseVariablesBlock():
	%Groups.SaveToFlowMap(FlowMapRes)
	%VariablesBlock.visible = false

func NewFlowMap():
	FlowMapRes = FlowMapResource.new()
	Reload()

func GetGroup(Name : String):
	match Name:
		"Global":
			return ProjectRes.Global
		"Local":
			return FlowMapRes.Local
		"Constants":
			return FlowMapRes.Constants
	return ProjectRes.Groups[Name]

func TextFormat():
	var Str : String = "<< %s >>" % FlowMapRes.MapName
	
	Str += "\n\n<< Variables >>"
	for i in FlowMapRes.Local:
		Str += "\n> %s = %s" % [i,str(FlowMapRes.Local[i])]
	#Str += "\n\n<< Used Globals >>"
	#for i in FlowMapRes.Constants:
	#	Str += "\n> Const:%s = %s" % [i,str(FlowMapRes.Global[i])]
	#Str += "\n\n"
	Str += "\n\n<< Constants >>"
	for i in FlowMapRes.Constants:
		Str += "\n> Const:%s = %s" % [i,str(FlowMapRes.Global[i])]
	Str += "\n\n"
	
	var CreatedLists : Array[FlowListResource]
	for c in get_children():
		if c is FlowListNode:
			if !CreatedLists.has(c.CurrentFlowListResource):
				CreatedLists.append(c.CurrentFlowListResource)
				Str += c.GetTextFormat()
	return Str

func ExportTextFormat():
	var Text = TextFormat()
	
	var TxtFile := FileAccess.open(ExportDirectory + "%s.dlog" % FlowMapRes.MapName, FileAccess.WRITE)
	TxtFile.store_string(Text)
	TxtFile = null
