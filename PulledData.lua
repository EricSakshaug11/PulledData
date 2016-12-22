--This code is based on the addon "Who Pulled?" by Aierre, and qod

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

function PulledData_ScanMembersSub(arg)
	local wpname,wpserv;
	wpname,wpserv = WhoPulled_GetNameServ(arg);
	if(wpname and WhoPulled_RageList[wpserv] and WhoPulled_RageList[wpserv][wpname] and not WhoPulled_NotifiedOf[wpname.."-"..wpserv]) then
		DEFAULT_CHAT_FRAME:AddMessage(wpname.." who pulled "..WhoPulled_RageList[wpserv][wpname].." against your team is in this team!");
		WhoPulled_NotifiedOf[wpname.."-"..wpserv] = true;
	end
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

function PulledData_IgnoredSpell(spell)
	if(spell == "Hunter's Mark" or spell == "Sap" or spell == "Soothe" or spell == "Polymorph" or spell == "Hex") then
		return true;
	end
	return false;
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
	--[[local num,num1,PulledData_Name,PulledData_Player,PulledData_Role,PulledData_Tankappend;
	if(UnitInRaid("player")) then 
		num=GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		num1=GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE);
		if (num < num1) then 
			num = num1;
		end
		while num > 0 do
			PulledData_Name=GetUnitName("raid"..num,1,true);
			PulledData_Role = UnitGroupRolesAssigned("raid"..num);
			if(PulledData_Role == "TANK") then
				WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpname;
				WhoPulled_Tanks = WhoPulled_Tankappend;
				local wp_tanks = string.gsub(WhoPulled_Tanks, "%s%-%s", "-");
				WhoPulled_Tanks = wp_tanks;
				if(not string.find(WhoPulled_Tanks,wpname,1,true)) then
					WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpname;
					WhoPulled_Tanks = WhoPulled_Tankappend;
				else
				end
			elseif GetPartyAssignment("MAINTANK", "raid"..num) then
				if(not string.find(WhoPulled_Tanks,wpname,1,true)) then 
					WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpname;
					WhoPulled_Tanks = WhoPulled_Tankappend;
				else 
				end

			else
				if string.find(WhoPulled_Tanks,wpname,1,true) then
					wp_tanks = string.gsub(WhoPulled_Tanks, wpname, "");
					WhoPulled_Tanks = wp_tanks;
				else
				
				end
			
			end
		WhoPulled_ScanMembersSub(wpname);
		num = num-1;
		end
	else
		num=GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		num1=GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE);
		if (num < num1) then 
			num = num1;
		end
		while num > 0 do
			num = num - 1;
			if wpname == nil then wpname = "Unknown" end
			if num > 0 then
				wpname = GetUnitName("party"..num,true);
				wprole = UnitGroupRolesAssigned("party"..num);
				if(wprole == "TANK") then
					local wp_tanks = string.gsub(WhoPulled_Tanks, "%s%-%s", "-");
					WhoPulled_Tanks = wp_tanks; 
					if(not string.find(WhoPulled_Tanks,wpname,1,true)) then 
						WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpname; 
						WhoPulled_Tanks = WhoPulled_Tankappend; 
					else 
					end
				else 
					if string.find(WhoPulled_Tanks,wpname,1,true) then 
						local wp_tanks = string.gsub(WhoPulled_Tanks, wpname, "");
						WhoPulled_Tanks = wp_tanks; 
					end
				end
			end
			wpname = UnitName("player");
			wprole = UnitGroupRolesAssigned(wpname);
			if(wprole == "TANK") then
				local wp_tanks = string.gsub(WhoPulled_Tanks, "%s%-%s", "-");
				WhoPulled_Tanks = wp_tanks; 
				if(not string.find(WhoPulled_Tanks,wpname,1,true)) then 
					WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpname; 
					WhoPulled_Tanks = WhoPulled_Tankappend; 
				else 
				end
			else 
				if string.find(WhoPulled_Tanks,wpname,1,true) then 
					local wp_tanks = string.gsub(WhoPulled_Tanks, wpname, "");
					WhoPulled_Tanks = wp_tanks; 
				end
			end
		end
		WhoPulled_ScanMembersSub(wpname);
		wpplayer = UnitName("player"); 
		wprole = UnitGroupRolesAssigned(wpplayer);
		if(wprole == "TANK") then
				local wp_tanks = string.gsub(WhoPulled_Tanks, "%s%-%s", "-");
			WhoPulled_Tanks = wp_tanks; 
			if(not string.find(WhoPulled_Tanks,wpplayer,1,true)) then
				WhoPulled_Tankappend = WhoPulled_Tanks.." "..wpplayer; 
				WhoPulled_Tanks = WhoPulled_Tankappend;
			else 
			end
		else 	
		end
	end
end

function PulledData_ScanForPets()
	
end

function PulledData_ClearPulledList()
	
end

function PulledData_World()
	
end

function PulledData_CheckWho(...)
	
end

function PulledData_AddEvent(class, level, role, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped)
	PulledData_Data[PulledData_Count] = {
		class, level, role, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped
	};
	PulledData_Count = PulledData_Count + 1;]]--
end

function PulledData_ToFile()
	
end