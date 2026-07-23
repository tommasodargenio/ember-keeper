extends Node

# GAME
signal game_loaded()
signal level_started()
signal map_loaded()
signal game_ready()
signal save_loaded()
signal game_saved(save_filename : String, saved_at: String, quit_on_save: bool)
signal game_options_saved()
signal game_options_loaded()
signal init_new_map()
signal game_paused()
signal game_resumed()

# Settings
signal music_toggle(status: bool)
signal music_volume(level: float)
signal sound_toggle(status: bool)
signal sound_volume(level: float)
signal main_volume(level: float)
signal auto_save(status: bool)
signal start_from_last_save(status: bool)
signal save_before_exiting(status: bool)
signal auto_save_frequency(value: int)

# PLAYER
signal player_loading_fuel(fuel: Fuel, quantity: int)
signal player_unloaded_fuel(fuel: Fuel, quantity: int)
signal player_sitting()
signal player_standing()
signal player_sat()
signal player_watering()

# FURNACE
signal active_furnace_changed(furnace: Furnace)

# UI
signal palette_changed(new_palette: String)
signal show_info_panel(showing: bool,  grid_position: Vector3i, selected_structure, is_vending_machine : bool)
signal show_resources_selector()
signal wallet_updated(current_credit: float)
signal selector_coordinates(position: Vector3)
signal population_count(total: int)
signal player_mood(mood_text: String, mood_value: float)
signal show_build_selector(showing: bool)
signal cta_outro_finished(icon_resource_path: String)
signal time_x_speed(factor: int)
signal show_message(type: Constants.MESSAGE_WINDOW_FLAG, title: String, message: String, action: String, disable_ui: bool )
signal message_window_closed(title: String)
signal show_vm_grid_view()
signal saving_data()
signal error_while_saving_data(err: Error)
signal transition_completed()
signal transition_half_completed()
signal key_binding_changed()
signal close_menu()
signal menu_loaded()
