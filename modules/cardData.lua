local M = {}

M.deck = {}
M.hand = {}
M.cards = {} 
M.opponentCards = {} --unsure if needed yet

function M.add_card_to_hand(card)
	table.insert(M.hand, card)
end

function M.add_opponent_card(card)
	table.insert(M.opponentCards, card)
end

function M.get_opponent_card(index)
	return M.opponentCards[index]
end

function M.remove_card_from_deck()
	return table.remove(M.deck, 1)
end

return M