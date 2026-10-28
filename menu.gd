extends Control








enum Tab{SURVIVORS, UPGRADES, QUESTS, ACHIEVEMENTS, MAPS, GRIMOIRE}

const PORTRAIT_SIZE: = 96
const UPGRADE_ICON_SIZE: = 72
const ROW_HEIGHT: = 124
const ROW_BUTTON: = Vector2(130, 92)
const NAME_WIDTH: = 380.0

@onready var _title: Label = $VBox / Title
@onready var _coin_icon: TextureRect = $VBox / TopRow / CoinIcon
@onready var _coin_label: Label = $VBox / TopRow / CoinLabel
@onready var _survivors_tab: Button = $VBox / Tabs / SurvivorsTab
@onready var _upgrades_tab: Button = $VBox / Tabs / UpgradesTab
@onready var _list: VBoxContainer = $VBox / Scroll / List
@onready var _last_run: Label = $VBox / LastRun

var _tab: = Tab.SURVIVORS
var _quests_tab: Button
var _quests_badge: PanelContainer
var _reveal: Control
var _settings: Control
var _admin: AdminScreen
var _achievements_tab: Button
var _grimoire_tab: Button
var _quick: Button
var _start: Button
var _back: Button
var _maps_opened_at: = 0
var _busy: = false
var _dev_rows: Array[Control] = []

func _ready() -> void :
	get_tree().paused = false
	Game.dev_mode = false
	Game.end_test_run()
	if OS.is_debug_build():
		var dev: = Button.new()
		dev.text = "Dev Test"
		dev.custom_minimum_size = Vector2(0, 64)
		dev.add_theme_font_size_override("font_size", 26)
		dev.pressed.connect( func() -> void :
			Game.dev_mode = true
			Game.sfx("select")
			LoadingCover.go(get_tree(), get_tree().change_scene_to_file.bind("res://main.tscn")))
		$VBox.add_child(dev)
		_dev_rows.append(dev)
		$VBox.move_child(dev, $VBox / StartButton.get_index())
		var unlock_row: = HBoxContainer.new()
		unlock_row.add_theme_constant_override("separation", 10)
		for entry: Array in [["Unlock Levels", Game.dev_unlock_all_levels], ["Unlock Heroes", Game.dev_unlock_all_heroes], ["Unlock Items", Game.dev_unlock_all_items]]:
			var b: = Button.new()
			b.text = entry[0]
			b.custom_minimum_size = Vector2(0, 56)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.add_theme_font_size_override("font_size", 22)
			var action: Callable = entry[1]
			b.pressed.connect( func() -> void :
				action.call()
				Game.sfx("select")
				_refresh())
			unlock_row.add_child(b)
		$VBox.add_child(unlock_row)
		_dev_rows.append(unlock_row)
		$VBox.move_child(unlock_row, $VBox / StartButton.get_index())
		var save_row: = HBoxContainer.new()
		save_row.add_theme_constant_override("separation", 10)
		var souls: = Button.new()
		souls.text = "+1000 Souls"
		souls.pressed.connect( func() -> void :
			Game.dev_add_souls()
			Game.sfx("select")
			_refresh())
		var reset: = Button.new()
		reset.text = "Reset Save"
		reset.pressed.connect( func() -> void :
			if reset.text == "Reset Save":
				reset.text = "Tap again: WIPE ALL"
				return
			Game.dev_reset_save()
			get_tree().reload_current_scene())
		for b: Button in [souls, reset]:
			b.custom_minimum_size = Vector2(0, 56)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.add_theme_font_size_override("font_size", 22)
			save_row.add_child(b)
		$VBox.add_child(save_row)
		_dev_rows.append(save_row)
		$VBox.move_child(save_row, $VBox / StartButton.get_index())
	var mood: = Ambience.new()
	$Background.add_child(mood)
	var start: Button = $VBox / StartButton
	start.text = "START"
	start.add_theme_font_size_override("font_size", 46)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.62, 0.13, 0.05).lightened(0.12 if state == "hover" else (0.25 if state == "pressed" else 0.0))
		sb.border_color = Game.theme.ui["accent"]
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(10)
		sb.shadow_color = Color(1, 0.35, 0.1, 0.35)
		sb.shadow_size = 12
		start.add_theme_stylebox_override(state, sb)
	_title.add_theme_font_size_override("font_size", 64)
	_title.add_theme_color_override("font_outline_color", Color(0.25, 0.03, 0.02))
	_title.add_theme_constant_override("outline_size", 16)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_title.add_theme_constant_override("shadow_offset_y", 6)
	for tab: Button in [_survivors_tab, _upgrades_tab]:
		tab.add_theme_font_size_override("font_size", 24)
	_quests_tab = _make_tab("Quests", Tab.QUESTS)
	_achievements_tab = _make_tab("Achievements", Tab.ACHIEVEMENTS)
	_grimoire_tab = _make_tab("Grimoire", Tab.GRIMOIRE)
	_quests_badge = _badge(_quests_tab)
	_build_settings_button()
	for tab: Button in $VBox / Tabs.get_children():
		tab.add_theme_font_size_override("font_size", 18)
		tab.clip_text = true
	_build_quick_play(start)
	_refresh()
	if RunSave.exists() and not RunSave.read().is_empty():
		_saved_run_popup()
	else:
		RunSave.discard()
		_maybe_shop_hint()




