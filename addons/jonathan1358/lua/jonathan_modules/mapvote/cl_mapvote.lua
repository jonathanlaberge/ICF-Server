surface.CreateFont("Jonathan1358.MapVote.VoteFont", {
	font = "Trebuchet MS",
	size = 19,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("Jonathan1358.MapVote.VoteFontCountdown", {
	font = "Tahoma",
	size = 32,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("Jonathan1358.MapVote.VoteSysButton", 
{	font = "Marlett",
	size = 13,
	weight = 0,
	symbol = true,
})

Jonathan1358.MapVote.EndTime = 0
Jonathan1358.MapVote.Panel = false

net.Receive("Jonathan1358.MapVote.MapVoteStart", function()
	Jonathan1358.MapVote.CurrentMaps = {}
	Jonathan1358.MapVote.Allow = true
	Jonathan1358.MapVote.Votes = {}
	
	local amt = net.ReadUInt(32)
	
	for i = 1, amt do
		local map = net.ReadString()
		
		Jonathan1358.MapVote.CurrentMaps[#Jonathan1358.MapVote.CurrentMaps + 1] = map
	end
	
	Jonathan1358.MapVote.EndTime = CurTime() + net.ReadUInt(32)
	timer.Create("Jonathan1358.MapVote.Tick", 1, 0, function() surface.PlaySound("ui/hint.wav") end)
	
	if(IsValid(Jonathan1358.MapVote.Panel)) then
		Jonathan1358.MapVote.Panel:Remove()
	end
	
	Jonathan1358.MapVote.Panel = vgui.Create("Jonathan1358.MapVote.VoteScreen")
	Jonathan1358.MapVote.Panel:SetMaps(Jonathan1358.MapVote.CurrentMaps)
end)

net.Receive("Jonathan1358.MapVote.MapVoteUpdate", function()
	local update_type = net.ReadUInt(3)
	
	if(update_type == Jonathan1358.MapVote.UPDATE_VOTE) then
		local ply = net.ReadEntity()
		
		if(IsValid(ply)) then
			local map_id = net.ReadUInt(32)
			Jonathan1358.MapVote.Votes[ply:SteamID()] = map_id
		
			if(IsValid(Jonathan1358.MapVote.Panel)) then
				Jonathan1358.MapVote.Panel:AddVoter(ply)
			end
		end
	elseif(update_type == Jonathan1358.MapVote.UPDATE_WIN) then	  
		if(IsValid(Jonathan1358.MapVote.Panel)) then
			timer.Remove("Jonathan1358.MapVote.Tick") 
			Jonathan1358.MapVote.Panel:Flash(net.ReadUInt(32))
		end
	end
end)

net.Receive("Jonathan1358.MapVote.MapVoteCancel", function()
	if IsValid(Jonathan1358.MapVote.Panel) then
		Jonathan1358.MapVote.Panel:Remove()
		timer.Remove("Jonathan1358.MapVote.Tick")
	end
end)

net.Receive("Jonathan1358.MapVote.RTVDelay", function()
	chat.AddText(Color(102,255,51), "[RTV]", Color(255,255,255), " The vote has been rocked, map vote will begin on round end")
end)

local PANEL = {}

function PANEL:Init()
	self:ParentToHUD()
	
	self.Canvas = vgui.Create("Panel", self)
	self.Canvas:MakePopup()
	self.Canvas:SetKeyboardInputEnabled(false)
	
	self.countDown = vgui.Create("DLabel", self.Canvas)
	self.countDown:SetTextColor(color_white)
	self.countDown:SetFont("Jonathan1358.MapVote.VoteFontCountdown")
	self.countDown:SetText("")
	self.countDown:SetPos(0, 14)
	
	self.mapList = vgui.Create("DPanelList", self.Canvas)
	self.mapList:SetDrawBackground(false)
	self.mapList:SetSpacing(4)
	self.mapList:SetPadding(4)
	self.mapList:EnableHorizontal(true)
	self.mapList:EnableVerticalScrollbar()
	
	self.closeButton = vgui.Create("DButton", self.Canvas)
	self.closeButton:SetText("")

	self.closeButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowCloseButton", panel, w, h)
	end

	self.closeButton.DoClick = function()
		self:SetVisible(false)
	end

	self.maximButton = vgui.Create("DButton", self.Canvas)
	self.maximButton:SetText("")
	self.maximButton:SetDisabled(true)

	self.maximButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowMaximizeButton", panel, w, h)
	end

	self.minimButton = vgui.Create("DButton", self.Canvas)
	self.minimButton:SetText("")
	self.minimButton:SetDisabled(true)

	self.minimButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowMinimizeButton", panel, w, h)
	end

	self.Voters = {}
end

function PANEL:PerformLayout()
	local cx, cy = chat.GetChatBoxPos()
	
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
	
	local extra = math.Clamp(300, 0, ScrW() - 640)
	self.Canvas:StretchToParent(0, 0, 0, 0)
	self.Canvas:SetWide(640 + extra)
	self.Canvas:SetTall(cy -60)
	self.Canvas:SetPos(0, 0)
	self.Canvas:CenterHorizontal()
	self.Canvas:SetZPos(0)
	
	self.mapList:StretchToParent(0, 90, 0, 0)

	local buttonPos = 640 + extra - 31 * 3

	self.closeButton:SetPos(buttonPos - 31 * 0, 4)
	self.closeButton:SetSize(31, 31)
	self.closeButton:SetVisible(true)

	self.maximButton:SetPos(buttonPos - 31 * 1, 4)
	self.maximButton:SetSize(31, 31)
	self.maximButton:SetVisible(true)

	self.minimButton:SetPos(buttonPos - 31 * 2, 4)
	self.minimButton:SetSize(31, 31)
	self.minimButton:SetVisible(true)
	
end

local heart_mat = Material("icon16/heart.png")
local star_mat = Material("icon16/star.png")
local shield_mat = Material("icon16/shield.png")

function PANEL:AddVoter(voter)
	for k, v in pairs(self.Voters) do
		if(v.Player and v.Player == voter) then
			return false
		end
	end
	
	
	local icon_container = vgui.Create("Panel", self.mapList:GetCanvas())
	local icon = vgui.Create("AvatarImage", icon_container)
	icon:SetSize(16, 16)
	icon:SetZPos(1000)
	icon:SetTooltip(voter:Name())
	icon_container.Player = voter
	icon_container:SetTooltip(voter:Name())
	icon:SetPlayer(voter, 16)

	if Jonathan1358.MapVote.HasExtraVotePower(voter) then
		icon_container:SetSize(40, 20)
		icon:SetPos(21, 2)
		icon_container.img = star_mat
	else
		icon_container:SetSize(20, 20)
		icon:SetPos(2, 2)
	end
	
	icon_container.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))
		
		if(icon_container.img) then
			surface.SetMaterial(icon_container.img)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(2, 2, 16, 16)
		end
	end
	
	table.insert(self.Voters, icon_container)
end

function PANEL:Think()
	for k, v in pairs(self.mapList:GetItems()) do
		v.NumVotes = 0
	end
	
	for k, v in pairs(self.Voters) do
		if(not IsValid(v.Player)) then
			v:Remove()
		else
			if(not Jonathan1358.MapVote.Votes[v.Player:SteamID()]) then
				v:Remove()
			else
				local bar = self:GetMapButton(Jonathan1358.MapVote.Votes[v.Player:SteamID()])
				
				if(Jonathan1358.MapVote.HasExtraVotePower(v.Player)) then
					bar.NumVotes = bar.NumVotes + 2
				else
					bar.NumVotes = bar.NumVotes + 1
				end
				
				if(IsValid(bar)) then
					local CurrentPos = Vector(v.x, v.y, 0)
					local NewPos = Vector((bar.x + bar:GetWide()) - 21 * bar.NumVotes - 2, bar.y + (bar:GetTall() * 0.5 - 10), 0)
					
					if(not v.CurPos or v.CurPos ~= NewPos) then
						v:MoveTo(NewPos.x, NewPos.y, 0.3)
						v.CurPos = NewPos
					end
				end
			end
		end
		
	end
	
	local timeLeft = math.Round(math.Clamp(Jonathan1358.MapVote.EndTime - CurTime(), 0, math.huge))
	
	self.countDown:SetText(tostring(timeLeft or 0).." seconds")
	self.countDown:SizeToContents()
	self.countDown:CenterHorizontal()
end

function PANEL:SetMaps(maps)
	self.mapList:Clear()
	
	for k, v in RandomPairs(maps) do
		local button = vgui.Create("DButton", self.mapList)
		button.ID = k
		button:SetText(v)
		
		button.DoClick = function()
			net.Start("Jonathan1358.MapVote.MapVoteUpdate")
				net.WriteUInt(Jonathan1358.MapVote.UPDATE_VOTE, 3)
				net.WriteUInt(button.ID, 32)
			net.SendToServer()
		end
		
		do
			local Paint = button.Paint
			button.Paint = function(s, w, h)
				local col = Color(255, 255, 255, 10)
				
				if(button.bgColor) then
					col = button.bgColor
				end
				
				draw.RoundedBox(4, 0, 0, w, h, col)
				Paint(s, w, h)
			end
		end
		
		button:SetTextColor(color_white)
		button:SetContentAlignment(4)
		button:SetTextInset(8, 0)
		button:SetFont("Jonathan1358.MapVote.VoteFont")
		
		local extra = math.Clamp(300, 0, ScrW() - 640)
		
		button:SetDrawBackground(false)
		button:SetTall(24)
		button:SetWide(285 + (extra / 2))
		button.NumVotes = 0
		
		self.mapList:AddItem(button)
	end
end

function PANEL:GetMapButton(id)
	for k, v in pairs(self.mapList:GetItems()) do
		if(v.ID == id) then return v end
	end
	
	return false
end

function PANEL:Paint()
	--Derma_DrawBackgroundBlur(self)
	
	local CenterY = ScrH() / 2
	local CenterX = ScrW() / 2
	
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function PANEL:Flash(id)
	self:SetVisible(true)

	local bar = self:GetMapButton(id)
	
	if(IsValid(bar)) then
		timer.Simple(0.0, function() bar.bgColor = Color(0, 255, 255) surface.PlaySound("hl1/fvox/blip.wav") end)
		timer.Simple(0.2, function() bar.bgColor = nil end)
		timer.Simple(0.4, function() bar.bgColor = Color(0, 255, 255) surface.PlaySound("hl1/fvox/blip.wav") end)
		timer.Simple(0.6, function() bar.bgColor = nil end)
		timer.Simple(0.8, function() bar.bgColor = Color(0, 255, 255) surface.PlaySound("hl1/fvox/blip.wav") end)
		timer.Simple(1.0, function() bar.bgColor = Color(100, 100, 100) end)
	end
end

derma.DefineControl("Jonathan1358.MapVote.VoteScreen", "", PANEL, "DPanel")
