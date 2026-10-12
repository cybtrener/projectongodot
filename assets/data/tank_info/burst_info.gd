class_name BurstInfo extends Resource


@export var bursts: Array[int] = [1]


@export var intraclip: = 0.12

@export var intraburst: = 0.12

@export var rammer_mode_normal: = false

func _init() -> void :

	for i in range(self.bursts.size()):
		self.bursts[i] = clampi(self.bursts[i], 1, 1000)
	self.intraclip = absf(self.intraclip)
	self.intraburst = absf(self.intraburst)
