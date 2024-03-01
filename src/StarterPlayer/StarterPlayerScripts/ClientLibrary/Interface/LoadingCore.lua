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

local GamesPage = MainMenu:WaitForChild("Games")

local Library = {
    LoadingScreenInfo = require(SharedLibrary:WaitForChild("General"):WaitForChild("LoadingScreenInfo"))
}

--// Functions

function LoadBar()
    LoadingScreen.Visible, GamesPage.Visible = true, false;


    local Tween = TweenService:Create(LoadingBar:WaitForChild("Subbar"), Library.LoadingScreenInfo.TweenData.LoadingTween, {Size = UDim2.new(1, 0, 1, 0)} )
    Tween:Play()

    local PercentageDetection = LoadingBar.Subbar.Changed:Connect(function()
        LoadingScreen.PercentageText.Text = tostring(math.floor(LoadingBar.Subbar.Size.X.Scale*100)).."%"
    end)

    Tween.Completed:Wait()
    PercentageDetection:Disconnect()
    if Tween then Tween:Destroy() end

    --[[     This was a really bad idea.     ]]--
    -- LoadingBar.Subbar:WaitForChild("Frame").Transparency = 0
    -- for i=1, 3 do
    --     task.wait(0.1)
    --     LoadingBar.Subbar.Frame.Position = UDim2.new(0, 0, 0, 0)
    --     Tween = TweenService:Create(LoadingBar.Subbar.Frame, Library.LoadingScreenInfo.TweenData.LoadingHighlight, {Position = UDim2.new(1, 0, 0, 0)})
    --     Tween:Play()
    --     Tween.Completed:Wait()
    --     if Tween then Tween:Destroy() end
    -- end

    task.wait(0.2)

    TweenService:Create(LoadingBar, Library.LoadingScreenInfo.TweenData.ClearScreenTween, {Position = UDim2.new(0.5, 0, 1.1, 0)}):Play()
    TweenService:Create(LoadingScreen.PercentageText, Library.LoadingScreenInfo.TweenData.ClearScreenTween, {Position = UDim2.new(0.5, 0, 1.1, 0)}):Play()
    TweenService:Create(LoadingScreen.GameTips, Library.LoadingScreenInfo.TweenData.ClearScreenTween, {Position = UDim2.new(0.5, 0, 1.1, 0)}):Play()

    task.wait(Library.LoadingScreenInfo.TweenData.ClearScreenTween.Time+0.1)
    TweenService:Create(LoadingScreen, Library.LoadingScreenInfo.TweenData.WholeScreenClear, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()

    GamesPage.Visible = true
    GamesPage.Position = UDim2.new(0.5, 0, -1.5, 0)
    TweenService:Create(GamesPage, Library.LoadingScreenInfo.TweenData.LoadGamesPage, {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
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