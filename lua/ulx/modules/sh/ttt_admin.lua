local CATEGORY_NAME  = "TTT Admin"
local gamemode_error = "The current gamemode is not trouble in terrorist town!"

--[Ulx Completes]------------------------------------------------------------------------------
ulx.target_role = {}
function updateRoles()
	table.Empty( ulx.target_role )
	    
	table.insert(ulx.target_role, "innocent") -- Add "innocent" to the table.
	table.insert(ulx.target_role, "traitor") -- Add "traitor" to the table.
	table.insert(ulx.target_role, "detective") -- Add "detective" to the table.
	table.insert(ulx.target_role, "mercenary") -- Add "mercenary" to the table.
	table.insert(ulx.target_role, "hypnotist") -- Add "hypnotist" to the table.
	table.insert(ulx.target_role, "glitch") -- Add "glitch" to the table.
	table.insert(ulx.target_role, "jester") -- Add "jester" to the table.
	table.insert(ulx.target_role, "phantom") -- Add "phantom" to the table.
	table.insert(ulx.target_role, "zombie") -- Add "zombie" to the table.
	table.insert(ulx.target_role, "vampire") -- Add "vampire" to the table.
	table.insert(ulx.target_role, "swapper") -- Add "swapper" to the table.
	table.insert(ulx.target_role, "assassin") -- Add "assassin" to the table.
	table.insert(ulx.target_role, "killer") -- Add "killer" to the table.
	table.insert(ulx.target_role, "emt") -- Add "emt" to the table
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXRoleNamesUpdate", updateRoles )
updateRoles()
																							   

ulx.modifiers = {
	"Team Deathmatch",
	"H.U.G.E Problem",
	"Sudden Death",
	"The Ol' Switcheroo",
	"Zombie Apocalypse",
	"Juggernaut",
	"Remove All"
}
--[End]----------------------------------------------------------------------------------------

--[Global Helper Functions][Used by more than one command.]------------------------------------
--[[send_messages][Sends messages to player(s)]
@param  {[PlayerObject]} v       [The player(s) to send the message to.]
@param  {[String]}       message [The message that will be sent.]
--]]

function SetRole(ply, role)
    ply:SetRole(role)

function GetRoleStartingCredits(role)
    return (role == ROLE_TRAITOR and GetConVarNumber("ttt_credits_starting")) or
        (role == ROLE_DETECTIVE and GetConVarNumber("ttt_det_credits_starting")) or
        (role == ROLE_MERCENARY and GetConVarNumber("ttt_mer_credits_starting")) or
        (role == ROLE_KILLER and GetConVarNumber("ttt_kil_credits_starting")) or
        (role == ROLE_ASSASSIN and GetConVarNumber("ttt_assin_credits_starting")) or
        (role == ROLE_HYPNOTIST and GetConVarNumber("ttt_hypno_credits_starting")) or
		(role == ROLE_ASSASSIN and GetConVarNumber("ttt_vamp_credits_starting")) or 0
end
function send_messages(v, message)
	if type(v) == "Players" then
		v:ChatPrint(message)
	elseif type(v) == "table" then
		for i=1, #v do
			v[i]:ChatPrint(message)
		end
	end
end

--[[corpse_find][Finds the corpse of a given player.]
@param  {[PlayerObject]} v       [The player that to find the corpse for.]
--]]
function corpse_find(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end

--[[corpse_remove][removes the corpse given.]
@param  {[Ragdoll]} corpse [The corpse to be removed.]
--]]
function corpse_remove(corpse)
	CORPSE.SetFound(corpse, false)
	if string.find(corpse:GetModel(), "zm_", 6, true) then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
        corpse:Remove()
        SendFullStateUpdate()
	elseif corpse.player_ragdoll then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
		corpse:Remove()
        SendFullStateUpdate()
	end
end

--[[corpse_identify][identifies the given corpse.]
@param  {[Ragdoll]} corpse [The corpse to be identified.]
--]]
function corpse_identify(corpse)
	if corpse then
		local ply = player.GetByUniqueID(corpse.uqid)
		ply:SetNWBool("body_found", true)
		CORPSE.SetFound(corpse, true)
	end
end
--[End]----------------------------------------------------------------------------------------

