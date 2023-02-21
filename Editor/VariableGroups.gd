extends Control

var IsProject : bool = false

var GlobalGroup : Control 
var LocalGroup : Control
var ConstantGroup : Control
var OtherGroups : Array[Control]

func CreateFromProject(Project : ProjectData):#
	IsProject = true
	for c in get_children():
		c.queue_free()
	
	GlobalGroup = CreateGroup("Global", Project.Global, false)
	
	OtherGroups.clear()
	for key in Project.Groups:
		OtherGroups.append(CreateGroup(key, Project.Groups[key]))

func CreateFromFlowMap(FlowMap : FlowMapResource):
	IsProject = false
	for c in get_children():
		c.queue_free()
	
	ConstantGroup = CreateGroup("Constant", FlowMap.Constants, false)
	LocalGroup = CreateGroup("Local", FlowMap.Local, false)

func SaveToFlowMap(FlowMap : FlowMapResource):
#	FlowMap.SetGroup("Global", GlobalGroup.GetVariables())
	FlowMap.SetGroup("Local", LocalGroup.GetVariables())
	FlowMap.SetGroup("Constants", ConstantGroup.GetVariables())
	
#	for i in OtherGroups:
#		FlowMap.SetGroup(i.GroupName, i.GetVariables())

fun

func CreateNewGroup():
	OtherGroups.append(CreateGroup())

func CreateGroup(Name : String = "NewGroup", Variables : Dictionary = {}, CustomName : bool = true):
	var NewGroup = preload("res://Editor/VariableGroup.tscn").instantiate()
	NewGroup.GroupName = Name
	NewGroup.Variables = Variables
	NewGroup.EditableName = CustomName
	if get_child_count() > 0:
		add_child(VSeparator.new())
	add_child(NewGroup)
	return NewGroup
