if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Hands"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "TW1STaL1CKY"
SWEP.Instructions = "You should not be able to see within the gamemode :V"
SWEP.Contact = ""
SWEP.Purpose = "Tagging weapon for HideAndSeek gamemode."
SWEP.IconLetter = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
if CLIENT then SWEP.FrameVisible = false end

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
		self.Owner:DrawWorldModel(false)
		self.TauntDelay = 0
	end
end

function SWEP:CalculateTagRange()
	if CLIENT then return end
	local should = tobool(GetConVarString("has_dyntagging")) or false
	
	if should then
		local range = 34+(self.Owner:Ping()/24)
		local zup = (self.Owner:Crouching()) and 64 or 76
		local zdn = (self.Owner:GetGroundEntity() == NULL) and -9 or -3
		
		local phgt = (self.Owner:Crouching()) and 32 or 52
		local trchgt = (self.Owner:Crouching()) and 2.75 or 12
		
		local srt = self.Owner:GetPos()+Vector(0,0,phgt)
		local trc1 = util.TraceHull({
			start = srt,
			endpos = srt+Vector(range,0,0),
			filter = player.GetAll(),
			mins = Vector(-0.5,-6,-12),
			maxs = Vector(0.5,6,trchgt)
		})
		local trc2 = util.TraceHull({
			start = srt,
			endpos = srt+Vector(-range,0,0),
			filter = player.GetAll(),
			mins = Vector(-0.5,-6,-12),
			maxs = Vector(0.5,6,trchgt)
		})
		local trc3 = util.TraceHull({
			start = srt,
			endpos = srt+Vector(0,range,0),
			filter = player.GetAll(),
			mins = Vector(-6,-0.5,-12),
			maxs = Vector(6,0.5,trchgt)
		})
		local trc4 = util.TraceHull({
			start = srt,
			endpos = srt+Vector(0,-range,0),
			filter = player.GetAll(),
			mins = Vector(-6,-0.5,-12),
			maxs = Vector(6,0.5,trchgt)
		})
		local trc5 = util.TraceHull({
			start = srt,
			endpos = srt+Vector(0,0,zup-phgt),
			filter = player.GetAll(),
			mins = Vector(-8,-8,-0.5),
			maxs = Vector(8,8,0.5)
		})
		
		local pos = self.Owner:GetPos()
		for k,v in pairs(ents.FindInBox(pos+Vector(math.max(trc1.Fraction*range,16.25),math.max(trc3.Fraction*range,16.25),zdn),pos+Vector(math.min(-(trc2.Fraction*range),-16.25),math.min(-(trc4.Fraction*range),-16.25),phgt+(trc5.Fraction*(zup-phgt))))) do
			if v:IsValid() and v:IsPlayer() and v:Team() == 1 then
				local v_phgt = (v:Crouching()) and 32 or 52
				local trcchk = util.TraceLine({
					start = srt,
					endpos = v:GetPos()+Vector(0,0,v_phgt),
					filter = player.GetAll()
				})
				if trcchk.Fraction == 1 then
					v:ViewPunch(Angle(8,math.random(-16,16),0))
					self.Owner:ViewPunch(Angle(-1,0,0))
					v:Caught(self.Owner)
					if RoundCount > 0 then self.Owner:AddFrags(1) end
					hook.Call("HASPlayerCaughtArea",GAMEMODE,self.Owner,v)
				end
			end
		end
	else
		local range = 34+(self.Owner:Ping()/24)
		local zup = (self.Owner:Crouching()) and 64 or 76
		local zdn = (self.Owner:GetGroundEntity() == NULL) and -9 or -3
		for k,v in pairs(ents.FindInBox(self.Owner:GetPos()+Vector(range,range,zdn),self.Owner:GetPos()+Vector(-range,-range,zup))) do
			if v:IsValid() and v:IsPlayer() and v:Team() == 1 then
				v:ViewPunch(Angle(8,math.random(-16,16),0))
				self.Owner:ViewPunch(Angle(-1,0,0))
				v:Caught(self.Owner)
				if RoundCount > 0 then self.Owner:AddFrags(1) end
				hook.Call("HASPlayerCaughtArea",GAMEMODE,self.Owner,v)
			end
		end
	end
