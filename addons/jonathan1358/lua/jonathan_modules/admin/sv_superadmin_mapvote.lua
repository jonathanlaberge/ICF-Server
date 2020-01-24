concommand.Add("Jonathan1358AdminMapvote+", function(plr)
	if plr:IsSuperAdmin() then
		Jonathan1358.MapVote.Start(nil, nil, nil, nil)
	end
end)
concommand.Add("Jonathan1358AdminMapvote-", function(plr)
	if plr:IsSuperAdmin() then
		Jonathan1358.MapVote.Cancel()
	end
end)
concommand.Add("Jonathan1358AdminMapvoteStart", function(plr)
	if plr:IsSuperAdmin() then
		Jonathan1358.MapVote.Start(nil, nil, nil, nil)
	end
end)
concommand.Add("Jonathan1358AdminMapvoteCancel", function(plr)
	if plr:IsSuperAdmin() then
		Jonathan1358.MapVote.Cancel()
	end
end)