-- ["Tile 1"] = {
--     Name = string,
--     Desc = string,
--     PlaceId = int, -- Required to grab data
--     MaxPlayers = int, -- Automatically enables the server browser if MaxPlayers is more than 1
--     Image = { -- This is an array so random images can cover each game - only put 1 id if you want 1
--         string,
--         string
--     }
-- }

return {
	["Tile1"] = {
		Name = "Shoshone Forest",
		Desc = "Firestorm is an open-world team based game involving fire suppression in a wildland setting. This game offers many opportunities and beautiful scenery, with each experience being unique in your quest to battle raging wildfires in Shoshone National Forest, Wyoming. (Fictional Depiction)",
        PlaceId = 16576400537,
        MaxPlayers = 60,
        Image = {
            "rbxassetid://15114978966"
        }
    },

	["Tile2"] = {
		Name = "Tutorial",
		Desc = "Firestorm is an open-world team based game involving fire suppression in a wildland setting. This game offers many opportunities and beautiful scenery, with each experience being unique in your quest to battle raging wildfires in Shoshone National Forest, Wyoming. (Fictional Depiction)",
        PlaceId = 16576400537,
        MaxPlayers = 1,
        Image = {
            "rbxassetid://15114980192"
        }
    },

	["Tile3"] = {
		Name = "The other forest",
		Desc = "Firestorm is NOT an open-world team based game involving fire suppression in a wildland setting. This game offers many opportunities and beautiful scenery, with each experience being unique in your quest to battle raging wildfires in Shoshone National Forest, Wyoming. (Fictional Depiction)",
        PlaceId = 16576400537,
        MaxPlayers = 60,
        Image = {
            "rbxassetid://15115812867"
        }
    },
}
