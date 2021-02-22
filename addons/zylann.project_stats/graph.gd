tool
extends Control


var _data_bounds = Rect2()
var _visual_points = PoolVector2Array()


func set_xy_data(data, base_bounds=null):
	var min_pos = data[0]
	var max_pos = min_pos

	if base_bounds != null:
		min_pos.x = min(min_pos.x, base_bounds.position.x)
		min_pos.y = min(min_pos.y, base_bounds.position.y)
		max_pos.x = max(max_pos.x, base_bounds.end.x)
		max_pos.y = max(max_pos.y, base_bounds.end.y)

	_visual_points.resize(len(data))
	
	for i in range(len(data)):
		var pos = data[i]
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
		_visual_points[i] = pos
	
	_data_bounds = Rect2(min_pos, max_pos - min_pos)
	#print("Bounds: ", _data_bounds)

	var rs = self.rect_size
	
	for pos in data:
		var npos = rs * (pos - min_pos) / _data_bounds.size
		_visual_points

	update()


func _draw():
	var vscale = rect_size / _data_bounds.size
	vscale.y = -vscale.y
	draw_set_transform(-_data_bounds.position + Vector2(0, rect_size.y), 0, vscale)

	var color = Color(1, 1, 1, 0.7)

	for i in range(1, len(_visual_points)):
		draw_line(_visual_points[i - 1], _visual_points[i], color, true)

	# Baaah this function expects dupes...
	#draw_polyline(_visual_points, Color(1, 0, 0, 1))


