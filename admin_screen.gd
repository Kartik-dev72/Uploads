class_name AdminScreen
extends Control









signal closed


const PRESETS: = [
	{"name": "Classic meta", "survivor": "exorcist", "note": "The classic's favourite evolutions", 
		"items": ["magic_bolt", "throwing_knife", "battle_axe", "holy_water", "lightning", "boomerang", 
			"cooldown", "crit", "area", "magnet", "amount", "luck"]}, 
	{"name": "Blood & mercy", "survivor": "zealot", "note": "Get hit, heal it back", 
		"items": ["whip", "aura", "lightning", "scythe", "bulwark", "spirit_orbs", 
			"max_hp", "regen", "amount", "lifesteal", "duration", "relic"]}, 
	{"name": "Fortress", "survivor": "paladin", "note": "Nothing gets close", 
		"items": ["aura", "spirit_orbs", "boomerang", "familiar", "ravens", "sigil", 
			"regen", "relic", "luck", "might", "armor", "speed"]}, 
	{"name": "Projectile storm", "survivor": "hunter", "note": "Fill the screen with steel", 
		"items": ["throwing_knife", "magic_bolt", "nails", "tear", "sodom", "lightning", 
			"crit", "cooldown", "censer", "armor", "might", "amount"]}, 
	{"name": "Reaper", "survivor": "undertaker", "note": "Big sweeps around you", 
		"items": ["scythe", "whip", "requiem", "maw", "spear", "aura", 
			"lifesteal", "max_hp", "curse", "blast", "bounty", "regen"]}, 
]

const COLUMNS: = 6
const TILE: = 104

var _picked: = {}
var _survivor: = ""
var _realm: = 0
var _tiles: = {}
var _survivor_label: Label
var _realm_label: Label
var _count_label: Label

func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_survivor = str(Game.survivor().get("id", ""))
	_realm = Game.tier
	var dim: = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.03)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var scroll: = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = Game.safe_top() + 16.0
	scroll.offset_bottom = -16.0
	scroll.offset_left = 16.0
	scroll.offset_right = -16.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var box: = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 14)
	scroll.add_child(box)
	var accent: Color = Game.theme.ui["accent"]
	box.add_child(_title("ADMIN", 52, accent))
	box.add_child(_toggle("No ads", "Every 'watch an ad' offer pays out at once.", Game.no_ads, func(on: bool) -> void :
		Game.no_ads = on
		Game.save_profile()))
	box.add_child(_title("TEST RUN", 36, accent))
	box.add_child(_note("Level-ups, chests and trophies only offer the items you pick (locked ones too). The survivor's own weapon is always in."))
	_survivor_label = _stepper(box, "Survivor", func(step: int) -> void :
		var list: Array = Game.theme.survivors
		var i: = list.find(Game.theme.survivor(_survivor))
		_survivor = str(list[posmod(i + step, list.size())]["id"])
		_refresh())
	_realm_label = _stepper(box, "Realm", func(step: int) -> void :
		_realm = posmod(_realm + step, Game.theme.difficulties.size())
		_refresh())
	box.add_child(_title("Presets", 30, Color(1, 1, 1, 0.8)))
	var presets: = GridContainer.new()
	presets.columns = 2
	presets.add_theme_constant_override("h_separation", 10)
	presets.add_theme_constant_override("v_separation", 10)
	box.add_child(presets)
	for p: Dictionary in PRESETS:
		var b: = _button("%s\n%s" % [p["name"], p["note"]], 22, func() -> void : _use_preset(p))
		b.custom_minimum_size = Vector2(0, 86)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		presets.add_child(b)
	_count_label = _note("")
	box.add_child(_count_label)
	box.add_child(_title("Weapons", 30, Color(1, 1, 1, 0.8)))
	box.add_child(_grid(Game.WEAPONS.keys(), true))
	box.add_child(_title("Passives", 30, Color(1, 1, 1, 0.8)))
	box.add_child(_grid(Game.PASSIVES.keys(), false))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var clear: = _button("Clear", 28, func() -> void :
		_picked.clear()
		_refresh())
	var all: = _button("All", 28, func() -> void :
		for id: String in _tiles:
			_picked[id] = true
		_refresh())
	for b: Button in [clear, all]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	var play: = PauseScreen._menu_button("PLAY TEST RUN", accent, _play)
	box.add_child(play)
	box.add_child(PauseScreen._menu_button("Back", Color(1, 1, 1, 0.4), close))
	_refresh()

