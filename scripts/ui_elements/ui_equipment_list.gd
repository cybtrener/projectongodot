class_name UIEquipmentList
extends Control

@export var hangar_ui: Control

@export var slot1: Control
@export var slot2: Control
@export var slot3: Control

@export var elements_grid: GridContainer
@export var consumables: bool

@export var current_item_icon: TextureRect
@export var current_item_name: Label
@export var current_item_desc: Label

@export var action_button: ButtonCustom
@export var action_credits: TextureRect
@export var action_text: Label
@export var action_cost: Label

static var entry_template: Control = load("res://assets/gfx/ui/hangar/ui_selectable_list_entry.tscn").instantiate()
static var col_greenish: Color = Color("a3e39b")

var item_selected: String = ""
var item_selected_cost: int = 0
var slot_selected: int = -1
var curtank: SaveTank


enum ActionStatus{
	NO_ITEM, BUY, SELL, SWAP
}

func slots() -> Array[Control]:
	return [slot1, slot2, slot3]

func get_action_status() -> ActionStatus:
	if slot_selected == -1 or item_selected == "":
		return ActionStatus.NO_ITEM
	if item_selected == slots()[slot_selected].id:
		return ActionStatus.SELL
	if slots()[slot_selected].id == "":
		var equipments: Array[StringName] = curtank.consumables if self.consumables else curtank.equipment
		if item_selected != "" and equipments.has(item_selected):
			return ActionStatus.NO_ITEM
		return ActionStatus.BUY
	if item_selected != slots()[slot_selected].id:
		return ActionStatus.SWAP


	return ActionStatus.NO_ITEM

func acc() -> Account:
	return Global.save_main.get_current_account()

func action_pressed():
	var cost: int = get_current_item_cost()
	var cost_format: String = Util.format_number(cost)
	var cost_format_abs: String = Util.format_number(absi(cost))

	match get_action_status():
		ActionStatus.SELL:
			Global.create_popup(tr("CONFIRM"), tr("popup:confirm_sell") % cost, false, func():
				get_selected_slot().id = ""

				acc().add_credits(absi(cost))

				update_curtank_from_slots()
				update(curtank)

				Audio.play_sound2d(Audio.ui_sell)
				if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
					hangar_ui.update_hangar(true, curtank.name)
			)
		ActionStatus.SWAP:
			var sell: bool = cost <= 0
			var header: String = tr("popup:confirm_buy") % Util.format_number(cost) if !sell else tr("popup:confirm_sell") % Util.format_number(absi(cost))

			Global.create_popup(tr("CONFIRM"), header, false, func():
				if sell:
					acc().add_credits(absi(cost))
				elif !acc().withdraw_credits(absi(cost)):
					Global.create_popup("ERROR", tr("popup:NotEnoughCredits") % cost_format, true)


				get_selected_slot().id = item_selected


				update_curtank_from_slots()
				update(curtank)


				if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
					hangar_ui.update_hangar(true, curtank.name)
			)
		ActionStatus.BUY:
			Global.create_popup(tr("CONFIRM"), tr("popup:confirm_buy") % cost_format, false, func():
				if !acc().withdraw_credits(absi(cost)):
					Global.create_popup("ERROR", tr("popup:NotEnoughCredits") % cost_format, true)

				get_selected_slot().id = item_selected

				update_curtank_from_slots()
				update(curtank)

				if is_instance_valid(hangar_ui) and hangar_ui.has_method("update_hangar"):
					hangar_ui.update_hangar(true, curtank.name)
			)

func get_selected_slot() -> Control:
	return slots()[slot_selected]

func get_current_item_cost() -> int:
	match get_action_status():
		ActionStatus.SELL:
			return get_equipment_cost_by_id(item_selected) * - 0.5
		ActionStatus.SWAP:
			var cost_slot: int = get_equipment_cost_by_id(get_selected_slot().id) * 0.5
			var cost_selected: int = get_equipment_cost_by_id(item_selected)
			return - (cost_slot - cost_selected)
		ActionStatus.BUY:
			return get_equipment_cost_by_id(item_selected)

	return 0

func update_action_info():
	match get_action_status():
		ActionStatus.NO_ITEM:
			action_credits.hide()
			action_cost.hide()
			action_text.hide()
			action_button.hide()
		ActionStatus.SELL:
			action_credits.show()
			action_cost.show()
			action_text.show()
			action_button.show()
			action_text.text = tr("hangar:return_cost")
			action_cost.add_theme_color_override("font_color", col_greenish)

			action_cost.text = Util.format_number(get_equipment_cost_by_id(item_selected) * 0.5)

			action_button.text = tr("SELL")
			action_button.theme_type_variation = "ButtonRed"
		ActionStatus.SWAP:
			action_credits.show()
			action_cost.show()
			action_text.show()
			action_button.show()

			var cost_slot: int = get_equipment_cost_by_id(slots()[slot_selected].id) * 0.5
			var cost_selected: int = get_equipment_cost_by_id(item_selected)
			var diff: int = cost_slot - cost_selected

			if diff > 0:
				action_text.text = tr("hangar:return_cost")
				action_cost.add_theme_color_override("font_color", col_greenish)
			else:
				action_text.text = tr("hangar:cost")
				action_cost.add_theme_color_override("font_color", Color.WHITE)

			action_cost.text = Util.format_number(diff)

			action_button.text = tr("SWAP")
			action_button.theme_type_variation = "ButtonOrange"
		ActionStatus.BUY:
			action_credits.show()
			action_cost.show()
			action_text.text = tr("hangar:cost")
			action_cost.text = "-" + Util.format_number(get_equipment_cost_by_id(item_selected))
			action_text.show()
			action_button.show()
			action_cost.add_theme_color_override("font_color", Color.WHITE)

			action_button.text = tr("BUY")
			action_button.theme_type_variation = "ButtonGreen"

