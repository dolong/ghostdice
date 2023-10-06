local M = {}
local cardModule = require "modules.card"
local cardData = require "modules.cardData"

-- Initial structure for the zones
M.zones = {
	[1] = {power = 0, cards = {}},
	[2] = {power = 0, cards = {}},
	[3] = {power = 0, cards = {}},
}
M.oppZones = {
	[1] = {power = 0, cards = {}},
	[2] = {power = 0, cards = {}},
	[3] = {power = 0, cards = {}},
}

-- Function to calculate and return the total power of a specific zone
local function calculate_zone_power(zone_number)
	local total_power = 0
	for _, card_instance in ipairs(M.zones[zone_number].cards) do
		local card_power = cardData.cards[card_instance].power
		if card_power then
			total_power = total_power + card_power
		end
	end
	M.zones[zone_number].power = total_power
	return total_power
end

-- Function to calculate and return the total power of a specific zone
local function calculate_opp_zone_power(zone_number)
	local total_power = 0
	for _, card_instance in ipairs(M.oppZones[zone_number].cards) do
		local card_power = cardData.cards[card_instance].power
		if card_power then
			total_power = total_power + card_power
		end
	end
	M.oppZones[zone_number].power = total_power
	return total_power
end

function M.refresh_zone_tile_power() 
	msg.post("landTile1#playerZoneScore", "set_text", {text = tostring(calculate_zone_power(1))})
	msg.post("landTile2#playerZoneScore", "set_text", {text = tostring(calculate_zone_power(2))})
	msg.post("landTile3#playerZoneScore", "set_text", {text = tostring(calculate_zone_power(3))})	
	msg.post("landTile1#opponentZoneScore", "set_text", {text = tostring(calculate_opp_zone_power(1))})
	msg.post("landTile2#opponentZoneScore", "set_text", {text = tostring(calculate_opp_zone_power(2))})
	msg.post("landTile3#opponentZoneScore", "set_text", {text = tostring(calculate_opp_zone_power(3))})
end

-- Function to add a card to a specific zone
function M.add_card(zone_number, card_instance)
	table.insert(M.zones[zone_number].cards, card_instance)
	calculate_zone_power(zone_number)  -- Recalculate power after adding a card
	print(zone_number, card_instance)
end

-- Function to remove a card from a specific zone
function M.remove_card(zone_number, card_instance)
	local cards = M.zones[zone_number].cards
	for i, card in ipairs(cards) do
		if card == card_instance then
			table.remove(cards, i)
			break
		end
	end
	calculate_zone_power(zone_number)  -- Recalculate power after removing a card
end

-- Function to get power from a specific zone
function M.get_power(zone_number)
	return M.zones[zone_number].power
end

-- Function to get cards from a specific zone
function M.get_cards(zone_number)
	return M.zones[zone_number].cards
end

function M.calculate_slot_position(cardsInDropZone)
	local slotx, sloty = 0, 0

	if cardsInDropZone == 1 then
		-- Do nothing as both slotx and sloty are 0
		slotx = 70
	elseif cardsInDropZone == 2 then
		sloty = -95
	elseif cardsInDropZone == 3 then
		slotx = 70
		sloty = -95
	elseif cardsInDropZone == 4 then
	end

	return slotx, sloty
end
-- Function to add a card to a specific zone
function M.add_opp_card(zone_number, card_instance)
	table.insert(M.oppZones[zone_number].cards, card_instance)
	calculate_opp_zone_power(zone_number)  -- Recalculate power after adding a card
	print('opponent zone: ', zone_number, card_instance)
end

-- Function to remove a card from a specific zone
function M.remove_opp_card(zone_number, card_instance)
	local cards = M.oppZones[zone_number].cards
	for i, card in ipairs(cards) do
		if card == card_instance then
			table.remove(cards, i)
			break
		end
	end
	calculate_zone_power(zone_number)  -- Recalculate power after removing a card
end

function M.add_power_opp(zone_number, power)
	M.oppZones[zone_number] = M.oppZones[zone_number] + power
end

function M.get_power_opp(zone_number)
	return M.oppZones[zone_number]
end

return M
