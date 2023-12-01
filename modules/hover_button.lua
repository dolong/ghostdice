-- Copyright (c) 2021 Maksim Tuprikov <insality@gmail.com>. This code is licensed under MIT license

local M = {}


M["button"] = {
	LONGTAP_TIME = 0.4,
	DOUBLETAP_TIME = 0.4,

	HOVER_MOUSE_IMAGE = "dice_indents",
	DEFAULT_IMAGE = "invis_indent",
	HOVER_IMAGE = "dice_indents",

	on_hover = function(self, node, state)
		local anim = state and M.button.HOVER_IMAGE or M.button.DEFAULT_IMAGE
		gui.play_flipbook(node, anim)
	end,

	on_mouse_hover = function(self, node, state)
		local anim = state and M.button.HOVER_MOUSE_IMAGE or M.button.DEFAULT_IMAGE
		gui.play_flipbook(node, anim)
	end
}


return M
