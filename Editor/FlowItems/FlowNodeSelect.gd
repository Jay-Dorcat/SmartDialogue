extends Button

@export var SubList : VBoxContainer

func Open():
	$Canvas.visible = true

func Cancel():
	$Canvas.visible = false

func AddText():
	SubList.AddText()
	Cancel()

func AddSelection():
	SubList.AddSelection()
	Cancel()

func AddJump():
	SubList.AddJump()
	Cancel()

func AddOperator():
	SubList.AddOperator()
	Cancel()

func AddBranch():
	SubList.AddBranch()
	Cancel()

func AddTrigger():
	SubList.AddTrigger()
	Cancel()
