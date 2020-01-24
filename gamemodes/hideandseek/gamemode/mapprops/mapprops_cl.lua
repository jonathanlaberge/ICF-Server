if game.GetMap() != "gm_construct" then return end		--we don't need this if the map isn't gm_construct

hook.Add("Tick","has_customlights",function()
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if v:GetMaterial() == "models/effects/comball_glow2" and v.Light == nil then
			v.Light = true
		end
		
		if v.Light == true then
			local mde = 420*(v:GetSkin()+1)
			local dl = DynamicLight(v:EntIndex())
			if (dl) then
				dl.Pos = v:GetPos()
				dl.r = 255
				dl.g = 255
				dl.b = 255
				dl.Brightness = 1
				dl.Size = mde
				dl.Decay = mde*2
				dl.DieTime = CurTime()+1
				dl.Style = 0
			end
		end
	end
end)