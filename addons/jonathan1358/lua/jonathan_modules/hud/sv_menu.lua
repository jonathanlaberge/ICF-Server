Jonathan1358.Hud.MenuOpenCommands = 
{
	"!motd;",
	"/motd;",
	"!website;",
	"/website;",
	"!rules;",
	"/rules;",
	"!help;",
	"/help;",
}

function Jonathan1358.Hud.MenuOpen(plr, page)
	umsg.Start("Jonathan1358.Hud.Menu", plr)
		umsg.String(page)
	umsg.End()
end
function Jonathan1358.Hud.MenuOpenConsole(plr)
	umsg.Start("Jonathan1358.Hud.Menu", plr)
		umsg.String("")
	umsg.End()
end
concommand.Add("motd", Jonathan1358.Hud.MenuOpenConsole)

-- Player Spawn
--function Jonathan1358.Hud.MenuOpenOnJoin(plr)
--	Jonathan1358.Hud.MenuOpen(plr, "")
--end
--hook.Add("PlayerInitialSpawn", "Jonathan1358.Hud.MenuOpenOnJoin", Jonathan1358.Hud.MenuOpenOnJoin)

-- Chat Command
function Jonathan1358.Hud.MenuOpenOnCommand(plr, command, team)
	for k,v in pairs(Jonathan1358.Hud.MenuOpenCommands) do
		if command == Jonathan1358.Split(v, ";")[1] then
			if Jonathan1358.Split(v, ";")[2] != "" then Jonathan1358.Hud.MenuOpen(plr, Jonathan1358.Split(v, ";")[2])
			else Jonathan1358.Hud.MenuOpen(plr, "") end
			if string.sub(command,1,1) == "/" then
				return ""
			end
		end
	end
end
hook.Add("PlayerSay", "Jonathan1358.Hud.MenuOpenOnCommand", Jonathan1358.Hud.MenuOpenOnCommand)