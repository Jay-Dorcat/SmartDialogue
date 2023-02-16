extends FlowItem

var FlowListJump : FlowListResource

var AllInstances : PackedInt32Array

var Offset : int = 0

func _ready():
	GetMapCore().FlowMapRes.FlowListsChanged.connect(ReloadLists)
	ReloadLists()
	super()

func _process(delta):
	var ListInsts := GetMapCore().FlowMapRes.FlowListInstances
	AllInstances.clear()
	for i in len(ListInsts):
		if ListInsts[i].FlowList == FlowListJump:
			AllInstances.append(i)
	CreateLines()

func Format():
	var ListName : String = FlowListJump.ListName if FlowListJump != null else ""
	return {
		"Type": "Jump",
		"FlowList": ListName,
		"Offset": %StartOffset.value
	}

func Unpack(Form : Dictionary):
	for i in GetMapCore().FlowMapRes.AllFlowLists:
		if i.ListName == Form.FlowList:
			FlowListJump = i 
	%StartOffset.value = Form.Offset
	ReloadLists()

func TextFormat():
	var ListName : String = FlowListJump.ListName.replace(" ", "_") if FlowListJump != null else ""
	if Offset == 0:
		return "Goto %s" % [ListName]
	else:
		return "Goto %s [%s]" % [ListName,str(Offset)]

func CreateLines():
	%LineStart.ClearLines()
	for i in AllInstances:
		var FLNode : FlowListNode = GetMapCore().GetFlowListNode(i)
		var ListItem : FlowItem = FLNode.GetListItem(Offset)
		var Start : Vector2 = %LineStart.global_position
		var End : Vector2 = FLNode.global_position
		if ListItem != null:
			End = ListItem.global_position + ListItem.size * Vector2(0,0.5)
		var Dist : float = Start.distance_to(End)
		%LineStart.AddLine(Start, Vector2(Dist * 0.5,0), Vector2(Dist,0) * -0.5, End)

func FlowListSelect(Index : int = -1):
	FlowListJump = GetMapCore().FlowMapRes.FlowListInstances[Index].FlowList
	Changed.emit()

func SetOffset(Value : int):
	Offset = Value
	Changed.emit()

func ReloadLists():
	GetMapCore().FlowMapRes.SetOptionsAsLists(%FlowLists)
	
	if FlowListJump == null:
		return
	
	for i in %FlowLists.item_count:
		if %FlowLists.get_item_text(i) == FlowListJump.ListName:
			%FlowLists.selected = i
			break
