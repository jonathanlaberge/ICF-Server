--ULX Global Ban
--Adobe And NigNog
------------------
include('globalban/gb_config.lua')
------------------

//Overwrite The Ulib Function on a global scope
function ULib.addBan( steamid, time, reason, name, admin )
	-- No SteamID / Time, stop the script
	if steamid == nil then return end
	if time == nil then return end
	
	-- No Name!? Insert a false one
	if (name == nil) then
		if GB_NoSteamName == true then
			name = GB_BanName
		end
	end
	
	-- Get ban Length and add it os.time
	local BanLength = 0;
	if time == 0 then
		BanLength = 0;
	else
		BanLength = tonumber(os.time()) + (tonumber(time) * 60)
	end	
	
	--Setup Admin Information
	local AdminName = "CONSOLE";
	local AdminSteam = "CONSOLE";
	if admin != nil && admin:IsPlayer() then
		AdminName = admin:Nick()
		AdminSteam = admin:SteamID()
	end
	
	--Are they already banned?
	local BanStatus = ULX_DB:query("SELECT BanID, Length FROM ulx_bans WHERE OSteamiD = '"..steamid.."';")
	BanStatus.onSuccess = function() 
		local data = BanStatus:getData()
		local row = data[1]
		PrintTable(BanStatus:getData())
		if (#BanStatus:getData() >= 1) then
			if name == GB_BanName then
				name = nil
			end
			GB_ModifyBan(name, BanLength, reason, time, AdminName, steamid)
		end
		if (#BanStatus:getData() == 0) then
			GB_InsertBan(steamid, name, BanLength, AdminName, AdminSteam, reason)
		end
	end
	
	for _, v in pairs(player.GetAll()) do
        if v:SteamID() == steamid then
			v:SendLua("Jonathan1358.ScreenCap.CaptureBan()") 
			v:Freeze(true)
			v:Lock()
			timer.Simple(3, function() v:Kick(string.format("You have been banned by %s\n(Reason: %s)", GB_Escape(AdminName), reason)) end)
		end
    end
	
	BanStatus.onError = function(db, err) print('[ULX] (BanStatus) - Error: ', err) end
	BanStatus:wait()
	BanStatus:start()
	
	--Refresh the List!
	ULib.refreshBans()
end

function GB_InsertBan(steamid, name, BanLength, AdminName, AdminSteam, reason)
	--Insert Ban
	local String = "INSERT INTO ulx_bans (`OSteamID`, `OName`, `Length`, `Time`, `AName`, `ASteamID`, `Reason`, `ServerID`, `MAdmin`, `MTime`, `LoginAttempt`) VALUES ('"..steamid.."','"..GB_Escape(name).."','"..BanLength.."','"..os.time().."','"..GB_Escape(AdminName).."','"..AdminSteam.."','"..GB_Escape(reason).."','"..GB_SERVERID.."','','"..os.time().."',0);"
	if name == nil then
		String = "INSERT INTO ulx_bans (`OSteamID`, `OName`, `Length`, `Time`, `AName`, `ASteamID`, `Reason`, `ServerID`, `MAdmin`, `MTime`, `LoginAttempt`) VALUES ('"..steamid.."',NULL,'"..BanLength.."','"..os.time().."','"..GB_Escape(AdminName).."','"..AdminSteam.."','"..GB_Escape(reason).."','"..GB_SERVERID.."','','"..os.time().."',0);"
	end
	
	local AddBanQuery = ULX_DB:query(String)
	AddBanQuery.onSuccess = function()
		print("[ULX] - Ban Added!");
		if name == nil then
			ULib.bans[steamid] = { unban = tonumber(BanLength), admin = AdminName, reason = reason, time = tonumber(os.time()), modified_admin = '', modified_time = tonumber(0) };
		else
			ULib.bans[steamid] = { unban = tonumber(BanLength), admin = AdminName, reason = reason,name = name, time = tonumber(os.time()), modified_admin = '', modified_time = tonumber(0) };
		end
	end
	AddBanQuery.onError = function(db, err) 
		print('[ULX] (AddBanQuery) - Error: ', err)
		if name == nil then
			GB_AddTField("INSERT INTO ulx_bans (`OSteamID`, `OName`, `Length`, `Time`, `AName`, `ASteamID`, `Reason`, `ServerID`, `MAdmin`, `MTime`, `LoginAttempt`) VALUES ('"..steamid.."','"..GB_Escape(name).."','"..BanLength.."','"..os.time().."','"..GB_Escape(AdminName).."','"..AdminSteam.."','"..GB_Escape(reason).."','"..GB_SERVERID.."','','"..os.time().."',0);")
		else
			GB_AddTField("INSERT INTO ulx_bans (`OSteamID`, `OName`, `Length`, `Time`, `AName`, `ASteamID`, `Reason`, `ServerID`, `MAdmin`, `MTime`, `LoginAttempt`) VALUES ('"..steamid.."',NULL,'"..BanLength.."','"..os.time().."','"..GB_Escape(AdminName).."','"..AdminSteam.."','"..GB_Escape(reason).."','"..GB_SERVERID.."','','"..os.time().."',0);");
		end
	end
	AddBanQuery:start()

	-- Regardless of outcome Kick player From Server
	--RunConsoleCommand('kickid',steamid,"You've been banned from the server.");
	
end

function GB_ModifyBan(name, BanLength, reason, time, AdminName, steamid)
	--Send ban update to the Database
	local UpdateBanQuery = ULX_DB:query("UPDATE ulx_bans SET OName='".. name .."', Length='".. BanLength .."', Reason='".. reason .."', MTime='".. time .."', MAdmin='".. GB_Escape(AdminName) .."' WHERE OSteamID='".. steamid .."';");
	UpdateBanQuery.onSuccess = function()
		print("[ULX] - Ban Modified!");
		if name == nil then
			ULib.bans[steamid] = { unban = tonumber(BanLength), admin = AdminName, reason = reason, modified_admin = GB_Escape(AdminName), modified_time = tonumber(time) };
		else
			ULib.bans[steamid] = { unban = tonumber(BanLength), name = name, admin = AdminName, reason = reason, modified_admin = GB_Escape(AdminName), modified_time = tonumber(time) };
		end
	end
	UpdateBanQuery.onError = function(db, err) 
		print('[ULX] (UpdateBanQuery) - Error: ', err) 
		GB_AddTField("UPDATE ulx_bans SET OName='".. name .."', Length='".. BanLength .."', Reason='".. reason .."', MTime='".. time .."', MAdmin='".. GB_Escape(AdminName) .."' WHERE OSteamID='".. steamid .."';")
	end
	UpdateBanQuery:start()
end


//Overwrite the ULib function for unbanning
function ULib.unban( steamid )
	--Query the Ban to the Database
	local UnBanQuery = ULX_DB:query("DELETE FROM ulx_bans WHERE OSteamID='"..steamid.."'");
	UnBanQuery.onSuccess = function()
		print("[ULX] - Ban Removed!");
		ULib.bans[steamid] = nil;
	end
	UnBanQuery.onError = function(db, err) 
		print('[ULX] (UnBanQuery) - Error: ', err)
		GB_AddTField("DELETE FROM ulx_bans WHERE OSteamID='"..steamid.."'")
	end
	UnBanQuery:start()
	
	--Possible Glitch Fix, Just Incase
	RunConsoleCommand('removeid',steamid);
	
	--Refresh the List!
	ULib.refreshBans()
end


//Refreshes the ban List
function ULib.refreshBans()

	--Use their tables ;)
	ULib.bans = nil
	ULib.bans = {}
	xgui.ulxbans = {}

	local BanList = ULX_DB:query("SELECT * FROM ulx_bans ORDER BY BanID DESC")
	if !BanList then return end -- Fix Error when MySQL Server failure
	
	BanList:wait()
	BanList.onSuccess = function()
		local data = BanList:getData()
		for i = 1, #data do
			if data[i]['OName'] != nil then
				table.insert( ULib.bans, tonumber(data[i]['OSteamID']) )ULib.bans[data[i]['OSteamID']] = { unban = tonumber(data[i]['Length']), admin = data[i]['AName'], reason = data[i]['Reason'], name = data[i]['OName'], time = tonumber(data[i]['Time']), modified_admin = data[i]['MAdmin'], modified_time = tonumber(data[i]['MTime']) }
			else
				table.insert( ULib.bans, tonumber(data[i]['OSteamID']) )ULib.bans[data[i]['OSteamID']] = { unban = tonumber(data[i]['Length']), admin = data[i]['AName'], reason = data[i]['Reason'], time = tonumber(data[i]['Time']), modified_admin = data[i]['MAdmin'], modified_time = tonumber(data[i]['MTime']) }
			end
			--^^ ULX Ban Info
			---------------------------------
			for k, v in pairs( ULib.bans ) do
				xgui.ulxbans[k] = v           -- Make sure it loads bans!
			end
			---------------------------------
			local t = {}
			t[data[i]['OSteamID']] = ULib.bans[data[i]['OSteamID']]
			xgui.addData( {}, "bans", t ) -- This will error out on startup (Most Times, GMod 13's Addon Loading is fucked), but that's fine, all ban data gets loaded already
		end
			
		if GB_UsageStats then
			GB_SendUsageStats(#data);
		end
	end
	BanList.onError = function(db, err) print('[ULX] (BanList) - Error: ', err) end
	BanList:start()

end
//Refresh on Script Load -- Otherwise has issues
ULib.refreshBans()


//See if a player is banned or not and display time left.
function GB_PlayerAuthed( ComID, IP, RealPass, ClientPass, PlayerNick )
	-- Query Bans In Descending order of banid and LIMIT 1 to obtain the latest ban
	local SteamID = GB_ComIDtoSteamID(ComID)
	if ULib.bans[SteamID] then
		print("[ULX] AUTHING PLAYER: " .. PlayerNick .. ' WITH SteamID: ' .. SteamID)
		print('[ULX] Banned')
		local LoginAttemptQuery = ULX_DB:query("UPDATE `ulx_bans` SET LoginAttempt = LoginAttempt + 1 WHERE OSteamID='"..SteamID.."'");
		LoginAttemptQuery:start()
		local BanInfo = ULib.bans[SteamID]
		local bantime = BanInfo.unban
		if bantime >= os.time() then
			local timeLeft = bantime - os.time();
			local Minutes = math.floor(timeLeft / 60);
			local Seconds = timeLeft - (Minutes * 60);
			local Hours = math.floor(Minutes / 60);
			local Minutes = Minutes - (Hours * 60);
			local Days = math.floor(Hours / 24);
			local Hours = Hours - (Days * 24);
				
			if (Minutes == 0 && Hours == 0 && Days == 0) then
				return false, "You are banned. Lifted in: " .. Seconds + 1 .. " Seconds.\n(Reason: " .. BanInfo.reason .. ")\nVisit http://jonathan1358.com/f/ for an unban appeal.";
			elseif (Hours == 0 && Days == 0) then
				return false, "You are banned. Lifted in: " .. Minutes + 1 .. " Minutes.\n(Reason: " .. BanInfo.reason .. ")\nVisit http://jonathan1358.com/f/ for an unban appeal.";
			elseif (Days == 0) then
				return false, "You are banned. Lifted in: " .. Hours + 1 .. " Hours.\n(Reason: " .. BanInfo.reason .. ")\nVisit http://jonathan1358.com/f/ for an unban appeal.";
			else
				return false, "You are banned. Lifted in: " .. Days + 1 .. " Days.\n(Reason: " .. BanInfo.reason .. ")\nVisit http://jonathan1358.com/f/ for an unban appeal.";
			end
		end
		if bantime == 0 then
			return false, GB_PermaMessage .. "(Reason: " .. BanInfo.reason .. ")";
		end
		if (bantime <= os.time() && !bantime == 0) then
			print("[ULX] - Removing expired bans!");
			ULib.unban(SteamID);
		end
	else
		print("[ULX] AUTHING PLAYER: " .. PlayerNick .. ' WITH SteamID: ' .. SteamID)
		print("[ULX] User has no active bans");
	end
end
hook.Add( "CheckPassword", "CheckPassword_GB", GB_PlayerAuthed )


// Timer
timer.Create( "GB_RefreshTimer", GB_RefreshTime, 0, function() ULib.refreshBans() end)