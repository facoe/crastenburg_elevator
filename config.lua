Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true					-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseThirdEye = true				-- If true uses third eye.
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication
Config.Use3DText = false                        -- Use 3D text to interact
Config.NHMenu = false						-- Use NH-Context [https://github.com/whooith/nh-context]
Config.QBMenu = true						-- Use QB-Menu (Ignored if Config.NHInput = true) [https://github.com/qbcore-framework/qb-menu]
Config.OXLib = false						-- Use the OX_lib (Ignored if Config.NHInput or Config.QBInput = true) [https://github.com/overextended/ox_lib] !! must add shared_script '@ox_lib/init.lua' and lua54 'yes' to fxmanifest!!
Config.ElevatorWaitTime = 1					-- How many seconds until the player arrives at their floor

Config.Notify = {
	enabled = false,							-- Display hint notification?
	distance = 3.0,							-- Distance from elevator that the hint will show
	message = "Target the elevator to use"	-- Text of the hint notification
}

--[[
	USAGE
	To add an elevator, copy the table below and configure as needed:
		coords = vector3 coords of center of elevator
		heading = Direction facing out of the elevator
		level = What floor are they going to
		label = What is on that floor
		jobs = OPTIONAL: Table of job keys that are allowed to access that floor and value of minimum grade of each job
		items = Opcional: cualquier elemento que se requiere para acceder a ese piso (solo requiere uno de los elementos enumerados)
		jobAndItem = OPTIONAL: If true, you must you have a required job AND a required items. If false or nil no items are needed
	
]]

--[[
	ExampleElevator = {	
		{
			coords = vector3(xxx, yyy, zzz), heading = 0.0, level = "Floor 2", label = "Roof",
			jobs = { ["police"] = 0, ["ambulance"] = 0, ["casino"] = 0 },
			items = { "casino_pass_bronze", "casino_pass_silver", "casino_pass_gold" }
		},
		{
			coords = vector3(xxx, yyy, zzz), heading = 0.0, level = "Floor 1", label = "Penthouse",
			jobs = { ["police"] = 0, ["ambulance"] = 0, ["casino"] = 0 },
			items = { "casino_pass_gold" },
			jobAndItem = true
		},
		{
			coords = vector3(xxx, yyy, zzz), heading = 0.0, level = "Floor 0", label = "Ground"
		},
	},
]]

Config.Elevators = {
	
	CrastenburgA = {
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 71.79), heading = 169.59108, level = "Piso 7", label = "701-730", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 67.79), heading = 169.59108, level = "Piso 6", label = "601-630", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 63.79), heading = 169.59108, level = "Piso 5", label = "501-530", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 59.79), heading = 169.59108, level = "Piso 4", label = "401-430", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 55.79), heading = 169.59108, level = "Piso 3", label = "301-330", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 51.79), heading = 169.59108, level = "Piso 2", label = "201-230", 
		},
		{
			coords = vector3(-1203.1069335938, -190.87379455566, 47.79), heading = 169.59108, level = "Piso 1", label = "101-130", 
		},
		{
			coords = vector3(-1196.890, -173.294, 39.315), heading = 169.59108, level = "Piso 0", label = "Lobby", 
		},
	},
	CrastenburgB = {
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 71.79), heading = 169.59108, level = "Piso 7", label = "701-730", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 67.79), heading = 169.59108, level = "Piso 6", label = "601-630", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 63.79), heading = 169.59108, level = "Piso 5", label = "501-530", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 59.79), heading = 169.59108, level = "Piso 4", label = "401-430", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 55.79), heading = 169.59108, level = "Piso 3", label = "301-330", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 51.79), heading = 169.59108, level = "Piso 2", label = "201-230", 
		},
		{
			coords = vector3(-1204.8363037109, -188.37803649902, 47.79), heading = 169.59108, level = "Piso 1", label = "101-130", 
		},
		{
			coords = vector3(-1195.536, -170.591, 39.315), heading = 169.59108, level = "Piso 0", label = "Lobby", 
		},
	},
	CrastenburgC = {
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 71.79), heading = 169.59108, level = "Piso 7", label = "701-730", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 67.79), heading = 169.59108, level = "Piso 6", label = "601-630", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 63.79), heading = 169.59108, level = "Piso 5", label = "501-530", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 59.79), heading = 169.59108, level = "Piso 4", label = "401-430", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 55.79), heading = 169.59108, level = "Piso 3", label = "301-330", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 51.79), heading = 169.59108, level = "Piso 2", label = "201-230", 
		},
		{
			coords = vector3(-1199.1802978516, -184.08113098145, 47.79), heading = 169.59108, level = "Piso 1", label = "101-130", 
		},
		{
			coords = vector3(-1189.130, -173.914, 39.315), heading = 169.59108, level = "Piso 0", label = "Lobby", 
		},
	},
	CrastenburgD = {
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 71.79), heading = 169.59108, level = "Piso 7", label = "701-730", 
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 67.79), heading = 169.59108, level = "Piso 6", label = "601-630",
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 63.79), heading = 169.59108, level = "Piso 5", label = "501-530", 
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 59.79), heading = 169.59108, level = "Piso 4", label = "401-430", 
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 55.79), heading = 169.59108, level = "Piso 3", label = "301-330", 
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 51.79), heading = 169.59108, level = "Piso 2", label = "201-230", 
		},
		{
			coords = vector3(-1197.4893798828, -186.58154296875, 47.79), heading = 169.59108, level = "Piso 1", label = "101-130", 
		},
		{
			coords = vector3(-1190.521, -176.579, 38.315), heading = 169.59108, level = "Piso 0", label = "Lobby", 
		},
	},
}
