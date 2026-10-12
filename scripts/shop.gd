extends Node


var blacklist_slot_cost_map: int = 7500
var blacklist_slot_cost_tank: int = 1500


var loot_pool_huge: ContainerLoot = ContainerLoot.new("huge_container", 0.1, 85).add_rewards([
	ContainerLoot.entry("t26_e4_superpershing", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("t34_hvy", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("ke_ni_b", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("ltp", 1, ContainerLoot.LootType.TANK), 

	ContainerLoot.entry(10000, 1, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(7500, 2, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(3500, 5, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(1500, 15, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(750, 25, ContainerLoot.LootType.GOLD), 

	ContainerLoot.entry(1000000, 15, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(500000, 25, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(250000, 25, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(150000, 45, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(75000, 75, ContainerLoot.LootType.CREDITS), 

	ContainerLoot.entry(150000, 1, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(85000, 2, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(35000, 5, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(15000, 15, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(7500, 25, ContainerLoot.LootType.FREEXP), 
])

var loot_pool_small: ContainerLoot = ContainerLoot.new("small_container", 0.2, 50).add_rewards([
	ContainerLoot.entry("t1_e6", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("t2_e1", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("ha_go", 1, ContainerLoot.LootType.TANK), 
	ContainerLoot.entry("bt_7a", 1, ContainerLoot.LootType.TANK), 

	ContainerLoot.entry(1000, 1, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(750, 2, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(500, 5, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(200, 15, ContainerLoot.LootType.GOLD), 
	ContainerLoot.entry(50, 25, ContainerLoot.LootType.GOLD), 

	ContainerLoot.entry(120000, 1, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(50000, 2, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(25000, 5, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(15000, 15, ContainerLoot.LootType.CREDITS), 
	ContainerLoot.entry(7500, 25, ContainerLoot.LootType.CREDITS), 

	ContainerLoot.entry(10000, 1, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(9000, 2, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(7500, 5, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(3000, 15, ContainerLoot.LootType.FREEXP), 
	ContainerLoot.entry(1500, 25, ContainerLoot.LootType.FREEXP), 
])

var premium_entries: Array[Entry] = [
	prem_entry(1), 
	prem_entry(3), 
	prem_entry(7), 
	prem_entry(14), 
	prem_entry(30), 
	prem_entry(90), 
	prem_entry(180), 
	prem_entry(360), 
]
var tank_entries: Array[Entry] = []
func _ready() -> void :
	tank_entries.append(tank_entry("pzii_j", 3000))
	tank_entries.append(tank_entry("kv-5", 8500, 0.8))
	tank_entries.append(tank_entry("e-25", 7500, 0.8))
var containers: Array[Entry] = [
	container_entry(loot_pool_small, 500, load("res://assets/gfx/ui/shop/daily_chest_small.tres"), 50), 
	container_entry(loot_pool_huge, 2500, load("res://assets/gfx/ui/shop/daily_chest_big.tres"), 15)
]



static var prem_imgs: Dictionary[int, Texture2D] = {
	1: load("res://assets/gfx/ui/shop/ImagePremium1.tres"), 
	3: load("res://assets/gfx/ui/shop/ImagePremium3.tres"), 
	7: load("res://assets/gfx/ui/shop/ImagePremium7.tres"), 
	14: load("res://assets/gfx/ui/shop/ImagePremium14.tres"), 
	30: load("res://assets/gfx/ui/shop/ImagePremium30.tres"), 
	90: load("res://assets/gfx/ui/shop/ImagePremium90.tres"), 
	180: load("res://assets/gfx/ui/shop/ImagePremium180.tres"), 
	360: load("res://assets/gfx/ui/shop/ImagePremium360.tres"), 
}
func prem_entry(days: int) -> Entry:
	var prem_day_cost: int = 250
	return Entry.new(
		"", days * prem_day_cost, func(acc: Account): acc.add_prem_account(0, days)
	).set_image(prem_imgs[days], 0.57).set_name_key(tr("shop:entry_prem") % days)
func tank_entry(tank: String, cost: int, icon_scale: float = 1) -> Entry:
	var tinfo: TankInfoMain = TanksDataBase.get_tank_by_name(tank)

	return Entry.new(
		tank, cost, func(acc: Account): acc.add_tank(tank, true)
	).set_name_key(tinfo.display_name).set_image(load(tinfo.icon), icon_scale)

func container_entry(loot: ContainerLoot, cost: int, img: Texture2D, guaranteed_reward_points: int) -> Entry:
	var e: Entry = Entry.new(loot.guaranteed_reward_id, cost, func(acc: Account): pass).set_image(img)
	e._on_buy = func(acc: Account):
		var tanks_has: Array = []
		for r in loot.rewards:
			if r.type != ContainerLoot.LootType.TANK: continue
			if !acc.has_tank(r.value): continue

			tanks_has.append(r.value)

		if tanks_has.size() == loot.get_tanks_amount():
			tanks_has.clear()

		loot.guaranteed_reward_points = guaranteed_reward_points
		var rewards: Array[Dictionary] = loot.get_random_rewards(acc.should_get_guaranteed_reward(loot.guaranteed_reward_id, loot.guaranteed_reward_points), tanks_has)
		Global.hangar_ui.open_chest(rewards, e, loot.guaranteed_reward_id, loot.guaranteed_reward_points)

		for r in rewards:
			match r.type:
				ContainerLoot.LootType.TANK:
					acc.add_tank(r.value, true)
				ContainerLoot.LootType.GOLD:
					acc.add_gold(r.value)
				ContainerLoot.LootType.CREDITS:
					acc.add_credits(r.value)
				ContainerLoot.LootType.FREEXP:
					acc.add_freexp(r.value)

	return e

class Entry:
	var name_key: String = ""
	var desc_key: String = ""
	var image: Texture2D
	var image_size_factor: float



	func _init(nam: String, cost: int, on_buy: Callable) -> void :
		self.name_key = "shop:entry_" + nam + "/name"
		self.desc_key = "shop:entry_" + nam + "/desc"

		cost_gold = cost
		_on_buy = on_buy

	func set_image(img: Texture2D, size_factor: float = 1) -> Entry:
		image = img
		image_size_factor = size_factor

		return self

	func set_name_key(key: String) -> Entry:
		name_key = key

		return self

	func set_desc_key(key: String) -> Entry:
		desc_key = key

		return self

	var cost_gold: int = 500
	var _on_buy: Callable = func(acc: Account):
		pass

	func on_buy(acc: Account):
		acc.add_gold( - cost_gold)

		_on_buy.call(acc)

		Global.update_hangar(false)

class ContainerLoot:
	enum LootType{
		TANK, GOLD, CREDITS, FREEXP
	}

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var guaranteed_reward_id: String = "default_container"
	var guaranteed_reward_points: int = 100
	var tank_chance: float = 1
	var gold_chance: float = 1


	static func entry(value, weight: int, type: LootType) -> Dictionary:
		return {
			value = value, 
			weight = maxi(weight, 1), 
			type = type, 
		}


	var rewards: Array[Dictionary] = []

	func _init(id: String, tank_chance: float, gold_chance: float) -> void :
		self.guaranteed_reward_id = id
		self.tank_chance = tank_chance
		self.gold_chance = gold_chance

	func add_rewards(arr: Array[Dictionary]) -> ContainerLoot:
		for e in arr:
			rewards.append(e)

		return self

	func get_tanks_amount() -> int:
		var t: int = 0
		for r in self.rewards:
			if r.type == LootType.TANK: t += 1
		return t

	func get_random_rewards(guaranteed_tank: bool, exclude: Array = []) -> Array[Dictionary]:
		var arr_tanks: Array[Dictionary] = []
		var arr_gold: Array[Dictionary] = []
		var arr_credits: Array[Dictionary] = []
		var arr_freexp: Array[Dictionary] = []

		for r in self.rewards:
			if exclude.has(r.value): continue

			[
				arr_tanks, 
				arr_gold, 
				arr_credits, 
				arr_freexp
			][r.type].append(r)

		var tank = get_weighted(arr_tanks)
		var gold = get_weighted(arr_gold)
		var credits = get_weighted(arr_credits)
		var freexp = get_weighted(arr_freexp)

		var rews: Array[Dictionary] = [
			credits, 
			freexp
		]

		if tank && (guaranteed_tank || Util.random_chance(self.tank_chance)):
			rews.append(tank)
		if Util.random_chance(self.gold_chance):
			rews.append(gold)

		return rews


	func get_weighted(array: Array[Dictionary]):
		var weight_total: int = 0

		for r in array:
			weight_total += r.weight

		var roll: int = randi_range(1, weight_total)
		for r in array:
			roll -= r.weight
			if roll <= 0: return r

		return null