const SETTINGS_BUTTON: = Vector2(150, 52)

func _build_settings_button() -> void :
	var row: = $VBox / TopRow
	var twin: = Control.new()
	twin.custom_minimum_size = SETTINGS_BUTTON
	twin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(twin)
	row.move_child(twin, 0)
	var b: = Button.new()
	b.text = "Settings"
	b.custom_minimum_size = SETTINGS_BUTTON
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(_open_settings)
	row.add_child(b)

func _open_settings() -> void :
	if is_instance_valid(_settings):
		return
	Game.sfx("click")
	var t: = Game.theme
	_settings = Control.new()
	_settings.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings.add_child(center)
	var box: = VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 20)
	center.add_child(box)
	var title: = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", t.ui["accent"])
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 12)
	box.add_child(title)
	PauseScreen.build_settings(box, false)
	if Ads.privacy_options_required():
		box.add_child(PauseScreen._menu_button("Ad Privacy Settings", Color(1, 1, 1, 0.4), func() -> void : Ads.show_privacy_options()))
	box.add_child(_admin_entry())
	box.add_child(PauseScreen._menu_button("Back", t.ui["accent"], _close_settings))
	add_child(_settings)



func _admin_entry() -> Control:
	if Game.admin:
		return PauseScreen._menu_button("Admin", Color(1, 0.4, 0.3, 0.7), _open_admin)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var field: = LineEdit.new()
	field.placeholder_text = "Enter code"
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.custom_minimum_size = Vector2(0, 64)
	field.add_theme_font_size_override("font_size", 26)
	field.secret = true
	row.add_child(field)
	var ok: = Button.new()
	ok.text = "OK"
	ok.custom_minimum_size = Vector2(110, 64)
	ok.focus_mode = Control.FOCUS_NONE
	ok.add_theme_font_size_override("font_size", 26)
	row.add_child(ok)
	var check: = func(_t: = "") -> void :
		if field.text.strip_edges().to_upper() == Game.ADMIN_CODE:
			Game.admin = true
			Game.save_profile()
			Game.sfx("jackpot")
			_close_settings()
			_open_admin()
		else:
			field.text = ""
			field.placeholder_text = "Wrong code"
			Game.sfx("click")
	ok.pressed.connect(check)
	field.text_submitted.connect(check)
	return row

func _open_admin() -> void :
	_close_settings()
	if is_instance_valid(_admin):
		return
	_admin = AdminScreen.new()
	add_child(_admin)

func _close_settings() -> void :
	if is_instance_valid(_settings):
		_settings.queue_free()
	_settings = null



func _badge(tab: Button) -> PanelContainer:
	var badge: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.85, 0.08, 0.05)
	sb.border_color = Color(1, 0.85, 0.6)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	badge.add_theme_stylebox_override("panel", sb)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(30, 30)
	var count: = Label.new()
	count.add_theme_font_size_override("font_size", 18)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(count)
	badge.anchor_left = 1.0
	badge.anchor_right = 1.0
	badge.offset_left = -36
	badge.offset_right = -4
	badge.offset_top = 2
	badge.offset_bottom = 32
	badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tab.add_child(badge)
	badge.visible = false
	var pulse: = badge.create_tween().set_loops()
	pulse.tween_property(badge, "scale", Vector2(1.15, 1.15), 0.45)
	pulse.tween_property(badge, "scale", Vector2.ONE, 0.45)
	badge.resized.connect( func() -> void : badge.pivot_offset = badge.size / 2.0)
	return badge

func _make_tab(label: String, tab: Tab) -> Button:
	var b: = Button.new()
	b.text = label
	b.toggle_mode = true
	b.custom_minimum_size = Vector2(0, 72)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 24)
	b.pressed.connect(_show_tab.bind(tab))
	$VBox / Tabs.add_child(b)
	return b


func _build_quick_play(start: Button) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$VBox.add_child(row)
	$VBox.move_child(row, start.get_index())
	_start = start
	_quick = Button.new()
	_quick.custom_minimum_size = Vector2(250, start.custom_minimum_size.y)
	_quick.add_theme_font_size_override("font_size", 22)
	_quick.pressed.connect( func() -> void : _play(Game.tier))
	start.reparent(row)
	start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_quick)
	_back = Button.new()
	_back.text = "BACK"
	_back.custom_minimum_size = _quick.custom_minimum_size
	_back.add_theme_font_size_override("font_size", 40)
	_back.pressed.connect(_leave_maps)
	row.add_child(_back)





func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		for c in get_children():
			if c is DevilTip:
				c._close()
				return
			if c == _reveal:
				_reveal.queue_free()
				_reveal = null
				return
			if c == _settings:
				_close_settings()
				return
			if c == _admin:
				_admin.close()
				return
		var book: = _list.get_child(0) as Grimoire if _tab == Tab.GRIMOIRE and _list.get_child_count() > 0 else null
		if book and book.close_page():
			return
		if _tab == Tab.MAPS:
			_leave_maps()
		else:
			get_tree().quit()







func _on_start_pressed() -> void :
	if Time.get_ticks_msec() - _maps_opened_at <= 400:
		return
	if _tab == Tab.MAPS:
		_play(Game.tier)
		return
	Game.sfx("click")
	_maps_opened_at = Time.get_ticks_msec()
	if _tab != Tab.SURVIVORS:
		_tab = Tab.SURVIVORS
		_refresh()
		return
	_tab = Tab.MAPS
	_maps_opened_at = Time.get_ticks_msec()
	_refresh()

