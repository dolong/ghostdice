local M = {}

local zonesModule = require "modules.zones"
local playersModule = require "modules.player"
local cardDataModule = require "modules.cardData"

M.playedActions = {}
M.playerEnded = false
M.oppPlayerEnded = false

function M.oppEndTurn() 
	M.oppPlayerEnded = true	
	print('opponent ended turn')
	M.checkTurnEndedByBothPlayers()
end

function M.endTurn() 
	M.playerEnded = true	
	print('player ended turn')
	M.checkTurnEndedByBothPlayers()
end

function M.checkTurnEndedByBothPlayers()
	if M.playerEnded and M.oppPlayerEnded then
		print('both players ended turn')
		M.newTurn()
	end
end

function M.newTurn() 
	num = playersModule.get_turn()

	local newTurn = playersModule.set_turn(num + 1 )
	local newEnergy = playersModule.set_energy(num + 1 )

	M.play_actions()

	msg.post("/energy#energy", "update_energy")
	M.drawCard()
	M.playerEnded = false
	M.oppPlayerEnded = false
end

function M.drawCard() 

	local card = cardDataModule.remove_card_from_deck()  -- Remove the top card from the deck
	cardDataModule.add_card_to_hand(card)  -- Add to the hand

	local cardNumber = #cardDataModule.hand
	local cardGO = factory.create("/spawner#playerCardFactory", vmath.vector3(610 + (cardNumber * 50), 40, 0), nil, {isDraggable = true}, .5)
	cardDataModule.cards[tostring(cardGO)] = card
	print("Creating card with name:", card.name)
	msg.post(cardGO, "set_name", {name = card.name})
	msg.post(cardGO, "set_cost", {cost = card.cost})
	msg.post(cardGO, "set_power", {power = card.power})
	msg.post("/client#client", "draw", { player_id = playersModule.get_id() })
	
end

-- Queues the message into the playedActions table
function M.queue_message(zone, player, cardName, cardPower, cardCost) 
	local action = {
		type = "card",
		zone = zone,
		player = player,
		cardName = cardName, 
		cardPower = cardPower, 
		cardCost = cardCost
	}
	table.insert(M.playedActions, action)		
end

-- Processes all the actions in the playedActions table
function M.play_actions()
	for _, action in ipairs(M.playedActions) do
		-- Assuming the type of all actions is "card" for this example.
		-- If you have other types, you'll need to handle those cases.
		if action.type == "card" then
			msg.post("/client#client", "drop", {
				zone = action.zone, 
				player_id = action.player, 
				cardName = action.cardName, 
				cardPower = action.cardPower, 
				cardCost = action.cardCost
			})
		end
	end
	-- Clear the actions table after processing
	M.playedActions = {}
end

function M.card_effect()
end

function M.card_effect()
end

function M.modify_card_power()	
end

return M
