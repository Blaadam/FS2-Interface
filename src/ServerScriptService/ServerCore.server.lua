--[[
    ServerCore.server.lua
    This script handles all the server initialisation for the server components utilised by the Firestorm Interactive Hub Experience.

    This script was developed by blaadam
    Last date of modiviation, 2024-01-11 @ 19:51 UTC
]]

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

local ServerLibrary = ServerScriptService:WaitForChild("ServerLibrary")

local Library = {
    
}

--// Functions

function PlayerJoined(Player)
    
end

function PlayerLeft(Player)
    
end

--// Execution

Players.PlayerAdded:Connect(PlayerJoined)
Players.PlayerRemoving:Connect(PlayerLeft)