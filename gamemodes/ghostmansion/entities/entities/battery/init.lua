AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/car_battery01.mdl")
	self:PhysicsInit(0)
	self:SetMoveType(0) 
	self:SetSolid(SOLID_VPHYSICS) 
	self:SetUseType(SIMPLE_USE)
end

function ENT:OnTakeDamage(dmg)
	return
end

function ENT:Use(activator)
end

function ENT:StartTouch( ent )
	if ent:IsPlayer() then
		if ent:Team() == 1 then
			if ent:GetNetVar("battery") < 100 then
			ent:SetNetVar("battery",(ent:GetNetVar("battery") + rechargeAmount))
				if ent:GetNetVar("battery") > 100 then
					ent:SetNetVar("battery", 100)
				end
			end
		end
		self:Remove()
	end
end