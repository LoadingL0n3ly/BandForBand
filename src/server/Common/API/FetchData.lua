local class = {}

local HttpService = game:GetService("HttpService")
local AvatarEditorService  = game:GetService("AvatarEditorService")

local PROXY_URL = "https://proxy-roblox.vercel.app/"

local headers = {
	["Accept"] = "application/json"
}
local JSONHeader = HttpService:JSONEncode(headers)

function class.GetCollectibles(Player)
	local ID = Player.UserId
	
	local Data = {
		["url"] = "https://inventory.roblox.com/v1/users/" .. ID .. "/assets/collectibles"
	}
	local json = HttpService:JSONEncode(Data)
	
	local Response
	
	local success, response = pcall(function()
		local data = HttpService:PostAsync(PROXY_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
		Response = HttpService:JSONDecode(data)
	end)
	
	return Response
end


return class

-- https://inventory.roblox.com/v2/users/1045324707/inventory/11?limit=100&sortOrder=Asc