Jonathan1358LibLoaded = false
if (SERVER) then
	AddCSLuaFile()
	local files, folders = file.Find("jonathan_modules/*", "LUA")
	for k,v in pairs(files) do
		include("jonathan_modules/" .. v)
		AddCSLuaFile("jonathan_modules/" .. v)
	end

	MsgC(Color(255,255,255), "\n\n\n\n\n ----- " ,Color(255,255,0), " Jonathan1358: Server side " ,Color(255,255,255), " ----- \n\n")
	MsgC(Color(255,255,255), "[Jonathan1358] Legend: ", Color(45,155,255), "Server ", Color(45,255,45), "Shared ", Color(255,165,45), "Client\n" )
	MsgC(Color(255,255,255), "██████" ,Color(45,255,45), " Shared " ,Color(255,255,255), "█████████████████████████████████████████████████████████████████\n")
	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." then continue end

		for _, File in SortedPairs(file.Find("jonathan_modules/" .. folder .."/sh_*.lua", "LUA"), true) do
			MsgC( Color(45,255,45), "   [Jonathan1358] Loading SHARED: " .. "/jonathan1358/lua/jonathan_modules/" .. folder .. "/" ..File .. "\n" )
			AddCSLuaFile("jonathan_modules/" .. folder .. "/" ..File)
			include("jonathan_modules/" .. folder .. "/" ..File)
		end
	end
	MsgC(Color(255,255,255), "██████" ,Color(45,155,255), " Server " ,Color(255,255,255), "█████████████████████████████████████████████████████████████████\n")
	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." then continue end

		for _, File in SortedPairs(file.Find("jonathan_modules/" .. folder .."/sv_*.lua", "LUA"), true) do
			MsgC( Color(45,155,255), "   [Jonathan1358] Loading SERVER: " .. "/jonathan1358/lua/jonathan_modules/" .. folder .. "/" ..File .. "\n" )
			include("jonathan_modules/" .. folder .. "/" ..File)
		end
	end
	MsgC(Color(255,255,255), "██████" ,Color(255,165,45), " Client " ,Color(255,255,255), "█████████████████████████████████████████████████████████████████\n")
	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." then continue end

		for _, File in SortedPairs(file.Find("jonathan_modules/" .. folder .."/cl_*.lua", "LUA"), true) do
			MsgC( Color(255,165,45), "   [Jonathan1358] Loading CLIENT: " .. "/jonathan1358/lua/jonathan_modules/" .. folder .. "/" ..File .. "\n" )
			AddCSLuaFile("jonathan_modules/" .. folder .. "/" ..File)
		end
	end
	MsgC(Color(255,255,255), "█████████████████████████████████████████████████████████████████████████████████\n")
	MsgC(Color(255,255,255), "[Jonathan1358] Legend: ", Color(45,155,255), "Server ", Color(45,255,45), "Shared ", Color(255,165,45), "Client\n" )
	MsgC(Color(0,255,0), "[Jonathan1358] Done\n" )
else
	local files, folders = file.Find("jonathan_modules/*", "LUA")
	for k,v in pairs(files) do
		include("jonathan_modules/" .. v)
	end
	MsgC(Color(255,255,255), "\n\n\n\n\n ----- " ,Color(50,255,255), " Jonathan1358: Client side " ,Color(255,255,255), " ----- \n\n")
	MsgC(Color(255,255,255), "[Jonathan1358] Legend: ", Color(45,155,255), "Server ", Color(45,255,45), "Shared ", Color(255,165,45), "Client\n" )
	MsgC(Color(255,255,255), "██████" ,Color(45,255,45), " Shared " ,Color(255,255,255), "█████████████████████████████████████████████████████████████████\n")
	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." then continue end

		for _, File in SortedPairs(file.Find("jonathan_modules/" .. folder .."/sh_*.lua", "LUA"), true) do
			MsgC( Color(45,255,45), "   [Jonathan1358] Loading SHARED: " .. "/jonathan1358/lua/jonathan_modules/" .. folder .. "/" ..File .. "\n" )
			include("jonathan_modules/" .. folder .. "/" ..File)
		end
	end
	MsgC(Color(255,255,255), "██████" ,Color(255,165,45), " Client " ,Color(255,255,255), "█████████████████████████████████████████████████████████████████\n")
	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." then continue end

		for _, File in SortedPairs(file.Find("jonathan_modules/" .. folder .."/cl_*.lua", "LUA"), true) do
			MsgC( Color(255,165,45), "   [Jonathan1358] Loading CLIENT: " .. "/jonathan1358/lua/jonathan_modules/" .. folder .. "/" ..File .. "\n" )
			include("jonathan_modules/" .. folder .. "/" ..File)
		end
	end
	MsgC(Color(255,255,255), "█████████████████████████████████████████████████████████████████████████████████\n")
	MsgC(Color(255,255,255), "[Jonathan1358] Legend: ", Color(45,155,255), "Server ", Color(45,255,45), "Shared ", Color(255,165,45), "Client\n" )
	MsgC(Color(0,255,0), "[Jonathan1358] Done\n" )
end
Jonathan1358LibLoaded = true