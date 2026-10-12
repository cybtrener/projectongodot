extends Resource
class_name BattleResultRes

func _init(date: float, time: float):
	self.date = date
	self.time = time

enum Status{
	DRAW, WIN, DEFEAT
}
enum Reason{
	EXTERMINATUS, BASE_CAPTURE, TIMEOUT, BASR_CAPTURED
}

@export var tank: String = "base_tank"

@export var resolved: bool = false

@export var date: float = 0
@export var status: int = Status.DRAW
@export var reason: int = Reason.EXTERMINATUS
@export var prem: bool = false
@export var time: float = 0
@export var player_id: int = 0
@export var player_tank_id: String = ""
@export var map_id: String = Map.RUDNIKI.id
@export var player_team_a: bool = true
@export var teamA: Array[Player] = []
@export var teamB: Array[Player] = []

@export var rewards: Array[String] = []

@export var credits: int
@export var credits_raw: int
@export var gold: int
@export var xp: int
@export var freexp: int

func add_reward(r: String):
	var rew: PlayerData.Reward = PlayerData.get_reward(r)
	if !rew: return

	rewards.append(r)
	gold += rew.gold_reward

	print("\treceived a reward: ", r)
	print("\t\tgold: ", rew.gold_reward)
	print("\t\ttotal gold: ", gold)

func get_the_player() -> Player:
	return (teamA if player_team_a else teamB)[player_id]

func get_player(nam: StringName) -> Player:
	for p in teamA:
		if p.name == nam: return p
	for p in teamB:
		if p.name == nam: return p

	return null

func from(r: BattleResultRes) -> BattleResultRes:
	tank = r.tank
	resolved = r.resolved
	date = r.date
	status = r.status
	reason = r.reason
	prem = r.prem
	time = r.time
	player_id = r.player_id
	player_tank_id = r.player_tank_id
	map_id = r.map_id
	player_team_a = r.player_team_a
	teamA = r.teamA
	teamB = r.teamB
	rewards = r.rewards
	credits = r.credits
	credits_raw = r.credits_raw
	gold = r.gold
	xp = r.xp
	freexp = r.freexp

	return self

func to_dict() -> Dictionary:
	var d: Dictionary = {
		tank = self.tank, 
		resolved = self.resolved, 
		date = self.date, 
		status = self.status, 
		reason = self.reason, 
		prem = self.prem, 
		time = self.time, 
		player_id = self.player_id, 
		player_tank_id = self.player_tank_id, 
		map_id = self.map_id, 
		player_team_a = self.player_team_a, 
		teamA = [], 
		teamB = [], 
		rewards = self.rewards, 
		credits = self.credits, 
		credits_raw = self.credits_raw, 
		gold = self.gold, 
		xp = self.xp, 
		freexp = self.freexp, 
	}

	for p in teamA:
		d.teamA.append(p.to_dict())
	for p in teamB:
		d.teamB.append(p.to_dict())

	return d
static func from_dict(d: Dictionary) -> BattleResultRes:
	var r: BattleResultRes = BattleResultRes.new(1, 1)

	if d.has("tank"): r.tank = d.tank
	if d.has("resolved"): r.resolved = d.resolved
	if d.has("date"): r.date = d.date
	if d.has("status"): r.status = d.status
	if d.has("reason"): r.reason = d.reason
	if d.has("prem"): r.prem = d.prem
	if d.has("time"): r.time = d.time
	if d.has("player_id"): r.player_id = d.player_id
	if d.has("player_tank_id"): r.player_tank_id = d.player_tank_id
	if d.has("map_id"): r.map_id = d.map_id
	if d.has("player_team_a"): r.player_team_a = d.player_team_a

	if d.has("teamA"):
		for p in d.teamA:
			r.teamA.append(Player.from_dict(p))
	if d.has("teamB"):
		for p in d.teamB:
			r.teamB.append(Player.from_dict(p))

	if d.has("rewards"): r.rewards = d.rewards
	if d.has("credits"): r.credits = d.credits
	if d.has("credits_raw"): r.credits_raw = d.credits_raw
	if d.has("gold"): r.gold = d.gold
	if d.has("xp"): r.xp = d.xp
	if d.has("freexp"): r.freexp = d.freexp

	return r
