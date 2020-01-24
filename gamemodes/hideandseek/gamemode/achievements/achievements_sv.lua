util.AddNetworkString("AchieveSV")
util.AddNetworkString("AchieveCL")

for k,v in pairs(AchievementList) do
	resource.AddFile("materials/has_achieve/icon_"..string.lower(k)..".png")
end

local function _AchNotice(ply,ach,cl)
	if GetConVarNumber("sv_cheats") > 0 then return end
	if cl != "true" then
		timer.Simple(0.8,function()
			net.Start("AchieveSV")
			net.WriteString("#ACH_CELE#|"..ply:EntIndex().."|"..tostring(ach))
			net.Broadcast()
		end)
	end
	
	net.Start("AchieveSV")
	net.WriteString("#ACH_EARN#|"..ach)
	net.Send(ply)
end

hook.Add("PlayerSpawn","HAS_AchMaster",function(ply)
	SendUserMessage("CheckAchState",ply)
	SendUserMessage("FriendsCaughtSetup",ply)
end)

net.Receive("AchieveCL",function(len,ply)
	local db = string.Explode("|",net.ReadString())
	
	if db[1] == "#PLY_CMLT#" then
		_AchNotice(ply,db[2],tostring(db[3]))
	end
	
	if db[1] == "#PLY_HALL#" then
		for k,v in pairs(player.GetHumans()) do
			v:SendLua([[Entity(]]..ply:EntIndex()..[[).IsAchMaster = true]])
		end
		ply.IsAchMaster = true
	end
end)


--Achievement setups
hook.Add("PlayerSpawn","FruitTableSetup",function(ply)
	if game.GetMap() != "cs_italy" then return end
	ply.PickedUpFruits = {
		melon = true,
		orange = true,
		banana = true
	}
end)

hook.Add("PlayerSpawn","HiderPlayingTime",function(ply)
	if ply:Team() != 1 then return end
	ply.HWTime = 0
	ply.TauntsSingle = 0
end)
hook.Add("HASTimerChanged","HiderPlayingTime",function()
	for k,v in pairs(player.GetAll()) do
		if v:Team() == 1 and RoundActive then
			v.HWTime = v.HWTime+1
		end
	end
end)

hook.Add("HASRoundStarted","HasNotMovedSetup",function()
	for k,v in pairs(player.GetAll()) do
		v.HasNotMoved = true
	end
end)

hook.Add("HASHitBreakable","BrokeThingy",function(ply,ent)
	if ply:Team() != 2 then return end
	timer.Simple(0.18,function()
		if (not ent:IsValid()) or ent:Health() <= 0 then
			ply.SBrokeStuff = true
			timer.Create("HAS_SBrokeStuff_"..ply:EntIndex(),8,1,function()
				if not ply:IsValid() then return end
				ply.SBrokeStuff = nil
			end)
		end
	end)
end)

hook.Add("Tick","HasNotMovedChecks",function()
	if timerblip >= GetConVarNumber("has_timelimit")-15 then return end
	if timerblip == 0 then return end
	for k,v in pairs(player.GetAll()) do
		if v.HasNotMoved != nil and v:Team() == 1 then
			local xm = (v:GetVelocity().x < 0) and -(v:GetVelocity().x) or v:GetVelocity().x
			local ym = (v:GetVelocity().y < 0) and -(v:GetVelocity().y) or v:GetVelocity().y
			if v.HasNotMoved and (xm >= 16 or ym >= 16) then
				v.HasNotMoved = false
			end
		end
	end
end)

hook.Add("OnPlayerHitGround","LandedOnPlayers",function(ply,wtr,fltr,spd)
	local ent = ply:GetGroundEntity()
	if ply:Team() == 2 and ent:IsValid() and ent:IsPlayer() and (not wtr) and spd > 100 then
		ply.LandedOnPlayer = ent
		timer.Simple(1,function()
			ply.LandedOnPlayer = nil
		end)
	end
end)

--Achievement earning hooks and stuff
hook.Add("HASPlayerFallDamage","ACH_RBRLEGS",function(ply,dmg)
	net.Start("AchieveSV")
	net.WriteString("#ACH_PROG#|RBRLEGS")
	net.Send(ply)
end)

hook.Add("HASPlayerTaunted","ACH_CONVOST",function(ply)
	if ply:Team() != 1 then return end
	if (not RoundActive) then return end
	ply.TauntsSingle = ply.TauntsSingle+1
	
	if ply.TauntsSingle >= 28 then
		net.Start("AchieveSV")
		net.WriteString("#ACH_EARN#|CONVOST")
		net.Send(ply)
	end
end)

hook.Add("HASPlayerCaught","ACH_SKR1000",function(ply,vic)
	net.Start("AchieveSV")
	net.WriteString("#ACH_PROG#|SKR1000")
	net.Send(ply)
end)

hook.Add("HASPlayerCaught","ACH_CLSECALL",function(ply,vic)
	timer.Simple(0.25,function()
		if team.NumPlayers(1) != 0 then return end
		if timerblip <= 10 then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|CLSECALL")
			net.Send(ply)
		end
	end)
end)

hook.Add("HASPlayerCaught","ACH_WAYTHRO",function(ply,vic)
	if ply.SBrokeStuff == true then
		net.Start("AchieveSV")
		net.WriteString("#ACH_EARN#|WAYTHRO")
		net.Send(ply)
	end
end)

