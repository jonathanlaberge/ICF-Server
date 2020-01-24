local FriendsCaught = 0

function _CreateAchVars()
	for k,v in pairs(AchievementList) do
		if LocalPlayer():GetPData("HAS_ACH_EARNED_"..k) == nil then
			LocalPlayer():SetPData("HAS_ACH_EARNED_"..k,false)
			if v.prog and LocalPlayer():GetPData("HAS_ACH_PROGRESS_"..k) == nil then
				LocalPlayer():SetPData("HAS_ACH_PROGRESS_"..k,0)
			end
		end
	end
end

function OpenAchievementsList()
	_CreateAchVars()
	AchieveLBase = AchieveLBase or NULL
	if AchieveLBase:IsValid() then return end
	AchieveLBase = vgui.Create("DFrame")
	AchieveLBase:SetPos(45,ScrH()/2-300)
	AchieveLBase:SetSize(600,600)
	AchieveLBase:SetTitle("Hide and Seek - Achievements")
	AchieveLBase:SetScreenLock(true)
	AchieveLBase:ShowCloseButton(false)
	AchieveLBase:MakePopup()
	local AchieveLListing = vgui.Create("DPanel",AchieveLBase)
	AchieveLListing:SetPos(10,33)
	AchieveLListing:SetSize(AchieveLBase:GetWide()-20,AchieveLBase:GetTall()-74)
	AchieveLListing.Paint = function()
		draw.RoundedBox(0,0,0,AchieveLListing:GetWide(),AchieveLListing:GetTall(),Color(50,50,50,255))
	end
	local AchieveLPanel = vgui.Create("DPanel",AchieveLListing)
	AchieveLPanel:SetPos(5,5)
	AchieveLPanel:SetSize(AchieveLListing:GetWide()-26,3000)
	AchieveLPanel.Paint = function()
		draw.RoundedBox(0,0,0,AchieveLPanel:GetWide(),AchieveLPanel:GetTall(),Color(0,0,0,0))
	end
	local _ = 0
	local achtotal = 0
	for k,v in pairs(AchievementList) do
		local AchieveLArea = vgui.Create("DPanel",AchieveLPanel)
		AchieveLArea:SetPos(24,24+(88*_))
		AchieveLArea:SetSize(AchieveLListing:GetWide()-74,80)
		AchieveLArea.Paint = function()
			if LocalPlayer():GetPData("HAS_ACH_EARNED_"..k) == "true" then
				draw.RoundedBox(4,0,0,AchieveLArea:GetWide(),AchieveLArea:GetTall(),Color(120,180,120,255))
			else
				draw.RoundedBox(4,0,0,AchieveLArea:GetWide(),AchieveLArea:GetTall(),Color(140,140,140,255))
			end
		end
		local AchieveImage = (file.Exists("materials/has_achieve/icon_"..string.lower(k)..".png","GAME")) and "has_achieve/icon_"..string.lower(k)..".png" or "icon64/tool.png"
		local AchieveLLine1 = vgui.Create("DImage",AchieveLArea)
		AchieveLLine1:SetPos(8,8)
		AchieveLLine1:SetImage(AchieveImage)
		AchieveLLine1:SizeToContents()
		local AchieveLLine2a = vgui.Create("DLabel",AchieveLArea)
		AchieveLLine2a:SetPos(80,8)
		AchieveLLine2a:SetColor(Color(255,255,255,255))
		AchieveLLine2a:SetFont("Trebuchet24")
		AchieveLLine2a:SetText(v.title)
		AchieveLLine2a:SizeToContents()
		local AchieveLLine2b = vgui.Create("DLabel",AchieveLArea)
		AchieveLLine2b:SetPos(80,34)
		AchieveLLine2b:SetColor(Color(255,255,255,255))
		AchieveLLine2b:SetFont("DermaDefault")
		AchieveLLine2b:SetText(v.desc)
		AchieveLLine2b:SizeToContents()
		if v.prog then
			if v.times == nil then
				Error("'"..k..".times' is a nil value. See the achievements table for '"..k.."'")
				surface.PlaySound("common/warning.wav")
				return
			end
			
			local AchieveLLine3a = vgui.Create("DLabel",AchieveLArea)
			AchieveLLine3a:SetPos(80,52)
			AchieveLLine3a:SetColor(Color(255,255,255,255))
			AchieveLLine3a:SetFont("DermaDefault")
			AchieveLLine3a:SetText(math.Clamp(tonumber(LocalPlayer():GetPData("HAS_ACH_PROGRESS_"..k)),0,v.times).."/"..v.times)
			AchieveLLine3a:SizeToContents()
			local AchieveLLine3b = vgui.Create("DPanel",AchieveLArea)
			AchieveLLine3b:SetPos(150,52)
			AchieveLLine3b:SetSize(AchieveLArea:GetWide()-200,15)
			AchieveLLine3b.Paint = function()
				draw.RoundedBox(0,0,0,AchieveLLine3b:GetWide(),AchieveLLine3b:GetTall(),Color(50,50,50,255))
				draw.RoundedBox(0,0,0,(math.Clamp(tonumber(LocalPlayer():GetPData("HAS_ACH_PROGRESS_"..k)),0,v.times)/v.times*100)*(AchieveLLine3b:GetWide()/100),AchieveLLine3b:GetTall(),Color(200,240,200,255))
			end
		end
		_ = _+1
		achtotal = (LocalPlayer():GetPData("HAS_ACH_EARNED_"..k) == "true") and achtotal+1 or achtotal
	end
	local AchieveLScroller = vgui.Create("DVScrollBar",AchieveLListing)
	AchieveLScroller:SetPos(AchieveLListing:GetWide()-18,2)
	AchieveLScroller:SetSize(16,AchieveLListing:GetTall()-4)
	AchieveLScroller:SetUp(1,(48+(88*_))-AchieveLListing:GetTall())
	AchieveLScroller:SetEnabled(true)
	AchieveLScroller.Think = function()
		AchieveLPanel:SetPos(5,AchieveLScroller:GetOffset()+2)
	end
	local AchieveLExit = vgui.Create("DButton",AchieveLBase)
	AchieveLExit:SetPos(8,AchieveLBase:GetTall()-34)
	AchieveLExit:SetSize(200,26)
	AchieveLExit:SetText("Close")
	AchieveLExit.DoClick = function()
		AchieveLBase:Close()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local AchieveLInfo1 = vgui.Create("DLabel",AchieveLBase)
	AchieveLInfo1:SetPos(218,AchieveLBase:GetTall()-34)
	AchieveLInfo1:SetColor(Color(255,255,255,255))
	AchieveLInfo1:SetFont("Trebuchet24")
	AchieveLInfo1:SetText(achtotal.."/"..table.Count(AchievementList))
	AchieveLInfo1:SizeToContents()
	local cmbar = (LocalPlayer().IsAchMaster == true) and Color(240,240,190,255) or Color(200,240,200,255)
	local AchieveLInfo2 = vgui.Create("DPanel",AchieveLBase)
	AchieveLInfo2:SetPos(306,AchieveLBase:GetTall()-30)
	AchieveLInfo2:SetSize(AchieveLBase:GetWide()-316,15)
	AchieveLInfo2.Paint = function()
		draw.RoundedBox(0,0,0,AchieveLInfo2:GetWide(),AchieveLInfo2:GetTall(),Color(50,50,50,255))
		draw.RoundedBox(0,0,0,(achtotal/table.Count(AchievementList)*100)*(AchieveLInfo2:GetWide()/100),AchieveLInfo2:GetTall(),cmbar)
	end
	if LocalPlayer().IsAchMaster == true then
		local AchieveLGoodie1 = vgui.Create("DImage",AchieveLBase)
		AchieveLGoodie1:SetPos(AchieveLInfo2:GetPos()-6,AchieveLBase:GetTall()-25)
		AchieveLGoodie1:SetImage("icon16/star.png")
		AchieveLGoodie1:SizeToContents()
		local AchieveLGoodie2 = vgui.Create("DImage",AchieveLBase)
		AchieveLGoodie2:SetPos((AchieveLInfo2:GetPos()+AchieveLInfo2:GetWide())-10,AchieveLBase:GetTall()-25)
		AchieveLGoodie2:SetImage("icon16/star.png")
		AchieveLGoodie2:SizeToContents()
	end
