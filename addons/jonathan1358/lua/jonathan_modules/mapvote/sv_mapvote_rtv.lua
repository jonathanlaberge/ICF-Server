Jonathan1358.MapVote.RTV = RTV or {}

Jonathan1358.MapVote.RTV.ChatCommands = {
	
	"!rtv",
	"/rtv",
	"rtv"

}

Jonathan1358.MapVote.RTV.TotalVotes = 0

Jonathan1358.MapVote.RTV.Wait = 60 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 

Jonathan1358.MapVote.RTV._ActualWait = CurTime() + Jonathan1358.MapVote.RTV.Wait

Jonathan1358.MapVote.RTV.PlayerCount = Jonathan1358.MapVote.Config.RTVPlayerCount or 3

function Jonathan1358.MapVote.RTV.ShouldChange()
	return Jonathan1358.MapVote.RTV.TotalVotes >= math.Round(#player.GetAll()*0.66)
end

function Jonathan1358.MapVote.RTV.RemoveVote()
	Jonathan1358.MapVote.RTV.TotalVotes = math.Clamp(Jonathan1358.MapVote.RTV.TotalVotes - 1, 0, math.huge)
end

function Jonathan1358.MapVote.RTV.Start()
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,100,50),"The vote has been rocked, map vote imminent")]])
	end
	timer.Simple(4, function()
		Jonathan1358.MapVote.Start(nil, nil, nil, nil)
	end)
end


function Jonathan1358.MapVote.RTV.AddVote(plr)

	if Jonathan1358.MapVote.RTV.CanVote(plr) then
		Jonathan1358.MapVote.RTV.TotalVotes = Jonathan1358.MapVote.RTV.TotalVotes + 1
		plr.RTVoted = true
		MsgN(plr:Nick().." has voted to Rock the Vote.")
		for k,v in pairs(player.GetAll()) do
			--v:PrintMessage(HUD_PRINTTALK,"[rtv] " plr:Nick().." has voted to Rock the Vote. ("..RTV.TotalVotes.."/"..math.Round(#player.GetAll()*0.66)..")")
			v:SendLua([[chat.AddText(Color(255,100,50),"[RTV] Someone has voted to Rock the Vote. (]] .. Jonathan1358.MapVote.RTV.TotalVotes .. [[ / ]] .. math.Round(#player.GetAll()*0.66) .. [[)")]])
			--v:SendLua('chat.AddText(Color(255,100,50),"' .. plr:Nick() .. ' has voted to Rock the Vote. (' .. RTV.TotalVotes .. ' / ' .. math.Round(#player.GetAll()*0.66) .. ')")')
		end
		if Jonathan1358.MapVote.RTV.ShouldChange() then
			Jonathan1358.MapVote.RTV.Start()
		end
	end

end

hook.Add("PlayerDisconnected", "Jonathan1358.MapVote.RemoveRTV", function(plr)

	if plr.RTVoted then
		Jonathan1358.MapVote.RTV.RemoveVote()
	end

	timer.Simple(0.1, function()

		if Jonathan1358.MapVote.RTV.ShouldChange() then
			Jonathan1358.MapVote.RTV.Start()
		end

	end)

end)

function Jonathan1358.MapVote.RTV.CanVote(plr)
	local plrCount = table.Count(player.GetAll())
	
	if Jonathan1358.MapVote.RTV._ActualWait >= CurTime() then
		return false, "You must wait a bit before voting!"
	end

	if Jonathan1358.MapVote.Allow then
		return false, "There is currently a vote in progress!"
	end

	if plr.RTVoted then
		return false, "You have already voted to Rock the Vote!"
	end

	if Jonathan1358.MapVote.RTV.ChangingMaps then
		return false, "There has already been a vote, the map is going to change!"
	end
	if plrCount < Jonathan1358.MapVote.RTV.PlayerCount then
		return false, "You need more players before you can rock the vote!"
	end

	return true

end

function Jonathan1358.MapVote.RTV.StartVote(plr)

	local can, err = Jonathan1358.MapVote.RTV.CanVote(plr)

	if not can then
		plr:PrintMessage(HUD_PRINTTALK, err)
		return
	end

	Jonathan1358.MapVote.RTV.AddVote(plr)

end

concommand.Add("rtv_start", Jonathan1358.MapVote.RTV.StartVote)

hook.Add("PlayerSay", "Jonathan1358.MapVote.RTV.Commands", function(plr, text)

	if table.HasValue(Jonathan1358.MapVote.RTV.ChatCommands, string.lower(text)) then
		Jonathan1358.MapVote.RTV.StartVote(plr)
		return ""
	end

end)
