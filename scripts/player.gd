class_name Player
extends Resource

static func _new(nam: StringName, tnk: BaseTank, team: BaseTank.Team) -> Player:
	var ply: Player = Player.new()
	ply.name = nam
	ply.tank = tnk
	ply.team = team

	if tnk.tank_info:
		ply.tank_info = tnk.tank_info
		ply.tank_name = ply.tank_info.name
		ply.max_health = tnk.tank_info.health
	else:
		tnk.setup_completed.connect( func():
			ply.tank_info = tnk.tank_info
			ply.tank_name = ply.tank_info.name
			ply.max_health = tnk.tank_info.health
		)

	tnk.player = ply

	return ply

func from(p: Player) -> Player:
	team = p.team
	name = p.name
	tank_name = p.tank_name
	kills = p.kills
	spotted = p.spotted
	dmg = p.dmg
	dmg_blocked = p.dmg_blocked
	dmg_taken = p.dmg_taken
	shells_shot = p.shells_shot
	base_ticks_captured = p.base_ticks_captured
	base_ticks_defended = p.base_ticks_defended
	base_ticks_defended_max = p.base_ticks_defended_max
	max_health = p.max_health
	health = p.health
	destroyed_time = p.destroyed_time
	log_damage_dealt = p.log_damage_dealt
	log_damage_received = p.log_damage_received
	log_hits_dmg = p.log_hits_dmg
	log_hits_bounce = p.log_hits_bounce
	rewards = p.rewards
	xp_earned = p.xp_earned
	credits_earned = p.credits_earned
	credits_lost_repair = p.credits_lost_repair
	credits_lost_ammo = p.credits_lost_ammo
	credits_lost_consumables = p.credits_lost_consumables
	module_crits = p.module_crits
	players_interacted = p.players_interacted
	platoon_id = p.platoon_id
	hits_dmg = p.hits_dmg
	hits_bounce = p.hits_bounce


	return self

func health_coeff() -> float:
	return health / max_health

func give_reward(name: StringName):
	rewards.append(name)

@export var team: BaseTank.Team = BaseTank.Team.TEAM_A
@export var name: StringName = "umerchik"

var tank: BaseTank
var tank_info: TankInfoMain
@export var tank_name: StringName

@export var kills: Array[StringName] = []
@export var spotted: Array[StringName] = []
@export var dmg: int = 0
@export var dmg_blocked: int = 0
@export var dmg_taken: int = 0
@export var shells_shot: Array[int] = [0, 0, 0]
@export var base_ticks_captured: int = 0
@export var base_ticks_defended: int = 0
@export var base_ticks_defended_max: int = 0

@export var max_health: int = 0
@export var health: int = 0

@export var destroyed_time: float = -1

@export var log_damage_dealt: Dictionary[StringName, int] = {}
@export var log_damage_received: Dictionary[StringName, int] = {}

@export var log_hits_dmg: Dictionary[StringName, int] = {}
@export var log_hits_bounce: Dictionary[StringName, int] = {}

@export var rewards: Array[StringName] = []

@export var xp_earned: int = 0
@export var xp_earned_raw: int = 0
@export var credits_earned: int = 0

@export var credits_lost_repair: int = 0
@export var credits_lost_ammo: int = 0
@export var credits_lost_consumables: int = 0

@export var module_crits: int = 0

@export var players_interacted: Dictionary[StringName, Dictionary] = {}

@export var platoon_id: int = -1
@export var hits_dmg: int = 0

@export var hits_bounce: int = 0:
	set(a):
		hits_bounce = a
		ach_piercer_streak_current = 0

var ach_piercer_streak_current: int = 0
var ach_piercer_streaks: int = 0
var ach_hand_of_death: int = 0
var ach_kolobanov_kills: int = 0
var ach_tarczay_kills: int = 0

func get_dmg() -> int:
	var d: int = 0
	for i in log_damage_dealt.keys():
		d += log_damage_dealt[i]

	return d

func get_def() -> int:
	var d: int = 0
	for i in log_damage_received.keys():
		d += log_damage_received[i]

	return d

