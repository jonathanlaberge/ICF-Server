function JonAdvertThink() -- Print JonAdverts
	if not Initialized then -- Not initialized?
		if not JonAdverts then JonAdverts = {} end -- If the table doesn't exist, create it.

		JonAdverts[1] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,0,0),"  By playing on our server, you agree to respect the rules. Type ",Color(0,80,255),"/rules",Color(255,0,0)," to read the server's rules.")]]
		--JonAdverts[3] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  Someone is breaking the rules? Type ",Color(88,255,88),"/report ",Color(255,255,255),"to report him.")]]
		JonAdverts[2] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  Type ",Color(255,255,0),"/muteppl",Color(255,255,255)," to simply gag someone.")]]
		JonAdverts[3] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  You are ",Color(255,0,0),"not",Color(255,255,255)," allowed to prop / trail spam in sledbuild. Disobeying this rules may get you a ",Color(255,0,0),"ban",Color(255,255,255),".")]]
		JonAdverts[4] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  You are not allowed to spawn these kind of duplications: ",Color(155,155,255),"Snake, Gravity props, House or fort")]]
		JonAdverts[5] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"MINIMAL",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  You can allow other players to control your props. To allow them, ",Color(40,200,215),"hold Q > go to Utilities Tab > NADMOD Section > Client",Color(255,255,255),". Select the player you want to share the prop with, then click ",Color(255,40,40),"apply",Color(255,255,255),".")]]
		
		
		--JonAdverts[8] = [[chat.AddText(Color(255,255,255),"[",Color(255,255,0),"I.C.F.",Color(0,255,255)," Adverts",Color(255,255,255),"] ",Color(255,255,255),"  We are looking for active admin. Type ",Color(0,255,255),"/apply ",Color(255,255,255),"to learn more.")]]
		Initialized = true
	end

	JonAdvertDelay = JonAdvertDelay or 300 -- Default Delay.
	if not JonAdvertToggle == false and JonAdverts and #JonAdverts then -- Not toggled and the table exists.
		for i = 1, #JonAdverts do -- Start a loop,
			i = math.random(1, #JonAdverts) -- Find a random entry.

			if JonAdverts[i] then -- Check it exists and aint toggled off.
				JonAdvertNextMessage = JonAdvertNextMessage or 0
				if CurTime() > JonAdvertNextMessage then
					--for k, v in pairs(player.GetAll()) do
						--v:SendLua(JonAdverts[i]) -- Print the JonAdvert for every player.
					net.Start("Jonathan1358.Msg.ChatColor")
						 net.WriteString(JonAdverts[i])
					net.Broadcast()	
					--end
					JonAdvertNextMessage = CurTime() + JonAdvertDelay -- Delay 'till next message.

					i = #JonAdverts -- End the loop
				end
			end
		end
	elseif not JonAdverts then
		JonAdverts = {} -- If the table doesn't exist, create it.
	end
end
hook.Add("Think", "JonAdvertThink", JonAdvertThink)

function ToggleJonAdverts(ply, cmd, args) -- Toggle JonAdverts
	local i = args[1]
	if i == "see" then
		if JonAdverts and #JonAdverts then -- Table exists, and contains data.
			for i = 1, #JonAdverts do -- i is reset here.
				if JonAdverts[i] and JonAdverts[i] then
					print(i.." - "..JonAdverts[i]..".") -- If this entry is valid then print it's number and message.
				end
			end
		end
	else
		if i == "0" then
			JonAdvertToggle = false
			print("JonAdverts off.")
		else
			JonAdvertToggle = true
			Initialized = false
			JonAdvertDelay = JonAdvertDelay or 300
			JonAdvertNextMessage = CurTime() + JonAdvertDelay
			print("JonAdverts on.")
		end
	end
end
concommand.Add("advert_show", ToggleJonAdverts)

function TimeJonAdverts(ply, cmd, args) -- Change Delay Time
	local i = args[1]
	if i then -- If the user actually entered a number,
		JonAdvertDelay = i
		print("Current delay time - "..JonAdvertDelay.." sec.")
	else -- Complain.
		print("Please enter the delay time.")
		print("Current delay time - "..JonAdvertDelay.." sec.")
	end
end
concommand.Add("advert_delay", TimeJonAdverts)