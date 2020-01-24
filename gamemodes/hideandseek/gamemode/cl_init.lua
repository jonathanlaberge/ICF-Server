include("shared.lua")
include("sh_anims.lua")
include("mapprops/mapprops_cl.lua")
include("achievements/achievements_sh.lua")
include("achievements/achievements_cl.lua")

--Option saves
if not file.Exists("hideandseek/gender.txt","DATA") then
	file.CreateDir("hideandseek")
	file.Write("hideandseek/gender.txt","Male")
end

if not file.Exists("hideandseek/notifsound.txt","DATA") then
	file.Write("hideandseek/notifsound.txt","None")
elseif string.match(file.Read("hideandseek/notifsound.txt","DATA"),".wav$") then
	file.Write("hideandseek/notifsound.txt","Click")
end

if not file.Exists("hideandseek/staminacol.txt","DATA") then
	file.Write("hideandseek/staminacol.txt","DEFAULT")
end

if not file.Exists("hideandseek/visual.txt","DATA") then
	file.Write("hideandseek/visual.txt","true")
end

if not file.Exists("hideandseek/scobsort.txt","DATA") then
	file.Write("hideandseek/scobsort.txt","0")
end
------------

local OptionsOpen = false

has_ver = "v1.2b"
firsthelp = true
COLOR_TEAM_Retr = function()
	if LocalPlayer():Team() == nil then return end
	teamrgb = team.GetColor(LocalPlayer():Team())
	COLOR_TEAM = Color(teamrgb["r"]*2,teamrgb["g"]*2,teamrgb["b"]*2)
end
COLOR_ALL = Color(255,255,255)
sprintpower = 100
InfSta = GetConVarNumber("has_infinitestamina")
RoundTimeSave = 0
RoundTimer = 0
RoundCount = "[ ? ]"
RoundActive = false
GameEnd = false
ScoBFocus = false
ScoBIsShowing = false
function sprintSTART()
	timer.Destroy("has_sprintregen")
	timer.Destroy("has_sprintregendelay")
	timer.Create("has_sprintdrain",0.055,0,function()
		local xm = LocalPlayer():GetVelocity():Length2D()
		if xm >= 65 then
			sprintpower = math.Clamp(sprintpower-1,0,100)
		end
	end)
end
function sprintEND()
	timer.Destroy("has_sprintdrain")
	timer.Create("has_sprintregendelay",2,1,function()
		timer.Create("has_sprintregen",0.05,0,function()
			sprintpower = math.Clamp(sprintpower+0.4,0,100)
			if sprintpower >= 100 then timer.Destroy("has_sprintregen") end
		end)
	end)
end
local function chatping()
	timer.Simple(0.05,function()
		local ssn = tostring(file.Read("hideandseek/notifsound.txt","DATA"))
		if not (ssn == "None" or ssn == nil) then
			surface.PlaySound(notifsnds[ssn])
		end
	end)
end
local function SpectatorCams()
	if file.Read("hideandseek/visual.txt","DATA") == "true" then
		for k,v in pairs(player.GetAll()) do
			if (LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4) then
				if v != LocalPlayer() and (v:Team() == 3 or v:Team() == 4) then
					render.Model({model="models/tools/camera/camera.mdl",pos=v:EyePos(),angle=v:EyeAngles()})
				end
			end
		end
	end
end
function ScoBRefreshIt()
	if ScoBBase:IsValid() then ScoBBase:Close() end
	ScoBShow()
end
function ScoBHide()
	timer.Destroy("ScoBRefresh")
	ScoBFocus = false
	ScoBIsShowing = false
	if ScoBBase:IsValid() then ScoBBase:Close() end
