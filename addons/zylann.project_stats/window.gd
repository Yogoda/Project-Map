tool
extends WindowDialog

onready var _item_list = get_node("HBoxContainer/ItemList")
onready var _graph = get_node("HBoxContainer/Graph")

var _analyzer = null
var _count_labels = {}
var _data_dir = ""


func set_analyzer(analyzer):
	if _analyzer == analyzer:
		return
	
	if _analyzer != null:
		_analyzer.disconnect("scan_completed", self, "_on_stats_updated")
	
	_analyzer = analyzer
	
	if _analyzer != null:
		_analyzer.connect("scan_completed", self, "_on_stats_updated")
		
		# We can't assume the analyzer is processing or not,
		# so in case it has already finished, we need to refresh
		refresh()


func set_data_dir(data_dir):
	_data_dir = data_dir


func _on_stats_updated():
	refresh()


func refresh():
	if _analyzer == null:
		print("ERROR: can't refresh, analyzer not set")
		return
	
	_item_list.clear()
	
	var data = _analyzer.get_data()
	
	for name in data:
		var v = data[name]
		if typeof(v) == TYPE_DICTIONARY:
			for k in v:
				_item_list.add_item((name + ": " + str(k)).capitalize())
				_item_list.add_item(str(v[k]))
		else:
			_item_list.add_item(name.capitalize())
			_item_list.add_item(str(data[name]))
	
	var history = load_history(_data_dir)
	load_graph(history)


func load_graph(history):
	var points = []
	points.resize(len(history))

	for i in range(len(history)):
		var h = history[i]
		
		var unix_time = h[0]
		var data = h[2]
		
		# Time is rebased to beginning because absolute doesn't fit in floats...
		# TODO in the future we may need to find a solution for large graphs
		var point = Vector2(unix_time - history[0][0], 0)
		
		if typeof(data.lines_of_code) == TYPE_DICTIONARY:
			if data.lines_of_code.has("gdscript"):
				point.y = data.lines_of_code["gdscript"]
		
		points[i] = point
	
	_graph.set_xy_data(points, Rect2(0, 0, 0, 0))


static func extract_date(fname):
	var str_numbers = fname.split("_")
	var numbers = []
	for s in str_numbers:
		if s.is_valid_integer():
			numbers.append(s.to_int())
	#print("Str: ", fname, ", StrN: ", str_numbers, ", n: ", numbers)
	return {
		"year": numbers[0],
		"month": numbers[1],
		"day": numbers[2],
		"hour": numbers[3],
		"minute": 0,
		"second": 0
	}


func load_history(data_dir):
	var dir = Directory.new()
	var err = dir.change_dir(data_dir)
	if err != OK:
		print("ERROR: cannot open directory '", data_dir, "'")
		return
	
	var history = []
	
	dir.list_dir_begin()
	while true:
		var fname = dir.get_next()
		if fname == "":
			break
		
		if fname.get_extension() == "json":
			var date = extract_date(fname)
			var unix_time = OS.get_unix_time_from_datetime(date)
			
			var fpath = data_dir.plus_file(fname)
			var f = File.new()
			var ferr = f.open(fpath, File.READ)
			if ferr != OK:
				print("ERROR: cannot open file '", fpath, "', code ", err)
				return
			
			var text = f.get_as_text()
			var data = JSON.parse(text)
			if data.error != OK:
				print("ERROR: failed to parse '", fpath, "'")
				print("Line ", data.error_line, ": ", data.error_string)
				return
			
			history.append([unix_time, date, data.result])
	
	dir.list_dir_end()

	if len(history) == 0:
		print("No data files found, cannot build graph for Project Statistics")
		return
	
	history.sort_custom(self, "_history_sorter")
	return history


func _history_sorter(a, b):
	if a[0] < b[0]:
		return true
	return false


	