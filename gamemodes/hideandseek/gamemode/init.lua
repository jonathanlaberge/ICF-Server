AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_anims.lua")
AddCSLuaFile("mapprops/mapprops_cl.lua")
AddCSLuaFile("achievements/achievements_sh.lua")
AddCSLuaFile("achievements/achievements_cl.lua")
include("shared.lua")
include("sh_anims.lua")
include("mapprops/mapprops_sv.lua")
include("achievements/achievements_sh.lua")
include("achievements/achievements_sv.lua")

if not ConVarExists("has_seekoncaught") then CreateConVar("has_seekoncaught","1",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, caught players will join the seekers. Otherwise, they will have to spectate until next round.") end
if not ConVarExists("has_timelimit") then CreateConVar("has_timelimit","180",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"The amount of time in seconds that players are allowed to seek.") end
if not ConVarExists("has_minplayers") then CreateConVar("has_minplayers","2",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"The minimum amount of players need to start a round.") end
if not ConVarExists("has_maxrounds") then CreateConVar("has_maxrounds","12",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"The amount of rounds to play until the map is changed.") end
if not ConVarExists("has_infinitestamina") then CreateConVar("has_infinitestamina","0",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, all players will be able to sprint five-ever.") end
if not ConVarExists("has_choosetype") then CreateConVar("has_choosetype","0",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, the first player caught will seek the next round. Otherwise, it will random.") end
if not ConVarExists("has_envdmgallowed") then CreateConVar("has_envdmgallowed","1",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, players will get caught and respawned when attacked by the world.") end
if not ConVarExists("has_lasttrail") then CreateConVar("has_lasttrail","1",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, the last hider will have a blue trail following them to give seekers a hint.") end
if not ConVarExists("has_dyntagging") then CreateConVar("has_dyntagging","0",{FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE},"If enabled, the area-tagging range will shrink when next to walls and objects.\n - This would heavily minimize the chances of being tagged through walls.\n - NOTE: This can cause lag when there are lots of players.") end

concommand.Add("has_restartround",function(ply)
	if not ply:IsAdmin() then return end
	RoundActive = false
	TimeLimit(false)
	if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
	timer.Simple(3,function() RoundRestart() end)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[RoundActive = false TimeLimit(false) chat.AddText(Color(255,255,255),"==== Forcing round restart in 3 seconds... ====")]])
	end
	print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - ENDED BY COMMAND! Forcing round restart in 3 seconds...")
end,nil,nil,FCVAR_SERVER_CAN_EXECUTE)
concommand.Add("has_extendtime",function(ply,cmd,arg)
	if not ply:IsAdmin() then return end
	if SeekerBlinded then print("[_H&S_] - Round time extension failed. Wait until blind-time finishes.") return end
	if arg[1] == nil then print("[_H&S_] - Round time extension failed. No given argument.") return end
	if type(tonumber(arg[1])) == "number" then
		RoundTimeSave = RoundTimeSave+tonumber(arg[1])
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RoundTimeSave = RoundTimeSave+]]..tonumber(arg[1]))
			v:SendLua([[chat.AddText(Color(200,255,200),"==== Time extended by ]]..arg[1]..[[ seconds! ====")]])
		end
		print("[_H&S_] - Round "..RoundCount.."'s time was extended by "..arg[1].." seconds!")
	else
		print("[_H&S_] - Round time extension failed. Given argument '"..arg[1].."' was not a number.")
	end
end,nil,nil,FCVAR_SERVER_CAN_EXECUTE)

thereisenough = false
lply = NULL
RoundFirstCaught = NULL --is only really used for 'has_choosetype 1'
RoundCount = -1
RoundActive = false
RoundTimeSave = CurTime()
RoundTimer = GetConVarNumber("has_timelimit")

