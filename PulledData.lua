function PulledData_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_INVITE_REQUEST");
	self:RegisterEvent("RAID_INSTANCE_WELCOME");
	self:RegisterEvent("PLAYER_LOGOUT");
	hooksecurefunc("LeaveParty",WhoPulled_OnLeaveParty);
	PulledData_Data = {}
	PulledData_Count = 1; --Remember, LUA tables are one indexed!
end

function PulledData_ScanMembersSub(arg1)
	
end

function PulledData_ScanForPets()
	
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