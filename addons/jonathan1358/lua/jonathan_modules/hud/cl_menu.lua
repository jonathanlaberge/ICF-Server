function Jonathan1358.Hud.MenuFrame(data)
	local MotdButtons = 
	{
		{
			Text	= "Rules",
			Link = "https://jolab.me/icf//thread-1.html",
			r = 114, v = 159, b = 255,
		},
		{
			Text	= "Motd",
			Link = "https://jolab.me/cmd/gm.motd?nomusic",
			r = 255, v = 255, b = 255,
		},
		{
			Text	= "Forum",
			Link = "https://jolab.me/icf/",
			r = 45, v = 35, b = 225,
		},
		{
			Text	= "Servers",
			Link = "https://jolab.me/icf//serversboard.php",
			r = 251, v = 255, b = 52,
		},
		-- {
			-- Text	= "Admin list",
			-- Link = "http://jonathan1358.tk/cmd/gm.motd.adminlist",
			-- r = 255, v = 51, b = 51,
		-- },
	}
	--##########################################
	--#AAAAAAAAA#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#BBBBBBBBB#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--#CCCCCCCCC#DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD#
	--##########################################
	
	
	--ABCD
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(ScrW(), ScrH())
	Frame:SetTitle("")
	Frame:SetVisible(true)
	Frame:SetDraggable(false)
	Frame:ShowCloseButton(false)
	Frame:MakePopup()
	Frame:Center()
	Frame.Paint = function()
		draw.RoundedBox(0, 0, 0, Frame:GetWide()-0, Frame:GetTall()-0, Color(50, 50, 50, 150))
		draw.RoundedBox(0, 2, 2, Frame:GetWide()-4, Frame:GetTall()-4, Color(75, 75, 75, 150))
	end
	--D
	local HtmlPanel = vgui.Create("DPanel", Frame)
	HtmlPanel:SetPos(302, 2)
	HtmlPanel:SetSize(Frame:GetWide() - 304, Frame:GetTall() - 4)
	HtmlPanel.Paint = function() end
	
	local HtmlBackground = vgui.Create("DPanel", HtmlPanel)
	HtmlBackground:SetPos(10, 10)
	HtmlBackground:SetSize(HtmlPanel:GetWide() - 20, HtmlPanel:GetTall() - 20)
	HtmlBackground.Paint = function()
		draw.RoundedBox(0, 0, 0, HtmlBackground:GetWide(), HtmlBackground:GetTall(), Color(0, 0, 0, 150))
		draw.DrawText("Loading :3", "Trebuchet24", HtmlBackground:GetWide()/2+1, HtmlBackground:GetTall()/2+1, Color(0, 0, 0, 255), 1)
		draw.DrawText("Loading :3", "Trebuchet24", HtmlBackground:GetWide()/2+0, HtmlBackground:GetTall()/2+0, Color(255, 255, 255, 255), 1)
	end
	
	local HtmlFrame = vgui.Create("DHTML", HtmlPanel)
	HtmlFrame:SetPos(12, 12)
	HtmlFrame:SetSize(HtmlPanel:GetWide() - 24, HtmlPanel:GetTall() - 24)
	--ABC
	local ButtonPanel = vgui.Create("DPanel", Frame)
	ButtonPanel:SetPos(2, 2)
	ButtonPanel:SetSize(300, ScrH() - 1)
	ButtonPanel.Paint = function()
		draw.RoundedBox(0, 0, 0, ButtonPanel:GetWide(), ButtonPanel:GetTall(), Color(60, 60, 60, 150))
		draw.RoundedBox(0, 0, 0, ButtonPanel:GetWide(), 187, Color(55, 55, 55, 150))
	end
	--A
	local Logo = vgui.Create("DHTML", ButtonPanel)
	Logo:SetPos(ButtonPanel:GetWide() / 2 - (184 / 2), 2)
	Logo:SetSize(184, 184)
	Logo:OpenURL("https://jolab.me/r/image/Logo.ICF.2.png")
	--C
	local Close = vgui.Create("DButton", ButtonPanel)
	Close:SetPos(10, ButtonPanel:GetTall()-42)
	Close:SetSize(ButtonPanel:GetWide() - 20, 32)
	Close:SetText("")
	Close.Hover = false
	Close.OnCursorEntered 	= function() Close.Hover = true end
	Close.OnCursorExited	= function() Close.Hover = false end
	Close.DoClick = function() 
		Frame:Close()
	end
	Close.Paint = function()
		draw.RoundedBox(0, 0, 0, Close:GetWide()-0, Close:GetTall()-0, Color(180, 0, 0, 255))
		draw.RoundedBox(0, 2, 2, Close:GetWide()-4, Close:GetTall()-4, Color(140, 0, 0, 255))
		if Close.Hover then
			draw.RoundedBox(0, 2, 2, Close:GetWide()-4, Close:GetTall()-4, Color(150, 30, 30, 255))
		end
		draw.DrawText("Close", "Trebuchet24", Close:GetWide()/2+1, 4+1, Color(0, 0, 0, 255), 1)
		draw.DrawText("Close", "Trebuchet24", Close:GetWide()/2+0, 4+0, Color(255, 255, 255, 255), 1)
	end
	--B
	local MotdButtonY = 190
	local MotdButtonI = 0
	for k,v in pairs(MotdButtons) do
		local MotdButton = vgui.Create("DButton", ButtonPanel)
		MotdButton:SetPos(10, MotdButtonY)
		MotdButton:SetSize(ButtonPanel:GetWide() - 20, 60)
		MotdButton:SetText("")
		MotdButton.Hover 	= false
		MotdButton.OnCursorEntered 	= function() MotdButton.Hover = true end
		MotdButton.OnCursorExited	= function() MotdButton.Hover = false end
		MotdButton.DoClick = function() 
			if string.sub(v['Link'],1,1) == "/" then
				RunConsoleCommand(string.sub(v['Link'], 2))
				Frame:Close()
			else
				HtmlFrame:OpenURL(v['Link']) 
			end
		end
		MotdButton.Paint = function()
			draw.RoundedBox(0, 0, 0, MotdButton:GetWide()-0, MotdButton:GetTall()-0, Color(75, 75, 75, 150))
			draw.RoundedBox(0, 2, 2, MotdButton:GetWide()-4, MotdButton:GetTall()-4, Color(90, 90, 90, 150))
			if MotdButton.Hover then
				draw.RoundedBox(0, 2, 2, MotdButton:GetWide()-4, MotdButton:GetTall()-4, Color(100, 100, 100, 255))
			end
			draw.DrawText(v['Text'], "CloseCaption_Bold", MotdButton:GetWide()/2+1, 16+1, Color(0, 0, 0, 255), 1)
			draw.DrawText(v['Text'], "CloseCaption_Bold", MotdButton:GetWide()/2+0, 16+0, Color(v['r'], v['v'], v['b'], 255), 1)
		end
		if MotdButtonI == 0 then
			HtmlFrame:OpenURL(v['Link'])
		end
		MotdButtonY = MotdButtonY + 60 + 8
		MotdButtonI = MotdButtonI + 1
	end 
	Page = data:ReadString()
	if Page != "" then HtmlFrame:OpenURL(Page) end
end
usermessage.Hook("Jonathan1358.Hud.Menu", Jonathan1358.Hud.MenuFrame)