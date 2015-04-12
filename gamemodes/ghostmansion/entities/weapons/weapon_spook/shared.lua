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
SWEP.WorldModel		= ""
SWEP.HoldType		= ""
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
	nextTele = 0
end

function SWEP:BulletCallback(att, tr, dmg)
	return {effects = true,damage = true}
end

nextAttack = 0
function SWEP:PrimaryAttack()
	if CurTime() > nextAttack then
		self.Owner:EmitSound("npc/stalker/breathing3.wav")
		nextAttack = CurTime() + 10
	end
end

nextTele = 0
function SWEP:SecondaryAttack()
	if SERVER then
		if CurTime() > nextTele then
			selfPos = self.Owner:GetPos()
			nextTele = CurTime() + 15
			for k, v in RandomPairs(player.GetAll()) do
				if v:Alive() and v != self.Owner then
					warpPos = v:GetPos()
					v:SetPos(selfPos)
					self.Owner:SetPos(warpPos)
					v:ChatPrint("You were translocated by the Ghost!")
					self.Owner:ChatPrint("You were translocated with "..v:Nick()..".")
					break
				else
					continue
				end
			end
		else
			self.Owner:ChatPrint("Translocation on cooldown for "..math.Round(nextTele - CurTime()).." seconds.")
		end
	end
end

tick = 0
function SWEP:Think()
	if SERVER then
		for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(), 20)) do
			if v:IsPlayer() and v:Team() != self.Owner:Team() and v:Alive() and !self.Owner.revealed and IsValid(self.Owner) then
				v:Kill()
				v:EmitSound("ambient/creatures/town_child_scream1.wav", 100, math.random(70,140))
				v:ConCommand([[play npc/stalker/go_alert2a.wav]])
				self.Owner:SetNetVar("visible", true)
				self.Owner.revealed = true
				self.Owner:SendLua([[RunConsoleCommand('act','zombie')]])
				timer.Simple(1.5, function() if IsValid(self.Owner) then self.Owner.revealed = false end end)
			end
		end
		if self.Owner:KeyDown( IN_SPEED ) then
			self.Owner:SetNetVar("visible", true )
		else
			if !self.Owner.revealed then
				self.Owner:SetNetVar("visible", false )
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
		
		weapon = "Ghost"
		desc = "Sneak Up Behind People."
		tele = "Right Click to Translocate."
		
		local hudtxt = {
		{text=weapon, font="Trebuchet24", xalign=TEXT_ALIGN_CENTER},
		{text=desc, font="Trebuchet18", xalign=TEXT_ALIGN_CENTER},
		{text=tele, font="Trebuchet18", xalign=TEXT_ALIGN_CENTER}}
	
		local x = ScrW() - 95
		local xbox = ScrW() - 200
		
		hudtxt[1].pos = {x, ScrH() - 90}
		hudtxt[2].pos = {x, ScrH() - 45}
		hudtxt[3].pos = {x, ScrH() - 130}
		
		
		draw.RoundedBox(10, xbox, ScrH() - 135, ScrW(), 25, Color(30,30,30,200))
		draw.RoundedBox(10, xbox, ScrH() - 105, ScrW(), 50, Color(10,10,10,200))
		draw.RoundedBox(10, xbox, ScrH() - 50, ScrW(), 25, Color(30,30,30,200))
		
		
		draw.TextShadow(hudtxt[1], 2)
		draw.TextShadow(hudtxt[2], 2)
		draw.TextShadow(hudtxt[3], 2)
		
		if self.Owner:GetNetVar("visible") then
		draw.SimpleTextOutlined("You are Visible!", "DermaLarge", ScrW()/2, ScrH() - 65, Color(255,255,255,(math.abs(255*math.tan(CurTime())))),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,50+math.abs(255*math.tan(CurTime()))))
	end
		
	end
end