end

function SWEP:Think()
	if CLIENT then return end
	if self.Owner:Team() != 2 then return end
	if SeekerBlinded or (not RoundActive) then return end
	self:CalculateTagRange()
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime()+0.25)
	self.Weapon:SetNextSecondaryFire(CurTime()+0.25)
	if self.Owner:Team() == 2 and SeekerBlinded then return end
	local ent = self.Owner:GetEyeTrace()
	if CLIENT then return end
	local entply = ent.Entity
	local entdis = self.Owner:EyePos():Distance(ent.HitPos)
	self.Owner:ViewPunch(Angle(-1,0,0))
	
	if (entply:GetClass() == "func_breakable_surf" or entply:GetClass() == "func_breakable") and entdis <= 100 then
		entply:Fire("RemoveHealth",25)
		self.Owner:EmitSound("physics/body/body_medium_impact_hard"..math.random(2,3)..".wav",78,math.random(98,102))
		hook.Call("HASHitBreakable",GAMEMODE,self.Owner,entply)
	end
	if not RoundActive then self.Owner:EmitSound("misc/happy_birthday_tf_"..math.random(10,29)..".wav",75,math.random(97,103)) return end

	if self.Owner:Team() != 2 or (not RoundActive) then return end
	
	if entply:IsPlayer() and entdis <= 120 and entply:Team() == 1 then
		entply:ViewPunch(Angle(8,math.random(-16,16),0))
		entply:Caught(self.Owner)
		if RoundCount > 0 then self.Owner:AddFrags(1) end
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime()+0.25)
	self.Weapon:SetNextSecondaryFire(CurTime()+0.25)
	if self.Owner:Team() == 2 and SeekerBlinded then return end
	local ent = self.Owner:GetEyeTrace()
	if CLIENT then return end
	local entply = ent.Entity
	local entdis = self.Owner:EyePos():Distance(ent.HitPos)
	self.Owner:ViewPunch(Angle(-1,0,0))
	
	if (entply:GetClass() == "func_breakable_surf" or entply:GetClass() == "func_breakable") and entdis <= 130 then
		entply:Fire("RemoveHealth",25)
		self.Owner:EmitSound("physics/body/body_medium_impact_hard"..math.random(2,3)..".wav",78,math.random(98,102))
		hook.Call("HASHitBreakable",GAMEMODE,self.Owner,entply)
	end
	if not RoundActive then self.Owner:EmitSound("misc/happy_birthday_tf_"..math.random(10,29)..".wav",75,math.random(97,103)) return end

	if self.Owner:Team() != 2 or (not RoundActive) then return end
	
	if entply:IsPlayer() and entdis <= 120 and entply:Team() == 1 then
		entply:ViewPunch(Angle(8,math.random(-16,16),0))
		entply:Caught(self.Owner)
		if RoundCount > 0 then self.Owner:AddFrags(1) end
	end
end

