extends Control
class_name FlowListNode

var OwnerFlowMap : FlowMapResource
var CurrentFlowListResource : FlowListResource

var InstanceID : int = 0

var Resizing : bool = false
var Moving : bool = false

var MousePosition : Vector2

var Outdated : bool = false

func SetMoving(Value : bool):
	Moving = Value
	MousePosition = get_global_mouse_position()

func SetResizing(Value : bool):
	Resizing = Value
	MousePosition = get_global_mouse_position()

func _ready():
	if CurrentFlowListResource == null:
		SetRes(FlowListResource.new())
	HasResourceUpdate()

func _process(delta):
	if Resizing || Moving:
		var NewMousePosition : Vector2 = get_global_mouse_position()
		var MouseChange : Vector2 = NewMousePosition - MousePosition
		if Resizing:
			size.x += MouseChange.x
		elif Moving:
			position += MouseChange
		MousePosition = NewMousePosition

func SizeChanged():
	size.y = 0

func Changed():
	if CurrentFlowListResource != null:
		Save()

func LoadProperties(Properties : Dictionary):
	InstanceID = Properties.Instance
	position = Properties.Position
	SetRes(Properties.FlowList)
	await ready
	Reload()

func Save():
	if CurrentFlowListResource != null:
		CurrentFlowListResource.SetData(%Name.text, %List.ListFormats(), InstanceID)
	OwnerFlowMap.SetInstanceProperties(InstanceID,{
		"Instance": InstanceID,
		"Position": position,
		"FlowList": CurrentFlowListResource
	})
	Page(0)

func Load():
	var FlowListIndex : int = %Options.selected
	SetRes(OwnerFlowMap.AllFlowLists[FlowListIndex])
	Reload()

func Reload():
	if CurrentFlowListResource == null:
		return
	
	%Name.text = CurrentFlowListResource.ListName
	%List.Unpack(CurrentFlowListResource.ListItems)
	Page(0)

func MakeUnique():
	SetRes(CurrentFlowListResource.duplicate(true))
	Save()
	Page(0)

func Page(Index : int = 0):
	for i in %Pages.get_child_count():
		%Pages.get_child(i).visible = i == Index
	match Index:
		3:
			OwnerFlowMap.SetOptionsAsLists(%Options)

func HasResourceUpdate():
	var HasRes : bool = CurrentFlowListResource != null
	%Reload.visible = HasRes
	%Save.visible = HasRes
	%MakeUnique.visible = HasRes

func RemoveRes():
	CurrentFlowListResource.ListChanged.disconnect(ResourceListChange)
	CurrentFlowListResource.NameChanged.disconnect(ResourceNameChange)#
	CurrentFlowListResource = null

func SetRes(NewRes : FlowListResource):
	if CurrentFlowListResource != null:
		CurrentFlowListResource.ListChanged.disconnect(ResourceListChange)
		CurrentFlowListResource.NameChanged.disconnect(ResourceNameChange)#
	CurrentFlowListResource = NewRes
	CurrentFlowListResource.ListChanged.connect(ResourceListChange)
	CurrentFlowListResource.NameChanged.connect(ResourceNameChange)

func ResourceNameChange():
	if CurrentFlowListResource.LastChangeInstance != InstanceID:
		%Name.text = CurrentFlowListResource.ListName

func ResourceListChange():
	if CurrentFlowListResource.LastChangeInstance != InstanceID:
		if len(CurrentFlowListResource.ListItems) < 20:
			Reload.call_deferred()
		else:
			Page(2)

func NameChanged(NewName : String):
	CurrentFlowListResource.SetName(NewName, InstanceID)

func Delete():
	OwnerFlowMap.RemoveInstance(InstanceID)
	queue_free()

func GetListItem(Index : int = 0):
	if %List.get_child_count() < Index + 1:
		return null
	return %List.get_child(Index)

func GetTextFormat():
	var Str : String = "# " + CurrentFlowListResource.ListName.replace(" ", "_")
	Str += %List.TextFormat() + "\n! Return\n\n"
	return Str
