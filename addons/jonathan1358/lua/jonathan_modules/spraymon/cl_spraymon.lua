local function WithinBox(v, v1, v2)
	local x, y, z, x1, y1, z1, x2, y2, z2 = v[1], v[2], v[3], v1[1], v1[2], v1[3], v2[1], v2[2], v2[3]
	return ((x >= x1 and x <= x2) or (x <= x1 and x >= x2)) and ((y >= y1 and y <= y2) or (y <= y1 and y >= y2)) and ((z >= z1 and z <= z2) or (z <= z1 and z >= z2))
end

CreateConVar("spraymon_nooverspraying", 0, FCVAR_REPLICATED, "anti over spraying: 0 | 1")

local sprays = {}

net.Receive("Jonathan1358.SprayMon.AddSpray", function()
	local ply = net.ReadEntity()
	if ply.SteamID then
		local normal = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local ang = normal:Angle()
		local vec = ang:Forward() * .001 + (ang:Right() + ang:Up()) * 32
		local pos = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()) + ang:Up() * 4
		sprays[ply:SteamID()] = {name = ply:Name(), pos1 = pos - vec, pos2 = pos + vec, normal = normal, clears = 0, pos11 = pos - vec * 1.75, pos22 = pos + vec * 1.75}
	end
end)

local function clear()
	for k, v in next, sprays do
		v.clears = v.clears + 1
		if v.clears >= 2 then
			sprays[k] = nil
		end
	end
end

net.Receive("Jonathan1358.SprayMon.ClearDecals", clear)

local rcc = RunConsoleCommand
RunConsoleCommand = function(cmd, ...)
	if cmd == "r_cleardecals" then
		clear()
	end
	return rcc(cmd, ...)
end

local pcc = FindMetaTable("Player").ConCommand
FindMetaTable("Player").ConCommand = function(self, cmd, ...)
	if self == LocalPlayer() and cmd:find("r_cleardecals", nil, true) then
		clear()
	end
	return pcc(self, cmd, ...)
end

local gcm = game.CleanUpMap
function game.CleanUpMap(...)
	clear()
	return gcm(...)
end

surface.CreateFont("SMSpray", {font = "Trebuchet MS", size = 24, weight = 900})

