local CMD = 'hook.Add("HUDPaint", "Jonathan1358.Admin.ESP", function () cam.Start3D() for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 10000)) do if v:IsPlayer() and v != LocalPlayer() and v:Alive() then render.SetColorModulation(team.GetColor(v:Team()).r/255, team.GetColor(v:Team()).g/255, team.GetColor(v:Team()).b/255) render.MaterialOverride(Material("models/debug/debugwhite")) render.SetBlend(1) v:DrawModel() end end cam.End3D() end)'

-- hook.Add("HUDPaint", "Jonathan1358.Admin.ESP", function ()
	-- cam.Start3D() 
		-- for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 10000)) do 
			-- if v:IsPlayer() and v != LocalPlayer() and v:Alive() then
				-- render.SetColorModulation(team.GetColor(v:Team()).r/255, team.GetColor(v:Team()).g/255, team.GetColor(v:Team()).b/255) 
				-- render.MaterialOverride(Material("models/debug/debugwhite")) 
				-- render.SetBlend(1) 
				-- v:DrawModel()
			-- end 
		-- end 
	-- cam.End3D()
-- end)

concommand.Add("Jonathan1358AdminESP+", function(plr)
	if plr:IsSuperAdmin() then
		net.Start("Jonathan1358.Admin.RunLua")
			net.WriteString(CMD)
		net.Send(plr)
	end
end)
concommand.Add("Jonathan1358AdminESP-", function(plr)
	if plr:IsSuperAdmin() then
		net.Start("Jonathan1358.Admin.RunLua")
			net.WriteString('hook.Remove("HUDPaint", "Jonathan1358.Admin.ESP")')
		net.Send(plr)
	end
end)