end
function ScoBShow()
	local specs = {}
	ScoBIsShowing = true
	ScoBBase = vgui.Create("DFrame")
	ScoBBase:SetPos(0,0)
	ScoBBase:SetSize(ScrW(),ScrH())
	ScoBBase:SetTitle("")
	ScoBBase:ShowCloseButton(false)
	ScoBBase:SetDraggable(false)
	if ScoBFocus then
		ScoBBase:MakePopup()
		ScoBBase:SetKeyBoardInputEnabled(false)
	end
	ScoBBase.Paint = function()
		draw.RoundedBox(0,0,0,ScoBBase:GetWide(),ScoBBase:GetTall(),Color(0,0,0,0))
	end
	ScoBHead = vgui.Create("DFrame",ScoBBase)
	ScoBHead:SetPos(ScrW()/2-400,80)
	ScoBHead:SetSize(800,40)
	ScoBHead:SetTitle("")
	ScoBHead:ShowCloseButton(false)
	ScoBHead:SetDraggable(false)
	ScoBHead.Paint = function()
		draw.RoundedBox(16,0,0,ScoBHead:GetWide(),ScoBHead:GetTall(),Color(0,0,0,200))
	end
	ScoBHeader1 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader1:SetPos(612,6)
	ScoBHeader1:SetColor(Color(255,255,255,255))
	ScoBHeader1:SetFont("DermaLarge")
	ScoBHeader1:SetText("Hide and Seek")
	ScoBHeader1:SizeToContents()
	ScoBHeader2_1 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_1:SetPos(12,5)
	ScoBHeader2_1:SetColor(Color(255,255,255,255))
	ScoBHeader2_1:SetFont("DermaDefault")
	ScoBHeader2_1:SetText(GetHostName())
	ScoBHeader2_1:SizeToContents()
	ScoBHeader2_2 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_2:SetPos(12,20)
	ScoBHeader2_2:SetColor(Color(255,255,255,255))
	ScoBHeader2_2:SetFont("DermaDefault")
	ScoBHeader2_2:SetText(game.GetMap())
	ScoBHeader2_2:SizeToContents()
	ScoBHeader2_3 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_3:SetPos(575,20)
	ScoBHeader2_3:SetColor(Color(255,255,255,255))
	ScoBHeader2_3:SetFont("DermaDefault")
	ScoBHeader2_3:SetText(has_ver)
	ScoBHeader2_3:SizeToContents()
	ScoBHeader2_4 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_4:SetPos(495,20)
	ScoBHeader2_4:SetColor(Color(255,255,255,255))
	ScoBHeader2_4:SetFont("DermaDefault")
	ScoBHeader2_4:SetText(#player.GetAll().." / "..game.MaxPlayers())
	ScoBHeader2_4:SizeToContents()
	ScoBHeaderP_1 = vgui.Create("DImage",ScoBHead)
	ScoBHeaderP_1:SetPos(555,19)
	ScoBHeaderP_1:SetImage("icon16/server_uncompressed.png")
	ScoBHeaderP_1:SizeToContents()
	ScoBHeaderP_2 = vgui.Create("DImage",ScoBHead)
	ScoBHeaderP_2:SetPos(475,19)
	ScoBHeaderP_2:SetImage("icon16/status_offline.png")
	ScoBHeaderP_2:SizeToContents()
	ScoBHeaderSc = vgui.Create("DButton",ScoBHead)
	ScoBHeaderSc:SetSize(173,26)
	ScoBHeaderSc:SetPos(612,6)
	ScoBHeaderSc:SetText("")
	ScoBHeaderSc.Paint = function()
		draw.RoundedBox(0,0,0,ScoBHeaderSc:GetWide(),ScoBHeaderSc:GetTall(),Color(0,0,0,0))
	end
	ScoBHeaderSc.DoClick = function(DermaButton)
		RunConsoleCommand("has_help")
		surface.PlaySound("garrysmod/content_downloaded.wav")
		timer.Simple(0.1,function() ScoBHide() end)
	end
	ScoBHeaderSc.DoRightClick = function(DermaButton)
		timer.Destroy("ScoBRefresh")
		local ScoBHeadMenu = vgui.Create("DMenu",ScoBHead)
		ScoBHeadMenu:AddOption("Open Help",function()
			RunConsoleCommand("has_help")
			surface.PlaySound("garrysmod/content_downloaded.wav")
			timer.Simple(0.1,function() ScoBHide() end)
		end):SetImage("icon16/information.png")
		ScoBHeadMenu:AddOption("Open Options",function()
			RunConsoleCommand("has_options")
			surface.PlaySound("garrysmod/content_downloaded.wav")
			timer.Simple(0.1,function() ScoBHide() end)
		end):SetImage("icon16/cog_edit.png")
		ScoBHeadMenu:AddOption("Open Achievements",function()
			RunConsoleCommand("has_achievements")
			surface.PlaySound("garrysmod/content_downloaded.wav")
			timer.Simple(0.1,function() ScoBHide() end)
		end):SetImage("icon16/table.png")
		ScoBHeadMenu:AddSpacer()
		local sb,mb = ScoBHeadMenu:AddSubMenu("Sort")
			sb:AddOption("By EntityID",function()
				file.Write("hideandseek/scobsort.txt","0")
				timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
				surface.PlaySound("garrysmod/ui_return.wav")
			end):SetImage("icon16/brick.png")
			mb:SetImage("icon16/image_link.png")
			sb:AddOption("By Alphabetical",function()
				file.Write("hideandseek/scobsort.txt","1")
				timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
				surface.PlaySound("garrysmod/ui_return.wav")
			end):SetImage("icon16/font.png")
			sb:AddOption("By Score",function()
				file.Write("hideandseek/scobsort.txt","2")
				timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
				surface.PlaySound("garrysmod/ui_return.wav")
			end):SetImage("icon16/medal_gold_1.png")
		ScoBHeadMenu:Open()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	
	local sorttab = player.GetAll()
	if file.Read("hideandseek/scobsort.txt","DATA") == "1" then
		table.sort(sorttab,function(a,b) return a:Name() < b:Name() end)
	elseif file.Read("hideandseek/scobsort.txt","DATA") == "2" then
		table.sort(sorttab,function(a,b) return a:Frags() > b:Frags() end)
	end
	local n = 0
	for k,v in pairs(sorttab) do
		if v:Team() != 3 then
			n = n+1
			local size = (team.NumPlayers(3) > 0 and n < 5) and 550 or 724
			local ScoBPly = vgui.Create("DFrame",ScoBBase)
			ScoBPly:SetPos(ScrW()/2-365,84+(38*n))
			ScoBPly:SetSize(size,36)
			ScoBPly:SetTitle("")
			ScoBPly:ShowCloseButton(false)
			ScoBPly:SetDraggable(false)
			ScoBPly.Think = function()
				local achflash = (math.sin(CurTime()*2.5)*12)+55
				local acol = (v.IsAchMaster == true) and Color(achflash,achflash*0.8,0,200) or Color(0,0,0,200)
				ScoBPly.Paint = function()
					draw.RoundedBox(4,0,0,ScoBPly:GetWide(),ScoBPly:GetTall(),acol)
				end
			end
			if v.IsAchMaster == true then
				for i=0,2 do
					local q = (i == 1) and 113 or 111
					local ScoBPlyAchh = vgui.Create("DImage",ScoBBase)
					ScoBPlyAchh:SetPos(ScrW()/2-352+(i*15),q+(38*n))
					ScoBPlyAchh:SetSize(9,9)
					ScoBPlyAchh:SetImage("icon16/star.png")
				end
			end
			local ScoBPlyA = vgui.Create("AvatarImage",ScoBPly)
			ScoBPlyA:SetSize(32,32)
			ScoBPlyA:SetPos(2,2)
			ScoBPlyA:SetPlayer(v,32)
			local ScoBPlyAB = vgui.Create("DButton",ScoBPly)
			ScoBPlyAB:SetSize(32,32)
			ScoBPlyAB:SetPos(2,2)
			ScoBPlyAB:SetText("")
			ScoBPlyAB.Paint = function()
				draw.RoundedBox(0,0,0,ScoBPlyAB:GetWide(),ScoBPlyAB:GetTall(),Color(0,0,0,0))
			end
			ScoBPlyAB.DoClick = function(DermaButton)
				v:ShowProfile()
				surface.PlaySound("garrysmod/content_downloaded.wav")
				timer.Simple(0.1,function() ScoBHide() end)
			end
			ScoBPlyAB.DoRightClick = function(DermaButton)
				timer.Destroy("ScoBRefresh")
				local ScoBPlyABMenu = vgui.Create("DMenu",ScoBPly)
				ScoBPlyABMenu:AddOption("Show Profile",function()
					v:ShowProfile()
					surface.PlaySound("garrysmod/content_downloaded.wav")
					timer.Simple(0.1,function() ScoBHide() end)
				end):SetImage("icon16/report_go.png")
				ScoBPlyABMenu:AddSpacer()
				if v:IsMuted() then
					ScoBPlyABMenu:AddOption("Unmute",function()
					v:SetMuted(false)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_return.wav")
					end):SetImage("icon16/sound.png")
				else
					ScoBPlyABMenu:AddOption("Mute",function()
					v:SetMuted(true)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_hover.wav")
					end):SetImage("icon16/sound_mute.png")
				end
				ScoBPlyABMenu:Open()
				surface.PlaySound("garrysmod/ui_click.wav")
			end
			local ScoBPlyN_1 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_1:SetPos(40,4)
			if v:SteamID() == "STEAM_0:0:33106902" then ScoBPlyN_1:SetColor(Color(245,210,125,255)) else ScoBPlyN_1:SetColor(Color(255,255,255,255)) end
			ScoBPlyN_1:SetFont("DermaDefaultBold")
			ScoBPlyN_1:SetText(v:Name())
			ScoBPlyN_1:SizeToContents()
			local ScoBPlyN_2 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_2:SetPos(40,18)
			ScoBPlyN_2:SetColor(Color(255,255,255,255))
			ScoBPlyN_2:SetFont("DermaDefault")
			ScoBPlyN_2:SetText("Score: "..v:Frags())
			ScoBPlyN_2:SizeToContents()
			local ScoBPlyN_3 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_3:SetPos(ScoBPly:GetWide()-24,11)
			ScoBPlyN_3:SetColor(Color(255,255,255,255))
			ScoBPlyN_3:SetFont("DermaDefault")
			ScoBPlyN_3:SetText(v:Ping())
			ScoBPlyN_3:SizeToContents()
			local ScoBPlyP = vgui.Create("DImage",ScoBPly)
			ScoBPlyP:SetPos(ScoBPly:GetWide()-44,10)
			if v:Ping() > 5 then ScoBPlyP:SetImage("icon16/transmit_blue.png") else ScoBPlyP:SetImage("icon16/server_connect.png") end
			ScoBPlyP:SizeToContents()
			if v:GetFriendStatus() != "none" then
				local ScoBPlyPF = vgui.Create("DImage",ScoBPly)
				ScoBPlyPF:SetPos(ScoBPly:GetWide()-72,10)
				if v:GetFriendStatus() == "blocked" then ScoBPlyPF:SetImage("icon16/exclamation.png") else ScoBPlyPF:SetImage("icon16/user_add.png") end
				ScoBPlyPF:SizeToContents()
			end
			if v == LocalPlayer() then
				local ScoBPlyY = vgui.Create("DImage",ScoBPly)
				ScoBPlyY:SetPos(ScoBPly:GetWide()-72,10)
				ScoBPlyY:SetImage("icon16/asterisk_orange.png")
				ScoBPlyY:SizeToContents()
			end
			if v:IsMuted() then
				local ScoBPlyPM = vgui.Create("DImage",ScoBPly)
				ScoBPlyPM:SetPos(ScoBPly:GetWide()-100,10)
				ScoBPlyPM:SetImage("icon16/sound_mute.png")
				ScoBPlyPM:SizeToContents()
			end
			if LocalPlayer():Team() != 1 then
				local ScoBPlyPT = vgui.Create("DImage",ScoBPly)
				ScoBPlyPT:SetPos(255,10)
				if v:Team() == 1 then ScoBPlyPT:SetImage("icon16/flag_blue.png") end
				if v:Team() == 2 then ScoBPlyPT:SetImage("icon16/flag_red.png") end
				if v:Team() == 4 and LocalPlayer():Team() != 2 then ScoBPlyPT:SetImage("icon16/camera_delete.png") end
				ScoBPlyPT:SizeToContents()
			end
		else
			table.insert(specs,v)
		end
	end
	if team.NumPlayers(3) > 0 then
		local ScoBSpec = vgui.Create("DFrame",ScoBBase)
		ScoBSpec:SetPos(ScrW()/2+187,122)
		ScoBSpec:SetSize(172,150)
		ScoBSpec:SetTitle("")
		ScoBSpec:ShowCloseButton(false)
		ScoBSpec:SetDraggable(false)
		ScoBSpec.Paint = function()
			draw.RoundedBox(4,0,0,ScoBSpec:GetWide(),ScoBSpec:GetTall(),Color(0,0,0,200))
		end
		local ScoBSpecP = vgui.Create("DImage",ScoBSpec)
		ScoBSpecP:SetPos(8,4)
		ScoBSpecP:SetImage("icon16/camera_go.png")
		ScoBSpecP:SizeToContents()
		local ScoBSpecT = vgui.Create("DLabel",ScoBSpec)
		ScoBSpecT:SetPos(30,4)
		ScoBSpecT:SetColor(Color(255,255,255,255))
		ScoBSpecT:SetFont("DermaDefaultBold")
		ScoBSpecT:SetText("Spectators:")
		ScoBSpecT:SizeToContents()
		for k,v in pairs(specs) do
			local y = 6+(k*16)
			local ScoBSpecPlyA = vgui.Create("AvatarImage",ScoBSpec)
			ScoBSpecPlyA:SetSize(14,14)
			ScoBSpecPlyA:SetPos(8,y)
			ScoBSpecPlyA:SetPlayer(v,16)
			local ScoBSpecPlyAB = vgui.Create("DButton",ScoBSpec)
			ScoBSpecPlyAB:SetSize(14,14)
			ScoBSpecPlyAB:SetPos(8,y)
			ScoBSpecPlyAB:SetText("")
			ScoBSpecPlyAB.Paint = function()
				draw.RoundedBox(0,0,0,ScoBSpecPlyAB:GetWide(),ScoBSpecPlyAB:GetTall(),Color(0,0,0,0))
			end
			ScoBSpecPlyAB.DoClick = function(DermaButton)
				v:ShowProfile()
				surface.PlaySound("garrysmod/content_downloaded.wav")
				timer.Simple(0.1,function() ScoBHide() end)
			end
			ScoBSpecPlyAB.DoRightClick = function(DermaButton)
				timer.Destroy("ScoBRefresh")
				local ScoBSpecPlyABMenu = vgui.Create("DMenu",ScoBPly)
				ScoBSpecPlyABMenu:AddOption("Show Profile",function()
					v:ShowProfile()
					surface.PlaySound("garrysmod/content_downloaded.wav")
					timer.Simple(0.1,function() ScoBHide() end)
				end):SetImage("icon16/report_go.png")
				ScoBSpecPlyABMenu:AddSpacer()
				if v:IsMuted() then
					ScoBSpecPlyABMenu:AddOption("Unmute",function()
					v:SetMuted(false)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_return.wav")
					end):SetImage("icon16/sound.png")
				else
					ScoBSpecPlyABMenu:AddOption("Mute",function()
					v:SetMuted(true)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_hover.wav")
					end):SetImage("icon16/sound_mute.png")
				end
				ScoBSpecPlyABMenu:Open()
				surface.PlaySound("garrysmod/ui_click.wav")
			end
			local ScoBSpecN = vgui.Create("DLabel",ScoBSpec)
			ScoBSpecN:SetPos(26,y)
			ScoBSpecN:SetColor(Color(255,255,255,255))
			ScoBSpecN:SetFont("DermaDefault")
			ScoBSpecN:SetText(v:Name())
			ScoBSpecN:SizeToContents()
		end
	end
end

function GM:Tick()
	if sprintpower <= 4 then
		RunConsoleCommand("-speed")
	end
	if InfSta == 1 then sprintpower = 100 end
end

function GM:KeyPress(ply,key)
	if ply == LocalPlayer() and key == IN_ATTACK2 then
		if ply:KeyDown(IN_SCORE) then
			ScoBFocus = true
			ScoBBase:MakePopup()
			ScoBBase:SetKeyBoardInputEnabled(false)
		end
	end
	if ply == LocalPlayer() and key == IN_SPEED then
		if sprintpower <= 4 then return end
		if (InfSta == 1 or (ply:Team() == 3 or ply:Team() == 4)) then return end
		if LocalPlayer():GetVelocity().x >= 40 or LocalPlayer():GetVelocity().y >= 40 then
			sprintpower = math.Clamp(sprintpower-1,0,100)
		end
		sprintSTART()
	end
end
function GM:KeyRelease(ply,key)
	if ply == LocalPlayer() and key == IN_SPEED then
		sprintEND()
	end
	if ply == LocalPlayer() and (key == IN_ATTACK or key == IN_ATTACK2) and CCFocus then
		DermaPanelX:SetMouseInputEnabled(true)
		DermaPanelX:SetKeyboardInputEnabled(true)
		CCFocus = false
	end
end

function GM:HUDShouldDraw(hud)
	if not (hud == "CHudWeaponSelection" or hud == "CHudHealth" or hud == "CHudBattery" or hud == "CHudPoisonDamageIndicator" or hud == "CHudZoom") then
		return true
	end
end

function GM:HUDPaint()
	local me = LocalPlayer()
	
	--Name and Stamina
	local themed = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and false or true
	local sta = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and team.GetColor(me:Team()) or string.Explode(",",file.Read("hideandseek/staminacol.txt","DATA"))
	local backcol = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and Color(0,0,0,200) or Color(sta[1]/3,sta[2]/3,sta[3]/3,200)
	local alpha = math.sin(CurTime()*6)*50+100
	local spec1 = (me:Team() == 3 or me:Team() == 4) and 80 or 32
	draw.RoundedBoxEx(16,20,ScrH()-80,200,spec1,backcol,true,true,false,false)
	draw.SimpleTextOutlined(me:Name(),"DermaDefaultBold",32,ScrH()-70,team.GetColor(me:Team()),0,1,2,Color(10,10,10,100))
	draw.SimpleTextOutlined(team.GetName(me:Team()),"DermaDefault",32,ScrH()-56,team.GetColor(me:Team()),0,1,2,Color(10,10,10,100))
	if me:Team() == 3 then draw.SimpleTextOutlined("F2 to switch teams","DermaDefaultBold",32,ScrH()-12,team.GetColor(me:Team()),0,1,2,Color(10,10,10,100)) end
	if not (me:Team() == 3 or me:Team() == 4) then
		draw.RoundedBoxEx(16,20,ScrH()-48,308,32,backcol,false,true,false,true)
		draw.RoundedBox(12,24,ScrH()-44,300,24,Color(0,0,0,200))
		if sprintpower > 4 then
			if file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT" then
				draw.RoundedBox(12,24,ScrH()-44,sprintpower*3,24,Color(sta.r,sta.g,sta.b,alpha))
			else
				draw.RoundedBox(12,24,ScrH()-44,sprintpower*3,24,Color(math.min((sta[1]+team.GetColor(me:Team()).r)/2,255),math.min((sta[2]+team.GetColor(me:Team()).g)/2,255),math.min((sta[3]+team.GetColor(me:Team()).b)/2,255),alpha))
			end
		end
		if InfSta == 1 then draw.SimpleText("I N F I N I T E","DermaLarge",172,ScrH()-31,Color(10,10,10,180),1,1) end
		draw.RoundedBox(0,20,ScrH()-16,200,16,backcol)
	end
	
	if (not firsthelp) then
		local ent = me:GetEyeTrace().Entity
		if ent:IsValid() and ent:IsPlayer() then
			if (ent:Team() == me:Team() or ent:GetPos():Distance(me:GetPos()) <= 550) or (not RoundActive) then
				draw.SimpleTextOutlined(ent:Name(),"DermaLarge",ScrW()/2,ScrH()/2+50,team.GetColor(ent:Team()),1,1,2,Color(10,10,10,100))
				draw.SimpleTextOutlined(team.GetName(ent:Team()),"DermaDefaultBold",ScrW()/2,ScrH()/2+70,team.GetColor(ent:Team()),1,1,2,Color(10,10,10,100))
			end
		end
	end
	
	--Time and Round
	local col = (RoundTimer < 1) and Color(100,100,100,255) or Color(255,255,255,255)
	local rtxt = (RoundCount == -1) and "Waiting for players..." or "Round "..RoundCount
	rtxt = (RoundCount == 0) and "Warm-up Round" or rtxt
	draw.RoundedBoxEx(16,20,0,128,72,backcol,false,false,true,true)
	draw.SimpleTextOutlined(rtxt,"DermaDefault",32,48,Color(255,255,255,255),0,1,2,Color(10,10,10,100))
	if TimeRemaining != nil then draw.SimpleTextOutlined(string.ToMinutesSeconds(math.Clamp(TimeRemaining,0,5999)),"DermaLarge",32,24,TimerColor,0,1,2,Color(10,10,10,100)) else draw.SimpleTextOutlined("00:00","DermaLarge",32,24,Color(100,100,100,255),0,1,2,Color(10,10,10,100)) end
	
	--Blindtime stuffs
	if SeekerBlinded then
		local BlindTime = math.max(TimeRemaining-RoundTimer,1)
		local TCorrect = (BlindTime == 1) and " second" or " seconds"
		local NCorrect = (me:Team() == 2) and "You" or "Seekers"
		draw.RoundedBoxEx(16,ScrW()/2-100,0,200,72,backcol,false,false,true,true)
		draw.SimpleTextOutlined(NCorrect.." will be unblinded in...","DermaDefault",ScrW()/2,24,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(BlindTime..TCorrect,"DermaDefault",ScrW()/2,40,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
	end
	
	--Most Score notice (GameEnd)
	if GameEnd then
		local scores = {}
		for k,v in pairs(player.GetAll()) do
			scores[v:Name()] = v:Frags()
		end
		local winner = (table.GetWinningKey(scores) == me:Name()) and table.GetWinningKey(scores).." (You!)" or table.GetWinningKey(scores)
		draw.RoundedBoxEx(16,ScrW()/2-200,0,400,72,backcol,false,false,true,true)
		draw.SimpleTextOutlined(winner,"DermaLarge",ScrW()/2,24,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined("had the most points with "..scores[table.GetWinningKey(scores)].."!","DermaDefaultBold",ScrW()/2,48,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
	end
	
	--Team Markers
	if not (me:Team() == 3 or me:Team() == 4) then
		for k,v in pairs(player.GetAll()) do
			if v != me and v:Team() == me:Team() then
				local col = team.GetColor(me:Team())
				
				local brge = (SeekerBlinded) and 1850 or 1225
				local alp = (me:Team() == 1) and -400+math.Clamp(me:GetPos():Distance(v:GetPos()),0,600)-(math.Clamp(me:GetPos():Distance(v:GetPos()),brge,brge+600)-brge) or -400+math.Clamp(me:GetPos():Distance(v:GetPos()),0,600)
				
				local arrowpos = (v:LookupBone("ValveBiped.Bip01_Head1") != nil) and v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))+Vector(0,0,12+math.Round(me:GetPos():Distance(v:GetPos())/50)) or v:GetPos()+Vector(0,0,78+math.Round(me:GetPos():Distance(v:GetPos())/50))
				local arrowscrpos = arrowpos:ToScreen()
				draw.SimpleTextOutlined("v","DermaLarge",tonumber(arrowscrpos.x),tonumber(arrowscrpos.y),Color(col.r,col.g,col.b,alp),1,1,2,Color(0,0,0,alp/3))
			end
		end
	end
	
	--Mouse Focus notice
	if ScoBIsShowing and (not ScoBFocus) then
		local bndi = (input.LookupBinding("+attack2") == nil) and "MOUSE2" or input.LookupBinding("+attack2")
		draw.SimpleTextOutlined("Use '"..bndi.."' (+attack2) to get mouse focus.","CloseCaption_Normal",ScrW()-24,ScrH()-30,Color(255,255,255,255),2,1,2,Color(10,10,10,100))
	end
	
	--Stuck-Player Notice
	if (me:Team() == 1 or me:Team() == 2) and me:GetCollisionGroup() == COLLISION_GROUP_WEAPON then
		draw.SimpleTextOutlined("Stuck prevention active...","DermaDefaultBold",ScrW()/2,ScrH()/2+128,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
	end
end

function GM:PlayerBindPress(ply,bind,prd)
	if ply == LocalPlayer() and (ply:Team() == 3 or ply:Team() == 4) then
		if string.match(bind,"+use") then return true end
	end
end

function GM:ChatText(plyi,plyn,txt,msg)
	if msg == "joinleave" then
		return true
	end
end
function GM:OnPlayerChat(ply,txt,teamchat,deadchat)
	if ply:IsValid() then
		if teamchat then
			if LocalPlayer():Team() == ply:Team() then
				chat.AddText(team.GetColor(ply:Team()),ply:Name(),COLOR_ALL,": ",COLOR_TEAM,string.Trim(txt))
				chatping()
			end
		else
			chat.AddText(team.GetColor(ply:Team()),ply:Name(),COLOR_ALL,": "..string.Trim(txt))
			chatping()
		end
	else
		chat.AddText(Color(40,40,40,255),"CONSOLE",Color(200,200,200,255),": "..string.Trim(txt))
		chatping()
	end
	return true
end

function GM:ScoreboardShow()
	if not ScoBIsShowing then ScoBShow() end
	timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
	return true
end
function GM:ScoreboardHide()
	ScoBHide()
end

local function teamSelect()
	_CreateAchVars()
	Derma_Query("What would you like to be doing?","Team Selection",
	"Hiding",function()
		net.Start("ChangeToHiding")
		net.SendToServer()
		if LocalPlayer():Team() == 3 then sprintpower = 100 end
		surface.PlaySound("garrysmod/save_load4.wav")
	end,"Spectating",function()
		net.Start("ChangeToSpectator")
		net.SendToServer()
		surface.PlaySound("garrysmod/save_load2.wav")
	end)
end
local function genderCheck()
	if file.Exists("hideandseek/gender.txt","DATA") then
		gender = tostring(file.Read("hideandseek/gender.txt","DATA"))
	else
		gender = "Male"
	end
	net.Start("PLYOption_Gender")
	net.WriteString(gender)
	net.SendToServer()
end
local function editOptions()
	if OptionsOpen then return end
	OptionsOpen = true
	local gender = (file.Read("hideandseek/gender.txt","DATA") == "Female") and 2 or 1
	local sound = table.KeyFromValue(notifsnds,file.Read("hideandseek/notifsound.txt","DATA"))
	local tstam = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and 1 or 0
	local stamina = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and string.Explode(",","255,0,0") or string.Explode(",",file.Read("hideandseek/staminacol.txt","DATA"))
	local showcams = (file.Read("hideandseek/visual.txt","DATA") == "true") and true or false
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(300,300)
	DermaPanel:SetPos(45,ScrH()/2.5)
	DermaPanel:SetTitle("Hide and Seek - Options")
	DermaPanel:SetScreenLock(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:SetMouseInputEnabled(true)
	DermaPanel:SetKeyboardInputEnabled(true)
	DermaPanel:MakePopup()
	local DermaImage1 = vgui.Create("DImage",DermaPanel)
	DermaImage1:SetPos(10,29)
	DermaImage1:SetImage("icon16/user.png")
	DermaImage1:SizeToContents()
	local DermaLabel1 = vgui.Create("DLabel",DermaPanel)
	DermaLabel1:SetPos(28,30)
	DermaLabel1:SetColor(Color(255,255,255,255))
	DermaLabel1:SetFont("DermaDefault")
	DermaLabel1:SetText("Gender:")
	DermaLabel1:SizeToContents()
	local DermaList1 = vgui.Create("DComboBox",DermaPanel)
	DermaList1:SetPos(8,45)
	DermaList1:SetSize(65,20)
	DermaList1:ChooseOption(file.Read("hideandseek/gender.txt","DATA"),gender)
	DermaList1:AddChoice("Male")
	DermaList1:AddChoice("Female")
	DermaList1.OnMousePressed = function()
		DermaList1:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaList1.OnSelect = function(index,value,data)
		genderchoice = (data == "Female") and 2 or 1
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaImage2 = vgui.Create("DImage",DermaPanel)
	DermaImage2:SetPos(10,68)
	DermaImage2:SetImage("icon16/comments.png")
	DermaImage2:SizeToContents()
	local DermaLabel2 = vgui.Create("DLabel",DermaPanel)
	DermaLabel2:SetPos(28,68)
	DermaLabel2:SetColor(Color(255,255,255,255))
	DermaLabel2:SetFont("DermaDefault")
	DermaLabel2:SetText("Chat Ping:")
	DermaLabel2:SizeToContents()
	local DermaList2 = vgui.Create("DComboBox",DermaPanel)
	DermaList2:SetPos(8,83)
	DermaList2:SetSize(202,20)
	DermaList2:ChooseOption(file.Read("hideandseek/notifsound.txt","DATA"),sound)
	table.foreach(notifsnds,function(key,value)
		DermaList2:AddChoice(key)
	end)
	DermaList2.OnMousePressed = function()
		DermaList2:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaList2.OnSelect = function(index,value,data)
		soundchoice = data
		if value != "None" then
			surface.PlaySound(notifsnds[data])
		end
	end
	local DermaImage3 = vgui.Create("DImage",DermaPanel)
	DermaImage3:SetPos(10,106)
	DermaImage3:SetImage("icon16/color_wheel.png")
	DermaImage3:SizeToContents()
	local DermaLabel3 = vgui.Create("DLabel",DermaPanel)
	DermaLabel3:SetPos(28,106)
	DermaLabel3:SetColor(Color(255,255,255,255))
	DermaLabel3:SetFont("DermaDefault")
	DermaLabel3:SetText("Theme Color:")
	DermaLabel3:SizeToContents()
	local DermaColorM = vgui.Create("DColorMixer",DermaPanel)
	if tstam == 1 then DermaColorM:SetPos(300,141) else DermaColorM:SetPos(8,141) end
	DermaColorM:SetSize(50,80)
	if file.Read("hideandseek/staminacol.txt","DATA") != "DEFAULT" then DermaColorM:SetColor(Color(stamina[1],stamina[2],stamina[3])) end
	DermaColorM:SetPalette(false)
	DermaColorM:SetAlphaBar(false)
	DermaColorM:SetWangs(true)
	local DermaColorB = vgui.Create("DButton",DermaPanel)
	DermaColorB:SetSize(80,20)
	DermaColorB:SetPos(8,122)
	if tstam == 1 then DermaColorB:SetText("Team Color") else DermaColorB:SetText("Set Color") end
	DermaColorB.DoClick = function(DermaButton)
		surface.PlaySound("garrysmod/ui_hover.wav")
		if tstam == 0 then
			tstam = 1
			DermaColorB:SetText("Team Color")
			DermaColorM:SetPos(300,141)
		else
			tstam = 0
			DermaColorB:SetText("Set Color")
			DermaColorM:SetPos(8,141)
		end
	end
	local DermaCheckBox = vgui.Create("DCheckBox",DermaPanel)
	DermaCheckBox:SetPos(8,216)
	DermaCheckBox:SetChecked(showcams)
	DermaCheckBox.OnChange = function()
		showcams = not showcams
	end
	local DermaLabel4 = vgui.Create("DLabel",DermaPanel)
	DermaLabel4:SetPos(28,217)
	DermaLabel4:SetColor(Color(255,255,255,255))
	DermaLabel4:SetFont("DermaDefault")
	DermaLabel4:SetText("Show spectators?")
	DermaLabel4:SizeToContents()
	local DermaButton1 = vgui.Create("DButton",DermaPanel)
	DermaButton1:SetSize(197,20)
	DermaButton1:SetPos(8,272)
	DermaButton1:SetText("Confirm")
	DermaButton1.DoClick = function(DermaButton)
		OptionsOpen = false
		local genderf = (genderchoice == nil) and file.Read("hideandseek/gender.txt","DATA") or DermaList1:GetOptionText(genderchoice)
		local soundf = (soundchoice == nil) and file.Read("hideandseek/notifsound.txt","DATA") or soundchoice
		local colorf = (tstam == 0) and DermaColorM:GetColor() or "DEFAULT"
		file.Write("hideandseek/gender.txt",genderf)
		file.Write("hideandseek/notifsound.txt",soundf)
		if tstam == 0 then
			file.Write("hideandseek/staminacol.txt",colorf.r..","..colorf.g..","..colorf.b)
		else
			file.Write("hideandseek/staminacol.txt",colorf)
		end
		file.Write("hideandseek/visual.txt",tostring(showcams))
		DermaPanel:Close()
		surface.PlaySound("garrysmod/save_load3.wav")
		net.Start("PLYOption_Change")
		net.SendToServer()
	end
	local DermaButton2 = vgui.Create("DButton",DermaPanel)
	DermaButton2:SetSize(77,20)
	DermaButton2:SetPos(213,272)
	DermaButton2:SetText("Cancel")
	DermaButton2.DoClick = function(DermaButton)
		OptionsOpen = false
		DermaPanel:Close()
		surface.PlaySound("garrysmod/ui_return.wav")
	end
end

function showHelp()
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600,400)
	DermaPanel:SetPos(25,ScrH()/4)
	DermaPanel:SetTitle("Hide and Seek - Help")
	DermaPanel:SetScreenLock(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:SetMouseInputEnabled(true)
	DermaPanel:SetKeyboardInputEnabled(true)
	DermaPanel:MakePopup()
	local DermaPropSheet = vgui.Create("DPropertySheet",DermaPanel)
	DermaPropSheet:SetSize(580,326)
	DermaPropSheet:SetPos(10,30)
	local DermaButton1 = vgui.Create("DButton",DermaPanel)
	DermaButton1:SetSize(200,30)
	DermaButton1:SetPos(10,360)
	DermaButton1:SetText("Let's play!")
	DermaButton1.DoClick = function(DermaButton)
		DermaPanel:Close()
		if firsthelp then teamSelect() end
		firsthelp = false
		surface.PlaySound("garrysmod/save_load3.wav")
	end
	local DermaButton2 = vgui.Create("DButton",DermaPanel)
	DermaButton2:SetSize(80,30)
	DermaButton2:SetPos(510,360)
	DermaButton2:SetText("Options")
	DermaButton2.DoClick = function(DermaButton)
		if OptionsOpen then return end
		editOptions()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaTab1 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab1:SetPos(5,20)
	DermaTab1:SetSize(570,281)
	DermaTab1.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab1:GetWide(),DermaTab1:GetTall())
	end
	local DermaLabel1_1 = vgui.Create("DLabel",DermaTab1)
	DermaLabel1_1:SetPos(10,10)
	DermaLabel1_1:SetColor(Color(255,255,255,255))
	DermaLabel1_1:SetFont("DermaLarge")
	DermaLabel1_1:SetText("Welcome to Hide and Seek!")
	DermaLabel1_1:SizeToContents()
	local DermaLabel1_2 = vgui.Create("DLabel",DermaTab1)
	DermaLabel1_2:SetPos(10,50)
	DermaLabel1_2:SetColor(Color(255,255,255,255))
	DermaLabel1_2:SetFont("DermaDefault")
	DermaLabel1_2:SetText("You've probably heard of the classic game of 'Hide and Seek', right? It's pretty much those very same rules!\n\nThere are two teams, the hiders and the seekers.\nHiding players have to hide away from the seekers while seeking players have to find the hiding\nplayers, simple! Now go play some good old Hide and Seek.\n\n\nHide and Seek buttons -\nF1 = Opens this help-box, click other tabs for more help!\nF2 = Opens team select.\nRELOAD = Taunt.\n\nPossible requirements -\n'Team Fortress 2' to fully hear gamemode audio.\n'Counter-Strike: Source' for maps that servers could host.\n'Left 4 Dead' to have a nice landing sound, not so important.")
	DermaLabel1_2:SizeToContents()
	local DermaTab2 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab2:SetPos(5,20)
	DermaTab2:SetSize(570,281)
	DermaTab2.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab2:GetWide(),DermaTab2:GetTall())
	end
	local DermaLabel2_1 = vgui.Create("DLabel",DermaTab2)
	DermaLabel2_1:SetPos(10,10)
	DermaLabel2_1:SetColor(Color(255,255,255,255))
	DermaLabel2_1:SetFont("DermaLarge")
	DermaLabel2_1:SetText("Hiding!")
	DermaLabel2_1:SizeToContents()
	local DermaLabel2_2 = vgui.Create("DLabel",DermaTab2)
	DermaLabel2_2:SetPos(10,50)
	DermaLabel2_2:SetColor(Color(255,255,255,255))
	DermaLabel2_2:SetFont("DermaDefault")
	DermaLabel2_2:SetText("Hiding players are marked with blue name tags and blue clothes. Fellow hiders\nwill also have blue markers over their heads, but only when you're close\nenough to them!\n\nUse clever spots to keep out of seekers' sights!\nWhen choosing open hiding spots, think about your escape routes!\nTry not to waste your sprint when escaping seekers!\nTry to trick seekers that are chasing you as they can run slightly faster than you!\n\n\nLanding after jumping will cause a short slowdown. But be careful, falling a\ngreat height will make you let out a yelp, giving seekers an idea of your position!\nFalling from even bigger heights will affect your stamina too!")
	DermaLabel2_2:SizeToContents()
	local DermaModel1 = vgui.Create("DModelPanel",DermaTab2)
	DermaModel1:SetSize(250,250)
	DermaModel1:SetPos(360,8)
	DermaModel1:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	DermaModel1:SetAnimated(true)
	DermaModel1:SetAnimSpeed(1)
	function DermaModel1:LayoutEntity() self:RunAnimation() end
	function DermaModel1.Entity:GetPlayerColor() return Vector(0,0.2,0.6) end
	local DermaTab3 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab3:SetPos(5,20)
	DermaTab3:SetSize(570,281)
	DermaTab3.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab3:GetWide(),DermaTab3:GetTall())
	end
	local DermaLabel3_1 = vgui.Create("DLabel",DermaTab3)
	DermaLabel3_1:SetPos(10,10)
	DermaLabel3_1:SetColor(Color(255,255,255,255))
	DermaLabel3_1:SetFont("DermaLarge")
	DermaLabel3_1:SetText("Seeking!")
	DermaLabel3_1:SizeToContents()
	local DermaLabel3_2 = vgui.Create("DLabel",DermaTab3)
	DermaLabel3_2:SetPos(10,50)
	DermaLabel3_2:SetColor(Color(255,255,255,255))
	DermaLabel3_2:SetFont("DermaDefault")
	DermaLabel3_2:SetText("Seeking players are marked with red name tags and red clothes.\nFellow seekers will also have red markers over their heads!\nYou can catch hiders by running into them or clicking them while close!\n\nCheck simple hiding spots as well as hard-to-reach places!\nUse your sprint when you're chasing hiders!\nWatch your teammates' arrows, if they are all in one spot,\nthey could be chasing someone! Team up with other seekers to quickly cover an area!\nDon't give up on chasing someone, you have a slight speed advantage over hiders!\n\n\nLanding after jumping will cause a short slowdown. But be careful, falling a\ngreat height will make you let out a yelp, letting hiders know you're close!\nFalling from even bigger heights will affect your stamina too!\nYou are also able to use a flashlight to find hiders in dark places.")
	DermaLabel3_2:SizeToContents()
	local DermaModel2 = vgui.Create("DModelPanel",DermaTab3)
	DermaModel2:SetSize(250,250)
	DermaModel2:SetPos(360,8)
	DermaModel2:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	DermaModel2:SetAnimated(true)
	DermaModel2:SetAnimSpeed(1)
	function DermaModel2:LayoutEntity() self:RunAnimation() end
	function DermaModel2.Entity:GetPlayerColor() return Vector(0.6,0.2,0) end
	local DermaTab4 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab4:SetPos(5,20)
	DermaTab4:SetSize(570,281)
	DermaTab4.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab4:GetWide(),DermaTab4:GetTall())
	end
	local DermaLabel4_1 = vgui.Create("DLabel",DermaTab4)
	DermaLabel4_1:SetPos(10,10)
	DermaLabel4_1:SetColor(Color(255,255,255,255))
	DermaLabel4_1:SetFont("DermaLarge")
	DermaLabel4_1:SetText("Spectating!")
	DermaLabel4_1:SizeToContents()
	local DermaLabel4_2 = vgui.Create("DLabel",DermaTab4)
	DermaLabel4_2:SetPos(10,50)
	DermaLabel4_2:SetColor(Color(255,255,255,255))
	DermaLabel4_2:SetFont("DermaDefault")
	DermaLabel4_2:SetText("Spectating is for when you want to take a break and want to stay in the server.\nIn some servers, you would have to spectate when you're caught and\nwait for the next round to start playing again.\n\nWhile spectating, you can... I don't know... think about future hiding spots?\nBut don't ghost for other players. Because that's a silly move...\n\nYou are able to see other spectators if you have 'Show spectators?' ticked\nin your settings menu. You can access it by clicking 'Options' below or by \nrunning 'has_options' in the console.")
	DermaLabel4_2:SizeToContents()
	local DermaModel3 = vgui.Create("DModelPanel",DermaTab4)
	DermaModel3:SetSize(250,250)
	DermaModel3:SetPos(360,8)
	DermaModel3:SetModel("models/tools/camera/camera.mdl")
	DermaModel3:SetCamPos(Vector(25,25,0))
	DermaModel3:SetLookAt(Vector(0,0,0))
	function DermaModel3:LayoutEntity() end
	local DermaTab5 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab5:SetPos(5,20)
	DermaTab5:SetSize(570,281)
	DermaTab5.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab5:GetWide(),DermaTab5:GetTall())
	end
	local DermaLabel5_1 = vgui.Create("DLabel",DermaTab5)
	DermaLabel5_1:SetPos(10,10)
	DermaLabel5_1:SetColor(Color(255,255,255,255))
	DermaLabel5_1:SetFont("DermaLarge")
	DermaLabel5_1:SetText("Achievements!")
	DermaLabel5_1:SizeToContents()
	local DermaLabel5_2 = vgui.Create("DLabel",DermaTab5)
	DermaLabel5_2:SetPos(10,50)
	DermaLabel5_2:SetColor(Color(255,255,255,255))
	DermaLabel5_2:SetFont("DermaDefault")
	DermaLabel5_2:SetText("Hide and Seek now has its own achievements!\nMore achievements are bound to be added at some point, so be prepared.\n\nNow this is where things can get interesting. As you play, you're able to earn achievements!\nThese achievements can give you personal goals and make rounds more exciting.\nWhy not try to get all of the achievements? It's possible, especially when\nyour achievements are saved cross-server! This means you don't need to stay on the\nsame server to earn all of the achievements!\n\nYou can see the achievement list by typing 'has_achievements' in the console.\nOr you can press the button below to view the list.")
	DermaLabel5_2:SizeToContents()
	local DermaLabel5_3 = vgui.Create("DButton",DermaTab5)
	DermaLabel5_3:SetSize(142,25)
	DermaLabel5_3:SetPos(10,205)
	DermaLabel5_3:SetText("View Achievements")
	DermaLabel5_3.DoClick = function()
		local derm = AchieveLBase or NULL
		if derm:IsValid() then return end
		OpenAchievementsList()
		surface.PlaySound("garrysmod/content_downloaded.wav")
	end
	local achtotal = (firsthelp) and "?" or 0
	if (not firsthelp) then
		for k,v in pairs(AchievementList) do
			if LocalPlayer():GetPData("HAS_ACH_EARNED_"..k) == "true" then
				achtotal = achtotal+1
			end
		end
	end
	local DermaLabel5_4 = vgui.Create("DLabel",DermaTab5)
	DermaLabel5_4:SetPos(28,245)
	DermaLabel5_4:SetColor(Color(255,255,255,255))
	DermaLabel5_4:SetFont("DermaDefault")
	DermaLabel5_4:SetText("Achievements earned: "..achtotal.."/"..table.Count(AchievementList))
	DermaLabel5_4:SizeToContents()
	local DermaLabel5_5 = vgui.Create("DImage",DermaTab5)
	DermaLabel5_5:SetPos(10,244)
	DermaLabel5_5:SetImage("icon16/medal_gold_2.png")
	DermaLabel5_5:SizeToContents()
	DermaPropSheet:AddSheet("Welcome",DermaTab1,"icon16/cake.png",false,false,"1 - Welcome to Hide and Seek!")
	DermaPropSheet:AddSheet("Achievements",DermaTab5,"icon16/medal_gold_3.png",false,false,"2 - About achievements.")
	DermaPropSheet:AddSheet("Hiding",DermaTab2,"icon16/user.png",false,false,"3 - About hiding players.")
	DermaPropSheet:AddSheet("Seeking",DermaTab3,"icon16/user_red.png",false,false,"4 - About seeking players.")
	DermaPropSheet:AddSheet("Spectating",DermaTab4,"icon16/camera.png",false,false,"5 - About spectating.")
end

net.Receive("NewRound",function()
	local dt = string.Explode("|",net.ReadString())
	RoundCount = tonumber(dt[1])
	RoundTimeSave = tonumber(dt[2])
	RoundTimer = tonumber(dt[3])
	if dt[4] != nil and tobool(dt[4]) == false then return end
	TimeLimit(true)
end)

hook.Add("PostDrawOpaqueRenderables","SpectatorCameras",SpectatorCams)

usermessage.Hook("showHelp",showHelp)
usermessage.Hook("TeamSelection",teamSelect)
usermessage.Hook("GenderOption",genderCheck)

concommand.Add("has_help",showHelp)
concommand.Add("has_options",editOptions)