local first = true
hook.Add("HUDPaint", "Jonathan1358.SprayMon", function()
	local todraw = {}
	local trace = LocalPlayer():GetEyeTraceNoCursor()
	for k, v in next, sprays do
		if v.normal == trace.HitNormal and WithinBox(trace.HitPos, v.pos1, v.pos2) then
			table.insert(todraw, k)
		end
	end
	if #todraw > 0 then
		if first then
			notification.AddLegacy("You can see the SteamID of spray owner by holding ALT while looking at it.", NOTIFY_HINT, 6)
			first = nil
		end
		local y = ScrH() / 2 - #todraw * 12
		draw.SimpleTextOutlined("Sprayed by:", "SMSpray", 10, y, Color(255, 136, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
		for k, v in next, todraw do
			y = y + 24
			draw.SimpleTextOutlined(sprays[v].name .. (input.IsKeyDown(KEY_LALT) and ": " .. v or ""), "SMSpray", 10, y, Color(255, 136, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
		end
		if input.IsKeyDown(KEY_LALT) then
			SetClipboardText(todraw[1])
		end
	end
end)

hook.Add("PlayerBindPress", "Jonathan1358.SprayMon", function(_, cmd, down)
	if down and cmd:find("impulse 201", nil, true) then
		if GetConVarNumber("spraymon_nooverspraying") > 0 then
			local trace = LocalPlayer():GetEyeTraceNoCursor()
			for k, v in next, sprays do
				if k ~= LocalPlayer():SteamID() and v.normal == trace.HitNormal and WithinBox(trace.HitPos, v.pos11, v.pos22) then
					chat.AddText(Color(255, 255, 255), "You can't place your spray here.")
					return true
				end
			end
		end
		net.Start("Jonathan1358.SprayMon.Spray")
		net.SendToServer()
	end
end)


local Tex_Corner8 = surface.GetTextureID("gui/corner8")
local loads = {}
local frame
concommand.Add("spraymon", function()
	if IsValid(frame) then
		frame:Remove()
		return
	end

	frame = vgui.Create("DFrame")
	frame:SetAlpha(0)
	frame:SetTitle("SprayMon")
	frame:SetSize(ScrW() * .94, ScrH() * .94)
	frame:Center()
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)

	local scroll = frame:Add("DScrollPanel")
	scroll:SetPos(7, 26)
	scroll:SetSize(frame:GetWide() - 14, frame:GetTall() - 30)

	local layout = scroll:Add("DIconLayout")
	layout:SetPos(0, 4)
	layout:SetSize(scroll:GetWide() - 16, scroll:GetTall())
	layout:SetSpaceX(4)
	layout:SetSpaceY(4)

	local err

	local all = player.GetHumans()
	table.sort(all, function(a, b) return a:Name():lower() < b:Name():lower() end)
	for k, v in next, all do
		if v.GetPlayerInfo and v:GetPlayerInfo() then
			local panel = layout:Add("DPanel")
			panel:SetDrawBackground(false)
			panel:SetSize(140, 168)

			local label1 = panel:Add("DLabel")
			label1:SetText(v:Name())
			label1:SizeToContents()
			if label1:GetWide() > 128 then
				label1:SetWide(128)
			end
			label1:SetPos(0, 4)
			label1:CenterHorizontal()

			local ok, mat, tex, w, h

			local name = v:GetPlayerInfo().customfiles[1]
			local uid = v:UserID()

			if name ~= "00000000" then
				mat = CreateMaterial("SMSpray_" .. uid .. (loads[uid] and "_" .. loads[uid] or ""), "UnlitGeneric", {
					["$basetexture"] = "temp/" .. name,
					["$vertexalpha"] = 1,
					Proxies = {
						AnimatedTexture = {
							animatedtexturevar = "$basetexture",
							animatedtextureframenumvar = "$frame",
							animatedtextureframerate = 5
						}
					}
				})
				tex = mat:GetTexture("$basetexture")
				if tex and "temp/" .. name == tex:GetName() then
					w, h = tex:Width(), tex:Height()
					ok = true
				end
			end

			function panel:Paint(pw, ph)
				surface.SetDrawColor(34, 34, 34, 255)

				surface.DrawRect(0, 2, 2, ph - 4)
				surface.DrawRect(2, 0, pw - 4, 2)
				surface.DrawRect(pw - 2, 2, 2, ph - 4)
				surface.DrawRect(2, ph - 2, pw - 4, 2)

				surface.SetTexture(Tex_Corner8)

				surface.DrawTexturedRectRotated(1, 1, 2, 2, 0) 
				surface.DrawTexturedRectRotated(pw - 1, 1, 2, 2, 270) 
				surface.DrawTexturedRectRotated(1, ph - 1, 2, 2, 90)
				surface.DrawTexturedRectRotated(pw - 1, ph - 1, 2, 2, 180)

				if ok then
					local d = math.max(w, h) / 128
					local w, h = w / d, h / d
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(mat)
					surface.DrawTexturedRect((pw - w) / 2, (ph - h) / 2, w, h)
				end
			end

			local label2 = panel:Add("DLabel")

			if tex then
				if ok then
					label2:SetText(w .. " x " .. h)
				else
					loads[uid] = (loads[uid] or 0) + 1
					label2:SetText("error")
					err = true
				end
			else
				label2:SetText(name == "00000000" and "no spray" or "not available")
			end

			label2:SizeToContents()

			if ok then
				label2:CenterHorizontal()
				label2:AlignBottom(4)

				function panel:OnCursorEntered()
					local d = (w > ScrW() or h > ScrH()) and math.max(w / ScrW(), h / ScrH()) or 1
					local w, h = w / d, h / d
					hook.Add("DrawOverlay", "Jonathan1358.SprayMon", function()
						surface.SetMaterial(mat)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect((ScrW() - w) / 2, (ScrH() - h) / 2, w, h)
					end)
				end

				function panel:OnCursorExited()
					hook.Remove("DrawOverlay", "Jonathan1358.SprayMon")
				end
			else
				label2:Center()
			end
		end
	end

	function frame:OnRemove()
		hook.Remove("DrawOverlay", "Jonathan1358.SprayMon")
	end

	local breload
	if err then
		breload = frame:Add("DButton")
		breload:SetText("Reload")
		breload:SetPos(0, 3)
		breload:SetSize(52, 19)
		function breload:DoClick()
			frame:Remove()
			RunConsoleCommand("spraymon")
		end
	end

	local orig = frame.Paint
	function frame:Paint(...)
		orig(self, ...)
		frame.Paint = orig
		local mx, my = 0, 0
		for k, v in next, layout:GetChildren() do
			local x = v.x + v:GetWide()
			if x > mx then
				mx = x
			end
			local y = v.y + v:GetTall()
			if y > my then
				my = y
			end
		end
		my = my + 38
		if my >= frame:GetTall() then
			mx = mx + 20
		end
		frame:SetSize(mx + 14, my < frame:GetTall() and my or frame:GetTall())
		frame:Center()
		if breload then
			breload:AlignRight(98)
		end
		scroll:SetSize(frame:GetWide() - 14, frame:GetTall() - 30)
		frame:SetAlpha(255)
		local x, y = frame:GetPos()
		gui.SetMousePos(x + frame:GetWide() - 20, y + 10)
	end
end)