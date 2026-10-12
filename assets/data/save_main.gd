extends SaveBase
class_name SaveMain

@export var current_acc: StringName = ""
var accounts: Dictionary[StringName, Account] = {}

static var accs_path: String = "user://save/accounts/"

func switch_account(acc: StringName):
	current_acc = acc
	var account: = accounts[acc] as Account

func login_into_current_account():
	var acc: = self.accounts[current_acc] as Account
	acc.log_in()

func get_current_account() -> Account:
	if not accounts.has(current_acc): return null
	return accounts[current_acc]

func login_used(l: String):
	for key in self.accounts.keys():
		var login: String = key.split(":")[0]
		if login == l: return true
	return false

func create_account(name: StringName, login: StringName, password: StringName):
	var acc: = Account.new()
	acc.name = name

	acc.add_tank("t1_cunningham", true)
	acc.add_tank("ltraktor", true)
	acc.add_tank("gb01_medium_mark_i", true)
	acc.add_tank("ms-1", true)

	acc.login = login
	acc.password = password

	accounts[login + ":" + password] = acc
	save_account(acc)

func save(path: StringName, save_path: StringName = ""):
	super.save(path, save_path)
	for key in accounts.keys():
		save_account(accounts[key])

func save_account(acc: Account):
	acc.save(accs_path + acc.name + ".tres", accs_path)

func load_accounts_encrypted():
	print("SaveMain: begin loading encrypted accounts")
	for path in Util.get_files_from_folder(accs_path, ["account"]):
		var res: Resource = Util.load_resource_encrypted(path)
		if res and res is Account:
			accounts[res.login + ":" + res.password] = res
		else:
			printerr("SaveMain: Failed to load encrypted resource! path: " + path)

	print("SaveMain: finished loading accounts")
	print()
func load_accounts():
	print("SaveMain: begin loading accounts")
	for res in Util.load_resources_from_folder(accs_path):
		if res is Account:
			accounts[res.login + ":" + res.password] = res
		else:
			printerr("SaveMain: Non-account resource detected in accounts folder!")
	print("SaveMain: total accounts:")
	for key in accounts.keys():
		print("\t" + accounts[key].name)
	print("SaveMain: finished loading accounts")
	print()
