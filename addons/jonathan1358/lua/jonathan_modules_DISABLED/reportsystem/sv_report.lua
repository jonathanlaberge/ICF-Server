util.AddNetworkString("TransferReport")
util.AddNetworkString("TransferAllReports")
util.AddNetworkString("ReportWarning")
util.AddNetworkString("TransferWarningLevel")
require("mysqloo")
 
DATABASE_HOST = "127.0.0.1"
DATABASE_PORT = 3306
DATABASE_NAME = "serveur_garrysmod"
DATABASE_USERNAME = "sv_gm"
DATABASE_PASSWORD = "urfJCXRfzwsat4Ap"


reportdb = "Noreportdb" --set after connect
hook.Add("DatabaseConnected", "SetGreportdb", function()
	print(reportdb)
end)
 
local function onConnected(database)
	--Log(3, "Connection to the database " .. DATABASE_NAME .. " has successfully been established")
	-- local createTable = database:query([[CREATE TABLE IF NOT EXISTS `reports` (
	  -- `id` int(11) NOT NULL AUTO_INCREMENT,
	  -- `reporter_steamid` varchar(255) NOT NULL,
	  -- `reporter_nick` varchar(255) NOT NULL,
	  -- `reporter_rpname` varchar(255) NOT NULL,
	  -- `reported_steamid` varchar(255) NOT NULL,
	  -- `reported_nick` varchar(255) NOT NULL,
	  -- `reported_rpname` varchar(255) NOT NULL,
	  -- `reason` varchar(255) NOT NULL,
	  -- `description` text NOT NULL,
	  -- `time_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	  -- `resolved_by` varchar(255) NOT NULL,
	  -- `warning_level` int(11) DEFAULT NULL,
	  -- PRIMARY KEY (`id`)
	-- ) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;]])
	
	-- function createTable:onError(...)
			-- print(...)
			-- error("Create reports failed")
	-- end
	-- function createTable:onSuccess()
			-- print("Reports Initialized")
	-- end
	-- createTable:start()
		   
	hook.Call("DatabaseConnected");
end
 
local function onConnectionFailed(database, err)
	--Log(1, "Couldn't connect to the database: " .. err)
end

local meta = FindMetaTable("Player")
function meta:isReportsAdmin()
	if ASS_NewLogLevel then
		return self:IsTempAdmin()
	end
	
	if ULib then
		return ULib.ucl.query(self, "reportadminmenu")
	end
end
 
function ConnectToReportDatabase()
		--Log(3, "Attempting to connect to " .. DATABASE_HOST .. ":" .. DATABASE_PORT .. " database: " .. DATABASE_NAME)
		local databaseObject = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT)
		databaseObject.onConnected = onConnected
		databaseObject.onConnectionFailed = onConnectionFailed
		databaseObject:connect()
		reportdb = databaseObject
		function antiTimeout()
				databaseObject:query("SET wait_timeout = 2147483"):start()
		end
		hook.Add("DatabaseConnected", "antiTimeout", antiTimeout)
end
hook.Add("Initialize", "Initreportdb", function() ConnectToReportDatabase() end)
hook.Add("OnReloaded", "InitreportdbReload", function() ConnectToReportDatabase() print("rld") end)
 
--Reconnect to the reportdb after timeout or connection issues
local function reconnect()
		--check every 10 minutes
		timer.Create("DatabaseUpkeep", 60*10, 0, function()
				if reportdb:status() != mysqloo.DATABASE_CONNECTED and reportdb:status() != mysqloo.DATABASE_CONNECTING then
						--Log(3, "Database connection was interrupted, reconnecting")
						--reportdb.onConnected = function() Log(3, "Connection to the database " .. DATABASE_NAME .. " has successfully been restablished") end
						reportdb:connect()
				end
		end)
end
hook.Add("DatabaseConnected", "ReconnecterReportDB", reconnect)
 
local function databaseErrorLog(q, err, sql)
	--Log(1, "[ReportSystem]Database Error(" .. err .. "), SQL: " .. sql .. ", reportdb:statatus() = " .. reportdb:status())
end

function notifyReportsChanged()
	local admins = {}
	for k, v in pairs(player.GetAll()) do
		if v:isReportsAdmin() then
			table.insert(admins, v)
		end
	end
	--local query = reportdb:query("SELECT * FROM reports ORDER BY time_created DESC LIMIT 20")
	local query = reportdb:query("SELECT * FROM reports ORDER BY time_created DESC LIMIT 50")
	function query:onSuccess(data)
		net.Start("TransferAllReports")
			net.WriteTable(data)
		net.Send(admins)
	end
	query:start()
end

net.Receive("TransferReport", function(len, ply)
	local reportedPlayerSteam = net.ReadString()
	local reason = net.ReadString()
	local description = net.ReadString()
   
	local reportedPlayer
	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == reportedPlayerSteam then
			reportedPlayer = v
		end
	end
   
	local reportedPlayerNick = "UNKNOWN"
	local reportedPlayerRpName = "UNKNOWN"
	if IsValid(reportedPlayer) then
		reportedPlayerNick = reportedPlayer.SteamName and reportedPlayer:SteamName() or reportedPlayer:Nick()
		reportedPlayerRpName = (reportedPlayer.DarkRPVars and  reportedPlayer.DarkRPVars["rpname"]) or "UNKNOWN"
	end
   
	local insert = reportdb:query(string.format("INSERT INTO reports(reporter_steamid, reporter_nick, reporter_rpname, reported_steamid, reported_nick, reported_rpname, reason, description) VALUES('%s','%s','%s','%s','%s','%s','%s','%s')",
		reportdb:escape(ply:SteamID()),
		reportdb:escape(ply.SteamName and ply:SteamName() or ply:Nick()),
		reportdb:escape((ply.DarkRPVars and ply.DarkRPVars["rpname"]) or "UNKNOWN"),
		reportdb:escape(reportedPlayerSteam),
		reportdb:escape(reportedPlayerNick),
		reportdb:escape(reportedPlayerRpName),
		reportdb:escape(reason),
		reportdb:escape(description)
	))
	insert.onError = databaseErrorLog
	insert:start()
   
	--Log(3, string.format("[ReportSystem]Player %s(%s) reported %s(%s)", ply:Nick(), ply:SteamID(), reportedPlayerNick, reportedPlayerSteam))
	if ulx and ulx.fancyLogAdmin then
		ulx.fancyLogAdmin(ply, "#A reported #T", {reportedPlayer})
	end
	if ASS_LogAction then
		ASS_LogAction(ply, ASS_ACL_REPORT, "reported " .. ASS_FullNick(reportedPlayer))
	end
end)
 
function resolveReport(ply, cmd, args)
	if not ply:isReportsAdmin() then return end
	local reportdbId = tonumber(args[1])
	--if not reportdbId then return end
	local query = reportdb:query("UPDATE reports SET resolved_by='" .. ply:Nick() .. "' WHERE id=" .. reportdbId)
	function query:onSuccess()
		--Log(3, "[ReportSystem]Admin " .. ply:Nick() .. " marked report " .. reportdbId .. " as resolved")
		notifyReportsChanged()
	end
	query.onError = databaseErrorLog;
	query:start()
end
concommand.Add("reportresolve", resolveReport)
 
net.Receive("ReportWarning", function(len, ply)
	if not ply:isReportsAdmin() then return end
	local reportdbId = net.ReadUInt(32)
	local warningLevel = net.ReadUInt(32)
	
	local query = reportdb:query(string.format("UPDATE reports SET warning_level=%i, resolved_by='%s' WHERE id = %i",
		warningLevel,
		ply:Nick(),
		reportdbId)
	)
	query.onError = databaseErrorLog
	function query:onSuccess()
		--Log(3, "[ReportSystem]Admin " .. ply:Nick() .. " set warning level of report " .. reportdbId .. " to " .. warningLevel)
		notifyReportsChanged()
		resendWarningLevels()
	end
	query:start()
end)
 
function removeReport(ply, cmd, args)
	if not ply:isReportsAdmin() then return end
	local reportdbId = tonumber(args[1])
	local query = reportdb:query("DELETE FROM reports WHERE id=" .. reportdbId)
	query.onError = databaseErrorLog;
	function query:onSuccess()
		--Log(3, "[ReportSystem]Admin " .. ply:Nick() .. " removed report with id " .. reportdbId )
		notifyReportsChanged()
		resendWarningLevels()
	end
	query:start()
end
concommand.Add("reportremove", removeReport)
 
function sendReportsToClient(ply)
	if not ply:isReportsAdmin() then return end
	
	--local query = reportdb:query("SELECT * FROM reports ORDER BY time_created DESC LIMIT 20")
	local query = reportdb:query("SELECT * FROM reports ORDER BY time_created DESC LIMIT 50")
	function query:onSuccess(data)
		net.Start("TransferAllReports")
				net.WriteTable(data)
		net.Send(ply)
	end
	query:start()
end

function resendWarningLevels(ply)
	local warningLevels = { }
	local query = reportdb:query("SELECT COUNT(*) AS reported_count, SUM(warning_level) AS warning_level, reported_steamid FROM reports WHERE warning_level != 0 GROUP BY reported_steamid")
	function query:onSuccess(data)
		local lookup = {}
		local send = {}
		for k, v in pairs(data) do
			lookup[v.reported_steamid] = v
			send[v.reported_steamid] = v
		end
		
		local admins = { }
		for k, v in pairs(player.GetAll()) do
			if lookup["NULL\n"] then
				send["NULL"] = lookup["NULL\n"]
			end
			if lookup[v:SteamID()] then
				send[v:SteamID()] = lookup[v:SteamID()]
			end
			if v:isReportsAdmin() then
				table.insert(admins, v)
			end
		end
		
		net.Start("TransferWarningLevel")
			net.WriteTable(send)
		if ply then
			net.Send(ply)
		else 
			net.Send(admins)
		end
	end
	query:start()
end

hook.Add("PlayerInitialSpawn", "PlayerSpawnSendReports", function(ply)
	resendWarningLevels()
end)

util.AddNetworkString("OpenReportMenu")
function openReportMenu(ply)
	net.Start("OpenReportMenu")
	net.Send(ply)
end

util.AddNetworkString("OpenReportAdminMenu")
function openReportAdminMenu(ply)
	sendReportsToClient(ply)
	net.Start("OpenReportAdminMenu")
	net.Send(ply)
end

function ReportMenuChat(plr, command, team)
	if command == "!report" or command == "/report" then
		openReportMenu(plr)
		return ""
	elseif command == "!reportadmin" or command == "/reportadmin" then
		if plr:IsAdmin() then
			openReportAdminMenu(plr)
			return ""
		end
	end
end
hook.Add("PlayerSay", "ReportMenuChat", ReportMenuChat)