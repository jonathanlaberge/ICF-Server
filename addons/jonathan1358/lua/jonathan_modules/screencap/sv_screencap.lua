--util.AddNetworkString("Jonathan1358.ScreenCap")
util.AddNetworkString("Jonathan1358.ScreenCap.ToServer")

if not file.Exists("jonathan1358_screencap", "DATA") then file.CreateDir("jonathan1358_screencap") end
if not file.Exists("jonathan1358_screencap/mode1_report", "DATA") then file.CreateDir("jonathan1358_screencap/mode1_report") end
if not file.Exists("jonathan1358_screencap/mode2_random", "DATA") then file.CreateDir("jonathan1358_screencap/mode2_random") end
if not file.Exists("jonathan1358_screencap/mode3_ban", "DATA") then file.CreateDir("jonathan1358_screencap/mode3_ban") end
if not file.Exists("jonathan1358_screencap/temp", "DATA") then file.CreateDir("jonathan1358_screencap/temp") end

net.Receive("Jonathan1358.ScreenCap.ToServer", function(len, plr)
	local Chunck = net.ReadInt(4)
	local TotalChunck = net.ReadFloat()
	local Mode = net.ReadInt(4)
	local ScreenData = net.ReadData(64000) 
	
	local ModeDir = nil
	if Mode == 1 then ModeDir = "mode1_report"
	elseif Mode == 2 then ModeDir = "mode2_random"
	elseif Mode == 3 then ModeDir = "mode3_ban"
	else ModeDir = "mode2_random" end
	if Chunck == 1 then
		local Image = file.Open("jonathan1358_screencap/temp/" .. plr:Name() .. "(" .. string.Replace(plr:SteamID(), ':', '_') .. ").txt", "wb", "DATA")
		Image:Write(ScreenData)
		Image:Close()
	else
		local Image = file.Open("jonathan1358_screencap/temp/" .. plr:Name() .. "(" .. string.Replace(plr:SteamID(), ':', '_') .. ").txt", "ab", "DATA")
		Image:Write(ScreenData)
		Image:Close()
	end
	if Chunck >= TotalChunck then
		local ImageFinal = file.Open("jonathan1358_screencap/" .. ModeDir .. "/[" .. os.date("%Y-%m-%d %H;%M;%S", os.time()) .. "] " .. string.gsub(plr:Name(), "[^a-zA-Z%d%s:]", "") .. " (" .. string.Replace(plr:SteamID(), ':', '_') .. ").txt", "wb", "DATA")
		ImageFinal:Write(file.Read("jonathan1358_screencap/temp/" .. plr:Name() .. "(" .. string.Replace(plr:SteamID(), ':', '_') .. ").txt"))
		ImageFinal:Close()
		PlayerTempRemove = plr -- This fix a problem with ban system because of the player leaving the server in 3 second after screenshot.
		timer.Simple(1, function() file.Delete("jonathan1358_screencap/temp/" .. PlayerTempRemove:Name() .. "(" .. string.Replace(PlayerTempRemove:SteamID(), ':', '_') .. ").txt") end)
	end
end)

-- hook.Add("PlayerInitialSpawn", "Jonathan1358.ScreenCap.RandomScreenshot", function(plr)
	-- timer.Remove("Jonathan1358ScreenCapRandomScreenshotForPlayer" .. string.Replace(plr:SteamID(), ':', '_'))
	----timer.Create("Jonathan1358ScreenCapRandomScreenshotForPlayer" .. string.Replace(plr:SteamID(), ':', '_') ,math.random(600, 700) ,0 ,function()
	-- timer.Create("Jonathan1358ScreenCapRandomScreenshotForPlayer" .. string.Replace(plr:SteamID(), ':', '_') ,5 ,0 ,function()
		-- umsg.Start("Jonathan1358.ScreenCap", plr)
			-- umsg.Short(3)
		-- umsg.End()
	-- end)
-- end)
-- hook.Add("PlayerDisconnected", "Jonathan1358.ScreenCap.RandomScreenshot", function(plr)
	-- timer.Remove("Jonathan1358ScreenCapRandomScreenshotForPlayer" .. string.Replace(plr:SteamID(), ':', '_'))
-- end)