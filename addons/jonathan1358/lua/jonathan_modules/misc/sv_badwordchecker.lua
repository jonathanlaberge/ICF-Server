function Jonathan1358.Misc.BadWordChecker(plr, text)
	Jonathan1358.Misc.BadWordCheckerBannedWords = 
	{
		"nigger",
		"nigga",
		"nigg3r",
		"niggar",
		"niglet",
		"niger",
		"n1gger",
		"n1gg3r",
		"nlgger",
		"nlgg3r",
		"n!gger",
		"n!gg3r",
		"niqqer",
		"niqqa",
		"whitepower",
		"whitpower",
		"white power",
		"fag",
		"fagget",
		"fgt",
		"faggot",
		"whore",
		"pussy",
		"cunt",
		"Allah",
		"Allahu",
		"Akbar",
		"Allah Akbar",
		"Allahu Akbar",
	};
	for k, v in pairs(Jonathan1358.Misc.BadWordCheckerBannedWords) do
		if string.find(string.lower(text), string.lower(v)) then
			plr:PrintMessage(HUD_PRINTTALK, "[I.C.F.] Please watch your language as to avoid aggrivating other players.")
			return ""
		end
	end
end
hook.Add("PlayerSay", "Jonathan1358.Misc.BadWordChecker", Jonathan1358.Misc.BadWordChecker);