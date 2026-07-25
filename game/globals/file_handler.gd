@tool
class_name FileHandler extends Node

enum STORE_TYPE {JSON, BINARY}
enum STORE_MODE {ENCRYPTED, PLAIN}

static func store_file(data: Dictionary, file_path: String, create_dir: bool = true, type : STORE_TYPE = STORE_TYPE.BINARY, mode: STORE_MODE = STORE_MODE.ENCRYPTED) -> Error:
	var result : Array = _open_file_for_write(file_path, create_dir, mode)
	var err: Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
		
	match type:
		STORE_TYPE.JSON:
			if mode == STORE_MODE.PLAIN:
				file.store_string(JSON.stringify(data))
			else:
				file.store_var(data, false)
		STORE_TYPE.BINARY:
			file.store_var(data, false)
		
	file.close()
	return OK

static func load_file(file_path: String, out_data: Dictionary, type : STORE_TYPE = STORE_TYPE.BINARY, mode: STORE_MODE = STORE_MODE.ENCRYPTED) -> Error:
	out_data.clear()
	
	var result: Array = _open_file_for_read(file_path, mode)
	var err: Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
	
	var extrated_data : Variant
	
	match type:
		STORE_TYPE.JSON:
			if mode == STORE_MODE.ENCRYPTED:
				extrated_data = file.get_var(false)
			else:
				var json_string : String = file.get_as_text()
				var json_extracted : Array = _extract_json_data(json_string)
				err = json_extracted[0] as Error
				extrated_data = json_extracted[1] as Variant
		STORE_TYPE.BINARY:
			extrated_data = file.get_var(false)
	
	file.close()
	
	out_data.merge(extrated_data as Dictionary, true)
	
	return OK

static func _extract_json_data(json_string: String) -> Array:
	var json : JSON = JSON.new()
	var err = json.parse(json_string)
	
	if err != OK:
		return [err, null]
	
	var json_data: Variant = json.get_data()
	if typeof(json_data) != TYPE_DICTIONARY:
		return [ERR_INVALID_DATA, null]
	
	return [OK, json_data]

static func _open_file_for_read(file_path: String, mode: STORE_MODE) -> Array:
	if not FileAccess.file_exists(file_path):
		return [ERR_FILE_NOT_FOUND, null]
		
	var file: FileAccess
	var key := Utility.make_aes_key(Constants.ENCRYPTION_KEY)
	match mode:
		STORE_MODE.PLAIN: file = FileAccess.open(file_path, FileAccess.READ)
		STORE_MODE.ENCRYPTED: file = FileAccess.open_encrypted(file_path, FileAccess.READ, key)

	if file == null:
		return [FileAccess.get_open_error(), null]
	
	return [OK, file]
	
	
static func _open_file_for_write(file_path: String, create_dir: bool, mode: STORE_MODE) -> Array:
	var err: Error = _check_and_create_directory(file_path, create_dir)
	if err != OK:
		return [err, null]
	
	var file: FileAccess
	var key :=  Utility.make_aes_key(Constants.ENCRYPTION_KEY)
	match mode:
		STORE_MODE.PLAIN: file = FileAccess.open(file_path, FileAccess.WRITE)
		STORE_MODE.ENCRYPTED: file = FileAccess.open_encrypted(file_path, FileAccess.WRITE, key)
	if file == null:
		return [FileAccess.get_open_error(), null]
	
	return [OK, file]

static func _check_and_create_directory(file_path: String, create_dir: bool) -> Error:
	var dir_path: String = file_path.get_base_dir()
	if DirAccess.dir_exists_absolute(dir_path):
		return OK
	if not create_dir:
		return ERR_CANT_CREATE
	return DirAccess.make_dir_recursive_absolute(dir_path)
