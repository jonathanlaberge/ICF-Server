Jonathan1358.MapVote.ENABLED = Jonathan1358.MapVote.ENABLED or false


Jonathan1358.MapVote.Config = Jonathan1358.MapVote.Config or
{
	MapLimit = 24,
	TimeLimit = 30,
	AllowCurrentMap = true,
	EnableCooldown = true,
	MapsBeforeRevote = 8,
	RTVPlayerCount = 1,
	MapPrefixes = {"gm_"}
}



Jonathan1358.MapVote.CurrentMaps = {}
Jonathan1358.MapVote.Votes = {}
Jonathan1358.MapVote.Allow = false
Jonathan1358.MapVote.UPDATE_VOTE = 1
Jonathan1358.MapVote.UPDATE_WIN = 3
function Jonathan1358.MapVote.HasExtraVotePower(ply)
	if ply:IsAdmin() then
		return true
	end 
	return false
end
