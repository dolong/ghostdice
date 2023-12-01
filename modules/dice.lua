local M = {}

M.player_1_lane1 = {}
M.player_1_lane2 = {}
M.player_1_lane3 = {}
M.player_2_lane1 = {}
M.player_2_lane2 = {}
M.player_2_lane3 = {}
M.opponentPlayedCards = {} 
M.lastDiceRoll = 0 
M.dicePlaced = true 

function M.add_dice_to_lane(playerNumber, diceNumber, lane)
	-- Check if a dice can be placed
	if M.dicePlaced == false then
		
		-- Construct the table name dynamically
		local table_name = "player_" .. playerNumber .. "_lane" .. lane

		-- Check if the table exists
		if M[table_name] then
			-- Insert the dice number into the appropriate table
			table.insert(M[table_name], diceNumber)
			print ("Placed ", diceNumber, " to lane ", lane)
			-- call setVisualHere	
			M.setVisual(playerNumber, lane)		
		else
			print("Invalid table name: " .. table_name)
		end
	else
		print("Dice placement not allowed. dicePlaced flag is true.")
	end
end


function M.setVisual(playerNumber, lane)
	-- Define the base square IDs for each player's lanes
	local baseSquareId = {
		[1] = {lane1 = "00", lane2 = "01", lane3 = "02"},
		[2] = {lane1 = "20", lane2 = "21", lane3 = "22"}
	}

	-- Construct the table name dynamically
	local tableName = "player_" .. playerNumber .. "_lane" .. lane

	-- Check if the lane exists and has dice
	if M[tableName] then
		-- Loop through the dice in the lane (up to 3 dice)
		for i, diceNumber in ipairs(M[tableName]) do
			-- Calculate the square ID based on the base ID and index
			local baseId = baseSquareId[playerNumber]["lane" .. lane]
			if baseId then
				local row = tonumber(baseId:sub(1, 1)) + (i - 1)
				local column = baseId:sub(2, 2)
				local adjustedSquareId = string.format("%01d%s", row, column)

				-- Construct the image name for the dice face
				local imageName = "dice_faces_" .. diceNumber

				-- Send a message to the grid script to update the visual
				msg.post("/squares#grid", "set_image", {image = imageName, square = adjustedSquareId})
			end
		end
	else
		print("Invalid lane: " .. tableName)
	end
end

function M.setDice(diceNumber)
	M.lastDiceRoll = diceNumber 
	M.dicePlaced = false
end

function M.getDiceRoll(diceNumber)
	return M.lastDiceRoll
end

--This first calls add_dice_to_lane, then 
--check_duplicate_in_opponent_player, then 
--remove_dicenumber_from_lane to remove dice from your opponent's lane if matches
function M.place_dice_to_lane(playerNumber, diceNumber, lane)
	-- Step 1: Add dice to the player's lane
	M.add_dice_to_lane(playerNumber, diceNumber, lane)

	-- Step 2: Check for duplicate dice number in the opponent's same lane
	local duplicate_found = check_duplicate_in_opponent_player(playerNumber, diceNumber, lane)

	-- Step 3: If duplicate is found, remove the dice number from the opponent's lane
	if duplicate_found then
		-- Determine the opponent's player number
		local opponentNumber = (playerNumber == 1) and 2 or 1

		-- Remove the dice number from the opponent's lane
		M.remove_dicenumber_from_lane(opponentNumber, diceNumber, lane)
	end

	M.dicePlaced = true
end

--Checks to see if there exist another dice of the same number in the opponents same lane.
function check_duplicate_in_opponent_player(playerNumber, diceNumber, lane)
	-- Determine the opponent's player number
	local opponentNumber = (playerNumber == 1) and 2 or 1

	-- Construct the table name for the opponent's lane dynamically
	local table_name = "player_" .. opponentNumber .. "_lane" .. lane

	-- Check if the table exists and search for the dice number
	local duplicate_found = false
	if M[table_name] then
		for i, number in ipairs(M[table_name]) do
			if number == diceNumber then
				duplicate_found = true
				break
			end
		end
	end

	return duplicate_found
end


function M.get_player_lanes(playerNumber)
	-- Initialize an empty return array
	local returnArray = {}

	-- Loop through each lane for the given player
	for lane = 1, 3 do
		-- Construct the table name dynamically
		local table_name = "player_" .. playerNumber .. "_lane" .. lane

		-- Check if the table exists
		if M[table_name] then
			-- Insert the contents of the lane into the return array
			table.insert(returnArray, M[table_name])
		else
			-- Insert an empty table if the lane does not exist
			table.insert(returnArray, {})
		end
	end

	return returnArray
end

function M.get_player_single_lane(playerNumber, laneNumber)
	-- Construct the table name dynamically
	local table_name = "player_" .. playerNumber .. "_lane" .. laneNumber

	-- Check if the table exists
	if M[table_name] then
		-- Return the contents of the lane
		return M[table_name]
	else
		-- Return an empty table if the lane does not exist
		return {}
	end
end

function M.get_status()
	-- Initialize an empty table for the status
	local status = {}

	-- Get the lane status for both players
	status.player_1 = M.get_player_lanes(1)
	status.player_2 = M.get_player_lanes(2)

	return status
end

function M.remove_dicenumber_from_lane(playerNumber, diceNumber, lane)
	-- Construct the table name dynamically
	local table_name = "player_" .. playerNumber .. "_lane" .. lane

	-- Check if the table exists
	if M[table_name] then
		-- Loop through the dice numbers in the lane
		for i = #M[table_name], 1, -1 do
			if M[table_name][i] == diceNumber then
				-- Remove the dice number if it matches
				table.remove(M[table_name], i)
				-- Assuming you want to remove all instances of this dice number
				-- If you only want to remove the first instance, break the loop here
				-- break
			end
		end
	else
		print("Invalid lane: " .. table_name)
	end
end



return M