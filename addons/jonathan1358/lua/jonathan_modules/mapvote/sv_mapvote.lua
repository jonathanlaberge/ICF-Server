util.AddNetworkString("Jonathan1358.MapVote.MapVoteStart")
util.AddNetworkString("Jonathan1358.MapVote.MapVoteUpdate")
util.AddNetworkString("Jonathan1358.MapVote.MapVoteCancel")
util.AddNetworkString("Jonathan1358.MapVote.RTVDelay")

Jonathan1358.MapVote.Continued = false

net.Receive("Jonathan1358.MapVote.MapVoteUpdate", function(len, ply)
	if(Jonathan1358.MapVote.Allow) then
		if(IsValid(ply)) then
			local update_type = net.ReadUInt(3)
			
			if(update_type == Jonathan1358.MapVote.UPDATE_VOTE) then
				local map_id = net.ReadUInt(32)
				
				if(Jonathan1358.MapVote.CurrentMaps[map_id]) then
					Jonathan1358.MapVote.Votes[ply:SteamID()] = map_id
					
					net.Start("Jonathan1358.MapVote.MapVoteUpdate")
						net.WriteUInt(Jonathan1358.MapVote.UPDATE_VOTE, 3)
						net.WriteEntity(ply)
						net.WriteUInt(map_id, 32)
					net.Broadcast()
				end
			end
		end
	end
end)


function Jonathan1358.MapVote.Start(length, current, limit, prefix)
	if Jonathan1358.MapVote.ENABLED == false then
		error("MapVote is not enabled. Set Jonathan1358.MapVote.ENABLED to true before using Jonathan1358.MapVote.Start.")
		return
	end
	current = current or Jonathan1358.MapVote.Config.AllowCurrentMap or false
	length = length or Jonathan1358.MapVote.Config.TimeLimit or 28
	limit = limit or Jonathan1358.MapVote.Config.MapLimit or 24
	cooldown = Jonathan1358.MapVote.Config.EnableCooldown or true
	prefix = prefix or Jonathan1358.MapVote.Config.MapPrefixes

	local is_expression = false

	if not prefix then
		local info = file.Read(GAMEMODE.Folder.."/"..GAMEMODE.FolderName..".txt", "GAME")

		if(info) then
			local info = util.KeyValuesToTable(info)
			prefix = info.maps
		else
			error("MapVote Prefix can not be loaded from gamemode")
		end

		is_expression = true
	else
		if prefix and type(prefix) ~= "table" then
			prefix = {prefix}
		end
	end
	
	local maps = file.Find("maps/*.bsp", "GAME")
	
	local vote_maps = {}
	
	local amt = 0

	for k, map in RandomPairs(maps) do
		local mapstr = map:sub(1, -5):lower()
		if(not current and game.GetMap():lower()..".bsp" == map) then continue end

		if is_expression then
			if(string.find(map, prefix)) then -- This might work (from gamemode.txt)
				vote_maps[#vote_maps + 1] = map:sub(1, -5)
				amt = amt + 1
			end
		else
			for k, v in pairs(prefix) do
				if string.find(map, "^"..v) then
					vote_maps[#vote_maps + 1] = map:sub(1, -5)
					amt = amt + 1
					break
				end
			end
		end
		
		if(limit and amt >= limit) then break end
	end
	
	net.Start("Jonathan1358.MapVote.MapVoteStart")
		net.WriteUInt(#vote_maps, 32)
		
		for i = 1, #vote_maps do
			net.WriteString(vote_maps[i])
		end
		
		net.WriteUInt(length, 32)
	net.Broadcast()
	
	Jonathan1358.MapVote.Allow = true
	Jonathan1358.MapVote.CurrentMaps = vote_maps
	Jonathan1358.MapVote.Votes = {}
	
	timer.Create("Jonathan1358.MapVote.MapVote", length, 1, function()
		Jonathan1358.MapVote.Allow = false
		local map_results = {}
		
		for k, v in pairs(Jonathan1358.MapVote.Votes) do
			if(not map_results[v]) then
				map_results[v] = 0
			end
			
			for k2, v2 in pairs(player.GetAll()) do
				if(v2:SteamID() == k) then
					if(Jonathan1358.MapVote.HasExtraVotePower(v2)) then
						map_results[v] = map_results[v] + 2
					else
						map_results[v] = map_results[v] + 1
					end
				end
			end
			
		end
		

		local winner = table.GetWinningKey(map_results) or 1
		
		net.Start("Jonathan1358.MapVote.MapVoteUpdate")
			net.WriteUInt(Jonathan1358.MapVote.UPDATE_WIN, 3)
			
			net.WriteUInt(winner, 32)
		net.Broadcast()
		
		local map = Jonathan1358.MapVote.CurrentMaps[winner]

		
		
		timer.Simple(4, function()
			hook.Run("MapVoteChange", map)
			RunConsoleCommand("changelevel", map)
		end)
	end)
end


function Jonathan1358.MapVote.Cancel()
	if Jonathan1358.MapVote.Allow then
		Jonathan1358.MapVote.Allow = false

		net.Start("Jonathan1358.MapVote.MapVoteCancel")
		net.Broadcast()

		timer.Destroy("Jonathan1358.MapVote.MapVote")
	end
end