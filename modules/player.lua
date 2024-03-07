-- player.lua
local M = {}

local player_id = nil
local opp_id = nil
M.token = ""

function M.set_id(id)
	player_id = id
end

function M.set_token(token)
	M.token = token
end
function M.get_token()
	return M.token
end

function M.get_token()
	return M.token
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


return M