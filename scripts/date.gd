extends Resource
class_name Date


















































const MAX_CALENDAR_DAYS: int = 42
const ZELLER_CONGRUENCE: Array = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
const DAYS: Array = [
	"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
	]
const MONTHS: Array = [
	"January", "February", "March", "April", "May", "June", "July", "August", 
	"September", "October", "November", "December"
	]





var day: int = 0: set = set_day


var month: int = 0: set = set_month


var year: int = 0: set = set_year


var min_year: int = 1000: set = set_min_year


var max_year: int = 9999: set = set_max_year








func _init(d: int = get_today().day, m: int = get_today().month, y: int = get_today().year) -> void :
	set_day(d).set_month(m).set_year(y)











func increment_day(mode: bool, max_iteration: int = 1) -> Date:
	var current_iteration: int = 0
	while current_iteration < max_iteration:
		match mode:
			true: day += 1
			false: day -= 1
		if day > get_days_in_month():
			increment_month(true)
			day = 1
		elif day < 1:
			increment_month(false)
			day = get_days_in_month()
		current_iteration += 1
	return self









func increment_month(mode: bool, max_iteration: int = 1) -> Date:
	var current_iteration: int = 0
	while current_iteration < max_iteration:
		match mode:
			true: month += 1
			false: month -= 1
		if month > 12:
			month = 1
			year += 1
		elif month < 1:
			month = 12
			year -= 1
		current_iteration += 1
	return self




func increment_year(mode: bool, max_iteration: int = 1) -> Date:
	return set_year((year + max_iteration) if mode else (year - max_iteration)).set_day(day)













func format_day(format, d: int = day, m: int = month, y: int = year) -> String:
	match format.length() if format is String else int(format):
		1: return str(d)
		2: return str(d).pad_zeros(2)
		3: return DAYS[get_weekday(d, m, y)].left(2)
		4: return DAYS[get_weekday(d, m, y)].left(3)
		_: return DAYS[get_weekday(d, m, y)]









func format_month(format, m: int = month) -> String:
	match format.length() if format is String else int(format):
		1: return str(m)
		2: return str(m).pad_zeros(2)
		3: return MONTHS[m - 1].left(3)
		_: return MONTHS[m - 1]





func format_year(format, y: int = year) -> String:
	return str(y) if (format.length() if format is String else int(format)) >= 4 else str(y).right(2)




func join_formats(formatted_strings: PackedStringArray, delimiter: String = "-") -> String:
	return delimiter.join(formatted_strings)

func difference_hours(date: Date):
	var yd: = date.year - self.year
	var md: = date.day - self.day





func get_days_in_month(m: int = month, y: int = year) -> int:
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	if _m in PackedInt32Array([4, 6, 9, 11]):
		return 30
	elif _m == 2:
		match (_y % 4 == 0 and _y % 100 != 0) or (_y % 400 == 0):
			true: return 29
			false: return 28
	return 31



func get_dict() -> Dictionary:
	return {"day": day, "month": month, "year": year}



func get_today(utc: bool = false) -> Dictionary:
	var system_date: Dictionary = Time.get_date_dict_from_system(utc)
	return {"day": system_date.day, "month": system_date.month, "year": system_date.year}



func get_weekday(d: int = day, m: int = month, y: int = year) -> int:
	var _d: int = clamp_day(d, m, y)
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	var dd: int = ZELLER_CONGRUENCE[_m - 1] + _d - 1
	var yy: int = _y - 1 if _m < 3 else _y
	return ((yy + int(yy / 4.0) - int(yy / 100.0) + int(yy / 400.0) + dd) % 7)



func get_last_week_day_of_year(y: int = year) -> int:
	var _y: int = clamp_year(y)
	return (_y + int(_y / 4.0) - int(_y / 100.0) + int(_y / 400.0)) % 7



func get_number_of_weeks_of_year(y: int = year) -> int:
	return 52 + (1 if get_last_week_day_of_year(y) == 4 or get_last_week_day_of_year(clamp_year(y) - 1) == 3 else 0)



