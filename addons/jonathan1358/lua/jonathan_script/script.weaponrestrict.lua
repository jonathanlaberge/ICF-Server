-- ======================================================================================
-- 				WEAPON RESTRICTION SCRIPT BY STEVEUK
--  You are free to make modifications and redistributions of this script as long as I'm credited for it
-- ======================================================================================

if( CLIENT ) then return end -- not clientside :downs:

-- cvars for controlling this
local wr_enabled = CreateConVar( "wr_enabled", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE } ) -- enabled or not
local wr_sandboxonly = CreateConVar( "wr_sandboxonly", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE } ) -- only enabled on sandbox
local wr_mode = CreateConVar( "wr_mode", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE } ) -- 0 = use whitelist, 1 = use blacklist
local wr_disablepickup = CreateConVar( "wr_disablepickup", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } ) -- whether weapons can be picked up or not
local wr_weapons = CreateConVar( "wr_weapons", "weapon_physgun;weapon_physcannon;gmod_tool;gmod_camera", { FCVAR_REPLICATED, FCVAR_ARCHIVE } ) -- allowed/disallowed weapons
local wr_ignoreusergroups = CreateConVar( "wr_ignoregroups", "superadmin;admin", { FCVAR_REPLICATED, FCVAR_ARCHIVE } ) -- user groups not affected by the script

-- some enums for the script
WR_MODE_WHITELIST 	= 0
WR_MODE_BLACKLIST	= 1

-- check if the user is in a whitelisted user group
function WRPlayerWhitelisted( pl )

	local tUserGroupTable = string.Explode( ";", wr_ignoreusergroups:GetString() ) -- split whitelist into table (seperated by ;)
	
	for k, v in pairs( tUserGroupTable ) do -- loop through easy user group
		if( pl:IsUserGroup( v ) == true ) then -- the user belongs to  a white listed usergroup
			return true -- allow
		end
	end
	
	return false -- we didn't find anything
	
end

-- helper function to get weapons list
function WRWeaponsList( )
	return string.Explode( ";", wr_weapons:GetString() ) -- return table from cvar where weapons are split by ;
end

-- friendlier looking function to see if wr is enabled
function WRIsEnabled( )

	if( gmod.GetGamemode().Name != "Sandbox" and wr_sandboxonly:GetBool() == true ) then -- sandbox only mode, but it's not sandbox!
		return false -- report as disabled
	end
	
	return wr_enabled:GetBool() -- return the cvar value if the gamemode and stuff is fine
end

-- friendly way of getting the wr operation mode
function WRGetMode()
	
	local iWRMode = wr_mode:GetInt( ) -- get cvar
	
	if( iWRMode == 0 or iWRMode == 1 ) then -- check it has a valid value
		return iWRMode -- return valid value
	else
		return WR_MODE_WHITELIST -- default to whitelist with invalid values
	end
	
end

-- friendly way of getting is a user can pickup weapons from the floor
function WRWeaponPickupDisabled()
	return wr_disablepickup:GetBool() -- get cvar value
end

-- function for checking weapons
function WRCheckWeapon( pl, weap )
	
	local tWeaponsList = WRWeaponsList() -- list of weapons
	
	if( WRGetMode() == WR_MODE_WHITELIST ) then -- white list behaviour
		if( table.HasValue( tWeaponsList, weap:GetClass() ) ) then -- weapon is in weapons list
			return true -- allow pickup
		else
			return false -- don't
		end
	elseif( WRGetMode() == WR_MODE_BLACKLIST ) then -- blacklist behaviour
		if( table.HasValue( tWeaponsList, weap:GetClass() ) ) then -- weapon is in weapons list, but this time it's a blacklist
			return false -- so return false instead
		else
			return true -- do!
		end		
	end
	
end

-- function to check if a weapon is indeed a swep
function WRIsSWEP( weap )
	
	local CheckSWEP = weapons.GetStored( weap:GetClass() ) -- try and find swep in swep register
 	
	if( CheckSWEP == nil ) then
		return false -- not a swep!
	end
	
	return true -- we're ok it's a swep
end

-- when the player spawns
function WRPlayerInitialSpawn( pl )

	if( WRIsEnabled() == true ) then -- WR is enabled
		
		local addphrase -- phrase to add on the end to the welcome message
		
		if( WRGetMode() == WR_MODE_WHITELIST ) then -- whitelist
			addphrase = "Only specific weapons are allowed."
		else -- black list
			addphrase = "Some weapons are not allowed to be used."
		end
		
		pl:SendLua( "GAMEMODE:AddNotify('This server has weapon restriction in effect. " .. addphrase .. "', NOTIFY_HINT, 10 )" ) -- show our welcome message
	end
	
end

-- just stores the time they spawned so it removes the weapons instead of dropping it
function WRPlayerSpawn( pl )
	pl.LastSpawnedAt = CurTime() -- store the last spawn time
	pl.LastWarn = CurTime()
end

-- when a player wants to pickup a weapon
function WRPlayerCanPickupWeapon( pl, weap )
	
	if( WRIsEnabled() == true and WRPlayerWhitelisted( pl ) == false ) then -- wr enabled and player not whitelisted?
		local bCheckWeapon = WRCheckWeapon( pl, weap ) -- check the weapon in the list
		
		if( bCheckWeapon == false and ( pl.LastSpawnedAt + 0.4 ) >= CurTime() ) then -- we recently spawned so remove weapons
			weap:Remove() -- remove weapon
			return false -- no further shit
		else
			if( WRWeaponPickupDisabled() == true ) then -- check for pickup settings
				
				if( bCheckWeapon == false and WRIsSWEP( weap ) == true ) then -- crappy swep detection
					weap:Remove() -- remove illegal swep
					pl:SendLua( "GAMEMODE:AddNotify('This SWEP has been disabled.', NOTIFY_ERROR, 10 )" )
				elseif( bCheckWeapon == false ) then
					if( pl.LastWarn + 5 <= CurTime() ) then
						pl:SendLua( "GAMEMODE:AddNotify('You cannot pickup this weapon.', NOTIFY_ERROR, 10 )" )
						pl.LastWarn = CurTime()
					end
				end
				
				return bCheckWeapon -- just return val
			end
		end
	end
	
end

-- hooks important for the script
hook.Add( "PlayerInitialSpawn", "WRInitarlPlayarSpoon", WRPlayerInitialSpawn ) -- called when they initially spawn, welcome message
hook.Add( "PlayerSpawn", "WRPlayarSpoon", WRPlayerSpawn ) -- called when a player spawns
hook.Add( "PlayerCanPickupWeapon", "WRCunPickapShoopen", WRPlayerCanPickupWeapon ) -- decides if a player can pickup a weapon