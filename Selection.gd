extends FlowItem

var Resizing : bool = false

var MousePosition : Vector2

var UncollapsedSize : float = 200
var Collapsed : bool = false

func SetResizing(Value : bool):
	Resizing = Value
	MousePosition = get_global_mouse_position()

func ToggleCollapsed():
	if !Collapsed:
		Collapse()
	else:
		Uncollapse()

func Collapse():
	%AddButtons.visible = false
	%RightPanel.visible = false
	%Collapser.text = "Uncollapse"
	Collapsed = true

func Uncollapse():
	%AddButtons.visible = true
	%RightPanel.visible = true
	%Collapser.text = "Collapse"
	Collapsed = false

func _ready():
	%List.Depth = get_parent().Depth + 1
	super()

func _process(delta):
	if Resizing:
		var NewMousePosition : Vector2 = get_global_mouse_position()
		var MouseChange : Vector2 = NewMousePosition - MousePosition
		UncollapsedSize += MouseChange.y
		%Textbox.custom_minimum_size.y = UncollapsedSize
		MousePosition = NewMousePosition

func Format():
	return {
		"Type": "Selection",
		"Prompt": %Prompt.text,
		"ListItems": %List.ListFormats()
	}

func Unpack(Form : Dictionary):
	%Prompt.text = Form.Prompt
	%List.Unpack(Form.ListItems)
