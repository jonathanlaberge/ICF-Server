--[[---------------------------------------------------------
	Material Design Core

	Copyright © 2015 Szymon (Szymekk) Jankowski
	All Rights Reserved
	Steam: https://steamcommunity.com/id/szymski
-------------------------------------------------------------]]

if SERVER then return end

matcore = { }
matcore.mat = { }

--[[------------------------------
	Materials
----------------------------------]]

matcore.mat.GradientUp = Material("vgui/gradient-u")
matcore.mat.GradientDown = Material("vgui/gradient-d")
matcore.mat.Blur = Material("pp/blurscreen")

matcore.mat.SU = Material("shadow/u.png", "unlitgeneric")
matcore.mat.SL = Material("shadow/l.png", "unlitgeneric")
matcore.mat.SR = Material("shadow/r.png", "unlitgeneric")
matcore.mat.SD = Material("shadow/d.png", "unlitgeneric")

matcore.mat.SLU = Material("shadow/lu.png", "unlitgeneric")
matcore.mat.SRU = Material("shadow/ru.png", "unlitgeneric")
matcore.mat.SLD = Material("shadow/ld.png", "unlitgeneric")
matcore.mat.SRD = Material("shadow/rd.png", "unlitgeneric")

--[[------------------------------
	Stencil functions
----------------------------------]]

function matcore.StencilStart()
	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS ) 	
	render.SetStencilReferenceValue( 1 )
	render.SetColorModulation( 1, 1, 1 )
end

function matcore.StencilReplace(v)
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue(v or 1)
end

function matcore.StencilEnd()
	render.SetStencilEnable( false )
end

--[[------------------------------
	Circles
----------------------------------]]

function matcore.DrawCircle(posx, posy, radius, color)
	local poly = { }
	local v = 40
	for i = 0, v do
		poly[i+1] = {x = math.sin(-math.rad(i/v*360)) * radius + posx, y = math.cos(-math.rad(i/v*360)) * radius + posy}
	end
	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(poly)
end

--[[------------------------------
	Animations
----------------------------------]]

function matcore.Lerp(t, from, to)
	return Lerp(t*((math.sin(3.14*math.Clamp(from/to,0,1)))*0.8+0.2), from, to)
end

--[[------------------------------
	Material boxes
----------------------------------]]

function matcore.DrawShadowC(x, y, w, h, left, top, right, bottom, cs) 
	surface.SetDrawColor(255, 255, 255, 255)

	local s = cs or 16

	if top then
		local m = {
			{x = x, y = y-s, u = 0, v = 0},
			{x = x+w, y = y-s, u = 1/w/1024, v = 0},
			{x = x+w, y = y-s+s, u = 1/w/1024, v = 1},
			{x = x, y = y-s+s, u = 0, v = 1},
		}
		surface.SetMaterial(matcore.mat.SU)
		surface.DrawPoly(m)
	end

	if right then
		local m = {
			{x = x+w, y = y, u = 0, v = 0},
			{x = x+w+s, y = y, u = 1, v = 0},
			{x = x+w+s, y = y+h, u = 1, v = 1/h/1024},
			{x = x+w, y = y+h, u = 0, v = 1/h/1024},
		}
		surface.SetMaterial(matcore.mat.SR)
		surface.DrawPoly(m)
	end

	if bottom then
		local m = {
			{x = x, y = y+h, u = 0, v = 0},
			{x = x+w, y = y+h, u = 1/w/1024, v = 0},
			{x = x+w, y = y+h+s, u = 1/w/1024, v = 1},
			{x = x, y = y+h+s, u = 0, v = 1},
		}
		surface.SetMaterial(matcore.mat.SD)
		surface.DrawPoly(m)
	end

	if left then
		local m = {
			{x = x-s, y = y, u = 0, v = 0},
			{x = x-s+s, y = y, u = 1, v = 0},
			{x = x-s+s, y = y+h, u = 1, v = 1/h/1024},
			{x = x-s, y = y+h, u = 0, v = 1/h/1024},
		}
		surface.SetMaterial(matcore.mat.SL)
		surface.DrawPoly(m)
	end
end