local function HAS_NextLevel()
	local nxmap = (GetConVarString("nextlevel") == "") and game.GetMapNext() or GetConVarString("nextlevel")
	local scores = {}
	for k,v in pairs(player.GetAll()) do
		scores[v:EntIndex()] = v:Frags()
	end
	local winner = Entity(table.GetWinningKey(scores))
	if winner:IsValid() then
		if (winner:Team() == 3 or winner:Team() == 4) then
			winner:SetTeam(2)
			winner:Spawn()
		end
		winner:SetPlayerColor(Vector(1,1,0))
		winner:SetColor(Color(255,200,0))
		winner:SetMaterial("models/shiny")
		winner:SendLua([[InfSta = 1]])
		winner:SetJumpPower(630)
		winner:SetWalkSpeed(350)
		winner:SetRunSpeed(550)
		winner:EmitSound("misc/tf_crowd_walla_intro.wav",80,100)
	end
	
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[surface.PlaySound("music/class_menu_09.wav") GameEnd = true]])
	end
	
	local scont = hook.Call("HASGameEnded",GAMEMODE,winner) --return true to STOP default mapchange
	if scont == true then return end
	
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"Let's vote for the next map.")]])
	end
	timer.Simple(15,function() Jonathan1358.MapVote.Start(nil, nil, nil, nil) end)
end
function CreateLTrail()
	ltrail = ents.Create("env_spritetrail")
	ltrail:SetKeyValue("spritename","trails/laser.vmt")
	ltrail:SetKeyValue("startwidth","50")
	ltrail:SetKeyValue("endwidth","0")
	ltrail:SetKeyValue("rendermode","5")
	ltrail:SetKeyValue("lifetime","1.75")
	ltrail:SetKeyValue("rendercolor","155 155 255")
	ltrail:Spawn()
end
function RoundOutOfTime()
	if RoundActive then
		if lply:IsValid() then lply = NULL end
		ltrail:FollowBone(nil,1)
		ltrail:SetKeyValue("lifetime","0")
		RoundActive = false
		TimeLimit(false)
		hook.Call("HASRoundEndedTime",GAMEMODE)
		timer.Simple(10,function() RoundRestart() end)
		for k,v in pairs(player.GetAll()) do
			if RoundCount > 0 then
				if v:Team() == 1 then v:AddFrags(3) end
			end
			v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") RoundActive = false TimeLimit(false) chat.AddText(Color(155,155,255),"==== The hiding win! ====")]])
		end
		print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - Ran out of time! "..team.NumPlayers(1).." hiding remained.")
	end
end
function RoundCheck(ply)
	if team.NumPlayers(1) == 0 and RoundActive then
		if lply:IsValid() then lply = NULL end
		ltrail:FollowBone(nil,1)
		ltrail:SetKeyValue("lifetime","0")
		RoundActive = false
		TimeLimit(false)
		if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
		hook.Call("HASRoundEndedCaught",GAMEMODE)
		timer.Simple(10,function() RoundRestart() end)
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") RoundActive = false TimeLimit(false) chat.AddText(Color(255,155,155),"==== The seekers win! ====")]])
		end
		print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - All were found with "..string.ToMinutesSeconds(math.Clamp(TimeRemaining,0,5999)).." to spare.")
	end
	if team.NumPlayers(2) == 0 and RoundActive then
		if SeekerBlinded and (#player.GetAll()-team.NumPlayers(3) > 1) then
			if ply != nil and ply:IsValid() then ply:AddFrags(-5) end
			plytab = {}
			table.foreach(player.GetAll(),function(key,val)
				if val:Team() != 3 then 
					table.insert(plytab,val:EntIndex(),val)
				end
			end)
			ranply = table.Random(plytab)
			ranply:SetTeam(2)
			ranply:Spawn()
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(255,255,255),"==== Seeker left! Randomizing seeker. ====")]])
			end
			print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - All seekers left! Choosing new seeker...")
		else
			if lply:IsValid() then lply = NULL end
			ltrail:FollowBone(nil,1)
			ltrail:SetKeyValue("lifetime","0")
			RoundActive = false
			TimeLimit(false)
			if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
			timer.Simple(10,function() RoundRestart() end)
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") RoundActive = false TimeLimit(false) chat.AddText(Color(155,155,255),"==== The hiding win! ====")]])
			end
			print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - All seekers left! Party poopers!")
		end
	end
	if team.NumPlayers(1) == 1 and RoundActive and (not lply:IsValid()) then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then
				lply = v
				v:SendLua([[sprintpower = 100]])
			end
			v:SendLua([[surface.PlaySound("ui/medic_alert.wav") chat.AddText(Color(255,255,255),"==== 1 hider is left! ====")]])
		end
		if GetConVarNumber("has_lasttrail") >= 1 then
			ltrail:FollowBone(lply,1)
			ltrail:SetPos(lply:GetBonePosition(1))
			ltrail:SetKeyValue("lifetime","1.75")
		end
	end
