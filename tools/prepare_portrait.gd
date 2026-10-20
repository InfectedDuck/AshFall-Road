extends SceneTree

const DEFAULT_SIZE := 64
const DEFAULT_MAX_COLORS := 20
## Background pixels within this RGB distance of a corner colour, and connected
## to the image edge, are flattened. Exact-match-only masks left speckled fields.
const BACKGROUND_TOLERANCE := 0.09


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("Usage: godot --headless --script tools/prepare_portrait.gd -- <source.png> <output.png> [max_colors] [flat_background_hex] [size] [nearest|area]")
		quit(2)
		return

	var source_path := ProjectSettings.globalize_path(str(args[0]))
	var output_path := ProjectSettings.globalize_path(str(args[1]))
	var maximum_colors := clampi(int(args[2]) if args.size() > 2 else DEFAULT_MAX_COLORS, 2, 256)
	var flatten_background := args.size() > 3 and not str(args[3]).is_empty()
	var background_color := Color.html(str(args[3])) if flatten_background else Color.TRANSPARENT
	var final_size := clampi(int(args[4]) if args.size() > 4 else DEFAULT_SIZE, 16, 512)
	# Area sampling keeps painterly sources readable at larger sizes; nearest
	# preserves the hard grid of sources already drawn as pixel art.
	var interpolation := Image.INTERPOLATE_LANCZOS if args.size() > 5 and str(args[5]) == "area" else Image.INTERPOLATE_NEAREST
	var image := Image.load_from_file(source_path)
	if image == null or image.is_empty():
		printerr("Could not load portrait source: %s" % source_path)
		quit(3)
		return

	var source_size := image.get_size()
	image.convert(Image.FORMAT_RGBA8)
	if source_size.x != source_size.y:
		var side := mini(source_size.x, source_size.y)
		var offset := Vector2i((source_size.x - side) / 2, (source_size.y - side) / 2)
		image = image.get_region(Rect2i(offset, Vector2i(side, side)))
	image.resize(final_size, final_size, interpolation)
	var background_mask := PackedByteArray()
	if flatten_background:
		background_mask = _corner_color_mask(image, background_color)
		_paint_mask(image, background_mask, background_color)
	var colors_before := _unique_color_count(image)
	var quantized_color_limit := maximum_colors - 1 if flatten_background else maximum_colors
	if colors_before > quantized_color_limit:
		_apply_median_cut(image, quantized_color_limit, background_mask)
	if flatten_background:
		_paint_mask(image, background_mask, background_color)

	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var error := image.save_png(output_path)
	if error != OK:
		printerr("Could not save prepared portrait: %s" % output_path)
		quit(4)
		return
	print("Prepared %s (%dx%d) -> %s (%dx%d, %d -> %d colors)" % [
		source_path,
		source_size.x,
		source_size.y,
		output_path,
		final_size,
		final_size,
		colors_before,
		_unique_color_count(image),
	])
	quit()


## A corner seeds the background only when it is close to the target colour or
## shares its colour with another corner (a background band). A lone corner of
## another colour is the subject cropped by the frame and must not be erased.
func _corner_color_mask(image: Image, target: Color) -> PackedByteArray:
	var corners: Array[Color] = [
		image.get_pixel(0, 0),
		image.get_pixel(image.get_width() - 1, 0),
		image.get_pixel(0, image.get_height() - 1),
		image.get_pixel(image.get_width() - 1, image.get_height() - 1),
	]
	var references: Array[Color] = []
	for index in range(corners.size()):
		var shared := false
		for other_index in range(corners.size()):
			if other_index != index and _color_distance(corners[index], corners[other_index]) <= 0.03:
				shared = true
		if _color_distance(corners[index], target) <= 0.12 or shared:
			references.append(corners[index])
	var width := image.get_width()
	var height := image.get_height()
	var mask := PackedByteArray()
	mask.resize(width * height)
	var queue: Array[Vector2i] = []
	for x in range(width):
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, height - 1))
	for y in range(height):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(width - 1, y))
	while not queue.is_empty():
		var point: Vector2i = queue.pop_back()
		if point.x < 0 or point.y < 0 or point.x >= width or point.y >= height:
			continue
		var index := point.y * width + point.x
		if mask[index] == 1 or not _near_any(image.get_pixel(point.x, point.y), references):
			continue
		mask[index] = 1
		queue.append(point + Vector2i.LEFT)
		queue.append(point + Vector2i.RIGHT)
		queue.append(point + Vector2i.UP)
		queue.append(point + Vector2i.DOWN)
	return mask


func _near_any(color: Color, references: Array[Color]) -> bool:
	for reference in references:
		if _color_distance(color, reference) <= BACKGROUND_TOLERANCE:
			return true
	return false


