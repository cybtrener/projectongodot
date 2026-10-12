extends SaveBase
class_name Account

enum ProgressionLevel{
	LVL1, 
	LVL2, 
	LVL3, 
	LVL4, 
	LVL5
}

var logged_in: = false

@export var name: = "null"

@export var credits: = 250000
@export var gold: = 250
@export var free_xp: int = 0

@export var selected_tank_id: = 0
@export var selected_tank_name: StringName = ""

@export var tanks: Array[SaveTank] = [
]

@export var blacklist_slots_map: int = 1
@export var blacklist_slots_tank: int = 3

@export var knyaz_given: bool = false

@export var researched_modules: Array[StringName]
@export var rewards: Dictionary[StringName, int] = {}
@export var achievements_done: Array[StringName]

@export var time_ingame: float = 0.0


@export var shop_guaranteed_rewards: Dictionary[String, int] = {}

func should_get_guaranteed_reward(id: String, max_points: int) -> bool:
	if !shop_guaranteed_rewards.has(id):
		shop_guaranteed_rewards[id] = 1
	else:
		shop_guaranteed_rewards[id] += 1

	var yep: bool = shop_guaranteed_rewards[id] >= max_points
	if yep:
		shop_guaranteed_rewards[id] = 0

	return yep

func get_guaranteed_reward_points(id: String) -> int:
	if !shop_guaranteed_rewards.has(id): return 0

	return shop_guaranteed_rewards[id]

@export var last_login: float = Util.curtime_sys()
@export var creation_time: float = Util.curtime_sys()

@export var prem_account_expiration: = 0

@export var login: String = "loh_yebany"
@export var password: String = "124567"

@export var stat_killed_tanks: Dictionary[StringName, int]

@export var stat_max_kills: int = 0

@export var stat_spotted_tanks: Dictionary[StringName, int]
@export var stat_damage_dealt: int = 0
@export var stat_damage_taken: int = 0

@export var stat_shells_shot: int = 0
@export var stat_shells_hits: int = 0

@export var battle_results: Array[Dictionary] = []

signal on_credits_changed(amount: int)
signal on_gold_changed(amount: int)
signal on_freexp_changed(amount: int)
signal on_tank_received(name: String)

var top_battle_result_is_unresolved: bool = false


func notify_hangar(text: String, snd: bool = false):
	Global.receive_hangar_notif(text)

	if Global.hangar_ui && snd:
		Audio.stop_sound2d(Audio.ui_notif)
		Audio.play_sound2d(Audio.ui_notif)


func log_in():
	if has_reward("beta_tester") && !has_tank("kv-220", true):
		add_tank("kv-220", true)

	if !knyaz_given:
		var tens: int = 0
		for t in tanks:
			var info: TankInfoMain = TanksDataBase.get_tank_by_name(t.name)
			if info.lvl < 10: continue
			tens += 1
			if tens >= 10:
				add_tank("knyaz", true)
				knyaz_given = true
				break

	cleanup()
	init_press_akk()

	logged_in = true
	self.last_login = Util.curtime_sys()

	if !researched_modules:
		researched_modules = []
	if !achievements_done:
		achievements_done = []
	if !battle_results:
		battle_results = []

func get_tanks_bought() -> Array[SaveTank]:
	var tanks_bought: Array[SaveTank] = []
	for t in tanks:
		if t.bought: tanks_bought.push_back(t)
	return tanks_bought

func get_tanks_unlocked_by(tank: StringName) -> Array[StringName]:
	var unlockers: Array[StringName] = []
	for t in self.tanks:
		var info: TankInfoMain = TanksDataBase.get_tank_by_name(t.name)
		for key in info.unlock_tanks.keys():
			if (key as String).to_lower() != tank: continue
			unlockers.push_back(t.name)

	return unlockers

func can_research_tank(tank: StringName) -> bool:
	return !get_tanks_unlocked_by(tank).is_empty()

func tank_bought(nam: StringName) -> bool:
	for t in self.tanks:
		if t.name == nam and t.bought: return true
	return false
