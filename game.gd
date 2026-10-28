extends Node







const THEME_SCRIPT: = "res://themes/hell_theme.gd"

const SAVE_PATH: = "user://save.cfg"



const MAX_WEAPONS: = 6
const MAX_PASSIVES: = 6



const TROPHY_SLOTS: = 1


const WEAPONS: = {
	"magic_bolt": preload("res://magic_bolt.gd"), 
	"throwing_knife": preload("res://throwing_knife.gd"), 
	"aura": preload("res://aura.gd"), 
	"spirit_orbs": preload("res://spirit_orbs.gd"), 
	"lightning": preload("res://lightning.gd"), 
	"boomerang": preload("res://boomerang.gd"), 
	"battle_axe": preload("res://battle_axe.gd"), 
	"holy_water": preload("res://holy_water.gd"), 
	"whip": preload("res://whip.gd"), 
	"familiar": preload("res://familiar.gd"), 
	"sigil": preload("res://sigil.gd"), 
	"shockwave": preload("res://shockwave.gd"), 
	"bulwark": preload("res://bulwark.gd"), 

	"winds": preload("res://winds.gd"), 
	"scythe": preload("res://scythe.gd"), 
	"maw": preload("res://maw.gd"), 
	"spear": preload("res://spear.gd"), 
	"tear": preload("res://tear.gd"), 

	"requiem": preload("res://requiem.gd"), 
	"ravens": preload("res://ravens.gd"), 
	"nails": preload("res://nails.gd"), 
	"sodom": preload("res://sodom.gd"), 
}











const EVOLUTIONS: = {
	"whip": "max_hp", 
	"magic_bolt": "cooldown", 
	"battle_axe": "area", 
	"holy_water": "magnet", 
	"aura": "regen", 
	"lightning": "amount", 
	"shockwave": "growth", 
	"sigil": "speed", 
	"familiar": "relic", 
	"sodom": "might", 
	"bulwark": "duration", 
	"throwing_knife": "crit", 
	"boomerang": "luck", 
	"spirit_orbs": "relic", 
	"winds": "thorns", 
	"scythe": "lifesteal", 
	"maw": "blast", 
	"spear": "bounty", 
	"tear": "armor", 
	"requiem": "curse", 
	"ravens": "speed", 
	"nails": "censer", 
}






const PACTS: = {
	"frenzy": {"val": 0.35, "unit": "pct"}, 
	"haste": {"val": 0.3, "unit": "pct"}, 
	"vital": {"val": 40, "unit": "int"}, 
	"greed": {"val": 0.75, "unit": "pct"}, 
	"titan": {"val": 1, "unit": "int"}, 
	"leech": {"val": 90, "unit": "int"}, 
	"second_chance": {"val": 1, "unit": "int"}, 
}
const PRICES: = {
	"frail": {"val": 20, "unit": "int", "not": ["vital"]}, 
	"sluggish": {"val": 0.15, "unit": "pct", "not": ["haste"]}, 
	"feeble": {"val": 0.2, "unit": "pct", "not": ["frenzy"]}, 
	"rusted": {"val": 0.15, "unit": "pct", "not": ["haste"]}, 
	"dim": {"val": 0.4, "unit": "pct", "not": []}, 
	"dull": {"val": 0.25, "unit": "pct", "not": ["greed"]}, 
	"debt": {"val": 0.4, "unit": "pct", "not": ["greed"]}, 
	"hunted": {"val": 0.25, "unit": "pct", "not": []}, 
	"barren": {"val": 0.5, "unit": "pct", "not": ["leech"]}, 
}






