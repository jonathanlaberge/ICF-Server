AchievementList = {
	SKR1000 = {
		title = "Seeking Champion",
		desc = "Catch 1000 players through-out your seeking career.",
		prog = true,
		times = 1000
	},
	SBMISSN = {
		title = "Submission",
		desc = "As a seeker, have a hider run into you.",
		prog = false
	},
	HCROWD = {
		title = "Three's a Crowd",
		desc = "As a hider, win a round with 2 or more other hiders close-by.",
		prog = false
	},
	PKUPBIKE = {
		title = "A Wise Man Once Said",
		desc = "RED! This isn't the time to use that!",
		prog = false
	},
	LASTMAN = {
		title = "Last Man Hiding",
		desc = "Win a round as the last hider. ( 4+ players )",
		prog = false
	},
	TOPPLYR = {
		title = "Top Player",
		desc = "Be announced as the top scorer 10 times. ( 4+ players )",
		prog = true,
		times = 10
	},
	CLSECALL = {
		title = "Close Call",
		desc = "As a seeker, end the round by catching a hider in the last 10 seconds.",
		prog = false
	},
	HEALTHY = {
		title = "Stayin' Healthy",
		desc = "Get a helping of nutritious goods from the market.",
		prog = false
	},
	ROOTED = {
		title = "Rooted",
		desc = "As a hider, survive a round by not setting foot out of your hiding spot.",
		prog = false
	},
	MTIS = {
		title = "Mario the Italian Seeker",
		desc = "As a seeker, catch a hider Mario style.",
		prog = false
	},
	FRNDSCHR = {
		title = "Friend Snatcher",
		desc = "As a seeker, catch 3 friends in a single round.",
		prog = false
	},
	TNQHDING = {
		title = "Hiding in Tranquillity",
		desc = "Wait for a total of 5 hours in your hiding career.",
		prog = true,
		times = 18000
	},
	CONVOST = {
		title = "Conversationalist",
		desc = "As a hider, let the seekers know they're bad by talking a lot.",
		prog = false
	},
	TCKLEFGHT = {
		title = "Magic Words",
		desc = "Starts out fun, ends in tears.",
		prog = false
	},
	WAYTHRO = {
		title = "Another Way Through",
		desc = "As a seeker, break something to hastily catch a hider.",
		prog = false
	},
	RBRLEGS = {
		title = "Rubber Legs",
		desc = "Break your legs 50 times.",
		prog = true,
		times = 50
	}
}

game.AddParticles("particles/explosion.pcf")
PrecacheParticleSystem("bday_confetti")
PrecacheParticleSystem("bday_confetti_colors")