func tank_researched(nam: StringName) -> bool:
	var info: TankInfoMain = get_tank_info_validate(nam, true)
	if !info: return false
	if info.prem: return true

	return has_tank(nam, true)

func get_tank_info_validate(name: StringName, allow_donthave: bool = false) -> TankInfoMain:
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(name)
	if info.name == Global.BASE_TANK: return null
	if !has_tank(name) and !allow_donthave: return null

	return info

func withdraw_credits(cred: int) -> bool:
	if credits < cred:
		Global.create_popup(tr("ERROR"), tr("popup:NotEnoughCredits"), true)
		return false

	Audio.play_sound2d(Audio.ui_buy)
	credits -= cred

	notify_hangar(tr("news/credits_lost") % cred)

	return true


func add_freexp(fxp: int):
	free_xp += fxp

	notify_hangar(tr("news/freexp_lost" if fxp < 0 else "news/freexp_receive") % fxp)


func add_credits(cred: int):
	credits = maxi(credits + cred, 0)
	if Global.in_hangar:
		Audio.stop_sound2d(Audio.ui_sell)
		Audio.play_sound2d(Audio.ui_sell)

	if cred != 0: notify_hangar(tr("news/credits_lost" if cred < 0 else "news/credits_receive") % cred)


func add_gold(g: int):
	self.gold += g
	if Global.in_hangar:
		Audio.stop_sound2d(Audio.ui_sell)
		Audio.play_sound2d(Audio.ui_sell)

	if g != 0: notify_hangar(tr("news/gold_lost" if g < 0 else "news/gold_receive") % g, true)

func try_research_tank(tank: StringName, hangar_ui: Control = null):
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if self.has_tank(tank) and self.get_tank(tank).bought:
		Global.create_popup(tr("ERROR"), "tank is already bought lol, idk how did you get there", true)
		return
	if tank_researched(tank):
		Global.create_popup(tr("ERROR"), "its already researched the fuck you want from me", true)
		return
	if !can_research_tank(tank):
		Global.create_popup(tr("ERROR"), tr("hangar:research_prev_mods"), true)
		return

	var tanks_unlocked_by: Array[SaveTank] = []
	var st_priority: SaveTank
	for t in get_tanks_unlocked_by(tank):
		var st: SaveTank = get_tank(t)
		if st != null: tanks_unlocked_by.push_back(st)
	for t in tanks_unlocked_by:
		if !st_priority or st_priority.exp < t.exp: st_priority = t

	var cost: int = info.cost_xp

	if st_priority.exp >= cost:
		Global.create_popup(tr("CONFIRM"), tr("popup:confirm_research") % Util.format_number(cost), false, func():
			st_priority.exp -= cost
			add_tank(tank)

			if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
				hangar_ui.update_hangar(true, tank)
		)

	elif st_priority.exp + free_xp >= cost:
		var cost_freexp: int = cost - st_priority.exp

		st_priority.exp = 0
		self.free_xp -= cost_freexp

		Global.create_popup(tr("CONFIRM"), tr("popup:confirm_research_freexp") % [Util.format_number(st_priority.exp), Util.format_number(cost_freexp)], false, func():
			add_tank(tank)

			if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
				hangar_ui.update_hangar(true, tank)
		)
	else:
		Global.create_popup(tr("ERROR"), tr("popup:NotEnoughExp") % cost, true)

func try_buy_tank(tank: StringName, hangar_ui: Control = null):
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if self.has_tank(tank) and self.get_tank(tank).bought:
		Global.create_popup(tr("ERROR"), "tank is already bought lol, idk how did you get there", true)
		return
	if !tank_researched(tank):
		Global.create_popup(tr("ERROR"), tr("popup:research_tank_first" if !info.prem else "buy_tank_first"), true)
		return
	var currency_name: String = "gold" if info.prem else "credits"
	var currency: int = self.gold if info.prem else self.credits
	var popup_notenogh: String = "popup:NotEnoughGold" if info.prem else "popup:NotEnoughCredits"

	if currency >= info.cost:
		Global.create_popup(tr("CONFIRM"), tr("popup:confirm_buy") % Util.format_number(info.cost), false, func():
			if has_tank(tank, true):
				self.get_tank(tank).bought = true

				if info.prem:
					notify_hangar(tr("news/tank_receive") % info.display_name_short, true)

			else:
				add_tank(tank, true)

			if info.prem:
				add_gold( - info.cost)
			else:
				add_credits( - info.cost)

			if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
				hangar_ui.update_hangar(true, tank)
		)
	else:
		Global.create_popup(tr("ERROR"), tr(popup_notenogh) % info.cost, true)