const PASSIVES: = {
	"might": {"per_level": 0.1, "max": 5, "fmt": "%s damage", "unit": "pct"}, 
	"cooldown": {"per_level": 0.08, "max": 5, "fmt": "Weapons attack %s faster", "unit": "pct", "plain": true}, 
	"area": {"per_level": 0.1, "max": 5, "fmt": "%s weapon area", "unit": "pct"}, 
	"amount": {"per_level": 1, "max": 2, "texts": ["+1 projectile for weapons that fire them", "+2 projectiles for weapons that fire them"]}, 
	"speed": {"per_level": 0.1, "max": 5, "fmt": "%s move speed", "unit": "pct"}, 
	"magnet": {"per_level": 0.25, "max": 5, "fmt": "%s pickup range", "unit": "pct"}, 
	"regen": {"per_level": 0.15, "max": 5, "fmt": "Regenerate %s HP a minute", "unit": "permin", 
		"about": "Grows as the run goes on, like the demons' damage"}, 
	"max_hp": {"per_level": 25, "max": 3, "texts": ["+25 max HP", "+50 max HP", "+75 max HP"]}, 
	"armor": {"per_level": 1, "max": 5, "fmt": "Every hit takes %s less HP", "unit": "", 
		"about": "Armor, as in the classic: each hit you take loses this much, down to 1 HP. Every point of armor (shop and survivor too) also adds 10% retaliation damage: thorns, and anything that strikes back when you are hit"}, 
	"growth": {"per_level": 0.08, "max": 5, "fmt": "%s XP", "unit": "pct"}, 
	"crit": {"per_level": 0.05, "max": 5, "fmt": "%s critical chance", "unit": "pct", "about": "Critical hits do double damage"}, 
	"lifesteal": {"per_level": 1, "max": 3, "fmt": "Heal 20 HP every %s kills", "unit": "kills", "kills": [0, 150, 100, 70], 
		"about": "It takes more kills later in the run, and heals come at most every few seconds"}, 
	"bounty": {"per_level": 0.5, "max": 3, "fmt": "%s XP from elites", "unit": "pct", "about": "Elites sometimes drop an extra soul too"}, 
	"blast": {"per_level": 0.08, "max": 3, "fmt": "%s chance for a kill to explode", "unit": "pct", "plain": true}, 
	"curse": {"per_level": 1, "max": 3, "texts": ["Risky: more and tougher monsters, but more souls", "Even more monsters, even more souls", "A horde beyond reason, souls beyond counting"]}, 


	"thorns": {"per_level": 7, "max": 5, "fmt": "%s thorn damage a second", "unit": "", 
		"about": "Hurts every demon touching you, and grows as the horde toughens"}, 
	"relic": {"per_level": 1, "max": 3, "fmt": "Saves you below 25%% HP, every %s s", "unit": "secs", "secs": [0, 150, 110, 75], 
		"about": "Heals 40% of your max HP, blasts nearby demons away and protects you for a moment"}, 
	"censer": {"per_level": 0.09, "max": 4, "fmt": "Demons near you move %s slower", "unit": "pct", "plain": true}, 
	"duration": {"per_level": 0.1, "max": 5, "fmt": "%s effect duration", "unit": "pct", 
		"about": "Pools, doom, the jaws' hold and bouncing tears all last longer"}, 


	"luck": {"per_level": 0.1, "max": 5, "fmt": "%s luck", "unit": "pct", 
		"about": "Luck gives a 4th level-up card sometimes, better chests and more rare drops"}, 
}




const POOLS: = ["damage", "defense", "utility"]
const ITEM_POOL: = {
	"bulwark": "defense", 
	"might": "damage", "cooldown": "damage", "area": "damage", "amount": "damage", "crit": "damage", "blast": "damage", 
	"armor": "defense", "max_hp": "defense", "regen": "defense", "lifesteal": "defense", 
	"thorns": "defense", "relic": "defense", "censer": "defense", 
	"speed": "utility", "magnet": "utility", "growth": "utility", "bounty": "utility", "luck": "utility", "duration": "utility", 
}


func pool_of(id: String) -> String:
	if ITEM_POOL.has(id):
		return ITEM_POOL[id]
	return "damage" if WEAPONS.has(id) else ""



func passive_text(id: String, level: int, single: = false) -> String:
	var p: Dictionary = PASSIVES[id]
	if p.has("texts"):
		return p["texts"][clampi(level - 1, 0, p["texts"].size() - 1)]
	var shown: = _passive_value(p, level)
	if level > 1 and not single:
		shown = "%s → %s" % [_passive_value(p, level - 1), shown]
	return p["fmt"] %shown



func passive_about(id: String) -> String:
	return str(PASSIVES[id].get("about", ""))

func _passive_value(p: Dictionary, level: int) -> String:
	var v: float = p["per_level"] * level
	match p.get("unit", ""):
		"pct": return ("" if p.get("plain", false) else "+") + "%d%%" % int(round(v * 100.0))
		"permin": return str(int(round(v * 60.0)))
		"kills": return str(p["kills"][mini(level, p["kills"].size() - 1)])
		"secs": return str(p["secs"][mini(level, p["secs"].size() - 1)])
		"cap": return str(int(round(p["base"] - v)))
	return str(int(v)) if is_equal_approx(v, roundf(v)) else str(v)





