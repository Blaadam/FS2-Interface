--[[
	Hub
	@blaadam
	
	October 5, 2021
	
	local ServerData = {
		ServerId = nil,
		ReserveCode = nil,
		
		CurrentPlayers = {},
		MaxPlayers = 50,
		ReservedSpots = 5,
		
		RegionLocation = "Unknown",
		Ping = 0,
		
		Locked = false,
		Shutdown = false,
	}
]]

local Lib = {}

--// Services
local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

--// Variables
local ServerRefreshRate = 1500
local PlayerCountData = DataStoreService:GetDataStore("PlayerCount")

local SharedLibrary = ReplicatedStorage:WaitForChild("SharedLibrary")

local SortedMaps = {}
local Queues = {}
local PlayerDebounce = {}
local PlayerActiveQueue = {}
local Moderators = require(script.Moderator)

local VersionControl = "Test0_"
local ServerTiles = require(SharedLibrary.General:WaitForChild("ServerTiles"))

--// Functions

function UpdatePlayers(PlaceId, ServerId, PlayerList)
	local Current = PlayerCountData:GetAsync(PlaceId .. "_" .. ServerId)
	if Current == nil then
		Current = PlayerCountData:SetAsync(PlaceId .. "_" .. ServerId, PlayerList)
	else
		PlayerCountData:UpdateAsync(PlaceId .. "_" .. ServerId, function(oldValue)
			return PlayerList
		end)
	end
end

function GetPlayers(PlaceId, ServerId)
	local Current = PlayerCountData:GetAsync(PlaceId .. "_" .. ServerId)

	return Current
end

function GetSortedMap(PlaceId)
	local SortedMap = nil
	if SortedMaps[PlaceId] then
		SortedMap = SortedMaps[PlaceId]
	else
		SortedMaps[PlaceId] = MemoryStoreService:GetSortedMap(VersionControl .. PlaceId)
		SortedMap = SortedMaps[PlaceId]
	end

	return SortedMap
end

function GetQueue(PlaceId, ServerId)
	warn(0.2)
	local Queue = nil
	if Queues[PlaceId .. "_" .. ServerId] then
		warn(0.3)
		Queue = Queues[PlaceId .. "_" .. ServerId]
	else
		warn(0.4)
		Queues[PlaceId .. "_" .. ServerId] = MemoryStoreService:GetQueue(PlaceId .. "_" .. ServerId, 30)
		Queue = Queues[PlaceId .. "_" .. ServerId]
	end

	return Queue
end

function GetServersByPlaceId(PlaceId)
	local Servers = {}

	local SortedMap = GetSortedMap(PlaceId)
	local RangeAsync = SortedMap:GetRangeAsync(0, 200)
	for key, ServerInfo in pairs(RangeAsync) do
		local ServerData = ServerInfo.value
		local Players = GetPlayers(PlaceId, ServerData.ServerId)
		ServerData.CurrentPlayers = Players
		table.insert(Servers, ServerData)
	end

	return Servers
end

function GetServerData(PlaceId, ServerId)
	local ServerData = GetSortedMap(PlaceId):GetAsync(ServerId)
	local PlayerList = GetPlayers(PlaceId, ServerId)
	ServerData.CurrentPlayers = PlayerList
	return ServerData
end

function UpdateServerData(PlaceId, ServerId, ServerData)
	local ToUpdate = ServerData
	local PlayerList = ServerData.CurrentPlayers or {}
	ToUpdate.CurrentPlayers = {}

	local function transformFunction(oldValue)
		return ToUpdate
	end

	if typeof(ToUpdate.RegionLocation) == "table" then
		ToUpdate.RegionLocation = ToUpdate.RegionLocation.countryCode .. "-" .. ToUpdate.RegionLocation.region
	end

	UpdatePlayers(PlaceId, ServerId, PlayerList)
	GetSortedMap(PlaceId):UpdateAsync(ServerId, transformFunction, ServerRefreshRate)
end

function DeleteServerData(PlaceId, ServerId)
	GetSortedMap(PlaceId):RemoveAsync(ServerId)
end

function CheckMod(Player)
	local isMod = false

	for _, v in pairs(Moderators) do
		if Player.UserId == v then
			isMod = true
			break
		end
	end

	if isMod then
		return isMod
	end

	return isMod
end

function canJoinServer(Player, Server)
	local can = false

	if #Server.CurrentPlayers < Server.MaxPlayers then
		can = true
	elseif
		#Server.CurrentPlayers >= Server.MaxPlayers
		and #Server.CurrentPlayers < (Server.MaxPlayers + Server.ReservedSpots)
	then
		if table.find(Moderators, Player.UserId) then
			can = true
		end
	end

	if Server.GameLocked and CheckMod(Player) then
		can = true
	elseif Server.GameLocked then
		can = false
	end

	return can
end

function isBooster(Player)
	if
		game:GetService("HttpService"):GetAsync("http://45.55.47.67:3000/boost/" .. tostring(Player.UserId)) == "true"
	then
		return true
	end
end