func close() -> void :
	closed.emit()
	queue_free()

func _use_preset(p: Dictionary) -> void :
	_picked.clear()
	for id: String in p["items"]:
		_picked[id] = true
	if not Game.theme.survivor(str(p["survivor"])).is_empty():
		_survivor = str(p["survivor"])
	_refresh()

func _play() -> void :
	if _picked.is_empty():
		_count_label.text = "Pick at least one item first."
		return
	Game.start_test_run(_survivor, _realm, _picked.keys())
	Game.sfx("select")
	LoadingCover.go(get_tree(), get_tree().change_scene_to_file.bind("res://main.tscn"))

func _refresh() -> void :
	var s: = Game.theme.survivor(_survivor)
	_survivor_label.text = str(s.get("name", "?"))
	_realm_label.text = str(Game.tier_info(_realm).get("name", "?"))
	var start: = str(s.get("weapon", ""))
	var w: = 0
	var p: = 0
	for id: String in _tiles:
		var on: bool = _picked.has(id) or id == start
		var b: Button = _tiles[id]
		b.modulate = Color.WHITE if on else Color(1, 1, 1, 0.3)
		b.button_pressed = on
		if on:
			if Game.WEAPONS.has(id):
				w += 1
			else:
				p += 1
	_count_label.text = "Picked: %d weapons (max %d held), %d passives (max %d held)" % [w, Game.MAX_WEAPONS, p, Game.MAX_PASSIVES]

func _grid(ids: Array, weapons: bool) -> GridContainer:
	var grid: = GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	for id: String in ids:
		var info: Dictionary = Game.theme.weapon(id) if weapons else Game.theme.passive(id)
		var b: = Button.new()
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(TILE, TILE + 18)
		b.icon = Game.theme.texture(str(info.get("icon", "")))
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.text = _short(str(info.get("name", id)))
		b.add_theme_font_size_override("font_size", 13)
		b.add_theme_constant_override("icon_max_width", 56)
		b.clip_text = true
		b.pressed.connect( func() -> void :
			if _picked.has(id):
				_picked.erase(id)
			else:
				_picked[id] = true
			Game.sfx("click")
			_refresh())
		_tiles[id] = b
		grid.add_child(b)
	return grid


static func _short(name: String) -> String:
	var out: = ""
	for w: String in name.replace("'s", "").split(" ", false):
		if w.to_lower() in ["of", "the", "a"]:
			continue
		if out != "" and out.length() + 1 + w.length() > 13:
			break
		out = w if out == "" else out + " " + w
	return out

func _stepper(box: Control, what: String, step: Callable) -> Label:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var name: = Label.new()
	name.text = what
	name.custom_minimum_size = Vector2(130, 0)
	name.add_theme_font_size_override("font_size", 26)
	row.add_child(name)
	row.add_child(_button("<", 30, step.bind(-1)))
	var value: = Label.new()
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 24)
	value.clip_text = true
	row.add_child(value)
	row.add_child(_button(">", 30, step.bind(1)))
	return value

func _toggle(what: String, note: String, value: bool, on_change: Callable) -> Control:
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", PauseScreen._panel_style(Color(1, 1, 1, 0.35)))
	var row: = HBoxContainer.new()
	panel.add_child(row)
	var col: = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var label: = Label.new()
	label.text = what
	label.add_theme_font_size_override("font_size", 30)
	col.add_child(label)
	col.add_child(_note(note))
	var b: = Button.new()
	b.toggle_mode = true
	b.button_pressed = value
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(120, 64)
	b.add_theme_font_size_override("font_size", 28)
	b.text = "ON" if value else "OFF"
	b.toggled.connect( func(on: bool) -> void :
		b.text = "ON" if on else "OFF"
		Game.sfx("click")
		on_change.call(on))
	row.add_child(b)
	return panel

func _button(text: String, font: int, action: Callable) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(72, 64)
	b.add_theme_font_size_override("font_size", font)
	b.pressed.connect( func() -> void :
		Game.sfx("click")
		action.call())
	return b

func _title(text: String, font: int, color: Color) -> Label:
	var l: = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)
	return l

func _note(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
	return l
