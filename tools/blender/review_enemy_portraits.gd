extends SceneTree

## Audits real PNGs and loader resolution; creates a labelled review board using
## actual PortraitArt controls. Run with a display to capture the board.
const Portraits = preload("res://scripts/ui/portrait_art.gd")
const OUT := "res://art_sources/blender"
var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var rows: Array[Dictionary] = []
	for id: String in Portraits.ENEMY_IDS:
		var path := Portraits.texture_path(id)
		var texture := Portraits.load_texture(id)
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://assets/portraits/%s.png" % id))
		var valid := texture != null and image != null and not image.is_empty()
		var count := 0
		if valid:
			valid = image.get_size() == Vector2i(64, 64)
			var colors := {}
			for y in range(image.get_height()):
				for x in range(image.get_width()):
					var color := image.get_pixel(x, y)
					colors[color.to_rgba32()] = true
					valid = valid and color.a8 == 255
			count = colors.size()
			valid = valid and count <= 20
			for p in [Vector2i(0,0), Vector2i(63,0), Vector2i(0,63), Vector2i(63,63)]:
				valid = valid and image.get_pixelv(p).to_rgba32() == Color.html("#20272B").to_rgba32()
		rows.append({"id": id, "path": path, "passed": valid, "colors": count})
		if not valid:
			failures += 1
			printerr("Portrait validation failed: ", id)
	var report := FileAccess.open(OUT + "/validation.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"failures": failures, "portraits": rows}, "\t") + "\n")
	report.close()
	print("Blender portrait validation: %d/13 passed" % (13 - failures))
	if DisplayServer.get_name() == "headless":
		quit(1 if failures else 0)
		return
	DisplayServer.window_set_size(Vector2i(1120, 1050))
	root.content_scale_size = Vector2i(1120, 1050)
	var bg := ColorRect.new()
	bg.color = Color.html("#11191E")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var heading := Label.new()
	heading.text = "ASHFALL ROAD  /  BLENDER ENEMY SCULPTURES"
	heading.position = Vector2(28, 18)
	heading.add_theme_font_size_override("font_size", 23)
	root.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "Posed 3D models -> game portraits   |   large preview + actual 64 px / 50 px"
	subtitle.position = Vector2(28, 51)
	root.add_child(subtitle)
	for i in range(Portraits.ENEMY_IDS.size()):
		var id: String = Portraits.ENEMY_IDS[i]
		var origin := Vector2(28 + (i % 4) * 275, 92 + (i / 4) * 236)
		var label := Label.new()
		label.text = id.trim_prefix("enemy_").capitalize()
		label.position = origin
		label.add_theme_font_size_override("font_size", 18)
		root.add_child(label)
		for item in [[160, Vector2(0,29)], [64, Vector2(171,29)], [50, Vector2(171,109)]]:
			var view := Portraits.create_view(id, Color.DIM_GRAY)
			view.position = origin + item[1]
			view.size = Vector2(item[0], item[0])
			root.add_child(view)
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "/portrait_review.png")
	print("Saved portrait_review.png from the actual game portrait controls")
	quit(1 if failures else 0)