end

function CheckAchState()
	if LocalPlayer().IsAchMaster == true then return end
	if firsthelp then return end
	
	local amm = 0
	for k,v in pairs(AchievementList) do
		amm = (LocalPlayer():GetPData("HAS_ACH_EARNED_"..k) == "true") and amm+1 or amm
	end
	
	if amm == table.Count(AchievementList) then
		net.Start("AchieveCL")
		net.WriteString("#PLY_HALL#")
		net.SendToServer()
	end
end

local function __ASpecialE(ply)
	ply:EmitSound("misc/achievement_earned.wav",100,100)
	
	ParticleEffectAttach("bday_confetti",1,ply,0)
	local efft = EffectData()
	efft:SetOrigin(ply:GetPos())
	util.Effect("PhyscannonImpact",efft)
	timer.Create("HAS_Ach_"..ply:EntIndex().."_1",0.4,10,function()
		if not ply:IsValid() then return end
		ParticleEffectAttach("bday_confetti",1,ply,0)
		local efft = EffectData()
		efft:SetOrigin(ply:GetPos())
		util.Effect("PhyscannonImpact",efft)
	end)
	timer.Create("HAS_Ach_"..ply:EntIndex().."_2",0.1,55,function()
		if not ply:IsValid() then return end
		ParticleEffectAttach("bday_confetti_colors",1,ply,0)
		local efft = EffectData()
		efft:SetOrigin(ply:GetPos())
		util.Effect("PhyscannonImpact",efft)
	end)
