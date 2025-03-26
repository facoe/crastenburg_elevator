ESX = nil
QBCore = nil
PlayerData = nil
PlayerJob = nil
PlayerGrade = nil

CreateThread(function()
	if Config.UseESX then
		ESX = exports["es_extended"]:getSharedObject()
		while not ESX.IsPlayerLoaded() do
					Wait(100)
			end

		PlayerData = ESX.GetPlayerData()
		PlayerJob = PlayerData.job.name
		PlayerGrade = PlayerData.job.grade

		RegisterNetEvent("esx:setJob", function(job)
			PlayerJob = job.name
			PlayerGrade = job.grade
		end)

	elseif Config.UseQBCore then

		QBCore = exports["qb-core"]:GetCoreObject()

		CreateThread(function()
			while true do
				PlayerData = QBCore.Functions.GetPlayerData()
				if PlayerData.citizenid ~= nil then
					PlayerJob = PlayerData.job.name
					PlayerGrade = PlayerData.job.grade.level
					break
				end
				Wait(100)
			end
		end)

		RegisterNetEvent("QBCore:Client:OnJobUpdate", function(job)
			PlayerJob = job.name
			PlayerGrade = job.grade.level
		end)
	end
end)

---------------------------

-- Función para verificar la distancia del jugador a un punto
local function isPlayerNear(coords, range)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= range
end

-- Función para cargar las IPLs de un piso
local function loadIplsForFloor(floor)
    if floor.level == "Piso 1" then
        loadEtage1()
    elseif floor.level == "Piso 2" then
        loadEtage2()
    elseif floor.level == "Piso 3" then
        loadEtage3()
    elseif floor.level == "Piso 4" then
        loadEtage4()
    elseif floor.level == "Piso 5" then
        loadEtage5()
    elseif floor.level == "Piso 6" then
        loadEtage6()
    elseif floor.level == "Piso 7" then
        loadEtage7()
    end
end

-- Hilo para gestionar la carga y descarga de IPLs dinámicamente
CreateThread(function()
    while true do
        Citizen.Wait(500) -- Reducir la frecuencia para optimizar el rendimiento

        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestFloor = nil
        local closestDistance = math.huge

        -- Encontrar el piso más cercano
        for elevatorName, elevatorFloors in pairs(Config.Elevators) do
            for _, floor in pairs(elevatorFloors) do
                local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, floor.coords.x, floor.coords.y, floor.coords.z)
                if distance < closestDistance then
                    closestDistance = distance
                    closestFloor = floor
                end
            end
        end

        -- Si el jugador está cerca de un piso y no está cargado
        if closestFloor and closestDistance <= 50.0 then -- Rango de 50 unidades
            if loadedEtage ~= closestFloor.level then
                UnloadIpl() -- Descargar todas las IPLs
                loadIplsForFloor(closestFloor) -- Cargar las IPLs del piso más cercano
                loadedEtage = closestFloor.level
            end
        elseif closestDistance > 50.0 and loadedEtage then
            -- Si el jugador se aleja, descargar las IPLs
            UnloadIpl()
            loadedEtage = nil
        end
    end
end)

----------------------------

