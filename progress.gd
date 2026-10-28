class_name Progress
extends RefCounted













signal quest_completed(quest: Dictionary)
signal achievement_unlocked(achievement: Dictionary)
signal item_unlocked(id: String)

const QUEST_COUNT: = 3
const AD_GIFTS_PER_DAY: = 3
const AD_GIFT_SOULS: = 30



const QUESTS: = [
	{"id": "kills_a", "text": "Slay %d monsters", "stat": "kills", "mode": "sum", "target": 300, "reward": 40}, 
	{"id": "kills_b", "text": "Slay %d monsters", "stat": "kills", "mode": "sum", "target": 800, "reward": 100}, 
	{"id": "time_a", "text": "Survive %s in one run", "stat": "time", "mode": "max", "target": 360, "reward": 50}, 
	{"id": "time_b", "text": "Survive %s in one run", "stat": "time", "mode": "max", "target": 630, "reward": 110}, 
	{"id": "boss_a", "text": "Defeat %d boss", "stat": "bosses", "mode": "sum", "target": 1, "reward": 60}, 
	{"id": "boss_b", "text": "Defeat %d bosses", "stat": "bosses", "mode": "sum", "target": 3, "reward": 160}, 
	{"id": "level_a", "text": "Reach level %d in one run", "stat": "level", "mode": "max", "target": 12, "reward": 50}, 
	{"id": "level_b", "text": "Reach level %d in one run", "stat": "level", "mode": "max", "target": 20, "reward": 120}, 
	{"id": "props", "text": "Smash %d props", "stat": "props", "mode": "sum", "target": 25, "reward": 40}, 
	{"id": "chests", "text": "Open %d treasure chests", "stat": "chests", "mode": "sum", "target": 2, "reward": 70}, 
	{"id": "elites", "text": "Slay %d elites", "stat": "elites", "mode": "sum", "target": 6, "reward": 70}, 
	{"id": "wins", "text": "Win %d run", "stat": "wins", "mode": "sum", "target": 1, "reward": 150}, 
	{"id": "slot", "text": "Sign %d devil's contracts", "stat": "slot", "mode": "sum", "target": 2, "reward": 30}, 
	{"id": "fusion", "text": "Turn %d weapon holy", "stat": "holys", "mode": "sum", "target": 1, "reward": 120}, 
	{"id": "trophy", "text": "Claim %d boss trophy", "stat": "trophies", "mode": "sum", "target": 1, "reward": 70}, 
]