const UNLOCKS: = {

	"nails": {"stat": "kills", "target": 1000, "text": "Defeat 1,000 monsters"}, 

	"sodom": {"stat": "found_sodom", "target": 1, "text": "Find it at the bottom of {r:1}"}, 
	"boomerang": {"stat": "purges", "target": 1, "text": "Pick up a {pickup:purge}"}, 
	"aura": {"stat": "hearts", "target": 10, "text": "Pick up 10 {pickup:heart}s"}, 
	"sigil": {"stat": "props", "target": 40, "text": "Smash 40 props"}, 
	"lightning": {"stat": "kills", "target": 5000, "text": "Defeat 5,000 monsters"}, 
	"shockwave": {"stat": "time", "target": 720, "text": "Survive 12 minutes in one run"}, 
	"familiar": {"stat": "wins", "target": 1, "text": "Survive the whole clock"}, 
	"bulwark": {"stat": "plvl_armor", "target": 5, "text": "Max out {p:armor}"}, 
	"winds": {"stat": "level", "target": 15, "text": "Reach level 15"}, 
	"scythe": {"stat": "bosses", "target": 3, "text": "Defeat 3 bosses"}, 
	"maw": {"stat": "holys", "target": 1, "text": "Turn a weapon holy"}, 
	"spear": {"stat": "time_paladin", "target": 450, "text": "Survive 7:30 as {s:paladin}"}, 
	"tear": {"stat": "time_realm_4", "target": 300, "text": "Survive 5 minutes in {r:4}"}, 
	"duration": {"stat": "found_duration", "target": 1, "text": "Find it far across {r:4}"}, 

	"max_hp": {"stat": "time", "target": 60, "text": "Survive 1 minute"}, 
	"speed": {"stat": "level", "target": 5, "text": "Reach level 5"}, 
	"growth": {"stat": "level", "target": 10, "text": "Reach level 10"}, 
	"magnet": {"stat": "vacuums", "target": 1, "text": "Pick up an {pickup:vacuum}"}, 
	"area": {"stat": "wlvl_holy_water", "target": 4, "text": "Get {w:holy_water} to level 4"}, 
	"crit": {"stat": "wlvl_throwing_knife", "target": 4, "text": "Get {w:throwing_knife} to level 4"}, 
	"cooldown": {"stat": "weapons_held", "target": 4, "text": "Hold 4 weapons at once"}, 
	"bounty": {"stat": "found_bounty", "target": 1, "text": "Find it far along the shore of {r:2}"}, 
	"curse": {"stat": "bosses", "target": 1, "text": "Defeat a boss"}, 
	"lifesteal": {"stat": "wlvl_aura", "target": 4, "text": "Get {w:aura} to level 4"}, 
	"blast": {"stat": "wlvl_sigil", "target": 4, "text": "Get {w:sigil} to level 4"}, 
	"amount": {"stat": "found_amount", "target": 1, "text": "Find it far out in {r:3}"}, 
	"regen": {"stat": "time_nun", "target": 450, "text": "Survive 7:30 as {s:nun}"}, 

	"thorns": {"stat": "deaths", "target": 3, "text": "Die 3 times"}, 
	"relic": {"stat": "found_relic", "target": 1, "text": "Find it far below {r:0}"}, 
}

func is_item_unlocked(id: String) -> bool:
	return dev_mode or progress.is_item_unlocked(id)



func is_item_in_run(id: String) -> bool:
	if is_test_run():
		return test_pool.has(id)
	return dev_mode or not UNLOCKS.has(id) or _run_items.has(id)

func is_test_run() -> bool:
	return not test_pool.is_empty()


func start_test_run(survivor_id: String, realm: int, items: Array) -> void :
	test_pool = items.duplicate()
	test_survivor = survivor_id
	var w: = str(theme.survivor(survivor_id).get("weapon", ""))
	if w != "" and not test_pool.has(w):
		test_pool.append(w)
	if _tier_before_test < 0:
		_tier_before_test = tier
	tier = clampi(realm, 0, theme.difficulties.size() - 1)
	theme.apply_level(tier)


func end_test_run() -> void :
	if not is_test_run() and _tier_before_test < 0:
		return
	test_pool = []
	test_survivor = ""
	if _tier_before_test >= 0:
		tier = _tier_before_test
		_tier_before_test = -1
		theme.apply_level(tier)


func unlock_text(id: String) -> String:
	var text: String = UNLOCKS.get(id, {}).get("text", "")
	var rx: = RegEx.create_from_string("[{](\\w+):(\\w+)[}]")
	for m in rx.search_all(text):
		var key: = m.get_string(2)
		var name: = key
		match m.get_string(1):
			"w": name = theme.weapon(key).get("name", key)
			"p": name = theme.passive(key).get("name", key)
			"s": name = theme.survivor(key).get("name", key)
			"pickup": name = str(theme.pickups.get(key, key)).replace("_", " ")
			"r":
				var i: = int(key)
				name = str(theme.difficulties[i].get("name", key)) if i < theme.difficulties.size() else key
		text = text.replace(m.get_string(), name)
	return text


func item_info(id: String) -> Dictionary:
	return theme.weapon(id) if WEAPONS.has(id) else theme.passive(id)