CreateThread(function()
	if Config.UseThirdEye then
		for elevatorName, elevatorFloors in pairs(Config.Elevators) do
			for index, floor in pairs(elevatorFloors) do
				local string = tostring(elevatorName .. index)
				if Config.ThirdEyeName == 'ox_target' then
					local info = {}
					info.elevator = elevatorName
					info.level = index
					exports.ox_target:addBoxZone({
						coords = vec3(floor.coords.x, floor.coords.y, floor.coords.z),
						size = vec3(3, 3, 3),
						rotation = floor.heading,
						debug = drawZones,
						options = {
						{
							name = string,
							icon = "fas fa-hand-point-up",
							label = "Usar elevador desde " .. floor.level,
							onSelect = function()
							TriggerEvent("crastenburg_elevator:showFloors",info)
							end
						}
						}
					})
				else
					exports[Config.ThirdEyeName]:AddBoxZone(string, floor.coords, 3, 3, {
						name = elevatorName,
						heading = floor.heading,
						debugPoly = false,
						minZ = floor.coords.z - 1.5,
						maxZ = floor.coords.z + 1.5
					},
					{
						options = {
							{
								event = "crastenburg_elevator:showFloors",
								icon = "fas fa-hand-point-up",
								label = "Usar elevador desde " .. floor.level,
								elevator = elevatorName,
								level = index
							},
						},
						distance = 1.5
					})
				end
			end
		end
	end

	if Config.Notify.enabled then
		local wasNotified = false
		while true do
			local sleep = 3000
			local nearElevator = false
			local playerCoords = GetEntityCoords(PlayerPedId())
			for elevatorName, elevatorFloors in pairs(Config.Elevators) do
				for index, floor in pairs(elevatorFloors) do
					local distance = #(playerCoords - floor.coords)
					if distance <= 10.0 then
						sleep = 10
						if distance <= Config.Notify.distance then
							nearElevator = true
							break
						end
					end
				end
			end
			if nearElevator then
				if not wasNotified then
					NotifyHint()
					wasNotified = true
				end
			else
				wasNotified = false
			end
			Wait(sleep)
		end
	end
end)

CreateThread(function()
	if Config.Use3DText then
		for elevatorName, elevatorFloors in pairs(Config.Elevators) do
			for index, floor in pairs(elevatorFloors) do
				CreateThread(function()
					while true do
						local sleep = 2000
						local playerCoords = GetEntityCoords(PlayerPedId())
						local distance = #(playerCoords - floor.coords)
						if distance <= 3.0 then
							sleep = 0
							DrawText3Ds(floor.coords.x,floor.coords.y,floor.coords.z, "Press ~r~E~w~ to use Elevator From " .. floor.level)
							if distance <= 1.5 and IsControlJustReleased(0, 38) then
								local data = {}
								data.elevator = elevatorName
								data.level = index
								TriggerEvent('crastenburg_elevator:showFloors', data)
							end
						end
						Wait(sleep)
					end
				end)
			end
		end
	end
end)

RegisterNetEvent("crastenburg_elevator:showFloors", function(data)
	local elevator = {}
	local floor = {}
	if Config.UseESX then
		PlayerData = ESX.GetPlayerData()
	elseif Config.UseQBCore then
		PlayerData = QBCore.Functions.GetPlayerData()
	end
	for index, floor in pairs(Config.Elevators[data.elevator]) do
		if Config.NHMenu then
			table.insert(elevator, {
				header = floor.level,
				context = floor.label,
				disabled = isDisabled(index, floor, data),
				event = "crastenburg_elevator:movement",
				args = { floor }
			})
		elseif Config.QBMenu then
			table.insert(elevator, {
				header = floor.level,
				txt = floor.label,
				disabled = isDisabled(index, floor, data),
				params ={
					event = "crastenburg_elevator:movement",
					args = floor
					}
			})
		elseif Config.OXLib then
			table.insert(elevator, {
				label = floor.level..' - '..floor.label,
				args = { value = floor.coords, value2 = isDisabled(index, floor, data)}
			})
		end
	end
	if Config.NHMenu then
		TriggerEvent("nh-context:createMenu", elevator)
	elseif Config.QBMenu then
		TriggerEvent("qb-menu:client:openMenu", elevator)
	elseif Config.OXLib then
		lib.registerMenu({
			id = 'elevator_ox',
			title = 'Elevator Floor Selector',
			options = elevator,
			position = 'top-right',
		}, function(selected, scrollIndex, args)
			if not args.value2 then
				TriggerEvent("crastenburg_elevator:movement", args.value)
			else
				NotifyNoAccess()
			end
		end)
		lib.showMenu('elevator_ox')
	end

end)

