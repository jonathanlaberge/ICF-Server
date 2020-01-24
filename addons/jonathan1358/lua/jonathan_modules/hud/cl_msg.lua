net.Receive("Jonathan1358.Msg.ChatColor", function(len)	 
	RunString(net.ReadString())
end) 

net.Receive("Jonathan1358.Msg.CenterBox", function(len)	 
	local Message = net.ReadString()
	local ColorRed = net.ReadFloat() or 150
	local ColorGreen = net.ReadFloat() or 150
	local ColorBlue = net.ReadFloat() or 150
	local TextColorRed = net.ReadFloat() or 150
	local TextColorGreen = net.ReadFloat() or 150
	local TextColorBlue = net.ReadFloat() or 150
	local Timeout = net.ReadFloat() or 5
	local Line = net.ReadFloat() or 1
	
	if (ColorRed + 15) > 255 then ColorRed = 255 end
	if (ColorGreen + 15) > 255 then ColorGreen = 255 end
	if (ColorBlue + 15) > 255 then ColorBlue = 255 end
	
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(600, 32 * Line)
	Frame:SetTitle("")
	Frame:SetVisible(true)
	Frame:SetDraggable(false)
	Frame:ShowCloseButton(false)
	--Frame:MakePopup()
	Frame:Center()
	Frame.Paint = function()
		draw.RoundedBox(0, 0, 0, Frame:GetWide()-0, Frame:GetTall()-0, Color(ColorRed, ColorGreen, ColorBlue, 150))
		draw.RoundedBox(0, 2, 2, Frame:GetWide()-4, Frame:GetTall()-4, Color(ColorRed + 15, ColorGreen + 15, ColorBlue + 15, 150))
	end
	local Text = vgui.Create("DPanel", Frame)
	Text:SetSize(596, 28 * Line)
	Text:SetPos(2, 2)
	Text.Paint = function() 
		draw.DrawText(Message, "Trebuchet24", Frame:GetWide() / 2, 0, Color(TextColorRed, TextColorGreen, TextColorBlue, 255), 1)
	end
	if Timeout > 0 then 
		timer.Simple(Timeout, function() Frame:Close() end)
	end
	
end) 

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
	self:SetSize(600*self.anim+50, 400*self.anim+50)
	self:Center()
end

function PANEL:Paint(w, h)
	matcore.DrawBoxS(16, 16, w-32, h-32, self.maincolor)
end

derma.DefineControl("JonDialog", "Dialog", PANEL, "DPanel")

function Jonathan1358.Hud.MsgDialog(maincolor, header, text, headerColor, textColor, agreeText, disagreeText, agree, disagree)
	local Dialog = vgui.Create("JonDialog")
	Dialog.Header:SetText(header)
	Dialog.Header:SetColor(headerColor)
	Dialog.Text:SetText(text)
	Dialog.Text:SetColor(textColor)
	Dialog.Agree:SetText(agreeText)
	Dialog.Disagree:SetText(disagreeText)
	Dialog.maincolor = maincolor
	return Dialog
end