const ACHIEVEMENTS: = [
	{"id": "first_blood", "name": "First Blood", "desc": "Defeat a monster", "stat": "kills", "target": 1, "reward": 10}, 
	{"id": "slayer", "name": "Slayer", "desc": "Defeat 1,000 monsters", "stat": "kills", "target": 1000, "reward": 50}, 
	{"id": "legion", "name": "Legion Breaker", "desc": "Defeat 10,000 monsters", "stat": "kills", "target": 10000, "reward": 200}, 
	{"id": "hardy", "name": "Hard to Kill", "desc": "Survive 7:30 in one run", "stat": "time", "target": 450, "reward": 40}, 
	{"id": "victory", "name": "Victory", "desc": "Survive the whole clock", "stat": "wins", "target": 1, "reward": 100}, 
	{"id": "giant", "name": "Giant Slayer", "desc": "Defeat a boss", "stat": "bosses", "target": 1, "reward": 40}, 
	{"id": "boss_hunter", "name": "Boss Hunter", "desc": "Defeat 10 bosses", "stat": "bosses", "target": 10, "reward": 150}, 
	{"id": "ascended", "name": "Ascended", "desc": "Turn a weapon holy", "stat": "holys", "target": 1, "reward": 60}, 
	{"id": "veteran", "name": "Veteran", "desc": "Reach level 20 in one run", "stat": "level", "target": 20, "reward": 60}, 
	{"id": "collector", "name": "Soul Collector", "desc": "Earn 1,000 souls in total", "stat": "souls", "target": 1000, "reward": 80}, 
	{"id": "elite_hunter", "name": "Elite Hunter", "desc": "Defeat 25 elites", "stat": "elites", "target": 25, "reward": 80}, 
	{"id": "wrecker", "name": "Wrecker", "desc": "Smash 100 props", "stat": "props", "target": 100, "reward": 40}, 
	{"id": "treasure", "name": "Treasure Hunter", "desc": "Open 10 treasure chests", "stat": "chests", "target": 10, "reward": 60}, 
	{"id": "gambler", "name": "High Roller", "desc": "Sign 5 devil's contracts", "stat": "slot", "target": 5, "reward": 50}, 
	{"id": "diligent", "name": "Diligent", "desc": "Claim 10 daily quests", "stat": "quests", "target": 10, "reward": 80}, 
	{"id": "tier2", "name": "Rising Heat", "desc": "Win in the second realm", "stat": "tier_won", "target": 2, "reward": 100}, 
	{"id": "tier3", "name": "Deep Trouble", "desc": "Win in the third realm", "stat": "tier_won", "target": 3, "reward": 200}, 
	{"id": "tier4", "name": "Into Oblivion", "desc": "Win in the fourth realm", "stat": "tier_won", "target": 4, "reward": 300}, 
	{"id": "untouchable", "name": "Untouchable", "desc": "Win a run without taking a single hit", "stat": "flawless", "target": 1, "reward": 250, "hidden": true}, 
	{"id": "thread", "name": "By a Thread", "desc": "Win with 20 HP or less", "stat": "close_call", "target": 1, "reward": 100, "hidden": true}, 
	{"id": "favorite", "name": "Fine Print", "desc": "Have an angelic lawyer void the devil's price", "stat": "voided", "target": 1, "reward": 50, "hidden": true}, 
	{"id": "arsenal", "name": "Arsenal", "desc": "Max out five weapons in one run", "stat": "maxed_weapons", "target": 5, "reward": 150, "hidden": true}, 
	{"id": "moonlit", "name": "Moonlit", "desc": "Survive 3 blood moons", "stat": "moons", "target": 3, "reward": 80, "hidden": true}, 
	{"id": "beyond", "name": "Beyond", "desc": "Win in the deepest realm", "stat": "tier_won", "target": 5, "reward": 500, "hidden": true}, 
	{"id": "thorned", "name": "Bed of Thorns", "desc": "Slay 500 demons with thorns", "stat": "thorn_kills", "target": 500, "reward": 80}, 
	{"id": "lazarus", "name": "Lazarus", "desc": "Be saved by the Lazarus Relic 10 times", "stat": "relic_saves", "target": 10, "reward": 80}, 
	{"id": "sanctuary", "name": "Sanctuary", "desc": "Max out 3 defensive passives in one run", "stat": "maxed_defense", "target": 3, "reward": 120, "hidden": true}, 
	{"id": "trophy", "name": "Trophy Hunter", "desc": "Claim 5 boss trophies", "stat": "trophies", "target": 5, "reward": 80}, 
]






const RECIPES_VERSION: = 4
const FUSION_REWARD: = 150

static var _all_achievements: Array = []

var stats: = {}
var recipes_version: = RECIPES_VERSION
var run: = {}
var tiers_won: Array = []
var unlocked: Array = []
var quest_day: = ""
var quests: Array = []
var quest_rerolled: = false
var ad_gifts: = 0
var items: Array = []
var news: Array = []

func begin_run() -> void :
	run = {}
	news = []


func add_news(kind: String, title: String, text: = "", icon: = "") -> void :
	news.append({"kind": kind, "title": title, "text": text, "icon": icon})




func track(stat: String, n: = 1) -> void :
	run[stat] = run.get(stat, 0) + n
	stats[stat] = stats.get(stat, 0) + n
	for q: Dictionary in quests:
		var def: = quest_def(q["id"])
		if def.get("stat") == stat and def.get("mode") == "sum" and q["progress"] < def["target"]:
			q["progress"] = mini(q["progress"] + n, def["target"])
			if q["progress"] >= def["target"]:
				quest_completed.emit(q)
	_check_achievements(stat)
	_check_items(stat)


