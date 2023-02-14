extends Control

const BEZIER_POINTS : int = 20

var Lines : Array[Dictionary]

func _process(delta):
	queue_redraw()

func _draw():
	draw_set_transform(-global_position)
	for i in Lines:
		DrawBezier(i.Start, i.Start + i.SControl, i.End + i.EControl, i.End)

func DrawBezier(Start : Vector2, SControl : Vector2, EControl : Vector2, End : Vector2):
	var Points : PackedVector2Array
	for i in BEZIER_POINTS + 1:
		var Perc : float = float(i) / BEZIER_POINTS
		Points.append(Vector2(
			bezier_interpolate(Start.x, SControl.x, EControl.x, End.x, Perc),
			bezier_interpolate(Start.y, SControl.y, EControl.y, End.y, Perc)))
	draw_circle(Start, 4, Color.BLACK)
	draw_circle(End, 4, Color.BLACK)
	draw_polyline(Points, Color.BLACK, 8, true)
	draw_circle(Start, 2.5, Color.WHITE)
	draw_circle(End, 2.5, Color.WHITE)
	draw_polyline(Points, Color.WHITE, 5, true)

func ClearLines():
	Lines.clear()

func AddLine(Start : Vector2, SControl : Vector2, EControl : Vector2, End : Vector2):
	Lines.append({
		"Start":Start,
		"SControl":SControl,
		"EControl":EControl,
		"End":End
	})