const MARKUP: = 20.0
const MARKUP_GROWTH: = 1.0936
const UPGRADES: = [
	{"id": "might", "name": "Might", "description": "+4% damage", "per": 0.04, "max": 10, "base": 100}, 
	{"id": "max_hp", "name": "Vitality", "description": "+20 max HP", "per": 20, "max": 3, "base": 480}, 
	{"id": "armor", "name": "Toughness", "description": "+1 armor: every hit takes 1 less HP", "per": 1, "max": 3, "base": 300}, 
	{"id": "cooldown", "name": "Haste", "description": "Weapons attack 2.5% faster", "per": 0.025, "max": 8, "base": 160}, 
	{"id": "area", "name": "Reach", "description": "+4% weapon area", "per": 0.04, "max": 6, "base": 120}, 
	{"id": "speed", "name": "Swiftness", "description": "+3% move speed", "per": 0.03, "max": 6, "base": 80}, 
	{"id": "magnet", "name": "Magnet", "description": "+12% pickup range", "per": 0.12, "max": 5, "base": 60}, 
	{"id": "crit", "name": "Precision", "description": "+2% critical chance", "per": 0.02, "max": 5, "base": 240}, 
	{"id": "growth", "name": "Wisdom", "description": "+4% XP", "per": 0.04, "max": 6, "base": 120}, 
	{"id": "greed", "name": "Avarice", "description": "+8% souls", "per": 0.08, "max": 8, "base": 470}, 
	{"id": "regen", "name": "Recovery", "description": "Regenerate +2.4 HP a minute", "per": 0.04, "max": 5, "base": 240}, 
	{"id": "reroll", "name": "Reroll", "description": "+1 level-up reroll per run", "per": 1, "max": 3, "base": 940}, 
	{"id": "skip", "name": "Skip", "description": "+1 level-up skip per run", "per": 1, "max": 3, "base": 280}, 
	{"id": "luck", "name": "Fortune", "description": "+5% luck", "per": 0.05, "max": 3, "base": 480}, 
	{"id": "exile", "name": "Exile", "description": "+1 exile per run: remove a card from the level-up choices for good", "per": 1, "max": 3, "base": 1500}, 
	{"id": "revive", "name": "Last Rites", "description": "+1 free revive per run, no ad needed", "per": 1, "max": 2, "base": 5600}, 
	{"id": "amount", "name": "Multitude", "description": "+1 projectile for weapons that fire them", "per": 1, "max": 1, "base": 22500}, 
]


const SCORE: = {
	"minute": 600, 
	"kill": 10, 
	"boss": 2000, 
	"statue": 5, 
	"prop": 25, 
	"xp": 5, 
	"coin": 50, 
	"heart": 20, 
	"blessing": 500, 
	"rare": 150, 
	"level": 100, 
	"victory": 5000, 
}
const WIN_SOULS: = 90
const MAX_HIGH_SCORES: = 10

var theme: GameTheme
var coins: = 0
var last_run: = {}
var shop_hint_shown: = false
var high_scores: Array = []
var dev_mode: = false

var progress: = Progress.new()
var tier: = 0
var run_tier: = 0
var _run_items: Array = []
var resume: = {}

var _toast: Toast
var _unlocked: Array = []
var _selected: = ""
var _upgrades: = {}



var _paid: = {}







const ADMIN_CODE: = "PORCICA1"
var admin: = false
var no_ads: = false
var test_pool: Array = []
var test_survivor: = ""
var _tier_before_test: = -1


var trophy_details: = false


var damage_numbers: = 2
var goal_arrows: = true
var music_volume: = 1.0
var sfx_volume: = 1.0



const SFX_VOICES: = 12
const SFX_GAP: = {"reap": 0.25, "xp": 0.04, "coin": 0.05, "hit": 0.06, "kill": 0.05, "hurt": 0.35, "break": 0.06}
const SFX_DEFAULT_GAP: = 0.03


const SFX_PRIORITY: = {"crunch": 5.0}
var _sfx_priority: AudioStreamPlayer

var _music: AudioStreamPlayer
var _muffle: AudioEffectLowPassFilter
var _mood_tween: Tween
const MUSIC_DB: = -8.0
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_next: = 0
var _sfx_streams: = {}
var _sfx_last: = {}
var _offscreen: = 795.0

func _ready() -> void :
	theme = load(THEME_SCRIPT).new()
	get_viewport().size_changed.connect(_update_view)
	_update_view()
	_toast = Toast.new()
	add_child(_toast)
	progress.quest_completed.connect(_on_quest_completed)
	progress.achievement_unlocked.connect(_on_achievement_unlocked)
	progress.item_unlocked.connect(_on_item_unlocked)
	for bus in ["Music", "SFX"]:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	_apply_ui_theme()
	load_profile()
	progress.ensure_today()
	tier = clampi(tier, 0, theme.difficulties.size() - 1)
	if not progress.is_tier_unlocked(tier):
		tier = 0
	theme.apply_level(tier)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	_muffle = AudioEffectLowPassFilter.new()
	_muffle.cutoff_hz = 20000.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), _muffle)
	_start_music()
	for i in SFX_VOICES:
		var p: = AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	_sfx_priority = AudioStreamPlayer.new()
	_sfx_priority.process_mode = Node.PROCESS_MODE_ALWAYS
	_sfx_priority.bus = "SFX"
	add_child(_sfx_priority)