func get_hit_ratio() -> float:
	var hits: float = 0
	var shots: float = 0

	if log_hits_dmg.is_empty():
		return 0

	for i in log_hits_dmg.keys():
		hits += log_hits_dmg[i]

	for s in shells_shot:
		shots += s

	if shots == 0 || hits == 0:
		return 1







	return hits / shots

func create_meta_info() -> Dictionary:
	return {
		tank_name = self.tank_name, 
		tank_lvl = self.tank_info.lvl, 
	}
func earn_xp(win: bool):
	var lvl_diff_coeff_spot: float = 0.4
	var lvl_diff_coeff_dmg: float = 0.2
	var lvl_diff_coeff_kill: float = 0.1

	var first_spot_coeff: float = 90
	var per_base_tick: float = 20

	var dmg_coeff: float = 0.25
	var kill_coeff: float = 50
	var block_coeff: float = 0.35

	var fxp_earned: float = 0



	for p in spotted:
		if players_interacted.has(p):
			var diff: int = tank_info.lvl - players_interacted[p].tank_lvl
			var dcoeff: float = maxi(1, 1 + diff * lvl_diff_coeff_spot)

			fxp_earned += first_spot_coeff * dcoeff

			continue

		fxp_earned += first_spot_coeff


	for p in log_damage_dealt.keys():
		if players_interacted.has(p):
			var diff: int = tank_info.lvl - players_interacted[p].tank_lvl
			var dcoeff: float = maxi(1, 1 + diff * lvl_diff_coeff_dmg)

			fxp_earned += log_damage_dealt[p] * dmg_coeff * dcoeff

			continue
		fxp_earned += log_damage_dealt[p] * dmg_coeff




	for p in kills:
		if players_interacted.has(p):
			var diff: int = tank_info.lvl - players_interacted[p].tank_lvl
			var dcoeff: float = maxi(1, 1 + diff * lvl_diff_coeff_kill)

			fxp_earned += kill_coeff * dcoeff

			continue
		fxp_earned += kill_coeff


	fxp_earned += per_base_tick * base_ticks_captured
	fxp_earned += dmg_blocked * block_coeff

	xp_earned_raw = fxp_earned

	fxp_earned *= 1.5 if tank_info.prem else 1
	fxp_earned *= 1.5 if win else 1

	xp_earned = int(fxp_earned)


func earn_credits(win: bool, courageous_resist: bool):
	var lvl_coeff: int = 800 * (1.85 if win else 1)
	if !win && courageous_resist:
		lvl_coeff *= 1.5

	var first_spot_coeff: int = 800
	var per_base_tick: int = 250

	var dmg_coeff: float = 10

	var block_coeff: int = 20

	credits_earned += lvl_coeff * tank_info.lvl
	credits_earned += spotted.size() * first_spot_coeff
	credits_earned += per_base_tick * base_ticks_captured
	credits_earned += dmg * dmg_coeff
	credits_earned += dmg_blocked * block_coeff

	credits_earned *= tank_info.farm_coeff


