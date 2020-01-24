--
-- Mute Players Menu
--
-- Version 1.6
-- Author: The Leprechaun
-- Email: the.leprechaun.server@gmail.com
--
--

-- Check if we are a client
if CLIENT then

	-- Create a new font for the player names
    surface.CreateFont( "NameDefault",
    {
        font        = "Helvetica",
        size        = 20,
        weight      = 800
    })
	
	-- Create the console command and function
	concommand.Add("LepMute", function()	
		-- Variables
		local plyrs = player.GetAll()
		local FrameWidth = 500
		local FrameHeight = 350
		local windowTitle = ""
		local muteAdmins = 0
		
		-- Get window title and admin mute setting from ConVar
		if (GetConVarString("lmp_mute_admins") == "0") then
			windowTitle = "Mute Players - Note: Admins cannot be muted"
			muteAdmins = 0
		else
			windowTitle = "Mute Players"
			muteAdmins = 1
		end
		
		-- Create the DFrame to house the stuff
		DermaFrame = vgui.Create( "DFrame" )
		DermaFrame:SetPos( (ScrW()/2)-100,(ScrH()/2)-100 )
		DermaFrame:SetWidth(FrameWidth)
		DermaFrame:SetHeight(FrameHeight)
		DermaFrame:SetTitle( windowTitle )
		DermaFrame:SetVisible( true )
		DermaFrame:SetDraggable( true )
		DermaFrame:ShowCloseButton( true )
		DermaFrame:Center()
		DermaFrame:SetDeleteOnClose(true)
		DermaFrame:MakePopup()
		
		-- Create a DPanelList. Used for it's scrollbar
		DermaScrollPanel = vgui.Create("DPanelList", DermaFrame)
		DermaScrollPanel:SetPos(6, 25)
		DermaScrollPanel:SetSize(FrameWidth-12, FrameHeight-50-12)
		DermaScrollPanel:SetSpacing(2)
		DermaScrollPanel:SetPadding(2)
		DermaScrollPanel:SetVisible(true)
		DermaScrollPanel:EnableHorizontal(false)
		DermaScrollPanel:EnableVerticalScrollbar(true)

		-- Get the size of DermaScrollPanel
		local scrollWide = DermaScrollPanel:GetWide()
		
		-- Function to create player panels and add them to DermaScrollPanel
		function CreatePlayerPanels()
		
			-- Loop through players
			for id, pl in pairs( plyrs ) do
		
				-- Create a DPanel to hold the player
				pl.PlayerPanel = vgui.Create("DPanel")
				pl.PlayerPanel:SetWide(scrollWide)
				pl.PlayerPanel:SetVisible(true)

				-- Get the width of pl.PlayerPanel
				pl.PlayerPanelWide = pl.PlayerPanel:GetWide()

				-- Create a DLabel for the players name
				pl.NameLabel = vgui.Create( "DLabel", pl.PlayerPanel )
				pl.NameLabel:SetFont("NameDefault")
				pl.NameLabel:SetText(pl:Nick())
				pl.NameLabel:SetWide(pl.PlayerPanelWide - 50)
				pl.NameLabel:SetPos(3,3)
				pl.NameLabel:SetColor(Color(0,0,0,255))

				-- Create a DImageButton for the mute icon
				pl.Mute = vgui.Create( "DImageButton", pl.PlayerPanel )
				pl.Mute:SetSize( 20, 20 )

				-- Set if the player is muted
				pl.Muted = pl:IsMuted()

				-- Set the icon the mute status of the player
				if ( pl.Muted ) then
					pl.Mute:SetImage( "icon32/muted.png" )
				else
					pl.Mute:SetImage( "icon32/unmuted.png" )
				end

				-- Function when pl.Mute is clicked
				pl.Mute.DoClick = function()
					-- Change the mute state
					pl:SetMuted( !pl.Muted )

					-- Clear our DermaScrollPanel
					DermaScrollPanel:Clear()

					-- Call the function to redraw the DermaScrollPanel
					CreatePlayerPanels()

					-- This code can probably be removed
					if ( pl.Muted ) then
						pl.Mute:SetImage( "icon32/muted.png")
						
					else
						pl.Mute:SetImage( "icon32/unmuted.png" )
					end
				end
				
				-- Add the player panel to the DermaScrollPanel
				DermaScrollPanel:AddItem(pl.PlayerPanel)

				-- Create the layout for the panel and its children
				pl.PlayerPanel:InvalidateLayout(true)
				pl.PlayerPanel.PerformLayout = function()
					pl.PlayerPanelWide = pl.PlayerPanel:GetWide()
					pl.NameLabel:SetWide(pl.PlayerPanelWide - 50)
					pl.Mute:SetPos(pl.PlayerPanelWide - 20 - 3,3)
					pl.NameLabel:SetPos(3,3)
				end
				
				-- Check if the player is and admin. If so, don't let players mute them
				-- Comment out this section to disable this feature
				if (pl:IsAdmin() and muteAdmins == 0) then
					pl.Mute:SetDisabled(true)
				else
					pl.Mute:SetDisabled(false)
				end
				----- Admin mute disable section end ------
			end
		end
		
		-- This is the initial call to the function to draw the DermaScrollPanel
		-- This is called when the console command is run
		-- Has to be below the function, otherwise the function would be nonexistent when called
		CreatePlayerPanels()
		
			-- Create a panel to mute all
		muteAllPanel = vgui.Create("DPanel", DermaFrame)
		muteAllPanel:SetWide(scrollWide)
		muteAllPanel:SetVisible(true)
		muteAllPanel:SetBackgroundColor(Color(70,192,255,255))

		-- Get the width of muteAllPanel
		muteAllPanelWide = muteAllPanel:GetWide()
		
		-- Create a DLabel for the mute all label
		muteAllLabel = vgui.Create( "DLabel", muteAllPanel )
		muteAllLabel:SetFont("NameDefault")
		muteAllLabel:SetText("Mute All")
		muteAllLabel:SetWide(muteAllPanelWide - 50)
		muteAllLabel:SetPos(3,3)
		muteAllLabel:SetColor(Color(0,0,0,255))
		
		-- Create a DImageButton for the mute icon
		muteAllMuteButton = vgui.Create( "DImageButton", muteAllPanel )
		muteAllMuteButton:SetSize( 20, 20 )

		-- Set the icon to mute icon
		muteAllMuteButton:SetImage( "icon32/muted.png" )

		-- Function when muteAllMuteButton is clicked
		muteAllMuteButton.DoClick = function()
		
			for id2, pl2 in pairs( plyrs ) do
				if (pl2:IsAdmin() and muteAdmins == 0) then
					if (pl2:IsMuted() == true) then
						pl2:SetMuted(false)
					end
				else
					if (pl2:IsMuted() == false) then
						pl2:SetMuted(true)
					end
				end
			end

			-- Clear our DermaScrollPanel
			DermaScrollPanel:Clear()

			-- Call the function to redraw the DermaScrollPanel
			CreatePlayerPanels()
		end
		
		-- Create a DImageButton for the mute icon
		muteAllUnMuteButton = vgui.Create( "DImageButton", muteAllPanel )
		muteAllUnMuteButton:SetSize( 20, 20 )

		-- Set the icon to mute icon
		muteAllUnMuteButton:SetImage( "icon32/unmuted.png" )

		-- Function when muteAllUnMuteButton is clicked
		muteAllUnMuteButton.DoClick = function()
		
			for id2, pl2 in pairs( plyrs ) do
				if (pl2:IsMuted() == true) then
					pl2:SetMuted(false)
				end
			end

			-- Clear our DermaScrollPanel
			DermaScrollPanel:Clear()

			-- Call the function to redraw the DermaScrollPanel
			CreatePlayerPanels()
		end
		
		muteAllPanel:SetPos(6,FrameHeight-25-6)

		-- Create the layout for the panel and its children
		muteAllPanel:InvalidateLayout(true)
		muteAllPanel.PerformLayout = function()
			muteAllPanelWide = muteAllPanel:GetWide()
			muteAllLabel:SetWide(muteAllPanelWide - 50)
			muteAllMuteButton:SetPos(muteAllPanelWide - 26 - 20,3)
			muteAllUnMuteButton:SetPos(muteAllPanelWide - 20 - 3,3)
			muteAllLabel:SetPos(3,3)
		end
		
	end)
end

-- Create ConVars
CreateConVar("lmp_mute_admins", "0", {FCVAR_REPLICATED})


-- Check if we are a Server
if SERVER then
	-- Add a hook to player chat
    hook.Add("PlayerSay", "LepMutePlayers", function(Player, Text, Public)
    	-- Check if the text starts with a !
        if Text[1] == "!" or Text[1] == "/" then

        	-- Make the text all lowercase
            Text = Text:lower()

            -- Check if the text is "!mute". If so, run the console command
            if Text == "!muteppl" or Text == "/muteppl" then
				Player:ConCommand("LepMute")
                return ""
            end
        end
    end)
end