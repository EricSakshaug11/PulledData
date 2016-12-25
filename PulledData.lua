--This code is based on the addon "Who Pulled?" by Aierre and qod
--And by "based on", I mean I copied and pasted several of their
--functions. It's a pretty cool addon, you should check it out.
--https://mods.curse.com/addons/wow/whopulled
--Modifications from the original functions are as follows:
--Changed all tabs to double spaces
--Changed variable names from WhoPulled naming scheme to PulledData naming scheme
--Added some comments. All of my comments will be deonted with a (PR)

--TODO
--Change PulledData_SendMsg(chat,enemy)

PulledData_GUIDs = {}; 
PulledData_MobToPlayer = {};
PulledData_LastMob = "";
PulledData_PetsToMaster = {};
PulledData_Tanks = "";
PulledData_RageList = {};
PulledData_NotifiedOf = {};
PulledData_Settings = {};
PulledData_RageList = {};
PulledData_Ignore = {};
PulledData_Ignored = {
  "Adder",
  "Arctic Hare",
  "Beetle",
  "Crab",
  "Crystal Spider",
  "Devout Follower",
  "Frog",
  "Gold Beetle",
  "Larva",
  "Maggot",
  "Rat",
  "Risen Zombie",
  "Roach",
  "Snake",
  "Spider",
  "Toad",
  "Zul'Drak Rat",
};
PulledData_Settings = {
["yonboss"] = false,
["rwonboss"] = false,
["silent"] = false,
["msg"] = "%p PULLED %e!!!",
}
PulledData_Count = 1;
PulledData_Data = {};
PulledData_RecordedFight = false;
PulledData_PullerName;

function PulledData_ClearPulledList() 
  wipe(PulledData_GUIDs);
end

function PulledData_PullBlah(wplayer,enemy,msg)
  local iggy = 1;
  if(GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0) or (GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0) then -- added to make it silent when soloing no matter what(qod)
    if(not PulledData_GUIDs[enemy[1]]) then
      PulledData_GUIDs[enemy[1]] = true;
      PulledData_MobToPlayer[enemy[2]] = wplayer;
      PulledData_LastMob = enemy[2];
      local wp_tanks = string.gsub(PulledData_Tanks, "%s%-%s", "-");
      PulledData_Tanks = wp_tanks;
      if (not PulledData_Settings["silent"]) then
        if(PulledData_Settings["yonboss"]) then
          local i,boss;
          i = 1;
          while(UnitExists("boss"..i)) do
            if(UnitName("boss"..i) == enemy[2]) then
              for i=1, #PulledData_Ignored do
                if strlower(PulledData_Ignored[i]) == strlower(enemy[2]) then iggy = 2; end
              end
              if(not string.find(PulledData_Tanks,wplayer,1,true) and iggy == 1) then
                if(UnitInRaid("player") and PulledData_Settings["rwonboss"] and (UnitIsGroupAssistant() or UnitIsGroupLeader())) then 
                  PulledData_RaidWarning(enemy[2]);
                else
                  PulledData_Yell(enemy[2]);
                end
              end
              break;
            end
            i = i+1;
          end
        else
          for i=1, #PulledData_Ignored do
            if strlower(PulledData_Ignored[i]) == strlower(enemy[2]) then iggy = 2; end
          end
          if(iggy == 1 and not strfind(PulledData_Tanks,wplayer,1,true)) then
            DEFAULT_CHAT_FRAME:AddMessage(msg);
          end
        end
      end
    end
  end
end

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

function PulledData_ScanForPets()
  if(UnitInRaid("player")) then
    for i=1,39,1 do
      if(UnitExists("raidpet"..i)) then
        PulledData_PetsToMaster[UnitGUID("raidpet"..i)] = UnitName("raid"..i);
      end
    end
  else
    if(UnitExists("pet")) then PulledData_PetsToMaster[UnitGUID("pet")] = UnitName("player"); end
    for i=1,4,1 do
      if(UnitExists("partypet"..i)) then
        PulledData_PetsToMaster[UnitGUID("partypet"..i)] = UnitName("party"..i);
      end
    end
  end