function matcore.DrawShadow(x, y, w, h) 
	surface.SetDrawColor(255, 255, 255, 255)

	local m = {
		{x = x, y = y-16, u = 0, v = 0},
		{x = x+w, y = y-16, u = 1/w/1024, v = 0},
		{x = x+w, y = y-16+16, u = 1/w/1024, v = 1},
		{x = x, y = y-16+16, u = 0, v = 1},
	}
	surface.SetMaterial(matcore.mat.SU)
	surface.DrawPoly(m)

	local m = {
		{x = x+w, y = y, u = 0, v = 0},
		{x = x+w+16, y = y, u = 1, v = 0},
		{x = x+w+16, y = y+h, u = 1, v = 1/h/1024},
		{x = x+w, y = y+h, u = 0, v = 1/h/1024},
	}
	surface.SetMaterial(matcore.mat.SR)
	surface.DrawPoly(m)

	local m = {
		{x = x, y = y+h, u = 0, v = 0},
		{x = x+w, y = y+h, u = 1/w/1024, v = 0},
		{x = x+w, y = y+h+16, u = 1/w/1024, v = 1},
		{x = x, y = y+h+16, u = 0, v = 1},
	}
	surface.SetMaterial(matcore.mat.SD)
	surface.DrawPoly(m)

	local m = {
		{x = x-16, y = y, u = 0, v = 0},
		{x = x-16+16, y = y, u = 1, v = 0},
		{x = x-16+16, y = y+h, u = 1, v = 1/h/1024},
		{x = x-16, y = y+h, u = 0, v = 1/h/1024},
	}
	surface.SetMaterial(matcore.mat.SL)
	surface.DrawPoly(m)


	surface.SetMaterial(matcore.mat.SLU)
	surface.DrawTexturedRect(x-16, y-16, 16, 16)

	surface.SetMaterial(matcore.mat.SRU)
	surface.DrawTexturedRect(x+w, y-16, 16, 16)

	surface.SetMaterial(matcore.mat.SRD)
	surface.DrawTexturedRect(x+w, y+h, 16, 16)

	surface.SetMaterial(matcore.mat.SLD)
	surface.DrawTexturedRect(x-16, y+h, 16, 16)
end

function matcore.DrawRoundedBoxS(x, y, w, h, col)
	surface.SetDrawColor(col)
	draw.RoundedBox(4, x, y, w, h, col)

	matcore.DrawShadow(x, y, w, h)
end

function matcore.DrawBoxS(x, y, w, h, col)
	surface.SetDrawColor(col)
	draw.RoundedBox(0, x, y, w, h, col)

	matcore.DrawShadow(x, y, w, h)
end

--[[------------------------------
	Flat buttons
----------------------------------]]

