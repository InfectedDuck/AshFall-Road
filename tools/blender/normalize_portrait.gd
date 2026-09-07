extends SceneTree

## One authored palette for the entire Blender set. Histogram quantization can
## discard tiny story accents (the scanner lens or brass ring), so reserve them.
const PALETTE := [
	"#20272B", "#141C22", "#343E40", "#515F62", "#829293",
	"#A5ABA4", "#CBC6AA", "#31585A", "#616C4B", "#AD8C4F",
	"#8D513A", "#A6603B", "#65505E", "#868091", "#BC5747",
	"#C39C82", "#A67A58", "#74503E", "#B5BFC0", "#8B7C66",
]

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		printerr("Usage: --script tools/blender/normalize_portrait.gd -- source.png output.png")
		quit(2)
		return
	var source := Image.load_from_file(args[0])
	if source == null or source.is_empty() or source.get_width() != source.get_height():
		printerr("Expected a square Blender render: ", args[0])
		quit(3)
		return
	source.convert(Image.FORMAT_RGBA8)
	source.resize(64, 64, Image.INTERPOLATE_NEAREST)
	var colors: Array[Color] = []
	for hex: String in PALETTE: colors.append(Color.html(hex))
	# Color-management dithering can move world-background pixels by one channel
	# value. Capture all four sampled corner colors, like the existing normalizer.
	var backgrounds := {}
	for p in [Vector2i(0,0), Vector2i(63,0), Vector2i(0,63), Vector2i(63,63)]:
		backgrounds[source.get_pixelv(p).to_rgba32()] = true
	for y in range(64):
		for x in range(64):
			var pixel := source.get_pixel(x, y)
			var near_background := absf(pixel.r - colors[0].r) <= 3.0/255.0 and absf(pixel.g - colors[0].g) <= 3.0/255.0 and absf(pixel.b - colors[0].b) <= 3.0/255.0
			if backgrounds.has(pixel.to_rgba32()) or near_background:
				source.set_pixel(x, y, colors[0])
				continue
			var best := colors[1]
			var distance := INF
			for i in range(1, colors.size()):
				var candidate := colors[i]
				var dr := pixel.r - candidate.r
				var dg := pixel.g - candidate.g
				var db := pixel.b - candidate.b
				var difference := dr*dr + dg*dg + db*db
				if difference < distance:
					distance = difference
					best = candidate
			best.a = 1.0
			source.set_pixel(x, y, best)
	var result := source.save_png(args[1])
	if result != OK:
		printerr("Cannot save normalized portrait: ", args[1])
		quit(4)
		return
	print("Prepared shared-palette 64x64 portrait: ", args[1])
	quit()
