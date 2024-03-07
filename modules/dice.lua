local M = {}

M.player_1_lane1 = {}
M.player_1_lane2 = {}
M.player_1_lane3 = {}
M.player_2_lane1 = {}
M.player_2_lane2 = {}
M.player_2_lane3 = {}
M.turnCount = 1
M.opponentPlayedCards = {} 
M.lastDiceRoll = 0 
M.dicePlaced = true 
M.aiRolled = false 
M.poof = false

function M.getWinner()
	local scorePlayer1 = 0
	local scorePlayer2 = 0

	-- Calculate scores for each lane for both players
	for lane = 1, 3 do
		scorePlayer1 = scorePlayer1 + M.calculate_lane_score(1, lane)
		scorePlayer2 = scorePlayer2 + M.calculate_lane_score(2, lane)
	end

	-- Determine the winner
	if scorePlayer1 > scorePlayer2 then
		return 1 -- Player 1 wins
	elseif scorePlayer2 > scorePlayer1 then
		return 2 -- Player 2 wins
	else
		return 0 -- It's a tie
	end
end

function M.getWinnerDifference()
	local scorePlayer1 = 0
	local scorePlayer2 = 0

	-- Calculate scores for each lane for both players
	for lane = 1, 3 do
		scorePlayer1 = scorePlayer1 + M.calculate_lane_score(1, lane)
		scorePlayer2 = scorePlayer2 + M.calculate_lane_score(2, lane)
	end
	-- Determine the winner
	if scorePlayer1 > scorePlayer2 then
		return scorePlayer1 - scorePlayer2 -- Player 1 wins
	elseif scorePlayer2 > scorePlayer1 then
		return scorePlayer2 - scorePlayer1 -- Player 2 wins
	else
		return 0 -- It's a tie
	end
end

function M.calculate_lane_score(playerNumber, lane)
	local table_name = "player_" .. playerNumber .. "_lane" .. lane
	local lane_array = M[table_name]

	if not lane_array then
		print("Invalid lane: " .. table_name)
		return 0
	end

	-- Count occurrences of each dice number
	local counts = {}
	for _, diceNumber in ipairs(lane_array) do
		counts[diceNumber] = (counts[diceNumber] or 0) + 1
	end

	-- Calculate score
	local score = 0
	for diceNumber, count in pairs(counts) do
		if count > 1 then
			-- For duplicates: Add the sum of the number multiplied by the count
			score = score + (diceNumber * count * count)
		else
			-- For non-duplicates: Just add the number
			score = score + diceNumber
		end
	end

	return score
end


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
		else
			print("Invalid table name: " .. table_name)
		end
	else
		print("Dice placement not allowed. dicePlaced flag is true.")
	end
end

function M.is_lane_full(playerNumber, lane)
	-- Construct the table name dynamically
	local table_name = "player_" .. playerNumber .. "_lane" .. lane

	-- Check if the lane exists and its length
	if M[table_name] and #M[table_name] < 3 then
		return false -- Lane is not full
	else
		return true -- Lane is full or does not exist
	end
end

function M.are_all_lanes_full(playerNumber)
	for lane = 1, 3 do
		if not M.is_lane_full(playerNumber, lane) then
			return false -- One of the lanes is not full
		end
	end
	return true -- All lanes are full
end


function M.nextTurn()
	M.turnCount = M.turnCount + 1
end

function M.getTurn()
	return M.turnCount
end


function M.aiRoll()
	M.aiRolled = true
end

function M.personRoll()
	M.aiRolled = false
end

function M.getTurn()
	return M.turnCount
end

function M.getCurrentPlayer()
	-- If turnCount is odd, it's player 1's turn, if even, it's player 2's turn
	-- This assumes player 1 starts on turn 1 (which is odd)
	if M.turnCount % 2 == 1 then
		return 1 -- Player 1's turn
	else
		return 2 -- Player 2's turn
	end
end

function M.update_score_labels(playerNumber)
	local totalScore = 0

	for lane = 1, 3 do
		local score = M.calculate_lane_score(playerNumber, lane)
		totalScore = totalScore + score

		-- Send a message to update individual lane scores
		msg.post("/locations#locations", "update_score_label", {playerNumber = playerNumber, lane = lane, score = score})
	end

	-- Send a message with the total score
	msg.post("/locations#locations", "update_total_player_score", {playerNumber = playerNumber, totalScore = totalScore})
end