func try_sell_tank(tank: StringName, hangar_ui: Control = null):
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if !tank_researched(tank):
		Global.create_popup(tr("ERROR"), tr("popup:research_tank_first" if !info.prem else "buy_tank_first"), true)
		return
	if self.has_tank(tank) and !self.get_tank(tank).bought:
		Global.create_popup(tr("ERROR"), tr("popup:buy_tank_first"), true)
		return

	var cost: int = info.cost * 400 if info.prem else info.cost
	cost *= 0.5

	Global.create_popup(tr("CONFIRM"), tr("popup:confirm_sell") % Util.format_number(cost), false, func():
		self.get_tank(tank).bought = false
		notify_hangar(tr("news/tank_sold") % info.display_name_short, true)

		add_credits(cost)
		self.selected_tank_id = clampi(selected_tank_id, 0, get_tanks_bought().size() - 1)

		if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
			hangar_ui.update_hangar(true, tank)
		)

func try_research_module(tank: StringName, kind: int, id: int, hangar_ui: Control = null):
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if !has_tank(tank, true):
		Global.create_popup(tr("ERROR"), tr("popup:research_tank_first" if !info.prem else "buy_tank_first"), true)
		return
	if !info:
		Global.create_popup(tr("ERROR"), "invalid tank", true)
		return

	var save_tank: SaveTank = get_tank(tank)

	kind = clampi(kind, 0, 2)

	var list: Array = [info.guns, info.engines, info.tracks][kind]
	if list.is_empty(): return
	if id > list.size() - 1: return

	var module = list[id]
	var cost: int = module.cost_xp
	var mod_name: StringName = module.name

	if save_tank.exp >= cost:
		Global.create_popup(tr("CONFIRM"), tr("popup:confirm_research") % Util.format_number(cost), false, func():
			save_tank.exp -= cost
			_research_module(mod_name)
			install_module(tank, kind, id)


			if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
				hangar_ui.update_hangar(true, tank)
				Audio.stop_sound2d(Audio.ui_select)
				Audio.play_sound2d(Audio.ui_install)
		)
	elif save_tank.exp + free_xp >= cost:
		var cost_freexp: int = cost - save_tank.exp



		Global.create_popup(tr("CONFIRM"), tr("popup:confirm_research_freexp") % [Util.format_number(save_tank.exp), Util.format_number(cost_freexp)], false, func():
			save_tank.exp = 0

			add_freexp( - cost_freexp)

			_research_module(mod_name)
			install_module(tank, kind, id)

			if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
				hangar_ui.update_hangar(true, tank)
				Audio.stop_sound2d(Audio.ui_select)
				Audio.play_sound2d(Audio.ui_install)
		)
	else:
		Global.create_popup(tr("ERROR"), tr("popup:NotEnoughExp") % cost, true)

func install_module(tank: StringName, kind: int, id: int) -> bool:
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if !has_tank(tank, true):
		Global.create_popup(tr("ERROR"), tr("popup:research_tank_first") if !info.prem else tr("popup:buy_tank_first"), true)
		return false
	if !info: return false

	var save_tank: SaveTank = get_tank(tank)

	kind = clampi(kind, 0, 2)
	var list: Array = [info.guns, info.engines, info.tracks][kind]
	id = clampi(id, 0, list.size() - 1)
	if kind == 0:
		save_tank.shells_amounts = []
		for s in info.guns[id].shells:
			save_tank.shells_amounts.append(0)

	if list.is_empty(): return false
	if id > list.size() - 1: return false

	save_tank.set(["gun_id", "engine_id", "track_id"][kind], id)

	return true

