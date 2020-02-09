ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		for i, v in pairs (Config.Insurance) do
			local station = Config.Insurance[i]
			local dist = GetDistanceBetweenCoords(station.Pos, coords, true)
			if dist <= 10.0 then
				DrawMarker(27, station.Pos, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 235, 0, 0, 100, 0, 0, 0, 1)
				if dist <= 1.5 then
					SetTextComponentFormat('STRING')
					AddTextComponentString(_U('press_button'))
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
					if IsControlJustPressed(0, 38) then
						if IsPedInAnyVehicle(GetPlayerPed(-1)) then
						else
							MenuInsurance(station.Name)
						end
					end
				end
			end
		end
	end
end)

function MenuInsurance(station)
	ESX.UI.Menu.CloseAll()
	ESX.TriggerServerCallback('flux_insurance:check', function(insTime)
		if insTime ~= nil  then
			ESX.ShowNotification(_U('ins_time', station, insTime))
		else
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_sell',
			{
				title    = _U('buy_ins', station),
				align    = 'center',
				elements = {
					{label = _U('3_days'),	value = 3},
					{label = _U('7_days'),	value = 7},
					{label = _U('14_days'),	value = 14},
					{label = _U('31_days'),	value = 31},
				}
			}, function(data, menu)
				TriggerServerEvent('flux_insurance:sell', station, data.current.value)
				menu.close()
			   end,
			function(data, menu)
				menu.close()
			end
			)
		end
	end, station)
end