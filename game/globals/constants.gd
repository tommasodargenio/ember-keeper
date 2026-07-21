extends Node

enum DEBUG_LAYERS {ALL, NPC, VM, WALLET, GAME, MAP, PATHFINDING}

const DEBUG := true
const DEBUG_TYPE : DEBUG_LAYERS = DEBUG_LAYERS.GAME
const GAME_NAME : String = "Ember Keeper"
const GAME_VERSION : String = "0.1.0-26.7"

# SAVE MANAGER
const MAX_AUTOSAVE_SLOTS : int = 3
const ENCRYPTION_KEY : String = "U(CTna;}3vK<m$+:drj;"
const SAVE_ENCRYPTED: bool = false
const SAVE_PERSIST_NODE_GROUP: String = "state_persist"
const AUTO_SAVE_DIRECTORY_NAME : String = "autosave"
const SESSION_SAVE_DIRECTORY_NAME : String = "last_session"
const SAVE_BASE_DIR := "user://saves"
const SAVE_FILE_BINARY: String = "udata.save" 
const SAVE_FILE_CLEAR : String = "udata.json"
const SAVE_PREFERENCES_FILE : String = "prefs.json"

# Game play
const LANTERNS_GROUP = "lanterns"	
	
const DEFAULT_KEY_BINDINGS = {
	"camera" : ["camera_back", "camera_forward", "camera_right", "camera_left", "camera_rotate", "camera_center", "zoom_in", "zoom_out"],
	"debug" : ["telemetry", "debug", "debug_panel", "clear_npcs", "spawn_npc", "load_resources", "test_fx", "rotate_tex_back", "rotate_tex"],
	"building" : ["building_mode", "resouce_selector", "structure_previous", "structure_next", "demolish", "rotate", "build"],
	"game" : ["save", "load", "generate_city_map", "regenerate_random_map"],
	"vending_machines": ["show_vm_grid_view","fix_vm", "restock_vm", "collect_money_from_vm"]
}




# UI Colors and stuff
const GAME_PALETTE = "amber"
const DIALOG_HIGHLIGHT_BORDER_DRAGGING = Color.AQUA
const DIALOG_HIGHLIGHT_BORDER_NORMAL = Color.DARK_CYAN
const BUTTON_STYLEBOX : Dictionary = {
	"hover": "uid://cbfhaxmikkffj",
	"normal": "uid://dl8mh7h4onvrm",
	"pressed": "uid://d3b1wm0mqnmnw",
	"disabled": "",
	"focus": ""
}
var WINDOW_TITLE_FORMAT = func(title: String): 
	return " :: %s " % title


const SCENE_PATHS : Dictionary = {
	"GameOver": "",
	"MainMenu": "uid://c5ogfpcb8jlb3",
	"SaveLoadMenu": "",
	"Credits": "",
	"Game": "",
	"Tutorial": "",
	"Settings" : "",
	"LoadingScreen": "",
	"KeyBindings": "",
	"Pause": "",
	"Quit": ""
}

const UI_RESOURCES : Dictionary = {
	"labelsGeneric": "uid://xm6tjqqy3waf",
	"labelTitles": "uid://dg4rysr5187ye",
	"labelTags": "uid://d3q4vhqeku4x0"
	
}

# UI Menu
const LOGO_CAROUSEL : Array = [
	"uid://1jggt8dgk5i3",
	"uid://0p8gtdmtkg8i"
]

const MENU_ACTIONS: Dictionary = {
	"None":      "",
	"Quit":      "quit",
	"Pause":     "pause",
	"Resume":    "resume",
	"SaveAndQuit": "savequit",
	"Back":		 "",
	"SavePrefs": "",
	"Close": ""
}

const TRANSITIONS_SHADERS : Dictionary = {
	"Curtain": "",
	"Dissolve": "",
	"Circular": "",
	"Pixelated": "",
}

# UI Theming
const DEBIT_WALLET_FONT_COLOR : Color = Color(0.71, 0.199, 0.199, 1.0)
const CREDIT_WALLET_FONT_COLOR: Color = Color.WHITE
const CURRENCY_UTF_CODE: String = "1F4B5"
const INFO_UTF_CODE: String = "2139"
const WARNING_UTF_CODE: String = "26A0"
const ERROR_UTF_CODE: String = "1F6A8"
enum MESSAGE_WINDOW_FLAG {INFO, WARNING, ERROR}