--[Round Modifier]---------------------------------------------------------------------------------
--[[ulx.roundmodifier][Applies a round modifier to the next round.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[Number]}       modifier      [The modifier that will be applied to the next round.]
--]]
function ulx.roundmodifier(calling_ply, modifier)
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError(calling_ply, gamemode_error, true) else
		
		if modifier == "Team Deathmatch" then
			hook.Add("TTTSelectRoles", "Round_Modifier_Deathmatch", function()
				local tdmChoices = {}
				local plyCount = 0
				for i, v in pairs(player.GetAll()) do
					table.insert(tdmChoices, v)
					plyCount = plyCount + 1
					v:SetRole(ROLE_DETECTIVE)
				end
				local traitorCount = math.ceil(plyCount * 0.5)
				local tp = 0
				while tp < traitorCount do
					local trapick = math.random(1, #tdmChoices)
					local traply = tdmChoices[trapick]
					traply:SetRole(ROLE_TRAITOR)
					table.remove(tdmChoices, trapick)
					tp = tp + 1
				end
				SendFullStateUpdate()
			end)
		elseif modifier == "H.U.G.E Problem" then
			hook.Add("TTTBeginRound", "Round_Modifier_Huge_Problem", function()
				for i, ply in pairs(player.GetAll()) do
					for _, wep in pairs(ply:GetWeapons()) do
						if wep.Kind == WEAPON_HEAVY then
							ply:StripWeapon(wep:GetClass())
						end
					end
					local huge = ply:Give("weapon_zm_sledge")
					ply:GiveAmmo(300, "smg1", true)
					huge.AllowDrop = false
				end
			end)
		elseif modifier == "Sudden Death" then
			hook.Add("TTTBeginRound", "Round_Modifier_Sudden_Death", function()
				timer.Create("suddenDeath", 0.1, 0, function()
					for i, ply in pairs(player.GetAll()) do
						if ply:Health() > 1 then
							ply:SetHealth(1)
						end
					end
				end)
			end)
		elseif modifier == "The Ol' Switcheroo" then
			hook.Add("TTTSelectRoles", "Round_Modifier_Switcheroo", function()
				local carnivalChoices = {}
				for i, v in pairs(player.GetAll()) do
					table.insert(carnivalChoices, v)
					v:SetRole(ROLE_SWAPPER)
				end
				
				local trapick = math.random(1, #carnivalChoices)
				local traply = carnivalChoices[trapick]
				traply:SetRole(ROLE_TRAITOR)
				table.remove(carnivalChoices, trapick)
				traply:SetDefaultCredits()
				
				local detpick = math.random(1, #carnivalChoices)
				local detply = carnivalChoices[detpick]
				detply:SetRole(ROLE_DETECTIVE)
				table.remove(carnivalChoices, detpick)
				detply:SetDefaultCredits()
				
				SendFullStateUpdate()
			end)
		elseif modifier == "Zombie Apocalypse" then
			hook.Add("TTTSelectRoles", "Round_Modifier_Zombie", function()
				local zombieChoices = {}
				local plyCount = 0
				for i, v in pairs(player.GetAll()) do
					table.insert(zombieChoices, v)
					plyCount = plyCount + 1
				end
				local zombieCount = math.ceil(plyCount * GetConVar("ttt_zombie_pct"):GetFloat())
				local zp = 0
				while zp < zombieCount do
					local zompick = math.random(1, #zombieChoices)
					local zomply = zombieChoices[zompick]
					zomply:SetRole(ROLE_ZOMBIE)
					table.remove(zombieChoices, zompick)
					zp = zp + 1
				end
				SendFullStateUpdate()
			end)
		elseif modifier == "Juggernaut" then
			hook.Add("TTTSelectRoles", "Round_Modifier_Juggernaut", function()
				local juggernautChoices = {}
				local plyCount = 0
				for i, v in pairs(player.GetAll()) do
					table.insert(juggernautChoices, v)
					v:SetRole(ROLE_TRAITOR)
					v:SetDefaultCredits()
					plyCount = plyCount + 1
				end
				
				local jugpick = math.random(1, #juggernautChoices)
				local jugply = juggernautChoices[jugpick]
				jugply:SetRole(ROLE_DETECTIVE)
				table.remove(juggernautChoices, jugpick)
				jugply:SetDefaultCredits()
				jugply:SetHealth((plyCount - 1) * 100)
				
				SendFullStateUpdate()
			end)
		elseif modifier == "Remove All" then
			hook.Remove("TTTSelectRoles", "Round_Modifier_Deathmatch")
			hook.Remove("TTTBeginRound", "Round_Modifier_Huge_Problem")
			hook.Remove("TTTBeginRound", "Round_Modifier_Sudden_Death")
			timer.Remove("suddenDeath")
			hook.Remove("TTTSelectRoles", "Round_Modifier_Switcheroo")
			hook.Remove("TTTSelectRoles", "Round_Modifier_Zombie")
			hook.Remove("TTTSelectRoles", "Round_Modifier_Juggernaut")
			ulx.fancyLogAdmin(calling_ply, false, "#A turned off all modifiers.")
			return
		else
			return
		end
		ulx.fancyLogAdmin(calling_ply, false, "#A turned on the modifier #s.", modifier)
	end
end

local roundmod = ulx.command(CATEGORY_NAME, "ulx roundmodifier", ulx.roundmodifier, "!roundmodifier")
roundmod:addParam { type = ULib.cmds.StringArg, completes = ulx.modifiers, hint = "Modifier" }
roundmod:defaultAccess(ULib.ACCESS_SUPERADMIN)
roundmod:help("Turns round modifiers on.")
--[Force role]---------------------------------------------------------------------------------
--[[ulx.force][Forces <target(s)> to become a specified role.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_role   [The role that target player(s) will have there role set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.slaynr( calling_ply, target_ply, num_slay, should_slaynr )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		local affected_plys = {}
		local slays_left = tonumber(target_ply:GetPData("slaynr_slays")) or 0
		local current_slay
		local new_slay
	    
	
		if ulx.getExclusive( target_ply, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		elseif num_slay < 0 then
			ULib.tsayError( calling_ply, "Invalid integer:\"" .. num_slay .. "\" specified.", true )
		else
			current_slay = tonumber(target_ply:GetPData("slaynr_slays")) or 0
			if not should_slaynr then 	
                new_slay = current_slay + num_slay  
            else
                new_slay = current_slay - num_slay	
            end

            --local slay_reason = reason
            --if slay_reason == "reason" then
            --	slay_reason = false
            --end

			if new_slay > 0 then 		
                target_ply:SetPData("slaynr_slays", new_slay)
                --target_ply:SetPData("slaynr_reason", slay_reason) 
            else
				target_ply:RemovePData("slaynr_slays")
                --target_ply:RemovePData("slaynr_reason")   
            end

	    	local slays_left 	= tonumber(target_ply:GetPData("slaynr_slays"))  or 0
			local slays_removed = ( current_slay - slays_left ) 		or 0

			if slays_removed==0 then
				chat_message = ("#T will not be slain next round.")
			elseif slays_removed > 0 then
				chat_message = ("#A removed ".. slays_removed .." round(s) of slaying from #T.")
			elseif slays_left == 1 then
				chat_message = ("#A will slay #T next round.")
			elseif slays_left > 1 then
				chat_message = ("#A will slay #T for the next ".. tostring(slays_left) .." rounds.")
			end
			ulx.fancyLogAdmin( calling_ply, chat_message, target_ply, reason )
		end
	end
end
local slaynr = ulx.command( CATEGORY_NAME, "ulx slaynr", ulx.slaynr, "!slaynr" )
slaynr:addParam{ type=ULib.cmds.PlayerArg }
slaynr:addParam{ type=ULib.cmds.NumArg, max=100, default=1, hint="rounds", ULib.cmds.optional, ULib.cmds.round }
--slaynr:addParam{ type=ULib.cmds.StringArg, hint="reason",  ULib.cmds.optional}
slaynr:addParam{ type=ULib.cmds.BoolArg, invisible=true }
slaynr:defaultAccess( ULib.ACCESS_ADMIN )
slaynr:help( "Slays target(s) for a number of rounds" )
slaynr:setOpposite( "ulx rslaynr", {_, _, _, true}, "!rslaynr" )
--[Helper Functions]---------------------------------------------------------------------------
hook.Add("TTTBeginRound", "SlayPlayersNextRound", function()
	local affected_plys = {}

	for _,v in pairs(player.GetAll()) do
		local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0
        
		if v:Alive() and slays_left > 0 then
			local slays_left=slays_left -1

			if slays_left == 0 then	
                v:RemovePData("slaynr_slays")
                v:RemovePData("slaynr_reason")
			else 					
                v:SetPData("slaynr_slays", slays_left) 
            end

			v:StripWeapons()

			table.insert( affected_plys, v )
			
			timer.Create("check" .. v:SteamID(), 0.1, 0, function() --workaround for issue with tommys damage log 
				 
				v:Kill()

				GAMEMODE:PlayerSilentDeath(v)

				local corpse = corpse_find(v)
				if corpse then
					v:SetNWBool("body_found", true)
                    SendFullStateUpdate()
                    
					if string.find(corpse:GetModel(), "zm_", 6, true) then
						corpse:Remove()
					elseif corpse.player_ragdoll then
						corpse:Remove()
					end
				end

				v:SetTeam(TEAM_SPEC)
				if v:IsSpec() then timer.Destroy("check" .. v:SteamID()) return end
			end)
            
            timer.Create("traitorcheck" .. v:SteamID(), 1, 0, function() --have to wait for gamemode before doing this
                if v:GetRole() == ROLE_TRAITOR then
                    SendConfirmedTraitors( GetInnocentFilter( false ) ) -- Update innocent's list of traitors.
                    SCORE:HandleBodyFound( v, v )
                end
            end)
		end
	end

	local slay_message
	for i=1, #affected_plys do
		local v = affected_plys[ i ]
		local string_inbetween

		if i > 1 and #affected_plys == i then
			string_inbetween=" and "
		elseif i > 1 then
			string_inbetween=", "
		end

		string_inbetween = string_inbetween or ""
		slay_message = ( ( slay_message or "") .. string_inbetween )
		slay_message = ( ( slay_message or "") .. v:Nick() )
	end

	local slay_message_context
	if #affected_plys == 1 then slay_message_context ="was" else slay_message_context ="were" end
	if #affected_plys ~= 0 then
		ULib.tsay(_, slay_message .. " ".. slay_message_context .." slain.")
	end
end)

hook.Add("PlayerSpawn", "Inform" , function(ply)
	local slays_left = tonumber(ply:GetPData("slaynr_slays")) or 0
	local slay_reason = false
        
	if ply:Alive() and slays_left > 0 then
		local chat_message = ""

		if slays_left > 0 then
			chat_message = (chat_message .. "You will be slain this round")
		end
		if slays_left > 1 then
			chat_message = (chat_message .. " and ".. (slays_left - 1) .." round(s) after the current round")
		end
		if slay_reason then
			chat_message = (chat_message .. " for \"".. slays_reason .."\".")
		else
			chat_message = (chat_message .. ".")
		end
		ply:ChatPrint(chat_message)
	end
end)
--[End]----------------------------------------------------------------------------------------


--[Force role]---------------------------------------------------------------------------------
--[[ulx.force][Forces <target(s)> to become a specified role.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_role   [The role that target player(s) will have there role set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.force( calling_ply, target_plys, target_role, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

		local affected_plys = {}
		local starting_credits=GetConVarNumber("ttt_credits_starting")
		local det_starting_credits = GetConVarNumber("ttt_det_credits_starting")
		local mer_starting_credits = GetConVarNumber("ttt_mer_credits_starting")
		local kil_starting_credits = GetConVarNumber("ttt_kil_credits_starting")
		local assin_starting_credits = GetConVarNumber("ttt_assin_credits_starting")
		local hypno_starting_credits = GetConVarNumber("ttt_hypno_credits_starting")
		local vamp_starting_credits = GetConVarNumber("ttt_vamp_credits_starting")

		local role
		local role_grammar
		local role_string
		local role_credits

	    if target_role ==  "traitor"   or target_role == "t" then role, role_grammar, role_string, role_credits = ROLE_TRAITOR,   "a ",  "traitor",   starting_credits end
	    if target_role ==  "detective" or target_role == "d" then role, role_grammar, role_string, role_credits = ROLE_DETECTIVE, "a ",  "detective", det_starting_credits end
		if target_role == "mercenary" or target_role == "m" then role, role_grammar, role_string, role_credits = ROLE_MERCENARY, "a ", "mercenary", mer_starting_credits end
		if target_role == "hypnotist" or target_role == "h" then role, role_grammar, role_string, role_credits = ROLE_HYPNOTIST, "a ", "hypnotist", hypno_starting_credits end
		if target_role == "glitch" or target_role == "g" then role, role_grammar, role_string, role_credits = ROLE_GLITCH, "a ", "glitch", 0 end
		if target_role == "jester" or target_role == "j" then role, role_grammar, role_string, role_credits = ROLE_JESTER, "a ", "jester", 0 end
		if target_role == "phantom" or target_role == "p" then role, role_grammar, role_string, role_credits = ROLE_PHANTOM, "a ", "phantom", 0 end
		if target_role == "zombie" or target_role == "z" then role, role_grammar, role_string, role_credits = ROLE_ZOMBIE, "a ", "zombie", 0 end
		if target_role == "vampire" or target_role == "v" then role, role_grammar, role_string, role_credits = ROLE_VAMPIRE, "a ", "vampire", vamp_starting_credits end
		if target_role == "swapper" or target_role == "s" then role, role_grammar, role_string, role_credits = ROLE_SWAPPER, "a ", "swapper", 0 end
		if target_role == "assassin" or target_role == "a" then role, role_grammar, role_string, role_credits = ROLE_ASSASSIN, "an ", "assassin", assin_starting_credits end
		if target_role == "killer" or target_role == "k" then role, role_grammar, role_string, role_credits = ROLE_KILLER, "a ", "killer", kil_starting_credits end
		if target_role == "emt" or target_role == "e" then role, role_grammar, role_string, role_credits = ROLE_KILLER, "an ", "emt", 0 end
	    if target_role ==  "innocent"  or target_role == "i" then role, role_grammar, role_string, role_credits = ROLE_INNOCENT,  "an ", "innocent",  0                end
	    
	    for i=1, #target_plys do
			local v = target_plys[ i ]
			local current_role = v:GetRole()
	
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif GetRoundState() == 1 or GetRoundState() == 2 then
	    		ULib.tsayError( calling_ply, "The round has not begun!", true )
			elseif role == nil then
	    		ULib.tsayError( calling_ply, "Invalid role :\"" .. target_role .. "\" specified", true )
			elseif not v:Alive() then
				ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
			elseif current_role == role then
	    		ULib.tsayError( calling_ply, v:Nick() .. " is already " .. role_string, true )
			else
				v:ResetEquipment()
				RemoveLoadoutWeapons(v)
				RemoveBoughtWeapons(v)

	            v:SetRole(role)
	            v:SetCredits(role_credits)
	            SendFullStateUpdate()

	            GiveLoadoutItems(v)
	            GiveLoadoutWeapons(v)

	            table.insert( affected_plys, v )
				
				if target_role == "killer" or target_role == "k" then
					v:SetMaxHealth(150)
					v:SetHealth(150)
				else
					v:SetMaxHealth(100)
					v:SetHealth(100)
				end
			end
	    ulx.fancyLogAdmin( calling_ply, should_silent, "#A forced #T to become the role of " .. role_grammar .."#s.", affected_plys, role_string )
	    send_messages(affected_plys, "Your role has been set to " .. role_string .. "." )
	end
end
local force = ulx.command( CATEGORY_NAME, "ulx force", ulx.force, "!force" )
force:addParam{ type=ULib.cmds.PlayersArg }
force:addParam{ type=ULib.cmds.StringArg, completes=ulx.target_role, hint="Role" }
force:addParam{ type=ULib.cmds.BoolArg, invisible=true }
force:defaultAccess( ULib.ACCESS_SUPERADMIN )
force:setOpposite( "ulx sforce", {_, _, _, true}, "!sforce", true )
force:help( "Force <target(s)> to become a specified role." )

--[Helper Functions]---------------------------------------------------------------------------
--[[GetLoadoutWeapons][Returns the loadout weapons ]
@param  {[Number]} r [The role of the loadout weapons to be returned]
@return {[table]}    [A table of loadout weapons for the given role.]
--]]
function GetLoadoutWeapons(r)
	local tbl = {
		[ROLE_INNOCENT] = {},
		[ROLE_TRAITOR]  = {},
		[ROLE_MERCENARY] = {},
		[ROLE_HYPNOTIST] = {},
		[ROLE_GLITCH] = {},
		[ROLE_JESTER] = {},
		[ROLE_PHANTOM] = {},
		[ROLE_ZOMBIE] = {},
		[ROLE_VAMPIRE] = {},
		[ROLE_SWAPPER] = {},
		[ROLE_ASSASSIN] = {},
		[ROLE_KILLER] = {},
		[ROLE_EMT] = {},
		[ROLE_DETECTIVE]= {}
	};
	for k, w in pairs(weapons.GetList()) do
		if w and type(w.InLoadoutFor) == "table" then
			for _, wrole in pairs(w.InLoadoutFor) do
				table.insert(tbl[wrole], WEPS.GetClass(w))
			end
		end
	end
	return tbl[r]
end

--[[RemoveBoughtWeapons][Removes previously bought weapons from the shop.]
@param  {[PlayerObject]} ply [The player who will have their bought weapons removed.]
--]]
function RemoveBoughtWeapons(ply)
	for _, wep in pairs(weapons.GetList()) do
		local wep_class = WEPS.GetClass(wep)
		if wep and type(wep.CanBuy) == "table" then
			for _, weprole in pairs(wep.CanBuy) do
				if weprole == ply:GetRole() and ply:HasWeapon(wep_class) then
					ply:StripWeapon(wep_class)
				end
			end
		end
	end
end

--[[RemoveLoadoutWeapons][Removes all loadout weapons for the given player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons removed.]
--]]
function RemoveLoadoutWeapons(ply)
	local weps = GetLoadoutWeapons( GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole() )
	for _, cls in pairs(weps) do
		if ply:HasWeapon(cls) then
			ply:StripWeapon(cls)
		end
	end
	
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
	if ply:HasWeapon("weapon_emt_healray") then
		ply:StripWeapon("weapon_emt_healray")
	end
	if ply:HasWeapon("weapon_emt_brainwash") then
		ply:StripWeapon("weapon_emt_brainwash")
    end
end

--[[GiveLoadoutWeapons][Gives the loadout weapons for that player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons given.]
--]]
function GiveLoadoutWeapons(ply)
	local r = GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole()
	local weps = GetLoadoutWeapons(r)
	if not weps then return end

	for _, cls in pairs(weps) do
		if not ply:HasWeapon(cls) then
			ply:Give(cls)
		end
	end
end

--[[GiveLoadoutItems][Gives the default loadout items for that role.]
@param  {[PlayerObject]} ply [The player who the equipment will be given to.]
--]]
function GiveLoadoutItems(ply)
	local items = EquipmentItems[ply:GetRole()]
	if items then
		for _, item in pairs(items) do
			if item.loadout and item.id then
				ply:GiveEquipmentItem(item.id)
			end
		end
	end
end
--[End]----------------------------------------------------------------------------------------



--[Respawn]------------------------------------------------------------------------------------
--[[ulx.respawn][Respawns <target(s)>]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawn( calling_ply, target_plys, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		local affected_plys = {}
	
		for i=1, #target_plys do
			local v = target_plys[ i ]
	
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif GetRoundState() == 1 then
	    		ULib.tsayError( calling_ply, "Waiting for players!", true )
                
			elseif v:Alive() and v:IsSpec() then -- players arent really dead when they are spectating, we need to handle that correctly
                timer.Destroy("traitorcheck" .. v:SteamID())
                v:ConCommand("ttt_spectator_mode 0") -- just incase they are in spectator mode take them out of it
                timer.Create("respawndelay", 0.1, 0, function() --seems to be a slight delay from when you leave spec and when you can spawn this should get us around that
                    local corpse = corpse_find(v) -- run the normal respawn code now
                    if corpse then corpse_remove(corpse) end

                    v:SpawnForRound( true )
                    v:SetCredits(GetRoleStartingCredits(v:GetRole()))
				
                    table.insert( affected_plys, v )
                    
                    ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned #T!", affected_plys )
                    send_messages(affected_plys, "You have been respawned.")
        
                    if v:Alive() then timer.Destroy("respawndelay") return end
                end)
                
            elseif v:Alive() then
				ULib.tsayError( calling_ply, v:Nick() .. " is already alive!", true ) 
			else
                timer.Destroy("traitorcheck" .. v:SteamID())
				local corpse = corpse_find(v)
				if corpse then corpse_remove(corpse) end

				v:SpawnForRound( true )
				v:SetCredits(GetRoleStartingCredits(v:GetRole()))
				
				table.insert( affected_plys, v )
			end
		end
		ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned #T!", affected_plys )
		send_messages(affected_plys, "You have been respawned.")
	end
end
local respawn = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn")
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:addParam{ type=ULib.cmds.BoolArg, invisible=true }
respawn:defaultAccess( ULib.ACCESS_SUPERADMIN )
respawn:setOpposite( "ulx srespawn", {_, _, true}, "!srespawn", true )
respawn:help( "Respawns <target(s)>." )
--[End]----------------------------------------------------------------------------------------



--[Respawn teleport]---------------------------------------------------------------------------
--[[ulx.respawntp][Respawns <target(s)>]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_ply    [The player who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawntp( calling_ply, target_ply, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

		local affected_ply = {}	
		if not calling_ply:IsValid() then
			Msg( "You are the console, you can't teleport or teleport others since you can't see the world!\n" )
			return
		elseif ulx.getExclusive( target_ply, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		elseif GetRoundState() == 1 then
            ULib.tsayError( calling_ply, "Waiting for players!", true )
            
        elseif target_ply:Alive() and target_ply:IsSpec() then
            timer.Destroy("traitorcheck" .. target_ply:SteamID())
            target_ply:ConCommand("ttt_spectator_mode 0")
            timer.Create("respawntpdelay", 0.1, 0, function() --have to wait for gamemode before doing this
                local t  = {}
                t.start  = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
                t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
                t.filter = target_ply
                if target_ply ~= calling_ply then
                    t.filter = { target_ply, calling_ply }
                end
                local tr = util.TraceEntity( t, target_ply )
		
                local pos = tr.HitPos

                local corpse = corpse_find(target_ply)
                if corpse then corpse_remove(corpse) end

                target_ply:SpawnForRound( true )
                target_ply:SetCredits(GetRoleStartingCredits(target_ply:GetRole()))
		
                target_ply:SetPos( pos )
                table.insert( affected_ply, target_ply )
                
                ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned and teleported #T!", affected_ply )
                send_messages(target_ply, "You have been respawned and teleported.")
                
                if target_ply:Alive() then timer.Destroy("respawntpdelay") return end
            end) 
            
		elseif target_ply:Alive() then
			ULib.tsayError( calling_ply, target_ply:Nick() .. " is already alive!", true )
		else
            timer.Destroy("traitorcheck" .. target_ply:SteamID())
			local t  = {}
			t.start  = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
			t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
			t.filter = target_ply
			if target_ply ~= calling_ply then
				t.filter = { target_ply, calling_ply }
			end
			local tr = util.TraceEntity( t, target_ply )
		
			local pos = tr.HitPos

			local corpse = corpse_find(target_ply)
			if corpse then corpse_remove(corpse) end

			target_ply:SpawnForRound( true )
			target_ply:SetCredits(GetRoleStartingCredits(target_ply:GetRole()))
		
			target_ply:SetPos( pos )
			table.insert( affected_ply, target_ply )
		end
		ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned and teleported #T!", affected_ply )
		send_messages(affected_plys, "You have been respawned and teleported.")
	end
end
local respawntp = ulx.command( CATEGORY_NAME, "ulx respawntp", ulx.respawntp, "!respawntp")
respawntp:addParam{ type=ULib.cmds.PlayerArg }
respawntp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
respawntp:defaultAccess( ULib.ACCESS_SUPERADMIN )
respawntp:setOpposite( "ulx srespawntp", {_, _, true}, "!srespawntp", true )
respawntp:help( "Respawns <target> to a specific location." )
--[End]----------------------------------------------------------------------------------------



--[Karma]--------------------------------------------------------------------------------------
--[[ulx.karma][Sets the <target(s)> karma to a given amount.]
@param  {[PlayerObject]} calling_ply [The player who used the command.]
@param  {[PlayerObject]} target_plys [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       amount      [The number the target's karma will be set to.]
--]]
function ulx.karma( calling_ply, target_plys, amount )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
    	for i=1, #target_plys do
			target_plys[ i ]:SetBaseKarma( amount )
    	    target_plys[ i ]:SetLiveKarma( amount )
    	end	
  	end
	ulx.fancyLogAdmin( calling_ply, "#A set the karma for #T to #i", target_plys, amount )
end
local karma = ulx.command( CATEGORY_NAME, "ulx karma", ulx.karma, "!karma" )
karma:addParam{ type=ULib.cmds.PlayersArg }
karma:addParam{ type=ULib.cmds.NumArg, min=0, max=10000, default=1000, hint="Karma", ULib.cmds.optional, ULib.cmds.round }
karma:defaultAccess( ULib.ACCESS_ADMIN )
karma:help( "Changes the <target(s)> Karma." )
--[End]----------------------------------------------------------------------------------------

--[Drinks]--------------------------------------------------------------------------------------
--[[ulx.drinks][Sets the <target(s)> drinks to a given amount.]
@param  {[PlayerObject]} calling_ply [The player who used the command.]
@param  {[PlayerObject]} target_plys [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       d      	 [The number the target's drinks will be set to.]
@param  {[Number]}       s       	 [The number the target's shots will be set to.]
--]]
function ulx.drinks(calling_ply, target_plys, d, s)
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError(calling_ply, gamemode_error, true) else
		for i = 1, #target_plys do
			target_plys[i]:SetBaseDrinks(d)
			target_plys[i]:SetLiveDrinks(d)
			target_plys[i]:SetBaseShots(s)
			target_plys[i]:SetLiveShots(s)
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A set the drinks and shots for #T to #i and #i", target_plys, d, s)
end

local drinks = ulx.command(CATEGORY_NAME, "ulx drinks", ulx.drinks, "!drinks")
drinks:addParam { type = ULib.cmds.PlayersArg }
drinks:addParam { type = ULib.cmds.NumArg, min = 0, max = 100, default = 0, hint = "Drinks", ULib.cmds.optional, ULib.cmds.round }
drinks:addParam { type = ULib.cmds.NumArg, min = 0, max = 100, default = 0, hint = "Shots", ULib.cmds.optional, ULib.cmds.round }
drinks:defaultAccess(ULib.ACCESS_ADMIN)
drinks:help("Changes the <target(s)> drinks.")
--[End]----------------------------------------------------------------------------------------


--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces <target(s)> to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.tttspec( calling_ply, target_plys, should_unspec )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

	    for i=1, #target_plys do
			local v = target_plys[ i ]

			if should_unspec then
			    v:ConCommand("ttt_spectator_mode 0")
			else
			    v:Kill()
			    v:SetForceSpec(true)
			    v:SetTeam(TEAM_SPEC)
			    v:ConCommand("ttt_spectator_mode 1")
			    v:ConCommand("ttt_cl_idlepopup")
			end
	    end
	    if should_unspec then
	   		ulx.fancyLogAdmin( calling_ply, "#A has forced #T to join the world of the living next round.", target_plys )
	   	else
	    	ulx.fancyLogAdmin( calling_ply, "#A has forced #T to spectate.", target_plys )
	   	end
	end
end
local tttspec = ulx.command( CATEGORY_NAME, "ulx fspec", ulx.tttspec, "!fspec" )
tttspec:addParam{ type=ULib.cmds.PlayersArg }
tttspec:addParam{ type=ULib.cmds.BoolArg, invisible=true }
tttspec:defaultAccess( ULib.ACCESS_ADMIN )
tttspec:setOpposite( "ulx unspec", {_, _, true}, "!unspec" )
tttspec:help( "Forces the <target(s)> to/from spectator." )
--[End]----------------------------------------------------------------------------------------

------------------------------ Next Round  ------------------------------
ulx.next_round = {}
local function updateNextround()
	table.Empty( ulx.next_round ) -- Don't reassign so we don't lose our refs
	
	table.insert(ulx.next_round, "innocent") -- Add "innocent" to the table.
	table.insert(ulx.next_round, "traitor") -- Add "traitor" to the table.
	table.insert(ulx.next_round, "detective") -- Add "detective" to the table.
	table.insert(ulx.next_round, "mercenary") -- Add "mercenary" to the table.
	table.insert(ulx.next_round, "hypnotist") -- Add "hypnotist" to the table.
	table.insert(ulx.next_round, "glitch") -- Add "glitch" to the table.
	table.insert(ulx.next_round, "jester") -- Add "jester" to the table.
	table.insert(ulx.next_round, "phantom") -- Add "phantom" to the table.
	table.insert(ulx.next_round, "zombie") -- Add "zombie" to the table.
	table.insert(ulx.next_round, "vampire") -- Add "vampire" to the table.
	table.insert(ulx.next_round, "swapper") -- Add "swapper" to the table.
	table.insert(ulx.next_round, "assassin") -- Add "assassin" to the table.
	table.insert(ulx.next_round, "killer") -- Add "killer" to the table.
	table.insert(ulx.next_round, "emt") -- Add "emt" to the table.
	table.insert(ulx.next_round, "unmark") -- Add "unmark" to the table.

end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXNextRoundUpdate", updateNextround )
updateNextround() -- Init


local PlysMarkedForTraitor = {}
local PlysMarkedForDetective = {}
local PlysMarkedForMercenary = {}
local PlysMarkedForHypnotist = {}
local PlysMarkedForGlitch = {}
local PlysMarkedForJester = {}
local PlysMarkedForPhantom = {}
local PlysMarkedForZombie = {}
local PlysMarkedForVampire = {}
local PlysMarkedForSwapper = {}
local PlysMarkedForAssassin = {}
local PlysMarkedForKiller = {}
local PlysMarkedForInnocent = {}
local PlysMarkedForEMT = {}
function ulx.nextround( calling_ply, target_plys, next_round )
    if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
        local affected_plys = {}
        local unaffected_plys = {}
        for i=1, #target_plys do
            local v = target_plys[ i ]
            local ID = v:UniqueID()
        
            if next_round == "traitor" then
                if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
                    ULib.tsayError( calling_ply, "that player is already marked for the next round", true )
                else
                    PlysMarkedForTraitor[ID] = true
                    table.insert( affected_plys, v ) 
                end
            end
            if next_round == "detective" then
                if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
                    ULib.tsayError( calling_ply, "that player is already marked for the next round!", true )
                else
                    PlysMarkedForDetective[ID] = true
                    table.insert( affected_plys, v ) 
                end
            end
			if next_round == "mercenary" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForMercenary[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "hypnotist" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForHypnotist[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "glitch" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForGlitch[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "jester" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForJester[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "phantom" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForPhantom[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "zombie" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForZombie[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "vampire" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForVampire[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "swapper" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForSwapper[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "assassin" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForAssassin[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "killer" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForKiller[ID] = true
					table.insert(affected_plys, v)
				end
			end
			if next_round == "innocent" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForInnocent[ID] = true
					table.insert(affected_plys, v)
				end
			if next_round == "emt" then
				if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true or PlysMarkedForMercenary[ID] == true or PlysMarkedForHypnotist[ID] == true or PlysMarkedForGlitch[ID] == true or PlysMarkedForJester[ID] == true or PlysMarkedForPhantom[ID] == true or PlysMarkedForZombie[ID] == true or PlysMarkedForVampire[ID] == true or PlysMarkedForSwapper[ID] == true or PlysMarkedForAssassin[ID] == true or PlysMarkedForKiller[ID] == true or PlysMarkedForInnocent[ID] == true or PlysMarkedForEMT[ID] == true then
					ULib.tsayError(calling_ply, "that player is already marked for the next round!", true)
				else
					PlysMarkedForEMT[ID] = true
					table.insert(affected_plys, v)
				end
			end
            if next_round == "unmark" then
                if PlysMarkedForTraitor[ID] == true then
                    PlysMarkedForTraitor[ID] = false
                    table.insert( affected_plys, v )
                end
                if PlysMarkedForDetective[ID] == true then
                    PlysMarkedForDetective[ID] = false
                    table.insert( affected_plys, v )
                end
				if PlysMarkedForMercenary[ID] == true then
					PlysMarkedForMercenary[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForHypnotist[ID] == true then
					PlysMarkedForHypnotist[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForGlitch[ID] == true then
					PlysMarkedForGlitch[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForJester[ID] == true then
					PlysMarkedForJester[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForPhantom[ID] == true then
					PlysMarkedForPhantom[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForZombie[ID] == true then
					PlysMarkedForZombie[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForVampire[ID] == true then
					PlysMarkedForVampire[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForSwapper[ID] == true then
					PlysMarkedForSwapper[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForAssassin[ID] == true then
					PlysMarkedForAssassin[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForKiller[ID] == true then
					PlysMarkedForKiller[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForInnocent[ID] == true then
					PlysMarkedForInnocent[ID] = false
					table.insert(affected_plys, v)
				end
				if PlysMarkedForEMT[ID] == true then
					PlysMarkedForEMT[ID] = false
					table.insert(affected_plys, v)
				end
            end
        end    
        
        if next_round == "unmark" then
            ulx.fancyLogAdmin( calling_ply, true, "#A has unmarked #T ", affected_plys )
        else
            ulx.fancyLogAdmin( calling_ply, true, "#A marked #T to be #s next round.", affected_plys, next_round )
        end
    end
end        
local nxtr= ulx.command( CATEGORY_NAME, "ulx forcenr", ulx.nextround, "!nr" )
nxtr:addParam{ type=ULib.cmds.PlayersArg }
nxtr:addParam{ type=ULib.cmds.StringArg, completes=ulx.next_round, hint="Next Round", error="invalid role \"%s\" specified", ULib.cmds.restrictToCompletes }
nxtr:defaultAccess( ULib.ACCESS_SUPERADMIN )
nxtr:help( "Forces the target to be a role in the following round." )

local function TraitorMarkedPlayers()
	for k, v in pairs(PlysMarkedForTraitor) do
		if v then
			local ply = player.GetByUniqueID(k)
			ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_TRAITOR)
            ply:AddCredits(GetConVarNumber("ttt_credits_starting"))
			PlysMarkedForTraitor[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end
hook.Add("TTTSelectRoles", "Admin_Round_Traitor", TraitorMarkedPlayers)

local function DetectiveMarkedPlayers()
	for k, v in pairs(PlysMarkedForDetective) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_DETECTIVE)
			ply:AddCredits(GetConVarNumber("ttt_det_credits_starting"))
			PlysMarkedForDetective[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Detective", DetectiveMarkedPlayers)

local function MercenaryMarkedPlayers()
	for k, v in pairs(PlysMarkedForMercenary) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_MERCENARY)
			ply:AddCredits(GetConVarNumber("ttt_mer_credits_starting"))
			PlysMarkedForMercenary[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Mercenary", MercenaryMarkedPlayers)

local function HypnotistMarkedPlayers()
	for k, v in pairs(PlysMarkedForHypnotist) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_HYPNOTIST)
			ply:AddCredits(GetConVarNumber("ttt_hypno_credits_starting"))														   
			PlysMarkedForHypnotist[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
			ply:Give("weapon_hyp_brainwash")
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Hypnotist", HypnotistMarkedPlayers)

local function GlitchMarkedPlayers()
	for k, v in pairs(PlysMarkedForGlitch) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_GLITCH)
			PlysMarkedForGlitch[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Glitch", GlitchMarkedPlayers)

local function JesterMarkedPlayers()
	for k, v in pairs(PlysMarkedForJester) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_JESTER)
			PlysMarkedForJester[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Jester", JesterMarkedPlayers)

local function PhantomMarkedPlayers()
	for k, v in pairs(PlysMarkedForPhantom) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_PHANTOM)
			PlysMarkedForPhantom[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Phantom", PhantomMarkedPlayers)

local function ZombieMarkedPlayers()
	for k, v in pairs(PlysMarkedForZombie) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_ZOMBIE)
			PlysMarkedForZombie[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
			ply:Give("weapon_zom_claws")
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Zombie", ZombieMarkedPlayers)

local function VampireMarkedPlayers()
	for k, v in pairs(PlysMarkedForVampire) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_VAMPIRE)
			ply:AddCredits(GetConVarNumber("ttt_vamp_credits_starting"))
			PlysMarkedForVampire[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
			ply:Give("weapon_vam_fangs")
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Vampire", VampireMarkedPlayers)

local function SwapperMarkedPlayers()
	for k, v in pairs(PlysMarkedForSwapper) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_SWAPPER)
			PlysMarkedForSwapper[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Swapper", SwapperMarkedPlayers)

local function AssassinMarkedPlayers()
	for k, v in pairs(PlysMarkedForAssassin) do
		if v then
			local ply = player.GetByUniqueID(k)
            ply:SetMaxHealth(100)
            ply:SetHealth(100)
			ply:SetRole(ROLE_ASSASSIN)
			ply:AddCredits(GetConVarNumber("ttt_assin_credits_starting"))														   
			PlysMarkedForAssassin[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Assassin", AssassinMarkedPlayers)

local function KillerMarkedPlayers()
	for k, v in pairs(PlysMarkedForKiller) do
		if v then
			local ply = player.GetByUniqueID(k)
			ply:SetRole(ROLE_KILLER)
			ply:SetMaxHealth(150)
			ply:SetHealth(150)
			PlysMarkedForKiller[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Killer", KillerMarkedPlayers)

local function EMTMarkedPlayers()
	for k, v in pairs(PlysMarkedForEMT) do
		if v then
			local ply = player.GetByUniqueID(k)
			ply:SetRole(ROLE_EMT)
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
			PlysMarkedForEMT[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
			ply:Give("weapon_vam_fangs")
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_EMT", EMTMarkedPlayers)

local function InnocentMarkedPlayers()
	for k, v in pairs(PlysMarkedForInnocent) do
		if v then
			ply = player.GetByUniqueID(k)
			ply:SetRole(ROLE_INNOCENT)
			PlysMarkedForPhantom[k] = false
			if ply:HasWeapon("weapon_hyp_brainwash") then
				ply:StripWeapon("weapon_hyp_brainwash")
			end
			if ply:HasWeapon("weapon_vam_fangs") then
				ply:StripWeapon("weapon_vam_fangs")
			end
			if ply:HasWeapon("weapon_zom_claws") then
				ply:StripWeapon("weapon_zom_claws")
			end
			if ply:HasWeapon("weapon_emt_healray") then
				ply:StripWeapon("weapon_emt_healray")
			end
			if ply:HasWeapon("weapon_emt_brainwash") then
				ply:StripWeapon("weapon_emt_brainwash")
			end
		end
	end
end

hook.Add("TTTSelectRoles", "Admin_Round_Innocent", InnocentMarkedPlayers)

---[Identify Corpse Thanks Neku]----------------------------------------------------------------------------
function ulx.identify( calling_ply, target_ply, unidentify )
    if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
        local body = corpse_find( target_ply )
        if not body then ULib.tsayError( calling_ply, "This player's corpse does not exist!", true ) return end
 
        if not unidentify then
            ulx.fancyLogAdmin( calling_ply, "#A identified #T's body!", target_ply )
            CORPSE.SetFound( body, true )
            target_ply:SetNWBool("body_found", true)
            
            if target_ply:GetRole() == ROLE_TRAITOR then
                -- update innocent's list of traitors
                SendConfirmedTraitors(GetInnocentFilter(false))
                SCORE:HandleBodyFound( calling_ply, target_ply )
            end
            
        else
            ulx.fancyLogAdmin( calling_ply, "#A unidentified #T's body!", target_ply )
            CORPSE.SetFound( body, false )
            target_ply:SetNWBool("body_found", false)
            SendFullStateUpdate()
        end
    end    
end
local identify = ulx.command( CATEGORY_NAME, "ulx identify", ulx.identify, "!identify")
identify:addParam{ type=ULib.cmds.PlayerArg }
identify:addParam{ type=ULib.cmds.BoolArg, invisible=true }
identify:defaultAccess( ULib.ACCESS_SUPERADMIN )
identify:setOpposite( "ulx unidentify", {_, _, true}, "!unidentify", true )
identify:help( "Identifies a target's body." )
 
---[Remove Corpse Thanks Neku]----------------------------------------------------------------------------
function ulx.removebody( calling_ply, target_ply )
    if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
        local body = corpse_find( target_ply )
        if not body then ULib.tsayError( calling_ply, "This player's corpse does not exist!", true ) return end
        ulx.fancyLogAdmin( calling_ply, "#A removed #T's body!", target_ply )
        if string.find( body:GetModel(), "zm_", 6, true ) then
            body:Remove()
        elseif body.player_ragdoll then
            body:Remove()
        end
    end
end
local removebody = ulx.command( CATEGORY_NAME, "ulx removebody", ulx.removebody, "!removebody")
removebody:addParam{ type=ULib.cmds.PlayerArg }
removebody:defaultAccess( ULib.ACCESS_SUPERADMIN )
removebody:help( "Removes a target's body." )

---[Impair Next Round - Concpet and some code from Decicus next round slap]----------------------------------------------------------------------------
function ulx.inr( calling_ply, target_ply, amount )
	local chat_message = ""
    if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
    
        local ImpairBy = target_ply:GetPData("ImpairNR", 0 )
        
        if amount == 0 then
            target_ply:RemovePData("ImpairNR")
            chat_message = "#T was wrongly convicted. The fine has been removed."
        
        else
            
            if amount == ImpairBy then
                ULib.tsayError( calling_ply, calling_ply:Nick() .. " will already be impaired for that amount of health." )
            
            else
                
                target_ply:SetPData( "ImpairNR", amount )
                chat_message = "#T did the crime and they will pay the fine of " .. amount .. " health next round."
            
            end
        end    
    end
	ulx.fancyLogAdmin( calling_ply, chat_message, target_ply )
end
local impair = ulx.command( CATEGORY_NAME, "ulx impairnr", ulx.inr, "!impairnr" )
impair:addParam{ type=ULib.cmds.PlayerArg }
impair:addParam{ type=ULib.cmds.NumArg, min=0, max=99, default=5, hint="Amount of health to remove.", ULib.cmds.optional, ULib.cmds.round }
impair:defaultAccess( ULib.ACCESS_ADMIN )
impair:help( "Impair the targets health the following round. Set to 0 to remove impairment" )

---[impair Next Round Helper Functions ]----------------------------------------------------------------------------

hook.Add("PlayerSpawn", "InformImpair" , function(ply)

local ImpairDamage = tonumber(ply:GetPData("ImpairNR")) or 0
        
	if ply:Alive() and ImpairDamage > 0 then
		local chat_message = ""

		if ImpairDamage > 0 then
			chat_message = (chat_message .. "You did the crime and they will pay the fine of " .. ImpairDamage .. " health next round.")
		end
		ply:ChatPrint(chat_message)
	end
end)

function ImpairPlayers()
        
    for _, ply in ipairs( player.GetAll() ) do

        local impairDamage = tonumber( ply:GetPData( "ImpairNR" ) ) or 0
        
        if ply:Alive() and impairDamage > 0 then
            local name = ply:Nick()
            ply:TakeDamage(impairDamage)
            ply:EmitSound("player/pl_pain5.wav")
            ply:ChatPrint("You did the crime and they have paid the fine of " .. impairDamage .. " health.")
            ply:RemovePData( "ImpairNR" ) 
            ULib.tsay(nil, name .. " did the crime and they have paid the fine of " .. impairDamage .. " health.", false)
        end   

    end

end
hook.Add( "TTTBeginRound", "ImpairPlayers", ImpairPlayers )

---[Round Restart]-------------------------------------------------------------------------
function ulx.roundrestart( calling_ply )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		ULib.consoleCommand( "ttt_roundrestart" .. "\n" )
		ulx.fancyLogAdmin( calling_ply, "#A has restarted the round." )
	end
end
local restartround = ulx.command( CATEGORY_NAME, "ulx roundrestart", ulx.roundrestart )
restartround:defaultAccess( ULib.ACCESS_SUPERADMIN )
restartround:help( "Restarts the round." )
---[End]----------------------------------------------------------------------------------------