end
function RoundEnoughPlayers()
	if thereisenough then return end
	local plynum = #player.GetAll()-team.NumPlayers(3)
	if (plynum >= math.max(2,GetConVarNumber("has_minplayers"))) and not RoundActive then
		thereisenough = true
		RoundRestart()
	end
end
function RoundRestart()
	local NoSupportedLowGravityMaps = 
	{
		'de_school',
		'de_district23',
		'has_museum',
		'ttt_casino_b2',
		'ttt_titanic',
		'de_icewerk',
		'de_banqiao_r2',
		'ttt_camel_v1a'
	}
	if table.HasValue(NoSupportedLowGravityMaps, game.GetMap()) then
		RunConsoleCommand("sv_gravity", "600") 
		if GetConVarNumber("hostport") == 27040 then
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(255,255,255),"================================================")]])
				v:SendLua([[chat.AddText(Color(255,255,255),"This map doesn't support low gravity. Gravity set to normal.")]])
				v:SendLua([[chat.AddText(Color(255,255,255),"================================================")]])
			end
		end
	end
	if RoundCount >= math.max(GetConVarNumber("has_maxrounds"),1) then HAS_NextLevel() return end
	game.CleanUpMap(false)
	for k,v in pairs(ents.GetAll()) do
		if v:IsWeapon() or v:IsVehicle() then
			if v:GetClass() != "has_hands" then v:Remove() end
		end
	end
	PopulateMap()
	CreateLTrail()
	RestartCount = 0
	if #player.GetAll()-team.NumPlayers(3) == 0 then print("[_H&S_] - There are no players. Aborting...") return end
	if GetConVarNumber("has_choosetype") != 1 or (not RoundFirstCaught:IsValid()) then --if random
		plytab = {}
		table.foreach(player.GetAll(),function(key,val)
			if val:Team() != 3 and val != ranply then 
				table.insert(plytab,val:EntIndex(),val)
			end
		end)
		ranply = table.Random(plytab)
	end
	if GetConVarNumber("has_choosetype") == 1 and RoundFirstCaught:IsValid() then
		ranply = RoundFirstCaught
	end
	if ranply == nil then ranply = player.GetAll()[1] ranply:SetTeam(2) end
	ranply:SetTeam(2)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[InfSta = ]]..GetConVarNumber("has_infinitestamina"))
		if v:Team() != 3 then
			if v != ranply then
				v:SetTeam(1)
			end
			v:Spawn()
			v:SendLua([[sprintpower = 100]])
		end
	end
	hook.Call("HASRoundStarted",GAMEMODE)
	RoundActive = ((#player.GetAll()-team.NumPlayers(3)) >= math.max(2,GetConVarNumber("has_minplayers"))) and true or false
	for k,v in pairs(player.GetAll()) do v:SendLua([[RoundActive = ]]..tostring(RoundActive)) end
	if RoundActive and GetConVarNumber("has_timelimit") < 1 then
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[TimeRemaining = 0]])
		end
	end
	if not RoundActive then
		thereisenough = false
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RoundTimer = 0 TimeRemaining = 0]])
			if v:Team() != 3 then
				v:SendLua([[chat.AddText(Color(255,255,255),"==== We need ]]..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3))..[[ more players to start. ====")]])
			end
		end
	return end
	RoundCount = RoundCount+1
	RoundTimeSave = CurTime()
	RoundTimer = GetConVarNumber("has_timelimit")
	RoundFirstCaught = NULL
	local tsnd = RoundCount.."|"..CurTime().."|"..GetConVarNumber("has_timelimit")
	if team.NumPlayers(1) == 1 then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then lply = v break end
		end
		if GetConVarNumber("has_lasttrail") >= 1 then
			ltrail:FollowBone(lply,1)
			ltrail:SetPos(lply:GetBonePosition(1))
			ltrail:SetKeyValue("lifetime","1.75")
		end
	end
	net.Start("NewRound")
	net.WriteString(tsnd)
	net.Broadcast()
	timer.Simple(0.1,function() TimeLimit(true) end)
	SeekerBlinding(true)
	timer.Create("has_unblind",30.1,1,function() SeekerBlinding(false) end)
	print("[_H&S_] - |============| Round "..RoundCount.." started |============|\n[_H&S_] - "..#player.GetAll()-team.NumPlayers(3).." playing, "..team.NumPlayers(3).." spectating, "..#player.GetAll().." / "..game.MaxPlayers().." online total.\n[_H&S_] - "..ranply:Name().." is SEEKING.")
end
FindMetaTable("Player").Caught = function(entply,sekr)
	if GetConVarNumber("has_seekoncaught") == 1 then
		entply:SetTeam(2)
		entply:AllowFlashlight(true)
		entply:SetWalkSpeed(200)
		entply:SetRunSpeed(360)
		entply:SetPlayerColor(Vector(0.6,0.2,0))
	else
		entply:SetMoveType(0)
		entply:SetSolid(0)
		entply:StripWeapons()
		entply:SetTeam(4)
		entply:SetPlayerColor(Vector(0,0,0))
		local pos = entply:EyePos()
		timer.Simple(4,function() local ang = entply:EyeAngles()
			entply:Spawn() entply:SetPos(pos) entply:SetEyeAngles(ang)
			entply:EmitSound("garrysmod/balloon_pop_cute.wav",90,math.random(125,140))
		end)
	end
	hook.Call("HASPlayerCaught",GAMEMODE,sekr,entply)
	sekr:SendLua([[hook.Call("HASPlayerCaught",GAMEMODE,Entity(]]..sekr:EntIndex()..[[),Entity(]]..entply:EntIndex()..[[))]])
	RoundFirstCaught = (not RoundFirstCaught:IsValid()) and entply or RoundFirstCaught
	entply:EmitSound("physics/body/body_medium_impact_soft7.wav",95,math.random(110,125))
	entply:SendLua([[surface.PlaySound("npc/roller/code2.wav")]])
	timer.Simple(0.1,RoundCheck)
end
local function PushAround(ply,key)
	if key == IN_USE then
		if ply:Team() == 3 or ply:Team() == 4 then return end
		local ent = ply:GetEyeTrace().Entity
		local dis = ply:EyePos():Distance(ply:GetEyeTrace().HitPos)
		if dis <= 72 and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer") then
			if ent:GetPhysicsObject():GetMass() > 35 then
				local ey = -ply:EyeAngles().p
				ent:GetPhysicsObject():Wake()
				if ey >= 2.5 then
					ent:GetPhysicsObject():AddVelocity(ply:GetForward()*56+Vector(0,0,ey*2.33))
				else
					ent:GetPhysicsObject():AddVelocity(ply:GetForward()*66)
				end
			end
		end
	end
end
local function PushBlockers(ply,key)
	if key == IN_USE then
		if ply:Team() == 3 or ply:Team() == 4 then return end
		local ent = ply:GetEyeTrace().Entity
		local dis = ply:EyePos():Distance(ply:GetEyeTrace().HitPos)
		if dis <= 70 and ent:IsPlayer() then
			if ply:Team() == ent:Team() and ent:GetVelocity():Length() <= 40 then
				ent:SetVelocity(ply:GetForward()*82)
			end
		end
	end
end

util.AddNetworkString("ChangeToSpectator")
util.AddNetworkString("ChangeToHiding")
util.AddNetworkString("PLYOption_Gender")
util.AddNetworkString("PLYOption_Change")
util.AddNetworkString("NewRound")
if not file.IsDir("sv_hideandseek","DATA") then
	print("[_H&S_] - A profiles folder was not present. Creating one now...")
	file.CreateDir("sv_hideandseek")
end
CreateLTrail() --to stop it from erroring on the first game

function GM:PlayerDisconnected(ply)
	if lply == ply then lply = NULL end
	ltrail:FollowBone(nil,1)
	ltrail:SetKeyValue("lifetime","0")
	if RoundFirstCaught == ply then RoundFirstCaught = NULL end
	local plynum = #player.GetAll()-team.NumPlayers(3)
	timer.Simple(0.1,RoundCheck)
	if plynum < math.max(2,GetConVarNumber("has_minplayers")) then
		thereisenough = false
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
	end
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	ply:SetDSP(0)
	if (ply:Team() == 3 or ply:Team() == 4) then
		local forceteam = ply:Team()
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply:SetTeam(forceteam)
		ply:SetNoDraw(false)
		ply:SetMaterial("models/effects/vol_light001")
		ply:SetRenderMode(1)
		ply:SetColor(Color(0,0,0,0))
		ply:CrosshairDisable()
		ply:SetAvoidPlayers(false)
		if SeekerBlinded then ply:SendLua([[hook.Remove("RenderScreenspaceEffects","SeekerRestrict")]]) end
		if ply:IsBot() then
			ply:SetTeam(2)
			ply:Spawn()
		end
	else
		ply:SetMaterial("")
		ply:SetRenderMode(0)
		ply:SetColor(Color(255,255,255,255))
		ply:CrosshairEnable()
		ply:SetAvoidPlayers(true)
	end
	local plygender = file.Read("sv_hideandseek/"..string.Replace(ply:SteamID(),":","")..".txt","DATA")
	if plygender == "Female" then
		ply:SetModel("models/player/group01/female_0"..math.random(1,6)..".mdl")
	else
		ply:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	end
	if ply:Team() == 2 then ply:SetPlayerColor(Vector(0.6,0.2,0)) else ply:SetPlayerColor(Vector(0,0.2,0.6)) end
	ply:SetGravity(1)
	ply:SetNoCollideWithTeammates(true) --------------------------------------------------------------------------------------------------------------------------------------------------------
	ply:SetJumpPower(210)
	ply:SetMaxHealth(100,true)
	ply:GodEnable()
	ply:SetCrouchedWalkSpeed(0.4)
	if ply:FlashlightIsOn() then ply:Flashlight(false) end
	if ply:Team() == 2 then
		if SeekerBlinded then ply:SendLua([[hook.Add("RenderScreenspaceEffects","SeekerRestrict",SeekerBK)]]) end
		ply:AllowFlashlight(true)
		ply:SetWalkSpeed(200)
		ply:SetRunSpeed(360)
	else
		ply:AllowFlashlight(false)
		ply:SetWalkSpeed(190)
		ply:SetRunSpeed(320)
	end
	RoundEnoughPlayers()
end

function GM:PlayerLoadout(ply)
	if ply:Team() == 1 or ply:Team() == 2 then
		ply:Give("has_hands")
	end
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(3)
	for k,v in pairs(player.GetAll()) do
		if v != ply then
			--v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(190,240,190)," connected!") LocalPlayer():EmitSound("npc/roller/remote_yes.wav",42,100)]])
			v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(190,240,190)," connected!")]])
		end
	end
	net.Start("NewRound")
	net.WriteString(RoundCount.."|"..CurTime().."|"..GetConVarNumber("has_timelimit").."|"..tostring(RoundActive))
	net.Send(ply)
	SendUserMessage("GenderOption",ply)