hook.Add("HASPlayerCaughtArea","ACH_SBMISSN",function(ply,vic)
	if timerblip >= GetConVarNumber("has_timelimit")-5 then return end
	vic.PreventSbmissn = true
	timer.Simple(1,function()
		if vic:IsValid() then vic.PreventSbmissn = nil end
	end)
	
	if ply.PreventSbmissn == true then return end
	if ply:GetVelocity():Length() <= 16 and ply:GetGroundEntity() != NULL then
		net.Start("AchieveSV")
		net.WriteString("#ACH_EARN#|SBMISSN")
		net.Send(ply)
	end
end)

hook.Add("HASPlayerCaughtArea","ACH_MTIS",function(ply,vic)
	timer.Create("HAS_MTIS_"..ply:EntIndex(),0.1,9,function()
		if ply.LandedOnPlayer == vic then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|MTIS")
			net.Send(ply)
		end
	end)
end)

hook.Add("HASRoundEndedTime","ACH_HCROWD",function()
	local hiders = {}
	for k,v in pairs(player.GetAll()) do if v:Team() == 1 then table.insert(hiders,v) end end
	
	for k,v in pairs(hiders) do
		local ccc = 0
		for _,a in pairs(hiders) do
			if (v != a) and v:GetPos():Distance(a:GetPos()) <= 240 then
				ccc = ccc+1
			end
		end
		if ccc >= 2 then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|HCROWD")
			net.Send(v)
		end
	end
end)

hook.Add("HASRoundEndedTime","ACH_LASTMAN",function()
	if #player.GetAll()-team.NumPlayers(3) < 4 then return end
	if team.NumPlayers(1) != 1 then return end
	for k,v in pairs(player.GetAll()) do 
		if v:Team() == 1 then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|LASTMAN")
			net.Send(v)
		end
	end
end)

hook.Add("HASRoundEndedTime","ACH_ROOTED",function()
	for k,v in pairs(player.GetAll()) do
		if v:Team() == 1 and v.HasNotMoved then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|ROOTED")
			net.Send(v)
		end
	end
end)

hook.Add("HASRoundEndedTime","ACH_TNQHDING",function()
	timer.Simple(0.33,function()
		for k,v in pairs(player.GetHumans()) do
			if v.HWTime != nil then
				net.Start("AchieveSV")
				net.WriteString("#ACH_PROG#|TNQHDING|"..tostring(v.HWTime))
				net.Send(v)
			end
		end
	end)
end)
hook.Add("HASRoundEndedCaught","ACH_TNQHDING",function()
	timer.Simple(0.33,function()
		for k,v in pairs(player.GetHumans()) do
			if v.HWTime != nil then
				net.Start("AchieveSV")
				net.WriteString("#ACH_PROG#|TNQHDING|"..tostring(v.HWTime))
				net.Send(v)
			end
		end
	end)
end)

hook.Add("HASGameEnded","ACH_TOPPLYR",function(ply)
	if #player.GetAll()-team.NumPlayers(3) < 4 then return end
	net.Start("AchieveSV")
	net.WriteString("#ACH_PROG#|TOPPLYR")
	net.Send(ply)
end)

hook.Add("PlayerSay","ACH_TCKLEFGHT",function(ply,txt,teamchat)
	if (string.match(string.lower(txt),"tickle fight") or string.match(string.lower(txt),"ticklefight")) then
		net.Start("AchieveSV")
		net.WriteString("#ACH_EARN#|TCKLEFGHT")
		net.Send(ply)
	end
end)

hook.Add("PlayerUse","ACH_PKUPBIKE",function(ply,ent)
	if not string.match(ent:GetClass(),"^prop_physics") then return end
	local tme = (GetConVarNumber("sv_cheats") > 0) and 12 or 1
	if ply.PickupTime == nil then ply.PickupTime = CurTime() end
	if CurTime() >= ply.PickupTime then
		ply.PickupTime = CurTime()+tme
		if ent:GetModel() == "models/props_junk/bicycle01a.mdl" then
			net.Start("AchieveSV")
			net.WriteString("#ACH_EARN#|PKUPBIKE")
			net.Send(ply)
		end
	else
		ply.PickupTime = CurTime()+tme
	end
end)

hook.Add("PlayerUse","ACH_HEALTHY",function(ply,ent)
	if game.GetMap() != "cs_italy" then return end
	if not string.match(ent:GetClass(),"^prop_physics") then return end
	if ent:GetModel() == "models/props_junk/watermelon01.mdl" and ply.PickedUpFruits.melon then
		ply.PickedUpFruits.melon = false
	end
	if ent:GetModel() == "models/props/cs_italy/orange.mdl" and ply.PickedUpFruits.orange then
		ply.PickedUpFruits.orange = false
	end
	if (ent:GetModel() == "models/props/cs_italy/bananna_bunch.mdl" or ent:GetModel() == "models/props/cs_italy/bananna.mdl") and ply.PickedUpFruits.banana then
		ply.PickedUpFruits.banana = false
	end
	
	local frr = 0
	for k,v in pairs(ply.PickedUpFruits) do
		if not v then
			frr = frr+1
		end
	end
	if frr == 3 then
		net.Start("AchieveSV")
		net.WriteString("#ACH_EARN#|HEALTHY")
		net.Send(ply)
	end
end)