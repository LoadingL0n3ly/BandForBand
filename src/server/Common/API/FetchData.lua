local class = {}

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local PROXY_URL = "https://proxy-roblox.vercel.app/"

local headers = {
	["Accept"] = "application/json"
}
local JSONHeader = HttpService:JSONEncode(headers)

local function GetPrice(assetId : number)
	local asset = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
	if asset then
	  return asset.PriceInRobux
	end
  end

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

local function Request(Data)
	local json = HttpService:JSONEncode(Data)
	
	local Response
	
	local success, response = pcall(function()
		local data = HttpService:PostAsync(PROXY_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
		Response = HttpService:JSONDecode(data)
	end)

	return Response
end

local function IsInventoryAvailable(Player)
	local ID = Player.UserId
	
	local Data = {
		["url"] = "https://inventory.roblox.com/v1/users/" .. ID .. "/can-view-inventory"
	}
	local json = HttpService:JSONEncode(Data)
	
	local Response
	
	local success, response = pcall(function()
		local data = HttpService:PostAsync(PROXY_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
		Response = HttpService:JSONDecode(data)
	end)
	
	return Response["canView"]
end

-- takes in player and type of assets to collect
-- {name = "", RobuxCost = int, id = int};


local function GetNonLimiteds(Player, ASSET_ID)
	local CanView = IsInventoryAvailable(Player) assert(CanView, "Can't view user's inventory!")
	
	local Result = {}
	local ID = Player.UserId
	local NextPageCursor = nil

	repeat
		local CursorText = ""
		if NextPageCursor then
			CursorText = "&cursor=" .. NextPageCursor
		end

		local Data = {
			["url"] = "https://inventory.roblox.com/v2/users/" .. ID .. "inventory/" .. ASSET_ID .. "?limit = 100" .. CursorText .. "&sortOrder=Asc"
		}

		local answer = Request(Data)
		NextPageCursor = answer["nextPageCursor"]

		local itemData = answer["data"]

		for i, DataPoint in itemData do
			local Name = Data.assetName
			local assetId = Data.assetId

			local AdditionalData = MarketplaceService:GetProductInfo(assetId)
			
		end


	until not NextPageCursor
	
end

function class.GetInventory(Player)
	local ID = Player.UserId
	
end




return class

-- https://inventory.roblox.com/v2/users/1045324707/inventory/11?limit=100&sortOrder=Asc

--2,8,11,12,17,18,19,24,32,64,65,66,67,68,69,70,71,72,76,77,79