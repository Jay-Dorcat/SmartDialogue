extends PanelContainer
class_name FlowItem

@export var UpButton : BaseButton
@export var DownButton : BaseButton
@export var DeleteButton : BaseButton
@export var ColouredPanel : Control

signal Changed()

func _ready():
	UpButton.pressed.connect(MoveUp)
	DownButton.pressed.connect(MoveDown)
	DeleteButton.pressed.connect(Remove)
	get_parent().child_entered_tree.connect(Moved.unbind(1))
	ColouredPanel.self_modulate = get_parent().GetDepthColour()
	Moved()

func MoveUp():
	if CanMoveUp():
		get_parent().move_child(self,get_index() - 1)
		Changed.emit()

func MoveDown():
	if CanMoveDown():
		get_parent().move_child(self,get_index() + 1)
		Changed.emit()

func _notification(What : int):
	if What == NOTIFICATION_MOVED_IN_PARENT:
		Moved()

func Moved():
	UpButton.visible = CanMoveUp()
	DownButton.visible = CanMoveDown()

func CanMoveUp():
	return get_index() != 0

func CanMoveDown():
	return get_index() != get_parent().get_child_count() - 1

func Remove():
	get_parent().remove_child(self)
	Changed.emit()
	queue_free()

func Format():
	pass

func Unpack(Form : Dictionary):
	pass

func TextFormat():
	pass

func GetMapCore() -> MapCore:
	return get_tree().get_first_node_in_group("MapCore")

func HasChanged():
	Changed.emit()
