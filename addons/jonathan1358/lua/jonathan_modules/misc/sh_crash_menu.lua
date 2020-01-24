--Increase this if the menu shows on map change.
Jonathan1358.Misc.CrashDelayTime = 5

--What's the title?
Jonathan1358.Misc.CrashTitle = "Sorry"

--What message do you want to display when the server has crashed?
Jonathan1358.Misc.CrashMessage = "Looks like the server has crashed. It should restart in less than 45 seconds."

--What is the estimated time in seconds it takes for the server to restart after a crash?
Jonathan1358.Misc.CrashServerRestartTime = 40

Jonathan1358.Misc.CrashBackgroundColor = Color(0, 64, 255)

Jonathan1358.Misc.CrashButtonColor = Color(236, 240, 241)
Jonathan1358.Misc.CrashButtonHoverColor = Color(41, 128, 185)

Jonathan1358.Misc.CrashTitleTextColor = Color(236, 240, 241)
Jonathan1358.Misc.CrashMessageTextColor = Color(236, 240, 241)
Jonathan1358.Misc.CrashButtonTextColor = Color(52, 152, 219)


--Server buttons(Limit 3).
Jonathan1358.Misc.CrashServerNameButtons = {
	--"Join Server 1",
	--"Join Server 2",
	--"Check Out My Profile",
}

--Make sure it corresponds to the server names above!
--You can also do websites. Have it start with http://
Jonathan1358.Misc.CrashServerIPButtons = {
	--"192.168.1.1",
	--"192.168.1.2",
	--"http://steamcommunity.com//id/Kalamitous/",
}

CM = {}
--Song = nil

if SERVER then
	util.AddNetworkString("Jonathan1358.Misc.CrashMenuPong")

	function Jonathan1358.Misc.CrashMenuPing(ply, cmd, args)
		if !ply.LastPing or ply.LastPing + 5 < CurTime() then
			ply.LastPing = CurTime()
			
			net.Start("Jonathan1358.Misc.CrashMenuPong")
			net.Send(ply)
		end
	end
	concommand.Add("checkping", Jonathan1358.Misc.CrashMenuPing)

	return
end

function xRes(num)
	local xMul = ScrW() / num
	return ScrW() / xMul
end

function yRes(num)
	local yMul = ScrH() / num
	return ScrH() / yMul
end

Jonathan1358.Misc.CrashMenuLastMoveTime = CurTime() + 10
Jonathan1358.Misc.CrashMenuCrashed = false
Jonathan1358.Misc.CrashMenuCanSpawn = false
Jonathan1358.Misc.CrashMenuSpawnTime = 0

function Jonathan1358.Misc.CrashMenuCrashDetect()
	if !IsValid(LocalPlayer()) or !Jonathan1358.Misc.CrashMenuCanSpawn or Jonathan1358.Misc.CrashMenuCrashed or Jonathan1358.Misc.CrashMenuSpawnTime > CurTime() or Jonathan1358.Misc.CrashMenuLastMoveTime > CurTime() then 
		return 
	end

	if !LocalPlayer():IsFrozen() and !LocalPlayer():InVehicle() then
		return true
	end
end

function Jonathan1358.Misc.CrashMenuPong(len)
	Jonathan1358.Misc.CrashMenuLastMoveTime = CurTime() + 10
end
net.Receive("Jonathan1358.Misc.CrashMenuPong", Jonathan1358.Misc.CrashMenuPong)

function Jonathan1358.Misc.CrashMenuMove()
	Jonathan1358.Misc.CrashMenuLastMoveTime = CurTime() + 1
end
hook.Add("Move", "Jonathan1358.Misc.CrashMenuMove", Jonathan1358.Misc.CrashMenuMove)

function Jonathan1358.Misc.CrashMenuInitPostEntity()
	Jonathan1358.Misc.CrashMenuCanSpawn = true
	Jonathan1358.Misc.CrashMenuSpawnTime = CurTime() + 5
end
hook.Add("InitPostEntity", "Jonathan1358.Misc.CrashMenuInitPostEntity", Jonathan1358.Misc.CrashMenuInitPostEntity)

