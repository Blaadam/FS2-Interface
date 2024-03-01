local Handler = {}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--// Variables
local SharedLibrary = ReplicatedStorage:WaitForChild("SharedLibrary")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ServerLibrary = ServerScriptService:WaitForChild("ServerLibrary")

local Library = {
	MemoryService = require(ServerLibrary.General:WaitForChild("MemoryService")),
	Moderators = require(SharedLibrary.General:WaitForChild("Moderators")),
	ServerTiles = require(SharedLibrary.General:WaitForChild("ServerTiles")),
}

--// Functions

function CheckMod(Player)
	local isMod = false

	for _, v in pairs(Library.Moderators) do
		if Player.UserId == v then
			isMod = true
			break
		end
		if isMod then
			break
		end
	end

	return isMod
end

--// Module Functions

function Handler:Initialise()
	function Remotes.GetServerData.OnServerInvoke(Player, ReceivedData)
		local Response = {
			Message = "",
			ErrorMessage = "",
			Data = nil,
		}

		if ReceivedData.Request == "GetServers" then
			if ReceivedData.Data.PlaceId then
				local Success, ErrorMsg = pcall(function()
					Response.Data = Library.MemoryService:GetServers(ReceivedData.Data.PlaceId)
				end)
				if not Success then
					Response.Message = "Error"
					Response.ErrorMessage = ErrorMsg
				end
				Response.Message = "Success"
			end
		elseif ReceivedData.Request == "Join" then
			if ReceivedData.Data.PlaceId and ReceivedData.Data.ServerId then
				local Result = Library.MemoryService:JoinServerById(
					Player,
					ReceivedData.Data.PlaceId,
					ReceivedData.Data.ServerId
				)
                
				if Result ~= "Success" then
					Response.Message = "Error"
					Response.ErrorMessage = Result
				else
					Response.Message = "SuccessNoData"
				end

			elseif ReceivedData.Data.PlaceId then
				local Result = Library.MemoryService:JoinServer(Player, ReceivedData.Data.PlaceId)
				Response.Message = "SuccessNoData"
			elseif (not CheckMod(Player)) and ReceivedData.Data.GameLocked then
				Response.Message = "Error"
				Response.ErrorMessage = "Game is locked."
			end
		end

		return Response
	end
end

--// Return
return Handler
