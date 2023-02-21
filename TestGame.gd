extends Control

@export var Parser : DialogueParser

func _ready():
	Parser.Parse()
	Parser.TextChanged.connect(SetText)
	Parser.SelectionsChanged.connect(SetSelections)

func SetText(Text : String):
	$Label.text = Text

func SetSelections(Selections : Array[Dictionary]):
	for c in $VBox.get_children():
		c.queue_free()
	
	for i in Selections:
		var NewButton := Button.new()
		NewButton.text = i.Prompt
		NewButton.pressed.connect(Parser.Select.bind(i.ArrIndex))
		$VBox.add_child(NewButton)

func NextButton():
	Parser.Next()
	
	## DEBUGGING ##
	var Str : String = ""
	Str = "Next Command: " + Parser.Commands[Parser.MainPointer.GetIndex()]
	Str += "\nPointer Depth: %s" % Parser.MainPointer.GetPointerDepth()
	Str += "\nPointer Indent: %s" % Parser.MainPointer.GetIndent()
	$Debug.text = Str
