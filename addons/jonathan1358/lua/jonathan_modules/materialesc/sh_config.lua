--[[---------------------------------------------------------
	MaterialEsc
	
	Copyright © 2015 Szymon (Szymekk) Jankowski
	All Rights Reserved
	Steam: https://steamcommunity.com/id/szymski
-------------------------------------------------------------]]

MESCConfig = { }
local Config = MESCConfig

--[[--------------------------------------------
	MaterialEsc Configuration

	Matching colors can be found here: http://www.google.com/design/spec/style/color.html#color-color-palette
	You can use this page to convert hex to rgb: http://www.colorhexa.com/
------------------------------------------------]]

Config.Background							= Color(255, 255, 255)

Config.ShowServerName						= true
Config.ServerName							= "I.C.F Server"
Config.ServerNameColor						= Color(63, 181, 63)

Config.ButtonBackground						= Color(255, 255, 255)
Config.ButtonClickColor						= Color(140, 140, 140, 100)
Config.ButtonClickColorCircle				= Color(140, 140, 140, 200)
Config.ButtonTextColor 						= Color(100, 100, 100, 255)
Config.ButtonHoverAnim						= true
Config.BarColor 							= Color(33, 150, 243)
Config.DialogHeader							= Color(0, 0, 0)

--Blue button color

Config.ButtonClickColor						= Color(66, 165, 245, 200)
Config.ButtonClickColorCircle				= Color(66, 165, 245, 255)

Config.Servers = {
	{
		name = "SledBuild #1",
		desc = "",
		addr = "192.99.35.97:27047",
		img = Material("materials/matesc/Sledbuild.png")
	},
	{
		name = "SledBuild #2",
		desc = "",
		addr = "192.99.35.97:27049",
		img = Material("materials/matesc/Sledbuild.png")
	},
	{
		name = "Hide and Seek #1",
		desc = "",
		addr = "192.99.35.97:27041",
		img = Material("materials/matesc/HideandSeek.png")
	},
	{
		name = "Hide and Seek #2 LOW GRAVITY",
		desc = "",
		addr = "192.99.35.97:27040",
		img = Material("materials/matesc/HideandSeek.png")
	},
	{
		name = "Prop Hunt LOW GRAVITY",
		desc = "",
		addr = "192.99.35.97:27048",
		img = Material("materials/matesc/PropHunt.png")
	},
	{
		name = "Melon Bomber",
		desc = "",
		addr = "192.99.35.97:27050",
		img = Material("materials/matesc/MelonBomber.png")
	},

}

--[[-------------------------------------------
	Custom buttons
	Config:OpenPage("your_url") - opens page in panel
-----------------------------------------------]]

function Config:RegisterButtons()

	Config:AddButton({
		text = "MOTD",
		click = function()
			if IsValid(DIALOG) then DIALOG:Remove() end
			Config:OpenPage("https://jolab.me/cmd/gm.motd?nomusic")
		end
	})
	Config:AddButton({
		text = "RULES",
		click = function()
			if IsValid(DIALOG) then DIALOG:Remove() end
			Config:OpenPage("https://jolab.me/icf/thread-1.html")
		end
	})
	Config:AddButton({
		text = "REPORT A PLAYER",
		click = function()
			if IsValid(DIALOG) then DIALOG:Remove() end
			gui.OpenURL("https://jolab.me/icf/forum-13.html")
			
			--local DIALOG = Jonathan1358.Hud.MsgDialog(Color(255, 255, 255), "Warning", "Don't send us useless report. Also don't fill in the description random characters to have the minimum chraracter limit. This will make your report invalid and YOU WILL GET BANNED.", Color(0, 0, 0), Color(100, 100, 100, 255), "OK", "Cancel")

			--DIALOG:SetAnimSize(600,200)
			--function DIALOG.Agree:DoClick()
			--	DIALOG:Remove()
			--	openReportMenu()
			--end
			--function DIALOG.Disagree:DoClick()
			--	DIALOG:Remove()
			end
		end
	})
	
	if GetConVarString('gamemode') != "guesswho" then
		Config:AddButton({
			text = "POINTSHOP",
			click = function()
				timer.Simple(0.2, function()
					if IsValid(DIALOG) then DIALOG:Remove() end
					Config:ClosePage()
					RunConsoleCommand("say","!shop")
				end)
			end
		})
	end
	
end

Config.DisconnectMessage = "Are you sure you want to leave this server?"

--[[
---------------------------------------------
	Here are some example styles
	To enable them - just remove /* and */
-----------------------------------------------

// Cyan button color

Config.ButtonClickColor						= Color(0, 191, 165, 200)
Config.ButtonClickColorCircle				= Color(0, 191, 165, 255)


// Blue button color

Config.ButtonClickColor						= Color(66, 165, 245, 200)
Config.ButtonClickColorCircle				= Color(66, 165, 245, 255)



// Dark theme

Config.Background							= Color(66, 66, 66)

Config.ButtonBackground						= Color(66, 66, 66)
Config.ButtonClickColor						= Color(0, 191, 165, 200)
Config.ButtonClickColorCircle				= Color(0, 191, 165, 255)
Config.ButtonTextColor 						= Color(255,255,255)

Config.DialogHeader							= Color(255, 255, 255)


// Transparent theme

Config.Background							= Color(0,0,0,150)

Config.ButtonBackground						= Color(66, 66, 66, 0)
Config.ButtonClickColor						= Color(0, 191, 165, 200)
Config.ButtonClickColorCircle				= Color(0, 191, 165, 255)
Config.ButtonTextColor 						= Color(255,255,255)

Config.DialogHeader							= Color(255, 255, 255)

--]]