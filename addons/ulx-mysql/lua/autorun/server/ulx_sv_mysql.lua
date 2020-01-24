require('mysqloo')

-- Start of Config */
-- The following are your mysql details. */
local HOST = "10.0.4.101" -- Host name or IP to your mysql database.
local USER = "sv_gm" -- User name for your mysql database.
local PASS = "urfJCXRfzwsat4Ap" -- Password for your mysql database.
local NAME = "serveur_garrysmod" -- The name of your data where it will create the mysql tables
local PORT = 3300 -- Port to your mysql(99.9% of the time its 3306).

-- The following are only, true OR false, and they're a boolean. */
local ENABLE_USERS = true -- Whether you want users to be synced to all servers.
local ENABLE_GROUPS = true -- Whether you want groups to be synced to all servers.
local ENABLE_BANS = false -- Whether you want bans to be synced to all servers.
local ENABLE_BACKUP = true -- Whether you want to store a local copy.

-- The following are only, numbers, and are measured in seconds. */
local REFRESH_TIME = 180 -- The amount of time you want the server to refresh groups.
local BACKUP_TIME = 300 -- The amount of time you want the server to write a local backup.
-- End of Config */

gameevent.Listen("player_connect")

function ULib.Connect()
	if !mysqloo then MsgN("[ULX MySQL] -> Failed to load mysqloo module.\n\tPlease recheck your version to make sure it's installed correctly.\n\tAlso check to see if you have the right version.") return end
	
	ULib.MySQL = mysqloo.connect(HOST, USER, PASS, NAME, PORT)
	ULib.MySQL.onConnected = function()
		ULib.MySQLConnected = true
		
		if ENABLE_GROUPS then
			ULib.ucl.getGroups()
		end
		
		if ENABLE_USERS then
			ULib.ucl.getUsers()
		end
		
		if ENABLE_BANS then
			ULib.getBans()
		end
		
		MsgN("[ULX MySQL] Successfully to connect to database.")
	end
	ULib.MySQL.onConnectionFailed = function(db, err)
		ULib.MySQLConnected = false
		MsgN("[ULX MySQL] Failed to connect to database -> " .. err)
	end
	ULib.MySQL:connect()
end
ULib.Connect()

function ULib.MySQL:DoQuery(query, func, err)
	if !mysqloo then MsgN("[ULX MySQL] -> Failed to load mysqloo module.\n\tPlease recheck your version to make sure it's installed correctly.\n\tAlso check to see if you have the right version.") return end
	if !ULib.MySQLConnected then return end
	if string.GetChar(query, query:len()) != ";" then query = query .. ";" end
	
	local query1 = ULib.MySQL:query(query)
	query1.onAborted = function( q )
		MsgN("[ULX MySQL] Query Aborted:", q)
		
		file.Append("query_aborted.txt", q .. "\n")
	end
	query1.onError = function( q, e, s )
		MsgN("[ULX MySQL] Query Failure:", e)
		
		file.Append("query_failure.txt", q .. "\t" .. e .. "\n")
		
		if err then
			err(q, e)
		end
	end
	query1.onSuccess = function(q)
		if func then
			func(q:getData())
		end
	end
	
	query1:start()
end

function ULib.ucl.getGroups()
	if !ENABLE_GROUPS then return end
	
	ULib.ucl.groups = {}
	
	ULib.MySQL:DoQuery("SELECT * FROM `ulx_groups`", function( data )
		if !ULib.MySQLData then ULib.MySQLData = true end
		
		for k, v in pairs(data) do
			if v['can_target'] == "" or v['can_target'] == " "  or v['can_target'] == "NULL" then
				v['can_target'] = nil
			end
			
			if v['inherit_from'] == "" or v['inherit_from'] == " " or v['inherit_from'] == "NULL" then
				v['inherit_from'] = nil
			end
			
			if v['inherit_from'] == "user" and v['name'] == "user" or v['inherit_from'] == v['name'] then
				v['inherit_from'] = nil
				
				ULib.MySQL:DoQuery("UPDATE `ulx_groups` SET `inherit_from`='" .. ULib.MySQL:escape("") .. "' WHERE `name`='" .. v['name'] .. "'")
			end
			
			ULib.ucl.groups[v['name']] = { allow = util.JSONToTable(v['allow']) or {}, can_target = v['can_target'] or nil, inherit_from = v['inherit_from'] or nil }
		end
	end)
end

function ULib.ucl.getUsers()
	if !ENABLE_USERS then return end
	
	ULib.ucl.users = {}
	
	ULib.MySQL:DoQuery("SELECT * FROM `ulx_users`", function( data )
		if !ULib.MySQLData then ULib.MySQLData = true end
		
		for k, v in pairs(data) do
			ULib.ucl.users[v['steamid']] = { allow = util.JSONToTable(v['allow']) or {}, name = v['name'] or nil, deny = util.JSONToTable(v['deny']) or {}, group = v['group'] or "user" }
		end
	end)
end

