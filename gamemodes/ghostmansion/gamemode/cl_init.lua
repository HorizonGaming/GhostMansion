include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_help.lua" )
include( "config.lua" )

function GM:Think() 
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	if ply:Team() == 2 then
		return true
	end
end

local tick = 0
local batCol = 0
function GM:HUDPaint()

	local ply = LocalPlayer()
	
	if LocalPlayer():Alive() then
		HP = LocalPlayer():Health()
	else
		HP = ""
	end
	
	if #player.GetAll() < 2 then
		draw.SimpleTextOutlined("Not enough players", "DermaLarge", ScrW()/2, ScrH() - 25, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0)) -- Not Enough Players
	end
	
	if LocalPlayer():Alive() and LocalPlayer():Team() == 2 then
		draw.RoundedBox(10, -10, ScrH() - 85, 200, 100, Color(0,0,0,240)) -- Background
		draw.RoundedBox(10, -10, ScrH() - 70, 185 * HP/LocalPlayer():GetMaxHealth(), 60, Color(150,0,0,200)) -- Color
		draw.DrawText(HP, "DermaLarge", 55, ScrH() - 55, Color(255, 255, 255, 255))
	end
	
	for k, v in pairs(player.GetAll()) do
		if v:Team() == 2 and LocalPlayer():Alive() and LocalPlayer():Team() == 1 then

			local alarm = math.Clamp(v:GetPos():Distance(LocalPlayer():GetPos()),0,255)
			if alarm < 200 and CurTime() > tick then
				LocalPlayer():EmitSound("ambient/levels/prison/radio_random1.wav",30,100*(100/alarm))
				tick = (CurTime() + 5*(alarm/500))
			end
			draw.RoundedBox(8, ScrW()/2 - 75, ScrH() - 60, 150, 150, Color(0, 0, 0, 200))
			draw.RoundedBox(8, ScrW()/2 - 75, ScrH() - 60, (150*alarm/255), 20, Color(255,255*alarm/255,255*alarm/255,10+math.abs(255*math.tan(CurTime()))))
			draw.DrawText("Spook-O-Meter", "Trebuchet18", ScrW()/2, ScrH() - 30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end

		if v:Alive() then
			if v:Team() == 1 then
				batCol = (LocalPlayer():GetNetVar("battery") or 0)/100
				local cord = v:GetPos():ToScreen()
				local name = v:Name()
				if LocalPlayer():Alive() then
					draw.DrawText(name, "HudSelectionText", cord.x, cord.y + 55, Color(255, 255 * batCol, 255 * batCol, 5), TEXT_ALIGN_CENTER)
				else
					draw.DrawText(name, "HudSelectionText", cord.x, cord.y + 10, Color(255, 255 * batCol, 255 * batCol, 5), TEXT_ALIGN_CENTER)
				end
				if v:GetNetVar("battery") == 0 then
					draw.DrawText("No Battery", "HudSelectionText", cord.x, cord.y + -90, Color(255, 255 * batCol, 255 * batCol, 5), TEXT_ALIGN_CENTER)
				end
			elseif v:Team() == 2 and v:GetNetVar("visible") then
				local cord2 = v:GetPos():ToScreen()
				local ghostHP = v:Health()
				col = (v:Health()/v:GetMaxHealth())
				if LocalPlayer():Alive() then
					draw.DrawText(ghostHP, "Trebuchet24", cord2.x, cord2.y + 55, Color(255, 255*col, 255*(col/1.5), 50), TEXT_ALIGN_CENTER)
				else
					draw.DrawText(ghostHP, "Trebuchet24", cord2.x, cord2.y + 20, Color(255, 255*col, 255*(col/1.5), 50), TEXT_ALIGN_CENTER)
				end
			end
		end
	end
	for k, v in pairs(ents.FindByClass("respawn")) do
		local progress = (v:GetNetVar("progress")) or 0
		local cord = v:GetPos():ToScreen()
		
		deathSayings = {"Your light... save me","So cold...","So dark...","That horrible sound...","Is this death...","Your light...","Save me...","Help me...","I feel nothing now..."}
		nextText = nextText or CurTime()
		if (nextText - CurTime()) <= 0 then
			nextText = CurTime() + 10
			deathText = table.Random(deathSayings)
		end
		
		draw.DrawText(deathText, "Trebuchet18", cord.x, cord.y - 40, Color(150, 100, 100, 50), TEXT_ALIGN_CENTER)
		draw.RoundedBox(1, cord.x - 25, cord.y + 10, 50, 5, Color(0,0,0) )
		draw.RoundedBox(1, cord.x - 25, cord.y + 10, 50 * (progress/reviveTime), 5, Color(100,0,0) )
	end
end

function GM:CalcView(ply, pos, angles, fov)
	if IsValid(ply) then
		local view = {}
		if ply:Alive() then
			local trace = {}
			if ply:Team() == 1 then
				trace.start = ply:GetPos() + Vector(0, 0, 100)
				trace.endpos = trace.start + Vector(0, 0, 200)
			elseif ply:Team() == 2 then
				trace.start = ply:GetPos() + Vector(0, 0, 200)
				trace.endpos = trace.start + Vector(0, 0, 400)
			end
			trace.filter = ply
			local tr = util.TraceLine(trace)
			view.origin = tr.HitPos + Vector(0, -50, 0)
		else
			view.origin = (Vector(0, -105, 540))
		end
		view.angles = Angle(80,90,0)
		view.fov = fov
		return view
	end
end

function GM:ShouldDrawLocalPlayer( ply )
	return true
end

local lastangles = Angle()
function GM:CreateMove( cmd )

	if LocalPlayer():Alive() then
		cmd:SetUpMove(0)
		cmd:RemoveKey(IN_JUMP)

		cmd:ClearMovement()

		local rel
		if zone then
			local center = (zone.mins + zone.maxs) / 2
			local t = LocalPlayer():GetPos() - center
			rel = t - Vector(x * zone.sqsize, y * zone.sqsize, t.z)
		end

		local vec = Vector(0, 0, 0)
		if cmd:KeyDown(IN_DUCK) then
			local ang = LocalPlayer():GetAimVector()

			if ang.x == 1 then -- Facing RIGHT
				if cmd:KeyDown(IN_FORWARD) then
					cmd:SetSideMove(-100000)
					vec.x = ang.x
				elseif cmd:KeyDown(IN_BACK) then
					cmd:SetSideMove(100000)
					vec.x = ang.x
				elseif cmd:KeyDown(IN_MOVERIGHT) then
					cmd:SetForwardMove(100000)
				elseif cmd:KeyDown(IN_MOVELEFT) then
					cmd:SetForwardMove(-100000)
				end
			elseif ang.x == -1 then -- Facing LEFT
				if cmd:KeyDown(IN_FORWARD) then
					cmd:SetSideMove(100000)
					vec.x = ang.x
				elseif cmd:KeyDown(IN_BACK) then
					cmd:SetSideMove(-100000)
					vec.x = ang.x
				elseif cmd:KeyDown(IN_MOVERIGHT) then
					cmd:SetForwardMove(-100000)
				elseif cmd:KeyDown(IN_MOVELEFT) then
					cmd:SetForwardMove(100000)
				end
			end
			if ang.y == 1 then -- Facing UP
				if cmd:KeyDown(IN_FORWARD) then
					cmd:SetForwardMove(100000)
				elseif cmd:KeyDown(IN_BACK) then
					cmd:SetForwardMove(-100000)
				elseif cmd:KeyDown(IN_MOVERIGHT) then
					cmd:SetSideMove(100000)
					vec.y = ang.y
				elseif cmd:KeyDown(IN_MOVELEFT) then
					cmd:SetSideMove(-100000)
					vec.y = ang.y
				end
			elseif ang.y == -1 then -- Facing DOWN
				if cmd:KeyDown(IN_FORWARD) then
					cmd:SetForwardMove(-100000)
				elseif cmd:KeyDown(IN_BACK) then
					cmd:SetForwardMove(100000)
				elseif cmd:KeyDown(IN_MOVERIGHT) then
					cmd:SetSideMove(-100000)
					vec.y = ang.y
				elseif cmd:KeyDown(IN_MOVELEFT) then
					cmd:SetSideMove(100000)
					vec.y = ang.y
				end
			end
		else
			if cmd:KeyDown(IN_FORWARD) then
				cmd:SetForwardMove(100000)
				vec.y = 1
			elseif cmd:KeyDown(IN_BACK) then
				cmd:SetForwardMove(100000)
				vec.y = -1
			end

			if cmd:KeyDown(IN_MOVELEFT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 180, 0)
				vec.x = -1
			elseif cmd:KeyDown(IN_MOVERIGHT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 0, 0)
				vec.x = 1
			end
		end

		if vec:Length() > 0 then
			lastangles = vec:Angle()
		end
		cmd:SetViewAngles(lastangles)

	end
end

hook.Remove("HUDPaint","HZG.HUD.Paint")
function GM:HUDShouldDraw(name)
	for k, v in pairs({"CHudHealth", "CHudWeaponSelection", "CHudBattery", "CHudAmmo", "CHudCrosshair"})do
		if name == v then return false end
	end
	return true
end

local tab = {
	["$pp_colour_brightness"] = 0.05, 
	["$pp_colour_contrast"] = 5, 
	["$pp_colour_colour"] = 0,
}
function GM:RenderScreenspaceEffects()
	if LocalPlayer():Team() == 2 and !LocalPlayer():GetNetVar("visible") then
		DrawColorModify( tab )
	end
end

local col = 1
function GM:PreDrawHalos()
	local client = LocalPlayer()
	
	if IsValid(client) and client:Alive() then
		halo.Add(ents.FindByClass( "battery" ), Color(255, 255, 100, 50), 0.5, 0.5, 2, true, false)
		halo.Add(ents.FindByClass( "super_battery" ), Color(100, 255, 100, (math.abs(25*math.tan(CurTime())))), 0.5, 0.5, 2, true, false)
		if client:Team() == 2 then
			local players = player.GetAll()
			local tab = {}
			local i = 1
			for k,v in pairs(players) do
				if not v:Alive() then continue end
				tab[i] = v
				i = i + 1
			end
			halo.Add(tab, Color(255, 255, 255), 0.5, 0.5, 2, true, true)
		end
		if client:Team() == 1 then
			local players = team.GetPlayers(2)
			local tab = {}
			local i = 1
			for k,v in pairs(players) do
				if not v:Alive() or !v:GetNetVar("visible") then continue end
				tab[i] = v
				i = i + 1
				col = v:Health()/v:GetMaxHealth()
			end
			halo.Add(tab, Color(255, 255*col, 255*(col/1.5)), 1, 1, 2, true, true)
		end
		local players = player.GetAll()
		local tab = {}
		local i = 1
		for k,v in pairs(players) do
			if not v:Alive() or v:Team() == 2 or not v:GetNetVar("battery") or (v:GetNetVar("battery") <= 100) then continue end
			tab[i] = v
			i = i + 1
		end
		halo.Add(tab, Color(100, 255, 100, (math.abs(25*math.tan(CurTime())))), 0.5, 0.5, 2, true, true)
	end
end