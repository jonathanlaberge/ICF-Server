--This will fix the swimming bug and any additional stuff

function GM:HandlePlayerSwimming(ply)
	return false
end

if CLIENT then
	hook.Add("CalcMainActivity","HAS_Anim_Swimming",function(ply,vel)
		local wtrc = util.TraceLine({	--because no client ply:WaterLevel()
			start = ply:EyePos(),
			endpos = ply:GetPos(),
			filter = ents.GetAll(),
			mask = MASK_WATER
		})
		local ftrc = util.TraceHull({	--because no client ply:IsOnGround()
			start = ply:GetPos()+Vector(0,0,1),
			endpos = ply:GetPos()+Vector(0,0,-1),
			filter = player.GetAll(),
			mins = Vector(-16,-16,-0.25),
			maxs = Vector(16,16,0.25)
		})
		
		if (not ftrc.Hit) and (wtrc.Fraction ~= 1) then
			local spd = (vel:Length() >= 125) and 1 or 2
			spd = (vel:Length() >= 280) and 0.75 or spd
			
			local time = RealTime()/spd
			if time < 1 then
				time = -time
			end
			
			ply:SetCycle(time)
			return 0,ply:LookupSequence("swimming_all")
		end
		
		if ply:Team() == 2 then
			if SeekerBlinded and RoundActive then
				if ply:LookupBone("ValveBiped.Bip01_R_Foot") != nil then
					local mv = ((math.sin(CurTime()*10)*10)-6)
					ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Foot"),Angle(0,mv,0))
				end
				return 0,ply:LookupSequence("pose_standing_02")
			end
		end
	end)
end