surface.CreateFont("matcore_btn", {
	font = "Roboto",
	size = 30,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 

local PANEL = {}

function PANEL:Init()
	self:SetHeight(48)
	self:SetFont("matcore_btn")	
	self:SetColor(self.textColor)

	self.anim = 0
	self.hAnim = 0
	self.mouseX = 0
	self.mouseY = 0

	self.OnClick = function() end
end

function PANEL:Think()
	self.anim = math.Max(self.anim - FrameTime()*8, 0)
	self.hAnim = Lerp(FrameTime()*8, self.hAnim, self:IsHovered() and 1 or 0)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, self.bgColor)

	local factor = math.sin(self.anim)

	draw.RoundedBox(0, 0, 0, w, h, Color(self.clickColor1.r, self.clickColor1.g, self.clickColor1.b, self.clickColor1.a*factor))
	matcore.DrawCircle(self.mouseX, self.mouseY, (3.14-self.anim)*100+10, Color(self.clickColor2.r, self.clickColor2.g, self.clickColor2.b, self.clickColor2.a*math.sin(math.min(self.anim,3.14/2))))

	if self.hold then
		draw.RoundedBox(0, 0, 0, w, h, Color(self.clickColor1.r, self.clickColor2.g, self.clickColor2.b, self.clickColor2.a*0.5*(1-factor)))
	end

	if self.hoverAnim then
		draw.RoundedBox(0, 0, 0, w, h, Color(self.clickColor1.r, self.clickColor1.g, self.clickColor1.b, self.clickColor1.a*0.3*self.hAnim))
	end 
end

function PANEL:UpdateColours(skin)
	self:SetTextStyleColor(self.textColor or Color(140,140,140,200))
end

function PANEL:OnMousePressed()
	self.anim = 3.14
	local x, y = self:LocalToScreen(0, 0)
	local mx, my = gui.MousePos()
	self.mouseX = mx - x
	self.mouseY = my - y

	self:DoClick()
end

derma.DefineControl("MFlatButton", "Flat button", PANEL, "DButton")

function matcore.MakeFlatButton(parent, bgColor, clickColor1, clickColor2, textColor, hoverAnim)
	local btn = parent:Add("MFlatButton")
	btn.bgColor = bgColor
	btn.clickColor1 = clickColor1 or Color(140,140,140,100)
	btn.clickColor2 = clickColor2 or Color(140,140,140,200)
	btn.textColor = textColor or Color(140,140,140,200)
	btn.hoverAnim = hoverAnim
	return btn
end

--[[------------------------------
	Dialogs
----------------------------------]]

surface.CreateFont("matcore_dialog_big", {
	font = "Roboto",
	size = 34,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 

surface.CreateFont("matcore_dialog_text", {
	font = "Roboto",
	size = 26,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 

surface.CreateFont("matcore_dialog_textb", {
	font = "Roboto",
	size = 26,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 

surface.CreateFont("matcore_dialog_btn", {
	font = "Roboto",
	size = 25,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
}) 


local PANEL = {}

function PANEL:Init()
	self:SetSize(0,0)

	self.anim = 0

	self.Header = self:Add("DLabel")
	self.Header:DockMargin(16+24,16+16,16+24,0)
	self.Header:Dock(TOP)
	self.Header:SetWrap(true)
	self.Header:SetFont("matcore_dialog_big")
	self.Header:SetColor(Color(0,0,0))
	self.Header:SetHeight(48)
	self.Header:SetContentAlignment(7)

	self.Text = self:Add("DLabel")
	self.Text:DockMargin(16+24,0,16+24,0)
	self.Text:Dock(FILL)
	self.Text:SetWrap(true)
	self.Text:SetFont("matcore_dialog_text")
	self.Text:SetColor(Color(0,0,0))
	self.Text:SetHeight(48)
	self.Text:SetContentAlignment(7)

	self.Btns = self:Add("DPanel")
	self.Btns:DockMargin(16+8,0,16+8,16+8)
	self.Btns:Dock(BOTTOM)
	self.Btns:SetHeight(48)
	function self.Btns:Paint(w, h) end

	self.Agree = self.Btns:Add("DButton")
	self.Agree:DockMargin(4,8,8,8)
	self.Agree:Dock(RIGHT)
	self.Agree:SetFont("matcore_dialog_btn")
	function self.Agree:Paint(w, h) end
	function self.Agree:UpdateColours()
		if self.Depressed || self.m_bSelected then self:SetTextStyleColor(Color(21, 101, 192)) return end
		self:SetTextStyleColor(Color(33, 150, 243))
	end

	self.Disagree = self.Btns:Add("DButton")
	self.Disagree:DockMargin(4,8,8,8)
	self.Disagree:Dock(RIGHT)
	self.Disagree:SetFont("matcore_dialog_btn")
	function self.Disagree:Paint(w, h) end
	function self.Disagree:UpdateColours()
		if self.Depressed || self.m_bSelected then self:SetTextStyleColor(Color(21, 101, 192)) return end
		self:SetTextStyleColor(Color(33, 150, 243))
	end

	self:MakePopup()
	self:MoveToFront()
end

function PANEL:SetAnimSize(w, h)
	self.targetW = w
	self.targetH = h
end

function PANEL:Think()
	self.anim = Lerp(FrameTime()*6, self.anim, 1)
	self:SetAlpha(255*self.anim)
	self:SetSize(self.targetW*self.anim+50, self.targetH*self.anim+50)
	self:Center()
end

function PANEL:Paint(w, h)
	matcore.DrawBoxS(16, 16, w-32, h-32, self.maincolor)
end

derma.DefineControl("MDialog", "Dialog", PANEL, "DPanel")

function matcore.MakeDialog(maincolor, header, text, headerColor, textColor, agreeText, disagreeText, agree, disagree)
	local dg = vgui.Create("MDialog")
	dg.Header:SetText(header)
	dg.Header:SetColor(headerColor)
	dg.Text:SetText(text)
	dg.Text:SetColor(textColor)
	dg.Agree:SetText(agreeText)
	dg.Disagree:SetText(disagreeText)
	dg.maincolor = maincolor
	return dg
end

--[[------------------------------
	List Dialogs
----------------------------------]]

local PANEL = {}

function PANEL:Init()
	self:SetSize(0,0)

	self.anim = 0

	self.Header = self:Add("DLabel")
	self.Header:DockMargin(16+24,16+16,16+24,0)
	self.Header:Dock(TOP)
	self.Header:SetWrap(true)
	self.Header:SetFont("matcore_dialog_big")
	self.Header:SetColor(Color(0,0,0))
	self.Header:SetHeight(48)
	self.Header:SetContentAlignment(7)

	self.Content = self:Add("DScrollPanel")
	self.Content:DockMargin(16,0,16,0)
	self.Content:Dock(FILL)
	function self.Content:PaintOver(w, h)
		matcore.DrawShadowC(0, 0, w, 0, false, false, false, true)
		matcore.DrawShadowC(0, h, w, 0, false, true, false, false)
	end

	self.Btns = self:Add("DPanel")
	self.Btns:DockMargin(16+8,0,16+8,16+8)
	self.Btns:Dock(BOTTOM)
	self.Btns:SetHeight(48)
	function self.Btns:Paint(w, h) end

	self.Agree = self.Btns:Add("DButton")
	self.Agree:DockMargin(4,8,8,8)
	self.Agree:Dock(RIGHT)
	self.Agree:SetFont("matcore_dialog_btn")
	function self.Agree:Paint(w, h) end
	function self.Agree:UpdateColours()
		if self.m_bDisabled then self:SetTextStyleColor(Color(120, 120, 120)) return end
		if self.Depressed || self.m_bSelected then self:SetTextStyleColor(Color(21, 101, 192)) return end
		self:SetTextStyleColor(Color(33, 150, 243))
	end

	self.Disagree = self.Btns:Add("DButton")
	self.Disagree:DockMargin(4,8,8,8)
	self.Disagree:Dock(RIGHT)
	self.Disagree:SetFont("matcore_dialog_btn")
	function self.Disagree:Paint(w, h) end
	function self.Disagree:UpdateColours()
		if self.Depressed || self.m_bSelected then self:SetTextStyleColor(Color(21, 101, 192)) return end
		self:SetTextStyleColor(Color(33, 150, 243))
	end

	self:MakePopup()
	self:MoveToFront()
end

function PANEL:AddItem(type)
	local pnl = self.Content:Add(type)
	pnl:Dock(TOP)
	return pnl
end

function PANEL:SetAnimSize(w, h)
	self.targetW = w
	self.targetH = h
end

function PANEL:Think()
	self.anim = Lerp(FrameTime()*6, self.anim, 1)
	self:SetAlpha(255*self.anim)
	self:SetSize((self.targetW or 0)*self.anim+50, (self.targetH or 0)*self.anim+50)
	self:Center()
end

function PANEL:Paint(w, h)
	matcore.DrawBoxS(16, 16, w-32, h-32, self.maincolor)
end

derma.DefineControl("MListDialog", "List Dialog", PANEL, "DPanel")

function matcore.MakeListDialog(maincolor, header, headerColor, textColor, agreeText, disagreeText, agree, disagree)
	local dg = vgui.Create("MListDialog")
	dg.Header:SetText(header)
	dg.Header:SetColor(headerColor)
	dg.Agree:SetText(agreeText)
	dg.Agree:SizeToContentsX()
	dg.Disagree:SetText(disagreeText)
	dg.Disagree:SizeToContentsX()
	dg.maincolor = maincolor
	return dg
end