end
function GM:PlayerAuthed(ply)
	ply:SendLua([[showHelp() hook.Add("Tick","teamchatcolor",COLOR_TEAM_Retr) RoundCount = ]]..RoundCount..[[ InfSta = ]]..GetConVarNumber("has_infinitestamina"))
	print("[_H&S_] - ("..ply:SteamID()..[[) ]]..ply:Name()..[[ successfully connected! EntID: ']]..ply:EntIndex().."'.")
end

function GM:PlayerDeath(ply,infr,atkr)
	ply:AddFrags(1) --to counter death penalty
end
function GM:CanPlayerSuicide(ply)
	return false
end
function GM:PlayerDeathSound()
	return true
end

function GM:GetFallDamage(ply,spd)
	if not RoundActive then return end
	local time = math.Round(spd/666,1)
	local adda = (string.match(ply:GetModel(),"female")) and "fe" or ""
	local jmp = ply:GetJumpPower()
	if spd >= 600 then
		ply:EmitSound("player/pl_fleshbreak.wav",75,math.random(80,90))
		ply:EmitSound("vo/npc/"..adda.."male01/pain0"..math.random(1,9)..".wav",80,math.random(98,102))
		ply:ViewPunch(Angle(0,math.random(-spd/45,spd/45),0))
		ply:SetJumpPower(85)
		if not ply:KeyDown(IN_SPEED) then ply:SendLua([[sprintSTART() sprintEND()]]) end
		if timer.Exists("HAS_FallRes_"..ply:EntIndex()) then timer.Destroy("HAS_FallRes_"..ply:EntIndex()) end
		timer.Create("HAS_FallRes_"..ply:EntIndex(),time,1,function() if ply:IsValid() then ply:SetJumpPower(jmp) end end)
		hook.Call("HASPlayerFallDamage",GAMEMODE,ply,spd/20)
	end
	if spd >= 760 then
		ply:EmitSound("physics/cardboard/cardboard_box_strain1.wav",75,math.random(100,110))
		ply:SendLua([[sprintpower = math.Clamp(sprintpower-(]]..time..[[*10),0,100)]])
		timer.Simple(math.random(2,4),function()
			if not ply:IsValid() then return end
			local which = math.random(1,5)
			local how = math.random(98,102)
			ply:EmitSound("vo/npc/"..adda.."male01/moan0"..which..".wav",76,how)
			if adda == "fe" then ply:EmitSound("vo/npc/female01/moan0"..which..".wav",100,how) end
		end)
	end
end

function GM:PlayerUse(ply,ent)
	if (ply:Team() == 3 or ply:Team() == 4) then
		return false
	else
		return true
	end
end

function GM:PlayerSpray(ply)
	timer.Simple(2,function()
		if ply:IsValid() then
			ply:AllowImmediateDecalPainting()
		end
	end)
	return false
end

function GM:ShowHelp(ply)
	SendUserMessage("showHelp",ply)
end

function GM:ShowTeam(ply)
	SendUserMessage("TeamSelection",ply)
end

function GM:EntityTakeDamage(ent,dmg) --to trigger_hurts work (if enabled)
	--------------------------------------------------------------------------------------------------------if SeekerBlinded then return end
	if GetConVarNumber("has_envdmgallowed") != 1 then return end
	if ent:IsPlayer() and dmg:GetAttacker():IsValid() then
		if ent:Alive() and dmg:GetAttacker():GetClass() == "trigger_hurt" then
			ent:Kill()
			ent:SetTeam(2)
			timer.Simple(0.1,RoundCheck)
		end
	end
end 

function GM:OnPlayerHitGround(ply,water,floater,spd)
	if not RoundActive then return end
	if spd > 100 and not water then
		local wspd = (ply:Team() == 2) and 200 or 190
		local rspd = (ply:Team() == 2) and 360 or 320
		local longer = (spd >= 600) and 1 or 0
		ply:ViewPunch(Angle(-ply:GetVelocity().z/100,0,0))
		ply:EmitSound("player/jumplanding_zombie.wav",75,math.random(80,100))
		ply:SetWalkSpeed(wspd/1.75)
		ply:SetRunSpeed(wspd)
		timer.Simple(longer+0.2,function() ply:SetWalkSpeed(wspd/1.5) ply:SetRunSpeed(wspd/1.5) end)
		timer.Simple(longer+0.4,function() ply:SetWalkSpeed(wspd/1.25) ply:SetRunSpeed(wspd/1.25) end)
		timer.Simple(longer+0.6,function() ply:SetWalkSpeed(wspd) ply:SetRunSpeed(wspd*1.25) end)
		timer.Simple(longer+0.8,function() ply:SetRunSpeed(rspd) end)
	end
end

function GM:PlayerSay(ply,txt,teamchat)
	local tag = (teamchat) and team.GetName(ply:Team()) or "All"
	print("("..tag..") "..ply:Name()..": "..string.Trim(txt))
	return txt
end

hook.Add("PlayerSay","HAS_ChatCommands",function(ply,txt,teamchat)  --because it broke somehow
	if ply:Team() == 4 and not teamchat then
		--ply:SendLua([[chat.AddText(Color(255,255,255),"You can only talk to other caught players! Use team-chat to talk!") LocalPlayer():EmitSound("misc/halloween/spelltick_02.wav",60,200)]])
		ply:SendLua([[chat.AddText(Color(255,255,255),"You can only talk to other caught players! Use team-chat to talk!")]])
	return "" end
	
	if string.match(string.lower(txt),"^([!/]help)$") then
		ply:ConCommand("has_help")
	end
	if string.match(string.lower(txt),"^([!/]achievements)$") then
		ply:ConCommand("has_achievements")
	end
end)

hook.Add("PlayerSay", "PlayerSayRespawn", function(plr, text)
	if (text == "!respawn" or text == "/respawn") then ---------------------------- Jonathan1358
		if plr:Team() == 2 and RoundActive then
			plr:Spawn()
		else
			plr:SendLua([[chat.AddText(Color(255,155,155),"[I.C.F.] You can't use this command right now.")]])
		end
		return ""
	end
end)

net.Receive("ChangeToSpectator",function(len,ply)
	if ply:Team() == 2 then ---------------------------- Jonathan1358
		ply:SendLua([[chat.AddText(Color(255,155,155),"[I.C.F.] You are in the seeker team. Wait to be in the hiding team before switching to spectator. Type /respawn if you wish to respawn.")]])
		return
	end
	if ply:Team() == 3 then return end
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(200,200,200)," is now spectating!")]])
	end
	ply:SetTeam(3)
	ply:Spawn()
	print("[_H&S_] - "..ply:Name().." changed to SPECTATING team.")
	RoundCheck(ply)
	if #player.GetAll()-team.NumPlayers(3) < math.max(2,GetConVarNumber("has_minplayers")) then
		thereisenough = false
		RoundActive = false
		for k,v in pairs(player.GetAll()) do v:SendLua([[RoundActive = false]]) end
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
		for k,v in pairs(player.GetAll()) do
			if v:Team() != 3 then
				v:SendLua([[chat.AddText(Color(255,255,255),"==== We need ]]..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3))..[[ more players to start. ====")]])
			end
		end
	end
