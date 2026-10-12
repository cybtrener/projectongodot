extends Node
class_name PlayerData

static var rewards: Dictionary[StringName, Reward] = {}
static var achievements: Dictionary[StringName, Achievement] = {}


static func get_reward(id: String) -> Reward:
	if !reward_is_valid(id): return null

	return rewards[id]

static func validate_achievements(acc: Account, ply: Player):
	for a in achievements.keys():
		var ach: Achievement = achievements[a]
		if ach.validate.call(acc, ply):
			for t in ach.reward_tanks:
				acc.add_tank(t, true)
			if ach.reward_credits > 0: acc.add_credits(ach.reward_credits)
			if ach.reward_gold > 0: acc.add_gold(ach.reward_gold)
			if ach.reward_freexp > 0: acc.add_freexp(ach.reward_freexp)

			acc.achievement_register(a)

static func validate_rewards(acc: Account, ply: Player) -> PackedStringArray:
	var valid_rewards: PackedStringArray = PackedStringArray()
	for r in rewards.keys():
		var rew: Reward = rewards[r]
		if rew.is_onetimer() and acc.has_reward(r):
			continue

		var valid = rew.validate.call(acc, ply)
		if valid:
			acc.add_reward(r, valid if valid is int else 1)

			for i in range(valid if valid is int else 1):
				valid_rewards.append(r)


	return valid_rewards

static func mastery_validator(acc: Account, player: Player, xp_tres: float):
	if !player or !player.tank_info: return false

	var tank_name: StringName = player.tank_info.name
	var stank: SaveTank = acc.get_tank(tank_name)

	var battles: Array[BattleResultRes] = acc.get_battles_in_tank(tank_name)

	var max_xp: int = 0
	for b in battles:
		if b.resolved: continue
		if b.xp > max_xp:
			max_xp = b.xp

	return battles.size() > 10 && (player.xp_earned / max_xp) - 1 > xp_tres

static var mastery_tres_3: float = 0.5
static var mastery_tres_2: float = 0.8
static var mastery_tres_1: float = 0.95
static var mastery_tres_m: float = 0.99

static func player_tank_class_is(ply: Player, clazz: TankInfoMain.Class) -> bool:
	if !ply: return false
	return ply.tank_info.tank_class == clazz

static func player_kills_reached(ply: Player, amount: int, eq_or_more: bool = false) -> bool:
	if !ply: return false

	return ply.kills.size() == amount || eq_or_more && ply.kills.size() >= amount

static func tarzcay_validator(ply: Player, kills: int):
	if !ply: return false
	return ply.ach_tarczay_kills > kills

