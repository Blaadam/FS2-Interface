--[[
    ServerCore.server.lua
    This script handles all the server initialisation for the server components utilised by the Firestorm Interactive Hub Experience.

    This script was developed by blaadam
    Last date of modiviation, 2024-01-11 @ 19:51 UTC
]]

--// Services
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

local ServerLibrary = ServerScriptService:WaitForChild("ServerLibrary")

local Library = {
    RequestHandler = require(ServerLibrary:WaitForChild("General"):WaitForChild("RequestHandler"))
}

--// Functions

function DBG(Message, Warning)
    if not RunService:IsStudio() then
        return false
    end

    if Warning then
        warn(Message)
    else
        print(Message)
    end
    return true
end

function PlayerJoined(Player)
    
end

function PlayerLeft(Player)
    
end

--// Execution

Players.PlayerAdded:Connect(PlayerJoined)
Players.PlayerRemoving:Connect(PlayerLeft)

--// Initialisation

DBG("SERVER INITIALISATION BEGUN", true)

Library.RequestHandler:Initialise()
DBG("RequestHandler initialised")

DBG("SERVER INITIALISED SUCCESSFULLY", true)

game:BindToClose(function()
    local c = 0
    repeat
        task.wait(1)
        c = c + 1
    until c > 20
end)