func _leave_maps() -> void :
	Game.sfx("click")
	_tab = Tab.SURVIVORS
	_refresh()

func _play(tier: int) -> void :
	if not Game.progress.is_tier_unlocked(tier):
		return
	Game.select_tier(tier)
	Game.sfx("select")
	LoadingCover.go(get_tree(), get_tree().change_scene_to_file.bind("res://main.tscn"))

func _show_tab(tab: int) -> void :
	_tab = tab as Tab
	Game.sfx("click")
	_refresh()

func _refresh() -> void :
	_refresh_header()
	var t: = Game.theme
	for child in _list.get_children():
		child.queue_free()
	match _tab:
		Tab.SURVIVORS:
			for s: Dictionary in t.survivors:
				_list.add_child(_survivor_row(s))
		Tab.UPGRADES:
			for u: Dictionary in _upgrades_by_price():
				_list.add_child(_upgrade_row(u))
			_list.add_child(_refund_button())
		Tab.QUESTS:
			_build_quests()
		Tab.ACHIEVEMENTS:
			_build_achievements()
		Tab.GRIMOIRE:
			_list.add_child(Grimoire.new())
		Tab.MAPS:
			_build_maps()



func _refresh_picked() -> void :
	_refresh_header()
	for row in _list.get_children():
		if row.is_queued_for_deletion():
			continue
		var fresh: Control = null
		if row.has_meta("survivor"):
			var s: Dictionary = row.get_meta("survivor")
			if bool(row.get_meta("picked")) != Game.is_selected(s):
				fresh = _survivor_row(s)
		elif row.has_meta("tier"):
			var i: int = row.get_meta("tier")
			if bool(row.get_meta("picked")) != (i == Game.tier):
				fresh = _map_row(i)
		if fresh:
			_list.add_child(fresh)
			_list.move_child(fresh, row.get_index())
			row.queue_free()


func _refresh_header() -> void :
	var t: = Game.theme
	$Background.color = t.ui["background"]
	_title.text = t.title
	_title.add_theme_color_override("font_color", t.ui["title"])
	_coin_icon.texture = t.texture(t.pickups["coin"])
	_coin_label.text = "%d %s" % [Game.coins, t.currency]
	Game.progress.ensure_today()
	_survivors_tab.set_pressed_no_signal(_tab == Tab.SURVIVORS)
	_upgrades_tab.set_pressed_no_signal(_tab == Tab.UPGRADES)
	_quests_tab.set_pressed_no_signal(_tab == Tab.QUESTS)
	_achievements_tab.set_pressed_no_signal(_tab == Tab.ACHIEVEMENTS)
	_grimoire_tab.set_pressed_no_signal(_tab == Tab.GRIMOIRE)
	var claimable: = Game.progress.claimable_quests()
	_quests_badge.visible = claimable > 0
	_quests_badge.get_child(0).text = str(claimable)
	_last_run.text = _last_run_text()
	var to_survivors: = _tab != Tab.SURVIVORS and _tab != Tab.MAPS
	_start.text = "CHARACTER SELECT" if to_survivors else "START"
	_start.add_theme_font_size_override("font_size", 30 if to_survivors else 46)
	_quick.visible = _tab != Tab.MAPS
	_back.visible = _tab == Tab.MAPS
	for row in _dev_rows:
		row.visible = _tab != Tab.MAPS
	var tier: = clampi(Game.tier, 0, t.difficulties.size() - 1)
	_quick.text = "QUICK PLAY\n%s · %s" % [Game.survivor()["name"], Game.tier_info(tier)["name"]]



func _build_maps() -> void :
	var title: = _label("Choose your descent", 30, Game.theme.ui["title"])
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_child(title)
	for i in Game.theme.difficulties.size():
		_list.add_child(_map_row(i))

func _map_row(i: int) -> Control:
	var t: = Game.theme
	var info: = Game.tier_info(i)
	var open: = Game.progress.is_tier_unlocked(i)
	var row: = _row_panel(open and i == Game.tier)
	row.set_meta("tier", i)
	row.set_meta("picked", i == Game.tier)
	row.custom_minimum_size.y = 150
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_map_preview(i, open))
	var text: = VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.add_child(_label(str(info["name"]).to_upper() if open else "? ? ?", 30, Color.WHITE if open else Color(1, 1, 1, 0.5)))
	if open:
		text.add_child(_label(str(info["desc"]), 20, t.ui["accent"]))
		text.add_child(_label(_layout_text(i), 18, Color(1, 1, 1, 0.75)))
		if Game.progress.tiers_won.has(i):
			text.add_child(_label("Conquered", 18, t.ui["xp"]))
	else:
		text.add_child(_label("Win a run on %s to unlock" % Game.tier_info(i - 1)["name"], 20, Color(1, 1, 1, 0.5)))
	hbox.add_child(text)
	var chosen: = open and i == Game.tier
	var button: = _row_button()
	button.text = "Chosen" if chosen else ("Choose" if open else "Locked")
	button.disabled = not open or chosen
	button.pressed.connect(_choose_map.bind(i))
	hbox.add_child(button)
	return row


