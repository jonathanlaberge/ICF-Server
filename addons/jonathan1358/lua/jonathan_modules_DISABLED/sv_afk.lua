if SERVER then
--AAfk - By Zach Petty (MrPresident) for the use on gman4president.com G4P GarrysMod servers.
--Original concept by Meggido of Team Ulysses
--Completely rewritten for the new lua and ULib
--
--BEGIN CONFIGURATION--
--
--aafk enabled? Should this addon start enabled?--
local aafkenabled = true
--
--AFK Timer (In Seconds) NOTE: If Kick Flag is turned on below, they will be kicked in twice the time you set for the afk flag--
local aafktime = 150
--
--Should the User be kicked if they stay afk after being flagged as AFK?--
local aafkick = true
--
--Should admins be immune to the afk kick if it is enabled?--
local aafkimmune = false
--
--How many users need to be connected before teh script starts kicking. (This requires aafk_kickenabled to be on.)
--If this is 0, then all afk users will be kicked if they stay afk, otherwise the script will not kick a user for being afk
--unless the server has this specified number of players connected. This is good for having the script only kick if the server
--is full.
local aafkicknumber = 0 --Default 0, if set to 0, the script will kick everytime someone is afk if aafk_kickenabled is on.
--
--
--END CONFIGURATION.. DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING--

	local oname = {}
	function aafkCheckAdmin( ply ) --Admin Check--
		if not ply:IsValid() then
			return true
		end

		if ply:IsSuperAdmin() then 
			return true 
		end

		return false
	end

	--ADDS THE CONSOLE COMMAND TO SET THE AFK TIMER--
	function aafkicknumbervar( ply, command, args )
		if !aafkCheckAdmin(ply) then
			ULib.console(ply, "Only Superadmin can change this variable", true)
			return
		end
		local aname = "Default"
		if ply:IsValid() then
			aname = ply:GetName()
		else
			aname = "Console"
		end
		if args[1] == nil then
			ULib.console(ply, "Value must be numerical and higher than or equal to 0", true)
		end
		if tonumber(args[1]) >= 0 then
			aafkicknumber = tonumber(args[1])
			local text = "Admin: " ..aname.. " has set the afk Kick Number to " ..aafkicknumber.. " players."
			ULib.console( ply, text )
			ULib.tsay(nil, text, true)
		else
			ULib.console(ply, "Value must be numerical and higher than or equal to 0", true)
		end

	end
	concommand.Add("aafk_kicknumber",aafkicknumbervar) 

	--ADDS THE CONSOLE COMMAND TO SET THE AFK TIMER--
	function aafktimevar( ply, command, args )
		if !aafkCheckAdmin(ply) then
			ULib.console(ply, "Only Superadmin can change this variable", true)
			return
		end
		local aname = "Default"
		if ply:IsValid() then
			aname = ply:GetName()
		else
			aname = "Console"
		end
		if args[1] == nil then
			ULib.console(ply, "Value must be numerical and higher than 0", true)
		end
		if tonumber(args[1]) >= 1 then
			aafktime = tonumber(args[1])
			timer.Create("AAFKCheck", aafktime, 0, AFKCheck) --Checks status every period you designate.
			local text = "Admin: " ..aname.. " has set the afk timer to " ..aafktime.. " seconds"
			ULib.console( ply, text )
			ULib.tsay(nil, text, true)
		else
			ULib.console(ply, "Value must be numerical and higher than 0", true)
		end

	end
	concommand.Add("aafk_time",aafktimevar) 

	--ADDS THE CONSOLE COMMAND TO SET KICK FLAGS--
	function aafkkickvar( ply, command, args )
		if !aafkCheckAdmin(ply) then
			ULib.console(ply, "Only Superadmin can change this variable", true)
			return
		end
		local aname = "Default"
		if ply:IsValid() then
			aname = ply:GetName()
		else
			aname = "Console"
		end
		if args[1] == "0" then
			local text = "Admin: " ..aname.. " has turned AFK Kicking off!"
			ULib.console( ply, text )
			aafkick = false
			--SetGlobalBool("aafkick", false)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has turned AFK Kicking off!", true)
			end
		elseif args[1] == "1" then
			local text = "Admin: " ..aname.. " has turned AFK Kicking on!"
			ULib.console( ply, text )
			aafkick = true
			--SetGlobalBool("aafkick", true)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has turned AFK Kicking on!", true)
			end
		else
			ULib.console(ply, "You must enter 1 for True or 0 for False!", true)
			return
		end
	end
	concommand.Add("aafk_kickenabled",aafkkickvar)

	--ADDS THE CONSOLE COMMAND TO SET ADMIN IMMUNITY--
	function aafkadminvar( ply, command, args )
		if !aafkCheckAdmin(ply) then
			ULib.console(ply, "Only Superadmin can change this variable", true)
			return
		end
		local aname = "Default"
		if ply:IsValid() then
			aname = ply:GetName()
		else
			aname = "Console"
		end
		if args[1] == "0" then
			local text = "Admin: " ..aname.. " has turned Admin Immunity off!"
			ULib.console( ply, text )
			aafkimmune = false
			--SetGlobalBool("aafkimmune", false)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has turned Admin Immunity off!", true)
			end
		elseif args[1] == "1" then
			local text = "Admin: " ..aname.. " has turned Admin Immunity on!"
			ULib.console( ply, text )
			aafkimmune = true
			--SetGlobalBool("aafkimmune", true)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has turned Admin Immunity on!", true)
			end
		else
			ULib.console(ply, "You must enter 1 for True or 0 for False!", true)
			return
		end
	end
	concommand.Add("aafk_adminimmune",aafkadminvar)

	--ADDS THE CONSOLE COMMAND TO SET IF IS ENABLED--
	function aafkenabledvar( ply, command, args )
		if !aafkCheckAdmin(ply) then
			ULib.console(ply, "Only Superadmin can change this variable", true)
			return
		end
		local aname = "Default"
		if ply:IsValid() then
			aname = ply:GetName()
		else
			aname = "Console"
		end
		if args[1] == "0" then
			local text = "Admin: " ..aname.. " has disabled aafk!"
			ULib.console( ply, text )
			aafkenabled = false
			--SetGlobalBool("aafkenabled", false)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has disabled aafk!", true)
			end
		elseif args[1] == "1" then
			local text = "Admin: " ..aname.. " has enabled aafk!"
			ULib.console( ply, text )
			aafkenabled = true
			--SetGlobalBool("aafkenabled", true)
			for i, v in ipairs(player.GetAll()) do
				ULib.tsay(v, "Admin: " ..aname.. " has enabled aafk!", true)
			end
		else
			ULib.console(ply, "You must enter 1 for True or 0 for False!", true)
			return
		end
	end
	concommand.Add("aafk_enabled",aafkenabledvar)

	function AFKChatHook(ply, text, public)
		local args = string.Explode(" ", text)
		if ply:GetNetworkedBool("afk") == true then
			ply:ConCommand("aafk_return 1q2w3e4r\n")
			ply:ConCommand("setinfo name " ..ply:GetNetworkedString("savedname").."\n")
		else
			if string.upper(args[1]) == "!AFK" then
				ply:SetNetworkedBool("afk", true)
				if aafkick == true then
					ply:SetNetworkedInt("ccount", 1)
					local Text = "You are flagged as AFK, AFK Kicking is enabled, you will be kicked the next time the server checks for afk players."
					ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"npc/attack_helicopter/aheli_damaged_alarm1.wav\")")
				else
					local Text = "You are flagged as AFK!"
					ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"npc/attack_helicopter/aheli_damaged_alarm1.wav\")")
				end
				ULib.tsay(nil, tostring(ply:GetName()).. " is now afk", true)
				oname[ply:UniqueID()].name = tostring(ply:GetName())
				ply:SetNetworkedString("savedname", ply:GetName())
				local afkname
				if string.Left(tostring(ply:GetName()), 5) == "<AFK>" then  --Somehow.. for some reason they already have AFK in as the start of their name.. we dont want it there twice.. =)
					afkname = oname[ply:UniqueID()].name
				else
					afkname = "<AFK>" ..oname[ply:UniqueID()].name..""
				end
				ply:ConCommand("setinfo name " ..afkname.."\n")
				return ""
			else
			local chatc = ply:GetNetworkedInt("ccount")
			chatc = chatc + 1
			ply:SetNetworkedInt("ccount", chatc)
			--ULib.tsay(ply, tostring(ply:GetNetworkedInt("ccount")), true)
			end
		end
	end
	hook.Add( "PlayerSay", "AFKChatHook", AFKChatHook )



	function AFKReturn(ply, command, args)
		if args[1] == "1q2w3e4r" then
			ply:SetNetworkedBool("afk", false)
                        local text = tostring(ply:GetName()).. " is now back from being AFK"
			ULib.tsay(nil, text, true)
                else
			ULib.console(ply, "You can not use this console command from your client")
		end
	end
	concommand.Add("aafk_return",AFKReturn)

	function AFKReturn(ply, command, args)
		if args[1] == "1q2w3e4r" then
			local kp = ply:GetNetworkedInt("kpress")
			kp = kp + 1
			ply:SetNetworkedInt("kpress", kp)
                else
			ULib.console(ply, "You can not use this console command from your client")
		end
	end
	concommand.Add("aafk_keycheck",AFKReturn)

	function AAFKPlayerSpawn(ply)
		ply:SetNetworkedBool("afk", false)
		ply:SetNetworkedInt("ccount", 0)
		ply:SetNetworkedInt("kpress", 0)
		ply:SetNetworkedAngle("savedangle", Angle(0, 0, 0))
		ply:SetNetworkedString("savedname", "")
		oname[ply:UniqueID()] = { name=ply:GetName() }
	end
	hook.Add( "PlayerInitialSpawn", "afksetvariables", AAFKPlayerSpawn )

	function KickAFK(ply)
		ULib.kick(ply, "AAFK: AFK Timeout Auto-Kick")
		--ULib.tsay(ply, "Kicked", true)
	end

	function AFKCheck()
		if aafkenabled == false then
			--Do Nothing.. Addon is disabled.
		else
          		for i, v in ipairs(player.GetAll()) do
				if v:GetNetworkedAngle("savedangle") == v:GetAngles() then --Does this new angle match the angle stored, or is the chat counter more than one?
				if v:GetNetworkedInt("kpress") >= 1 then -- Has the pressed a key, but not changed angles?
					v:SetNetworkedInt("kpress", 0)
					v:SetNetworkedInt("ccount", 0)
				else
				if v:GetNetworkedInt("ccount") >= 1 then -- Has the player Talked.. but not moved?
					v:SetNetworkedInt("ccount", 0)
					v:SetNetworkedInt("kpress", 0)
				else
					if v:GetNetworkedBool("afk") == true then
						if aafkick == true then
							if aafkicknumber <= tonumber(#(player.GetAll())) then
								if aafkimmune == true then
									if v:query("aafk_immune") == true or v:IsAdmin() == true then
										ULib.tsay(v, "Still AFK, but immune to kick", true)
									else
										v:ConCommand("setinfo name " ..oname[v:UniqueID()].name.."\n")
										timer.Simple(1, KickAFK, v)
										ULib.tsay(nil, "AAFK: (Player) " ..tostring(v:GetName()).. " has been kicked from the server for being idle", true)
									end
								else
									v:ConCommand("setinfo name " ..oname[v:UniqueID()].name.."\n")
									timer.Simple(1, KickAFK, v)
								ULib.tsay(nil, "AAFK: (Player) " ..tostring(v:GetName()).. " has been kicked from the server for being idle", true)
								end
							else
								ULib.tsay(v, "You are still afk, however the server is not full enough to kick afk players", true)
							end
						else
						ULib.tsay(v, "Still AFK, However kick has been disabled.", true)
						end
					elseif v:GetNetworkedBool("afk") == false then
						v:SetNetworkedBool("afk", true)
						if aafkick == true then
							local Text = "You are flagged as AFK, if you do not move in " ..aafktime.. " seconds you will be kicked"
							v:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"npc/attack_helicopter/aheli_damaged_alarm1.wav\")")
						else
							local Text = "You are flagged as AFK!"
							v:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"npc/attack_helicopter/aheli_damaged_alarm1.wav\")")
						end
						ULib.tsay(nil, tostring(v:GetName()).. " is now afk", true)
						oname[v:UniqueID()].name = v:GetName()
						v:SetNetworkedString("savedname", v:GetName())
						local afkname
						if string.Left(tostring(v:GetName()), 5) == "<AFK>" then  --Somehow.. for some reason they already have AFK in as the start of their name.. we dont want it there twice.. =)
							afkname = oname[v:UniqueID()].name
						else
							afkname = "<AFK>" ..oname[v:UniqueID()].name..""
						end
						v:ConCommand("setinfo name " ..afkname.."\n")
					end
					v:SetNetworkedInt("ccount", 0)
				end
				end
				else
					--Angles don't match.. player has moved.... or they have been chatting, do nothing.
					v:SetNetworkedInt("ccount", 0)
					v:SetNetworkedInt("kpress", kp)
				end
				v:SetNetworkedAngle("savedangle", v:GetAngles()) --Store new angle value for the user in the loop
			end
		end
	end
	timer.Create("AAFKCheck", aafktime, 0, AFKCheck) --Checks status every period you designate.


