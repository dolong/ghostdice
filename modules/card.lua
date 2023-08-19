-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.
local M = {}

M.cardNames = {}
M.cardPowers = {}
M.cardCosts = {}
M.cardDescriptions = {}

M.deck = {}  -- List of card objects in the deck
M.hand = {}  -- List of card objects in the hand

local cardNext = 6

function M.card_Next()
	return cardNext
end

function M.set_card_Next(num)
	cardNext = num
end

return M