func to_dict() -> Dictionary:
	var default: Player = Player.new()

	var d: Dictionary = {}

	if self.team != default.team: d[&"team"] = self.team
	if self.name != default.name: d[&"name"] = self.name
	if self.tank_name != default.tank_name: d[&"tank_name"] = self.tank_name
	if self.kills != default.kills: d[&"kills"] = self.kills
	if self.spotted != default.spotted: d[&"spotted"] = self.spotted
	if self.dmg_blocked != default.dmg_blocked: d[&"dmg_blocked"] = self.dmg_blocked
	if self.dmg_taken != default.dmg_taken: d[&"dmg_taken"] = self.dmg_taken
	if self.shells_shot != default.shells_shot: d[&"shells_shot"] = self.shells_shot
	if self.base_ticks_captured != default.base_ticks_captured: d[&"base_ticks_captured"] = self.base_ticks_captured
	if self.base_ticks_defended != default.base_ticks_defended: d[&"base_ticks_defended"] = self.base_ticks_defended
	if self.base_ticks_defended_max != default.base_ticks_defended_max: d[&"base_ticks_defended_max"] = self.base_ticks_defended_max
	if self.max_health != default.max_health: d[&"max_health"] = self.max_health
	if self.health != default.health: d[&"health"] = self.health
	if self.destroyed_time != default.destroyed_time: d[&"destroyed_time"] = self.destroyed_time
	if self.log_damage_dealt != default.log_damage_dealt: d[&"log_damage_dealt"] = self.log_damage_dealt
	if self.log_damage_received != default.log_damage_received: d[&"log_damage_received"] = self.log_damage_received
	if self.log_hits_dmg != default.log_hits_dmg: d[&"log_hits_dmg"] = self.log_hits_dmg
	if self.log_hits_bounce != default.log_hits_bounce: d[&"log_hits_bounce"] = self.log_hits_bounce
	if self.rewards != default.rewards: d[&"rewards"] = self.rewards
	if self.xp_earned != default.xp_earned: d[&"xp_earned"] = self.xp_earned
	if self.xp_earned_raw != default.xp_earned_raw: d[&"xp_earned_raw"] = self.xp_earned_raw
	if self.credits_earned != default.credits_earned: d[&"credits_earned"] = self.credits_earned
	if self.credits_lost_repair != default.credits_lost_repair: d[&"credits_lost_repair"] = self.credits_lost_repair
	if self.credits_lost_ammo != default.credits_lost_ammo: d[&"credits_lost_ammo"] = self.credits_lost_ammo
	if self.credits_lost_consumables != default.credits_lost_consumables: d[&"credits_lost_consumables"] = self.credits_lost_consumables
	if self.module_crits != default.module_crits: d[&"module_crits"] = self.module_crits
	if self.players_interacted != default.players_interacted: d[&"players_interacted"] = self.players_interacted
	if self.platoon_id != default.platoon_id: d[&"platoon_id"] = self.platoon_id
	if self.hits_dmg != default.hits_dmg: d[&"hits_dmg"] = self.hits_dmg
	if self.hits_bounce != default.hits_bounce: d[&"hits_bounce"] = self.hits_bounce


	return d

static func from_dict(d: Dictionary) -> Player:
	var p: Player = Player.new()

	if d.has("team"): p.team = d.team
	if d.has("name"): p.name = d.name
	if d.has("tank_name"): p.tank_name = d.tank_name
	if d.has("kills"): p.kills = d.kills
	if d.has("spotted"): p.spotted = d.spotted
	if d.has("dmg"): p.dmg = d.dmg
	if d.has("dmg_blocked"): p.dmg_blocked = d.dmg_blocked
	if d.has("dmg_taken"): p.dmg_taken = d.dmg_taken
	if d.has("shells_shot"): p.shells_shot = d.shells_shot
	if d.has("base_ticks_captured"): p.base_ticks_captured = d.base_ticks_captured
	if d.has("base_ticks_defended"): p.base_ticks_defended = d.base_ticks_defended
	if d.has("base_ticks_defended_max"): p.base_ticks_defended_max = d.base_ticks_defended_max
	if d.has("max_health"): p.max_health = d.max_health
	if d.has("health"): p.health = d.health
	if d.has("destroyed_time"): p.destroyed_time = d.destroyed_time
	if d.has("log_damage_dealt"): p.log_damage_dealt = d.log_damage_dealt
	if d.has("log_damage_received"): p.log_damage_received = d.log_damage_received
	if d.has("log_hits_dmg"): p.log_hits_dmg = d.log_hits_dmg
	if d.has("log_hits_bounce"): p.log_hits_bounce = d.log_hits_bounce
	if d.has("rewards"): p.rewards = d.rewards
	if d.has("xp_earned_raw"): p.xp_earned_raw = d.xp_earned_raw
	if d.has("xp_earned"): p.xp_earned = d.xp_earned
	if d.has("credits_earned"): p.credits_earned = d.credits_earned
	if d.has("credits_lost_repair"): p.credits_lost_repair = d.credits_lost_repair
	if d.has("credits_lost_ammo"): p.credits_lost_ammo = d.credits_lost_ammo
	if d.has("credits_lost_consumables"): p.credits_lost_consumables = d.credits_lost_consumables
	if d.has("module_crits"): p.module_crits = d.module_crits
	if d.has("players_interacted"): p.players_interacted = d.players_interacted
	if d.has("platoon_id"): p.platoon_id = d.platoon_id
	if d.has("hits_dmg"): p.hits_dmg = d.hits_dmg
	if d.has("hits_bounce"): p.hits_bounce = d.hits_bounce


	return p