func _layout_text(i: int) -> String:
	var axis: = str(Game.theme.level_look(i, "terrain").get("band", {}).get("axis", ""))
	var layout: = "Open in every direction"
	if axis == "x":
		layout = "Corridor: left and right"
	elif axis == "y":
		layout = "Shaft: up and down"
	var waiting: Array[String] = []
	if not RealmGoals.is_done("hero", i):
		waiting.append("Rescue")
	if not RealmGoals.is_done("item", i):
		waiting.append("Treasure")
	var goals: = "Rescue and treasure found" if waiting.is_empty() else " and ".join(waiting) + " waiting"
	return "%s  ·  %s" % [layout, goals]

func _choose_map(i: int) -> void :
	if i == Game.tier:
		return
	Game.select_tier(i)
	Game.sfx("click")
	_refresh_picked()


func _map_preview(i: int, open: bool) -> Control:
	var t: = Game.theme
	var ground: Array = [GameMap.preview_async(i) if open else null]
	var table: Array = t.level_look(i, "spawn_table")
	var monster: Texture2D = null
	if not table.is_empty():
		monster = t.texture(str(t.enemies.get(table[0]["enemy"], {}).get("sprite", "")))
	var band: Dictionary = t.level_look(i, "terrain").get("band", {})
	var walls: Array[Texture2D] = []
	for o: Dictionary in t.level_look(i, "map_obstacles"):
		var tex: = t.texture(str(o.get("sprite", "")))
		if tex:
			walls.append(tex)
	var box: = Control.new()
	box.custom_minimum_size = Vector2(126, 126)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.draw.connect( func() -> void :
		var r: = Rect2(Vector2.ZERO, box.size)
		if not open:
			_draw_sealed(box, r)
			return
		if ground[0]:
			box.draw_texture_rect(ground[0], r, false)
		else:
			box.draw_rect(r, Color(t.level_look(i, "map").get("ground_dark", Color(0.1, 0.1, 0.1))))
		_draw_preview_walls(box, r, str(band.get("axis", "")), walls)
		if monster:
			var size: = monster.get_size() * 3.5
			box.draw_texture_rect(monster, Rect2((box.size - size) / 2.0, size), false)
		_draw_preview_goals(box, r, i)
		box.draw_rect(r, Color(1, 1, 1, 0.25), false, 2.0))
	if open and ground[0] == null:
		var poll: = func() -> void :
			ground[0] = GameMap.preview_async(i)
			if ground[0]:
				box.queue_redraw()
		box.ready.connect( func() -> void :
			var tw: = box.create_tween().set_loops(400)
			tw.tween_callback( func() -> void :
				if ground[0] == null:
					poll.call()
				else:
					tw.kill()).set_delay(0.05))
	if not open:
		var tw: = box.create_tween().set_loops()
		tw.tween_method( func(_v: float) -> void : box.queue_redraw(), 0.0, 1.0, 1.0)
	box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return box



const PREVIEW_WALL: = 0.2
func _draw_preview_walls(box: Control, r: Rect2, axis: String, walls: Array[Texture2D]) -> void :
	if axis == "":
		return
	var depth: = (r.size.y if axis == "x" else r.size.x) * PREVIEW_WALL
	for side in 2:
		var dark: = Rect2(r.position, Vector2(r.size.x, depth)) if axis == "x" else Rect2(r.position, Vector2(depth, r.size.y))
		if side == 1:
			dark.position += Vector2(0, r.size.y - depth) if axis == "x" else Vector2(r.size.x - depth, 0)
		box.draw_rect(dark, Color(0, 0, 0, 0.85))
		if walls.is_empty():
			continue
		var n: = 7
		for k in n:
			var tex: Texture2D = walls[(k + side * 2) % walls.size()]
			var size: = tex.get_size() * 1.2
			var along: = (k + 0.5) / n * (r.size.x if axis == "x" else r.size.y)
			var edge: = depth if side == 0 else (r.size.y if axis == "x" else r.size.x) - depth
			var foot: = Vector2(along, edge + (0.0 if side == 0 else size.y * 0.6)) if axis == "x" else Vector2(edge + (size.x * 0.3 if side == 0 else - size.x * 0.3), along + size.y * 0.5)
			box.draw_texture_rect(tex, Rect2(foot - Vector2(size.x * 0.5, size.y), size), false)



func _draw_preview_goals(box: Control, r: Rect2, i: int) -> void :
	var looks: Array = Game.theme.level_looks
	var goals: Dictionary = (looks[i] as Dictionary).get("goals", {}) if i < looks.size() else {}
	for kind: String in ["hero", "item"]:
		var g: Dictionary = goals.get(kind, {})
		if g.is_empty() or RealmGoals.is_done(kind, i):
			continue
		var dir: Vector2 = RealmGoals.DIRS.get(str(g.get("dir", "up")), Vector2.UP)
		var c: Color = Game.theme.ui.get("holy", Color(1, 0.93, 0.55)) if kind == "hero" else Game.theme.ui["accent"]
		var tip: = r.get_center() + dir * (r.size.x * 0.5 - 6.0)
		var side: = dir.orthogonal()
		var tri: = PackedVector2Array([tip, tip - dir * 14.0 + side * 10.0, tip - dir * 14.0 - side * 10.0])
		var outline: = PackedVector2Array([tip + dir * 2.0, tip - dir * 16.0 + side * 13.0, tip - dir * 16.0 - side * 13.0])
		box.draw_colored_polygon(outline, Color(0, 0, 0, 0.8))
		box.draw_colored_polygon(tri, c)


