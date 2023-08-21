local M = {}

M.deck = {}
M.hand = {}
M.cards = {} 
M.opponentCards = {} -- So far this is opponents Played Cards

function M.add_card_to_hand(card)
	table.insert(M.hand, card)
end

function M.add_opponent_card(card)
	table.insert(M.opponentCards, card)
end

-- Possibly can remove, referring directly to table
function M.get_opponent_card(index)
	return M.opponentCards[index]
end

function M.remove_card_from_deck()
	return table.remove(M.deck, 1)
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