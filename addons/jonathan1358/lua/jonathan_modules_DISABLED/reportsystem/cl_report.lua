function openReportMenu()
	local reportFrame = vgui.Create("DFrame")
	local width, height = 500, 300
	reportFrame:SetPos(ScrW() / 2 - width / 2, ScrH() / 2 - height / 2)
	reportFrame:SetSize(width, height)
	reportFrame:SetTitle("Report a player")
	reportFrame:SetVisible(true)
	reportFrame:SetDraggable(true)
	reportFrame:ShowCloseButton(true)
	reportFrame:MakePopup()

	local playerList = vgui.Create("DListView", reportFrame)
	playerList:SetWide(100)
	playerList:DockMargin(10, 10, 10, 10)
	playerList:Dock(LEFT)
	playerList:SetMultiSelect(false)
	playerList:AddColumn("Player")
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) and v != LocalPlayer() then
			local name = (v.DarkRPVars and v.DarkRPVars["rpname"]) or v:Nick()
			playerList:AddLine(name).steamId = v:SteamID()
		end
	end
	
	local rightPanel = vgui.Create("DPanelList", reportFrame)
	rightPanel:DockMargin(0, 10, 10, 10)
	rightPanel:Dock(FILL)
	rightPanel:EnableHorizontal(false)
	rightPanel:SetSpacing(5)
	
	local reasonLabel = vgui.Create("DLabel")
	reasonLabel:SetText("Report Reason:")
	rightPanel:AddItem(reasonLabel)
	local reasonMultiChoice = vgui.Create("DComboBox", reasonPanel)
	reasonMultiChoice:AddChoice("RDM (Random Death Match)")
	reasonMultiChoice:AddChoice("Exploits for an unfair advantage")
	reasonMultiChoice:AddChoice("Abusive language")
	reasonMultiChoice:AddChoice("Prop killing")
	reasonMultiChoice:AddChoice("Prop spamming")
	reasonMultiChoice:AddChoice("Mic or chat spamming")
	reasonMultiChoice:AddChoice("Vulgar spray")
	reasonMultiChoice:AddChoice("Try to crash the server")
	reasonMultiChoice:AddChoice("Hacking")
	reasonMultiChoice:AddChoice("Admin abuse")
	reasonMultiChoice:AddChoice("Other?")

	local selectedReason
	function reasonMultiChoice.OnSelect(index, value, data) 
		selectedReason = data
	end
	rightPanel:AddItem(reasonMultiChoice)
	
	local GamemodeLabel = vgui.Create("DLabel")
	GamemodeLabel:SetText("Gamemode:")
	rightPanel:AddItem(GamemodeLabel)
	local GamemodeMultiChoice = vgui.Create("DComboBox", reasonPanel)
	GamemodeMultiChoice:AddChoice("SledBuild")
	GamemodeMultiChoice:AddChoice("Prop Hunt")
	GamemodeMultiChoice:AddChoice("Trouble in Terrorist Town")
	GamemodeMultiChoice:AddChoice("Hide and Seek")
	GamemodeMultiChoice:AddChoice("DayZ")
	GamemodeMultiChoice:AddChoice("Murder")
	GamemodeMultiChoice:AddChoice("Melon Bomber")
	GamemodeMultiChoice:AddChoice("DeathRun")

	local selectedGamemode
	function GamemodeMultiChoice.OnSelect(index, value, data) 
		selectedGamemode = data
	end
	rightPanel:AddItem(GamemodeMultiChoice)
	
	--Please explain what happened. Make sure you said the server gamemode. Abuse can result of a ban.--
	local textLabel = vgui.Create("DLabel")
	textLabel:SetText("Please explain what happened. Abuse will result of a ban.")
	rightPanel:AddItem(textLabel)
	local textInput = vgui.Create("DTextEntry")
	textInput:SetText("")
	textInput:SetTall(90)
	textInput:SetMultiline(true)
	rightPanel:AddItem(textInput)
	
	local confirmButton = vgui.Create("DButton")
	confirmButton:SetText("Submit")
	function confirmButton.DoClick() 
		local line = playerList:GetSelectedLine()
		if not line then
			--Derma_Message("You did not select any player!", "Error", "Ok")
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Error", "You did not select any player!", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() DIALOG:Remove() end
			function DIALOG.Disagree:DoClick() DIALOG:Remove() end
			return
		end
		line = playerList:GetLine(line)
		local steamId = line.steamId
		local reason = selectedReason
		if not reason then 
			--Derma_Message("You did not select a reason!", "Error", "Ok")
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Error", "You did not select a reason!", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() DIALOG:Remove() end
			function DIALOG.Disagree:DoClick() DIALOG:Remove() end
			return
		end
		local details = textInput:GetValue()
		if not details then 
			--Derma_Message("You did not provide a description!", "Error", "Ok")
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Error", "You did not provide a description!", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() DIALOG:Remove() end
			function DIALOG.Disagree:DoClick() DIALOG:Remove() end
			return
		end
		if string.len(details) < 100 then 
			--Derma_Message ("Your description is too short! 100 characters minimun.\nDon't send us useless report. Also don't fill in the description \nwith RANDOM CHARACTERS to have the minimum chraracter limit.\nThis will make your report invalid and WILL get you a BAN.\nWe are serious about this...", "Error", "Ok")
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Error", "Your description is too short! 100 characters minimun. Don't send us useless report. Also don't fill in the description with RANDOM CHARACTERS to have the minimum chraracter limit. This will make your report invalid and WILL get you a BAN. We are serious about this...", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() DIALOG:Remove() end
			function DIALOG.Disagree:DoClick() DIALOG:Remove() end
			return
		end
		if not selectedGamemode then 
			--Derma_Message("You did not select any gamemode!", "Error", "Ok")
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Error", "You did not select any gamemode!", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() DIALOG:Remove() end
			function DIALOG.Disagree:DoClick() DIALOG:Remove() end
			return
		end
		
		-- local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Thank you for your report. An admin will look at it shortly.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
		-- DIALOG:SetAnimSize(600,200)
		-- function DIALOG.Agree:DoClick() 
			-- DIALOG:Remove()
			-- net.Start("TransferReport")
				-- net.WriteString(steamId)
				-- net.WriteString(reason)
				-- net.WriteString("Gamemode: " .. selectedGamemode .. " Details: " .. details)
			-- net.SendToServer()
			-- if reason == "Admin abuse" or reason == "Abusive language" or reason == "Other?" or reason == "Hacking" or reason == "Try to crash the server" or reason == "Vulgar spray" or reason == "Prop spamming" or reason == "Exploits for an unfair advantage" then
				-- local DIALOG2 = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Screenshot", "Your report may get more credibility if you send to us a screenshot of the problem. Do you want to send us a screenshot?", Color(0, 0, 0), Color(100, 100, 100, 255), "Yes", "No")
				-- DIALOG2:SetAnimSize(600,200)
				-- function DIALOG2.Agree:DoClick() 
					-- DIALOG2:Remove() 
					-- Jonathan1358.ScreenCap.GuideReport()
				-- end
				-- function DIALOG2.Disagree:DoClick() DIALOG2:Remove() end
			-- end
		-- end
		-- function DIALOG.Disagree:DoClick() DIALOG:Remove() end
		if reason == "Admin abuse" or reason == "Other?" or reason == "Hacking" or reason == "Try to crash the server" or reason == "Vulgar spray" or reason == "Prop spamming" or reason == "Exploits for an unfair advantage" then
			local DIALOG
			if reason == "Prop spamming" then
				DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Because of your reason of the report, you must send to the server a screenshot. Your report is about prop spamming. Point your crosshair in direction of prop spamming while taking screenshot. Do you want to proceed or abort your report?", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Abort")
			elseif reason == "Vulgar spray" then
				DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Because of your reason of the report, you must send to the server a screenshot. Your report is about vulgar spray. Point your crosshair in direction of the spray while taking screenshot. Do you want to proceed or abort your report?", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Abort")
			elseif reason == "Admin abuse" or reason == "Hacking" or reason == "Try to crash the server" or reason == "Exploits for an unfair advantage" then
				DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Because of your reason of the report, you must send to the server a screenshot. Your report is about '" .. reason .. "'. Point your crosshair in direction of the player while taking screenshot. Do you want to proceed or abort your report?", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Abort")
			else
				DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Because of your reason of the report, you must send to the server a screenshot. Do you want to proceed or abort your report?", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Abort")
			end
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() 
				DIALOG:Remove()
				Jonathan1358.ScreenCap.GuideReport(steamId, reason, "Gamemode: " .. selectedGamemode .. " Details: " .. details)
			end
			function DIALOG.Disagree:DoClick()
				DIALOG:Remove() 
			end
		else
			local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Because of your reason of the report, you must post on our forum instead of using this system. This report has not been submitted.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			DIALOG:SetAnimSize(600,200)
			function DIALOG.Agree:DoClick() 
				DIALOG:Remove()
				gui.OpenURL("https://jonathan1358.com/f/forum-13.html")
			end
			function DIALOG.Disagree:DoClick()
				DIALOG:Remove()
				gui.OpenURL("https://jonathan1358.com/f/forum-13.html")
			end
		end
		-- else
			-- local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "", "Thank you for your report. An admin will look at it shortly.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "")
			-- DIALOG:SetAnimSize(600,200)
			-- function DIALOG.Agree:DoClick() 
				-- DIALOG:Remove()
				-- net.Start("TransferReport")
					-- net.WriteString(steamId)
					-- net.WriteString(reason)
					-- net.WriteString("Gamemode: " .. selectedGamemode .. " Details: " .. details)
				-- net.SendToServer()
			-- end
			-- function DIALOG.Disagree:DoClick()
				-- DIALOG:Remove()
				-- net.Start("TransferReport")
					-- net.WriteString(steamId)
					-- net.WriteString(reason)
					-- net.WriteString("Gamemode: " .. selectedGamemode .. " Details: " .. details)
				-- net.SendToServer()
			-- end
		-- end
		
		
		reportFrame:Close()
		--Derma_Message("Thank you for your report. An admin will look at it shortly.", "Report sent", "Ok")
	end
	rightPanel:AddItem(confirmButton)