end


if CLIENT then
	local savedangle = Angle(0, 0, 0)
	local savedname = ""
	local timevar = 0
	local keyspressed = 0

	function MoveCheckAFK()
	local mcnewangle = ""
	local mcstoredangle = ""
	local mcchecknew = ""
	local mccheckstored = ""
		if LocalPlayer():GetNetworkedBool("afk") == true then
			mcstoredangle = string.Explode(" ", tostring(savedangle))
			mccheckstored = string.Left(mcstoredangle[2], 3)
			mcnewangle = string.Explode(" ", tostring(LocalPlayer():GetAngles()))
			mcchecknew = string.Left(mcnewangle[2], 3)
			if mcchecknew == mccheckstored then  --Meaning They are still afk...
				return
			else
				LocalPlayer():ConCommand("aafk_return 1q2w3e4r\n")
				LocalPlayer():ConCommand("setinfo name " ..LocalPlayer():GetNetworkedString("savedname").."\n")
			end
		else
			savedangle = LocalPlayer():GetAngles()
		end
	end
	timer.Create("CheckAFKTimer", 1, 0, MoveCheckAFK)

	function CheckKeyPressesReset()
		if keyspressed > 0 then
			LocalPlayer():ConCommand("aafk_keycheck 1q2w3e4r\n")
		end
		keyspressed = 0
	end
	timer.Create("CheckKeyPressesReset", 5, 0, CheckKeyPressesReset)
	
	function KeyPressHook()
		keyspressed = keyspressed + 1
	end
	hook.Add("KeyPress", "KeyPress", KeyPressHook)	

	function KeyReleaseHook()
		keyspressed = keyspressed + 1
	end
	hook.Add("KeyRelease", "KeyRelease", KeyReleaseHook)	
	

	function DrawAFKNames()
		local vStart = LocalPlayer():GetPos()
		local vEnd
		for k, v in pairs(player.GetAll()) do
			if v:GetNetworkedBool("afk") == true then
				local vStart = LocalPlayer():GetPos()
				local vEnd = v:GetPos() + Vector(0,0,40)
				local trace = {}
				trace.start = vStart
				trace.endpos = vEnd
				local trace = util.TraceLine( trace )
				if trace.HitWorld then
				else
					local mepos = LocalPlayer():GetPos()
					local tpos = v:GetPos()
					local tdist = mepos:Distance(tpos)
					if tdist <= 3000 then
						local zadj = 0.03334 * tdist
						local pos = v:GetPos() + Vector(0,0,v:OBBMaxs().z + 5 + zadj)
     		       			pos = pos:ToScreen()
     		       			if v != LocalPlayer() then
     		           				draw.SimpleText("<=~AFK~=>", "TargetID", pos.x - 30, pos.y , Color(255,0,0,155))
           		 			end
					end
				end
			end
    		end
	end
hook.Add("HUDPaint", "DrawAFKNames", DrawAFKNames)

end
