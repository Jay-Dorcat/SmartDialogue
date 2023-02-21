extends FlowItem

var AssignVar : StringName

func _ready():
	UpdateVariables()
	GetMapCore().FlowMapRes.VariablesChanged.connect(UpdateVariables)
	super()

func Format():
	return {
		"Type": "Operator",
		"Operations": %Operation.text,
		"AssignVar": %Variables.get_item_text(%Variables.selected)
	}

func Unpack(Form : Dictionary):
	AssignVar = Form.AssignVar
	%Operation.text = Form.Operations
	UpdateVariables()

func TextFormat():
	AssignVar = %Variables.get_item_text(%Variables.selected)
	return "Var %s = %s" % [AssignVar,%Operation.text]

func UpdateVariables():
	%Variables.clear()
	
	var FlowMapRes : FlowMapResource = GetMapCore().FlowMapRes
	
	AddGroup("Global", FlowMapRes.Global)
	AddGroup("Local", FlowMapRes.Local)
	for grp in FlowMapRes.GetCustomGroups():
		AddGroup(grp, FlowMapRes.GetGroup(grp))
	
	for i in %Variables.item_count:
		if %Variables.get_item_text(i) == AssignVar:
			%Variables.selected = i
			break

func AddGroup(GroupName : String, Group : Dictionary):
	if len(Group) > 0:
		%Variables.add_separator(GroupName)
		for i in Group:
			%Variables.add_item(i)