func module_researched(nam: StringName):
	return self.researched_modules.has(nam)
func _research_module(nam: StringName):
	if module_researched(nam): return
	self.researched_modules.push_back(nam)

func get_battles_in_tank(tank: String) -> Array[BattleResultRes]:
	var ress: Array[BattleResultRes] = []
	for res in battle_results:
		if !res: continue
		if res.tank == tank: ress.append(BattleResultRes.from_dict(res))

	return ress

func get_tank(tank: StringName) -> SaveTank:
	for t in tanks:
		if t.name == tank:
			return t
	return null

func is_tank_elite(name: StringName) -> bool:
	var info = TanksDataBase.get_tank_by_name(name)
	if info.prem: return true

	for t in info.unlock_tanks:
		if TanksDataBase.tank_exists(t) and !tank_researched(t): return false
	for module in info.guns:
		if !module_researched(module.name): return false
	for module in info.engines:
		if !module_researched(module.name): return false
	for module in info.tracks:
		if !module_researched(module.name): return false

	return true

func get_current_tank() -> SaveTank:
	if get_tanks_bought().is_empty(): return null
	var id: int = clampi(selected_tank_id, 0, get_tanks_bought().size() - 1)

	if get_tanks_bought().size() - 1 < selected_tank_id: return null

	for t in get_tanks_bought():
		if t.name == selected_tank_name: return get_tank(t.name)

	return get_tank(get_tanks_bought()[0].name)

func has_reward(id: StringName) -> bool:
	return rewards.has(id)
func add_reward(id: StringName, amount: int = 1):
	if !PlayerData.reward_is_valid(id): return

	var r: PlayerData.Reward = PlayerData.rewards[id]
	if r.is_onetimer() && has_reward(id):
		return

	if !has_reward(id):
		rewards[id] = amount
	else:
		rewards[id] = rewards[id] + amount

func achievement_register(id: StringName):
	if !PlayerData.achievement_is_valid(id): return

	achievements_done.append(id)

func add_tank(nam: String, bought: bool = false, no_compensation: bool = false) -> SaveTank:
	if nam == Global.BASE_TANK: return

	print("adding tank: ", nam)
	print("has_tank: ", self.has_tank(nam, true))

	if self.has_tank(nam, true):
		var st: SaveTank = self.get_tank(nam)
		if !st.bought:
			st.bought = bought
		elif !no_compensation:
			var info: TankInfoMain = TanksDataBase.get_tank_by_name(nam)
			if info.prem: add_credits(info.cost * Global.gold_price)

		print("self.get_tank(nam).bought: ", self.get_tank(nam).bought)

		Global.update_hangar(true)

		return

	var t: = SaveTank.new().with_name(nam)
	t.bought = bought
	tanks.push_back(t)

	var tinfo: TankInfoMain = TanksDataBase.get_tank_by_name(nam)

	notify_hangar(tr("news/tank_receive") % tinfo.display_name_short, true)

	Global.update_hangar(true)

	return t

func has_tank(nam: StringName, include_researched: bool = false) -> bool:
	for t in self.tanks:
		if t.name == nam and (t.bought or include_researched): return true
	return false

func prem_account_validate():
	if prem_account_expiration < Util.curtime_sys():
		prem_account_expiration = Util.curtime_sys()
func add_prem_account(hours: float, days: float = 0):
	prem_account_validate()
	prem_account_expiration += hours * 3600 + days * 24 * 3600

	if hours > 0 || days > 0: notify_hangar(tr("news/prem_receive") % [hours, days])

func get_prem_account() -> Dictionary:
	var curtime = Util.curtime_sys()
	var exp: float = maxf(prem_account_expiration - curtime, 0)

	var minutes: float = exp / 60
	var hours: float = minutes / 60
	var days: float = hours / 24

	return {
		days = days, 
		hours = hours, 
		minutes = minutes
	}
