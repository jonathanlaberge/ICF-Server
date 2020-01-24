local Tags = 
{
	--Group    --Tag     --Color
	{ "vip", "VIP", Color(255, 0, 150, 255) },
	{ "trialmoderator", "TMod", Color(0, 155, 0, 255) },
	{ "moderator", "Mod", Color(0, 255, 0, 255) },
	{ "vipmoderator", "VIP Mod", Color(50, 255, 170, 255) },
	{ "vipadmin", "VIP Admin", Color(50, 205, 255, 255) },
	{ "admin", "Admin", Color(0, 0, 255, 255) },
	{ "headadmin", "HeadAdmin", Color(0, 0, 255, 255) },
	{ "superadmin", "Owner", Color(255, 255, 0, 255) }
}

hook.Add("OnPlayerChat", "Jonathan1358.Misc.Prefix", function(plr, Text, TeamOnly)
	if IsValid(plr) and plr:IsPlayer() then
		local Exclude = 
		{
			'STEAM_0:1:74945827',
			--'STEAM_0:1:48888328',
		}
		if table.HasValue(Exclude, plr:SteamID()) then
			return true
		end
		for k,v in pairs(Tags) do
			if plr:IsUserGroup(v[1]) then
				local R = 46
				local G = 204
				local B = 250
				local A = 255
				local NickTeam = team.GetColor(plr:Team())
				if !TeamOnly then
					chat.AddText(Color(255, 255, 255, 255), "[", v[3], v[2], Color(255, 255, 255, 255), "] ", NickTeam, plr:Nick(), Color(255, 255, 255, 255), ": ", Color(R, G, B, A), Text)
					return true
				else
					chat.AddText(Color(255, 255, 255, 255), "[", v[3], v[2], Color(255, 255, 255, 255), "] ", NickTeam, "(TEAM) ", plr:Nick(), Color(255, 255, 255, 255), ": ", Color(R, G, B, A), Text)
					return true
				end
			end
		end
	end
	if !IsValid(plr) and !plr:IsPlayer() then
		local ConsoleColor = Color(0, 255, 0) --Change this to change Console name color
		chat.AddText(ConsoleColor, "Console", Color(255, 255, 255, 255), ": ", Text)
		return true
	end
end)