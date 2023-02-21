extends Camera2D

var MoveSpeed : float = 500

var MousePosition : Vector2

func _process(delta):
	var NewMousePosition : Vector2 = get_global_mouse_position()
	if Input.is_action_pressed("Drag"):
		var MouseChange : Vector2 = NewMousePosition - MousePosition
		position -= MouseChange
		NewMousePosition -= MouseChange
	MousePosition = NewMousePosition
	
	if Input.is_action_just_released("ZoomIn"):
		zoom += Vector2.ONE * 0.05
	if Input.is_action_just_released("ZoomOut"):
		zoom -= Vector2.ONE * 0.05
