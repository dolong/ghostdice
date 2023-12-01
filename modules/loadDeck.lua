local M = {}
local cardDataModule = require "modules.cardData"
local playersModule = require "modules.player"

M.deckLoaded = false

function M.getDeckLoaded()
	return M.deckLoaded
end

function handleResponse(self, id, response)

	local handSize = 5
	if response.status == 200 then
		local data = json.decode(response.response)
		for i = 1, #data.names do
			local card = {
				name = data.names[i],
				cost = data.costs[i],
				power = data.powers[i],
				-- image = "",
				-- description = ""

				-- You can add more attributes if needed
			}
			table.insert(cardDataModule.deck, card)

			M.deckLoaded = true
			-- sends the deck to opponent to add
			--msg.post("/client#client", "addOpponentDeck", { player_id = playersModule.get_id(), cardName = data.names[i], cardCost = data.costs[i], cardPower = data.powers[i]})
		end
	else
		print("Error: ", response.status)
	end
end


function M.callDrawCardsExternal()
	local body = json.encode({cards = 12}) -- encoding data as a JSON string
	local headers = {["Content-Type"] = "application/json"} -- setting content type to json
	http.request("https://eohjayfp35ysioq.m.pipedream.net/", "POST", handleResponse, headers, body)
	-- go to handleResponse(self, id, response) next
end


return M