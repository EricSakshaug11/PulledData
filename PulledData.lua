function PulledData_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_INVITE_REQUEST");
	self:RegisterEvent("RAID_INSTANCE_WELCOME");
	self:RegisterEvent("PLAYER_LOGOUT");
	hooksecurefunc("LeaveParty",WhoPulled_OnLeaveParty);
	PulledData_Data = {};
	PulledData_Count = 1; --Remember, Lua tables are one indexed!
	PulledData_PetsToMaster = {};
end

function PulledData_ScanMembersSub(arg1)
	
end

function PulledData_ScanForPets()
	if(UnitInRaid("player")) then
		for i=1,39,1 do
			if(UnitExists("raidpet"..i)) then
				PulledData_PetsToMaster[UnitGUID("raidpet"..i)] = UnitName("raid"..i);
			end
		end
	else
		if(UnitExists("pet")) then WhoPulled_PetsToMaster[UnitGUID("pet")] = UnitName("player"); end
		for i=1,4,1 do
			if(UnitExists("partypet"..i)) then
				PulledData_PetsToMaster[UnitGUID("partypet"..i)] = UnitName("party"..i);
			end
		end
	end
end

function PulledData_GetPetOwner()
	if(PulledData_PetsToMaster[pet]) then return PulledData_PetsToMaster[pet]; end
	if(UnitInRaid("player")) then
		for i=1,40,1 do
			if(UnitGUID("raidpet"..i) == pet) then
				return UnitName("raid"..i);
			end
		end
	else
		if(UnitGUID("pet") == pet) then return UnitName("player"); end
		for i=1,5,1 do
			if(UnitGUID("partypet"..i) == pet) then
				return UnitName("party"..i);
			end
		end
	end
	return "Unknown";
end

function PulledData_ScanMembers()
	
end

function PulledData_ScanForPets()
	
end

function PulledData_ClearPulledList()
	
end

function PulledData_World()
	
end

function PulledData_CheckWho(...)
	
end

function PulledData_AddEvent(class, level, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped)
	PulledData_Data[PulledData_Count] = {
		class, level, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped
	};
	PulledData_Count = PulledData_Count + 1;
end

function PulledData_ToFile()
	
end