end)
net.Receive("ChangeToHiding",function(len,ply)
	if ply:Team() != 3 then return end
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(200,200,200)," is now playing!")]])
	end
	if GetConVarNumber("has_seekoncaught") == 1 then
		ply:SetTeam(2)
		ply:Spawn()
	else
		ply:SetTeam(4)
	end
	print("[_H&S_] - "..ply:Name().." changed to "..string.upper(team.GetName(ply:Team())).." team.")
	RoundCheck(ply)
	if #player.GetAll()-team.NumPlayers(3) < math.max(2,GetConVarNumber("has_minplayers")) then
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
		for k,v in pairs(player.GetAll()) do
			if v:Team() != 3 then
				v:SendLua([[chat.AddText(Color(255,255,255),"==== We need ]]..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3))..[[ more players to start. ====")]])
			end
		end
	end
end)
net.Receive("PLYOption_Gender",function(len,ply)
	local gender = net.ReadString()
	local steamid = string.Replace(ply:SteamID(),":" or "_","")
	if file.Exists("sv_hideandseek/"..steamid..".txt","DATA") then
		file.Write("sv_hideandseek/"..steamid..".txt",gender)
	else
		file.Write("sv_hideandseek/"..steamid..".txt","Male")
	end	
end)
net.Receive("PLYOption_Change",function(len,ply)
	SendUserMessage("GenderOption",ply)
	ply:SendLua([[chat.AddText(Color(200,200,200),"Your options have been successfully saved!")]])
end)

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")
hook.Add("player_connect","SV_ShowConnect",function(db)
	for k,v in pairs(player.GetAll()) do
		--v:SendLua([[chat.AddText(Color(255,255,255),"]]..db.name..[[",Color(220,220,160)," started connecting...") LocalPlayer():EmitSound("npc/turret_floor/deploy.wav",42,100)]])
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..db.name..[[",Color(220,220,160)," started connecting...")]])
	end
	print("[_H&S_] - ("..db.networkid..") "..db.name.." started joining with the IP '"..db.address.."'.")
end)
hook.Add("player_disconnect","SV_ShowDisconnect",function(db)
	local rea = (string.Trim(db.reason) == "" or db.reason == "Disconnect by user.") and "" or " ("..string.Trim(db.reason)..")"
	local svrea = (string.Trim(db.reason) == "" or db.reason == "Disconnect by user.") and "no reason" or "the reason '"..string.Trim(db.reason).."'"
	--for k,v in pairs(player.GetAll()) do
	--	v:SendLua([[chat.AddText(Color(255,255,255),"]]..db.name..[[",Color(240,190,190)," left!]]..rea..[[") LocalPlayer():EmitSound("npc/turret_floor/retract.wav",42,100)]])
	--end
	print("[_H&S_] - ("..db.networkid..") "..db.name.." left with "..svrea..".")
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------hook.Add("KeyPress","has_pushprops",PushAround)
hook.Add("KeyPress","has_pushplayers",PushBlockers)
hook.Add("Tick","has_sprintdropobj",function()
	for k,v in pairs(player.GetAll()) do
		if v:Alive() or (v:Team() == 1 or v:Team() == 2) then
			if v:KeyDown(IN_SPEED) and v:GetVelocity():Length() >= 300 then
				v:DropObject()
			end
		end
	end
end)
-- hook.Add("Tick","has_antistuck",function()
	-- for k,v in pairs(player.GetAll()) do
		-- if v:Team() == 1 or v:Team() == 2 then
			-- local dkn = (v:KeyDown(IN_DUCK) or v:Crouching()) and 58 or 70
			-- for _,p in pairs(ents.FindInBox(v:GetPos()+Vector(14,14,2),v:GetPos()+Vector(-14,-14,dkn))) do
				-- if p != v and p:IsPlayer() and (p:Team() == v:Team()) then
					-- v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					-- v:SetRenderMode(1)
					-- v:SetColor(Color(v:GetColor().r,v:GetColor().g,v:GetColor().b,235))
					-- if timer.Exists("HAS_AntiStuck_"..v:EntIndex()) then timer.Destroy("HAS_AntiStuck_"..v:EntIndex()) end
					-- timer.Create("HAS_AntiStuck_"..v:EntIndex(),0.25,1,function()
						-- v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
						-- v:SetRenderMode(0)
						-- v:SetColor(Color(v:GetColor().r,v:GetColor().g,v:GetColor().b,255))
					-- end)
					-- break
				-- end
			-- end
		-- end
	-- end
-- end)