func _apply_ui_theme() -> void :
	var ui: Dictionary = theme.ui
	var accent: Color = ui["accent"]
	var th: = Theme.new()
	var styles: = {
		"normal": [ui["panel"], accent.darkened(0.45), 2], 
		"hover": [ui["panel"].lightened(0.1), accent.darkened(0.1), 2], 
		"pressed": [ui["panel"].lightened(0.22), accent, 3], 
		"disabled": [ui["panel"].darkened(0.35), Color(accent, 0.2), 2], 
		"focus": [Color(0, 0, 0, 0), Color(accent, 0.0), 0], 
	}
	for state: String in styles:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = styles[state][0]
		sb.border_color = styles[state][1]
		sb.set_border_width_all(styles[state][2])
		sb.set_corner_radius_all(8)
		sb.set_content_margin_all(10)
		sb.shadow_color = Color(0, 0, 0, 0.45)
		sb.shadow_size = 4 if state != "disabled" else 0
		sb.shadow_offset = Vector2(0, 3)
		th.set_stylebox(state, "Button", sb)
	th.set_color("font_color", "Button", Color(1, 0.95, 0.9))
	th.set_color("font_hover_color", "Button", Color.WHITE)
	th.set_color("font_pressed_color", "Button", accent.lightened(0.4))
	th.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.35))
	th.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.8))
	th.set_constant("outline_size", "Button", 4)
	get_tree().root.theme = th




func preload_sounds() -> void :
	for sound: String in theme.sounds:
		if not _sfx_streams.has(sound):
			var path: String = theme.sounds[sound]
			_sfx_streams[sound] = load(path) if path != "" and ResourceLoader.exists(path) else null

func sfx(sound: String, pitch: = 1.0, volume_db: = 0.0) -> void :
	var now: = Time.get_ticks_msec()
	if now - _sfx_last.get(sound, -100000) < SFX_GAP.get(sound, SFX_DEFAULT_GAP) * 1000.0:
		return
	if not _sfx_streams.has(sound):
		var path: String = theme.sounds.get(sound, "")
		_sfx_streams[sound] = load(path) if path != "" and ResourceLoader.exists(path) else null
	var stream: AudioStream = _sfx_streams[sound]
	if stream == null:
		return
	_sfx_last[sound] = now
	if SFX_PRIORITY.has(sound):
		_sfx_priority.stream = stream
		_sfx_priority.pitch_scale = pitch
		_sfx_priority.volume_db = volume_db + SFX_PRIORITY[sound]
		_sfx_priority.play()
		return
	var p: = _sfx_players[_sfx_next]
	for i in _sfx_players.size():
		var candidate: = _sfx_players[(_sfx_next + i) % _sfx_players.size()]
		if not candidate.playing:
			p = candidate
			break
	_sfx_next = (_sfx_players.find(p) + 1) % _sfx_players.size()
	p.stream = stream
	p.pitch_scale = pitch * randf_range(0.95, 1.05)
	p.volume_db = volume_db
	p.play()

func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_profile()
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		progress.ensure_today()
		_safe_top = -1.0





func view_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func design_offset() -> float:
	return maxf(0.0, (view_size().y - 1280.0) / 2.0)


func offscreen_distance() -> float:
	return _offscreen

func _update_view() -> void :
	_offscreen = view_size().length() / 2.0 + 60.0
	_safe_top = -1.0




func safe_top() -> float:
	if _safe_top < 0.0:
		_safe_top = _measure_safe_top()
	return _safe_top

var _safe_top: = -1.0

func _measure_safe_top() -> float:
	if not OS.has_feature("mobile"):
		return 0.0
	var screen: = DisplayServer.screen_get_size()
	var safe: = DisplayServer.get_display_safe_area()
	if screen.y <= 0 or safe.size.y <= 0:
		return 0.0
	var window: = DisplayServer.window_get_size()
	if window.y <= 0:
		return 0.0
	return clampf(safe.position.y * view_size().y / float(window.y), 0.0, 160.0)


func _start_music() -> void :
	if theme.music == "" or not ResourceLoader.exists(theme.music):
		return
	var stream: = load(theme.music) as AudioStreamWAV
	if stream == null:
		return
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_music = AudioStreamPlayer.new()
	_music.stream = stream
	_music.volume_db = MUSIC_DB
	_music.process_mode = Node.PROCESS_MODE_ALWAYS
	_music.bus = "Music"
	add_child(_music)
	_music.play()




