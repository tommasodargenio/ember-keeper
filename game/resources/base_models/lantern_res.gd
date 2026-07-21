class_name Lantern extends Resource

enum lantern_state {LIT, UNLIT}

@export var name : String = ""
@export var description : String = ""

@export var energy_required : int = 0
@export var state : lantern_state = lantern_state.UNLIT