end

REPORTS = { }
net.Receive("TransferAllReports", function(len)
	REPORTS = net.ReadTable()
	if LocalPlayer().reportList and LocalPlayer().reportList.reload then
		LocalPlayer().reportList:reload() 
	end
end)

function openReportAdminMenu()
	local reportsFrame = vgui.Create("DFrame")
	local width, height = 1000, 700
	reportsFrame:SetPos(ScrW() / 2 - width / 2, ScrH() / 2 - height / 2)
	reportsFrame:SetSize(width, height)
	reportsFrame:SetTitle("Manage Reports")
	reportsFrame:SetVisible(true)
	reportsFrame:SetDraggable(true)
	reportsFrame:ShowCloseButton(true)
	reportsFrame:MakePopup()

	local reportList = vgui.Create("DListView", reportsFrame)
	reportList:SetWide(440)
	reportList:SetTall(680)
	reportList:DockMargin(10, 10, 10, 10)
	reportList:Dock(LEFT)
	reportList:SetMultiSelect(false)
	reportList:AddColumn("Date"):SetWidth(110)
	reportList:AddColumn("Reporter")
	reportList:AddColumn("REPORTED")
	reportList:AddColumn("Reason"):SetWidth(90)
	reportList:AddColumn("Warning"):SetWidth(50)
	function reportList:reload()
		local selectedReportId = nil
		if self:GetSelectedLine() then
			selectedReportId = self:GetLine(self:GetSelectedLine()).report.id
		end
		local selectedItem = nil
		
		self:Clear()
		for k, report in pairs(REPORTS) do
			local line = reportList:AddLine(report.time_created, 
				report.reporter_rpname != "UNKNOWN" and report.reporter_rpname or report.reporter_nick,
				report.reported_rpname != "UNKNOWN" and report.reported_rpname or report.reported_nick,
				report.reason, 
				report.warning_level)
			
			function line:GetColumnText(i)
				if i == 5 then --Warning Level
					if self.Columns[i] then
						return self.Columns[i].Value != "" and self.Columns[i].Value or 0
					else
						return 0
					end
				end
				return self.Columns[i] and self.Columns[i].value or ""
			end
				
			line.report = report
			if line.report.id == selectedReportId then
				selectedItem = line
			end
			function line:Paint()
				self:SizeToContents()
				local highlightColor 
				if string.len(self.report.resolved_by) < 1 then 
					highlightColor = Color(255, 0, 0, 180)
				elseif self.report.warning_level and self.report.warning_level > 0 then
					highlightColor = Color(255, 255, 0)
				else
					highlightColor = Color(0, 255, 0, 150)
				end
				
				if self:IsLineSelected() then
					surface.SetDrawColor(0, 0, 255, 255)
					surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
					surface.SetDrawColor(Color(0, 0, 255, 255))
					surface.DrawRect(2, 2, self:GetWide() - 4, self:GetTall() - 4)
				else
					surface.SetDrawColor(highlightColor)
					surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
				end
			end
		end
		if not selectedItem then 
			self:SelectFirstItem() 
		else
			self:SelectItem(selectedItem)
		end
	end
	reportList:reload()
	LocalPlayer().reportList = reportList
	
	local rightPanel = vgui.Create("DPanel", reportsFrame)
	rightPanel:DockMargin(0, 10, 10, 10)
	rightPanel:SetWide(520)
	rightPanel:SetTall(680)
	rightPanel:Dock(FILL)
	
	local topPanelLeft = vgui.Create("DTextEntry", rightPanel)
	topPanelLeft:SetPos(5, 5)
	topPanelLeft:SetWide(250)
	topPanelLeft:SetTall(100)
	topPanelLeft:SetMultiline(true)
	topPanelLeft:SetEnabled(false)
	
	local topPanelRight = vgui.Create("DTextEntry", rightPanel)
	topPanelRight:SetPos(255, 5)
	topPanelRight:SetWide(250)
	topPanelRight:SetTall(100)
	topPanelRight:SetMultiline(true)
	topPanelRight:SetEnabled(false)
	
	local reasonEntry = vgui.Create("DTextEntry", rightPanel)
	reasonEntry:SetPos(5, 110)
	reasonEntry:SetWide(500)
	reasonEntry:SetTall(100)
	reasonEntry:SetMultiline(true)
	reasonEntry:SetEnabled(false)
	
	function reportList:OnRowSelected(line) 
		local report = self:GetLine(line).report
		--topPanelLeft:SetText(string.format("Reported Player:\n\nRpName: %s\nNick: %s\nSteamID: %s\nWarning Level: %i\n", report.reported_rpname, report.reported_nick, report.reported_steamid, WARNINGLEVELS[report.reported_steamid] and WARNINGLEVELS[report.reported_steamid].warning_level or 0))
		topPanelLeft:SetText(string.format("Reported Player:\n\nNick: %s\nSteamID: %s\nWarning Level: %i\n", report.reported_nick, report.reported_steamid, WARNINGLEVELS[report.reported_steamid] and WARNINGLEVELS[report.reported_steamid].warning_level or 0))
		topPanelLeft:SetTextColor(Color(255, 0, 0, 255))
		topPanelLeft:SizeToContents()
		--topPanelRight:SetText(string.format("Reporting Player:\n\nRpName: %s\nNick: %s\nSteamID: %s\nWarning level: %i\n", report.reporter_rpname, report.reporter_nick, report.reporter_steamid, WARNINGLEVELS[report.reporter_steamid] and WARNINGLEVELS[report.reporter_steamid].warning_level or 0))
		topPanelRight:SetText(string.format("Reporting Player:\n\nNick: %s\nSteamID: %s\nWarning level: %i\n", report.reporter_nick, report.reporter_steamid, WARNINGLEVELS[report.reporter_steamid] and WARNINGLEVELS[report.reporter_steamid].warning_level or 0))
		topPanelRight:SetTextColor(Color(0, 0, 0, 255))
		topPanelRight:SizeToContents()
		reasonEntry:SetText(report.description or "")
		reasonEntry:SetTextColor(Color(0, 0, 0, 255))
	end
	
	function reportList:OnRowRightClick(line)
		local menu = DermaMenu()
		local selectedDbId = self:GetLine(line).report.id
		-- menu:AddOption("Delete", function() 
			-- RunConsoleCommand("reportremove", selectedDbId)
			-- self:RemoveLine(line)
		-- end)
		if string.len(self:GetLine(line).report.resolved_by) < 1 then
			menu:AddOption("Set report as invalid", function()
				RunConsoleCommand("reportresolve", selectedDbId)
				self:GetLine(line).report.resolved_by = LocalPlayer():Nick()
			end)
		end
		local setWarning = menu:AddSubMenu("Set warning level")
		for i = 0, 5 do
			setWarning:AddOption(i, function()
				timer.Simple(1, function() reportList:OnRowSelected(line) end)
				net.Start("ReportWarning")
					net.WriteUInt(selectedDbId, 32)
					net.WriteUInt(i, 32)
				net.SendToServer()
				self:GetLine(line).report.resolved_by = LocalPlayer():Nick()
				reportList:reload()
			end)
		end
		menu:Open()
	end