func music_mood(pitch: = 1.0, muffle_hz: = 20000.0, duck_db: = 0.0, secs: = 1.5) -> void :
	if _music == null:
		return
	if _mood_tween:
		_mood_tween.kill()
	_mood_tween = create_tween().set_parallel().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_mood_tween.tween_property(_music, "pitch_scale", pitch, secs)
	_mood_tween.tween_property(_music, "volume_db", MUSIC_DB + duck_db, secs)
	_mood_tween.tween_property(_muffle, "cutoff_hz", muffle_hz, secs).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func loop_stream(sound: String) -> AudioStreamWAV:
	var path: String = theme.sounds.get(sound, "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	var stream: = load(path) as AudioStreamWAV
	if stream:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	return stream



func set_music_volume(v: float) -> void :
	music_volume = clampf(v, 0.0, 1.0)
	_set_bus_volume("Music", music_volume)

func set_sfx_volume(v: float) -> void :
	sfx_volume = clampf(v, 0.0, 1.0)
	_set_bus_volume("SFX", sfx_volume)

func _set_bus_volume(bus_name: String, v: float) -> void :
	var bus: = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus, linear_to_db(v))
	AudioServer.set_bus_mute(bus, v <= 0.0)





func survivor() -> Dictionary:
	if test_survivor != "" and not theme.survivor(test_survivor).is_empty():
		return theme.survivor(test_survivor)
	var s: = theme.survivor(_selected)
	if dev_mode or (is_unlocked(s) and survivor_available(s)):
		return s
	return theme.survivors[0]

func is_selected(s: Dictionary) -> bool:
	return survivor()["id"] == s["id"]



func is_unlocked(s: Dictionary) -> bool:
	if s.has("rescue"):
		return dev_mode or _unlocked.has(s["id"])
	if s.has("requires_win"):
		return survivor_available(s)
	return s.get("price", 0) <= 0 or _unlocked.has(s["id"])

func select_survivor(s: Dictionary) -> void :
	if is_unlocked(s):
		_selected = s["id"]
		save_profile()


func dev_unlock_all_heroes() -> void :
	for s: Dictionary in theme.survivors:
		if not _unlocked.has(s["id"]):
			_unlocked.append(s["id"])
	save_profile()

func dev_unlock_all_items() -> void :
	for id: String in UNLOCKS:
		if not progress.items.has(id):
			progress.items.append(id)
	save_profile()

func dev_unlock_all_levels() -> void :
	for i in theme.difficulties.size():
		if not progress.tiers_won.has(i):
			progress.tiers_won.append(i)
	save_profile()

func dev_add_souls() -> void :
	coins += 1000
	save_profile()



func dev_reset_save() -> void :
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RunSave.PATH))
	coins = 0
	_unlocked = []
	_selected = ""
	_upgrades = {}
	_paid = {}
	tier = 0
	shop_hint_shown = false
	high_scores = []
	progress = Progress.new()
	progress.quest_completed.connect(_on_quest_completed)
	progress.achievement_unlocked.connect(_on_achievement_unlocked)
	progress.item_unlocked.connect(_on_item_unlocked)
	progress.ensure_today()
	theme.apply_level(0)
	save_profile()


func survivor_available(s: Dictionary) -> bool:
	return dev_mode or not s.has("requires_win") or progress.tiers_won.has(int(s["requires_win"]))


func rescue_text(s: Dictionary) -> String:
	var tier_i: = int(s.get("rescue", 0))
	var looks: Dictionary = theme.level_looks[tier_i] if tier_i < theme.level_looks.size() else {}
	var dir: = str(looks.get("goals", {}).get("hero", {}).get("dir", "out"))
	return "Bound at a stake, far %s in %s" % [dir, tier_info(tier_i)["name"]]


func rescue_survivor(id: String) -> bool:
	if _unlocked.has(id):
		return false
	_unlocked.append(id)
	save_profile()
	return true

func buy_survivor(s: Dictionary) -> bool:
	var price: int = s.get("price", 0)
	if s.has("rescue") or is_unlocked(s) or coins < price or not survivor_available(s):
		return false
	coins -= price
	_unlocked.append(s["id"])
	select_survivor(s)
	return true



func upgrade_level(id: String) -> int:
	var level: int = _upgrades.get(id, 0)
	for u: Dictionary in UPGRADES:
		if u["id"] == id:
			return mini(level, u["max"])
	return level

func upgrade_cost(u: Dictionary) -> int:
	return _cost_at(u, upgrade_level(u["id"]))



func _cost_at(u: Dictionary, lvl: int, owned: = -1) -> int:
	var n: = shop_levels() if owned < 0 else owned

	return int(float(u["base"]) * (1 + lvl) + floorf(MARKUP * pow(MARKUP_GROWTH, n)))