function M.setVisual(playerNumber, lane)
	-- Define the base square IDs for each player's lanes
	local baseSquareId = {
		[1] = {lane1 = "00", lane2 = "01", lane3 = "02"},
		[2] = {lane1 = "00", lane2 = "01", lane3 = "02"}
	}
	local tableName = "player_" .. playerNumber .. "_lane" .. lane

	for i = 1, 3 do
		local baseId = baseSquareId[playerNumber]["lane" .. lane]
		if baseId then
			local row = tonumber(baseId:sub(1, 1)) + (i - 1)
			local column = baseId:sub(2, 2)
			local adjustedSquareId = string.format("%01d%s", row, column)
			local imageName

			-- Check if there is a dice at this position
			if i <= #M[tableName] then
				imageName = "dice_faces_" .. M[tableName][i]
			else
				imageName = "dice_blank" -- Set to blank if no dice
			end

			-- Update the visual
			local grid_id = (playerNumber == 1) and "/squares#grid" or "/squares1#grid"
			msg.post(grid_id, "set_image", {image = imageName, square = adjustedSquareId, player = playerNumber})			
		end
	end
	
	M.update_score_labels(playerNumber)
end
function M.play_poof_sound()
	if (M.poof) then
		msg.post("/sounds#poof", "play_sound", {gain = 1.0})
		M.poof = false
	end
end
function M.setDice(diceNumber)
	M.lastDiceRoll = diceNumber 
	M.dicePlaced = false
end

function M.getDiceRoll()
	return M.lastDiceRoll
end

--This first calls add_dice_to_lane, then 
--check_duplicate_in_opponent_player, then 
--remove_dicenumber_from_lane to remove dice from your opponent's lane if matches
function M.place_dice_to_lane(playerNumber, diceNumber, lane)
	-- Step 1: Add dice to the player's lane
	M.add_dice_to_lane(playerNumber, diceNumber, lane)

	M.setVisual(playerNumber, lane)	
	

	M.dicePlaced = true
end

function M.check_duplicates_and_destroy(playerNumber, diceNumber, lane)
	-- Step 2: Check for duplicate dice number in the opponent's same lane
	local duplicate_found = M.check_duplicate_in_opponent_player(playerNumber, diceNumber, lane)

	-- Step 3: If duplicate is found, remove the dice number from the opponent's lane
	if duplicate_found then
		-- Determine the opponent's player number
		local opponentNumber = (playerNumber == 1) and 2 or 1

		-- Remove the dice number from the opponent's lane
		M.remove_dicenumber_from_lane(opponentNumber, diceNumber, lane)
	end

end

--Checks to see if there exist another dice of the same number in the opponents same lane.
function M.check_duplicate_in_opponent_player(playerNumber, diceNumber, lane)
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

function M.array_to_string(array)
	local str = "["
	for i, value in ipairs(array) do
		str = str .. value
		if i < #array then
			str = str .. ","
		end
	end
	str = str .. "]"
	return str
end

function M.get_player_lanes_as_string(playerNumber)
	local lanes = M.get_player_lanes(playerNumber)
	local laneStrings = {}

	for _, lane in ipairs(lanes) do
		table.insert(laneStrings, M.array_to_string(lane))
	end

	return "[" .. table.concat(laneStrings, ", ") .. "]"
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

function M.get_status_as_string()
	-- Get the lane status for both players and convert them to strings
	local player1_lanes = M.get_player_lanes(1)
	local player1_lanes_str = "[" .. table.concat(M.map_to_string_array(player1_lanes, M.array_to_string), ", ") .. "]"

	local player2_lanes = M.get_player_lanes(2)
	local player2_lanes_str = "[" .. table.concat(M.map_to_string_array(player2_lanes, M.array_to_string), ", ") .. "]"

	-- Combine both players' lane statuses into one string
	return "{'player_1': " .. player1_lanes_str .. ", 'player_2': " .. player2_lanes_str .. "}"
end

function M.get_status_as_readable_string()
	-- Initialize an empty string to build the status
	local status_str = ""

	-- Process each player
	for player_number = 1, 2 do
		-- Add the player's board heading
		status_str = status_str .. "Player " .. player_number .. "’s board: "

		-- Get the lanes for the current player
		local lanes = M.get_player_lanes(player_number)

		-- Iterate through each lane and append its status
		for lane_number, lane in ipairs(lanes) do
			local lane_str = "Lane " .. lane_number .. ": [" .. table.concat(lane, ", ") .. "], "
			status_str = status_str .. lane_str
		end

		-- Add an extra newline for spacing between players, if it's the first player
		if player_number == 1 then
			status_str = status_str .. "\n"
		end
	end

	return status_str
end



-- Helper function to apply a function (func) to each element of an array (array) and return a new array
function M.map_to_string_array(array, func)
	local new_array = {}
	for _, value in ipairs(array) do
		table.insert(new_array, func(value))
	end
	return new_array
end
function M.remove_dicenumber_from_lane(playerNumber, diceNumber, lane)
	local table_name = "player_" .. playerNumber .. "_lane" .. lane

	-- Check if the lane table exists
	if M[table_name] then
		-- Loop backward through the lane
		for i = #M[table_name], 1, -1 do
			if M[table_name][i] == diceNumber then
				-- Remove the dice number
				table.remove(M[table_name], i)
				-- Continue the loop to find more instances of the dice number
			end
		end
		-- Update the visual for the entire lane
		M.setVisual(playerNumber, lane)
	else
		print("Invalid lane: " .. table_name)
	end
end



return M