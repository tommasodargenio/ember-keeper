class_name LD extends RefCounted

#region system messages
#SAVE LOAD MENU
static var SAVE_OPERATION_MODE_TITLE = "...or select a session to save to"
static var LOAD_OPERATION_MODE_TITLE = "Select a session to load"
static var SAVE_MENU_TITLE = "Save"
static var LOAD_MENU_TITLE = "Load"
static var ERROR_SAVING_NAME_MISSING = "Please type a new name for your game or select one of the slots below to overwrite"
static var ERROR_SAVING_NAME_MALFORMED = "The game name you have entered contains illegal words or characters, use only letters from A to Z, numbers from 0 to 9, or the symbols -+_"
#endregion

## GAME ZONE
#region game messages
#INTRO
static var INTRO_ARTICLE_1 = "[color=black]NEW HEXLOU[/color] — With the season's longest night nearly upon us, the town council has appointed a new [color=darkred]Ember Keeper[/color] to tend the old furnace beneath the hall and keep the [color=dark_goldenrod]lantern-road[/color] lit till dawn."
static var INTRO_ARTICLE_2 = "The duties are [color=green]simple[/color], the [color=navy_blue]council insists[/color], if not easy.[br][br] [color=sienna]Feed the furnace[/color] — but not too eagerly, as an overfed [color=firebrick]flame[/color] runs hot and turns [color=red]dangerous[/color].[br][br] Watch the [color=dark_green]pressure gauge[/color] closely, and keep a bucket of [color=aqua]water[/color] near at hand should the old iron start to spit and flare.[br][br] Every [color=dark_goldenrod]lantern[/color] kept burning is a traveler kept safe; [br][br]let too many go [color=black]dark[/color] for too long, and word of trouble will not be long in following."
static var INTRO_ARTICLE_3 = "The [color=navy_blue]council[/color] reminds the new [color=darkred]Keeper[/color] that the town's [color=deep_pink]spirits[/color] — and its patience — will rise and fall with the light.[br][br] Dawn, the almanac assures us, is still some hours off."
static var INTRO_ARTICLE_4 = "We wish the [color=darkred]Keeper[/color] a quiet watch.[br][hr][br][color=dark_green]ALMANAC TODAY[/color][br][color=darkred]Sunset: [/color] %s[br][color=dark_violet]Sunrise: [/color] %s[br]" % [GameClock._get_sunset_time(), GameClock._get_sunrise_time()]
static var INTRO_ARTICLE : Array = [INTRO_ARTICLE_1, INTRO_ARTICLE_2, INTRO_ARTICLE_3, INTRO_ARTICLE_4]
# FUEL
static var FUEL_RESTOCKED = "We just got a new shipment of fuel boss!"
static var FUEL_EMPTY = "Crickets!. Order more boss!"
#FURNACE
static var FURNACE_NOT_FUEL = "Not sure what you are carrying but this ain't fuel!!"
static var FURNACE_WRONG_FUEL = "You can't load %s into this furnace which only accepts %s"
static var FURNACE_FULL = "Furnace at max capacity, can't load"
static var FURNACE_FUEL_LOADED = "Loaded %s, furnace is now full — %s still in hand"
static var FURNACE_BURNING_FUEL = "We are burning baby, current load %s"
static var FURNACE_PUFFING = "The furnace is exploding, use some water!"
static var FURNACE_UNPUFFING = "Pfff - Disaster adverted!"
#PLAYER
static var PLAYER_EMPTY_HANDED = "You have nothing to load"
static var PLAYER_DRY = "You don't have any water on you!"
#WATER
static var WATER_BUCKET_EMPTY = "Not enough water in this bucket"
#endregion