-- function ULib.getBans()
	-- if !ENABLE_BANS then return end
	
	-- ULib.bans = {}
	
	-- ULib.MySQL:DoQuery("SELECT * FROM `bans`", function( data )
		-- if !ULib.MySQLData then ULib.MySQLData = true end
		
		-- for k, v in pairs(data) do
			-- ULib.bans[v['steamid']] = { reason = v['reason'], admin = v['admin'], unban = tonumber(v['unban']), time = tonumber(v['time']), name = v['name'] }
			
			-- if v['modified_time'] then
				-- ULib.bans[v['steamid']].modified_time = tonumber(v['modified_time'])
			-- end
			
			-- if v['modified_admin'] then
				-- ULib.bans[v['steamid']].modified_admin = v['modified_admin']
			-- end
		-- end
	-- end)
-- end

function ULib.refreshGroups()
	if !ENABLE_GROUPS then return end
	
	ULib.MySQL:DoQuery("SELECT * FROM `ulx_groups`", function( data )
		for k, v in pairs(data) do
			if v['can_target'] == "" or v['can_target'] == " " or v['can_target'] == "NULL" then
				v['can_target'] = nil
			end
			
			if v['inherit_from'] == "" or v['inherit_from'] == " " or v['inherit_from'] == "NULL" then
				v['inherit_from'] = nil
			end
			
			if !ULib.ucl.groups[v['name']] then
				ULib.ucl.groups[v['name']] = { allow = util.JSONToTable(v['allow']) or {}, can_target = v['can_target'] or nil, inherit_from = v['inherit_from'] or nil }
			else
				ULib.ucl.groups[v['name']].allow = util.JSONToTable(v['allow']) or {}
				ULib.ucl.groups[v['name']].inherit_from = v['inherit_from'] or nil
				ULib.ucl.groups[v['name']].can_target = v['can_target'] or nil
			end
			
			if k and k == #data then
				hook.Call( ULib.HOOK_UCLCHANGED )
			end
		end
	end)
end

-- local _addban = ULib.addBan
-- function ULib.addBan( steamid, time, reason, name, admin )
	-- if !ENABLE_BANS then return _addban( steamid, time, reason, name, admin ) end
	
	-- local strTime = time ~= 0 and string.format( "for %s minute(s)", time ) or "permanently"
	-- local showReason = string.format( "Banned %s: %s", strTime, reason )
	
	-- local players = player.GetAll()
	-- for i=1, #players do
		-- if players[ i ]:SteamID() == steamid then
			-- ULib.kick( players[ i ], showReason, admin )
		-- end
	-- end
	
	-- game.ConsoleCommand( string.format( "kickid %s %s\n", steamid, showReason or "" ) )
	
	-- local admin_name
	-- if admin then
		-- admin_name = "(Console)"
		-- if admin:IsValid() then
			-- admin_name = string.format( "%s(%s)", admin:Name(), admin:SteamID() )
		-- end
	-- end
	
	-- local found = false
	-- local t = {}
	-- if ULib.bans[ steamid ] then
		-- found = true
		
		-- t = ULib.bans[ steamid ]
		-- t.modified_admin = admin_name
		-- t.modified_time = os.time()
	-- else
		-- t.admin = admin_name
	-- end
	-- t.time = t.time or os.time()
	-- if time > 0 then
		-- t.unban = ( ( time * 60 ) + os.time() )
	-- else
		-- t.unban = 0
	-- end
	-- if reason then
		-- t.reason = reason
	-- end
	-- if name then
		-- t.name = name
	-- end
	
	-- ULib.bans[ steamid ] = t
	
	-- local banfound = false
	
	-- ULib.MySQL:DoQuery("SELECT * FROM `bans` WHERE `steamid`='" .. steamid .. "'", function( data )
		-- data = data[1]
		
		-- if data then
			-- ULib.MySQL:DoQuery("UPDATE `bans` SET `reason`='" .. ULib.MySQL:escape(t.reason) .. "', `admin`='" .. ULib.MySQL:escape(t.admin) .. "' WHERE `steamid`='" .. steamid .. "'")
		-- else
			-- ULib.MySQL:DoQuery("INSERT INTO `bans` (`steamid`, `reason`, `admin`, `unban`, `time`, `name`) VALUES('" .. ULib.MySQL:escape(steamid) .. "', '" .. ULib.MySQL:escape(t.reason or "No reason given.") .. "', '" .. ULib.MySQL:escape(t.admin or "Console") .. "', '" .. t.unban .. "', '" .. t.time .. "', '" .. ULib.MySQL:escape(t.name or "SteamID Ban") .. "')")
		-- end
	-- end)
	
	-- ULib.MySQL:DoQuery("SELECT * FROM `bans`", function( data )
		-- for k, v in pairs(data) do
			-- if tonumber(v['unban']) > os.time() or tonumber(v['unban']) == 0 then
				-- ULib.bans[v['steamid']] = { reason = v['reason'], admin = v['admin'], unban = tonumber(v['unban']), time = tonumber(v['time']), name = v['name'] }
			-- else
				-- ULib.unban(v['steamid'])
			-- end
		-- end
	-- end)
	
	-- syncBans()
-- end

-- local _unban = ULib.unban
-- function ULib.unban( steamid )
	-- if !ENABLE_BANS then return _unban(steamid) end
	
	-- ULib.MySQL:DoQuery("SELECT `steamid` FROM `bans` WHERE `steamid`='" .. steamid .. "'", function( data )
		-- data = data[1]
		
		-- if data and data['steamid'] then
			-- ULib.MySQL:DoQuery("DELETE FROM `bans` WHERE `steamid`='" .. steamid .. "'")
		-- end
	-- end)
	
	-- ULib.bans[ steamid ] = nil
	
	-- game.ConsoleCommand("removeid " .. steamid .. " \n")
	
	-- syncBans()