end

net.Receive("ReportUpdate", function(len) 
	if LocalPlayer().reportList then LocalPlayer().reportList:reload() end
end)

WARNINGLEVELS = {}
net.Receive("TransferWarningLevel", function(len)
	WARNINGLEVELS = net.ReadTable()
end)

surface.CreateFont("reportfont", {
	size = 18,
	weight = 400,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
	

local function reportInfoDraw()
	if LocalPlayer():IsAdmin() then
		for _,v in pairs(player.GetAll()) do
			if v != LocalPlayer() and v:Alive() then
				local ply = LocalPlayer()
				local pos = v:EyePos()
				
				local Alpha = 255 - (v:GetPos():Distance(ply:GetPos()) / 2)
				if Alpha > 2 then
					local ScreenPos = (v:GetPos() + Vector(0,0,95)):ToScreen()
					if WARNINGLEVELS[v:SteamID()] then
						draw.SimpleTextOutlined(string.format("Warning Level: %i", WARNINGLEVELS[v:SteamID()].warning_level), "reportfont", ScreenPos.x, ScreenPos.y - 20, Color(255,0,0,Alpha), 1, 0, 0.8, Color(60,60,60,Alpha - 50))
						draw.SimpleTextOutlined(string.format("Times Reported: %i", WARNINGLEVELS[v:SteamID()].reported_count), "reportfont", ScreenPos.x, ScreenPos.y - 3, Color(255,0,0,Alpha), 1, 0, 0.8, Color(60,60,60,Alpha - 50))
					end
				end
			end
		end
	end
end
hook.Add("HUDPaint", "DrawReportInfo", reportInfoDraw)

net.Receive("OpenReportMenu", function() 
	local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Warning", "Don't send us useless report. Also don't fill in the description random characters to have the minimum chraracter limit. This will make your report invalid and YOU WILL GET BANNED.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Cancel")
	--local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Warning", "The report system is temporarily closed. Please, visit our forum for ban request.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Cancel")
	DIALOG:SetAnimSize(600,200)
	function DIALOG.Agree:DoClick()
		DIALOG:Remove()
		openReportMenu()
		--gui.OpenURL("https://jonathan1358.com/f/forum-13.html")
	end
	function DIALOG.Disagree:DoClick()
		DIALOG:Remove()
		--gui.OpenURL("https://jonathan1358.com/f/forum-13.html")
	end
end)

net.Receive("OpenReportAdminMenu", function() 
	openReportAdminMenu()
end)