extends FlowItem

const BASE_TRIGGERS : PackedStringArray = [
	"End","Select"
]

var TriggerName : String

func _ready():
	UpdateOptions()
	super()

func Format():
	return {
		"Type": "Trigger",
		"TriggerName": %Options.get_item_text(%Options.selected)
	}

func Unpack(Form : Dictionary):
	TriggerName = Form.TriggerName
	UpdateOptions()
	GetMapCore().FlowMapRes.TriggersChanged.connect(UpdateOptions)

func TextFormat():
	return "Trigger : " + %Options.get_item_text(%Options.selected)

func UpdateOptions():
	%Options.clear()
	%Options.add_separator("Default")
	for i in BASE_TRIGGERS:
		%Options.add_item(i)
	
	%Options.add_separator("Custom")
	for i in GetMapCore().FlowMapRes.CustomTriggers:
		%Options.add_item(i)
	
	for i in %Options.item_count:
		if %Options.get_item_text(i) == TriggerName:
			%Options.selected = i
			break

func Submit():
	release_focus()