function GetPriorityLevel(Player)
	local PriorityLevel = {
		Regular = 0,
		Nitro = 1,
		QA = 2,
		Developer = 3,
	}

	local Priority = PriorityLevel.Regular

	if isBooster(Player) then
		Priority = PriorityLevel.Nitro
	end
	if Player:GetRankInGroup(9836366) == 100 then
		Priority = PriorityLevel.QA
	end
	if Player:GetRankInGroup(2803381) >= 40 then
		Priority = PriorityLevel.Developer
	end

	return Priority
end

function GetPlaceData(PlaceId)
	local returnData = nil

	for Section, Data in pairs(ServerTiles) do
		if returnData == nil then
			if Section == "Main Game" then
				if PlaceId == Data.PlaceId then
					returnData = Data
				end
			else
				for Tile, TileData in pairs(Data) do
					if TileData.Replacement and TileData.PlaceId ~= PlaceId then
						if TileData.Replacement.PlaceId == PlaceId then
							returnData = TileData.Replacement
						end
					else
						if TileData.PlaceId == PlaceId then
							returnData = TileData
						end
					end
				end
			end
		end
	end

	return returnData
end

function GetQueueList(PlaceId, ServerId, Count)
	local Queue = GetQueue(PlaceId, ServerId)
	local QueueList, Id = Queue:ReadAsync(Count, false, 0)

	if Id then
		local success, err = pcall(function()
			Queue:RemoveAsync(Id)
		end)
		if not success then
			print("Error removing from queue: " .. err)
		end
	end
	return QueueList
end

function JoinServerQueue(Player, PlaceId, ServerId, Priority)
	warn(0.1)
	local Queue = GetQueue(PlaceId, ServerId)
	warn(0.5)
	local Success = false
	warn(0.6)
	local AdjustedPriority = GetPriorityLevel(Player) or 0
	warn(0.7)
	if Queue then
		warn(0.8)
		local success, err = pcall(function()
			Queue:AddAsync(Player.UserId, ServerRefreshRate, AdjustedPriority)
		end)
		warn(0.9)
		if success then
			Success = true
			PlayerActiveQueue[Player.UserId] = {
				PlaceId = PlaceId,
				ServerId = ServerId,
				InQueue = true,
			}
		else
			warn("Could not join queue: " .. err)
		end
	end

	return Success
end

function LeaveServerQueue(Player)
	local PlayerQueue = PlayerActiveQueue[Player.UserId]
	local Success = false

	if PlayerQueue then
		local Queue = GetQueue(PlayerQueue.PlaceId, PlayerQueue.ServerId)

		if Queue then
			local success, err = pcall(function()
				-- SOME METHOD TO REMOVE INDIVIDUALLY??
				Queue:AddAsync(Player.UserId, 1, 0)
			end)
			PlayerActiveQueue[Player.UserId] = {
				PlaceId = nil,
				ServerId = nil,
				InQueue = false,
			}
			if success then
				Success = true
				PlayerActiveQueue[Player.UserId] = nil
				print("Successfully exitted queue")
			else
				warn("Could not exit queue: " .. err)
			end
		end
	end

	return Success
end

function CreateServer(Player, PlaceId)
	local PlaceInfo = GetPlaceData(PlaceId) or { Max_Players = 70, Developer_Slots = 10 }

	local ServerData = {
		ServerId = nil,
		ReserveCode = nil,

		CurrentPlayers = {},
		MaxPlayers = PlaceInfo.Max_Players,
		ReservedSpots = PlaceInfo.Developer_Slots,

		StartTime = 0,
		RegionLocation = nil,
		Ping = 0,

		Locked = false,
		Shutdown = false,
	}

	local TeleportOptions = Instance.new("TeleportOptions")
	TeleportOptions.ShouldReserveServer = true

	local TeleportResult = TeleportService:TeleportAsync(PlaceId, { Player }, TeleportOptions)

	if PlaceInfo.Max_Players > 1 then
		ServerData.ServerId = TeleportResult.PrivateServerId
		ServerData.ReserveCode = TeleportResult.ReservedServerAccessCode
		table.insert(ServerData.CurrentPlayers, Player.UserId)
		UpdatePlayers(PlaceId, ServerData.ServerId, ServerData.CurrentPlayers)
		ServerData.CurrentPlayers = {}
	end
	return ServerData
end