func shop_levels() -> int:
	var n: = 0
	for u: Dictionary in UPGRADES:
		n += upgrade_level(u["id"])
	return n


func shop_total() -> int:
	var total: = 0
	var n: = 0
	for u: Dictionary in UPGRADES:
		for lvl in int(u["max"]):
			total += _cost_at(u, lvl, n)
			n += 1
	return total


func upgrade_bonus(id: String) -> float:
	for u: Dictionary in UPGRADES:
		if u["id"] == id:
			return u.get("per", 0.0) * upgrade_level(id)
	return 0.0

func is_maxed(u: Dictionary) -> bool:
	return upgrade_level(u["id"]) >= u["max"]


func upgrades_spent() -> int:
	var total: = 0
	for u: Dictionary in UPGRADES:
		var paid: Array = _paid.get(u["id"], [])
		for lvl in upgrade_level(u["id"]):
			total += int(paid[lvl]) if lvl < paid.size() else _cost_at(u, lvl)
	return total





func _trim_upgrades() -> void :
	for u: Dictionary in UPGRADES:
		var id: String = u["id"]
		var have: = int(_upgrades.get(id, 0))
		if have <= int(u["max"]):
			continue
		var paid: Array = _paid.get(id, [])
		var back: = 0
		for i in range(int(u["max"]), paid.size()):
			back += int(paid[i])
		coins += back
		_upgrades[id] = int(u["max"])
		_paid[id] = paid.slice(0, int(u["max"]))
		save_profile.call_deferred()

func refund_upgrades() -> int:
	var total: = upgrades_spent()
	coins += total
	_upgrades = {}
	_paid = {}
	save_profile()
	return total

func buy_upgrade(u: Dictionary) -> bool:
	if is_maxed(u) or coins < upgrade_cost(u):
		return false
	var cost: = upgrade_cost(u)
	var lvl: = upgrade_level(u["id"])
	coins -= cost
	var paid: Array = _paid.get(u["id"], [])
	if paid.size() == lvl:
		paid.append(cost)
		_paid[u["id"]] = paid
	_upgrades[u["id"]] = lvl + 1
	save_profile()
	return true



func tier_info(index: = -1) -> Dictionary:
	var list: Array = theme.difficulties
	return list[clampi(tier if index < 0 else index, 0, list.size() - 1)]

func select_tier(index: int) -> void :
	if index >= 0 and index < theme.difficulties.size() and progress.is_tier_unlocked(index):
		tier = index
		theme.apply_level(tier)
		save_profile()



func track(stat: String, n: = 1) -> void :
	if not dev_mode:
		progress.track(stat, n)



func track_souls(n: int, who: = "") -> void :
	if dev_mode:
		return
	progress.track("souls", n)
	progress.track("souls_" + (who if who != "" else str(survivor().get("id", ""))), n)

func track_max(stat: String, value: float) -> void :
	if not dev_mode:
		progress.track_max(stat, value)

func begin_run() -> void :
	run_tier = 0 if dev_mode else tier
	Pickup.reset_little_hearts()
	Ghost.alive.clear()
	_run_items = progress.items.duplicate()
	preload_sounds()
	progress.ensure_today()
	progress.begin_run()


func run_items() -> Array:
	return _run_items.duplicate()

func restore_run_items(items: Array) -> void :
	_run_items = items.duplicate()

func add_souls(amount: int) -> void :
	coins += amount

func toast(title: String, subtitle: = "", color: = Color(1, 0.85, 0.3), icon: = "") -> void :
	if _toast:
		_toast.push(title, subtitle, color, icon)



func announce(title: String, task: String, reward: String, color: Color, icon: = "") -> void :
	if _toast:
		_toast.push(title, task, color, icon, reward, "achievement")

func _on_quest_completed(q: Dictionary) -> void :
	var def: = Progress.quest_def(q["id"])
	var task: = Progress.quest_text(def)
	announce("DAILY QUEST COMPLETE", task, "Reward: +%d %s" % [def["reward"], theme.currency], theme.ui.get("xp", Color.GREEN))
	progress.add_news("quest", "Quest complete", "%s  +%d %s" % [task, def["reward"], theme.currency], "icon_star")

func _on_item_unlocked(id: String) -> void :
	var info: = item_info(id)
	var kind: = "weapon" if WEAPONS.has(id) else "item"
	announce("ACHIEVEMENT UNLOCKED", unlock_text(id), "Reward: new %s, %s  (from your next run)" % [kind, info.get("name", id)], 
		theme.ui.get("holy", Color(1, 0.93, 0.55)), str(info.get("icon", "")))
	progress.add_news("unlock", "New %s: %s" % [kind, info.get("name", id)], unlock_text(id), info.get("icon", ""))
	save_profile.call_deferred()

