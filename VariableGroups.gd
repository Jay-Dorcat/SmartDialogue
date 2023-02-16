extends Control

var GlobalGroup : Control 
var LocalGroup : Control
var ConstantGroup : Control
var OtherGroups : Array[Control]

func CreateFromFlowMap(FlowMap : FlowMapResource):
	for c in get_children():
		c.queue_free()
	
	ConstantGroup = CreateGroup("Constant", FlowMap.Constants, false)
	GlobalGroup = CreateGroup("Global", FlowMap.Global, false)
	LocalGroup = CreateGroup("Local", FlowMap.Local, false)
	
	OtherGroups.clear()
	for key in FlowMap.Groups:
		OtherGroups.append(CreateGroup(key, FlowMap.Groups[key]))

func SaveToFlowMap(FlowMap : FlowMapResource):
	FlowMap.SetGroup("Global", GlobalGroup.GetVariables())
	FlowMap.SetGroup("Local", LocalGroup.GetVariables())
	FlowMap.SetGroup("Constants", ConstantGroup.GetVariables())
	
	for i in OtherGroups:
		FlowMap.SetGroup(i.GroupName, i.GetVariables())

func CreateNewGroup():
	OtherGroups.append(CreateGroup())

func CreateGroup(Name : String = "NewGroup", Variables : Dictionary = {}, CustomName : bool = true):
	var NewGroup = preload("res://VariableGroup.tscn").instantiate()
	NewGroup.GroupName = Name
	NewGroup.Variables = Variables
	NewGroup.EditableName = CustomName
	if get_child_count() > 0:
		add_child(VSeparator.new())
	add_child(NewGroup)
	return NewGroup
