util.AddNetworkString("Jonathan1358.SprayMon.AddSpray")
util.AddNetworkString("Jonathan1358.SprayMon.ClearDecals")
util.AddNetworkString("Jonathan1358.SprayMon.Spray")

CreateConVar("spraymon_nodelay", 0, FCVAR_SERVER_CAN_EXECUTE, "no delay for 0: nobody | -1: everyone | 1: admins | 2: superadmins")
CreateConVar("spraymon_nooverspraying", 0, FCVAR_REPLICATED, "anti over spraying: 0 | 1")

hook.Add("PlayerSpray", "Jonathan1358.SprayMon", function(ply)
	local trace = util.GetPlayerTrace(ply, ply:EyeAngles():Forward())
	trace.mask = MASK_SOLID_BRUSHONLY
	trace = util.TraceLine(trace)
	net.Start("Jonathan1358.SprayMon.AddSpray")
		net.WriteEntity(ply)
		net.WriteFloat(trace.HitNormal.x)
		net.WriteFloat(trace.HitNormal.y)
		net.WriteFloat(trace.HitNormal.z)
		net.WriteFloat(trace.HitPos.x)
		net.WriteFloat(trace.HitPos.y)
		net.WriteFloat(trace.HitPos.z)
	net.Broadcast()
end)

local pcc = FindMetaTable("Player").ConCommand
FindMetaTable("Player").ConCommand = function(self, cmd, ...)
	if cmd:find("r_cleardecals", nil, true) then
		net.Start("Jonathan1358.SprayMon.ClearDecals")
		net.Send(self)
	end
	return pcc(self, cmd, ...)
end

net.Receive("Jonathan1358.SprayMon.Spray", function(_, ply)
	local convar = GetConVarNumber("spraymon_nodelay")
	if convar == -1 or convar > 0 and (convar == 1 and ply:IsAdmin() or ply:IsSuperAdmin()) or ULib and ULib.ucl.query(ply, "spraymon_nodelay") then
		ply:AllowImmediateDecalPainting()
	end
end)