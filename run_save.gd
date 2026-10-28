class_name RunSave
extends RefCounted














const PATH: = "user://run.cfg"
const VERSION: = 1
const BOSS_RESTART: = 3.0
const RESUME_SHIELD: = 2.0

static func exists() -> bool:
	return FileAccess.file_exists(PATH)


static func read() -> Dictionary:
	var cfg: = ConfigFile.new()
	if cfg.load(PATH) != OK:
		return {}
	var data: Variant = cfg.get_value("run", "data", {})
	if not data is Dictionary or int((data as Dictionary).get("version", 0)) != VERSION:
		return {}
	return data

static func discard() -> void :
	if exists():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


static func write(player: Player) -> void :
	var spawner: = player.get_parent().get_node_or_null("Spawner") as Spawner
	var map: = player.get_tree().get_first_node_in_group("map") as GameMap
	var weapons: = []
	for c in player.get_children():
		if c is Weapon:
			var w: = c as Weapon
			weapons.append({"id": str(Weapon.info(w.get_script(), "ID")), "level": w.level, "holy": w.holy})
	var data: = {
		"version": VERSION, 
		"survivor": str(Game.survivor()["id"]), 
		"tier": Game.run_tier, 
		"items": Game.run_items(), 
		"test": {"pool": Game.test_pool.duplicate(), "survivor": Game.test_survivor}, 
		"map_seed": map.map_seed if map else 0, 
		"pos": player.global_position, 
		"player": player.save_state(), 
		"weapons": weapons, 
		"progress_run": Game.progress.run.duplicate(true), 
		"news": Game.progress.news.duplicate(true), 
	}
	var chests: = []
	for c in player.get_tree().get_nodes_in_group(OffscreenPointer.GROUP):
		var p: = c as Pickup
		if p and p.kind == Pickup.Kind.BLESSING and not p.is_queued_for_deletion():
			var boss: Variant = Game.theme.enemies.find_key(p.trophy) if not p.trophy.is_empty() else ""
			chests.append([p.global_position, p.tier, p.blessed, str(boss) if boss != null else ""])
	data["chests"] = chests
	var shrines: = player.get_tree().get_first_node_in_group("shrines") as Shrines
	if shrines:
		data["shrines"] = shrines.save_state()
	if spawner:
		data["spawner"] = spawner.save_state()
		if spawner.director:
			data["events"] = spawner.director.save_state()
	var cfg: = ConfigFile.new()
	cfg.set_value("run", "data", data)
	cfg.save(PATH)
	Enemy.flush_bestiary()
	Game.save_profile()


static func continue_run() -> bool:
	var data: = read()
	discard()
	if data.is_empty():
		return false
	var s: = Game.theme.survivor(str(data["survivor"]))
	if s.is_empty():
		return false
	var test: Dictionary = data.get("test", {})
	if not (test.get("pool", []) as Array).is_empty():
		Game.start_test_run(str(data["survivor"]), int(data["tier"]), test["pool"])
	else:
		Game.select_survivor(s)
		Game.select_tier(int(data["tier"]))
	Game.resume = data
	return true


static func abandon() -> void :
	var data: = read()
	discard()
	if data.is_empty():
		return
	var p: Dictionary = data["player"]
	var survived: = float(p["survived"])
	var kills: = int(p["kills"])
	var won: = bool(p.get("won", false))

	var base: = int(survived / Player.SECONDS_PER_SOUL) + kills / Player.KILLS_PER_SOUL + (Game.WIN_SOULS if won else 0)
	var bonus: = int(base * float(p.get("soul_mult", 1.0)))
	Game.coins += bonus
	Game.track_souls(bonus, str(data.get("survivor", "")))
	Game.end_run({"score": int(p["score"]), "time": survived, "level": int(p["level"]), "kills": kills, 
		"coins": int(p["coins"]), "bonus": bonus, "won": won, "tier": int(data["tier"])})


static func describe(data: Dictionary) -> String:
	var p: Dictionary = data["player"]
	var secs: = int(p["survived"])
	return "%s  ·  %s\n%02d:%02d  ·  Lv %d  ·  %s pts" % [Game.theme.survivor(str(data["survivor"])).get("name", "?"), 
		Game.tier_info(int(data["tier"]))["name"], secs / 60, secs % 60, int(p["level"]), HUD.format_score(int(p["score"]))]


static func restore(player: Player, data: Dictionary) -> void :
	Game.restore_run_items(data.get("items", []))
	Shrines.resume_taken = (data.get("shrines", []) as Array).duplicate()
	Game.progress.run = (data.get("progress_run", {}) as Dictionary).duplicate(true)
	Game.progress.news = (data.get("news", []) as Array).duplicate(true)
	for c in player.get_children():
		if c is Weapon:
			player.remove_child(c)
			c.queue_free()
	player.load_state(data["player"])
	for w: Dictionary in data["weapons"]:
		var script: Script = Game.WEAPONS.get(str(w["id"]))
		if script == null:
			continue
		var weapon: Weapon = script.new()
		weapon.level = clampi(int(w["level"]), 1, Weapon.max_level(script))
		weapon.holy = bool(w["holy"]) or bool(w.get("evolved", false))
		player.add_child(weapon)
	var map: = player.get_tree().get_first_node_in_group("map") as GameMap
	var pos: Vector2 = data.get("pos", Vector2.ZERO)
	player.global_position = map.push_out(pos, player.radius) if map else pos
	player._invuln = maxf(player._invuln, RESUME_SHIELD)
	for c: Array in data.get("chests", []):
		var p: = Pickup.spawn(player.get_parent(), Pickup.Kind.BLESSING, c[0])
		p.tier = int(c[1])
		p.blessed = bool(c[2])
		p.quiet = true
		if str(c[3]) != "":
			p.trophy = Game.theme.enemies.get(str(c[3]), {})
	var spawner: = player.get_parent().get_node_or_null("Spawner") as Spawner
	if spawner and data.has("spawner"):
		spawner.load_state(data["spawner"], player.survived)
		if spawner.director and data.has("events"):
			spawner.director.load_state(data["events"])
