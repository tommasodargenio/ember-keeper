extends Node

enum DEBUG_LAYERS {ALL, NPC, VM, WALLET, GAME, MAP, PATHFINDING, LOADING}
const DEBUG := false
const DEBUG_TYPE : DEBUG_LAYERS = DEBUG_LAYERS.GAME
const GAME_NAME : String = "Ember Keeper"
const GAME_VERSION : String = "1.0.0-26.7"

# CREDITS
const CREDIT_AUTHOR = "TomDubliner"
const CREDIT_ENGINE = "Godot"
const CREDIT_ART = ["Kenney", "TheStarvingArtificer", "kalebsilva", "Other"]
const CREDIT_MUSIC = ["Starostin"]
const CREDIT_SFX = ["Freesound Community", "Gearpile"]

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
const CITY_LANTERNS_GROUP = "city_lanterns"
const WOODS_LANTERNS_GROUP = "woods_lanters"
const STARTING_TOWN_LANTERNS = 2
const STARTING_WOODS_LANTERNS = 3
const WATER_TO_USE = 10
const FUEL_TO_ORDER = 20
const FUEL_ORDER_TIMEOUT = 5.0

const DEFAULT_KEY_BINDINGS = {
	"game" : ["save", "load", "pause", "exit"],
	"player": ["player_left","player_right", "player_up", "player_down", "interact"]
}




# UI Colors and stuff
const VFX_GROUP = "vfx"
const SFX_GROUP = "sfx"
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
const PANEL_STYLEBOX = "uid://c6kciv845e2vy"
var WINDOW_TITLE_FORMAT = func(title: String): 
	return " :: %s " % title


const RESOURCES : Dictionary = {
	"Truck": "uid://dp4t8bf1kxxua",
	"WaterBucket": "uid://c2laqg6ww1g0p",
	"FuelWood": "uid://8n2mapwkgmp0",
	"FuelCoal": "uid://3rkli5loqurd",
	"EmpytEmote": "uid://dbvsihb7wxdnm",
	"EmoteArrowRight": "uid://cmgtoabevrjmc",
	"EmoteArrowLeft": "uid://mxeggk1ukhxl",
	"EmoteTear": "uid://mprm7qylmk0g",
	"EmoteTears": "uid://cftuq7sw5y53p",
	"EmoteQuestion": "uid://dnw27o1hcv4sq",
	"EmoteExclamations": "uid://d1y1n6rtkksbw" 
}

const SCENE_PATHS : Dictionary = {
	"GameOver": "uid://ddhfcdtf1dlmc",
	"Lantern": "uid://nts6xlg42gy6",
	"MainMenu": "uid://c5ogfpcb8jlb3",
	"HotBarItem" : "uid://cy717i5jy85m4",
	"FloatingIcon": "uid://baxhl45rv2b6a",
	"SaveLoadMenu": "",
	"Credits": "uid://grfv787skusj",
	"Game": "uid://c1jut3diux3vh",
	"Tutorial": "uid://d1886r0h4pbhn",
	"Settings" : "uid://dr554h7o64nh3",
	"LoadingScreen": "",
	"KeyBindings": "",
	"Pause": "uid://dbngrypwajlmq",
	"Quit": ""
}

const FX : Dictionary = {
	"Puffing": "uid://clcn45q5cyths",
}

const UI_RESOURCES : Dictionary = {
	"labelsGeneric": "uid://xm6tjqqy3waf",
	"labelTitles": "uid://dg4rysr5187ye",
	"labelTags": "uid://d3q4vhqeku4x0"
	
}

const SFX : Dictionary = {
	"pickupwater1" : "uid://cdlw01asxlcni",
	"pickupwater2" : "uid://i50kkm7qv2sw",
	"pickupwater3" : "uid://c2ta8bi4hau7i",
	"pickwood1": "uid://difmkekk6vhoy",
	"pickwood2": "uid://b7a475srji1u1",
	"placewood1": "uid://dr2qaoggu2wge",
	"placewood2": "uid://dsx70nj67scsh",
	"placewood3": "uid://sho01ub7bm43",
	"furnaceignite": "uid://i8s666iux44h",
	"sit": "uid://dqthmr57bd1in",
	"footstep_soft": "uid://dq5hymbgsnfhg",
	"footstep_stone": "uid://1qtwrnbavx2s",
	"stove_working": "uid://babbvrhqtw2ci",
	"rumble": "uid://ctjanrpn8eom4",
	"puffing": "uid://canj8wsswfqpf",
	"menuButton": "uid://bs8vicyyf87sm",
	"menuToggle": "uid://b50to6fhjtu38",
	
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
	"Restart": "restart",
	"Back":		 "",
	"SavePrefs": "",
	"Close": ""
}

const TRANSITIONS_SHADERS : Dictionary = {
	"Curtain": "uid://ox5j7ay6rlww",
	"Dissolve": "uid://dslbars51mlp3",
	"Circular": "uid://b5sjhty0emqg1",
	"Pixelated": "uid://7tobwfll2evx",
}

# UI Theming
const DEBIT_WALLET_FONT_COLOR : Color = Color(0.71, 0.199, 0.199, 1.0)
const CREDIT_WALLET_FONT_COLOR: Color = Color.WHITE
const CURRENCY_UTF_CODE: String = "1F4B5"
const INFO_UTF_CODE: String = "2139"
const WARNING_UTF_CODE: String = "26A0"
const ERROR_UTF_CODE: String = "1F6A8"
enum MESSAGE_WINDOW_FLAG {INFO, WARNING, ERROR}
