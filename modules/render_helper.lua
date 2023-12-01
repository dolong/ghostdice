local M = {}

function M.action_to_position(action)
	return vmath.vector3((M.xoffset or 0) + action.screen_x / (M.zoom_factor or 1), (M.yoffset or 0) + action.screen_y / (M.zoom_factor or 1), 0)
end


function M.register_object(instance_id, collisionobject_url)
	-- Assume the collisionobject has a box shape named "box"
	-- Adjust accordingly if it's a different shape or has a different name.
	local scale = go.get(collisionobject_url, "box.scale")
	local size = vmath.vector3(scale.x * 2, scale.y * 2, 0) -- box scale gives half extents

	-- Get the position of the game object.
	local position = go.get_position(instance_id) 

	-- Store this data by the instance_id for easy lookup.
	M.objects[instance_id] = { position = position, size = size }
end

function M.get_object(id)
	return M.objects[id]
end

return M