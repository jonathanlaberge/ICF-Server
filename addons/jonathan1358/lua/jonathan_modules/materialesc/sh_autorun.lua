--[[---------------------------------------------------------
	MaterialEsc
	
	Copyright © 2015 Szymon (Szymekk) Jankowski
	All Rights Reserved
	Steam: https://steamcommunity.com/id/szymski
-------------------------------------------------------------]]

if SERVER then
	--AddCSLuaFile()
	--AddCSLuaFile("matesc_config.lua")
	--AddCSLuaFile("matcore.lua")

	CreateConVar("mesc_ver", 1, FCVAR_NOTIFY)

	resource.AddFile("materials/matesc/menu.png")
	resource.AddFile("materials/matesc/close.png")
	resource.AddFile("materials/matesc/server.png")
	resource.AddFile("materials/matesc/Sledbuild.png")
	resource.AddFile("materials/matesc/HideandSeek.png")
	resource.AddFile("materials/matesc/Slender.png")
	resource.AddFile("materials/matesc/Cinema.png")
	resource.AddFile("materials/matesc/PropHunt.png")
	resource.AddFile("materials/matesc/MelonBomber.png")

	resource.AddFile("materials/shadow/u.png")
	resource.AddFile("materials/shadow/l.png")
	resource.AddFile("materials/shadow/r.png")
	resource.AddFile("materials/shadow/d.png")

	resource.AddFile("materials/shadow/lu.png")
	resource.AddFile("materials/shadow/ru.png")
	resource.AddFile("materials/shadow/ld.png")
	resource.AddFile("materials/shadow/rd.png")

	return
end

--include("matcore.lua")

--include("matesc_config.lua")
local Config = MESCConfig

--[[------------------------------
	Useful
----------------------------------]]

local MatMenu = Material("matesc/menu.png", "unlitgeneric")
local MatClose = Material("matesc/close.png", "unlitgeneric")
local MatServer = Material("matesc/server.png", "unlitgeneric")