function SWEP:Reload()
	if CLIENT or self.TauntDelay > CurTime() then return end
	self.TauntDelay = CurTime()+2.5
	local taunts = {}
	local adda = (string.match(self.Owner:GetModel(),"female")) and "fe" or ""
	if RoundActive then
		if self.Owner:Team() == 1 then
			taunts = {
				"vo/npc/"..adda.."male01/answer20.wav",
				"vo/npc/"..adda.."male01/gordead_ans05.wav",
				"vo/npc/"..adda.."male01/gordead_ans06.wav",
				"vo/npc/"..adda.."male01/behindyou01.wav",
				"vo/npc/"..adda.."male01/hi01.wav",
				"vo/npc/"..adda.."male01/hi02.wav",
				"vo/npc/"..adda.."male01/illstayhere01.wav",
				"vo/npc/"..adda.."male01/littlecorner01.wav",
				"vo/npc/"..adda.."male01/runforyourlife01.wav",
				"vo/npc/"..adda.."male01/question30.wav",
				"vo/npc/"..adda.."male01/waitingsomebody.wav",
				"vo/npc/"..adda.."male01/uhoh.wav",
				"vo/npc/"..adda.."male01/incoming02.wav",
				"vo/npc/"..adda.."male01/yougotit02.wav",
				"vo/npc/"..adda.."male01/gethellout.wav",
				"vo/npc/"..adda.."male01/strider_run.wav",
				"vo/npc/"..adda.."male01/overhere01.wav",
				"vo/canals/"..adda.."male01/stn6_go_nag02.wav",
				"vo/trainyard/"..adda.."male01/cit_window_use01.wav",
				"vo/trainyard/"..adda.."male01/cit_window_use02.wav",
				"vo/trainyard/"..adda.."male01/cit_window_use03.wav",
				"vo/coast/barn/"..adda.."male01/youmadeit.wav",
				"vo/canals/"..adda.."male01/stn6_incoming.wav",
				"ambient/voices/cough2.wav",
				"ambient/voices/cough3.wav"
			}
			if string.match(self.Owner:GetModel(),"female") then
				table.insert(taunts,"vo/canals/airboat_go_nag01.wav")
				table.insert(taunts,"vo/canals/airboat_go_nag03.wav")
				table.insert(taunts,"vo/canals/arrest_getgoing.wav")
				table.insert(taunts,"vo/trainyard/cit_window_usnext.wav")
			else
				table.insert(taunts,"vo/canals/boxcar_becareful.wav")
				table.insert(taunts,"vo/canals/boxcar_becareful_b.wav")
				table.insert(taunts,"vo/canals/boxcar_go_nag03.wav")
				table.insert(taunts,"vo/canals/boxcar_go_nag04.wav")
				table.insert(taunts,"vo/canals/gunboat_goonout.wav")
				table.insert(taunts,"vo/canals/matt_beglad.wav")
				table.insert(taunts,"vo/canals/matt_getin.wav")
				table.insert(taunts,"vo/canals/matt_goodluck.wav")
				table.insert(taunts,"vo/canals/matt_tearinguprr_b.wav")
				table.insert(taunts,"vo/canals/shanty_go_nag01.wav")
				table.insert(taunts,"vo/canals/shanty_go_nag02.wav")
				table.insert(taunts,"vo/canals/shanty_go_nag03.wav")
				table.insert(taunts,"vo/canals/shanty_gotword.wav")
			end
		else
			taunts = {
				"vo/npc/"..adda.."male01/readywhenyouare01.wav",
				"vo/npc/"..adda.."male01/readywhenyouare02.wav",
				"vo/npc/"..adda.."male01/squad_approach02.wav",
				"vo/npc/"..adda.."male01/squad_away01.wav",
				"vo/npc/"..adda.."male01/squad_away02.wav",
				"vo/npc/"..adda.."male01/upthere01.wav",
				"vo/npc/"..adda.."male01/upthere02.wav",
				"vo/npc/"..adda.."male01/gotone01.wav",
				"vo/npc/"..adda.."male01/gotone02.wav",
				"vo/npc/"..adda.."male01/overthere01.wav",
				"vo/npc/"..adda.."male01/overthere02.wav",
				"vo/npc/"..adda.."male01/hi01.wav",
				"vo/npc/"..adda.."male01/hi02.wav",
				"vo/coast/odessa/"..adda.."male01/stairman_follow01.wav",
				"ambient/voices/cough2.wav",
				"ambient/voices/cough3.wav"
			}
			if string.match(self.Owner:GetModel(),"female") then
				table.insert(taunts,"vo/trainyard/female01/cit_hit05.wav")
			else
				table.insert(taunts,"vo/coast/bugbait/sandy_youthere.wav")
				table.insert(taunts,"vo/coast/bugbait/sandy_help.wav")
			end
		end
	else
		taunts = {
			"vo/npc/"..adda.."male01/yeah02.wav",
			"vo/coast/odessa/"..adda.."male01/nlo_cheer01.wav",
			"vo/coast/odessa/"..adda.."male01/nlo_cheer02.wav",
			"vo/coast/odessa/"..adda.."male01/nlo_cheer03.wav"
		}
	end
	self.Owner:EmitSound(table.Random(taunts),89,math.random(98,102))
	hook.Call("HASPlayerTaunted",GAMEMODE,self.Owner)
end