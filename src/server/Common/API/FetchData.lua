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

	local Response = Request(Data)
	
	if not Response then
		task.wait(2)
		warn("Re-sending request")
		Response = Request(Data)
	end

	if Response["canView"] then
		return Response["canView"]
	else
		warn("Unable to determine if inventory is available")
		warn(Response)
		return nil
	end
end

local function GetLimitedValue(assetId)
	local Price = 0

	local FirstData = {
		["url"] = "https://catalog.roblox.com/v1/catalog/items/" .. assetId .."/details?itemType=Asset"
	}
	
	local FirstResponse = Request(FirstData)

	if FirstResponse["lowestResalePrice"] then
		Price = FirstResponse["lowestResalePrice"]
	else
		warn("Not able to get price")
		warn(FirstResponse)
		warn(FirstData)
	end
	
	return Price
end


local function GetAssets(Player, AssetType: Enum.AssetType)
	local CanView = IsInventoryAvailable(Player) assert(CanView, "Can't view user's inventory!")
	if not CanView then return false end
	
	local Limiteds = {}
	local NonLimiteds = {}

	local ID = Player.UserId
	local NextPageCursor = nil

	repeat
		local CursorText = ""
		if NextPageCursor then
			CursorText = "&cursor=" .. NextPageCursor
		end

		local Data = {
			["url"] = "https://inventory.roblox.com/v2/users/" .. ID .. "/inventory/" .. AssetType.Value .. "?limit=100" .. CursorText .. "&sortOrder=Asc"
		}
		warn(Data.url)

		local answer = Request(Data)
		local itemData = answer["data"]
		
		if not itemData then 
			warn("Unable to load page data")
			warn(answer)
			continue
		end

		NextPageCursor = answer["nextPageCursor"]

		for i, DataPoint in itemData do
			local assetName = DataPoint.assetName
			local assetId = DataPoint.assetId
			local assetData = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
			local UniqueID = HttpService:GenerateGUID(false)

			if assetData.IsLimited then
				-- Item is a limited
				local assetPrice = GetLimitedValue(assetId)
				Limiteds[UniqueID] = {Name = assetName, RobloxId = assetId, Price = assetPrice}
			else
				-- Item is not a limited
				local assetPrice = assetData.PriceInRobux

				if assetData.Creator.CreatorTargetId == ID then
					warn("Player owns this thing, so ignoring")
					assetPrice = 0
				end

				NonLimiteds[UniqueID] = {Name = assetName, RobloxId = assetId, Price = assetPrice or 0}
			end
		end
	until not NextPageCursor
	
	return Limiteds, NonLimiteds
end

function class.GetInventory(Player)
	local Limiteds, NonLimiteds = GetAssets(Player, Enum.AssetType.Face)
	print(Limiteds, NonLimiteds)
end




return class

-- https://inventory.roblox.com/v2/users/1045324707/inventory/11?limit=100&sortOrder=Asc

--2,8,11,12,17,18,19,24,32,64,65,66,67,68,69,70,71,72,76,77,79