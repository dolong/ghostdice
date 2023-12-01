local M = {}

M.deck = {}
M.hand = {}
M.cards = {} 
M.opponentDeck = {} 
M.opponentHand = {} 
M.opponentPlayedCards = {} -- So far this is opponents Played Cards
M.opponentHandSize = 0 -- TODO: Utilize this

function formatNewlines(str, maxLineLength)
	local result = ""
	local lineStart = 1
	local strLength = string.len(str)

	while lineStart <= strLength do
		local lineEnd = lineStart + maxLineLength - 1
		if lineEnd >= strLength then
			-- Add the rest of the string if it's shorter than maxLineLength
			result = result .. string.sub(str, lineStart, strLength)
			break
		else
			-- Find the last space in the substring
			local spacePos = lineEnd
			while spacePos >= lineStart and string.sub(str, spacePos, spacePos) ~= " " do
				spacePos = spacePos - 1
			end
			if spacePos < lineStart then
				-- No spaces found, have to break a word
				spacePos = lineEnd
			end
			-- Add the substring from lineStart to the last space
			result = result .. string.sub(str, lineStart, spacePos)
			-- If not at the end of the string, add a newline
			if spacePos < strLength then
				result = result .. "\n"
			end
			-- Move to the next line starting after the last space
			lineStart = spacePos + 1
		end
	end

	return result
end
function M.destroyDemoCards()
	-- Iterate over all stored instance IDs and delete the associated game objects
	for go_id, _ in pairs(M.cards) do
		if go.exists(go_id) then
			go.delete(go_id)  -- Delete the game object
			print("Deleted game object with instance ID (hash):", go_id)  -- Print the hash
		end
	end

	-- -- Clear the tracking tables
	-- cardDataModule.cards = {}
	-- cardDataModule.hand = {}  -- Assuming you also want to clear the hand
end
function M.drawDemoCards()
	local i = M.getHandSize()
	local card = M.remove_card_from_deck()  -- Remove the top card from the deck
	M.add_card_to_hand(card)
	local cardNumber = #M.hand

	-- probably should use the card hand from text.gui

	local cardGO = factory.create("/spawncards#playerCardFactory", vmath.vector3(115 + (i * 245), 790, 0), nil, {isDraggable = true}, 1)

	M.cards[tostring(cardGO)] = card
	print("Instance ID (hash) of created game object:", cardGO)  -- Print the hash

	print("Creating card with name:", card.name)
	msg.post(cardGO, "set_name", {name = card.name})
	msg.post(cardGO, "set_cost", {cost = card.cost})
	msg.post(cardGO, "set_power", {power = card.power})

	formattedDescription = formatNewlines(card.description, 27)

	msg.post(cardGO, "set_description", {description = formattedDescription})
end

function M.add_card_to_hand(card)
	table.insert(M.hand, card)
end

function M.add_opponent_played_card(card)
	table.insert(M.opponentPlayedCards, card)
end

function M.add_card_to_opponent_hand(card)
	table.insert(M.opponentHand, card)
end

function M.add_opponent_deck(card)
	table.insert(M.opponentDeck, card)
end

function M.getHandSize()
	return #M.hand
end

function M.addOpponentCardToHandSize()
	M.opponentHandSize = M.opponentHandSize + 1
end

function M.getOpponentHandSize()
	return M.opponentHandSize
end

-- Possibly can remove, referring directly to table
function M.get_opponent_card(index)
	return M.opponentCards[index]
end

-- Remove Top Card
function M.remove_card_from_deck()
	return table.remove(M.deck, 1)
end

-- Remove Top Card
function M.remove_card_from_opponent_deck()
	return table.remove(M.opponentDeck, 1)
end

-- One Time Effects that occur when player ends turn
function M.card_effect()
end

-- Ongoing Effects that occur every time the players end turn
function M.ongoing_card_effect()
end

-- Modify a card power of a single card
function M.modify_card_power(card, change)		
	reference = cardDataModule.cards[tostring(card)]
	msg.post(cardGO, "set_power", {power = card.power})
end

return M