func get_equipment_cost_by_id(id: String) -> int:
	var eq: EquipmentBase = get_equipment_by_id(id)
	if eq:
		var tinfo: TankInfoMain = TanksDataBase.get_tank_by_name(curtank.name)
		var cost: int = (TanksDataBase.cost_by_lvl_consumables if consumables else TanksDataBase.cost_by_lvl_equipment)[tinfo.lvl - 1] * eq.cost_factor

		return cost

	return 0

func get_equipment_by_id(id: String) -> EquipmentBase:
	var list: Dictionary[StringName, EquipmentBase] = TanksDataBase.consumables_list if consumables else TanksDataBase.equipment_list
	if !list.has(id): return null

	return list[id]

func update_curtank_from_slots():
	if !curtank: return
	if consumables:
		curtank.consumables = [&"", &"", &""]
		curtank.consumables[0] = slot1.id
		curtank.consumables[1] = slot2.id
		curtank.consumables[2] = slot3.id
	else:
		curtank.equipment = [&"", &"", &""]
		curtank.equipment[0] = slot1.id
		curtank.equipment[1] = slot2.id
		curtank.equipment[2] = slot3.id

func select_slot_int(id: int):
	var slots: Array = slots()

	if slots[id].id != "":
		select_item(slots[id].id, true)

	var selected_item_is_installed: bool = false
	for s in slots:
		if s.id == item_selected: selected_item_is_installed = true

	if slots[id].id == "" && selected_item_is_installed:
		for e in elements_grid.get_children():
			if !item_is_installed(e.id):
				select_item(e.id)
				break

	for i in range(slots.size()):
		slots[i].select("", i == id)
	slot_selected = id

	update_action_info()

func item_is_installed(id: StringName) -> bool:
	return (curtank.consumables if consumables else curtank.equipment).has(id)

func select_slot(id: StringName, bypass_chain: bool = false):
	if !bypass_chain and id != "":
		select_item(id, true)

	var slots: Array = slots()
	if bypass_chain:
		var flag: = false
		for s in slots:
			if s.id == id: flag = true
		if !flag: return

	for i in range(slots.size()):
		var slot: Control = slots[i]

		var selected: bool = slot.id == id
		if selected: slot_selected = i
		slot.select("", id != "" and selected)

	update_action_info()

func select_item(id: StringName, bypass_chain: bool = false, deselect_all: bool = false):
	if !bypass_chain and id != "":
		select_slot(id, true)

	for c in elements_grid.get_children():
		if !c.has_method("select"): continue

		if c.select(id if !deselect_all else ""):
			item_selected = id
			current_item_icon.texture = c.icon.texture
			current_item_name.text = tr(c.name_key)
			current_item_desc.text = tr(c.desc_key)

			item_selected_cost = c.cost

	update_action_info()

func _ready() -> void :
	slot1.pressed.connect(select_slot_int.bind(0))
	slot2.pressed.connect(select_slot_int.bind(1))
	slot3.pressed.connect(select_slot_int.bind(2))

	action_button.pressed.connect(action_pressed)

func update(_curtank: SaveTank):
	var tinfo: TankInfoMain = TanksDataBase.get_tank_by_name(_curtank.name)
	var list: Dictionary[StringName, EquipmentBase] = TanksDataBase.consumables_list if consumables else TanksDataBase.equipment_list
	if list.is_empty(): return


	self.curtank = _curtank

	var slots_ids: Array[StringName] = curtank.consumables if consumables else curtank.equipment

	current_item_icon.texture = null
	current_item_name.text = ""
	current_item_desc.text = ""

	item_selected = ""
	item_selected_cost = 0
	slot_selected = -1

	var slots: Array = [slot1, slot2, slot3]
	for s in slots:
		s.init("", "", null, 0)
		s.id = ""
	for i in range(slots_ids.size()):
		if i > 2: continue
		if !list.has(slots_ids[i]): continue

		var eq: EquipmentBase = list[slots_ids[i]]
		slots[i].init(eq.name_key, eq.desc_key, eq.icon, 0)
		slots[i].id = eq.name_id

	for c in elements_grid.get_children():
		if is_instance_valid(c): c.queue_free()

	for id in list.keys():
		var eq: EquipmentBase = list[id]
		if !eq.can_be_used_on_nation(tinfo.nation): continue

		var entry: Control = entry_template.duplicate()
		var installed: bool = slots_ids.has(id)
		entry.init(eq.name_key, eq.desc_key, eq.icon, 0, installed)
		entry.id = id
		entry.pressed.connect(select_item.bind(entry.id))

		var flag_allslots: bool = true
		for s in slots_ids:
			if s == "": flag_allslots = false

		if !installed && flag_allslots && slots_ids.size() >= 3:
			entry.enable(false)

		entry.cost = get_equipment_cost_by_id(eq.name_id)

		elements_grid.add_child(entry)

	var last_free_slot: int = 0
	for i in range(slots().size()):
		var slot = slots()[i]
		if slot.id == "":
			last_free_slot = i
			break


	select_slot_int(last_free_slot)
