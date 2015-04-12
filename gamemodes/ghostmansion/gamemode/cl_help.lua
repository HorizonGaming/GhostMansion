local help = { "Welcome to Ghost Mansion!",
			   "",
			   "The objective of the gamemode is to exterminate the spooky ghost!",
			   "",
			   "Shine your flashlight on the ghost to reveal it and do damage.",
			   "Your flashlight runs on batteries, so don't let them run out!",
			   "Collect yellow normal batteries to recharge your battery.",
			   "Collect green super batteries to boost your battery into overcharge and deal more damage!",
			   "You can shine your flashlight to revive spooked teammates!",
			   "Hold shift to run. Hold left control to strafe.",
			   "Your Spook-O-Meter will turn red and make noises the closer the ghost is to you.",
			   "",
			   "If you are the ghost, sneak up behind humans to spook them!",
			   "Running will reveal you, however you can still use this to your advantage.",
			   "You can't spook people while a light is on you, so be sneaky for the ultimate spook.",
			   "The round ends when the ghost is exterminated or all humans are spooked.",
			   "",
			   "",
			   "Gamemode created by Indie"}

local PANEL = { }

function PANEL:Init( )

	local text = ""
	for k, v in ipairs( help ) do
	
		if ( k != 1 ) then
			text = text.."\n"
		end
		
		text = text..v
		
	end
	
	local lbl = vgui.Create( "DLabel", self )
	lbl:SetText( text )
	lbl:SetPos( 10, 30 )
	lbl:SizeToContents( )
	
	local w, h = surface.GetTextSize( "Default", "W" )
	
	self:SetSize( 500, #help * h + ( #help * 0.5 ) )
	self:Center( )
	self:MakePopup( )
	self:SetTitle("Gamemode Help")
	self:SetKeyboardInputEnabled( false )
	
	surface.PlaySound( "ui/hint.wav" )
	
end

function PANEL:Paint( )

	surface.SetDrawColor( Color( 0, 0, 0, 220 ) )
	surface.DrawRect( 0, 0, self:GetWide( ), self:GetTall( ) )
	surface.DrawRect( 0, 0, self:GetWide( ), 22.5 )
	
end
vgui.Register( "HelpScreen", PANEL, "DFrame" )

function CC_ShowHelp( pl, cmd, args )
	
	if ( GAMEMODE.HelpScreen ) then GAMEMODE.HelpScreen:Remove( ) end
	GAMEMODE.HelpScreen = vgui.Create( "HelpScreen" )
	
end
concommand.Add( "sh_helpscreen", CC_ShowHelp )