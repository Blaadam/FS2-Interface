local Browser = {}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables
local SharedLibrary = ReplicatedStorage:WaitForChild("SharedLibrary")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local GetServerData = Remotes:WaitForChild("GetServerData")

local Player = Players.LocalPlayer
local MainMenu = Player.PlayerGui:WaitForChild("MainMenu")

local GamesMenu = MainMenu:WaitForChild("Games")
local GameOptions = GamesMenu:WaitForChild("GameOptions")
local ServerBrowserMenu = GamesMenu:WaitForChild("ServerBrowser")

local Library = {
    ServerTiles = require(SharedLibrary.General:WaitForChild("ServerTiles")),
    Maid = require(SharedLibrary.Packages:WaitForChild("Maid"))
}

local Maid = Library.Maid.new()

local Servers = {}

--// Functions
function PlayGame(PlaceID, ServerID)
	GetServerData:InvokeServer({
        Request = "Join",
        Data = {
            PlaceId = PlaceID,
            ServerId = ServerID
        }
    })
end

function OpenGameBrowser(TileName, PlaceInfo)
	Maid:DoCleaning()
    print(PlaceInfo)
end

function RefreshGames()
	Maid:DoCleaning()
    for TileName, TileData in pairs(Library.ServerTiles) do
        local PlaceInfo = GetServerData:InvokeServer({
            Request = "GetServers",
            Data = {
                PlaceId = TileData.PlaceId
            }
        })
        Servers[TileName] = PlaceInfo

        local Tile = GameOptions:FindFirstChild(TileName)
        if not Tile then continue end

        Tile:WaitForChild("Servers").Visible = (TileData.MaxPlayers > 1)
        Tile:WaitForChild("Online").Visible = (TileData.MaxPlayers > 1)

        Tile:WaitForChild("GameImage").Image = TileData.Image[math.random(1, #TileData.Image)]

        Tile:WaitForChild("GameTitle").Text = TileData.Name
		Tile:WaitForChild("GameDesc").Text = TileData.Desc
		
		if (not Servers[TileName]) and (not RunService:IsStudio()) then continue end
		
		Tile.Online.Text = tostring(Servers[TileName].CurrentPlayers or 0).." Online"
		
		Maid:GiveTask(Tile.Play.Activated:Connect(function()
            PlayGame(TileData.PlaceId)
        end))

        Maid:GiveTask(Tile.Servers.Activated:Connect(function()
            OpenGameBrowser(TileName, Servers[TileName])
        end))
    end
end

--// Module Functions

function Browser:Initialise()
    RefreshGames()
end

--// Return
return Browser