static func init():
	new_reward(
		"beta_tester", 
		load("uid://bg1gvlhurs3uv"), 
		func(acc: Account, player: Player):
			if Global.VERSION_TYPE == Global.VersionType.BETA:
				acc.add_tank("kv-220", true)
				return true

			return false
	).set_rare().set_type(Reward.Type.ONE_TIME).set_gold_reward(500).set_rare()

	new_reward(
		"first_blood", 
		load("uid://cfl2pdvakkf8y"), 
		func(acc: Account, player: Player):
			if !player: return false
			return player.kills.size() > 0
	).set_type(Reward.Type.ONE_TIME).set_gold_reward(250).set_rare()

	new_reward(
		"first_victory", 
		load("res://assets/gfx/ui/lobby_common/achievements/firstVictory.tres"), 
		func(acc: Account, player: Player):
			return false
	).set_type(Reward.Type.ONE_TIME).set_rare().set_gold_reward(250)

	new_reward(
		"defender", 
		load("res://assets/gfx/ui/lobby_common/achievements/defender.tres"), 
		func(acc: Account, player: Player):
			if !player: return false
			return player.base_ticks_defended_max >= 70
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(300)

	new_reward(
		"armor_piercer", 
		load("res://assets/gfx/ui/lobby_common/achievements/armorPiercer.tres"), 
		func(acc: Account, player: Player):
			if !player: return false

			return player.ach_piercer_streaks
	).set_type(Reward.Type.GENERIC).set_gold_reward(20)

	new_reward(
		"fadin", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalFadin.tres"), 
		func(acc: Account, player: Player):
			return false
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(300)

	new_reward(
		"mastery_mark_3", 
		load("res://assets/gfx/ui/lobby_common/achievements/markOfMastery1.tres"), 
		func(acc: Account, player: Player):
			return mastery_validator(acc, player, mastery_tres_3) and !(
				mastery_validator(acc, player, mastery_tres_2)
				or 
				mastery_validator(acc, player, mastery_tres_1)
				or 
				mastery_validator(acc, player, mastery_tres_m)
			)
	).set_type(Reward.Type.GENERIC).set_rare().set_desc("rewards:mastery_mark/desc").set_gold_reward(125)

	new_reward(
		"mastery_mark_2", 
		load("res://assets/gfx/ui/lobby_common/achievements/markOfMastery2.tres"), 
		func(acc: Account, player: Player):
			return mastery_validator(acc, player, mastery_tres_2) and !(
				mastery_validator(acc, player, mastery_tres_1)
				or 
				mastery_validator(acc, player, mastery_tres_m)
			)
	).set_type(Reward.Type.GENERIC).set_rare().set_desc("rewards:mastery_mark/desc").set_gold_reward(200)

	new_reward(
		"mastery_mark_1", 
		load("res://assets/gfx/ui/lobby_common/achievements/markOfMastery3.tres"), 
		func(acc: Account, player: Player):
			return mastery_validator(acc, player, mastery_tres_1) and !mastery_validator(acc, player, mastery_tres_m)
	).set_type(Reward.Type.GENERIC).set_rare().set_desc("rewards:mastery_mark/desc").set_gold_reward(300)

	new_reward(
		"mastery_mark_m", 
		load("res://assets/gfx/ui/lobby_common/achievements/markOfMastery4.tres"), 
		func(acc: Account, player: Player):
			return mastery_validator(acc, player, mastery_tres_m)
	).set_type(Reward.Type.GENERIC).set_rare().set_desc("rewards:mastery_mark/desc").set_gold_reward(400)

	new_reward(
		"kolobanov", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalKolobanov.tres"), 
		func(acc: Account, player: Player):
			if !player: return false
			return player.ach_kolobanov_kills >= 3
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(500)

	new_reward(
		"rassenay", 
		load("res://assets/gfx/ui/lobby_common/achievements/heroesOfRassenay.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, maxi(Global.MAX_TEAM_TANKS, 7))
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(maxi(Global.MAX_TEAM_TANKS, 7) * 75)

	new_reward(
		"lafayette_pool", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalLafayettePool.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 6)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(200)

	new_reward(
		"radley_walters", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalRadleyWalters.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 5)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(150)

	new_reward(
		"tarzcay", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalTarczay.tres"), 
		func(acc: Account, player: Player):
			return tarzcay_validator(player, 5)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(2500)
	new_reward(
		"bruno_pietro", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalBrunoPietro.tres"), 
		func(acc: Account, player: Player):
			return tarzcay_validator(player, 3) && !tarzcay_validator(player, 5)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(1700)
	new_reward(
		"billotte", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalBillotte.tres"), 
		func(acc: Account, player: Player):
			return tarzcay_validator(player, 2) && !tarzcay_validator(player, 3) && !tarzcay_validator(player, 5)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(750)


	new_reward(
		"lehvaslaiho", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalLehvaslaiho.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 2) && player_tank_class_is(player, TankInfoMain.Class.MT)
	).set_type(Reward.Type.GENERIC).set_gold_reward(50)

	new_reward(
		"oskin", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalOskin.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 3) && player_tank_class_is(player, TankInfoMain.Class.MT)
	).set_type(Reward.Type.GENERIC).set_gold_reward(75)

	new_reward(
		"nikolas", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalNikolas.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 4, true) && player_tank_class_is(player, TankInfoMain.Class.MT)
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(150)

	new_reward(
		"orlik", 
		load("res://assets/gfx/ui/lobby_common/achievements/medalOrlik.tres"), 
		func(acc: Account, player: Player):
			return player_kills_reached(player, 3, true) && player_tank_class_is(player, TankInfoMain.Class.LT)
	).set_type(Reward.Type.GENERIC).set_gold_reward(100)
	new_reward(
		"warrior", 
		load("res://assets/gfx/ui/lobby_common/achievements/warrior.tres"), 
		func(acc: Account, player: Player):
			return false
	).set_type(Reward.Type.GENERIC).set_gold_reward(150)
	new_reward(
		"bombardier", 
		load("res://assets/gfx/ui/lobby_common/achievements/bombardier.tres"), 
		func(acc: Account, player: Player):
			return false
	).set_type(Reward.Type.GENERIC).set_rare().set_gold_reward(350)







class Reward:
	var icon: Texture2D
	var id: StringName
	var name_key: StringName
	var desc_key: StringName
	var gold_reward: int = 0

	var rare: bool = false

	func set_rare() -> Reward:
		self.rare = true
		return self

	func set_desc(new: String) -> Reward:
		self.desc_key = new
		return self

	func set_gold_reward(new: int) -> Reward:
		self.gold_reward = new
		return self

	func is_onetimer() -> bool:
		return type == Type.ONE_TIME

	var type: Type = Type.GENERIC
	var check_type: CheckWhen = CheckWhen.ALWAYS

	func set_type(t: Type) -> Reward:
		self.type = t
		return self
	func check_when(cw: CheckWhen) -> Reward:
		self.check_type = cw
		return self

	enum Type{
		GENERIC, 
		ONE_TIME, 
	}
	enum CheckWhen{
		ON_BATTLE_END, ON_HANGAR_UPDATE, ALWAYS
	}

	var validate = func(acc: Account, player: Player) -> bool:
		return false

class Achievement:
	var id: StringName
	var name_key: StringName
	var desc_key: StringName

	var validate = func(acc: Account, player: Player) -> bool:
		return false

	func with_rewards(
		tanks: Array[StringName], 
		credits: int, 
		gold: int, 
		freexp: int, 
	) -> Achievement:
		self.reward_tanks = tanks
		self.reward_credits = credits
		self.reward_gold = gold
		self.reward_freexp = freexp

		return self

	var reward_tanks: Array[StringName] = []
	var reward_credits: int = 0
	var reward_gold: int = 0
	var reward_freexp: int = 0

static func reward_is_valid(id: StringName) -> bool:
	return rewards.has(id)
static func achievement_is_valid(id: StringName) -> bool:
	return achievements.has(id)

static func new_reward(id: StringName, icon: Texture2D, validate: Callable) -> Reward:
	var reward: Reward = Reward.new()
	reward.icon = icon
	reward.id = id
	reward.name_key = "rewards:" + id + "/name"
	reward.desc_key = "rewards:" + id + "/desc"
	reward.validate = validate


	rewards[id] = reward

	return reward

static func new_achievement(id: StringName, icon: Texture2D, validate: Callable) -> Achievement:
	var achievement: Achievement = Achievement.new()
	achievement.icon = icon
	achievement.name_key = "achievments:" + id + "/name"
	achievement.desc_key = "achievments:" + id + "/desc"
	achievement.validate = validate

	achievements[id] = achievement

	return achievement
