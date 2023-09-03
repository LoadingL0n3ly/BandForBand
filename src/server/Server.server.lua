local timeStart = tick()

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Common = ServerScriptService:WaitForChild("Common")

local APIHandler = require(Common.API)

-- // SETUP FUNCTIONS
local function PlayerAdded(player)
    APIHandler.PlayerJoined(player)
end

-- // CONNECTIONS 
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

print("🏁 Loaded Server in " .. math.floor((tick() - timeStart) * 1000) .. " ms")