func track_max(stat: String, value: float) -> void :
	if value > run.get(stat, 0):
		run[stat] = value
	if value > stats.get(stat, 0):
		stats[stat] = value
	for q: Dictionary in quests:
		var def: = quest_def(q["id"])
		if def.get("stat") == stat and def.get("mode") == "max" and q["progress"] < def["target"] and value > q["progress"]:
			q["progress"] = mini(int(value), def["target"])
			if q["progress"] >= def["target"]:
				quest_completed.emit(q)
	_check_achievements(stat)
	_check_items(stat)

func mark_tier_won(tier: int) -> void :
	if not tiers_won.has(tier):
		tiers_won.append(tier)
	track_max("tier_won", tier + 1)

func is_tier_unlocked(tier: int) -> bool:
	return tier <= 0 or tiers_won.has(tier - 1)







static func all_achievements() -> Array:
	if _all_achievements.is_empty():
		_all_achievements = ACHIEVEMENTS.duplicate()
		for id: String in Game.EVOLUTIONS:
			var w: = Game.theme.weapon(id)
			var partner: = Game.theme.passive(Game.EVOLUTIONS[id])
			_all_achievements.append({"id": "fuse_" + id, "name": w.get("holy_name", id), 
				"desc": "Turn %s holy with %s" % [w.get("name", id), partner.get("name", "")], 
				"stat": "holy_" + id, "target": 1, "reward": FUSION_REWARD, "hidden": true, "fusion": id})
	return _all_achievements

func is_fusion_known(weapon_id: String) -> bool:
	return unlocked.has("fuse_" + weapon_id)



static var _achievements_by_stat: = {}
static var _items_by_stat: = {}

func _check_achievements(stat: String) -> void :
	if _achievements_by_stat.is_empty():
		for a: Dictionary in all_achievements():
			if not _achievements_by_stat.has(a["stat"]):
				_achievements_by_stat[a["stat"]] = []
			_achievements_by_stat[a["stat"]].append(a)
	for a: Dictionary in _achievements_by_stat.get(stat, []):
		if a["stat"] == stat and not unlocked.has(a["id"]) and stats.get(stat, 0) >= a["target"]:
			unlocked.append(a["id"])
			achievement_unlocked.emit(a)

func is_unlocked(id: String) -> bool:
	return unlocked.has(id)

func achievement_progress(a: Dictionary) -> float:
	return minf(float(stats.get(a["stat"], 0)), float(a["target"]))



func is_item_unlocked(id: String) -> bool:
	return not Game.UNLOCKS.has(id) or items.has(id)

func item_progress(id: String) -> float:
	var u: Dictionary = Game.UNLOCKS[id]
	return minf(float(stats.get(u["stat"], 0)), float(u["target"]))

func _check_items(stat: String, quiet: = false) -> void :
	if _items_by_stat.is_empty():
		for key: String in Game.UNLOCKS:
			var watched: String = Game.UNLOCKS[key]["stat"]
			if not _items_by_stat.has(watched):
				_items_by_stat[watched] = []
			_items_by_stat[watched].append(key)
	for id: String in _items_by_stat.get(stat, []):
		var u: Dictionary = Game.UNLOCKS[id]
		if u["stat"] == stat and not items.has(id) and stats.get(stat, 0) >= u["target"]:
			items.append(id)
			if not quiet:
				item_unlocked.emit(id)


func _check_all_items() -> void :
	for id: String in Game.UNLOCKS:
		_check_items(Game.UNLOCKS[id]["stat"], true)




static func quest_text(def: Dictionary) -> String:
	var target: = int(def["target"])
	if def.get("stat") == "time":
		return str(def["text"]) % ("%d:%02d" % [target / 60, target % 60])
	return str(def["text"]) % target

