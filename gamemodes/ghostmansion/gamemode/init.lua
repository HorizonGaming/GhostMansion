AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_help.lua" )
AddCSLuaFile( "config.lua" )

resource.AddWorkshop( 361119360 ) -- ghost_manson by Skotty

include( "shared.lua" )
include( "sv_spawnpoints.lua" )
include( "config.lua" )
	
function GM:Initialize()
	game.active = false
	self.NextRoundTime = nil
	timer.Create("spawnbattery", batteryTimer, 0, function()
		for k, v in pairs(ents.GetAll()) do
			if (v:GetClass() == "battery") or (v:GetClass() == "super_battery") then
				v:Remove()
			end
		end
			
		local ent = ents.Create("battery")
		if math.random(1,100) <= superProb then 
			ent = ents.Create("super_battery") 
		end
		ent:SetPos(Vector(table.Random((spawnPoints))))
		ent:Spawn()
	end)
end

MaxBattery = 100
function GM:PlayerInitialSpawn( ply )
	if !game.active then
		ply:SetTeam(1)
		SetUpPlayer(ply)
	else
		ply:SetTeam(3)
		SetUpPlayer(ply)
	end
	if #player.GetAll() == 2 then
		self.NextRoundTime = CurTime()
	end
	ply:ConCommand("sh_helpscreen")
end

function GM:NewRound()
	game.CleanUpMap()
	for k, v in pairs(player.GetAll()) do
		if v:GetNetVar("nextGhost") then
			v:SetNetVar("nextGhost", false)
			v:SetTeam(2)
			SetUpPlayer(v)
		else
			v:SetTeam(1)
			SetUpPlayer(v)
		end
	end
	if #team.GetPlayers(2) == 0 then
		randGhost = table.Random(player.GetAll())
		randGhost:SetTeam(2)
		SetUpPlayer(randGhost)
	end
end

