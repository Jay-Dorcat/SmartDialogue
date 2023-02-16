extends FlowItem

func _ready():
	%List.Depth = get_parent().Depth + 1
	super()

func Format():
	return {
		"Type": "Branch",
		"Query": %Query.text,
		"ListItems": %List.ListFormats()
	}

func Unpack(Form : Dictionary):
	%Query.text = Form.Query
	%List.Unpack(Form.ListItems)

func TextFormat():
	return "If %s%s" % [%Query.text,%List.TextFormat()]
