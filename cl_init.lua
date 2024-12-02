function GetCardinalDirection()
	local camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
    local playerHeadingDegrees = 360.0 - ( ( camRot.z + 360.0 ) % 360.0 )
    local tickDegree = playerHeadingDegrees - 180 / 2
    local tickDegreeRemainder = 9.0 - ( tickDegree % 9.0 )
   
    tickDegree = tickDegree + tickDegreeRemainder
    return tickDegree
end

function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if ( dgr >= 0.0 and dgr < 22.5 ) or dgr >= 337.5 then
		return " E "
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "SE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return " S "
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SW"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return " W "
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "NW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return " N "
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NE"
	end
end

do
    local street
    local direction
    local zone
    local time = exports.sample_util:GetHudColor() .. "Time: ~w~12:00pm"

    local labelCache = {}
    function GetLabel( name )
        if not labelCache[name] then
            labelCache[name] = GetLabelText( name )
        end

        return labelCache[name]
    end

    Citizen.CreateThread( function()
        while true do
            local p = PlayerPedId()
            local c = GetEntityCoords( p )

            zone = GetLabel( GetNameOfZone( c.x, c.y, c.z ) )
            direction = degreesToIntercardinalDirection( GetCardinalDirection() )
            street = GetStreetNameFromHashKey( GetStreetNameAtCoord( c.x, c.y, c.z ) )

            local hours = GetClockHours()
            local timeType = "am"

            if hours == 0 then
                hours = 12
            elseif hours > 12 then
                timeType = "pm"
                hours = hours - 12
            end

            time = ("%d:%02d"):format( hours, GetClockMinutes() ) .. timeType 

            Citizen.Wait( 250 )
        end
    end )

    Citizen.CreateThread( function()
        while true do
            exports.sample_util:DrawTextRightOfMinimap( exports.sample_util:GetHudColor() .. "Time: ~w~" .. time, 0.0, 0.10, 0.4 )

            local directionText = "| " .. exports.sample_util:GetHudColor() .. direction .. " ~w~|"

            exports.sample_util:DrawTextRightOfMinimap( directionText, 0.0, 0.115, 0.95 )

            exports.sample_util:DrawText( "discord.gg/floridasrp", 1.0, 0.0, 0.4, 2 )

            exports.sample_util:DrawTextRightOfMinimap( street, 0.0475, 0.12, 0.4 )
            exports.sample_util:DrawTextRightOfMinimap( zone, 0.0475, 0.14, 0.4 )

            Citizen.Wait( 0 )
        end
    end )
end