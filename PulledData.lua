--This code is based on the addon "Who Pulled?" by Aierre, and qod
--And by "based on", I mean I copied and pasted several of their
--functions. It's a pretty cool addon, you should check it out.

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
--I don't think that this one is needed by my addon, I'll just comment it out.
--[[function PulledData_ScanMembersSub(arg)
  local PulledData_name,PulledData_Server;
  wpname,wpserv = PulledData_GetNameServ(arg);
  if(wpname and PulledData_RageList[wpserv] and WhoPulled_RageList[wpserv][wpname] and not PulledData_NotifiedOf[wpname.."-"..wpserv]) then
    DEFAULT_CHAT_FRAME:AddMessage(wpname.." who pulled "..PulledData_RageList[wpserv][wpname].." against your team is in this team!");
    PulledData_NotifiedOf[wpname.."-"..wpserv] = true;
  end
   end]]--

--Matches pets to their owners. It's not the pets' fault, it's the owner's.
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

--Returns true if "spell" is a spell that is listed to be ignored. 
function PulledData_IgnoredSpell(spell)
  if(spell == "Hunter's Mark" or spell == "Sap" or spell == "Soothe" or spell == "Polymorph" or spell == "Hex") then
    return true;
  end
  return false;
end

--
function PulledData_GetPetOwner(pet)
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
     end]]--
end

function PulledData_ScanForPets()
  
end

function PulledData_ClearPulledList()
  
end

--CONVERT FROM WHOPULLED TO PULLEDDATA
function PulledData_World()
   local i,i2,found,v2,t,WhoPulled_variablesLoaded;
        if(WhoPulled_variablesLoaded == nil) then
            WhoPulled_variablesLoaded = false
        end
		if ( not WhoPulled_variablesLoaded ) then
			if(WhoPulled_Ignore ~= nil) then
				t = WhoPulled_Ignore;
				found = 1
				for i2,v2 in pairs(t) do
					found = 1
					for i=1, #WhoPulled_Ignored do
						if WhoPulled_Ignored[i] == i2 then found = 2 
						end
					end
					if found == 1 then
						tinsert(WhoPulled_Ignored, i2)
					end
				end
			end
			found = 1 -- Healing Stream, Flametongue, and Bloodworms mandatory ignore(qod)
			for i=1, #WhoPulled_Ignored do
				if WhoPulled_Ignored[i] == "Healing Stream Totem" then found = 2
				end
			end
			if found == 1 then
				tinsert(WhoPulled_Ignored, "Healing Stream Totem")
			end
			found = 1
			for i=1, #WhoPulled_Ignored do
				if WhoPulled_Ignored[i] == "Bloodworm" then found = 2
				end
			end
			if found == 1 then
				tinsert(WhoPulled_Ignored, "Bloodworm")
			end
			found = 1
			for i=1, #WhoPulled_Ignored do
				if WhoPulled_Ignored[i] == "Flametongue Totem" then found = 2
				end
			end
			if found == 1 then
				tinsert(WhoPulled_Ignored, "Flametongue Totem")
			end -- end of mandatory ignore items
			wipe(WhoPulled_Ignore)
			table.sort(WhoPulled_Ignored)
			WhoPulled_variablesLoaded = true
		end
	local text
	for i=1, #WhoPulled_Ignored do
		if not text then
			text = WhoPulled_Ignored[i]
		else
			text = text.."\n"..WhoPulled_Ignored[i]
		end
	end
	WPIgnoreEditBox:SetText(text or "")

end


function PulledData_CheckWho(...)
  local time,event,hidecaster,sguid,sname,sflags,sraidflags,dguid,dname,dflags,draidflags,arg1,arg2,arg3,itype;
  
  if(IsInInstance()) then
    time,event,hidecaster,sguid,sname,sflags,sraidflags,dguid,dname,dflags,draidflags,arg1,arg2,arg3 = select(1, ...);
    if(dname and sname and dname ~= sname and not string.find(event,"_RESURRECT") and not string.find(event,"_CREATE") and (string.find(event,"SWING") or string.find(event,"RANGE") or string.find(event,"SPELL"))) then
      if(not string.find(event,"_SUMMON")) then
        if(bit.band(sflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --A player is attacking a mob
          if(not PulledData_IgnoreddSpell(arg2)) then
             --Put this here so it still counts as aggro if a mob casts one of these on a player.


             --FIX THIS, ADD MY OWN PULLBLAH THING, IT'S ADDEVENT 
             PulledData_PullBlah(sname,{dguid,dname},sname.." pulled "..dname.."! /ywho to tell everyone!");

             
          end
        elseif(bit.band(dflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
           --A mob is attacking a player (stepped onto, perhaps?)


           --ANOTHER PULLBLAH
           WhoPulled_PullBlah(dname,{sguid,sname},dname.." pulled "..sname.."! /ywho to tell everyone!");

           
        elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --Player's pet attacks a mob
          local pullname;
          pname = PulledData_GetPetOwner(sguid);
          if(pname == "Unknown") then pullname = sname.." (pet)";
          else pullname = pname;
          end

          --YETANOTHER PULLBLAH
          WhoPulled_PullBlah(pullname,{dguid,dname},pname.."'s "..sname.." pulled "..dname.."! /ywho to tell everyone!");
          

        elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --Mob attacks a player's pet
          local pullname;
          pname = WhoPulled_GetPetOwner(dguid);
          if(pname == "Unknown") then pullname = dname.." (pet)";
          else pullname = pname;
          end


          --PULLBLAH
          WhoPulled_PullBlah(pullname,{sguid,sname},pname.."'s "..dname.." pulled "..sname.."! /ywho to tell everyone!");


        end
      else
       --Record summon
      WhoPulled_PetsToMaster[dguid] = sname;
      end
    end
  end
end

function PulledData_AddEvent(class, level, role, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped)
  PulledData_Data[PulledData_Count] = {
    class, level, role, pullerLevel, location, server, pullType, race, faction, pullerDied, wiped
  };
  PulledData_Count = PulledData_Count + 1;]]--
end

function PulledData_ToFile()
  
end