func has_prem_account() -> bool: return get_prem_account().minutes > 0

func get_time_played():
	return int(time_ingame * Util.sec_to_hour)

func get_last_unresolved_battle_result() -> BattleResultRes:
	var rbress: Array[Dictionary] = battle_results.duplicate()
	rbress.reverse()

	for r in rbress:
		if !r.resolved:
			r.resolved = true
			return BattleResultRes.from_dict(r)
	return null


func receive_battle_result(result: BattleResultRes):
	if result.credits > 0 && self.has_prem_account():
		result.credits *= 1.5






	add_credits(result.credits)
	add_gold(result.gold)
	add_freexp(result.freexp)

	var t: SaveTank = get_tank(result.player_tank_id)
	t.exp += result.xp

	var my_boy: Player = result.get_the_player()
	if my_boy.xp_earned > 0 && self.has_prem_account():
		my_boy.xp_earned *= 1.5

	for d in my_boy.log_damage_dealt.keys():
		t.stat_damage_dealt += my_boy.log_damage_dealt[d]
		stat_damage_dealt += my_boy.log_damage_dealt[d]
		t.stat_shells_hits += 1
		stat_shells_hits += 1
	for d in my_boy.log_damage_received.keys():
		t.stat_damage_taken += my_boy.log_damage_received[d]
		stat_damage_taken += my_boy.log_damage_received[d]

	for s in my_boy.shells_shot:
		stat_shells_shot += s
		t.stat_shells_shot += s

	for p in my_boy.kills:
		var pl: Player = result.get_player(p)
		if !pl: continue
		if !pl.tank_name: continue

		t.stat_kills += 1

		Util.dict_add_to_int(stat_killed_tanks, pl.tank_name, 1)

	if my_boy.xp_earned > t.stat_max_xp:
		t.stat_max_xp = my_boy.xp_earned

	if my_boy.kills.size() > stat_max_kills:
		stat_max_kills = my_boy.kills.size()
		t.stat_max_kills = my_boy.kills.size()

	for p in my_boy.spotted:
		var pl: Player = result.get_player(p)
		if !pl: continue
		if !pl.tank_name: continue

		Util.dict_add_to_int(stat_spotted_tanks, pl.tank_name, 1)



	for r in result.rewards:
		Util.dict_add_to_int(t.rewards, r, 1)

	battle_results.append(result.to_dict())
	print("account '", name, "'", "received battle result: ", result)
	print("\tstatus :", result.status)

	var status: String = tr({
		BattleResultRes.Status.DRAW: "battle_notif:draw", 
		BattleResultRes.Status.WIN: "battle_notif:victory", 
		BattleResultRes.Status.DEFEAT: "battle_notif:defeat", 
	}[result.status])
	var tinfo: TankInfoMain = TanksDataBase.get_tank_by_name(result.player_tank_id)
	notify_hangar("[" + status + "] " + tinfo.display_name_short + " | " + tr(Map.get_(result.map_id).name_display))



	if Global.save_battle_results:
		var path: String = "res://_battle_result_test/"
		DirAccess.make_dir_recursive_absolute(path)
		var date: Dictionary = Time.get_datetime_dict_from_system()
		var err: = ResourceSaver.save(result, path + "battle_" + Time.get_date_string_from_unix_time(result.date) + "_" + str(date.hour) + "-" + str(date.minute) + str(date.second) + ".tres")
		print("\tsaved battle result, err = ", err)


static func wn8_stats_dict(dmg: float, spot: float, frag: float, def: float, win: float) -> Dictionary:
	return {
		dmg = dmg, 
		spot = spot, 
		frag = frag, 
		def = def, 
		win = win, 
	}




