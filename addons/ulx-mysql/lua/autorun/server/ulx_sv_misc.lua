
function syncBans( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "bans")
end

function syncUsers( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "users")
end

function syncGroups( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "groups")
end