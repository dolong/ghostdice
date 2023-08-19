-- player.lua
local M = {}
local cardModule = require "modules.card"

local player_id = nil
local opp_id = nil
local energy = 0
local turn = 0

function M.set_id(id)
	player_id = id
end

function M.get_id()
	return player_id
end

function M.set_oppId(id)
	opp_id = id
end

function M.get_oppId()
	return opp_id
end

function M.check_drop_requirements(droppedCardCost)
	if (droppedCardCost <= energy) then
		return true
	else 
		return false
	end
end

function M.get_energy()
	return energy
end

function M.set_energy(num)
	energy = num
end

function M.get_turn()
	return turn
end

function M.set_turn(num)
	turn = num
end

-- Potentially other player-related functions here

return M