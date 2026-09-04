local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- make sure you set the wezterm's definition first!
-- see https://wezterm.org/config/lua/config/term.html
config.term = "wezterm"

config.font_size = 9
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.audible_bell = "SystemBeep"

-- from kanso's wezterm extra
config.force_reverse_video_cursor = true
config.colors = {
	foreground = "#C5C9C7",
	background = "#090E13",

	cursor_bg = "#090E13",
	cursor_fg = "#C5C9C7",
	cursor_border = "#C5C9C7",

	selection_fg = "#C5C9C7",
	selection_bg = "#22262D",

	scrollbar_thumb = "#22262D",
	split = "#22262D",

	ansi = {
		"#090E13",
		"#C4746E",
		"#8A9A7B",
		"#C4B28A",
		"#8BA4B0",
		"#A292A3",
		"#8EA4A2",
		"#A4A7A4",
	},
	brights = {
		"#A4A7A4",
		"#E46876",
		"#87A987",
		"#E6C384",
		"#7FB4CA",
		"#938AA9",
		"#7AA89F",
		"#C5C9C7",
	},
	visual_bell = "#0c131a",
}

config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
	target = "BackgroundColor",
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_style = "Gnome"
config.enable_kitty_keyboard = true

config.keys = {
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

return config
