extends Resource
class_name FlowMapResource

@export var MapName : StringName = "NewMap"
@export var FileName : StringName = "NewMap"

@export var AllFlowLists : Array[FlowListResource]

@export var FlowListInstances : Array[Dictionary]

var MapNode : Node2D

func NewFlowList(FlowList : FlowListResource):
	AllFlowLists.append(FlowList)

func SetInstanceProperties(Instance : int, Properties : Dictionary):
	if !AllFlowLists.has(Properties.FlowList):
		AllFlowLists.append(Properties.FlowList)
	FlowListInstances[Instance] = Properties

func GetInstanceProperties(Instance : int):
	return FlowListInstances[Instance]

func CreateNewInstance(Properties : Dictionary):
	FlowListInstances.append(Properties)
	return len(FlowListInstances)-1

func RemoveInstance(Instance : int):
	FlowListInstances.remove_at(Instance)

func CreateObjFromInstance(Instance : int):
	var New = preload("res://FlowList.tscn").instantiate()
	New.OwnerFlowMap = self
	New.InstanceID = Instance
	New.LoadProperties(FlowListInstances[Instance])
	return New

func CreateObjsFromInstances():
	var Objs : Array
	for i in len(FlowListInstances):
		Objs.append(CreateObjFromInstance(i))
	return Objs

func SetOptionsAsLists(Options : OptionButton):
	Options.clear()
	for i in AllFlowLists:
		Options.add_item(i.ListName)

func SetName(NewName : StringName):
	MapName = NewName
	if FileName == "":
		FileName = NewName

func Save():
	ResourceSaver.save(self,"res://FlowMaps/%s.tres" % FileName)

static func Load(FilePath : String):
	var New = ResourceLoader.load(FilePath)
	
	return New
