extends Node


# PLAYER
signal player_loading_fuel(fuel: Fuel, quantity: int)
signal player_unloaded_fuel(fuel: Fuel, quantity: int)
signal player_sitting()
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