func get_iso_day_of_year(d: int = day, m: int = month, y: int = year) -> int:
	return int((_get_unix(d, m, y) - _get_unix_first_day_of_year(y)) / 86400.0) + 1



func get_iso_week_number(d: int = day, m: int = month, y: int = year) -> int:
	var iso_day_of_year: int = get_iso_day_of_year(d, m, y) - 1
	var iso_weekday: int = (get_last_week_day_of_year(y - 1) + iso_day_of_year) % 7 + 1
	var iso_week_number: int = int(float(iso_day_of_year + 1 - iso_weekday + 10) / 7.0)
	if iso_week_number < 1:
		return get_number_of_weeks_of_year(y - 1)
	elif iso_week_number > get_number_of_weeks_of_year(y):
		return 1
	return iso_week_number































func get_calendar_dict(m: int = month, y: int = year) -> Dictionary:
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	var calendar_dict: Dictionary = {}
	var day_first: int = get_weekday(1, _m, _y)
	var day_count: int = 1
	for day_idx in MAX_CALENDAR_DAYS:
		calendar_dict[day_idx] = {}
		if day_idx in range(day_first, get_days_in_month(_m, _y) + day_first):
			calendar_dict[day_idx] = {
				"day": day_count, 
				"row": int(day_idx / 7.0), 
				"week": get_iso_week_number(day_count, _m, _y), 
				"weekday": get_weekday(day_count, _m, _y)
				}
			day_count += 1
	return calendar_dict


















func get_calendar_array2d(m: int = month, y: int = year) -> Array:
	var calendar_array2d: Array = []
	var calendar_dict: Dictionary = get_calendar_dict(m, y)
	var last_day_idx: int = 0
	for row_idx in sqrt(MAX_CALENDAR_DAYS) - 1:
		var row: PackedStringArray = PackedStringArray([])
		var row_range: PackedInt32Array = PackedInt32Array(range(last_day_idx, last_day_idx + 7))
		row.resize(7)
		row.fill("  ")
		for idx in row_range.size():
			var day_idx: int = row_range[idx]
			if not calendar_dict[day_idx].is_empty():
				row[idx] = str(calendar_dict[day_idx].day).pad_zeros(2)
			if idx == row_range.size() - 1:
				last_day_idx = day_idx + 1
		calendar_array2d.append(row)
	return calendar_array2d







func print_calendar_array2d(m: int = month, y: int = year) -> void :
	print("> %s / %d" % [format_month(4, m), year])
	print((DAYS as Array).map( func substr(text: String) -> String: return text.substr(0, 2)))
	get_calendar_array2d(m, y).any( func print_row(row: Array) -> void : print(row))





func set_today() -> Date:
	set_day(get_today().day).set_month(get_today().month).set_year(get_today().year)
	return self




func set_day(d: int) -> Date:
	day = clamp_day(d, month, year)
	return self



func set_month(m: int) -> Date:
	month = clamp_month(m)
	return self



func set_year(y: int) -> Date:
	year = clamp_year(y)
	return self




func set_min_year(value: int) -> Date:
	min_year = clamp_year_bounds(value)
	return self




func set_max_year(value: int) -> Date:
	max_year = clamp_year_bounds(value)
	return self







func clamp_day(d: int = day, m: int = month, y: int = year) -> int:
	return clampi(d, 1, get_days_in_month(m, y))


func clamp_month(m: int = month) -> int:
	return clampi(m, 1, 12)


func clamp_year(y: int = year) -> int:
	return clampi(y, min_year, max_year)


func clamp_year_bounds(value: int) -> int:
	return clampi(value, 1000, 9999)




func _get_unix(d: int = day, m: int = month, y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict(
		{"day": clamp_day(d, m, y), "month": clamp_month(m), "year": clamp_year(y)}
		)


func _get_unix_first_day_of_year(y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": clamp_year(y), "month": 1, "day": 1})
