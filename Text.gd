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
	%Textbox.custom_minimum_size.y = 30
	%ResizeBar.visible = false
	%Collapser.text = "Uncollapse"
	Collapsed = true

func Uncollapse():
	%Textbox.custom_minimum_size.y = UncollapsedSize
	%ResizeBar.visible = true
	%Collapser.text = "Collapse"
	Collapsed = false

func _process(delta):
	if Resizing:
		var NewMousePosition : Vector2 = get_global_mouse_position()
		var MouseChange : Vector2 = NewMousePosition - MousePosition
		UncollapsedSize += MouseChange.y
		%Textbox.custom_minimum_size.y = UncollapsedSize
		MousePosition = NewMousePosition

func Format():
	return {
		"Type": "Text",
		"Text" : %Textbox.text
	}

func Unpack(Form : Dictionary):
	%Textbox.text = Form.Text