surface.CreateFont("CMTitle", {
	font = "Coolvetica", 
	size = xRes(150), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMFont", {
	font = "Coolvetica", 
	size = xRes(50), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMButton", {
	font = "Coolvetica", 
	size = xRes(40), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMButton2", {
	font = "Coolvetica", 
	size = xRes(30), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

function Jonathan1358.Misc.CrashMenu()
	for k, v  in ipairs(player.GetAll()) do
		v.CrashedPing = v:Ping()
	end
	
	local retryTime = CurTime() + Jonathan1358.Misc.CrashServerRestartTime
	
	-- if YouTubeURL != nil then
		-- Song = vgui.Create("HTML")
		-- Song:SetPos(0,0)
		-- Song:SetSize(0, 0)
		-- Song:OpenURL(YouTubeURL)
	timer.Simple(3, function() 
		if Jonathan1358.Misc.CrashMenuCrashed == true then
			-- surface.PlaySound("jonathan1358/the_sims_3-cartographers_symphony.mp3")
			-- timer.Create("SongStopper", 1, 0, function ()
				-- if Jonathan1358.Misc.CrashMenuCrashed == false then
					-- timer.Simple(1, function() RunConsoleCommand("stopsound") end)
					-- timer.Destroy("SongStopper")
				 -- end
			-- end)
		end
	end)
	-- end
		
	local CMM = vgui.Create("DFrame")
	CMM:SetSize(ScrW(), ScrH())
	CMM:Center()
	CMM:SetTitle("")
	CMM:ShowCloseButton(false)
	CMM:MakePopup()
	CMM:SetDraggable(false)
	CMM.Paint = function()
		draw.RoundedBox(0, 0, 0, CMM:GetWide(), CMM:GetTall(), Jonathan1358.Misc.CrashBackgroundColor)
		draw.SimpleText(Jonathan1358.Misc.CrashTitle, "CMTitle", xRes(200), yRes(150), Jonathan1358.Misc.CrashTitleTextColor, TEXT_ALIGN_LEFT)
	end
	CMM:SetAlpha(0)
	CMM:AlphaTo(255, 0.5, Jonathan1358.Misc.CrashDelayTime)

	local CMT = vgui.Create("DLabel", CMM)
	CMT:SetSize(ScrW() / 2 - xRes(200), ScrH())
	CMT:SetPos(xRes(200), yRes(150) + xRes(150) + yRes(100) - ScrH() / 2)
	CMT:SetText(Jonathan1358.Misc.CrashMessage)
	CMT:SetFont("CMFont")
	CMT:SetWrap(true)
	CMT:SetTextColor(Jonathan1358.Misc.CrashMessageTextColor)
	
	local bNum
	
	if Jonathan1358.Misc.CrashServerNameButtons != nil then
		bNum = #Jonathan1358.Misc.CrashServerNameButtons
	else
		bNum = 0
	end
	
	for i = 1, (bNum + 2) do	
		local CMR = vgui.Create("DButton", CMM)
		CMR:SetPos(ScrW() - (ScrW() / 2 - xRes(400)) - xRes(200), yRes(165) * i)
		CMR:SetText("")
		CMR:SetSize(ScrW() / 2 - xRes(400), yRes(100))
		
			local CMA = vgui.Create("DButton", CMM)
			CMA:SetPos(ScrW() - (ScrW() / 2 - xRes(400)) - xRes(200), yRes(165) * i)
			CMA:SetText("")
			CMA:SetSize(0, 0)
			CMR.OnCursorEntered = function()
				surface.PlaySound("buttons/lightswitch2.wav")
				CMA:SizeTo(ScrW() / 2 - xRes(400), 0, 0.5, 0, -1)
			end
			CMR.OnCursorExited = function()
				CMA:SizeTo(0, 0, 0.5, 0, -1)
			end
			CMA.Paint = function()
				draw.RoundedBox(0, 0, 0, 0, 0, Color(255, 255, 255))
			end
		
		CMR.Paint = function()	
			draw.RoundedBox(0, 0, 0, CMR:GetWide(), CMR:GetTall(), Jonathan1358.Misc.CrashButtonColor)
			
			draw.RoundedBox(0, 0, 0, CMA:GetWide(), yRes(100), Jonathan1358.Misc.CrashButtonHoverColor)
			
			local text = ""
			
			if i == (bNum + 1) then
				draw.SimpleText("Reconnecting in:", "CMButton2", xRes(15), yRes(22), Jonathan1358.Misc.CrashButtonTextColor, TEXT_ALIGN_LEFT)
				draw.SimpleText(tostring(math.Round(retryTime - CurTime())).." seconds", "CMButton2", xRes(15), yRes(52), Jonathan1358.Misc.CrashButtonTextColor, TEXT_ALIGN_LEFT)
			elseif i == (bNum + 2) then
				text = "Disconnect"
				
				draw.SimpleText(text, "CMButton", xRes(15), yRes(30), Jonathan1358.Misc.CrashButtonTextColor, TEXT_ALIGN_LEFT)
			else
				text = Jonathan1358.Misc.CrashServerNameButtons[i]
				
				draw.SimpleText(text, "CMButton", xRes(15), yRes(30), Jonathan1358.Misc.CrashButtonTextColor, TEXT_ALIGN_LEFT)
			end
		end
		
		CMR.DoClick = function()
			if i == (bNum + 2) then
				RunConsoleCommand("disconnect")
			end
			
			if i <= bNum then
				if string.find(Jonathan1358.Misc.CrashServerIPButtons[i], "http", 0, false) then
					gui.OpenURL(Jonathan1358.Misc.CrashServerIPButtons[i])
				else
					for k, v in pairs(player.GetAll()) do
						v:ConCommand("connect "..Jonathan1358.Misc.CrashServerIPButtons[i])
					end
				end
			end
			
			surface.PlaySound("buttons/button14.wav")
		end
	end

	local aPlay = false
	local bPlay = false
	local cPlay = false
	
	hook.Add("Think", "CrashRecover", function()
		for k, v in ipairs(player.GetAll()) do
			if v.CrashedPing != v:Ping() then
				hook.Remove("Think", "CrashRecover")
				
				Jonathan1358.Misc.CrashMenuCrashed = false
				Jonathan1358.Misc.CrashMenuLastMoveTime = CurTime() + 5
			end
		end
		
		if Jonathan1358.Misc.CrashMenuCrashed and (retryTime - CurTime() - 0.5) <= 3 and Jonathan1358.Misc.CrashMenuLastMoveTime + 5 < CurTime() then
			local a = (retryTime - CurTime() - 0.5) <= 3 and (retryTime - CurTime()) > 2
			local b = (retryTime - CurTime() - 0.5) <= 2 and (retryTime - CurTime()) > 1
			local c = (retryTime - CurTime() - 0.5) <= 1 and (retryTime - CurTime()) > 0
			if (a and aPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				aPlay = true
			elseif (b and bPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				bPlay = true
			elseif (c and cPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				cPlay = true
			elseif (retryTime - CurTime() - 0.5) <= 0 then
				surface.PlaySound("buttons/button3.wav")
			
				RunConsoleCommand("retry")
			end
		elseif Jonathan1358.Misc.CrashMenuLastMoveTime > CurTime() then
			hook.Remove("Think", "CrashRecover")
			
			aPlay = false
			bPlay = false
			cPlay = false
			
			Jonathan1358.Misc.CrashMenuCrashed = false
			
			if CMM and CMM:IsValid() then
				CMM:Close()
			end
		end
	end)
end

function Jonathan1358.Misc.CrashMenuThink()
	if !Jonathan1358.Misc.CrashMenuCrashed and Jonathan1358.Misc.CrashMenuCrashDetect() then
		RunConsoleCommand("checkping")
		
		if Jonathan1358.Misc.CrashMenuLastMoveTime < CurTime() then
			Jonathan1358.Misc.CrashMenuCrashed = true
			
			Jonathan1358.Misc.CrashMenu()
		else
			Jonathan1358.Misc.CrashMenuCrashed = false
		end
	end
end
hook.Add("Think", "Jonathan1358.Misc.CrashMenuThink", Jonathan1358.Misc.CrashMenuThink)

--MsgC(Color(52, 152, 219), "Loaded Server Crash Menu & Auto-Reconnection, an addon by Kalamitous.\n")