-- end

local _addGroup = ULib.ucl.addGroup
function ULib.ucl.addGroup( name, allows, inherit_from )
	if !ENABLE_GROUPS then return _addGroup( name, allows, inherit_from ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addGroup", "string", name )
	ULib.checkArg( 2, "ULib.ULib.ucl.addGroup", {"nil","table"}, allows )
	ULib.checkArg( 3, "ULib.ULib.ucl.addGroup", {"nil","string"}, inherit_from )
	allows = allows or {}
	inherit_from = inherit_from or "user"
	
	if ULib.ucl.groups[ name ] then return error( "Group already exists, cannot add again (" .. name .. ")", 2 ) end
	if inherit_from then
		if inherit_from == name then return error( "Group cannot inherit from itself", 2 ) end
		if not ULib.ucl.groups[ inherit_from ] then return error( "Invalid group for inheritance (" .. tostring( inherit_from ) .. ")", 2 ) end
	end
	
	for k, v in ipairs( allows ) do allows[ k ] = v:lower() end
	
	ULib.ucl.groups[ name ] = { allow=allows, inherit_from=inherit_from }
	
	local query = "`name`"
	local query2 = "'" .. ULib.MySQL:escape(name) .. "'"
	
	query = query .. ", `allow`"
	query2 = query2 .. ", '" .. ULib.MySQL:escape(util.TableToJSON(allows)) .. "'"
	
	query = query .. ", `inherit_from`"
	query2 = query2 .. ", '" .. ULib.MySQL:escape(inherit_from) .. "'"
	
	ULib.MySQL:DoQuery("INSERT INTO `ulx_groups` (" .. query .. ") VALUES(" .. query2 .. ")")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _groupAllow = ULib.ucl.groupAllow
function ULib.ucl.groupAllow( name, access, revoke )
	if !ENABLE_GROUPS then return _groupAllow( name, access, revoke ) end
	
	ULib.checkArg( 1, "ULib.ucl.groupAllow", "string", name )
	ULib.checkArg( 2, "ULib.ucl.groupAllow", {"string","table"}, access )
	ULib.checkArg( 3, "ULib.ucl.groupAllow", {"nil","boolean"}, revoke )
	
	if type( access ) == "string" then access = { access } end
	if not ULib.ucl.groups[ name ] then return error( "Group does not exist for changing access (" .. name .. ")", 2 ) end
	
	local allow = ULib.ucl.groups[ name ].allow
	
	local changed = false
	for k, v in pairs( access ) do
		local access = v:lower()
		local accesstag
		if type( k ) == "string" then
			accesstag = v:lower()
			access = k:lower()
		end
		
		if not revoke and (allow[ access ] ~= accesstag or (not accesstag and not ULib.findInTable( allow, access ))) then
			changed = true
			if not accesstag then
				table.insert( allow, access )
				allow[ access ] = nil
			else
				allow[ access ] = accesstag
				if ULib.findInTable( allow, access ) then
					table.remove( allow, ULib.findInTable( allow, access ) )
				end
			end
		elseif revoke and (allow[ access ] or ULib.findInTable( allow, access )) then
			changed = true
			
			allow[ access ] = nil
			if ULib.findInTable( allow, access ) then
				table.remove( allow, ULib.findInTable( allow, access ) )
			end
		end
	end
	
	local group = ULib.ucl.groups[name]
	ULib.MySQL:DoQuery("UPDATE `ulx_groups` SET `allow`='"  .. ULib.MySQL:escape(util.TableToJSON(group.allow)) ..  "', `inherit_from`='" .. ULib.MySQL:escape(group.inherit_from or "user") .. "', `can_target`='" .. ULib.MySQL:escape(group.can_target or " ") .. "' WHERE `name`='" .. name .. "'")
	
	if changed then
		for id, userInfo in pairs( ULib.ucl.authed ) do
			local ply = ULib.getPlyByID( id )
			if ply and ply:CheckGroup( name ) then
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
		
		ULib.ucl.saveGroups()
		
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
	
	return changed
end

local _renameGroup = ULib.ucl.renameGroup
function ULib.ucl.renameGroup( orig, new )
	if !ENABLE_GROUPS then return _renameGroup( orig, new ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.renameGroup", "string", orig )
	ULib.checkArg( 2, "ULib.ULib.ucl.renameGroup", "string", new )
	
	if orig == ULib.ACCESS_ALL then return error( "This group (" .. orig .. ") cannot be renamed!", 2 ) end
	if not ULib.ucl.groups[ orig ] then return error( "Group does not exist for renaming (" .. orig .. ")", 2 ) end
	if ULib.ucl.groups[ new ] then return error( "Group already exists, cannot rename (" .. new .. ")", 2 ) end
	
	for id, userInfo in pairs( ULib.ucl.users ) do
		if userInfo.group == orig then
			userInfo.group = new
		end
	end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( orig ) then
			if ply:GetUserGroup() == orig then
				ULib.queueFunctionCall( ply.SetUserGroup, ply, new )
			else
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
	end
	
	ULib.ucl.groups[ new ] = ULib.ucl.groups[ orig ]
	ULib.ucl.groups[ orig ] = nil
	
	ULib.MySQL:DoQuery("DELETE FROM `ulx_groups` WHERE `name`='" .. orig .. "'")
	
	local query = "`name`"
	local query2 = "'" .. ULib.MySQL:escape(new) .. "'"
	
	if ULib.ucl.groups[ new ].allow then
		query = query .. ", `allow`"
		query2 = query2 .. ", '" .. ULib.MySQL:escape(util.TableToJSON(ULib.ucl.groups[ new ].allow)) .. "'"
	end
	
	if ULib.ucl.groups[ new ].can_target then
		query = query .. ", `can_target`"
		query2 = query2 .. ", '" .. ULib.MySQL:escape(ULib.ucl.groups[ new ].can_target) .. "'"
	end
	
	if ULib.ucl.groups[ new ].inherit_from then
		query = query .. ", `inherit_from`"
		query2 = query2 .. ", '" .. ULib.MySQL:escape(ULib.ucl.groups[ new ].inherit_from) .. "'"
	end
	
	ULib.MySQL:DoQuery("INSERT INTO `ulx_groups` (" .. query .. ") VALUES(" .. query2 .. ")")
	
	for _, groupInfo in pairs( ULib.ucl.groups ) do
		if groupInfo.inherit_from == orig then
			groupInfo.inherit_from = new
		end
	end
	
	ULib.ucl.saveUsers()
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _removeGroup = ULib.ucl.removeGroup
function ULib.ucl.removeGroup( name )
	if !ENABLE_GROUPS then return _removeGroup( name ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.removeGroup", "string", name )
	
	if name == ULib.ACCESS_ALL then return error( "This group (" .. name .. ") cannot be removed!", 2 ) end
	if not ULib.ucl.groups[ name ] then return error( "Group does not exist for removing (" .. name .. ")", 2 ) end
	
	local inherits_from = ULib.ucl.groupInheritsFrom( name )
	if inherits_from == ULib.ACCESS_ALL then inherits_from = nil end
	
	for id, userInfo in pairs( ULib.ucl.users ) do
		if userInfo.group == name then
			userInfo.group = inherits_from
			
			ULib.MySQL:DoQuery("DELETE FROM `ulx_users` WHERE `steamid`='" .. id .. "'")
			
			syncUsers()
		end
	end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( name ) then
			if ply:GetUserGroup() == name then
				ULib.queueFunctionCall( ply.SetUserGroup, ply, inherits_from or ULib.ACCESS_ALL )
			else
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
	end
	
	ULib.MySQL:DoQuery("DELETE FROM `ulx_groups` WHERE `name`='" .. name .. "'")
	
	ULib.ucl.groups[ name ] = nil
	for _, groupInfo in pairs( ULib.ucl.groups ) do
		if groupInfo.inherit_from == name then
			groupInfo.inherit_from = inherits_from
		end
	end
	
	ULib.ucl.saveUsers()
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _setGroupInheritance = ULib.ucl.setGroupInheritance
function ULib.ucl.setGroupInheritance( group, inherit_from )
	if !ENABLE_GROUPS then return _setGroupInheritance( group, inherit_from ) end
	
	ULib.checkArg( 1, "ULib.ucl.renameGroup", "string", group )
	ULib.checkArg( 2, "ULib.ucl.renameGroup", {"nil","string"}, inherit_from )
	if inherit_from then
		if inherit_from == ULib.ACCESS_ALL then inherit_from = nil end
	end
	
	if group == ULib.ACCESS_ALL then return error( "This group (" .. group .. ") cannot have it's inheritance changed!", 2 ) end
	if not ULib.ucl.groups[ group ] then return error( "Group does not exist (" .. group .. ")", 2 ) end
	if inherit_from and not ULib.ucl.groups[ inherit_from ] then return error( "Group for inheritance does not exist (" .. inherit_from .. ")", 2 ) end
	
	local old_inherit = ULib.ucl.groups[ group ].inherit_from
	ULib.ucl.groups[ group ].inherit_from = inherit_from
	local groupCheck = ULib.ucl.groupInheritsFrom( group )
	while groupCheck do
		if groupCheck == group then
			ULib.ucl.groups[ group ].inherit_from = old_inherit
			error( "Changing group \"" .. group .. "\" inheritance to \"" .. inherit_from .. "\" would cause cyclical inheritance. Aborting.", 2 )
		end
		groupCheck = ULib.ucl.groupInheritsFrom( groupCheck )
	end
	ULib.ucl.groups[ group ].inherit_from = old_inherit
	
	if old_inherit == inherit_from then return end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( group ) then
			ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
		end
	end
	
	ULib.ucl.groups[ group ].inherit_from = inherit_from
	
	ULib.MySQL:DoQuery("UPDATE `ulx_groups` SET `inherit_from`='" .. ULib.MySQL:escape(inherit_from or "user") .. "' WHERE `name`='" .. group .. "'")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _setGroupCanTarget = ULib.ucl.setGroupCanTarget
function ULib.ucl.setGroupCanTarget( group, can_target )
	if !ENABLE_GROUPS then return _setGroupCanTarget( group, can_target ) end
	
	ULib.checkArg( 1, "ULib.ucl.setGroupCanTarget", "string", group )
	ULib.checkArg( 2, "ULib.ucl.setGroupCanTarget", {"nil","string"}, can_target )
	if not ULib.ucl.groups[ group ] then return error( "Group does not exist (" .. group .. ")", 2 ) end
	
	if ULib.ucl.groups[ group ].can_target == can_target then return end
	
	ULib.ucl.groups[ group ].can_target = can_target
	ULib.MySQL:DoQuery("UPDATE `ulx_groups` SET `can_target`='" .. ULib.MySQL:escape(can_target) .. "' WHERE `name`='" .. group .. "'")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _addUser = ULib.ucl.addUser
function ULib.ucl.addUser( id, allows, denies, group )
	if !ENABLE_USERS then return _addUser( id, allows, denies, group ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addUser", "string", id )
	ULib.checkArg( 2, "ULib.ULib.ucl.addUser", {"nil","table"}, allows )
	ULib.checkArg( 3, "ULib.ULib.ucl.addUser", {"nil","table"}, denies )
	ULib.checkArg( 4, "ULib.ULib.ucl.addUser", {"nil","string"}, group )
	
	id = id:upper()
	allows = allows or {}
	denies = denies or {}
	if allows == ULib.DEFAULT_GRANT_ACCESS.allow then allows = table.Copy( allows ) end
	if denies == ULib.DEFAULT_GRANT_ACCESS.deny then denies = table.Copy( denies ) end
	if group and not ULib.ucl.groups[ group ] then return error( "Group does not exist for adding user to (" .. group .. ")", 2 ) end
	
	for k, v in ipairs( allows ) do allows[ k ] = v:lower() end
	for k, v in ipairs( denies ) do denies[ k ] = v:lower() end
	
	local ply = ULib.getPlyByID( id )
	local found = false
	local name
	
	if ULib.ucl.users[ id ] then
		found = true
	end
	
	if ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name then name = ULib.ucl.users[ id ].name end
	ULib.ucl.users[ id ] = { allow=allows, deny=denies, group=group, name=name }
	
	if ply then
		name = ply:Nick()
	end
	
	ULib.MySQL:DoQuery("SELECT * FROM `ulx_users` WHERE `steamid`='" .. id .. "'", function( data )
		data = data[1]
		
		if data and data['steamid'] then
			ULib.MySQL:DoQuery("UPDATE `ulx_users` SET `name`='" .. ULib.MySQL:escape(name) .. "', `group`='" .. ULib.MySQL:escape(group) .. "' WHERE `steamid`='" .. id .. "'")
			
			found = true
		else
			ULib.MySQL:DoQuery("INSERT INTO `ulx_users` (`steamid`, `deny`, `allow`, `name`, `group`) VALUES('" .. ULib.MySQL:escape(id) .. "', '" .. ULib.MySQL:escape(util.TableToJSON(denies)) .. "', '" .. ULib.MySQL:escape(util.TableToJSON(allows)) .. "', '" .. ULib.MySQL:escape(name or "No name given.") .. "', '" .. ULib.MySQL:escape(group) .. "')")
			
			found = false
		end
	end)
	
	ULib.ucl.saveUsers()
	
	syncUsers()
	
	if ply then
		ULib.ucl.probe( ply )
	else
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
end

local _removeUser = ULib.ucl.removeUser
function ULib.ucl.removeUser( id )
	if !ENABLE_USERS then return _removeUser( id ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addUser", "string", id )
	id = id:upper()
	
	local userInfo = ULib.ucl.users[ id ] or ULib.ucl.authed[ id ]
	if not userInfo then return error( "User id does not exist for removing (" .. id .. ")", 2 ) end
	
	local changed = false
	
	if ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		local ply = ULib.getPlyByID( id )
		if not ply then return error( "SANITY CHECK FAILED!" ) end
		
		local ip = ULib.splitPort( ply:IPAddress() )
		local checkIndexes = { ply:UniqueID(), ip, ply:SteamID() }
		
		for _, index in ipairs( checkIndexes ) do
			if ULib.ucl.users[ index ] then
				changed = true
				ULib.ucl.users[ index ] = nil
				break
			end
		end
		
		ULib.MySQL:DoQuery("DELETE FROM `ulx_users` WHERE `steamid`='" .. ply:SteamID() .. "'")
	else
		changed = true
		ULib.ucl.users[ id ] = nil
		
		ULib.MySQL:DoQuery("DELETE FROM `ulx_users` WHERE `steamid`='" .. id .. "'")
	end
	
	syncUsers()
	
	ULib.ucl.saveUsers()
	
	local ply = ULib.getPlyByID( id )
	if ply then
		ply:SetUserGroup( ULib.ACCESS_ALL, true )
		ULib.ucl.probe( ply )
	else
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
end

local _userAllow = ULib.ucl.userAllow
function ULib.ucl.userAllow( id, access, revoke, deny )
	if !ENABLE_USERS then return _userAllow( id, access, revoke, deny ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.userAllow", "string", id )
	ULib.checkArg( 2, "ULib.ULib.ucl.userAllow", {"string","table"}, access )
	ULib.checkArg( 3, "ULib.ULib.ucl.userAllow", {"nil","boolean"}, revoke )
	ULib.checkArg( 4, "ULib.ULib.ucl.userAllow", {"nil","boolean"}, deny )
	
	id = id:upper()
	if type( access ) == "string" then access = { access } end
	
	local uid = id
	if not ULib.ucl.authed[ uid ] then
		local ply = ULib.getPlyByID( id )
		if ply and ply:IsValid() then
			uid = ply:UniqueID()
		end
	end
	
	local userInfo = ULib.ucl.users[ id ] or ULib.ucl.authed[ uid ]
	if not userInfo then return error( "User id does not exist for changing access (" .. id .. ")", 2 ) end
	
	if userInfo.guest then
		local allows = {}
		local denies = {}
		if not revoke and not deny then allows = access
		elseif not revoke and deny then denies = access end
		
		ULib.ucl.addUser( id, allows, denies )
		return true
	end
	
	local accessTable = userInfo.allow
	local otherTable = userInfo.deny
	if deny then
		accessTable = userInfo.deny
		otherTable = userInfo.allow
	end
	
	local changed = false
	for k, v in pairs( access ) do
		local access = v:lower()
		local accesstag
		if type( k ) == "string" then
			access = k:lower()
			if not revoke and not deny then
				accesstag = v:lower()
			end
		end
		
		if not revoke and (accessTable[ access ] ~= accesstag or (not accesstag and not ULib.findInTable( accessTable, access ))) then
			changed = true
			if not accesstag then
				table.insert( accessTable, access )
				accessTable[ access ] = nil
			else
				accessTable[ access ] = accesstag
				if ULib.findInTable( accessTable, access ) then
					table.remove( accessTable, ULib.findInTable( accessTable, access ) )
				end
			end
			
			if deny then
				otherTable[ access ] = nil
			end
			if ULib.findInTable( otherTable, access ) then
				table.remove( otherTable, ULib.findInTable( otherTable, access ) )
			end
		elseif revoke and (accessTable[ access ] or ULib.findInTable( accessTable, access )) then
			changed = true
			
			if not deny then
				accessTable[ access ] = nil
			end
			if ULib.findInTable( accessTable, access ) then
				table.remove( accessTable, ULib.findInTable( accessTable, access ) )
			end
		end
	end
	
	local ply = ULib.getPlyByID( id )
	
	if ply then
		local v = ULib.ULib.ucl.users[ply:SteamID()]
		
		ULib.MySQL:DoQuery("UPDATE `ulx_users` SET `deny`='" .. ULib.MySQL:escape(util.TableToJSON(v.deny)) .. "', `allow`='"  .. ULib.MySQL:escape(util.TableToJSON(v.allow)) ..  "', `name`='" .. ULib.MySQL:escape(v.name) .. "', `group`='" .. ULib.MySQL:escape(v.group) .. "' WHERE `steamid`='" .. ply:SteamID() .. "'")
	end
	
	if changed then
		if ply then
			ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
		end
		
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
	
	ULib.ucl.saveUsers()
	
	syncUsers()
	
	return changed
end

local _protectedfiles = { "data/ulib/bans.txt", "data/ulib/users.txt", "data/ulib/groups.txt" }
local _fileWrite = ULib.fileWrite
function ULib.fileWrite( file, str )
	if table.HasValue(_protectedfiles, file) then
		if str == "" then
			MsgN("[ULX MySQL] -> ULib.fileWrite -> Save(" .. string.Replace(file, "data/ulib/", "") .. ") halted.\n\tFile was being overwritten with no content.")
			return false
		end
	else
		return _fileWrite( file, str )
	end
end

hook.Add("PlayerInitialSpawn", "PlayerBanned", function( ply )
	if !ULib.MySQLConnected then
		ply:ChatPrint("[ULXMySQL] Your sever was unable to connect to the database. Errors will occur until it's connected.")
	end
	
	if ULib.MySQLConnected and !ULib.MySQLData then
		ply:ChatPrint("[ULXMySQL] Your sever was unable to fetch data from mysql database. Errors will occur until data is retrieved.")
	end
	
	if ENABLE_BANS then
		for k, v in pairs(ULib.bans) do
			if k == ply:SteamID() then
				if tonumber(v.unban) < os.time() and tonumber(v.unban) != 0 then
					ULib.unban(ply:SteamID())
				end
			end
		end
		
		ULib.MySQL:DoQuery("SELECT * FROM `bans` WHERE `steamid`='" .. ply:SteamID() .. "'", function( data )
			data = data[1]
			
			if data then
				if tonumber(data['unban']) > os.time() or tonumber(data['unban']) == 0 then
					if !ULib.bans[data['steamid']] then
						ULib.bans[data['steamid']] = { reason = data['reason'], admin = data['admin'], unban = tonumber(data['unban']), time = tonumber(data['time']), name = data['name'] }
					else
						ULib.bans[data['steamid']] = { reason = data['reason'], admin = data['admin'], unban = tonumber(data['unban']), time = tonumber(data['time']), name = data['name'] }
						
						
						if data['modified_time'] then
							ULib.bans[data['steamid']].modified_time = tonumber(data['modified_time'])
						end
						
						if data['modified_admin'] then
							ULib.bans[data['steamid']].modified_admin = tonumber(data['modified_admin'])
						end
					end
					
					local time = "for " .. string.NiceTime(os.difftime(data['unban'], os.time()))
					
					if data['unban'] == 0 or data['modified_time'] == 0 then
						time = "Permanent"
					end
					
					game.ConsoleCommand(string.format("kickid %s %s %s\n", ply:UserID(), "Banned for " .. data['reason'] .. " by " .. data['admin'], time ) )
				else
					ULib.unban(data['steamid'])
				end
			end
		end)
	end
	
	if ENABLE_USERS then
		ULib.MySQL:DoQuery("SELECT * FROM `ulx_users` WHERE `steamid`='" .. ply:SteamID() .. "'", function( data )
			data = data[1]
			
			if data then
				if !ULib.ucl.users[data['steamid']] then
					ULib.ucl.users[data['steamid']] = { allow = util.JSONToTable(data['allow']) or {}, name = data['name'] or "", deny = util.JSONToTable(data['deny']) or {}, group = data['group'] or "user" }
				else
					if data['allow'] then
						ULib.ucl.users[data['steamid']].allow = util.JSONToTable(data['allow'])
					end
					
					if data['deny'] then
						ULib.ucl.users[data['steamid']].deny = util.JSONToTable(data['deny'])
					end
					
					if data['group'] then
						ULib.ucl.users[data['steamid']].group = data['group']
					end
					
					ply:SetUserGroup(data['group'])
				end
				
				if data['name'] and data['name'] != ply:Nick() then
					ULib.MySQL:DoQuery("UPDATE `ulx_users` SET `name`='" .. ULib.MySQL:escape(ply:Nick()) .. "' WHERE `steamid`='" .. ply:SteamID() .. "'")
				end
			end
		end)
	end
	
	timer.Simple(3, function()
		if !IsValid(ply) then return end
		
		if ENABLE_BANS then
			xgui.sendDataTable(ply, "bans")
		end
		
		if ENABLE_USERS then
			xgui.sendDataTable(ply, "users")
		end
		
		if ENABLE_GROUPS then
			xgui.sendDataTable(ply, "groups")
		end
	end)
end)

-- hook.Add("player_connect", "DenyAccessPlayerBanned", function( data )
	-- if ENABLE_BANS then
		-- for k, v in pairs(ULib.bans) do
			-- if k == data['networkid'] then
				-- if tonumber(v.unban) > os.time() or tonumber(v.unban) == 0 then
					-- if !v.reason then
						-- v.reason = "No reason given"
					-- end
					
					-- if !v.admin then
						-- v.admin = "Console"
					-- end
					
					-- local time = "for " .. string.NiceTime(os.difftime(v.unban, os.time()))
					
					-- if v.unban == 0 then
						-- time = "Permanent"
					-- end
					
					-- game.ConsoleCommand(string.format("kickid %s %s %s\n", data['userid'], "Banned for " .. v.reason .. " by " .. v.admin, time ) )
				-- end
			-- end
		-- end
	-- end
-- end)

function ULib.SyncData( ply, cmd, args )
	if IsValid(ply) then ply:ChatPrint("[ULX MySQL] -> Sync -> Error(" .. 12746 .. ") -> This should only be run in the servers console.") return end
	if !ULib.MySQLConnected then MsgN("[ULX MySQL] -> Sync -> Error(" .. 894 .. ") ->Halted\n\tNot connected to database.") return end
	
	MsgN("[ULX MySQL] -> Sync -> Started.\n\tThis may take sometime depending on the size of files.")
	
	local querys, errors = 0, 0
	local groups, error1 = ULib.parseKeyValues(ULib.removeCommentHeader(ULib.fileRead(ULib.UCL_GROUPS), "/"))
	local users, error2 = ULib.parseKeyValues(ULib.removeCommentHeader(ULib.fileRead(ULib.UCL_USERS), "/"))
	local bans, error3 = ULib.parseKeyValues(ULib.removeCommentHeader(ULib.fileRead(ULib.BANS_FILE), "/"))
	
	-- ULib.MySQL:DoQuery("DROP TABLE IF EXISTS `bans`")
	-- ULib.MySQL:DoQuery("DROP TABLE IF EXISTS `ulx_groups`")
	-- ULib.MySQL:DoQuery("DROP TABLE IF EXISTS `ulx_users`")
	
	-- ULib.MySQL:DoQuery("CREATE TABLE IF NOT EXISTS `bans` ( `steamid` varchar(32), `reason` text, `admin` text, `unban` int(11) DEFAULT NULL, `time` int(11) DEFAULT NULL, `name` text, `modified_time` int(11) DEFAULT NULL, `modified_admin` text,  PRIMARY KEY (`steamid`));",
	-- function() querys = querys + 1 end,
	-- function( q, e )
		-- MsgN("[ULX MySQL] -> Sync -> Failed to create bans table.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
		
		-- errors = errors + 1
	-- end)
	-- ULib.MySQL:DoQuery("CREATE TABLE IF NOT EXISTS `ulx_groups` ( `name` text, `allow` longtext, `inherit_from` text, `can_target` text);",
	-- function() querys = querys + 1 end,
	-- function( q, e )
		-- MsgN("[ULX MySQL] -> Sync -> Failed to create groups table.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
		
		-- errors = errors + 1
	-- end)
	-- ULib.MySQL:DoQuery("CREATE TABLE IF NOT EXISTS `ulx_users` ( `steamid` varchar(32) NOT NULL DEFAULT '', `deny` text, `allow` text, `name` text, `group` text, PRIMARY KEY (`steamid`));",
	-- function() querys = querys + 1 end,
	-- function( q, e )
		-- MsgN("[ULX MySQL] -> Sync -> Failed to create users table.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
		
		-- errors = errors + 1
	-- end)
	
	if !error1 then
		for k, v in pairs(groups) do
			local query = "`name`"
			local query2 = "'" .. ULib.MySQL:escape(k) .. "'"
			
			if v.allow then
				query = query .. ", `allow`"
				query2 = query2 .. ", '" .. ULib.MySQL:escape(util.TableToJSON(v.allow)) .. "'"
			end
			
			if v.can_target then
				query = query .. ", `can_target`"
				query2 = query2 .. ", '" .. ULib.MySQL:escape(v.can_target) .. "'"
			end
			
			if v.inherit_from then
				query = query .. ", `inherit_from`"
				query2 = query2 .. ", '" .. ULib.MySQL:escape(v.inherit_from) .. "'"
			end
			
			ULib.MySQL:DoQuery("INSERT INTO `ulx_groups` (" .. query .. ") VALUES(" .. query2 .. ")",
			function() querys = querys + 1 end,
			function( q, e )
				MsgN("[ULX MySQL] -> Sync -> Failed to insert group.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
				
				errors = errors + 1
			end)
		end
	else
		MsgN("[ULX MySQL] -> Sync -> Failed to insert existing groups.\n\tReason: " .. error1)
		
		errors = errors + 1
	end
	
	if !error2 then
		for k, v in pairs(users) do
			local deny, allow, name, group = "[]", "[]", "", "user"
			
			if v.deny then
				deny = util.TableToJSON(v.deny)
			end
			
			if v.allow then
				allow = util.TableToJSON(v.allow)
			end
			
			if v.name then
				name = v.name
			end
			
			if v.group then
				group = v.group
			end
			
			ULib.MySQL:DoQuery("INSERT INTO `ulx_users` (`steamid`, `deny`, `allow`, `name`, `group`) VALUES('" .. ULib.MySQL:escape(k) .. "', '" .. ULib.MySQL:escape(deny) .. "', '" .. ULib.MySQL:escape(allow) .. "', '" .. ULib.MySQL:escape(name) .. "', '" .. ULib.MySQL:escape(group) .. "')",
			function() querys = querys + 1 end,
			function( q, e )
				MsgN("[ULX MySQL] -> Sync -> Failed to insert user.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
				
				errors = errors + 1
			end)
		end
	else
		MsgN("[ULX MySQL] -> Sync -> Failed to insert existing users.\n\tReason: " .. error2)
		
		errors = errors + 1
	end
	
	if !error3 then
		for k, v in pairs(bans) do
			if !v.reason then
				v.reason = "No reason given"
			end
			
			if !v.admin then
				v.admin = "Console"
			end
			
			if !v.name then
				v.name = k
			end
			
			if !v.time then
				v.time = os.time()
			end
			
			if !v.unban then
				v.unban = 0
			end
			
			if string.find(v.unban, "e+") then
				v.unban = 0
			end
			
			local query = "`steamid`, `reason`, `admin`, `unban`, `time`, `name`"
			local query2 = "'" .. ULib.MySQL:escape(k) .. "', '" .. ULib.MySQL:escape(v.reason) .. "', '" .. ULib.MySQL:escape(v.admin) .. "', '" .. v.unban .. "', '" .. v.time .. "', '" .. ULib.MySQL:escape(v.name) .. "'"
			
			if v.modified_time then
				query = query .. ", `modified_time`"
				query2 = query2 .. ", '" .. tonumber(v.modified_time) .. "'"
			end
			
			if v.modified_admin then
				query = query .. ", `modified_admin`"
				query2 = query2 .. ", '" .. v.modified_admin .. "'"
			end
			
			ULib.MySQL:DoQuery("INSERT INTO `bans` (" .. query .. ") VALUES(" .. query2 .. ")",
			function() querys = querys + 1 end,
			function( q, e )
				MsgN("[ULX MySQL] -> Sync -> Failed to insert ban.\n\tReason: " .. q .. ".\n\tQuery: " .. e .. ".")
				
				errors = errors + 1
			end)
		end
	else
		MsgN("[ULX MySQL] -> Sync -> Failed to insert existing bans.\n\tReason: " .. error3)
		
		errors = errors + 1
	end
	
	timer.Simple(3, function()
		MsgN("[ULX MySQL] -> Sync -> Completed with " .. querys .. " querys and " .. errors .. " errors.")
		
		ULib.ucl.getGroups()
		ULib.ucl.getUsers()
		ULib.getBans()
	end)
end
concommand.Add("ulx_mysql_sync", ULib.SyncData)

timer.Create("refreshGroups", REFRESH_TIME, 0, function()
	if !ULib.MySQLConnected then MsgN("[ULX MySQL] -> Refresh Groups -> Not connected to the database.") return end
	if !ENABLE_GROUPS then return end
	
	ULib.refreshGroups()
end)

timer.Create("backTime", BACKUP_TIME, 0, function()
	if !ULib.MySQLConnected then MsgN("[ULX MySQL] -> Backup -> Not connected to the database.") return end
	
	if ENABLE_BACKUP then
		if ENABLE_BANS then
			ULib.fileWrite(ULib.BANS_FILE, ULib.makeKeyValues(ULib.bans))
		end
		
		if ENABLE_USERS then
			ULib.fileWrite(ULib.UCL_USERS, ULib.makeKeyValues(ULib.ucl.users))
		end
		
		if ENABLE_GROUPS then
			ULib.fileWrite(ULib.UCL_GROUPS, ULib.makeKeyValues(ULib.ucl.groups))
		end
	end
end)
