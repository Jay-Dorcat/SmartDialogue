extends FlowItem

var Collapsed : bool = false

func ToggleCollapsed():
	if !Collapsed:
		Collapse()
	else:
		Uncollapse()

func Collapse():
	%Textbox.custom_minimum_size.y = 35
	%Textbox.scroll_fit_content_height = false
	%Collapser.text = "Uncollapse"
	Collapsed = true

func Uncollapse():
	%Textbox.custom_minimum_size.y = 0
	%Textbox.scroll_fit_content_height = true
	%Collapser.text = "Collapse"
	Collapsed = false

func Format():
	return {
		"Type": "Text",
		"Text" : %Textbox.text
	}

func Unpack(Form : Dictionary):
	%Textbox.text = Form.Text

func TextFormat():
	return "Text : " + %Textbox.text.replace("\n"," (\\n) ")

func PreviewFocused():
	%TextPreview.visible = false
	%Textbox.visible = true
	%Textbox.grab_focus()

func EditorUnfocused():
	%TextPreview.text = %Textbox.text
	%TextPreview.visible = true
	%Textbox.visible = false