end

function PulledData_ScanMembersSub(combo)
  local pdname,pdserv;
  pdname,pdserv = PulledData_GetNameServ(combo);
  if(pdname and PulledData_RageList[pdserv] and PulledData_RageList[pdserv][pdname] and not PulledData_NotifiedOf[pdname.."-"..pdserv]) then
    DEFAULT_CHAT_FRAME:AddMessage(pdname.." who pulled "..PulledData_RageList[pdserv][pdname].." against your team is in this team!");
    PulledData_NotifiedOf[pdname.."-"..pdserv] = true;
  end
end

function PulledData_ScanMembers()
  local num,num1,pdname,pdplayer,pdrole,PulledData_Tankappend;
  if(UnitInRaid("player")) then 
    num=GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
    num1=GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE);
    if (num < num1) then 
      num = num1;
    end
    while num > 0 do
      pdname=GetUnitName("raid"..num,1,true);
      pdrole = UnitGroupRolesAssigned("raid"..num);
      if(pdrole == "TANK") then
        PulledData_Tankappend = PulledData_Tanks.." "..wpname;
        PulledData_Tanks = PulledData_Tankappend;
        local pd_tanks = string.gsub(PulledData_Tanks, "%s%-%s", "-");
        PulledData_Tanks = pd_tanks;
        if(not string.find(PulledData_Tanks,wpname,1,true)) then
          PulledData_Tankappend = PulledData_Tanks.." "..wpname;
          PulledData_Tanks = PulledData_Tankappend;
        else
        end
      elseif GetPartyAssignment("MAINTANK", "raid"..num) then
        if(not string.find(PulledData_Tanks,pdname,1,true)) then 
          PulledData_Tankappend = PulledData_Tanks.." "..pdname;
          PulledData_Tanks = PulledData_Tankappend;
        end
      else
        if string.find(PulledData_Tanks,pdname,1,true) then
          pd_tanks = string.gsub(PulledData_Tanks, pdname, "");
          PulledData_Tanks = pd_tanks;
        end
      end
    PulledData_ScanMembersSub(pdname);
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
      if pdname == nil then pdname = "Unknown" end
      if num > 0 then
        pdname = GetUnitName("party"..num,true);
        pdrole = UnitGroupRolesAssigned("party"..num);
        if(pdrole == "TANK") then
          local pd_tanks = string.gsub(PulledData_Tanks, "%s%-%s", "-");
          PulledData_Tanks = pd_tanks; 
          if(not string.find(PulledData_Tanks,pdname,1,true)) then 
            PulledData_Tankappend = PulledData_Tanks.." "..pdname; 
            PulledData_Tanks = PulledData_Tankappend; 
          end
        else 
          if string.find(PulledData_Tanks,pdname,1,true) then 
            local pd_tanks = string.gsub(PulledData_Tanks, pdname, "");
            PulledData_Tanks = pd_tanks; 
          end
        end
      end
      pdname = UnitName("player");
      pdrole = UnitGroupRolesAssigned(pdname);
      if(pdrole == "TANK") then
        local pd_tanks = string.gsub(PulledData_Tanks, "%s%-%s", "-");
        PulledData_Tanks = pd_tanks; 
        if(not string.find(PulledData_Tanks,pdname,1,true)) then 
          PulledData_Tankappend = PulledData_Tanks.." "..pdname; 
          PulledData_Tanks = PulledData_Tankappend;  
        end
      else 
        if string.find(PulledData_Tanks,pdname,1,true) then 
          local pd_tanks = string.gsub(PulledData_Tanks, pdname, "");
          PulledData_Tanks = pd_tanks; 
        end
      end
    end
    PulledData_ScanMembersSub(pdname);
    pdplayer = UnitName("player"); 
    pdrole = UnitGroupRolesAssigned(pdplayer);
    if(pdrole == "TANK") then
        local pd_tanks = string.gsub(PulledData_Tanks, "%s%-%s", "-");
      PulledData_Tanks = pd_tanks; 
      if(not string.find(PulledData_Tanks,pdplayer,1,true)) then
        PulledData_Tankappend = PulledData_Tanks.." "..pdplayer; 
        PulledData_Tanks = PulledData_Tankappend;
      else 
      end
    else   
    end
  end