static var wn8_expected_stats_by_lvl: Array[Dictionary] = [

	wn8_stats_dict(
		250, 
		1, 
		1, 
		20, 
		0.5)
	, 

	wn8_stats_dict(
		350, 
		1, 
		1, 
		30, 
		0.55)
	, 

	wn8_stats_dict(
		600, 
		1, 
		1, 
		70, 
		0.55)
	, 

	wn8_stats_dict(
		1000, 
		1, 
		1, 
		130, 
		0.55)
	, 

	wn8_stats_dict(
		1350, 
		2, 
		2, 
		350, 
		0.6)
	, 

	wn8_stats_dict(
		1300, 
		2, 
		2, 
		450, 
		0.6)
	, 

	wn8_stats_dict(
		1800, 
		3, 
		2, 
		600, 
		0.65)
	, 

	wn8_stats_dict(
		2350, 
		3, 
		2, 
		750, 
		0.7)
	, 

	wn8_stats_dict(
		2800, 
		3, 
		2, 
		1000, 
		0.8)
	, 

	wn8_stats_dict(
		3200, 
		3, 
		2, 
		1500, 
		0.85)
]


func get_avg_battle_stats() -> Dictionary:
	if battle_results.is_empty():
		return {
			avg_dmg = 0, 
			avg_spot = 0, 
			avg_frag = 0, 
			avg_block = 0, 
			avg_hitratio = 0, 
			avg_xp = 0, 
			max_xp = 0, 
			max_kills = 0, 
		}


	var avg_dmg: float = 0
	var avg_spot: float = 0
	var avg_frag: float = 0
	var avg_block: float = 0
	var avg_hitratio: float = 0

	var avg_xp: float = 0
	var max_xp: float = 0
	var max_kills: float = 0

	for rb in battle_results:
		var b: BattleResultRes = BattleResultRes.from_dict(rb)

		var p: Player = b.get_the_player()

		avg_dmg += p.get_dmg()
		avg_spot += p.spotted.size()
		avg_frag += p.kills.size()
		avg_block += p.get_def()
		avg_hitratio += p.get_hit_ratio()

		avg_xp += p.xp_earned_raw
		if p.xp_earned_raw > max_xp: max_xp = p.xp_earned_raw
		if p.kills.size() > max_kills: max_kills = p.kills.size()

	var s: float = battle_results.size()

	avg_dmg /= s
	avg_spot /= s
	avg_frag /= s
	avg_block /= s
	avg_hitratio /= s
	avg_xp /= s


	return {
		avg_dmg = avg_dmg, 
		avg_spot = avg_spot, 
		avg_frag = avg_frag, 
		avg_block = avg_block, 
		avg_hitratio = avg_hitratio, 
		avg_xp = avg_xp, 
		max_xp = max_xp, 
		max_kills = max_kills, 
	}

func get_rating() -> int:
	var bc: float = battle_results.size()
	if bc <= 0:
		return 0

	var win: float = get_wr()

	var surv: float = 0
	var dmg: float = 0
	var xp: float = 0

	for b in battle_results:
		var r: BattleResultRes = BattleResultRes.from_dict(b)
		var ply: Player = r.get_the_player()
		if ply.health > 0: surv += 1
		dmg += ply.get_dmg()

	surv /= bc
	dmg /= bc
	xp /= bc

	return 540 * bc ** 0.37 * tanh(
			(0.00163 * bc ** - 0.37) * (
			(3500 / (1 + exp(16 - 31 * win))) + (1400 / (1 + exp(8 - 27 * surv))) + 3700 * (asinh(0.0006 * dmg)) * 3900 * asinh(0.0015 * xp)
		)
	)

