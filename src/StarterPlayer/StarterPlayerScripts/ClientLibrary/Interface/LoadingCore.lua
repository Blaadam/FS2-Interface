local Core = {}

--// Services

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// Variables
local SharedLibrary = ReplicatedStorage:WaitForChild("SharedLibrary")

local Player = Players.LocalPlayer
local MainMenu = Player.PlayerGui:WaitForChild("MainMenu")

local LoadingScreen = MainMenu:WaitForChild("LoadingScreen")
local LoadingBar = LoadingScreen:WaitForChild("LoadingBar")

local Library = {
    LoadingScreenInfo = require(SharedLibrary:WaitForChild("General"):WaitForChild("LoadingScreenInfo"))
}

--// Functions

function LoadBar()

    local IntValue = Instance.new("IntValue")
    IntValue.Parent = script

    local Tween = TweenService:Create(LoadingBar:WaitForChild("Subbar"), Library.LoadingScreenInfo.TweenData.LoadingTween, {Size = UDim2.new(1, 0, 1, 0)} )
    Tween:Play()

    local PercentageDetection = LoadingBar.Subbar.Changed:Connect(function()
        LoadingScreen.PercentageText.Text = tostring(math.floor(LoadingBar.Subbar.Size.X.Scale*100)).."%"
    end)

    Tween.Completed:Wait()
    PercentageDetection:Disconnect()
    if Tween then Tween:Destroy() end

end

--// Module Functions

function Core:Initialise()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
    task.spawn(function()
        repeat
            task.wait(1)
        until game:IsLoaded()

        LoadBar()
    end)
end

--// Return

return Core