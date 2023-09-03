local class = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Common = ServerScriptService:WaitForChild("Common")
local API = script

local FetchData = require(API:WaitForChild("FetchData"))

function class.PlayerJoined(Player)
    FetchData.GetInventory(Player)
end

return class