--// Module Functions
function Lib:JoinServerById(Player, PlaceId, ServerId)
	warn(1)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	warn(2)
	PlayerDebounce[Player.UserId] = true
	warn(3)

	local ServerData = GetServerData(PlaceId, ServerId)

	warn(4)
	if ServerData then
		warn(5)
		if canJoinServer(Player, ServerData) then
			warn(6)
			local function transformFunction(oldValue)
				return ServerData
			end
			warn(7)
			ServerData.CurrentPlayers = GetPlayers(PlaceId, ServerId)
			warn(8)
			if table.find(ServerData.CurrentPlayers, Player.UserId) then
				-- do nthng
				warn(9)
			else
				table.insert(ServerData.CurrentPlayers, Player.UserId)
				--UpdatePlayers(PlaceId,ServerId,ServerData.CurrentPlayers)
				warn(10)
			end
			ServerData.CurrentPlayers = {}
			warn(11)
			GetSortedMap(PlaceId):UpdateAsync(ServerData.ServerId, transformFunction, ServerRefreshRate)
			warn(12)
			TeleportService:TeleportToPrivateServer(PlaceId, ServerData.ReserveCode, { Player })
			print(13)
			task.delay(5, function()
				PlayerDebounce[Player.UserId] = nil
			end)
			print(14)
			return "Success"
		else
			print(15)
			local Queued = JoinServerQueue(Player, PlaceId, ServerId)
			print(16)
			if Queued == true then
				print(17)
				return "Server is full. Pending in queue. " .. GetPriorityLevel(Player)
			else
				print(18)
				return "Server is full. Could not queue."
			end
		end
	else
		print(19)
		return "No Server Found"
	end
end

function Lib:JoinServer(Player, PlaceId)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	PlayerDebounce[Player.UserId] = true

	local PlaceInfo = GetPlaceData(PlaceId)

	if PlaceInfo.Max_Players == 1 then
		CreateServer(Player, PlaceId)
		task.delay(30, function()
			PlayerDebounce[Player.UserId] = nil
		end)
		return "Success"
	else
		local Servers = GetServersByPlaceId(PlaceId)
		local ServerData = nil

		if Servers and #Servers > 0 then
			local tempData = {
				PlayerCount = 0,
				ServerId = nil,
			}

			for ServerId, Data in pairs(Servers) do
				if #Data.CurrentPlayers > tempData.PlayerCount or tempData.ServerId == nil then
					if canJoinServer(Player, Data) then
						tempData.ServerId = ServerId
						tempData.PlayerCount = #Data.CurrentPlayers
						ServerData = Data
						break
					end
				end
			end

			if ServerData then
				table.insert(ServerData.CurrentPlayers, Player.UserId)
				--UpdatePlayers(PlaceId,ServerData.ServerId,ServerData.CurrentPlayers)
				ServerData.CurrentPlayers = {}

				local function transformFunction(oldValue)
					return ServerData
				end
				GetSortedMap(PlaceId):UpdateAsync(ServerData.ServerId, transformFunction, ServerRefreshRate)
				TeleportService:TeleportToPrivateServer(PlaceId, ServerData.ReserveCode, { Player })
				task.delay(10, function()
					PlayerDebounce[Player.UserId] = nil
				end)
				return "Success"
			else
				local ServerData = CreateServer(Player, PlaceId)
				GetSortedMap(PlaceId):SetAsync(
					ServerData.ServerId,
					ServerData,
					ServerRefreshRate,
					#ServerData.CurrentPlayers
				)
				task.delay(30, function()
					PlayerDebounce[Player.UserId] = nil
				end)
				return "Success"
			end
		else
			local ServerData = CreateServer(Player, PlaceId)
			GetSortedMap(PlaceId):SetAsync(
				ServerData.ServerId,
				ServerData,
				ServerRefreshRate,
				#ServerData.CurrentPlayers
			)
			task.delay(30, function()
				PlayerDebounce[Player.UserId] = nil
			end)
			return "Success"
		end
	end
end

function Lib:CreateServer(Player, PlaceId)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	PlayerDebounce[Player.UserId] = true

	local ServerData = CreateServer(Player, PlaceId)
	GetSortedMap(PlaceId):SetAsync(ServerData.ServerId, ServerData, ServerRefreshRate, #ServerData.CurrentPlayers)
	task.delay(30, function()
		PlayerDebounce[Player.UserId] = nil
	end)
	return "Success"
end

function Lib:GetServers(PlaceId)
	return GetServersByPlaceId(PlaceId)
end

function Lib:GetServerData(PlaceId, ServerId)
	return GetServerData(PlaceId, ServerId)
end

function Lib:UpdateServerData(PlaceId, ServerId, ServerData)
	return UpdateServerData(PlaceId, ServerId, ServerData)
end

function Lib:DeleteServer(PlaceId, ServerId)
	return DeleteServerData(PlaceId, ServerId)
end

function Lib:UpdatePlayerDatastore(PlaceId, ServerId, PlayerList)
	UpdatePlayers(PlaceId, ServerId, PlayerList)
end

function Lib:LeaveQueue(Player)
	LeaveServerQueue(Player)
end

function Lib:GetQueue(PlaceId, ServerId, Count)
	return GetQueueList(PlaceId, ServerId, Count)
end

function Lib:IsPlayerInQueue(Player, PlaceId, ServerId)
	local PlayerQueue = PlayerActiveQueue[Player.UserId]
	local is = false
	if PlayerQueue then
		if PlayerQueue.PlaceId == PlaceId and PlayerQueue.ServerId == ServerId and PlayerQueue.InQueue == true then
			is = true
		else
			is = false
		end
	end

	return is
end

--// Return
return Lib
