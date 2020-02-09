ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

RegisterServerEvent('flux_insurance:delete')
AddEventHandler('flux_insurance:delete', function(identifier, iType)
	MySQL.Async.execute('DELETE FROM user_licenses WHERE type = @type AND owner = @owner', 
	{
		['@type'] = iType,
		['@owner'] = identifier
	}, function(rowsChanged)
		print("Insurance deleted")
	end)
end)

RegisterServerEvent('flux_insurance:sell')
AddEventHandler('flux_insurance:sell', function(station, hLong)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetIdentifier = xPlayer.identifier
	local iType = ""
	
	if station == "NNW" then
		iType = "ems_insurance"
	elseif station == "OC" then
		iType = "oc_insurance"
	end
	
	local year1 = round(os.date('%Y'),0)
	local month1 = round(os.date('%m'),0)
	local day1 = round(os.date('%d')+hLong,0)
	local hour1 = round(os.date('%H'),0)
	local minutes1 = round(os.date('%M'),0)
	local seconds1 = round(os.date('%S'),0)
	local mTime = {year = year1, month = month1, day = day1, hour = hour1, min = minutes1, sec = seconds1}
	local dt = os.time(mTime)
	
	local needMoney
	if hLong == 3 then
		needMoney = 5000
	elseif hLong == 7 then
		needMoney = 10000
	elseif hLong == 14 then
		needMoney = 20000
	elseif hLong == 31 then
		needMoney = 40000
	end
	
	if xPlayer.getMoney() >= needMoney then
		MySQL.Sync.execute("INSERT INTO user_licenses (type, label, owner, time) VALUES (@type, @label, @owner, @time)", 
		{
			['@type'] = iType,
			['@label'] = _U('insurance', station),
			['@owner'] = targetIdentifier,
			['@time'] = dt
		})
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('bought_ins', station, hLong))
		xPlayer.removeMoney(needMoney)
		local fraction
		if station == "NNW" then
			fraction = 'ambulance'
		elseif station == "OC" then
			fraction = 'mecano'
		end
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. fraction, function(account)
			account.addMoney(needMoney)
		end)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enought'))
	end
end)

ESX.RegisterServerCallback('flux_insurance:check',function(source, cb, station)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier
	local iType = ""
	
	if station == "NNW" then
		iType = "ems_insurance"
	elseif station == "OC" then
		iType = "oc_insurance"
	end
	
	MySQL.Async.fetchAll(
		'SELECT time as timestamp FROM user_licenses WHERE owner = @owner AND type = @type',
		{ 
			['@owner'] = identifier,
			['@type'] = iType,
		},
		function(result)
			if result[1] ~= nil then
				local tr = tostring(result[1].timestamp)
				local fromUnix = os.date('%Y-%m-%d %H:%M:%S', tr)
				cb(fromUnix)
			else
				cb(nil)
			end
		end
	)
end)

function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function CheckUb(d, h, m)
	print("----- FluX_Insurance -----")
	local iType1 = "ems_insurance"
	local iType2 = "oc_insurance"
	MySQL.Async.fetchAll('SELECT owner, type, time as timestamp FROM user_licenses WHERE type = @type or type = @type2', 
		{
			['@type'] = iType1,
			['@type2'] = iType2
		}, 
		function(result)
			local nowTime = os.time()
			for i=1, #result, 1 do
				local aboTime = result[i].timestamp
				if aboTime <= nowTime then
					TriggerEvent('flux_insurance:delete', result[i].owner, result[i].type)
				end
			end
		end
	)
end

TriggerEvent('cron:runAt', 02, 0, CheckUb)
TriggerEvent('cron:runAt', 04, 0, CheckUb)
TriggerEvent('cron:runAt', 12, 0, CheckUb)
TriggerEvent('cron:runAt', 14, 0, CheckUb)
TriggerEvent('cron:runAt', 16, 0, CheckUb)
TriggerEvent('cron:runAt', 18, 0, CheckUb)
TriggerEvent('cron:runAt', 20, 0, CheckUb)
TriggerEvent('cron:runAt', 22, 0, CheckUb)
TriggerEvent('cron:runAt', 24, 0, CheckUb)