end

function PulledData_OnLeaveParty()
  wipe(PulledData_PetsToMaster);
  PulledData_Tanks = "";
  wipe(PulledData_NotifiedOf);
end

function PulledData_IgnoreddSpell(spell)
  if(spell == "Hunter's Mark" or spell == "Sap" or spell == "Soothe") then
    return true;
  end
  return false;
end

function PulledData_CheckWho(...)
  local time,event,hidecaster,sguid,sname,sflags,sraidflags,dguid,dname,dflags,draidflags,arg1,arg2,arg3,itype;
  
  if(IsInInstance()) then
     time,event,hidecaster,sguid,sname,sflags,sraidflags,dguid,dname,dflags,draidflags,arg1,arg2,arg3 = select(1, ...);

     --[[The follwing if statement does this:
     If given a source and a destination, and the source and destination
     are not the same, and it's not a friendly spell, then begin processing.
     (PR)]]--
     if(dname and sname and dname ~= sname and not string.find(event,"_RESURRECT") and not string.find(event,"_CREATE") and (string.find(event,"SWING") or string.find(event,"RANGE") or string.find(event,"SPELL"))) then

        --[[If this isn't a summon action, continue processing aggro
        If it is a summon, record pets.
        (PR)]]--
        if(not string.find(event,"_SUMMON")) then

        --If the source is a player, and the destination is an NPC. (PR)   
           if(bit.band(sflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
              
          --A player is attacking a mob (PR)
          if(not PulledData_IgnoreddSpell(arg2)) then
            --Put this here so it still counts as aggro if a mob casts one of these on a player.
            PulledData_PullBlah(sname,{dguid,dname},sname.." pulled "..dname.."! /ywho to tell everyone!");
          end
        elseif(bit.band(dflags,COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --A mob is attacking a player (stepped onto, perhaps?)
          PulledData_PullBlah(dname,{sguid,sname},dname.." pulled "..sname.."! /ywho to tell everyone!");
        elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(dflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --Player's pet attacks a mob
          local pullname;
          pname = PulledData_GetPetOwner(sguid);
          if(pname == "Unknown") then pullname = sname.." (pet)";
          else pullname = pname;
          end
          PulledData_PullBlah(pullname,{dguid,dname},pname.."'s "..sname.." pulled "..dname.."! /ywho to tell everyone!");

        elseif(bit.band(sflags,COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0 and bit.band(sflags,COMBATLOG_OBJECT_TYPE_NPC) ~= 0) then
          --Mob attacks a player's pet
          local pullname;
          pname = PulledData_GetPetOwner(dguid);
          if(pname == "Unknown") then pullname = dname.." (pet)";
          else pullname = pname;
          end
          PulledData_PullBlah(pullname,{sguid,sname},pname.."'s "..dname.." pulled "..sname.."! /ywho to tell everyone!");
        end
      else
        --Record summon
        PulledData_PetsToMaster[dguid] = sname;
      end
    end
  end
end

function PulledData_GetNameServ(combo)
  if not combo then return nil; end
  local pdname,pdserv = combo:match("([^%- ]+)%-?(.*)");
  if(pdname == "") then return nil,nil; end
  if(pdserv == "") then
    pdserv = GetRealmName();
    if not pdserv then pdserv = ""; end --whatever
  end
  return pdname,pdserv;
end

function PulledData_NameOrTarget(combo)
  if(pdname == "%t") then return UnitName("playertarget");
  else return combo;
  end
end

function PulledData_CLI(line)
  if line == "" then
    InterfaceOptionsFrame_OpenToCategory("PulledData")
  end
  local pos,comm;
  pos = string.find(line," ");
  if(pos) then
    comm = strlower(strsub(line,1,pos-1));
    line = strsub(line,pos+1);
  else
    comm = line;
    line = "";
  end
  if(comm == "clear")then
    wipe(PulledData_MobToPlayer);
    PulledData_LastMob = "";
  elseif(comm == "boss")then
    line = strlower(line);
    if(line == "rw") then
      PulledData_Settings["rwonboss"] = true;
      PulledData_Settings["yonboss"] = true;
      DEFAULT_CHAT_FRAME:AddMessage("Automatic raid warning of who pulled a boss: on");
    elseif(line == "true" or line == "yell" or line == "on") then
      PulledData_Settings["rwonboss"] = false;
      PulledData_Settings["yonboss"] = true;
      DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: on");
    else
      PulledData_Settings["rwonboss"] = false;
      PulledData_Settings["yonboss"] = false;
      DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: off");
    end
  elseif(comm == "msg")then
    PulledData_Settings["msg"] = line;
  elseif(comm == "silent")then
    line = strlower(line);
    if(line == "true" or line == "yell" or line == "on") then
      PulledData_Settings["silent"] = true;
      DEFAULT_CHAT_FRAME:AddMessage("Silent mode: on");
    else
      PulledData_Settings["silent"] = false;
      DEFAULT_CHAT_FRAME:AddMessage("Silent mode: off");
    end
  elseif(comm == "cleartanks" or comm == "ct")then
    PulledData_OnLeaveParty();
    DEFAULT_CHAT_FRAME:AddMessage("Tank list cleared");
  elseif(comm == "tank" or comm == "tanks") then
    line = PulledData_NameOrTarget(line);
    PulledData_Tanks = " "..line.." ";
    PulledData_ScanMembers();
    DEFAULT_CHAT_FRAME:AddMessage("Set tanks to:"..PulledData_Tanks);
  elseif(comm == "rage") then
    line = PulledData_NameOrTarget(line);
    if(PulledData_MobToPlayer[line]) then
      local pdname,pdserv = PulledData_GetNameServ(PulledData_MobToPlayer[line]);
      if not PulledData_RageList[pdserv] then PulledData_RageList[pdserv] = {}; end
      PulledData_RageList[pdserv][pdname] = line;
      DEFAULT_CHAT_FRAME:AddMessage("Your rage for "..pdname.." from "..pdserv.." for pulling "..line.." is now set in stone. You will be reminded should they ever join your party again.");
    else
      DEFAULT_CHAT_FRAME:AddMessage("No one pulled a "..line..".");
    end
  elseif(comm == "forgive") then -- needs testing, doesn't look right
    local pdname,pdserv = PulledData_GetNameServ(line);
    if(pdname) then
      local i,v,x;
      PulledData_RageList[pdserv][pdname] = nil;
      x=0;
      for i,v in pairs(PulledData_RageList[pdserv]) do
        x=x+1;
      end
      if(x == 0) then PulledData_RageList[pdserv] = nil; end
      DEFAULT_CHAT_FRAME:AddMessage("You have decided to give "..pdname.." of "..pdserv.." a second chance.");
    else
      DEFAULT_CHAT_FRAME:AddMessage("You have nothing against that player anyway.");
    end
  elseif(comm == "list") then
    local i,i2,v,v2,t;
    if(line ~= "") then
      line = PulledData_NameOrTarget(line);
      t = {};
      for i2,v2 in pairs(PulledData_RageList) do
        for i,v in pairs(v2) do
          if(i2 == line or v == line) then
            if not t[i2] then t[i2] = {}; end
            t[i2][i] = v;
          end
        end
      end
    else
      t = PulledData_RageList;
    end
    for i2,v2 in pairs(t) do
      DEFAULT_CHAT_FRAME:AddMessage("~~~~["..i2.."]~~~~");
      for i,v in pairs(v2) do
        DEFAULT_CHAT_FRAME:AddMessage(" * "..i..": Pulled "..v);
      end
    end
  elseif(comm == "ignore")then
    line = PulledData_NameOrTarget(line);
        line = (line):gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "");
    local found;
    for i=1, #PulledData_Ignored do
      if PulledData_Ignored[i] == line then found = i; end
    end
    if found then
      tremove(PulledData_Ignored, found);
      DEFAULT_CHAT_FRAME:AddMessage("Now listening to pulls of "..line);
    else
      tinsert(PulledData_Ignored, line);
      DEFAULT_CHAT_FRAME:AddMessage("Now ignoring pulls of "..line);
    end
    table.sort(PulledData_Ignored);
    local text;
    for i=1, #PulledData_Ignored do
      if not text then
        text = PulledData_Ignored[i];
      else
        text = text.."\n"..PulledData_Ignored[i];
      end
    end
    PDIgnoreEditBox:SetText(text or "");
  elseif(comm == "showtanks" or comm == "st") then
    DEFAULT_CHAT_FRAME:AddMessage("Tanks are set to: "..PulledData_Tanks);
  elseif(comm == "help") then
    line = strlower(line);
    if(line == "clear") then
      DEFAULT_CHAT_FRAME:AddMessage("Clears stored data on who pulled what for this session.");
    elseif(line == "boss" or line == "pdyb") then
      DEFAULT_CHAT_FRAME:AddMessage("Turns automatically yelling on boss pull on or off. Say rw if you want to use raid warning insted of yell. The short hand toggle for this is /pdyb");
    elseif(line == "msg") then
      DEFAULT_CHAT_FRAME:AddMessage("Message that you say. Use %p for the player who pulled, and %e for the enemy he pulled.");
    elseif(line == "who" or line == "swho" or line == "ywho" or line == "rwho" or line == "pwho" or line == "bwho" or line == "gwho" or line == "owho" or line == "rwwho") then
      DEFAULT_CHAT_FRAME:AddMessage("/Xwho Announce who pulled the latest pull or the given enemy where X can be s for Say, y for Yell, r for Raid, rw for Raid Warning, p for Party, g for Guild, o for Officer, b for Battlground, or m (Me/My) for only showing it to yourself.");
    elseif(line == "silent" or line == "pdsm") then
      DEFAULT_CHAT_FRAME:AddMessage("When active, do not show who pulled what when it happens. The short hand toggle for this is /pdsm");
    elseif(line == "tank" or line == "tanks") then
      DEFAULT_CHAT_FRAME:AddMessage("Any players you pass in this list will not be shown to pull enemies. This way you can ignore tank pulls, and only see when someone else pulls. List can be space, comma, period, or | separated. This list will be cleared when you leave the party or raid group.  Also automatically adds tanks based on party or raid role.");
    elseif(line == "rage") then
      DEFAULT_CHAT_FRAME:AddMessage("Add the player who killed the given enemy to your rage list for future warnings about that player.");
    elseif(line == "forgive") then
      DEFAULT_CHAT_FRAME:AddMessage("Remove the given player from your rage list. Remember to give the name as Name-Realm if they're not on the realm you're currently on.");
    elseif(line == "list") then
      DEFAULT_CHAT_FRAME:AddMessage("Dump your rage list to the console, optionally filtered by what they killed or what realm they're from.");
    elseif(line == "ignore") then
      DEFAULT_CHAT_FRAME:AddMessage("Toggles ignoring messages about pulls of a certain enemy, such as critters.");
    elseif(line == "help") then
      DEFAULT_CHAT_FRAME:AddMessage("Are you serious? lol");
    else
      DEFAULT_CHAT_FRAME:AddMessage("{} surround required parameters, [] surround optional ones.");
      DEFAULT_CHAT_FRAME:AddMessage("/pd help [topic] For help on a specific function.");
      DEFAULT_CHAT_FRAME:AddMessage("/pd clear");
      DEFAULT_CHAT_FRAME:AddMessage("/pd boss {on/off}");
      DEFAULT_CHAT_FRAME:AddMessage("/pd silent {on/off}");
      DEFAULT_CHAT_FRAME:AddMessage("/pd msg {custom message}");
      DEFAULT_CHAT_FRAME:AddMessage("/pd tanks [list of tanks]");
      DEFAULT_CHAT_FRAME:AddMessage("/pd rage {enemy}");
      DEFAULT_CHAT_FRAME:AddMessage("/pd forgive {player}");
      DEFAULT_CHAT_FRAME:AddMessage("/pd list [enemy/realm]");
      DEFAULT_CHAT_FRAME:AddMessage("/pd ignore [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/swho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/ywho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/rwho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/rwwho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/pwho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/bwho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/gwho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/owho [enemy]");
      DEFAULT_CHAT_FRAME:AddMessage("/mwho [enemy]");
    end
  end
end

--CHANGE THIS FUNCTION (PR)
function PulledData_SendMsg(chat,enemy)
  local msg,player;
  if enemy == "" then enemy = PulledData_LastMob; end
  player = PulledData_MobToPlayer[enemy];
  if player then
    msg = PulledData_Settings["msg"]:gsub("%%p",player);
    msg = msg:gsub("%%e",enemy);
    if(chat == "ECHO") then
      DEFAULT_CHAT_FRAME:AddMessage(msg); --CHANGE THIS (PR)
    else
      SendChatMessage(msg,chat); --CHANGE THIS (PR)
    end
  else
    DEFAULT_CHAT_FRAME:AddMessage("No information on who pulled that enemy."); --CHANGE THIS (PR)
  end
end

function PulledData_Say(enemy)
  PulledData_SendMsg("SAY",enemy);
end

function PulledData_Yell(enemy)
  PulledData_SendMsg("YELL",enemy);
end

function PulledData_Raid(enemy) -- needs check if in a raid
  PulledData_SendMsg("RAID",enemy);
end

function PulledData_Party(enemy) -- needs checks to force /i if not in a real party, and default chat frame if not in a party at all
  PulledData_SendMsg("PARTY",enemy);
end

function PulledData_BG(enemy) -- needs check if in a bg
  PulledData_SendMsg("BATTLEGROUND",enemy);
end

function PulledData_Guild(enemy) -- needs check if in a guild
  PulledData_SendMsg("GUILD",enemy);
end

function PulledData_Officer(enemy) -- needs check if in a guild and if officer chat is available (if such check is even possible)
  PulledData_SendMsg("OFFICER",enemy);
end

function PulledData_RaidWarning(enemy) -- needs check if in a raid
  PulledData_SendMsg("RAID_WARNING",enemy);
end

function PulledData_Me(enemy)
  PulledData_SendMsg("ECHO",enemy);
end

function PulledData_YoB()
  PulledData_Settings["yonboss"] = not PulledData_Settings["yonboss"];
  if(PulledData_Settings["yonboss"]) then DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: on");
  else DEFAULT_CHAT_FRAME:AddMessage("Automatic yell who pulled a boss: off");
  end
end

function PulledData_Silent()
  PulledData_Settings["silent"] = not PulledData_Settings["silent"];
  if(PulledData_Settings["silent"]) then DEFAULT_CHAT_FRAME:AddMessage("Silent mode: on");
  else DEFAULT_CHAT_FRAME:AddMessage("Silent mode: off");
  end
end

function PulledData_Options()
  InterfaceOptionsFrame_OpenToCategory("PulledData?");
end

function PulledData_World()

        local i,i2,found,v2,t,PulledData_variablesLoaded;
        if(PulledData_variablesLoaded == nil) then
            PulledData_variablesLoaded = false
        end
    if ( not PulledData_variablesLoaded ) then
      if(PulledData_Ignore ~= nil) then
        t = PulledData_Ignore;
        found = 1
        for i2,v2 in pairs(t) do
          found = 1
          for i=1, #PulledData_Ignored do
            if PulledData_Ignored[i] == i2 then found = 2 
            end
          end
          if found == 1 then
            tinsert(PulledData_Ignored, i2)
          end
        end
      end
      found = 1 -- Healing Stream, Flametongue, and Bloodworms mandatory ignore(qod)
      for i=1, #PulledData_Ignored do
        if PulledData_Ignored[i] == "Healing Stream Totem" then found = 2
        end
      end
      if found == 1 then
        tinsert(PulledData_Ignored, "Healing Stream Totem")
      end
      found = 1
      for i=1, #PulledData_Ignored do
        if PulledData_Ignored[i] == "Bloodworm" then found = 2
        end
      end
      if found == 1 then
        tinsert(PulledData_Ignored, "Bloodworm")
      end
      found = 1
      for i=1, #PulledData_Ignored do
        if PulledData_Ignored[i] == "Flametongue Totem" then found = 2
        end
      end
      if found == 1 then
        tinsert(PulledData_Ignored, "Flametongue Totem")
      end -- end of mandatory ignore items
      wipe(PulledData_Ignore)
      table.sort(PulledData_Ignored)
      PulledData_variablesLoaded = true
    end
  local text
  for i=1, #PulledData_Ignored do
    if not text then
      text = PulledData_Ignored[i]
    else
      text = text.."\n"..PulledData_Ignored[i]
    end
  end
  PDIgnoreEditBox:SetText(text or "")
end

  SLASH_YWHOPULLED1 = "/ywho"
  SlashCmdList["YWHOPULLED"] = PulledData_Yell
  SLASH_SWHOPULLED1 = "/swho"
  SlashCmdList["SWHOPULLED"] = PulledData_Say
  SLASH_RWHOPULLED1 = "/rwho"
  SlashCmdList["RWHOPULLED"] = PulledData_Raid
  SLASH_PWHOPULLED1 = "/pwho"
  SlashCmdList["PWHOPULLED"] = PulledData_Party
  SLASH_BWHOPULLED1 = "/bwho"
  SlashCmdList["BWHOPULLED"] = PulledData_BG
  SLASH_MWHOPULLED1 = "/mwho"
  SlashCmdList["MWHOPULLED"] = PulledData_Me
  SLASH_BWHOPULLED1 = "/gwho"
  SlashCmdList["GWHOPULLED"] = PulledData_Guild
  SLASH_BWHOPULLED1 = "/owho"
  SlashCmdList["OWHOPULLED"] = PulledData_Officer
  SLASH_RWWHOPULLED1 = "/rwwho"
  SlashCmdList["RWWHOPULLED"] = PulledData_RaidWarning
  SLASH_WHOPULLED1 = "/pd"
  SlashCmdList["WHOPULLED"] = PulledData_CLI
  SLASH_WHOPULLEDB1 = "/pdyb"
  SlashCmdList["WHOPULLEDB"] = PulledData_YoB
  SLASH_WHOPULLEDSM1 = "/pdsm"
  SlashCmdList["WHOPULLEDSM"] = PulledData_Silent


--This is one of only two functions added by me (PR)
function PulledData_AddEvent(class, level, role, enemyName, enemyLevel, location, server, pullType, race, faction, pullerDied, wiped, timestamp)
  PulledData_Data[PulledData_Count] = {
    class, level, role, enemyName, enemyLevel, location, server, pullType, race, faction, pullerDied, wiped, timestamp
  };
  PulledData_Count = PulledData_Count + 1;
end

--This is the other function added by me. (PR)
function PulledData_ToFile()
  
end
