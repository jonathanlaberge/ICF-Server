// A script to allow players to unstuck themselves.
// some code from Rejax; mostly rewritten by Rei

if SERVER then 
	util.AddNetworkString( "StuckMessage" )
end

if CLIENT then

	local m = {}
		m[1] = "You are stuck, trying to free you..."
		m[2] = ""
		m[3] = "You should be unstuck!"
		m[4] = "You must be alive and out of vehicles to use this command!"
		m[5] = ""
		m[6] = "Cooldown period still active! Wait a bit!"
		m[7] = { "Player '", "' used the UnStuck command!" }
		m[8] = "Sorry, i failed"    -- (unreachable code :D)
		m[9] = "You are arrested!"
		
	net.Receive( "StuckMessage", function()
	
		local fl = net.ReadInt( 8 )
		local ply = net.ReadEntity()

		if not ply:IsPlayer() then
			chat.AddText( Color( 200, 100, 100 ), "[UNSTUCK] ", Color( 255, 255, 255 ), m[fl] )
		else
			chat.AddText( Color( 255, 100, 100 ), "[UNSTUCK ADMIN] ", Color( 255, 255, 255 ), m[fl][1], ply:Nick(), m[fl][2] )
		end
		
	end)

end

if SERVER then

	UNSTUCK_COMMAND_COOLDOWN = 600

	local function SendMessage( ply, num, pent )
		net.Start( "StuckMessage" )
			net.WriteInt( num, 8 )
			if pent then
				net.WriteEntity( pent )
			end
		net.Send( ply )
	end

		
	
	function CollisionBoxOutsideMap( pPos, minBound, maxBound )
		if not util.IsInWorld( Vector( pPos.x+minBound.x, pPos.y+minBound.y, pPos.z+minBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x-minBound.x, pPos.y+minBound.y, pPos.z+minBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x-minBound.x, pPos.y-minBound.y, pPos.z+minBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x+minBound.x, pPos.y-minBound.y, pPos.z+minBound.z ) ) then return true end
		
		if not util.IsInWorld( Vector( pPos.x+maxBound.x, pPos.y+maxBound.y, pPos.z+maxBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x-maxBound.x, pPos.y+maxBound.y, pPos.z+maxBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x-maxBound.x, pPos.y-maxBound.y, pPos.z+maxBound.z ) ) then return true end
		if not util.IsInWorld( Vector( pPos.x+maxBound.x, pPos.y-maxBound.y, pPos.z+maxBound.z ) ) then return true end
		
		for i=0.2, 0.8, 0.2 do
			if not util.IsInWorld( Vector( pPos.x, pPos.y, pPos.z+(maxBound.z+minBound.z)*i ) ) then return true end
		end
		return false
	end
	
	
	function CollisionBoxContainsProps( pPos, minBound, maxBound )
		lowerBoxPos = Vector()
		lowerBoxPos:Set(pPos)
		lowerBoxPos:Add(minBound)
		upperBoxPos = Vector()
		upperBoxPos:Set(pPos)
		upperBoxPos:Add(maxBound)
		
		t = ents.FindInBox(lowerBoxPos, upperBoxPos)
		for key,value in pairs(t) do
			colliding = value:GetSolid()==SOLID_VPHYSICS
			-- print(value:GetSolid(), colliding, value)
			if colliding then return true end
		end
		return false
	end
	
	
	local function FindNewPos( ply , try )
		local minBound, maxBound = ply:GetCollisionBounds()
		local oldZVelo = ply:GetVelocity().z
		ply:SetVelocity( Vector( 0, 0, 250 ) )
		
		timer.Simple( 0.1, function()
			local absZdelta = math.abs(  (ply:GetVelocity().z-oldZVelo) );
			if absZdelta>30 then
				SendMessage( ply, 3 )
				return
			end
			
			-- PLAYER IS STUCK...
			local pos = ply:GetPos()
			if try>0 then
				pos:Add(Vector(0,0,30))     -- ...diving up undetectable displacement-maps
				ply:SetPos(pos)
			else
				SendMessage( ply, 1 )
			end
			local testPos
			for i=15, 10550.0, 0.1 do
				testPos = Vector( math.random(-i, i)+pos.x, math.random(-i, i)+pos.y, math.random(-i, i)+pos.z)
				if not CollisionBoxOutsideMap( testPos, minBound, maxBound ) then
					if not CollisionBoxContainsProps( testPos, minBound, maxBound ) then
						ply:SetPos(testPos)
						if try<5 then
							try = try + 1						
							FindNewPos( ply , try )
						end
						return
					end
				end
			end
			SendMessage( ply, 8 )
		end )
	end

	local function UnStuck( ply )
		if ply:GetMoveType() == MOVETYPE_OBSERVER or ply:InVehicle() or not ply:Alive() then
			SendMessage(ply, 4 )
			return
		end
		
		FindNewPos( ply , 0 )
	
		for k,v in pairs( player.GetAll() ) do
			if v:IsAdmin() or v:IsSuperAdmin() or v:IsUserGroup( "mod" ) then
				SendMessage( v, 7, ply )
			end
		end
	end

	hook.Add("PlayerSay", "playersaystuck", function(ply, text)

		if ( text == "!unstuck" or text == "!stuck" or text == "/stuck" or text == "/unstuck" ) then
			
			local arrested = false
			if DarkRP then
				local version = tonumber( GAMEMODE.Version:sub(3,3) )
				if version >= 5 then
					arrested = ply:isArrested()
				else
					arrested = ply:IsArrested()
				end
			end
			
			if arrested then
				SendMessage( ply, 9 )
				return ""
			end
			
			if ply.UnStuckCooldown == nil then
				ply.UnStuckCooldown = CurTime() - 1
			end
			
			if (ply.UnStuckCooldown < CurTime()) then
		
				if ply:Alive() then 
					ply.UnStuckCooldown = CurTime() + UNSTUCK_COMMAND_COOLDOWN
					-- SendMessage( ply, 5 )
					UnStuck( ply )
				else
					SendMessage( ply, 4 )
				end
			
			else
				SendMessage( ply, 6 )
			end
			
		return ""
		end
	end)
 
end