surface.CreateFont("mesc_sname", {
	font = "Roboto",
	size = 38,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 

local function DrawBlur(layers, density, alpha)
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( matcore.mat.Blur )

	for i = 1, 3 do
		matcore.mat.Blur:SetFloat( "$blur", ( i / layers ) * density )
		matcore.mat.Blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
end

--[[----------------------------------
	HTML Panel creation
--------------------------------------]]

local htmlOpened = true -- DEBUG: def false

local function CreateHTMLPanel()
	if IsValid(MESCH) then
		MESCH:Remove()
	end

	-- Main
	MESCH = vgui.Create("DFrame")
	MESCH:SetSize(ScrW()-MESC:GetWide()+16, ScrH())
	MESCH:SetPos(ScrW(), 0)
	function MESCH:Paint(w, h) 
		draw.RoundedBox(0, 0, 0, w, h, Config.Background)
	end
	function MESCH:Think()
		local x, y = self:GetPos()
		self:SetPos(Lerp(FrameTime()*5, x, htmlOpened and MESC:GetWide()-16 or ScrW()+32))
	end

	local parent = MESCH:Add("DPanel")
	parent:SetPos(0,0)
	parent:SetSize(MESCH:GetSize())

	local bar = parent:Add("DPanel")
	bar:Dock(TOP)
	bar:SetHeight(64)
	function bar:Paint(w, h)
		matcore.DrawBoxS(0, 0, w, h-32, Config.BarColor)
		matcore.DrawShadowC(0, 0, w, h-32, false, false, false, true, 4)
		matcore.DrawShadowC(0, 0, w, h-32, false, false, false, true, 4)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(MatClose)
		surface.DrawTexturedRect(0, 0, 32, 32)
	end

	local btn = bar:Add("DButton")
	btn:SetSize(32,32)
	btn:SetText("")
	function btn:Paint() end
	function btn:DoClick()
		Config:ClosePage()
	end

	local dhtml = parent:Add("DHTML")
	MESCH.dhtml = dhtml
	dhtml:DockMargin(0,-32,0,0)
	dhtml:Dock(FILL)

	MESCH:SetPopupStayAtBack(true)
	MESCH:MakePopup()
end

function Config:OpenPage(url)
	if !IsValid(MESCH) then
		CreateHTMLPanel()
	end
	htmlOpened = true
	MESCH.dhtml:OpenURL(url)
	MESCH:SetPopupStayAtBack(true)
	MESCH:MakePopup()
end

function Config:ClosePage()
	htmlOpened = false
	if IsValid(MESCH) then
		MESCH:SetMouseInputEnabled(false)
		MESCH:SetKeyboardInputEnabled(false)
	end
	timer.Simple(2, function()
		if IsValid(MESCH) && !htmlOpened then
			MESCH:Remove()
		end
	end)
end

--[[----------------------------------
	Panel creation
--------------------------------------]]

local function ShowServerList() 
	if IsValid(DIALOG) then DIALOG:Remove() end
	DIALOG = matcore.MakeListDialog(Config.Background, "Servers", Config.DialogHeader, Config.ButtonTextColor, "Connect", "Close", agree, disagree)
	DIALOG:SetAnimSize(600, ScrH() - 50)
	function DIALOG.Disagree:DoClick()
		DIALOG:Remove()
	end
	function DIALOG.Agree:DoClick()
		if !DIALOG.addr then return end
		LocalPlayer():ConCommand("connect " .. DIALOG.addr)
	end
	DIALOG.Agree:SetEnabled(false)

	local allServerItems = { }

	for k, v in pairs(Config.Servers) do
		local pnl = DIALOG:AddItem("DPanel")
		pnl:SetHeight(96)
		function pnl:Paint()

		end
		allServerItems[#allServerItems+1] = pnl
		local btn = matcore.MakeFlatButton(pnl, Config.ButtonBackground, Config.ButtonClickColor, Config.ButtonClickColorCircle, Config.ButtonTextColor, Config.ButtonHoverAnim)
		pnl.btn = btn
		btn:Dock(FILL)
		btn:SetText("")
		function btn:DoClick()
			for k, v in pairs(allServerItems) do
				v.btn.hold = false
			end
			self.hold = true 
			DIALOG.addr = v.addr
			DIALOG.Agree:SetEnabled(true)
		end

		if !v.img || v.img == "" then 
			local img = btn:Add("DPanel")
			img:Dock(LEFT)
			img:SetWidth(96)
			function img:Paint()
				surface.SetDrawColor(Config.ButtonTextColor)
				surface.SetMaterial(MatServer)
				surface.DrawTexturedRect(-16, -16, 128, 128)
			end
		else
			local img = btn:Add("DPanel")
			img:Dock(LEFT)
			img:SetWidth(128)
			img:SetHeight(96) 
			function img:Paint()
			surface.SetDrawColor(Color(255,255,255))
				surface.SetMaterial(v.img)
				surface.DrawTexturedRect(0, 0, 128, 128)
			end
		end

		local name = btn:Add("DLabel")	
		name:DockMargin(16,8,16,4)
		name:Dock(TOP)
		name:SetText(v.name)
		name:SetFont("matcore_dialog_textb")
		name:SetColor(Config.ButtonTextColor)

		local desc = btn:Add("DLabel")
		desc:DockMargin(16,0,16,8)
		desc:Dock(FILL)
		desc:SetWrap(true)
		desc:SetText(v.desc)
		desc:SetFont("matcore_dialog_text")
		desc:SetColor(Config.ButtonTextColor)
		desc:SetContentAlignment(7)
	end
end

local opened = true -- DEBUG: def false

local sw = false

local function CreateHUDPanel()
	if IsValid(MESC) then
		MESC:Remove()
	end

	-- Main
	MESC = vgui.Create("DPanel")
	if !IsValid(MESC) then sw = false return end
	MESC:SetSize(300, ScrH())
	MESC:SetPos(-MESC:GetWide(), 0)
	function MESC:Paint(w, h) 
		draw.RoundedBox(0, 0, 0, w-16, h, Config.Background)

		matcore.DrawShadowC(0, 0, w-16, h, false, false, true, false)
		matcore.DrawShadowC(0, 0, w-16, h, false, false, true, false)
	end
	function MESC:Think()
		local x, y = self:GetPos()
		self:SetPos(Lerp(FrameTime()*5, x, opened and 0 or -MESC:GetWide()-32))
	end

	-- Up info

	if ScrH() < 1000 then
		local sName = MESC:Add("DLabel")
		sName:DockMargin(0,0,16,0)
		sName:Dock(TOP)
		sName:SetHeight(72)
		sName:SetFont("mesc_sname")
		sName:SetText(Config.ServerName)
		sName:SetColor(Config.ServerNameColor)
		sName:SetContentAlignment(5)
	else
		local img = MESC:Add("DHTML")
		img:Dock(TOP)
		img:SetWidth(184)
		img:SetHeight(200) 
		--img:DockMargin(208,0,0,0)
		img:SetContentAlignment(5)
		img:SetHTML([[
			<style>
				img{max-width: 100%; max-height: 100%;display: block;margin-left: auto;margin-right: auto}
			</style>
			<body><img src="https://jolab.me/r/image/Logo.ICF.png"></body>
		]])
	end

	-- Buttons

	local discon = matcore.MakeFlatButton(MESC, Config.ButtonBackground, Color(254, 50, 50, 200), Color(254, 50, 50, 255), Config.ButtonTextColor, Config.ButtonHoverAnim)
	discon:DockMargin(0,180,16,ScrH() > 800 and 200 or 16)
	discon:Dock(BOTTOM)
	discon:SetText("DISCONNECT")
	function discon:DoClick()
		if IsValid(DIALOG) then DIALOG:Remove() end
		DIALOG = matcore.MakeDialog(Config.Background, "Disconnect?", Config.DisconnectMessage, Config.DialogHeader, Config.ButtonTextColor, "YES", "NO")
		DIALOG:SetAnimSize(500,300)
		function DIALOG.Agree:DoClick()
			RunConsoleCommand("disconnect")
		end
		function DIALOG.Disagree:DoClick()
			DIALOG:Remove()
		end
	end

	local con = matcore.MakeFlatButton(MESC, Config.ButtonBackground, Config.ButtonClickColor, Config.ButtonClickColorCircle, Config.ButtonTextColor, Config.ButtonHoverAnim)
	con:DockMargin(0,2,16,16)
	con:Dock(BOTTOM)
	--con:SetText("OPTIONS")
	con:SetText("DEFAULT MENU")
	function con:DoClick()
		timer.Simple(0.2, function()
			opened = false
			if IsValid(DIALOG) then DIALOG:Remove() end
			Config:ClosePage()
			timer.Simple(2, function()
				if IsValid(MESC) && !opened then
					MESC:Remove()
				end
			end)
			gui.EnableScreenClicker(false)
		end)
		timer.Simple(0.2, function()
			--RunConsoleCommand("gamemenucommand", "openoptionsdialog")
			RunConsoleCommand("gamemenucommand", "opengamemenu")
			RunConsoleCommand("gameui_activate")
		end)
	end

	if #Config.Servers > 0 then
		local con = matcore.MakeFlatButton(MESC, Config.ButtonBackground, Config.ButtonClickColor, Config.ButtonClickColorCircle, Config.ButtonTextColor, Config.ButtonHoverAnim)
		con:DockMargin(0,2,16,16)
		con:Dock(BOTTOM)
		con:SetText("SERVERS")
		function con:DoClick()
			timer.Simple(0.2, function()
				ShowServerList()
			end)
		end
	end

	local toAdd = { }

	function Config:_AddButton(table)
		local btn = matcore.MakeFlatButton(MESC, Config.ButtonBackground, Config.ButtonClickColor, Config.ButtonClickColorCircle, Config.ButtonTextColor, Config.ButtonHoverAnim)
		btn:DockMargin(0,2,16,2)
		btn:SetText(table.text)
		btn.DoClick = table.click or btn.DoClick
		btn:Dock(BOTTOM)
	end

	function Config:AddButton(table)
		toAdd[#toAdd+1] = table
	end

	Config:RegisterButtons()

	for i=1, #toAdd do
		Config:_AddButton(toAdd[#toAdd-i+1])
	end

	local con = matcore.MakeFlatButton(MESC, Config.ButtonBackground, Color(100, 254, 100, 200), Color(100, 254, 100, 255), Config.ButtonTextColor, Config.ButtonHoverAnim)
	con:DockMargin(0,2,16,16)
	con:Dock(BOTTOM)
	con:SetText("CONTINUE")
	function con:DoClick()
		timer.Simple(0.2, function()
			opened = false
			if IsValid(DIALOG) then DIALOG:Remove() end
			Config:ClosePage()
			timer.Simple(2, function()
				if IsValid(MESC) && !opened then
					MESC:Remove()
				end
			end)
			gui.EnableScreenClicker(false)
		end)
	end
end

--[[----------------------------------
	Hooks
--------------------------------------]]

--CreateHUDPanel() -- DEBUG
--gui.EnableScreenClicker(true) -- DEBUG

local function RegisterHook() 
	hook.Add("PreRender", "MESCOpen", function()
		if input.IsKeyDown(KEY_ESCAPE) && !sw then
			gui.HideGameUI()
			opened = !opened
			if !opened then	
				timer.Simple(2, function()
					if IsValid(MESC) && !opened then
						MESC:Remove()
					end
				end)
				gui.EnableScreenClicker(false)
				if IsValid(DIALOG) then DIALOG:Remove() end
				Config:ClosePage()
			else
				--Jonathan1358
				--if type(atlaschat.theme) == "table" then				--Jonathan1358
				if not atlaschat == nil then							--Jonathan1358
					local panel = atlaschat.theme.GetValue("panel")		--Jonathan1358
					if ValidPanel(panel) and !panel:IsVisible() then	--Jonathan1358
						CreateHUDPanel()
						gui.EnableScreenClicker(true)
					else												--Jonathan1358
						opened = !opened								--Jonathan1358
					end													--Jonathan1358
				else													--Jonathan1358
					CreateHUDPanel()									--Jonathan1358
					gui.EnableScreenClicker(true)						--Jonathan1358
				end														--Jonathan1358
			end
			sw = true
		end
		if !input.IsKeyDown(KEY_ESCAPE) then sw = false end
		--if input.IsKeyDown(KEY_BACKQUOTE) then gui.HideGameUI() end
	end)
end

hook.Add("HUDPaint", "MESCBlur", function()
	if IsValid(MESC) then
		local x, y = MESC:GetPos()
		local factor = 1-(math.Max(-x,0)/MESC:GetWide())

		DrawBlur(4, 6, 255*factor)
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 185*factor))
	end
end)

local hidden = { "DarkRP_LocalPlayerHUD", "CHudCrosshair", "CHudChat", "DarkRP_HUD", "DarkRP_Hungermod", "CHudHealth", "CHudAmmo", "CHudSecondaryAmmo", "DarkRP_Agenda", "DarkRP_EntityDisplay" }

hook.Add("HUDShouldDraw", "MESCHide", function(name)
	if opened && table.HasValue(hidden, name) then return false end
end)

local lastMatCore = matcore

hook.Add("Tick", "MESCTick", function()
	if Config != MESCConfig then
		Config = MESCConfig
		CreateHUDPanel()
	end

	if lastMatCore != matcore then
		CreateHUDPanel()
		lastMatCore = matcore

	end
end)

hook.Add("CreateMove", "MESCCreateMove", function(cmd)
	if opened then
		cmd:ClearMovement()
	end
end)


--RegisterHook() --DEBUG

hook.Add("InitPostEntity", "MESCLoad", function() 
	RegisterHook()
	timer.Simple(5, function()
		sw = false
		opened = false
	end)
end)