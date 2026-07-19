extends Node

# For usernames, identifiers — things that could be spoofed
func is_safe_identifier(text: String) -> bool:
	var ts = TextServerManager.get_primary_interface()
	if not ts.has_feature(TextServer.FEATURE_UNICODE_SECURITY):
		push_warning("UnicodeSecurity not supported.")
		return true
	return not ts.spoof_check(text)

# For display messages, labels — just block control characters
func is_safe_input(text: String) -> bool:
	if text.is_empty():
		return false
	for i in text.length():
		var c = text.unicode_at(i)
		if c < 32 and c != 9 and c != 10:
			return false
	return true

func get_file_as_string_by_uid(uid_string: String) -> String:
	var uid = ResourceUID.text_to_id(uid_string)
	if uid == ResourceUID.INVALID_ID:
		push_error("Invalid UID: " + uid_string)
		return ""

	var path = ResourceUID.get_id_path(uid)
	if path.is_empty():
		push_error("No path found for UID: " + uid_string)
		return ""

	return FileAccess.get_file_as_string(path)

func seconds_to_time(total_seconds: float, seconds_on: bool = true) -> String:
	#total_seconds = 12345
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hours:  int   =  int(total_seconds / 3600.0)
	
	var hhmmss_string:String = "%02d:%02d" % [hours, minutes]
	if seconds_on:
		hhmmss_string += ":%05.2f" % seconds
	
	return hhmmss_string
	
func format_number(number, thousands_sep: String = ".", decimal_sep: String = ",", force_decimals: bool = false, decimal_places: int = 2) -> String:
	# Split into integer and decimal parts
	var int_part: String
	var dec_part: String = ""
	
	if number is float:
		# Use snapped to avoid floating point noise, then format
		var factor = pow(10, decimal_places)
		var rounded = snapped(number, 1.0 / factor)
		var parts = ("%.{}f".format([decimal_places]) % rounded).split(".")
		int_part = parts[0]
		dec_part = parts[1] if parts.size() > 1 else ""
	else:
		int_part = str(int(number))
	
	# Handle negative numbers
	var negative = int_part.begins_with("-")
	if negative:
		int_part = int_part.substr(1)
	
	# Insert thousands separators
	var result = ""
	var count = 0
	for i in range(int_part.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = thousands_sep + result
		result = int_part[i] + result
		count += 1
	
	if negative:
		result = "-" + result
	
	# Append decimal part
	if number is float:
		result = result + decimal_sep + dec_part
	elif force_decimals:
		result = result + decimal_sep + "0".repeat(decimal_places)
	
	return result	

func format_currency(value: float) -> String:
	var parts := ("%0.2f" % abs(value)).split(".")
	var int_part := parts[0]
	var dec_part := parts[1]
	
	var result := ""
	var count  := 0
	var value_sign := "-" if value < 0 else ""
	
	for i in range(int_part.length() -1, -1, -1):
		result = int_part[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	
	return value_sign + result + "." + dec_part

func get_date_with_month(short: bool = true, eu: bool = false, year: bool = true, randomized : bool = false) -> String:
	var short_months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var long_months = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	var res = ""
	var date = {}
	
	if randomized:
		randomize()
		date = {"day": randi_range(1,28), "month": randi_range(1,12), "year": randi_range(1200, 2100)}
	else:
		date = Time.get_date_dict_from_system()
	var month = ""
	if short:
		month = short_months[date["month"]]
	else:
		month = long_months[date["month"]]
			
	if eu:
		res = "%02d %s%s" % [date["day"], month, " " + str(date["year"]) if year else ""]
	else:
		res = "%s %02d%s" % [month, date["day"], ", " + str(date["year"]) if year else ""] 
	
	return res

func get_time(ampm: bool = true, seconds : bool = true, randomized : bool = false) -> String:
	var time
	if randomized:
		randomize()
		time = {"hour": randi_range(1, 24), "minute": randi_range(0, 59), "second": randi_range(0, 59)}
	else:
		time = Time.get_time_dict_from_system()
	var hour = time["hour"]
	var ampm_s = ""
	if ampm:
		if hour > 12:
			hour -= 12
			ampm_s = "PM"
		else:
			ampm_s = "AM"
	var res = ""
	if seconds:
		res = "%02d:%02d:%02d %s" % [hour, time["minute"], time["second"], ampm_s]
	else:
		res = "%02d:%02d %s" % [hour, time["minute"], ampm_s]

	return res
	
func compute_hash(data: PackedByteArray, salt: String = "my_secret_salt") -> String:
	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(data)
	hasher.update(salt.to_utf8_buffer())
	return hasher.finish().hex_encode()

func make_aes_key(key_str: String) -> PackedByteArray:
	var key = key_str.to_utf8_buffer()
	
	if key.size() < 32:
		key.resize(32)
	elif key.size() > 32:
		key = key.slice(0, 32)
		
	return key	
	
func logger(layer : Constants.DEBUG_LAYERS, msg) -> void:
	if not Constants.DEBUG: return
	if layer == Constants.DEBUG_TYPE or Constants.DEBUG_TYPE == Constants.DEBUG_LAYERS.ALL:
		print(msg)
		
func get_next_autosave_index() -> int:
	if not DirAccess.dir_exists_absolute(Constants.SAVE_BASE_DIR): return -1
	
	var autosave_dir = Constants.SAVE_BASE_DIR.path_join(Constants.AUTO_SAVE_DIRECTORY_NAME + "_1")
	
	if not DirAccess.dir_exists_absolute(autosave_dir): return 1
	
	var saves = DirAccess.open(Constants.SAVE_BASE_DIR)
	var highest := 0
	var oldest := Time.get_unix_time_from_system()
	var autosaves_count := 0

	saves.list_dir_begin()
	var entry = saves.get_next()
	while entry != "":
		if saves.current_is_dir() and entry.begins_with(Constants.AUTO_SAVE_DIRECTORY_NAME):
			var index_str = entry.trim_prefix(Constants.AUTO_SAVE_DIRECTORY_NAME + "_")
			if index_str.is_valid_int():
				autosaves_count += 1
				var modified_timestamp := 0
				var slot_path = Constants.SAVE_BASE_DIR.path_join(entry)
				var save_file = slot_path.path_join(Constants.SAVE_FILE_BINARY if Constants.SAVE_ENCRYPTED else Constants.SAVE_FILE_CLEAR)
				if FileAccess.file_exists(save_file):
					modified_timestamp = FileAccess.get_modified_time(save_file)
				
				oldest = min(oldest, modified_timestamp)
				
				if oldest == modified_timestamp:
					highest = max(highest, index_str.to_int())
		entry = saves.get_next()
		
	saves.list_dir_end()
	
	if autosaves_count < Constants.MAX_AUTOSAVE_SLOTS:
		highest +=1
	
	return highest