func get_tank_wn8(nam: String) -> int:









	if nam == Global.BASE_TANK: return 0
	var info: TankInfoMain = TanksDataBase.get_tank_by_name(nam)
	var stats_expected: Dictionary = wn8_expected_stats_by_lvl[info.lvl - 1]

	var avg_dmg: float = 0
	var avg_spot: float = 0
	var avg_frag: float = 0
	var avg_def: float = 0
	var avg_win: float = 0

	var battles: Array[BattleResultRes] = get_battles_in_tank(nam)
	for b in battles:
		var p: Player = b.get_the_player()
		avg_dmg += p.get_dmg()
		avg_spot += p.spotted.size()
		avg_frag += p.kills.size()
		avg_def += p.get_def()
		avg_win += 1 if b.status == BattleResultRes.Status.WIN else 0

	avg_dmg /= battles.size()
	avg_spot /= battles.size()
	avg_frag /= battles.size()
	avg_def /= battles.size()
	avg_win /= battles.size()


	var rDAMAGE = avg_dmg / stats_expected.dmg
	var rSPOT = avg_spot / stats_expected.spot
	var rFRAG = avg_frag / stats_expected.frag
	var rDEF = avg_def / stats_expected.def
	var rWIN = avg_win / stats_expected.win

	var rWINc: float = maxf(0, (rWIN - 0.71) / (1 - 0.71))
	var rDAMAGEc: float = maxf(0, (rDAMAGE - 0.22) / (1 - 0.22))
	var rFRAGc: float = maxf(0, minf(rDAMAGEc + 0.2, (rFRAG - 0.12) / (1 - 0.12)))
	var rSPOTc: float = maxf(0, minf(rDAMAGEc + 0.1, (rSPOT - 0.38) / (1 - 0.38)))
	var rDEFc: float = maxf(0, minf(rDAMAGEc + 0.1, (rDEF - 0.1) / (1 - 0.1)))

	var WN8: float = 980 * rDAMAGEc + 210 * rDAMAGEc * rFRAGc + 155 * rFRAGc * rSPOTc + 75 * rDEFc * rFRAGc + 145 * minf(1.8, rWINc)

	return WN8

func get_wr() -> float:
	if battle_results.size() == 0: return 0


	var wins: int = 0
	for battle in battle_results:


		if battle.status == BattleResultRes.Status.WIN: wins += 1




	return 100 * (float(wins) / float(battle_results.size()))

func module_validate(nm: String):
	if !self.module_researched(nm):
		self._research_module(nm)

func validate_modules(modules: Array, installed_id: int):
	if modules.size() < 1: return
	if modules.size() < installed_id + 1: return
	module_validate(modules[0].name)
	module_validate(modules[installed_id].name)

func get_tank_status(tank: StringName) -> Global.ResearchStatus:
	var info: TankInfoMain = get_tank_info_validate(tank, true)
	if !info: return Global.ResearchStatus.NOT_AVAILABLE

	if self.tank_bought(tank):
		return Global.ResearchStatus.INSTALLED_BOUGHT
	elif self.tank_researched(tank) or info.prem:
		return Global.ResearchStatus.RESEARCHED
	elif self.can_research_tank(tank):
		return Global.ResearchStatus.AVAILABLE


	return Global.ResearchStatus.NOT_AVAILABLE

func cleanup() -> void :
	var tanks_names: Array[StringName] = []
	var tanks_new: Array[SaveTank] = []

	for t in self.tanks:
		if tanks_names.has(t.name): continue
		var info: = TanksDataBase.get_tank_by_name(t.name)
		if info.name == Global.BASE_TANK: continue

		tanks_names.append(t.name)
		tanks_new.append(t)

		t.cleanup()

		validate_modules(info.guns, t.gun_id)
		validate_modules(info.engines, t.engine_id)
		validate_modules(info.tracks, t.track_id)

	self.tanks = tanks_new

	print("my tanks: ")
	for t in self.tanks:
		print("\t", t.name, "; bought: ", t.bought)

func init_press_akk():
	if login != "dxii@press.hui":
		return

	for t in TanksDataBase.list_main.keys():
		if !has_tank(t) || !tank_bought(t) && TanksDataBase.get_tank_by_name(t).prem:
			add_tank(t, true, true)

	var g: int = 2500000
	var c: int = 2500000000
	var fxp: int = 2500000

	if gold < g: gold = 2500000
	if credits < c: credits = 2500000000
	if free_xp < fxp: free_xp = 2500000


func on_load():
	pass

func on_save():
	pass

func save(path: StringName, save_path: StringName = ""):
	Util.save_resource_encrypted(self, path, ".account")

func log_out():
	if not logged_in: return

	self.top_battle_result_is_unresolved = false

	logged_in = false
	self.time_ingame += Util.curtime_sys() - self.last_login
