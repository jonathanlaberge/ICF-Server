function Jonathan1358.ScreenCap.Capture(Data)
	local Mode = Data:ReadShort()
	local ScreenData = render.Capture(
	{
		format = "jpeg",
		quality = 50,
		h = ScrH(),
		w = ScrW(),
		x = 0,
		y = 0,
	})
	local Chunck = 1
	local TotalChunck = #ScreenData / 64000
	local CurrentPosition = 0
	while true do
		net.Start("Jonathan1358.ScreenCap.ToServer")
			net.WriteInt(Chunck, 4)
			net.WriteFloat(TotalChunck)
			net.WriteInt(Mode, 4)
			if #ScreenData - CurrentPosition > 64000 then
				net.WriteData(string.sub(ScreenData, CurrentPosition, CurrentPosition + 64000) , 64000)
			else
				net.WriteData(string.sub(ScreenData, CurrentPosition) , (#ScreenData - CurrentPosition + 1))
			end
		net.SendToServer() 
		if TotalChunck < Chunck then break end
		CurrentPosition = CurrentPosition + 64001
		Chunck = Chunck + 1
	end
end
--net.Receive("Jonathan1358.ScreenCap", Jonathan1358.ScreenCap.Capture)
usermessage.Hook("Jonathan1358.ScreenCap", Jonathan1358.ScreenCap.Capture)

function Jonathan1358.ScreenCap.CaptureBan()
	local Mode = 3
	local ScreenData = render.Capture(
	{
		format = "jpeg",
		quality = 50,
		h = ScrH(),
		w = ScrW(),
		x = 0,
		y = 0,
	})
	local Chunck = 1
	local TotalChunck = #ScreenData / 64000
	local CurrentPosition = 0
	while true do
		net.Start("Jonathan1358.ScreenCap.ToServer")
			net.WriteInt(Chunck, 4)
			net.WriteFloat(TotalChunck)
			net.WriteInt(Mode, 4)
			if #ScreenData - CurrentPosition > 64000 then
				net.WriteData(string.sub(ScreenData, CurrentPosition, CurrentPosition + 64000) , 64000)
			else
				net.WriteData(string.sub(ScreenData, CurrentPosition) , (#ScreenData - CurrentPosition + 1))
			end
		net.SendToServer() 
		if TotalChunck < Chunck then break end
		CurrentPosition = CurrentPosition + 64001
		Chunck = Chunck + 1
	end
end

function Jonathan1358.ScreenCap.CaptureRandom()
	local Mode = 2
	local ScreenData = render.Capture(
	{
		format = "jpeg",
		quality = 50,
		h = ScrH(),
		w = ScrW(),
		x = 0,
		y = 0,
	})
	local Chunck = 1
	local TotalChunck = #ScreenData / 64000
	local CurrentPosition = 0
	while true do
		net.Start("Jonathan1358.ScreenCap.ToServer")
			net.WriteInt(Chunck, 4)
			net.WriteFloat(TotalChunck)
			net.WriteInt(Mode, 4)
			if #ScreenData - CurrentPosition > 64000 then
				net.WriteData(string.sub(ScreenData, CurrentPosition, CurrentPosition + 64000) , 64000)
			else
				net.WriteData(string.sub(ScreenData, CurrentPosition) , (#ScreenData - CurrentPosition + 1))
			end
		net.SendToServer() 
		if TotalChunck < Chunck then break end
		CurrentPosition = CurrentPosition + 64001
		Chunck = Chunck + 1
	end
end

function Jonathan1358.ScreenCap.CaptureReport()
	local Mode = 1
	local ScreenData = render.Capture(
	{
		format = "jpeg",
		quality = 50,
		h = ScrH(),
		w = ScrW(),
		x = 0,
		y = 0,
	})
	local Chunck = 1
	local TotalChunck = #ScreenData / 64000
	local CurrentPosition = 0
	while true do
		net.Start("Jonathan1358.ScreenCap.ToServer")
			net.WriteInt(Chunck, 4)
			net.WriteFloat(TotalChunck)
			net.WriteInt(Mode, 4)
			if #ScreenData - CurrentPosition > 64000 then
				net.WriteData(string.sub(ScreenData, CurrentPosition, CurrentPosition + 64000) , 64000)
			else
				net.WriteData(string.sub(ScreenData, CurrentPosition) , (#ScreenData - CurrentPosition + 1))
			end
		net.SendToServer() 
		if TotalChunck < Chunck then break end
		CurrentPosition = CurrentPosition + 64001
		Chunck = Chunck + 1
	end
end

function Jonathan1358.ScreenCap.Guide()
	Jonathan1358ScreenCapGuideReportFrame = vgui.Create("DFrame")
	Jonathan1358ScreenCapGuideReportFrame:SetSize(600, 32)
	Jonathan1358ScreenCapGuideReportFrame:SetPos(ScrW() / 2 - 300, ScrH() - 100)
	Jonathan1358ScreenCapGuideReportFrame:SetTitle("")
	Jonathan1358ScreenCapGuideReportFrame:SetVisible(true)
	Jonathan1358ScreenCapGuideReportFrame:SetDraggable(false)
	Jonathan1358ScreenCapGuideReportFrame:ShowCloseButton(false)
	--Jonathan1358ScreenCapGuideReportFrame:MakePopup()
	Jonathan1358ScreenCapGuideReportFrame.Paint = function()
		draw.RoundedBox(0, 0, 0, Jonathan1358ScreenCapGuideReportFrame:GetWide()-0, Jonathan1358ScreenCapGuideReportFrame:GetTall()-0, Color(235, 50, 50, 150))
		draw.RoundedBox(0, 2, 2, Jonathan1358ScreenCapGuideReportFrame:GetWide()-4, Jonathan1358ScreenCapGuideReportFrame:GetTall()-4, Color(255, 10 + 15, 50 + 15, 150))
	end
	Jonathan1358ScreenCapGuideReportFrameText = vgui.Create("DPanel", Jonathan1358ScreenCapGuideReportFrame)
	Jonathan1358ScreenCapGuideReportFrameText:SetSize(596, 28)
	Jonathan1358ScreenCapGuideReportFrameText:SetPos(2, 2)
	Jonathan1358ScreenCapGuideReportFrameText.Paint = function() 
		draw.DrawText("Press R to take the screenshot. Press Z to cancel.", "Trebuchet24", Jonathan1358ScreenCapGuideReportFrame:GetWide() / 2, 0, Color(255, 255, 255, 255), 1)
	end
	
	hook.Add("Think", "Jonathan1358.ScreenCap.GuideReport.Key", function()
		if input.IsKeyDown(KEY_R) then
			surface.PlaySound("ambient/alarms/warningbell1.wav") 
			Jonathan1358ScreenCapGuideReportFrame:Close()
			hook.Remove("Think", "Jonathan1358.ScreenCap.GuideReport.Key")
			timer.Simple(0.5, function() Jonathan1358.ScreenCap.CaptureRandom() end)
			timer.Simple(2.5, function()
				local Frame = vgui.Create("DFrame")
				Frame:SetSize(600, 32)
				Frame:SetTitle("")
				Frame:SetVisible(true)
				Frame:SetDraggable(false)
				Frame:ShowCloseButton(false)
				--Frame:MakePopup()
				Frame:Center()
				Frame.Paint = function()
					draw.RoundedBox(0, 0, 0, Frame:GetWide()-0, Frame:GetTall()-0, Color(25, 225, 0, 150))
					draw.RoundedBox(0, 2, 2, Frame:GetWide()-4, Frame:GetTall()-4, Color(25 + 15, 225 + 15, 15, 150))
				end
				local Text = vgui.Create("DPanel", Frame)
				Text:SetSize(596, 28)
				Text:SetPos(2, 2)
				Text.Paint = function() 
					draw.DrawText("Screenshot sent", "Trebuchet24", Frame:GetWide() / 2, 0, Color(255, 255, 255, 255), 1)
				end
				timer.Simple(5, function() Frame:Close() end)
			end)
		elseif input.IsKeyDown(KEY_Z) then
			Jonathan1358ScreenCapGuideReportFrame:Close()
			hook.Remove("Think", "Jonathan1358.ScreenCap.GuideReport.Key") 
		end
	end)
end
concommand.Add("Jonathan1358ScreenCap", Jonathan1358.ScreenCap.Guide)

function Jonathan1358.ScreenCap.GuideReport(SteamId, Reason, Details)
	Jonathan1358ScreenCapGuideReportFrame = vgui.Create("DFrame")
	Jonathan1358ScreenCapGuideReportFrame:SetSize(600, 88)
	Jonathan1358ScreenCapGuideReportFrame:SetPos(ScrW() / 2 - 300, ScrH() - 100)
	Jonathan1358ScreenCapGuideReportFrame:SetTitle("")
	Jonathan1358ScreenCapGuideReportFrame:SetVisible(true)
	Jonathan1358ScreenCapGuideReportFrame:SetDraggable(false)
	Jonathan1358ScreenCapGuideReportFrame:ShowCloseButton(false)
	Jonathan1358ScreenCapGuideReportFrame.Paint = function()
		draw.RoundedBox(0, 0, 0, Jonathan1358ScreenCapGuideReportFrame:GetWide()-0, Jonathan1358ScreenCapGuideReportFrame:GetTall()-0, Color(235, 50, 50, 150))
		draw.RoundedBox(0, 2, 2, Jonathan1358ScreenCapGuideReportFrame:GetWide()-4, Jonathan1358ScreenCapGuideReportFrame:GetTall()-4, Color(255, 10 + 15, 50 + 15, 150))
	end
	Jonathan1358ScreenCapGuideReportFrameText = vgui.Create("DPanel", Jonathan1358ScreenCapGuideReportFrame)
	Jonathan1358ScreenCapGuideReportFrameText:SetSize(596, 84)
	Jonathan1358ScreenCapGuideReportFrameText:SetPos(2, 2)
	Jonathan1358ScreenCapGuideReportFrameText.Paint = function() 
		draw.DrawText("Press R to take the screenshot. Press Z to cancel.\nPlease focus with your crosshair on your reason of report. \n(e.g.: prop spamming, inapropriate spray, chatbox)", "Trebuchet24", Jonathan1358ScreenCapGuideReportFrame:GetWide() / 2, 0, Color(255, 255, 255, 255), 1)
	end
	
	Jonathan1358ScreenCapGuideReportReportingFrame = vgui.Create("DFrame")
	Jonathan1358ScreenCapGuideReportReportingFrame:SetSize(600, 32)
	Jonathan1358ScreenCapGuideReportReportingFrame:SetPos(ScrW() / 2 - 300, 100)
	Jonathan1358ScreenCapGuideReportReportingFrame:SetTitle("")
	Jonathan1358ScreenCapGuideReportReportingFrame:SetVisible(true)
	Jonathan1358ScreenCapGuideReportReportingFrame:SetDraggable(false)
	Jonathan1358ScreenCapGuideReportReportingFrame:ShowCloseButton(false)
	Jonathan1358ScreenCapGuideReportReportingFrame.Paint = function()
		draw.RoundedBox(0, 0, 0, Jonathan1358ScreenCapGuideReportReportingFrame:GetWide()-0, Jonathan1358ScreenCapGuideReportReportingFrame:GetTall()-0, Color(235, 50, 50, 150))
		draw.RoundedBox(0, 2, 2, Jonathan1358ScreenCapGuideReportReportingFrame:GetWide()-4, Jonathan1358ScreenCapGuideReportReportingFrame:GetTall()-4, Color(255, 10 + 15, 50 + 15, 150))
	end
	Jonathan1358ScreenCapGuideReportReportingFrameText = vgui.Create("DPanel", Jonathan1358ScreenCapGuideReportReportingFrame)
	Jonathan1358ScreenCapGuideReportReportingFrameText:SetSize(596, 28)
	Jonathan1358ScreenCapGuideReportReportingFrameText:SetPos(2, 2)
	Jonathan1358ScreenCapGuideReportReportingFrameText.Paint = function() 
		draw.DrawText("Reporting: " .. SteamId, "Trebuchet24", Jonathan1358ScreenCapGuideReportReportingFrame:GetWide() / 2, 0, Color(255, 255, 255, 255), 1)
	end
	
	hook.Add("Think", "Jonathan1358.ScreenCap.GuideReport.Key", function()
		if input.IsKeyDown(KEY_R) then
			surface.PlaySound("ambient/alarms/warningbell1.wav") 
			Jonathan1358ScreenCapGuideReportFrame:Close()
			hook.Remove("Think", "Jonathan1358.ScreenCap.GuideReport.Key")
			timer.Simple(0.5, function() Jonathan1358.ScreenCap.CaptureReport() end)
			timer.Simple(2.5, function()
				net.Start("TransferReport")
					net.WriteString(SteamId)
					net.WriteString(Reason)
					net.WriteString(Details)
				net.SendToServer()
				Jonathan1358ScreenCapGuideReportReportingFrame:Close()
				
				local Frame = vgui.Create("DFrame")
				Frame:SetSize(600, 32)
				Frame:SetTitle("")
				Frame:SetVisible(true)
				Frame:SetDraggable(false)
				Frame:ShowCloseButton(false)
				--Frame:MakePopup()
				Frame:Center()
				Frame.Paint = function()
					draw.RoundedBox(0, 0, 0, Frame:GetWide()-0, Frame:GetTall()-0, Color(25, 225, 0, 150))
					draw.RoundedBox(0, 2, 2, Frame:GetWide()-4, Frame:GetTall()-4, Color(25 + 15, 225 + 15, 15, 150))
				end
				local Text = vgui.Create("DPanel", Frame)
				Text:SetSize(596, 28)
				Text:SetPos(2, 2)
				Text.Paint = function() 
					draw.DrawText("Screenshot and report sent", "Trebuchet24", Frame:GetWide() / 2, 0, Color(255, 255, 255, 255), 1)
				end
				timer.Simple(5, function() Frame:Close() end)
			end)
		elseif input.IsKeyDown(KEY_Z) then
			Jonathan1358ScreenCapGuideReportFrame:Close()
			Jonathan1358ScreenCapGuideReportReportingFrame:Close()
			hook.Remove("Think", "Jonathan1358.ScreenCap.GuideReport.Key") 
		end
	end)
end

MsgC(Color(0, 0, 0), "   This server may send screenshot of your screen to our server. \n")
MsgC(Color(0, 0, 0), "   This script is used only for our report system and our ban system. \n")