RegisterNetEvent("crastenburg_elevator:movement", function(arg)
	local floor = {}
	if Config.OXLib then
		floor.coords = arg
	else
		floor = arg
	end
	local ped = PlayerPedId()
	DoScreenFadeOut(1500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	RequestCollisionAtCoord(floor.coords.x, floor.coords.y, floor.coords.z)
	while not HasCollisionLoadedAroundEntity(ped) do
		Wait(0)
	end
	SetEntityCoords(ped, floor.coords.x, floor.coords.y, floor.coords.z, false, false, false, false)
	SetEntityHeading(ped, floor.heading and floor.heading or 0.0)
	Wait(Config.ElevatorWaitTime*1000)
	DoScreenFadeIn(1500)
end)

function isDisabled(index, floor, data)
	if index == data.level then return true end
	if Config.UseESX then
		PlayerData = ESX.GetPlayerData()
	elseif Config.UseQBCore then
		PlayerData = QBCore.Functions.GetPlayerData()
	end
	local hasJob, hasItem = false, false
	if floor.jobs ~= nil and next(floor.jobs) then
		for jobName, gradeLevel in pairs(floor.jobs) do
			if PlayerJob == jobName and PlayerGrade >= gradeLevel then
				hasJob = true
				break
			end
		end
	end
	if floor.items ~= nil and next(floor.items) then
		if Config.UseESX then
			for i = 1, #floor.items, 1 do
				for k, v in ipairs(PlayerData.inventory) do
					if v.name == floor.items[i] and v.count > 0 then
						hasItem = true
						break
					end
				end
			end
		elseif Config.UseQBCore then
			for i = 1, #floor.items, 1 do
				for slot, item in pairs(PlayerData.items) do
					if PlayerData.items[slot] then
						if item.name == floor.items[i] then
							hasItem = true
							break
						end
					end
				end
			end
		end
	end
	if floor.jobs == nil and floor.items == nil then return false end
	return floor.jobAndItem and not (hasJob and hasItem) or not (hasJob or hasItem)
end

function NotifyHint()
	AddTextEntry('elevatorHelp', Config.Notify.message)
	BeginTextCommandDisplayHelp('elevatorHelp')
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function NotifyNoAccess()
	AddTextEntry('elevatorHelp', 'You cannot use this!')
	BeginTextCommandDisplayHelp('elevatorHelp')
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function DrawText3Ds(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	SetTextScale(0.30, 0.30)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry('STRING')
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end




function UnloadIpl()
	RemoveIpl('int_hotel_corridor01')
	RemoveIpl('int_hotel_doubleroom101')
	RemoveIpl('int_hotel_doubleroom102')
	RemoveIpl('int_hotel_doubleroom103')
	RemoveIpl('int_hotel_doubleroom104')
	RemoveIpl('int_hotel_doubleroom105')
	RemoveIpl('int_hotel_doubleroom106')
	RemoveIpl('int_hotel_room101')
	RemoveIpl('int_hotel_room102')
	RemoveIpl('int_hotel_room103')
	RemoveIpl('int_hotel_room104')
	RemoveIpl('int_hotel_room105')
	RemoveIpl('int_hotel_room106')
	RemoveIpl('int_hotel_room107')
	RemoveIpl('int_hotel_room108')
	RemoveIpl('int_hotel_room109')
	RemoveIpl('int_hotel_room110')
	RemoveIpl('int_hotel_room111')
	RemoveIpl('int_hotel_room112')
	RemoveIpl('int_hotel_room113')
	RemoveIpl('int_hotel_room114')
	RemoveIpl('int_hotel_room115')
	RemoveIpl('int_hotel_room116')
	RemoveIpl('int_hotel_room117')
	RemoveIpl('int_hotel_room118')
	RemoveIpl('int_hotel_room119')
	RemoveIpl('int_hotel_room120')
	RemoveIpl('int_hotel_room121')
	RemoveIpl('int_hotel_room122')
	RemoveIpl('int_hotel_room123')
	RemoveIpl('int_hotel_room124')
	
	RemoveIpl('int_hotel_corridor02')
	RemoveIpl('int_hotel_doubleroom201')
	RemoveIpl('int_hotel_doubleroom202')
	RemoveIpl('int_hotel_doubleroom203')
	RemoveIpl('int_hotel_doubleroom204')
	RemoveIpl('int_hotel_doubleroom205')
	RemoveIpl('int_hotel_doubleroom206')
	RemoveIpl('int_hotel_room201')
	RemoveIpl('int_hotel_room202')
	RemoveIpl('int_hotel_room203')
	RemoveIpl('int_hotel_room204')
	RemoveIpl('int_hotel_room205')
	RemoveIpl('int_hotel_room206')
	RemoveIpl('int_hotel_room207')
	RemoveIpl('int_hotel_room208')
	RemoveIpl('int_hotel_room209')
	RemoveIpl('int_hotel_room210')
	RemoveIpl('int_hotel_room211')
	RemoveIpl('int_hotel_room212')
	RemoveIpl('int_hotel_room213')
	RemoveIpl('int_hotel_room214')
	RemoveIpl('int_hotel_room215')
	RemoveIpl('int_hotel_room216')
	RemoveIpl('int_hotel_room217')
	RemoveIpl('int_hotel_room218')
	RemoveIpl('int_hotel_room219')
	RemoveIpl('int_hotel_room220')
	RemoveIpl('int_hotel_room221')
	RemoveIpl('int_hotel_room222')
	RemoveIpl('int_hotel_room223')
	RemoveIpl('int_hotel_room224')
	
	RemoveIpl('int_hotel_corridor03')
	RemoveIpl('int_hotel_doubleroom301')
	RemoveIpl('int_hotel_doubleroom302')
	RemoveIpl('int_hotel_doubleroom303')
	RemoveIpl('int_hotel_doubleroom304')
	RemoveIpl('int_hotel_doubleroom305')
	RemoveIpl('int_hotel_doubleroom306')
	RemoveIpl('int_hotel_room301')
	RemoveIpl('int_hotel_room302')
	RemoveIpl('int_hotel_room303')
	RemoveIpl('int_hotel_room304')
	RemoveIpl('int_hotel_room305')
	RemoveIpl('int_hotel_room306')
	RemoveIpl('int_hotel_room307')
	RemoveIpl('int_hotel_room308')
	RemoveIpl('int_hotel_room309')
	RemoveIpl('int_hotel_room310')
	RemoveIpl('int_hotel_room311')
	RemoveIpl('int_hotel_room312')
	RemoveIpl('int_hotel_room313')
	RemoveIpl('int_hotel_room314')
	RemoveIpl('int_hotel_room315')
	RemoveIpl('int_hotel_room316')
	RemoveIpl('int_hotel_room317')
	RemoveIpl('int_hotel_room318')
	RemoveIpl('int_hotel_room319')
	RemoveIpl('int_hotel_room320')
	RemoveIpl('int_hotel_room321')
	RemoveIpl('int_hotel_room322')
	RemoveIpl('int_hotel_room323')
	RemoveIpl('int_hotel_room324')
	
	RemoveIpl('int_hotel_corridor04')
	RemoveIpl('int_hotel_doubleroom401')
	RemoveIpl('int_hotel_doubleroom402')
	RemoveIpl('int_hotel_doubleroom403')
	RemoveIpl('int_hotel_doubleroom404')
	RemoveIpl('int_hotel_doubleroom405')
	RemoveIpl('int_hotel_doubleroom406')
	RemoveIpl('int_hotel_room401')
	RemoveIpl('int_hotel_room402')
	RemoveIpl('int_hotel_room403')
	RemoveIpl('int_hotel_room404')
	RemoveIpl('int_hotel_room405')
	RemoveIpl('int_hotel_room406')
	RemoveIpl('int_hotel_room407')
	RemoveIpl('int_hotel_room408')
	RemoveIpl('int_hotel_room409')
	RemoveIpl('int_hotel_room410')
	RemoveIpl('int_hotel_room411')
	RemoveIpl('int_hotel_room412')
	RemoveIpl('int_hotel_room413')
	RemoveIpl('int_hotel_room414')
	RemoveIpl('int_hotel_room415')
	RemoveIpl('int_hotel_room416')
	RemoveIpl('int_hotel_room417')
	RemoveIpl('int_hotel_room418')
	RemoveIpl('int_hotel_room419')
	RemoveIpl('int_hotel_room420')
	RemoveIpl('int_hotel_room421')
	RemoveIpl('int_hotel_room422')
	RemoveIpl('int_hotel_room423')
	RemoveIpl('int_hotel_room424')
	
	RemoveIpl('int_hotel_corridor05')
	RemoveIpl('int_hotel_doubleroom501')
	RemoveIpl('int_hotel_doubleroom502')
	RemoveIpl('int_hotel_doubleroom503')
	RemoveIpl('int_hotel_doubleroom504')
	RemoveIpl('int_hotel_doubleroom505')
	RemoveIpl('int_hotel_doubleroom506')
	RemoveIpl('int_hotel_room501')
	RemoveIpl('int_hotel_room502')
	RemoveIpl('int_hotel_room503')
	RemoveIpl('int_hotel_room504')
	RemoveIpl('int_hotel_room505')
	RemoveIpl('int_hotel_room506')
	RemoveIpl('int_hotel_room507')
	RemoveIpl('int_hotel_room508')
	RemoveIpl('int_hotel_room509')
	RemoveIpl('int_hotel_room510')
	RemoveIpl('int_hotel_room511')
	RemoveIpl('int_hotel_room512')
	RemoveIpl('int_hotel_room513')
	RemoveIpl('int_hotel_room514')
	RemoveIpl('int_hotel_room515')
	RemoveIpl('int_hotel_room516')
	RemoveIpl('int_hotel_room517')
	RemoveIpl('int_hotel_room518')
	RemoveIpl('int_hotel_room519')
	RemoveIpl('int_hotel_room520')
	RemoveIpl('int_hotel_room521')
	RemoveIpl('int_hotel_room522')
	RemoveIpl('int_hotel_room523')
	RemoveIpl('int_hotel_room524')
	
	RemoveIpl('int_hotel_corridor06')
	RemoveIpl('int_hotel_doubleroom601')
	RemoveIpl('int_hotel_doubleroom602')
	RemoveIpl('int_hotel_doubleroom603')
	RemoveIpl('int_hotel_doubleroom604')
	RemoveIpl('int_hotel_doubleroom605')
	RemoveIpl('int_hotel_doubleroom606')
	RemoveIpl('int_hotel_room601')
	RemoveIpl('int_hotel_room602')
	RemoveIpl('int_hotel_room603')
	RemoveIpl('int_hotel_room604')
	RemoveIpl('int_hotel_room605')
	RemoveIpl('int_hotel_room606')
	RemoveIpl('int_hotel_room607')
	RemoveIpl('int_hotel_room608')
	RemoveIpl('int_hotel_room609')
	RemoveIpl('int_hotel_room610')
	RemoveIpl('int_hotel_room611')
	RemoveIpl('int_hotel_room612')
	RemoveIpl('int_hotel_room613')
	RemoveIpl('int_hotel_room614')
	RemoveIpl('int_hotel_room615')
	RemoveIpl('int_hotel_room616')
	RemoveIpl('int_hotel_room617')
	RemoveIpl('int_hotel_room618')
	RemoveIpl('int_hotel_room619')
	RemoveIpl('int_hotel_room620')
	RemoveIpl('int_hotel_room621')
	RemoveIpl('int_hotel_room622')
	RemoveIpl('int_hotel_room623')
	RemoveIpl('int_hotel_room624')
	
	RemoveIpl('int_hotel_corridor07')
	RemoveIpl('int_hotel_doubleroom701')
	RemoveIpl('int_hotel_doubleroom702')
	RemoveIpl('int_hotel_doubleroom703')
	RemoveIpl('int_hotel_doubleroom704')
	RemoveIpl('int_hotel_doubleroom705')
	RemoveIpl('int_hotel_doubleroom706')
	RemoveIpl('int_hotel_room701')
	RemoveIpl('int_hotel_room702')
	RemoveIpl('int_hotel_room703')
	RemoveIpl('int_hotel_room704')
	RemoveIpl('int_hotel_room705')
	RemoveIpl('int_hotel_room706')
	RemoveIpl('int_hotel_room707')
	RemoveIpl('int_hotel_room708')
	RemoveIpl('int_hotel_room709')
	RemoveIpl('int_hotel_room710')
	RemoveIpl('int_hotel_room711')
	RemoveIpl('int_hotel_room712')
	RemoveIpl('int_hotel_room713')
	RemoveIpl('int_hotel_room714')
	RemoveIpl('int_hotel_room715')
	RemoveIpl('int_hotel_room716')
	RemoveIpl('int_hotel_room717')
	RemoveIpl('int_hotel_room718')
	RemoveIpl('int_hotel_room719')
	RemoveIpl('int_hotel_room720')
	RemoveIpl('int_hotel_room721')
	RemoveIpl('int_hotel_room722')
	RemoveIpl('int_hotel_room723')
	RemoveIpl('int_hotel_room724')
end

function loadEtage1()
	RequestIpl('int_hotel_corridor01')
	RequestIpl('int_hotel_doubleroom101')
	RequestIpl('int_hotel_doubleroom102')
	RequestIpl('int_hotel_doubleroom103')
	RequestIpl('int_hotel_doubleroom104')
	RequestIpl('int_hotel_doubleroom105')
	RequestIpl('int_hotel_doubleroom106')
	RequestIpl('int_hotel_room101')
	RequestIpl('int_hotel_room102')
	RequestIpl('int_hotel_room103')
	RequestIpl('int_hotel_room104')
	RequestIpl('int_hotel_room105')
	RequestIpl('int_hotel_room106')
	RequestIpl('int_hotel_room107')
	RequestIpl('int_hotel_room108')
	RequestIpl('int_hotel_room109')
	RequestIpl('int_hotel_room110')
	RequestIpl('int_hotel_room111')
	RequestIpl('int_hotel_room112')
	RequestIpl('int_hotel_room113')
	RequestIpl('int_hotel_room114')
	RequestIpl('int_hotel_room115')
	RequestIpl('int_hotel_room116')
	RequestIpl('int_hotel_room117')
	RequestIpl('int_hotel_room118')
	RequestIpl('int_hotel_room119')
	RequestIpl('int_hotel_room120')
	RequestIpl('int_hotel_room121')
	RequestIpl('int_hotel_room122')
	RequestIpl('int_hotel_room123')
	RequestIpl('int_hotel_room124')
end

function loadEtage2()
	RequestIpl('int_hotel_corridor02')
	RequestIpl('int_hotel_doubleroom201')
	RequestIpl('int_hotel_doubleroom202')
	RequestIpl('int_hotel_doubleroom203')
	RequestIpl('int_hotel_doubleroom204')
	RequestIpl('int_hotel_doubleroom205')
	RequestIpl('int_hotel_doubleroom206')
	RequestIpl('int_hotel_room201')
	RequestIpl('int_hotel_room202')
	RequestIpl('int_hotel_room203')
	RequestIpl('int_hotel_room204')
	RequestIpl('int_hotel_room205')
	RequestIpl('int_hotel_room206')
	RequestIpl('int_hotel_room207')
	RequestIpl('int_hotel_room208')
	RequestIpl('int_hotel_room209')
	RequestIpl('int_hotel_room210')
	RequestIpl('int_hotel_room211')
	RequestIpl('int_hotel_room212')
	RequestIpl('int_hotel_room213')
	RequestIpl('int_hotel_room214')
	RequestIpl('int_hotel_room215')
	RequestIpl('int_hotel_room216')
	RequestIpl('int_hotel_room217')
	RequestIpl('int_hotel_room218')
	RequestIpl('int_hotel_room219')
	RequestIpl('int_hotel_room220')
	RequestIpl('int_hotel_room221')
	RequestIpl('int_hotel_room222')
	RequestIpl('int_hotel_room223')
	RequestIpl('int_hotel_room224')
end

function loadEtage3()
	RequestIpl('int_hotel_corridor03')
	RequestIpl('int_hotel_doubleroom301')
	RequestIpl('int_hotel_doubleroom302')
	RequestIpl('int_hotel_doubleroom303')
	RequestIpl('int_hotel_doubleroom304')
	RequestIpl('int_hotel_doubleroom305')
	RequestIpl('int_hotel_doubleroom306')
	RequestIpl('int_hotel_room301')
	RequestIpl('int_hotel_room302')
	RequestIpl('int_hotel_room303')
	RequestIpl('int_hotel_room304')
	RequestIpl('int_hotel_room305')
	RequestIpl('int_hotel_room306')
	RequestIpl('int_hotel_room307')
	RequestIpl('int_hotel_room308')
	RequestIpl('int_hotel_room309')
	RequestIpl('int_hotel_room310')
	RequestIpl('int_hotel_room311')
	RequestIpl('int_hotel_room312')
	RequestIpl('int_hotel_room313')
	RequestIpl('int_hotel_room314')
	RequestIpl('int_hotel_room315')
	RequestIpl('int_hotel_room316')
	RequestIpl('int_hotel_room317')
	RequestIpl('int_hotel_room318')
	RequestIpl('int_hotel_room319')
	RequestIpl('int_hotel_room320')
	RequestIpl('int_hotel_room321')
	RequestIpl('int_hotel_room322')
	RequestIpl('int_hotel_room323')
	RequestIpl('int_hotel_room324')
end

function loadEtage4()
	RequestIpl('int_hotel_corridor04')
	RequestIpl('int_hotel_doubleroom401')
	RequestIpl('int_hotel_doubleroom402')
	RequestIpl('int_hotel_doubleroom403')
	RequestIpl('int_hotel_doubleroom404')
	RequestIpl('int_hotel_doubleroom405')
	RequestIpl('int_hotel_doubleroom406')
	RequestIpl('int_hotel_room401')
	RequestIpl('int_hotel_room402')
	RequestIpl('int_hotel_room403')
	RequestIpl('int_hotel_room404')
	RequestIpl('int_hotel_room405')
	RequestIpl('int_hotel_room406')
	RequestIpl('int_hotel_room407')
	RequestIpl('int_hotel_room408')
	RequestIpl('int_hotel_room409')
	RequestIpl('int_hotel_room410')
	RequestIpl('int_hotel_room411')
	RequestIpl('int_hotel_room412')
	RequestIpl('int_hotel_room413')
	RequestIpl('int_hotel_room414')
	RequestIpl('int_hotel_room415')
	RequestIpl('int_hotel_room416')
	RequestIpl('int_hotel_room417')
	RequestIpl('int_hotel_room418')
	RequestIpl('int_hotel_room419')
	RequestIpl('int_hotel_room420')
	RequestIpl('int_hotel_room421')
	RequestIpl('int_hotel_room422')
	RequestIpl('int_hotel_room423')
	RequestIpl('int_hotel_room424')
end

function loadEtage5()
	RequestIpl('int_hotel_corridor05')
	RequestIpl('int_hotel_doubleroom501')
	RequestIpl('int_hotel_doubleroom502')
	RequestIpl('int_hotel_doubleroom503')
	RequestIpl('int_hotel_doubleroom504')
	RequestIpl('int_hotel_doubleroom505')
	RequestIpl('int_hotel_doubleroom506')
	RequestIpl('int_hotel_room501')
	RequestIpl('int_hotel_room502')
	RequestIpl('int_hotel_room503')
	RequestIpl('int_hotel_room504')
	RequestIpl('int_hotel_room505')
	RequestIpl('int_hotel_room506')
	RequestIpl('int_hotel_room507')
	RequestIpl('int_hotel_room508')
	RequestIpl('int_hotel_room509')
	RequestIpl('int_hotel_room510')
	RequestIpl('int_hotel_room511')
	RequestIpl('int_hotel_room512')
	RequestIpl('int_hotel_room513')
	RequestIpl('int_hotel_room514')
	RequestIpl('int_hotel_room515')
	RequestIpl('int_hotel_room516')
	RequestIpl('int_hotel_room517')
	RequestIpl('int_hotel_room518')
	RequestIpl('int_hotel_room519')
	RequestIpl('int_hotel_room520')
	RequestIpl('int_hotel_room521')
	RequestIpl('int_hotel_room522')
	RequestIpl('int_hotel_room523')
	RequestIpl('int_hotel_room524')
end

function loadEtage6()
	RequestIpl('int_hotel_corridor06')
	RequestIpl('int_hotel_doubleroom601')
	RequestIpl('int_hotel_doubleroom602')
	RequestIpl('int_hotel_doubleroom603')
	RequestIpl('int_hotel_doubleroom604')
	RequestIpl('int_hotel_doubleroom605')
	RequestIpl('int_hotel_doubleroom606')
	RequestIpl('int_hotel_room601')
	RequestIpl('int_hotel_room602')
	RequestIpl('int_hotel_room603')
	RequestIpl('int_hotel_room604')
	RequestIpl('int_hotel_room605')
	RequestIpl('int_hotel_room606')
	RequestIpl('int_hotel_room607')
	RequestIpl('int_hotel_room608')
	RequestIpl('int_hotel_room609')
	RequestIpl('int_hotel_room610')
	RequestIpl('int_hotel_room611')
	RequestIpl('int_hotel_room612')
	RequestIpl('int_hotel_room613')
	RequestIpl('int_hotel_room614')
	RequestIpl('int_hotel_room615')
	RequestIpl('int_hotel_room616')
	RequestIpl('int_hotel_room617')
	RequestIpl('int_hotel_room618')
	RequestIpl('int_hotel_room619')
	RequestIpl('int_hotel_room620')
	RequestIpl('int_hotel_room621')
	RequestIpl('int_hotel_room622')
	RequestIpl('int_hotel_room623')
	RequestIpl('int_hotel_room624')
end

function loadEtage7()
	RequestIpl('int_hotel_corridor07')
	RequestIpl('int_hotel_doubleroom701')
	RequestIpl('int_hotel_doubleroom702')
	RequestIpl('int_hotel_doubleroom703')
	RequestIpl('int_hotel_doubleroom704')
	RequestIpl('int_hotel_doubleroom705')
	RequestIpl('int_hotel_doubleroom706')
	RequestIpl('int_hotel_room701')
	RequestIpl('int_hotel_room702')
	RequestIpl('int_hotel_room703')
	RequestIpl('int_hotel_room704')
	RequestIpl('int_hotel_room705')
	RequestIpl('int_hotel_room706')
	RequestIpl('int_hotel_room707')
	RequestIpl('int_hotel_room708')
	RequestIpl('int_hotel_room709')
	RequestIpl('int_hotel_room710')
	RequestIpl('int_hotel_room711')
	RequestIpl('int_hotel_room712')
	RequestIpl('int_hotel_room713')
	RequestIpl('int_hotel_room714')
	RequestIpl('int_hotel_room715')
	RequestIpl('int_hotel_room716')
	RequestIpl('int_hotel_room717')
	RequestIpl('int_hotel_room718')
	RequestIpl('int_hotel_room719')
	RequestIpl('int_hotel_room720')
	RequestIpl('int_hotel_room721')
	RequestIpl('int_hotel_room722')
	RequestIpl('int_hotel_room723')
	RequestIpl('int_hotel_room724')
end







