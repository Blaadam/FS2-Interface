--[[
    ClientLibrary/init.client.lua
    This script handles all the server initialisation for the server components utilised by the Firestorm Interactive Hub Experience.

    This script was developed by blaadam
    Last date of modiviation, 2024-01-11 @ 19:51 UTC
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Variables
local Player = Players.LocalPlayer
local MainMenu = Player.PlayerGui:WaitForChild("MainMenu")

local Library = {
    LoadingCore = require(script:WaitForChild("Interface"):WaitForChild("LoadingCore")),
    ServerBrowser = require(script.Interface:WaitForChild("ServerBrowser"))
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

--// Execution

DBG("CLIENT INITIALISATION BEGUN", true)

Library.LoadingCore:Initialise()
DBG("LoadingCore initialised")
Library.ServerBrowser:Initialise()
DBG("ServerBrowser initialised")

DBG("CLIENT INITIALISED SUCCESSFULLY", true)