func _draw_sealed(box: Control, r: Rect2) -> void :
	var t: = Time.get_ticks_msec() / 1000.0
	box.draw_rect(r, Color(0.03, 0.01, 0.02))
	for i in 9:
		var p: = Vector2(fmod(i * 37.0 + t * (6.0 + i), r.size.x), fmod(i * 53.0 + sin(t * 0.6 + i) * 10.0, r.size.y))
		box.draw_circle(p, 18.0 + (i % 3) * 7.0, Color(0.25, 0.08, 0.08, 0.12))
	var accent: Color = Game.theme.ui["accent"]
	var pulse: = 0.55 + 0.45 * sin(t * 2.2)
	box.draw_circle(r.get_center(), 34.0, Color(accent.darkened(0.4), 0.18 * pulse))
	for k in 2:
		var a: = Vector2(0, 14) if k == 0 else Vector2(r.size.x, 14)
		var b: = Vector2(r.size.x, r.size.y - 14) if k == 0 else Vector2(0, r.size.y - 14)
		var n: = 9
		for j in n:
			var c: = a.lerp(b, (j + 0.5) / n)
			var link: = Rect2(c - Vector2(5, 3), Vector2(10, 6)) if j % 2 == 0 else Rect2(c - Vector2(3, 5), Vector2(6, 10))
			box.draw_rect(link, Color(0.28, 0.26, 0.3), false, 2.0)
	var font: = ThemeDB.fallback_font
	box.draw_string_outline(font, Vector2(0, r.get_center().y + 22), "?", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 64, 10, Color(0.1, 0, 0))
	box.draw_string(font, Vector2(0, r.get_center().y + 22), "?", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 64, Color(accent, 0.5 + 0.5 * pulse))
	box.draw_rect(r, Color(1, 1, 1, 0.15), false, 2.0)



func _reveal_survivor(s: Dictionary) -> void :
	var t: = Game.theme
	var overlay: = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(600, 0)
	center.add_child(box)
	var head: = _label("A SOUL STEPS OUT OF THE DARK", 26, Color(1, 1, 1, 0.7))
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)
	var portrait: = _icon(t.texture(s["sprite"]), 260, false)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(portrait)
	var who: = _label("%s  the %s" % [s["name"], s.get("title", "")], 40, t.ui["title"])
	who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var weapon: = _label(str(t.weapon(s.get("weapon", "")).get("name", "")), 26, t.ui["accent"])
	weapon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var perk: = _label(str(s.get("perk", "")), 22, Color(0.8, 0.8, 0.8))
	perk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tap: = _label("tap to continue", 22, Color(1, 1, 1, 0.45))
	tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for l: Label in [who, weapon, perk, tap]:
		l.modulate.a = 0.0
		box.add_child(l)
	add_child(overlay)
	_reveal = overlay
	var tw: = overlay.create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(portrait, "modulate", Color.WHITE, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_callback( func() -> void : Game.sfx("holy"))
	for l: Label in [who, weapon, perk]:
		tw.tween_property(l, "modulate:a", 1.0, 0.25)
	tw.tween_interval(0.3)
	tw.tween_property(tap, "modulate:a", 1.0, 0.3)
	overlay.gui_input.connect( func(e: InputEvent) -> void :
		if (e is InputEventMouseButton or e is InputEventScreenTouch) and e.pressed and tap.modulate.a > 0.5:
			Game.sfx("click")
			overlay.queue_free())

func _last_run_text() -> String:
	var r: = Game.last_run
	if r.is_empty():
		return ""
	var secs: = int(r["time"])
	return "Last run: %s pts  ·  %02d:%02d  ·  Lv %d  ·  %d kills  ·  +%d %s\nBest: %s pts" % [
		HUD.format_score(r.get("score", 0)), secs / 60, secs % 60, r["level"], r["kills"], r["coins"] + r.get("bonus", 0), 
		Game.theme.currency, HUD.format_score(Game.best_score())]



func _survivor_row(s: Dictionary) -> Control:
	var t: = Game.theme
	var weapon: = t.weapon(s.get("weapon", ""))
	var row: = _row_panel(Game.is_selected(s))
	row.set_meta("survivor", s)
	row.set_meta("picked", Game.is_selected(s))
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_icon(t.texture(s["sprite"]), PORTRAIT_SIZE, Game.is_unlocked(s)))

	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	if not Game.survivor_available(s):
		info.add_child(_fit_label("???", 28, NAME_WIDTH, Color(1, 1, 1, 0.8)))
		info.add_child(_label(str(s.get("secret", "???")) + "...", 20, Color(0.7, 0.8, 1.0, 0.8)))
		hbox.add_child(info)
		var locked: = _row_button()
		locked.text = "???"
		locked.disabled = true
		hbox.add_child(locked)
		return row
	if not Game.is_unlocked(s):
		info.add_child(_fit_label("???", 28, NAME_WIDTH, Color(1, 1, 1, 0.8)))
		info.add_child(_label("\"%s...\"" % str(s.get("riddle", "A lost soul waits in the dark")), 20, Color(1, 0.72, 0.6, 0.85)))

		var brings: = HBoxContainer.new()
		brings.add_child(_icon(t.texture(weapon.get("icon", "")), 32, true))
		brings.add_child(_label(weapon.get("name", ""), 22, t.ui["accent"]))
		info.add_child(brings)
		hbox.add_child(info)
		if s.has("rescue"):
			info.add_child(_label(Game.rescue_text(s), 18, Color(Game.theme.ui.get("holy", Color(1, 0.93, 0.55)), 0.9)))
			var bound: = _row_button()
			bound.text = "Rescue"
			bound.disabled = true
			hbox.add_child(bound)
			return row
		var buy: = _row_button()
		buy.text = "Buy\n%d" % s["price"]
		buy.disabled = Game.coins < s["price"]
		buy.pressed.connect( func() -> void :
			if Game.buy_survivor(s):
				Game.sfx("buy")
				_refresh()
				_reveal_survivor(s)
			else:
				Game.sfx("click"))
		hbox.add_child(buy)
		return row
	info.add_child(_fit_label("%s  the %s" % [s["name"], s.get("title", "")], 28, NAME_WIDTH, Color.WHITE))
	var weapon_line: = HBoxContainer.new()
	weapon_line.add_child(_icon(t.texture(weapon.get("icon", "")), 32, true))
	weapon_line.add_child(_label(weapon.get("name", ""), 22, t.ui["accent"]))
	info.add_child(weapon_line)
	info.add_child(_label(s.get("perk", ""), 20, Color(0.75, 0.75, 0.75)))
	if s.has("grows"):
		info.add_child(_label("Grows: " + str(s["grows"]), 18, Color(Game.theme.ui["xp"], 0.85)))
	hbox.add_child(info)

	var button: = _row_button()
	if Game.is_selected(s):
		button.text = "Picked"
		button.disabled = true
	elif Game.is_unlocked(s):
		button.text = "Pick"
		button.pressed.connect( func() -> void :
			Game.select_survivor(s)
			Game.sfx("click")
			_refresh_picked())
	else:
		button.text = "Buy\n%d" % s["price"]
		button.disabled = Game.coins < s["price"]
		button.pressed.connect( func() -> void :
			Game.sfx("buy" if Game.buy_survivor(s) else "click")
			_refresh())
	hbox.add_child(button)
	return row


func _upgrades_by_price() -> Array:
	var list: Array = Game.UPGRADES.duplicate()
	list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		var pa: = float(a["base"])
		var pb: = float(b["base"])
		return pa < pb or (pa == pb and Game.UPGRADES.find(a) < Game.UPGRADES.find(b)))
	return list



func _saved_run_popup() -> void :
	var t: = Game.theme
	var data: = RunSave.read()
	var overlay: = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel: = _row_panel(true)
	panel.custom_minimum_size = Vector2(620, 0)
	center.add_child(panel)
	panel.remove_child(panel.get_child(0))
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	for line: Array in [["UNFINISHED RUN", 40, t.ui["accent"]], [RunSave.describe(data), 28, Color.WHITE]]:
		var label: = _label(line[0], line[1], line[2])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(label)
	var go: = _action_button()
	go.text = "CONTINUE"
	go.custom_minimum_size = Vector2(0, 96)
	go.add_theme_font_size_override("font_size", 38)
	for state: String in ["normal", "hover", "pressed"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.62, 0.13, 0.05).lightened(0.2 if state == "pressed" else 0.0)
		sb.border_color = t.ui["accent"]
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(10)
		go.add_theme_stylebox_override(state, sb)
	go.pressed.connect( func() -> void :
		if RunSave.continue_run():
			Game.sfx("select")
			LoadingCover.go(get_tree(), get_tree().change_scene_to_file.bind("res://main.tscn"))
		else:
			overlay.queue_free()
			_refresh())
	box.add_child(go)
	var drop: = _action_button()
	drop.text = "Abandon run"
	drop.custom_minimum_size = Vector2(0, 72)
	var armed: = [false]
	drop.pressed.connect( func() -> void :
		Game.sfx("click")
		if not armed[0]:
			armed[0] = true
			drop.text = "Tap again: the run ends, souls are kept"
			return
		RunSave.abandon()
		overlay.queue_free()
		_refresh())
	box.add_child(drop)
	add_child(overlay)





func _maybe_shop_hint() -> void :
	if Game.shop_hint_shown or Game.last_run.is_empty():
		return
	if Game.UPGRADES.any( func(u: Dictionary) -> bool: return Game.upgrade_level(u["id"]) > 0):
		Game.shop_hint_shown = true
		Game.save_profile()
		return
	var cheapest: int = Game.UPGRADES.map( func(u: Dictionary) -> int: return Game.upgrade_cost(u)).min()
	if Game.coins < cheapest:
		return
	Game.shop_hint_shown = true
	Game.save_profile()
	var t: = Game.theme
	var tip: Dictionary = t.devil_tips.get("shop", {}).duplicate()
	if tip.is_empty():
		return
	tip["hint"] = str(tip.get("hint", "")) % [Game.coins, t.currency]
	DevilTip.show_tip(self, tip, func() -> void : _show_tab(Tab.UPGRADES))

func _upgrade_row(u: Dictionary) -> Control:
	var row: = _row_panel(false)
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_icon(Game.theme.texture(Game.theme.upgrade_icon(u["id"])), UPGRADE_ICON_SIZE, true))
	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_child(_label("%s   %d / %d" % [u["name"], Game.upgrade_level(u["id"]), u["max"]], 28, Color.WHITE))
	info.add_child(_label(u["description"], 22, Color(0.75, 0.75, 0.75)))
	hbox.add_child(info)

	var button: = _row_button()
	if Game.is_maxed(u):
		button.text = "MAX"
		button.disabled = true
	else:
		button.text = "Buy\n%d" % Game.upgrade_cost(u)
		button.disabled = Game.coins < Game.upgrade_cost(u)
		button.pressed.connect( func() -> void :
			Game.sfx("buy" if Game.buy_upgrade(u) else "click")
			_refresh())
	hbox.add_child(button)
	return row



func _refund_button() -> Button:
	var spent: = Game.upgrades_spent()
	var button: = _action_button()
	button.custom_minimum_size = Vector2(0, 80)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 24)
	button.text = "Refund all upgrades  (+%d %s)" % [spent, Game.theme.currency] if spent > 0 else "Refund all upgrades"
	button.disabled = spent <= 0
	button.pressed.connect( func() -> void :
		if not button.text.begins_with("Tap again"):
			button.text = "Tap again to refund %d %s" % [spent, Game.theme.currency]
			Game.sfx("click")
			return
		Game.refund_upgrades()
		Game.sfx("buy")
		_refresh())
	return button



func _build_quests() -> void :
	var p: = Game.progress
	_list.add_child(_label("Daily quests: new ones tomorrow. Finish them to claim %s." % Game.theme.currency, 22, Color(1, 1, 1, 0.7)))
	if Ads.can_show():
		_list.add_child(_gift_row())
	for i in p.quests.size():
		_list.add_child(_quest_row(i, p.quests[i]))
	var reroll: = _action_button()
	reroll.custom_minimum_size = Vector2(0, 80)
	reroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not p.quest_rerolled:
		reroll.text = "Reroll quests  (free today)"
		reroll.pressed.connect( func() -> void :
			p.reroll_quests()
			Game.save_profile()
			Game.sfx("reroll")
			_refresh())
	else:
		reroll.text = "Reroll quests  (watch a video)"
		reroll.disabled = not Ads.can_show() or _busy
		reroll.pressed.connect( func() -> void :
			_busy = true
			Ads.show_rewarded( func(earned: bool) -> void :
				_busy = false
				if earned:
					p.reroll_quests(true)
					Game.save_profile()
					Game.sfx("reroll")
				_refresh()))
	_list.add_child(reroll)
	if Ads.privacy_options_required():
		var privacy: = _action_button()
		privacy.text = "Ad privacy settings"
		privacy.custom_minimum_size = Vector2(0, 64)
		privacy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		privacy.add_theme_font_size_override("font_size", 22)
		privacy.pressed.connect( func() -> void : Ads.show_privacy_options())
		_list.add_child(privacy)


func _gift_row() -> Control:
	var p: = Game.progress
	var left: = Progress.AD_GIFTS_PER_DAY - p.ad_gifts
	var row: = _row_panel(left > 0)
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_icon(Game.theme.texture(Game.theme.pickups["coin"]), 56, left > 0))
	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_child(_label("Offering: +%d %s" % [Progress.AD_GIFT_SOULS, Game.theme.currency], 24, Color.WHITE))
	info.add_child(_label("Watch a video  ·  %d left today" % left, 20, Game.theme.ui["accent"]))
	hbox.add_child(info)
	var button: = _row_button()
	button.text = "Watch" if left > 0 else "Tomorrow"
	button.disabled = left <= 0 or _busy
	button.pressed.connect( func() -> void :
		_busy = true
		button.disabled = true
		Ads.show_rewarded( func(earned: bool) -> void :
			_busy = false
			if earned:
				Game.add_souls(p.take_ad_gift())
				Game.save_profile()
				Game.sfx("buy")
			_refresh()))
	hbox.add_child(button)
	return row

func _quest_row(index: int, q: Dictionary) -> Control:
	var def: = Progress.quest_def(q["id"])
	var done: = Game.progress.quest_done(q)
	var row: = _row_panel(done and not q["claimed"])
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_icon(Game.theme.texture("icon_star"), 56, done))
	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_child(_label(Progress.quest_text(def), 24, Color.WHITE))
	info.add_child(_bar(q["progress"], def["target"]))
	info.add_child(_label("%d / %d     +%d %s" % [q["progress"], def["target"], def["reward"], Game.theme.currency], 20, Game.theme.ui["accent"]))
	hbox.add_child(info)
	var button: = _row_button()
	if q["claimed"]:
		button.text = "Done"
		button.disabled = true
	elif done:
		button.text = "Claim"
		button.pressed.connect( func() -> void :
			var paid: = Game.progress.claim_quest(index)
			Game.add_souls(paid)
			Game.save_profile()
			Game.sfx("buy")
			_refresh())
		if Ads.can_show():
			var double: = _action_button()
			double.text = "x2\nvideo"

			double.custom_minimum_size = Vector2(100, 0)
			double.disabled = _busy
			double.pressed.connect( func() -> void :
				_busy = true
				double.disabled = true
				Ads.show_rewarded( func(earned: bool) -> void :
					_busy = false
					if earned:
						Game.add_souls(Game.progress.claim_quest(index) * 2)
						Game.save_profile()
						Game.sfx("buy")
					_refresh()))
			hbox.add_child(double)
	else:
		button.text = "..."
		button.disabled = true
	hbox.add_child(button)
	return row



func _build_achievements() -> void :
	var p: = Game.progress
	var all: = Progress.all_achievements()

	var ids: Array = Game.UNLOCKS.keys()
	var got: = ids.filter( func(id: String) -> bool: return p.is_item_unlocked(id)).size()
	var done: = all.filter( func(a: Dictionary) -> bool: return p.is_unlocked(a["id"])).size()
	_list.add_child(_label("Achievements  %d / %d" % [done + got, all.size() + ids.size()], 26, Game.theme.ui["accent"]))
	var hidden_fusions: = 0
	for a: Dictionary in all:
		if a.has("fusion") and not p.is_unlocked(a["id"]):
			hidden_fusions += 1
			continue
		_list.add_child(_achievement_row(a))
	if hidden_fusions > 0:
		_list.add_child(_achievement_row({"id": "", "name": "??? x%d" % hidden_fusions, "desc": "Holy recipes still to discover", 
			"hidden": false, "stat": "", "target": 1, "reward": Progress.FUSION_REWARD, "fusion_group": true}))
	for id: String in ids:
		_list.add_child(_unlock_row(id))

func _achievement_row(a: Dictionary) -> Control:
	var done: = Game.progress.is_unlocked(a["id"])
	var secret: bool = a.get("hidden", false) and not done
	var row: = _row_panel(done)
	var hbox: = row.get_child(0) as HBoxContainer
	var icon: = "icon_star"
	if a.has("fusion") and done:
		icon = str(Game.theme.weapon(a["fusion"]).get("holy_icon", icon))
	hbox.add_child(_icon(Game.theme.texture(icon), 56, done))
	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_child(_label("???" if secret else a["name"], 26, Color.WHITE if done else Color(1, 1, 1, 0.8)))
	var desc: String = "Discover a holy recipe" if secret and a.has("fusion") else ("???" if secret else a["desc"])
	info.add_child(_label(desc, 20, Color(0.75, 0.75, 0.75)))
	if not secret and not done:
		var target: int = a["target"]
		var have: = int(Game.progress.achievement_progress(a))
		if target > 1:
			info.add_child(_bar(have, target))
			info.add_child(_label("%s / %s" % [HUD.format_score(have), HUD.format_score(target)], 18, Color(1, 1, 1, 0.6)))
	hbox.add_child(info)
	if not done:
		var reward: = _label("?" if secret else ("+%d each" if a.has("fusion_group") else "+%d") % a["reward"], 24, Game.theme.ui["accent"])
		reward.size_flags_horizontal = Control.SIZE_SHRINK_END
		reward.custom_minimum_size = Vector2(70, 0)
		reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		reward.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(reward)
	return row

func _unlock_row(id: String) -> Control:
	var done: = Game.progress.is_item_unlocked(id)
	var info: = Game.item_info(id)
	var row: = _row_panel(done)
	var hbox: = row.get_child(0) as HBoxContainer
	hbox.add_child(_icon(Game.theme.texture(str(info.get("icon", ""))), 56, done))
	var col: = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(_label(str(info.get("name", id)) if done else "???", 26, Color.WHITE if done else Color(1, 1, 1, 0.8)))
	col.add_child(_label(Game.unlock_text(id), 20, Color(0.75, 0.75, 0.75)))
	if not done:
		var target: int = Game.UNLOCKS[id]["target"]
		if target > 1:
			var have: = int(Game.progress.item_progress(id))
			col.add_child(_bar(have, target))
	hbox.add_child(col)
	var reward: = _label("""New
weapon""" if Game.WEAPONS.has(id) else "New\nitem"\
	, 20, Game.theme.ui["accent"])
	reward.size_flags_horizontal = Control.SIZE_SHRINK_END
	reward.custom_minimum_size = Vector2(80, 0)
	reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reward.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if not done:
		hbox.add_child(reward)
	return row

func _bar(value: float, max_value: float) -> ProgressBar:
	var bar: = ProgressBar.new()
	bar.max_value = max_value
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 16)
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	var fill: = StyleBoxFlat.new()
	fill.bg_color = Game.theme.ui["xp"]
	fill.set_corner_radius_all(4)
	var back: = StyleBoxFlat.new()
	back.bg_color = Color(0, 0, 0, 0.5)
	back.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	return bar



func _row_panel(highlight: bool) -> PanelContainer:
	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, ROW_HEIGHT)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	var style: = StyleBoxFlat.new()
	style.bg_color = Game.theme.ui["panel"]
	style.border_color = Game.theme.ui["accent"] if highlight else Color(1, 1, 1, 0.12)
	style.set_border_width_all(4 if highlight else 2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	var hbox: = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)
	return panel

func _icon(tex: Texture2D, icon_size: int, unlocked: bool) -> TextureRect:
	var icon: = TextureRect.new()
	icon.texture = tex
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not unlocked:
		icon.modulate = Color(0, 0, 0, 0.9)
	return icon

func _label(text: String, font_size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label



func _fit_label(text: String, font_size: int, width: float, color: Color) -> Label:
	var label: = _label(text, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var font: = label.get_theme_font("font")
	var fs: = font_size
	while fs > 18 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > width:
		fs -= 1
	label.add_theme_font_size_override("font_size", fs)
	return label


func _row_button() -> Button:
	var button: = _action_button()
	button.custom_minimum_size = ROW_BUTTON
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return button

func _action_button() -> Button:
	var button: = Button.new()
	button.custom_minimum_size = Vector2(130, 0)
	button.add_theme_font_size_override("font_size", 26)
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	return button