end

local function AchEff(ply,ach)
	if not ply:IsValid() then return end
	chat.AddText(team.GetColor(ply:Team()),ply:Name(),Color(230,230,230)," has earned ",Color(180,245,180),AchievementList[tostring(ach)]["title"],Color(230,230,230),"!")
	if RoundActive then
		if LocalPlayer():Team() == ply:Team() then
			__ASpecialE(ply)
		end
	else
		__ASpecialE(ply)
	end
end

net.Receive("AchieveSV",function()
	local db = string.Explode("|",net.ReadString())
	
	if db[1] == "#ACH_EARN#" then
		if LocalPlayer():GetPData("HAS_ACH_EARNED_"..db[2]) == "true" then return end
		
		if GetConVarNumber("sv_cheats") <= 0 then
			LocalPlayer():SetPData("HAS_ACH_EARNED_"..db[2],true)
			if (not AchievementList[db[2]]["prog"]) then
				net.Start("AchieveCL")
				net.WriteString("#PLY_CMLT#|"..db[2])
				net.SendToServer()
			end
		else
			timer.Simple(0.8,function()
				chat.AddText(Color(220,100,100),"You could have earned an achievement.\nUnfortunately, cheats have been enabled on this server...")
				LocalPlayer():EmitSound("misc/halloween/spelltick_02.wav",100,34)
				timer.Simple(1.75,function()
					local x = (math.random(1,2) == 1) and 1 or 3
					LocalPlayer():EmitSound("items/halloween/crazy0"..x..".wav")
				end)
			end)
		end
	end
	if db[1] == "#ACH_PROG#" then
		if LocalPlayer():GetPData("HAS_ACH_EARNED_"..db[2]) == "true" then return end
		if GetConVarNumber("sv_cheats") > 0 then return end
		
		local amnt = (db[3] == nil) and 1 or tonumber(db[3])
		LocalPlayer():SetPData("HAS_ACH_PROGRESS_"..db[2],tonumber(LocalPlayer():GetPData("HAS_ACH_PROGRESS_"..db[2]))+amnt)
		
		if tonumber(LocalPlayer():GetPData("HAS_ACH_PROGRESS_"..db[2])) >= AchievementList[db[2]]["times"] then
			net.Start("AchieveCL")
			net.WriteString("#PLY_CMLT#|"..db[2])
			net.SendToServer()
		end
	end
	
	if db[1] == "#ACH_CELE#" then
		AchEff(Entity(db[2]),db[3])
	end
end)

usermessage.Hook("CheckAchState",CheckAchState)
usermessage.Hook("FriendsCaughtSetup",function() FriendsCaught = 0 end)

concommand.Add("has_achievements",OpenAchievementsList)

--Achievement earning hooks and stuff (CLIENT)
hook.Add("HASPlayerCaught","ACH_FRNDSCHR",function(ply,vic)
	if vic:GetFriendStatus() == "friend" then
		FriendsCaught = FriendsCaught+1
	end
	
	if FriendsCaught >= 3 then
		net.Start("AchieveCL")
		net.WriteString("#PLY_CMLT#|FRNDSCHR|true")
		net.SendToServer()
	end
end)