func _on_achievement_unlocked(a: Dictionary) -> void :
	coins += a.get("reward", 0)
	save_profile.call_deferred()
	var icon: String = str(theme.weapon(a["fusion"]).get("holy_icon", "")) if a.has("fusion") else ""
	var title: = ("HOLY RECIPE: " if a.has("fusion") else "ACHIEVEMENT: ") + str(a["name"]).to_upper()
	announce(title, a["desc"], "Reward: +%d %s" % [a.get("reward", 0), theme.currency], theme.ui["accent"], icon)
	if a.has("fusion"):
		progress.add_news("fusion", "Holy recipe found: " + a["name"], a["desc"], theme.weapon(a["fusion"]).get("holy_icon", ""))
	else:
		progress.add_news("achievement", "Achievement: " + a["name"], "%s  +%d %s" % [a["desc"], a.get("reward", 0), theme.currency], "icon_star")


func pact_value(id: String) -> float:
	if PACTS.has(id):
		return PACTS[id]["val"]
	return PRICES[id]["val"] if PRICES.has(id) else 0.0


func pact_text(id: String) -> String:
	var unit: String = (PACTS[id] if PACTS.has(id) else PRICES[id])["unit"]
	var v: = pact_value(id)
	var shown: = int(round(v * 100.0)) if unit == "pct" else int(v)
	var text: String = (theme.pact(id) if PACTS.has(id) else theme.pact_price(id))["text"] %shown
	return text.replace("(s)", "" if shown == 1 else "s")


func roll_pact_price(boon: String) -> String:
	return PRICES.keys().filter( func(id: String) -> bool: return not boon in PRICES[id]["not"]).pick_random()




func end_run(summary: Dictionary) -> int:
	last_run = summary
	var rank: = -1
	if not dev_mode and summary.get("score", 0) > 0:
		var entry: = summary.duplicate()
		entry["date"] = Time.get_date_string_from_system()
		rank = high_scores.size()
		for i in high_scores.size():
			if entry["score"] > high_scores[i]["score"]:
				rank = i
				break
		high_scores.insert(rank, entry)
		high_scores.resize(mini(high_scores.size(), MAX_HIGH_SCORES))
		if rank >= MAX_HIGH_SCORES:
			rank = -1
	save_profile()
	return rank

func best_score() -> int:
	return high_scores[0]["score"] if not high_scores.is_empty() else 0



func save_profile() -> void :
	var cfg: = ConfigFile.new()
	cfg.set_value("profile", "coins", coins)
	cfg.set_value("profile", "unlocked", _unlocked)
	cfg.set_value("profile", "selected", _selected)
	cfg.set_value("profile", "upgrades", _upgrades)
	cfg.set_value("profile", "paid", _paid)
	cfg.set_value("profile", "tier", _tier_before_test if _tier_before_test >= 0 else tier)
	cfg.set_value("profile", "shop_hint_shown", shop_hint_shown)
	cfg.set_value("progress", "data", progress.to_dict())
	cfg.set_value("scores", "high_scores", high_scores)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "trophy_details", trophy_details)
	cfg.set_value("settings", "damage_numbers", damage_numbers)
	cfg.set_value("settings", "goal_arrows", goal_arrows)
	cfg.set_value("admin", "on", admin)
	cfg.set_value("admin", "no_ads", no_ads)
	cfg.save(SAVE_PATH)

func load_profile() -> void :
	var cfg: = ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	coins = cfg.get_value("profile", "coins", 0)
	_unlocked = cfg.get_value("profile", "unlocked", [])
	var selected: Variant = cfg.get_value("profile", "selected", "")
	_selected = selected if selected is String else ""
	_upgrades = cfg.get_value("profile", "upgrades", {})
	_paid = cfg.get_value("profile", "paid", {})
	_trim_upgrades()
	tier = cfg.get_value("profile", "tier", 0)
	shop_hint_shown = cfg.get_value("profile", "shop_hint_shown", false)
	var saved_progress: Variant = cfg.get_value("progress", "data", {})
	if saved_progress is Dictionary:
		progress.from_dict(saved_progress)
	high_scores = cfg.get_value("scores", "high_scores", [])
	music_volume = cfg.get_value("settings", "music_volume", 1.0)
	sfx_volume = cfg.get_value("settings", "sfx_volume", 1.0)
	trophy_details = cfg.get_value("settings", "trophy_details", false)
	damage_numbers = clampi(int(cfg.get_value("settings", "damage_numbers", 2)), 0, 2)
	goal_arrows = bool(cfg.get_value("settings", "goal_arrows", true))
	admin = bool(cfg.get_value("admin", "on", false))
	no_ads = admin and bool(cfg.get_value("admin", "no_ads", false))