func _color_distance(left: Color, right: Color) -> float:
	return Vector3(left.r - right.r, left.g - right.g, left.b - right.b).length()


func _paint_mask(image: Image, mask: PackedByteArray, color: Color) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[y * image.get_width() + x] == 1:
				image.set_pixel(x, y, color)


func _unique_color_count(image: Image) -> int:
	var colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			colors[image.get_pixel(x, y).to_rgba32()] = true
	return colors.size()


## Background pixels are excluded from the histogram: the flat field otherwise
## dominates the pixel counts and starves saturated subject colours of buckets.
func _apply_median_cut(image: Image, maximum_colors: int, background_mask: PackedByteArray) -> void:
	var histogram := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if not background_mask.is_empty() and background_mask[y * image.get_width() + x] == 1:
				continue
			var color := image.get_pixel(x, y)
			var key := color.to_rgba32()
			if histogram.has(key):
				histogram[key]["count"] = int(histogram[key]["count"]) + 1
			else:
				histogram[key] = {"color": color, "count": 1}

	var initial_bucket: Array = []
	for entry: Dictionary in histogram.values():
		initial_bucket.append(entry)
	var buckets: Array = [initial_bucket]
	while buckets.size() < maximum_colors:
		var split_index := _best_bucket_to_split(buckets)
		if split_index < 0:
			break
		var parts := _split_bucket(buckets[split_index])
		if parts.size() != 2:
			break
		buckets.remove_at(split_index)
		buckets.append(parts[0])
		buckets.append(parts[1])

	var palette: Array[Color] = []
	for bucket: Array in buckets:
		palette.append(_average_color(bucket))
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			image.set_pixel(x, y, _nearest_color(image.get_pixel(x, y), palette))


func _best_bucket_to_split(buckets: Array) -> int:
	var best_index := -1
	var best_score := -1.0
	for index in range(buckets.size()):
		var bucket: Array = buckets[index]
		if bucket.size() < 2:
			continue
		var ranges := _bucket_ranges(bucket)
		var weight := 0
		for entry: Dictionary in bucket:
			weight += int(entry["count"])
		var score: float = maxf(ranges.x, maxf(ranges.y, ranges.z)) * float(weight)
		if score > best_score:
			best_score = score
			best_index = index
	return best_index


func _split_bucket(bucket: Array) -> Array:
	var ranges := _bucket_ranges(bucket)
	var channel := 0
	if ranges.y >= ranges.x and ranges.y >= ranges.z:
		channel = 1
	elif ranges.z >= ranges.x and ranges.z >= ranges.y:
		channel = 2
	var sorted_bucket := bucket.duplicate(true)
	sorted_bucket.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return _channel_value(left["color"], channel) < _channel_value(right["color"], channel)
	)
	var total_weight := 0
	for entry: Dictionary in sorted_bucket:
		total_weight += int(entry["count"])
	var running_weight := 0
	var split_at := 1
	for index in range(sorted_bucket.size() - 1):
		running_weight += int(sorted_bucket[index]["count"])
		if running_weight * 2 >= total_weight:
			split_at = index + 1
			break
	return [sorted_bucket.slice(0, split_at), sorted_bucket.slice(split_at)]


func _bucket_ranges(bucket: Array) -> Vector3:
	var minimum := Vector3(1.0, 1.0, 1.0)
	var maximum := Vector3.ZERO
	for entry: Dictionary in bucket:
		var color: Color = entry["color"]
		minimum = Vector3(minf(minimum.x, color.r), minf(minimum.y, color.g), minf(minimum.z, color.b))
		maximum = Vector3(maxf(maximum.x, color.r), maxf(maximum.y, color.g), maxf(maximum.z, color.b))
	return maximum - minimum


func _channel_value(color: Color, channel: int) -> float:
	if channel == 1:
		return color.g
	if channel == 2:
		return color.b
	return color.r


func _average_color(bucket: Array) -> Color:
	var total := 0
	var accumulated := Color(0, 0, 0, 0)
	for entry: Dictionary in bucket:
		var count := int(entry["count"])
		var color: Color = entry["color"]
		accumulated += color * float(count)
		total += count
	return accumulated / float(maxi(1, total))


func _nearest_color(color: Color, palette: Array[Color]) -> Color:
	var nearest := palette[0]
	var nearest_distance := INF
	for candidate: Color in palette:
		var red := color.r - candidate.r
		var green := color.g - candidate.g
		var blue := color.b - candidate.b
		var alpha := color.a - candidate.a
		var distance := red * red + green * green + blue * blue + alpha * alpha
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest
