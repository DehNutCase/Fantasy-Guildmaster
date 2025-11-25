extends Node

const actions = {
}

const rating_breakpoints = [
	["S", 5000], 
	["A", 1000], 
	["B", 500], 
	["C", 250], 
	["D", 50], 
	["E", 0]
]

const quests = {
	"dragon_hunt": {
		"type": "Hunt",
		"target": "Dragon(s)",
		"quest_stats" : {
			"Atk": 4000.0,
			"Def": 8000.0,
			"Mag": 4000.0,
			"Res": 8000.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_highdora.png"),
	},
	"dumpling_hunt": {
		"type": "Hunt",
		"target": "Dumpling(s)",
		"quest_stats" : {
			"Atk": 10.0,
			"Def": 20.0,
			"Mag": 50.0,
			"Res": 20.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/s_manju.png"),
	},
	"unicorn_capture": {
		"type": "Capture",
		"target": "Unicorn(s)",
		"quest_stats" : {
			"Atk": 0.0,
			"Def": 0.0,
			"Mag": 0.0,
			"Res": 0.0,
			"Spd": 1500.0,
			"Luk": 1500.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_MiniUnicorn.png"),
	},
	"sword_smithing": {
		"type": "Smith",
		"target": "Sword(s)",
		"quest_stats" : {
			"Atk": 0.0,
			"Def": 500.0,
			"Mag": 0.0,
			"Res": 0.0,
			"Spd": 500.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/alchemy03_01.png"),
	},
	"package_delivery": {
		"type": "Deliver",
		"target": "Package(s)",
		"quest_stats" : {
			"Atk": 0.0,
			"Def": 10.0,
			"Mag": 0.0,
			"Res": 10.0,
			"Spd": 500.0,
			"Luk": 10.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/box01_01.png"),
	},
	"bat_hunt": {
		"type": "Hunt",
		"target": "Bat(s)",
		"quest_stats" : {
			"Atk": 30.0,
			"Def": 30.0,
			"Mag": 200.0,
			"Res": 200.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_Batn.png"),
	},
	"hedgehog_hunt": {
		"type": "Hunt",
		"target": "Hedgehog(s)",
		"quest_stats" : {
			"Atk": 1000.0,
			"Def": 1000.0,
			"Mag": 50.0,
			"Res": 50.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_J_Hedgehog.png"),
	},
	"knight_spar": {
		"type": "Spar With",
		"target": "Knight(s)",
		"quest_stats" : {
			"Atk": 1000.0,
			"Def": 100.0,
			"Mag": 1000.0,
			"Res": 100.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_Knight.png"),
	},
	"skeleton_hunt": {
		"type": "Hunt",
		"target": "Skeleton(s)",
		"quest_stats" : {
			"Atk": 100.0,
			"Def": 100.0,
			"Mag": 100.0,
			"Res": 100.0,
			"Spd": 0.0,
			"Luk": 0.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/f_MinionsA.png"),
	},
	"herb_gather": {
		"type": "Gather",
		"target": "Herb(s)",
		"quest_stats" : {
			"Atk": 0.0,
			"Def": 0.0,
			"Mag": 0.0,
			"Res": 0.0,
			"Spd": 500.0,
			"Luk": 500.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/herb6_01.png"),
	},
	"ore_gather": {
		"type": "Gather",
		"target": "Ore(s)",
		"quest_stats" : {
			"Atk": 0.0,
			"Def": 0.0,
			"Mag": 0.0,
			"Res": 0.0,
			"Spd": 500.0,
			"Luk": 500.0,
		},
		"icon": preload("res://assets/sprites/quest_icons/ore01_01.png"),
	},
}

const adventurers = {
	"hero_m": {
		"name": "Hero (M)",
		"stats" : {
			"Atk": 750,
			"Def": 1100,
			"Mag": 800,
			"Res": 750,
			"Spd": 1100,
			"Luk": 800,
		},
		"growth_rate": {
			"Atk": .5,
			"Def": .5,
			"Mag": .5,
			"Res": .5,
			"Spd": .5,
			"Luk": .5,
		},
		"icon": preload("res://assets/sprites/adventurer_icons/M_Brave_01.png"),
	},
	"hero_f": {
		"name": "Hero (F)",
		"stats" : {
			"Atk": 1200,
			"Def": 400,
			"Mag": 1200,
			"Res": 350,
			"Spd": 600,
			"Luk": 600,
		},
		"growth_rate": {
			"Atk": .5,
			"Def": .5,
			"Mag": .5,
			"Res": .5,
			"Spd": .5,
			"Luk": .5,
		},
		"icon": preload("res://assets/sprites/adventurer_icons/F_Brave_01.png"),
	},
	"adventurer_m": {
		"name": "Adventurer (M)",
		"stats" : {
			"Atk": 450,
			"Def": 450,
			"Mag": 450,
			"Res": 450,
			"Spd": 450,
			"Luk": 450,
		},
		"growth_rate": {
			"Atk": 1.0,
			"Def": 1.0,
			"Mag": 1.0,
			"Res": 1.0,
			"Spd": 1.0,
			"Luk": 1.0,
		},
		"icon": preload("res://assets/sprites/adventurer_icons/002tf_adventurer_blue_male_A.png"),
	},
	"adventurer_f": {
		"name": "Adventurer (F)",
		"stats" : {
			"Atk": 650,
			"Def": 250,
			"Mag": 650,
			"Res": 250,
			"Spd": 250,
			"Luk": 650,
		},
		"growth_rate": {
			"Atk": 1.0,
			"Def": 1.0,
			"Mag": 1.0,
			"Res": 1.0,
			"Spd": 1.0,
			"Luk": 1.0,
		},
		"icon": preload("res://assets/sprites/adventurer_icons/001tf_adventurer_female_A.png"),
	},
	"apprentice_witch": {
		"name": "Apprentice Witch",
		"stats" : {
			"Atk": 10,
			"Def": 10,
			"Mag": 100,
			"Res": 50,
			"Spd": 50,
			"Luk": 2000,
		},
		"growth_rate": {
			"Atk": 2,
			"Def": 2,
			"Mag": 2,
			"Res": 2,
			"Spd": 2,
			"Luk": 2,
		},
		"icon": preload("res://assets/sprites/adventurer_icons/exp_01_000.png"),
	},
}

const music = {
	"default" = preload("res://addons/maaacks_game_template/assets/music/8Bit Mini Gamer Loop.wav"),
	"boss" = preload("res://addons/maaacks_game_template/assets/music/8Bit Adventure Loop.wav"),
	"victory" = preload("res://addons/maaacks_game_template/assets/music/Hollywood Star Loop.wav"),
	"defeat" = preload("res://addons/maaacks_game_template/assets/music/8Bit Tragic Mistake Loop.wav"),
}

const constants = {
	"PROGRESS_BAR_MULTIPLIER" = 100, #Multiply quest card progress bar max value and changes by this factor, used to make progress more granular to allow time slowdowns
	"STAT_ORDER" = ["Atk", "Def", "Mag", "Res", "Spd", "Luk"],
}

const stats = {
	"atk": {
		"label": "Atk",
		"color": Color.ORANGE
	},
	"def": {
		"label": "Def",
		"color": Color.LIGHT_SEA_GREEN,
	},
	"mag": {
		"label": "Mag",
		"color": Color.BLUE,
	},
	"res": {
		"label": "Res",
		"color": Color.BLUE_VIOLET
	},
	"spd": {
		"label": "Spd",
		"color": Color.GREEN
	},
	"luk": {
		"label": "Luk",
		"color": Color.YELLOW
	},
}
