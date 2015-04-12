if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
else
	killicon.AddFont( "weapon_mu_magnum", "HL2MPTypeDeath", "1", Color( 255, 0, 0 ) )
end
SWEP.Base = "weapon_base"

SWEP.PrintName		= ""
SWEP.Slot			= 0
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 50
SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/weapons/w_stunbaton.mdl"
SWEP.HoldType		= "pistol"
SWEP.PKOneOnly = true

SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.Author			= "Indie"
SWEP.Contact		= ""
SWEP.Purpose		= "Ghost Mansion"
SWEP.Instructions	= ""

SWEP.Primary.Sound				= ""
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 1
SWEP.Primary.Recoil				= 5
SWEP.Primary.Cone				= 1
SWEP.Primary.Delay				= 3
SWEP.Primary.ClipSize			= 1	
SWEP.Primary.DefaultClip		= 1
SWEP.Primary.Tracer				= 1
SWEP.Primary.Force				= 0
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "Battery"
SWEP.Primary.ReloadTime = 3.7
SWEP.ReloadFinishedSound		= Sound("Weapon_Crossbow.BoltElectrify")
SWEP.ReloadSound = Sound("Weapon_357.Reload")

SWEP.Secondary.Sound				= ""
SWEP.Secondary.Damage				= 0
SWEP.Secondary.NumShots				= 1
SWEP.Secondary.Recoil				= 1
SWEP.Secondary.Cone					= 0
SWEP.Secondary.Delay				= 0.25
SWEP.Secondary.ClipSize				= -1
SWEP.Secondary.DefaultClip			= -1
SWEP.Secondary.Tracer				= -1
SWEP.Secondary.Force				= 5
SWEP.Secondary.TakeAmmoPerBullet	= false
SWEP.Secondary.Automatic			= false
SWEP.Secondary.Ammo					= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetColor(Color(0,0,0))
end

function SWEP:BulletCallback(att, tr, dmg)
	return {effects = true,damage = true}
end

function SWEP:OnRemove()
end

function SWEP:PrimaryAttack()
	if SERVER then
		if self.Owner:KeyDown( IN_SPEED ) then return end
		if self.Owner:GetNetVar("battery") <= 0 then return end
		if not self.Owner:GetNetVar("Flashlight") then
			self.Owner:LuaFlashlight( true )
			self.Owner:SetNetVar("Flashlight",true)
		else
			self.Owner:LuaFlashlight( false )
			self.Owner:SetNetVar("Flashlight",false)
		end
	end	
end

nextSec = 0
function SWEP:SecondaryAttack()
	if SERVER then
		if CurTime() > nextSec then
			self.Owner:EmitSound("vo/npc/male01/help01.wav")
			nextSec = CurTime() + 5
		end
	end
end

MASK_SHOT_OPAQUE = bit.bor(MASK_SHOT, CONTENTS_OPAQUE)
function LightVisible(posa, posb, ...)
	local filter = {}
	if ... ~= nil then
		for k, v in pairs({...}) do
			filter[#filter + 1] = v
		end
	end

	return not util.TraceLine({start = posa, endpos = posb, mask = MASK_SHOT_OPAQUE, filter = filter}).Hit
end

function SWEP:Think()
	if SERVER then
		self.Tick1 = self.Tick1 or 0
		self.Tick2 = self.Tick2 or 0
		if self.Owner:GetNetVar("battery") <= 0 or self.Owner:KeyDown( IN_SPEED ) then
			if self.Owner:GetNetVar("Flashlight") then
				self.Owner:LuaFlashlight(false)
			end
		end
		if self.Owner:GetNetVar("Flashlight") then
			if CurTime() > self.Tick1 then
				if self.Owner:GetNetVar("Flashlight") and IsValid(self.Owner.FlashlightEnt) then
					self.Owner:SetNetVar("battery", (self.Owner:GetNetVar("battery")) - 1)
				end
				self.Tick1 = CurTime() + 0.5
			end
			for k,v in pairs(team.GetPlayers(2)) do
				if IsValid(v) and v:Alive() then
					local eyepos = self.Owner:GetShootPos()
					local nearest = v:NearestPoint(eyepos)
					local dist = eyepos:DistToSqr(nearest)

					if dist <= (100*100) and LightVisible(eyepos, nearest, self.Owner, v) then
						local dot = (nearest - eyepos):GetNormal():Dot(self.Owner:GetAimVector())
						if dot >= 0.9 then
							v:SetNetVar("visible", true)
							v.revealed = true
							timer.Create("setvis"..v:EntIndex(), 1.5, 1, function() 
								v:SetNetVar("visible",false)
								v.revealed = false
							end)
							if self.Owner:GetNetVar("battery") > 100 then
								v:TakeDamage(1.2, self.Owner)
							else
								v:TakeDamage(1, self.Owner)
							end
						end
					end
				end
			end
			for k, v in pairs(ents.FindInSphere(self.Owner:GetPos(), 30 )) do
				if v:GetClass() == "respawn" then
					if CurTime() > self.Tick2 then
						v:SetNetVar("progress", v:GetNetVar("progress") + 0.1)
						self.Tick2 = CurTime() + 0.1
					end
				end
			end
		end
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

if CLIENT then -- Weapon HUD
	function SWEP:DrawHUD()
		
		weapon = "Flashlight"
		batteryPower = (self.Owner:GetNetVar("battery")) or 0
		desc = "Battery: "..batteryPower..""
		obj = "Shine your light on the ghost."
		
		local hudtxt = {
		{text=weapon, font="Trebuchet24", xalign=TEXT_ALIGN_CENTER},
		{text=desc, font="Trebuchet18", xalign=TEXT_ALIGN_CENTER},
		{text=obj, font="Trebuchet18", xalign=TEXT_ALIGN_CENTER}}
	
		local x = ScrW() - 95
		local xbox = ScrW() - 200
		
		hudtxt[1].pos = {x, ScrH() - 90}
		hudtxt[2].pos = {x, ScrH() - 45}
		hudtxt[3].pos = {x, ScrH() - 130}
		
		
		draw.RoundedBox(10, xbox, ScrH() - 105, ScrW(), 50, Color(10,10,10,200))
		draw.RoundedBox(10, xbox, ScrH() - 135, ScrW(), 25, Color(10,10,10,200))
		if batteryPower > 100 then
			draw.RoundedBox(10, xbox, ScrH() - 50, ScrW(), 25, Color(0,50,0,200))
		else
			draw.RoundedBox(10, xbox, ScrH() - 50, ScrW(), 25, Color(100 * (batteryPower/100),100 * (batteryPower/100),100 * (batteryPower/100),200))
		end
		
		draw.TextShadow(hudtxt[1], 2)
		draw.TextShadow(hudtxt[2], 2)
		draw.TextShadow(hudtxt[3], 2)
		
	end
end