function SetUpPlayer(ply)
	timer.Simple(0, function()
		ply:Spawn()
		ply:StripWeapons()
		ply:SetCustomCollisionCheck( true )
		if ply:Team() == 1 then
			ply:Give("weapon_flashlight")
			ply:SetNetVar("battery", MaxBattery)
			ply:SetWalkSpeed( 120 )
			ply:SetRunSpeed( 150 )
			ply:SetModel(table.Random({
			"models/player/Group01/Female_01.mdl",
			"models/player/Group01/Female_02.mdl",
			"models/player/Group01/Female_03.mdl",
			"models/player/Group01/Female_04.mdl",
			"models/player/Group01/Female_06.mdl",
			"models/player/group01/male_01.mdl",
			"models/player/Group01/Male_02.mdl",
			"models/player/Group01/male_03.mdl",
			"models/player/Group01/Male_04.mdl",
			"models/player/Group01/Male_05.mdl",
			"models/player/Group01/Male_06.mdl",
			"models/player/Group01/Male_07.mdl",
			"models/player/Group01/Male_08.mdl",
			"models/player/Group01/Male_09.mdl"
			}))
		elseif ply:Team() == 2 then
			ply:SetNetVar("visible", false)
			ply.revealed = false
			ply:Give("weapon_spook")
			ply:Flashlight( false )
			ply:SetModel("models/player/zombie_soldier.mdl")
			ply:SetWalkSpeed( 130 )
			ply:SetRunSpeed( 200 )
			timer.Create("speedUp", 5, 0, function() ply:SetRunSpeed(ply:GetRunSpeed() + 1) end)
			local health = (300 + (50*(#player.GetAll())))
			ply:SetHealth(health)
			ply:SetMaxHealth(health)
		elseif ply:Team() == 3 then
			ply:KillSilent()
		end
	end)
end

function GM:ShouldCollide(ent1, ent2)
	if ent1:IsPlayer() and ent2:IsPlayer() and (ent1:Team() == ent2:Team()) then
		return false
	else
		return true
	end
end

function GM:PlayerDisconnected( ply )
	if (ply:Team() == 1) and (team.GetPlayers(1) == 1) then
		for k, v in pairs(player.GetAll()) do
			v:ChatPrint("The last human disconnected.")
		end
		self.NextRoundTime = (CurTime() + 5)
	elseif (ply:Team() == 2) and (team.GetPlayers(2) == 1) then
		for k, v in pairs(player.GetAll()) do
			v:ChatPrint("The last ghost disconnected.")
		end
		self.NextRoundTime = (CurTime() + 5)
	end
end

function GM:Think()
	if self.NextRoundTime and (CurTime() > self.NextRoundTime) then
		self:NewRound()
		self.NextRoundTime = nil
	end
	if #player.GetAll() > 1 then
		game.active = true
		if #team.GetPlayers(2) == 0 then
			self.NextRoundTime = CurTime()
		end
	else
		game.active = false
		for k, v in pairs(player.GetAll()) do
			v:StripWeapons()
		end
	end
	for k, v in pairs(player.GetAll()) do
		if v:Team() == 1 then
			v:SetRenderMode( 0 )
			v:SetColor(Color(255,255,255,255))
		elseif v:Team() == 2 then
			if v:GetNetVar("visible") then
				v:SetRenderMode( 0 )
				v:SetColor(Color(255,255,255,255))
			else
				v:SetRenderMode( 4 )
				v:SetColor(Color(255,255,255,0))
			end
		end
	end
end

function GM:PlayerDeath(victim, inflictor, killer)
	local plys1 = (#team.GetPlayers(1) - 1)
	local plys2 = (#team.GetPlayers(2) - 1)
	local deathPos = victim:GetPos()
	local term1 = ""
	if plys1 == 1 then
		term1 = "player remains."
	else
		term1 = "players remain."
	end		
	
	if victim:Team() == 1 then
		victim:LuaFlashlight( false )
		victim:SetNetVar("Flashlight",false)
		if plys1 > 0 then
			for k, v in pairs(player.GetAll()) do
				v:ChatPrint(victim:Name().." got spooked! "..plys1.." "..term1)
			end
			local ent = ents.Create("respawn")
			ent:Spawn()
			ent:SetPos(Vector(tostring(deathPos)) + Vector(0,0,15))
			ent.Owner = victim
			timer.Simple(noRevive, function() 
				if IsValid(ent) then
					ent.Owner:ChatPrint("Your grave crumbled to pieces!")
					ent:Remove() 
				end 
			end)
			victim:SetTeam(3)
		else
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("Everybody got spooked! The Ghost wins!")
				victim:SetTeam(3)
				victim:SetNetVar("nextGhost", true)
				self.NextRoundTime = (CurTime() + 5)
			end
		end
		victim:EmitSound("ambient/creatures/town_child_scream1.wav", 100, math.random(70,120))
	elseif victim:Team() == 2 then
		if plys2 > 0 then
			for k, v in pairs(player.GetAll()) do
				v:ChatPrint("A ghost was exterminated by "..killer:Nick().."!")
				victim:SetTeam(3)
				killer:SetNetVar("nextGhost", true)
			end
		else
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("The last ghost was exterminated by "..killer:Nick().."!")
				killer:SetNetVar("nextGhost", true)
				victim:SetTeam(3)
				self.NextRoundTime = (CurTime() + 5)
			end
		end
		victim:EmitSound("ambient/creatures/town_moan1.wav", 100, math.random(70,120))
	end
end

function GM:PlayerDeathThink( ply )
	if ply:Team() == 3 then
		ply:Freeze( true )
	else
		ply:Freeze( false )
	end
end

function GM:PlayerSpawn(ply)
	ply:AllowFlashlight( false )
	ply:SetNetVar( "Flashlight", false )
end

function GM:CanPlayerSuicide( ply )
	ply:ChatPrint("You can't escape!")
	return false
end

function GM:ShowHelp( ply )
	ply:ConCommand("sh_helpscreen")
end


local meta = FindMetaTable("Player")
function meta:LuaFlashlight( on )
	if on then
		local c = Color( 255, 255, 255 ) 
		local b = 0.4
		local size = 45
		local len = 550
						
		self.FlashlightEnt = ents.Create( "sent_flashlight" )
		self.FlashlightEnt:CreateLight( c, b, size, len )
		self.FlashlightEnt:SetOwner( self )
		self.FlashlightEnt:SetPos( self:GetShootPos() )
		self.FlashlightEnt:SetAngles( self:GetAimVector():Angle())
		self.FlashlightEnt:Spawn()
		
		self:EmitSound( "items/flashlight1.wav", 50, 110 )
		self:SetNetVar( "Flashlight", true )
	elseif IsValid( self.FlashlightEnt ) then
		self.FlashlightEnt:Remove()
			
		self:EmitSound( "items/flashlight1.wav", 50, 90 )
		self:SetNetVar( "Flashlight", false )
	end
end
