extends FlowItem

func Format():
	return {
		"Type": "Trigger",
		"TriggerName": %TriggerName.text
	}

func Unpack(Form : Dictionary):
	%TriggerName.text = Form.TriggerName

func TextFormat():
	return "Trigger : " + %TriggerName.text

func Submit():
	release_focus()