static func quest_def(id: String) -> Dictionary:
	for d: Dictionary in QUESTS:
		if d["id"] == id:
			return d
	return {}


func ensure_today() -> void :
	var today: = Time.get_date_string_from_system()
	if quest_day == today and quests.size() == QUEST_COUNT:
		return
	quest_day = today
	quest_rerolled = false
	ad_gifts = 0
	quests.clear()
	_fill_quests()

func _fill_quests() -> void :
	var used_stats: = []
	for q: Dictionary in quests:
		used_stats.append(quest_def(q["id"]).get("stat"))
	var pool: = QUESTS.duplicate()
	pool.shuffle()
	for d: Dictionary in pool:
		if quests.size() >= QUEST_COUNT:
			break
		if used_stats.has(d["stat"]):
			continue
		used_stats.append(d["stat"])
		quests.append({"id": d["id"], "progress": 0, "claimed": false})

func quest_done(q: Dictionary) -> bool:
	return q["progress"] >= quest_def(q["id"])["target"]

func claimable_quests() -> int:
	return quests.filter( func(q: Dictionary) -> bool: return quest_done(q) and not q["claimed"]).size()



func reroll_quests(force: = false) -> bool:
	if quest_rerolled and not force:
		return false
	quest_rerolled = true
	var kept: = quests.filter( func(q: Dictionary) -> bool: return quest_done(q))
	var old_ids: = quests.filter( func(q: Dictionary) -> bool: return not quest_done(q)).map( func(q: Dictionary) -> String: return q["id"])
	quests = kept
	_fill_quests()

	for i in quests.size():
		if old_ids.has(quests[i]["id"]) and not quest_done(quests[i]):
			var others: = []
			for j in quests.size():
				if j != i:
					others.append(quest_def(quests[j]["id"]).get("stat"))
			var options: = QUESTS.filter( func(d: Dictionary) -> bool:
				return not old_ids.has(d["id"]) and not others.has(d["stat"]) and not quests.any( func(q: Dictionary) -> bool: return q["id"] == d["id"]))
			if not options.is_empty():
				quests[i] = {"id": options.pick_random()["id"], "progress": 0, "claimed": false}
	return true


func take_ad_gift() -> int:
	if ad_gifts >= AD_GIFTS_PER_DAY:
		return 0
	ad_gifts += 1
	return AD_GIFT_SOULS


func claim_quest(index: int) -> int:
	var q: Dictionary = quests[index]
	if q["claimed"] or not quest_done(q):
		return 0
	q["claimed"] = true
	track("quests")
	return quest_def(q["id"])["reward"]



func to_dict() -> Dictionary:
	return {"stats": stats, "tiers_won": tiers_won, "unlocked": unlocked, "quest_day": quest_day, 
		"quests": quests, "quest_rerolled": quest_rerolled, "ad_gifts": ad_gifts, "items": items, 
		"recipes_version": recipes_version}

func from_dict(d: Dictionary) -> void :
	stats = d.get("stats", {})
	tiers_won = d.get("tiers_won", [])
	unlocked = d.get("unlocked", [])
	quest_day = d.get("quest_day", "")
	quests = d.get("quests", [])
	quest_rerolled = d.get("quest_rerolled", false)
	ad_gifts = d.get("ad_gifts", 0)
	items = d.get("items", [])
	if stats.get("wins", 0) < tiers_won.size():
		stats["wins"] = tiers_won.size()
	recipes_version = int(d.get("recipes_version", 1))
	if recipes_version < 2:
		unlocked = unlocked.filter( func(id: String) -> bool: return not id.begins_with("fuse_"))
	if recipes_version < 3:
		unlocked.erase("fuse_familiar")
		stats.erase("holy_familiar")
	if recipes_version < 4:
		for w: String in ["tear", "bulwark", "ravens"]:
			unlocked.erase("fuse_" + w)
			stats.erase("holy_" + w)
	recipes_version = RECIPES_VERSION
	_check_all_items()
