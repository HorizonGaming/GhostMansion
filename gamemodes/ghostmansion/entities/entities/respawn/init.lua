AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetNetVar("progress", 0)
	self:SetModel("models/props_c17/gravestone003a.mdl")
	self:SetAngles(Angle(0,90,0))
	self:SetModelScale(0.7,0)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE) 
	self:SetSolid(SOLID_NONE)
end

function ENT:Think()
	if self:GetNetVar("progress") > reviveTime then	
		self.Owner:Spawn()
		self.Owner:ChatPrint("You were revived!")
		self.Owner:SetPos(Vector(tostring(self:GetPos())))
		self.Owner:SetTeam(1)
		self.Owner:Give("weapon_flashlight")
		self.Owner:SetNetVar("battery", 50)
		self.Owner:AllowFlashlight( true )
		self.Owner:SetWalkSpeed( 120 )
		self.Owner:SetRunSpeed( 160 )
		self.Owner:SetModel(table.Random({
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
		"models/player/Group01/Male_09.mdl"}))
		self.Owner:SendLua([[RunConsoleCommand('act','wave')]])
	end
	if not IsValid(self.Owner) or self.Owner:Alive() then
		self:Remove()
	end
end