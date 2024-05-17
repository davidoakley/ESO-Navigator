local Utils = MapSearch.Utils

local Data = {}

-- Hardcoded lookup of all fast travel nodes in all zones =(

local _zoneNodeLookup = {

    [  3] = { -- Glenumbra
        { poiIndex = 26, nodeIndex = 1,   name = "Wyrd Tree Wayshrine", traders_cnt = 1, },
        { poiIndex = 27, nodeIndex = 2,   name = "Aldcroft Wayshrine" },
        { poiIndex = 28, nodeIndex = 3,   name = "Deleyn's Mill Wayshrine" },
        { poiIndex = 29, nodeIndex = 4,   name = "Eagle's Brook Wayshrine" },
        { poiIndex = 30, nodeIndex = 5,   name = "North Hag Fen Wayshrine" },
        { poiIndex = 31, nodeIndex = 6,   name = "Lion Guard Redoubt Wayshrine", traders_cnt = 1, },
        { poiIndex = 32, nodeIndex = 7,   name = "Crosswych Wayshrine" },
        { poiIndex = 33, nodeIndex = 8,   name = "Farwatch Wayshrine" },
        { poiIndex = 34, nodeIndex = 20,  name = "Baelborne Rock Wayshrine" },
        { poiIndex = 35, nodeIndex = 62,  name = "Daggerfall Wayshrine", traders_cnt = 5, },
        { poiIndex = 36, nodeIndex = 64,  name = "Burial Tombs Wayshrine" },
        { poiIndex = 42, nodeIndex = 193, name = "Dungeon: Spindleclutch I" },
        { poiIndex = 46, nodeIndex = 212, name = "The Harborage" },
        { poiIndex = 65, nodeIndex = 216, name = "Hag Fen Wayshrine" },
        { poiIndex = 66, nodeIndex = 267, name = "Dungeon: Spindleclutch II" },
        { poiIndex = 67, nodeIndex = 297, name = "Captain Margaux's Place" },
        { poiIndex = 68, nodeIndex = 289, name = "The Rosy Lion" },
        { poiIndex = 69, nodeIndex = 292, name = "Daggerfall Overlook" },
        { poiIndex = 70, nodeIndex = 342, name = "Exorcised Coven Cottage" },
        { poiIndex = 71, nodeIndex = 470, name = "Dungeon: Red Petal Bastion", },

    },
    [ 19] = { -- Stormhaven
        { poiIndex = 20, nodeIndex = 189, name = "Dungeon: Wayrest Sewers I" },
        { poiIndex = 22, nodeIndex = 14,  name = "Koeglin Village Wayshrine", traders_cnt = 1, },
        { poiIndex = 23, nodeIndex = 15,  name = "Alcaire Castle Wayshrine" },
        { poiIndex = 24, nodeIndex = 16,  name = "Firebrand Keep Wayshrine", traders_cnt = 1, },
        { poiIndex = 25, nodeIndex = 22,  name = "Wind Keep Wayshrine" },
        { poiIndex = 26, nodeIndex = 23,  name = "Dro-Dara Plantation Wayshrine" },
        { poiIndex = 27, nodeIndex = 18,  name = "Soulshriven Wayshrine" },
        { poiIndex = 28, nodeIndex = 19,  name = "Pariah Abbey Wayshrine" },
        { poiIndex = 35, nodeIndex = 31,  name = "Weeping Giant Wayshrine" },
        { poiIndex = 42, nodeIndex = 56,  name = "Wayrest Wayshrine", traders_cnt = 7, },
        { poiIndex = 43, nodeIndex = 17,  name = "Bonesnap Ruins Wayshrine" },
        { poiIndex = 62, nodeIndex = 263, name = "Dungeon: Wayrest Sewers II" },
        { poiIndex = 64, nodeIndex = 318, name = "Gardner House" },
        { poiIndex = 65, nodeIndex = 302, name = "Hammerdeath Bungalow" },
        { poiIndex = 66, nodeIndex = 363, name = "Dungeon: Scalecaller Peak" },

    },
    [ 20] = { -- Rivenspire
        { poiIndex = 17, nodeIndex = 190, name = "Dungeon: Crypt of Hearts I" },
        { poiIndex = 18, nodeIndex = 9,   name = "Oldgate Wayshrine", traders_cnt = 1, },
        { poiIndex = 19, nodeIndex = 10,  name = "Crestshade Wayshrine" },
        { poiIndex = 20, nodeIndex = 11,  name = "Tamrith Camp Wayshrine", },       
        { poiIndex = 22, nodeIndex = 12,  name = "Boralis Wayshrine" },
        { poiIndex = 23, nodeIndex = 13,  name = "Staging Grounds Wayshrine" },
        { poiIndex = 24, nodeIndex = 82,  name = "Northpoint Wayshrine" },
        { poiIndex = 25, nodeIndex = 83,  name = "Fell's Run Wayshrine" },
        { poiIndex = 26, nodeIndex = 84,  name = "Hoarfrost Downs Wayshrine", traders_cnt = 1, },
        { poiIndex = 27, nodeIndex = 55,  name = "Shornhelm Wayshrine", traders_cnt = 5, },
        { poiIndex = 37, nodeIndex = 86,  name = "Sanguine Barrows Wayshrine" },
        { poiIndex = 41, nodeIndex = 208, name = "Shrouded Pass Wayshrine" },
        { poiIndex = 58, nodeIndex = 269, name = "Dungeon: Crypt of Hearts II" },
        { poiIndex = 59, nodeIndex = 307, name = "Ravenhurst" },
        { poiIndex = 60, nodeIndex = 409, name = "Wraithhome" },
        { poiIndex = 61, nodeIndex = 498, name = "Dungeon: Shipwright's Regret", },

    },
    [ 41] = { -- Stonefalls
        { poiIndex = 20, nodeIndex = 65,  name = "Davon's Watch Wayshrine", traders_cnt = 1, },
        { poiIndex = 21, nodeIndex = 66,  name = "Othrenis Wayshrine" },
        { poiIndex = 22, nodeIndex = 41,  name = "Fort Arand Wayshrine" },
        { poiIndex = 23, nodeIndex = 67,  name = "Ebonheart Wayshrine", traders_cnt = 5, },
        { poiIndex = 24, nodeIndex = 68,  name = "Vivec's Antlers Wayshrine" },
        { poiIndex = 25, nodeIndex = 71,  name = "Brothers of Strife Wayshrine" },
        { poiIndex = 26, nodeIndex = 72,  name = "Hrogar's Hold Wayshrine" },
        { poiIndex = 27, nodeIndex = 73,  name = "Fort Virak Wayshrine" },
        { poiIndex = 28, nodeIndex = 74,  name = "Iliath Temple Wayshrine" },
        { poiIndex = 29, nodeIndex = 75,  name = "Sathram Plantation Wayshrine" },
        { poiIndex = 30, nodeIndex = 76,  name = "Kragenmoor Wayshrine", traders_cnt = 1, },
        { poiIndex = 31, nodeIndex = 77,  name = "Ashen Road Wayshrine" },
        { poiIndex = 34, nodeIndex = 98,  name = "Dungeon: Fungal Grotto I" },
        { poiIndex = 39, nodeIndex = 69,  name = "Sulfur Pools Wayshrine" },
        { poiIndex = 40, nodeIndex = 108, name = "Senie Wayshrine" },
        { poiIndex = 46, nodeIndex = 212, name = "The Harborage" },
        { poiIndex = 66, nodeIndex = 266, name = "Dungeon: Fungal Grotto II" },
        { poiIndex = 67, nodeIndex = 298, name = "Kragenhome" },
        { poiIndex = 68, nodeIndex = 290, name = "The Ebony Flask Inn Room" },
        { poiIndex = 69, nodeIndex = 293, name = "Ebonheart Chateau" },
        { poiIndex = 70, nodeIndex = 531, name = "Dungeon: Bal Sunnar", },

    },
    [ 57] = { -- Deshaan
        { poiIndex = 21, nodeIndex = 198, name = "Dungeon: Darkshade Caverns I" },
        { poiIndex = 22, nodeIndex = 24,  name = "West Narsis Wayshrine" },
        { poiIndex = 23, nodeIndex = 25,  name = "Muth Gnaar Hills Wayshrine", traders_cnt = 1, },
        { poiIndex = 24, nodeIndex = 26,  name = "Quarantine Serk Wayshrine" },
        { poiIndex = 25, nodeIndex = 27,  name = "Ghost Snake Vale Wayshrine" },
        { poiIndex = 26, nodeIndex = 28,  name = "Mournhold Wayshrine", traders_cnt = 7, },
        { poiIndex = 27, nodeIndex = 29,  name = "Tal'Deic Grounds Wayshrine", traders_cnt = 1, },
        { poiIndex = 28, nodeIndex = 30,  name = "Obsidian Gorge Wayshrine" },
        { poiIndex = 29, nodeIndex = 32,  name = "Mzithumz Wayshrine" },
        { poiIndex = 30, nodeIndex = 79,  name = "Selfora Wayshrine" },
        { poiIndex = 31, nodeIndex = 80,  name = "Silent Mire Wayshrine" },
        { poiIndex = 32, nodeIndex = 81,  name = "Eidolon's Hollow Wayshrine" },
        { poiIndex = 43, nodeIndex = 205, name = "Shad Astula Wayshrine" },
        { poiIndex = 60, nodeIndex = 264, name = "Dungeon: Darkshade Caverns II" },
        { poiIndex = 61, nodeIndex = 319, name = "Quondam Indorilia" },
        { poiIndex = 62, nodeIndex = 309, name = "Velothi Reverie" },
        { poiIndex = 63, nodeIndex = 287, name = "Flaming Nix Deluxe Garret" },
        { poiIndex = 64, nodeIndex = 454, name = "Dungeon: The Cauldron" },

    },
    [ 58] = { -- Malabal Tor
        { poiIndex = 2, nodeIndex = 101,  name = "Dra'bul Wayshrine", traders_cnt = 1, },
        { poiIndex = 3, nodeIndex = 99,   name = "Ilayas Ruins Wayshrine" },
        { poiIndex = 4, nodeIndex = 102,  name = "Velyn Harbor Wayshrine" },
        { poiIndex = 5, nodeIndex = 100,  name = "Vulkwasten Wayshrine" },
        { poiIndex = 6, nodeIndex = 104,  name = "Abamath Wayshrine" },
        { poiIndex = 7, nodeIndex = 105,  name = "Wilding Vale Wayshrine" },
        { poiIndex = 8, nodeIndex = 106,  name = "Baandari Post Wayshrine", traders_cnt = 5, },
        { poiIndex = 9, nodeIndex = 103,  name = "Bloodtoil Valley Wayshrine" },
        { poiIndex = 10, nodeIndex = 107, name = "Valeguard Wayshrine", traders_cnt = 1, },
        { poiIndex = 41, nodeIndex = 188, name = "Dungeon: Tempest Island" },
        { poiIndex = 60, nodeIndex = 294, name = "Black Vine Villa" },
        { poiIndex = 61, nodeIndex = 299, name = "Cyrodilic Jungle House" },
        { poiIndex = 62, nodeIndex = 485, name = "Doomchar Plateau", },

    },
    [ 92] = { -- Bangkorai
        { poiIndex = 19, nodeIndex = 33,  name = "Evermore Wayshrine", traders_cnt = 5, },
        { poiIndex = 20, nodeIndex = 34,  name = "Troll's Toothpick Wayshrine" },
        { poiIndex = 21, nodeIndex = 35,  name = "Viridian Woods Wayshrine" },
        { poiIndex = 22, nodeIndex = 36,  name = "Bangkorai Pass Wayshrine", traders_cnt = 1, },
        { poiIndex = 23, nodeIndex = 37,  name = "Nilata Ruins Wayshrine" },
        { poiIndex = 24, nodeIndex = 38,  name = "Hallin's Stand Wayshrine", traders_cnt = 1, },
        { poiIndex = 25, nodeIndex = 39,  name = "Old Tower Wayshrine" },
        { poiIndex = 26, nodeIndex = 40,  name = "Onsi's Breath Wayshrine" },
        { poiIndex = 27, nodeIndex = 63,  name = "Sunken Road Wayshrine" },
        { poiIndex = 36, nodeIndex = 186, name = "Dungeon: Blackheart Haven" },
        { poiIndex = 40, nodeIndex = 204, name = "Eastern Evermore Wayshrine" },
        { poiIndex = 41, nodeIndex = 206, name = "Halcyon Lake Wayshrine" },
        { poiIndex = 61, nodeIndex = 323, name = "Forsaken Stronghold" },
        { poiIndex = 62, nodeIndex = 313, name = "Mournoth Keep" },
        { poiIndex = 63, nodeIndex = 303, name = "Twin Arches" },
        { poiIndex = 64, nodeIndex = 341, name = "Dungeon: Fang Lair" },
        { poiIndex = 65, nodeIndex = 425, name = "Dungeon: Unhallowed Grave" },
        { poiIndex = 66, nodeIndex = 427, name = "Thieves' Oasis" },

    },
    [101] = { -- Eastmarch
        { poiIndex = 14, nodeIndex = 87,  name = "Windhelm Wayshrine", traders_cnt = 5, },
        { poiIndex = 15, nodeIndex = 88,  name = "Fort Morvunskar Wayshrine" },
        { poiIndex = 16, nodeIndex = 89,  name = "Kynesgrove Wayshrine" },
        { poiIndex = 17, nodeIndex = 90,  name = "Voljar Meadery Wayshrine", traders_cnt = 1, },
        { poiIndex = 18, nodeIndex = 91,  name = "Cradlecrush Wayshrine" },
        { poiIndex = 19, nodeIndex = 92,  name = "Fort Amol Wayshrine", traders_cnt = 1, },
        { poiIndex = 20, nodeIndex = 93,  name = "Wittestadr Wayshrine" },
        { poiIndex = 21, nodeIndex = 94,  name = "Mistwatch Wayshrine" },
        { poiIndex = 22, nodeIndex = 95,  name = "Jorunn's Stand Wayshrine" },
        { poiIndex = 23, nodeIndex = 96,  name = "Logging Camp Wayshrine" },
        { poiIndex = 24, nodeIndex = 97,  name = "Skuldafn Wayshrine" },
        { poiIndex = 41, nodeIndex = 195, name = "Dungeon: Direfrost Keep" },
        { poiIndex = 58, nodeIndex = 312, name = "Grymharth's Woe" },
        { poiIndex = 59, nodeIndex = 380, name = "Enchanted Snow Globe Home" },
        { poiIndex = 60, nodeIndex = 389, name = "Dungeon: Frostvault" },
        { poiIndex = 61, nodeIndex = 392, name = "Frostvault Chasm" },

    },
    [103] = { -- The Rift
        { poiIndex = 14, nodeIndex = 109, name = "Riften Wayshrine" },
        { poiIndex = 15, nodeIndex = 110, name = "Skald's Retreat Wayshrine", traders_cnt = 5, },
        { poiIndex = 16, nodeIndex = 111, name = "Trolhetta Wayshrine" },
        { poiIndex = 17, nodeIndex = 112, name = "Trolhetta Summit Wayshrine" },
        { poiIndex = 23, nodeIndex = 113, name = "Honrich Tower Wayshrine" },
        { poiIndex = 24, nodeIndex = 114, name = "Fallowstone Hall Wayshrine", traders_cnt = 1, },
        { poiIndex = 25, nodeIndex = 115, name = "Northwind Mine Wayshrine" },
        { poiIndex = 26, nodeIndex = 116, name = "Geirmund's Hall Wayshrine" },
        { poiIndex = 27, nodeIndex = 117, name = "Taarengrav Wayshrine" },
        { poiIndex = 28, nodeIndex = 118, name = "Nimalten Wayshrine", traders_cnt = 1, },
        { poiIndex = 29, nodeIndex = 119, name = "Ragged Hills Wayshrine" },
        { poiIndex = 30, nodeIndex = 120, name = "Fullhelm Fort Wayshrine" },
        { poiIndex = 42, nodeIndex = 187, name = "Dungeon: Blessed Crucible" },
        { poiIndex = 61, nodeIndex = 322, name = "Old Mistveil Manor" },
        { poiIndex = 62, nodeIndex = 301, name = "Autumn's-Gate" },
        { poiIndex = 63, nodeIndex = 372, name = "Hunter's Glade" },
        { poiIndex = 64, nodeIndex = 532, name = "Dungeon: Scrivener's Hall", },

    },
    [104] = { -- Alik'r Desert
        { poiIndex = 17, nodeIndex = 42,  name = "Morwha's Bounty Wayshrine", traders_cnt = 1, },
        { poiIndex = 18, nodeIndex = 43,  name = "Sentinel Wayshrine", traders_cnt = 5, },
        { poiIndex = 19, nodeIndex = 44,  name = "Bergama Wayshrine", traders_cnt = 1, },
        { poiIndex = 20, nodeIndex = 45,  name = "Leki's Blade Wayshrine" },
        { poiIndex = 21, nodeIndex = 46,  name = "Satakalaam Wayshrine" },
        { poiIndex = 29, nodeIndex = 57,  name = "Divad's Chagrin Mine Wayshrine" },
        { poiIndex = 30, nodeIndex = 58,  name = "Kulati Mines Wayshrine" },
        { poiIndex = 31, nodeIndex = 59,  name = "Aswala Stables Wayshrine" },
        { poiIndex = 32, nodeIndex = 137, name = "Sep's Spine Wayshrine" },
        { poiIndex = 34, nodeIndex = 60,  name = "Shrikes' Aerie Wayshrine" },
        { poiIndex = 35, nodeIndex = 61,  name = "HoonDing's Watch Wayshrine" },
        { poiIndex = 42, nodeIndex = 196, name = "Dungeon: Volenfell" },
        { poiIndex = 43, nodeIndex = 155, name = "Goat's Head Oasis Wayshrine" },
        { poiIndex = 62, nodeIndex = 286, name = "Sisters of the Sands Apartment" },
        { poiIndex = 63, nodeIndex = 314, name = "House of the Silent Magnifico" },

    },
    [108] = { -- Greenshade
        { poiIndex = 13, nodeIndex = 150, name = "Seaside Sanctuary" },
        { poiIndex = 17, nodeIndex = 147, name = "Greenheart Wayshrine", traders_cnt = 1, },
        { poiIndex = 18, nodeIndex = 143, name = "Marbruk Wayshrine", traders_cnt = 5, },
        { poiIndex = 19, nodeIndex = 148, name = "Labyrinth Wayshrine" },
        { poiIndex = 20, nodeIndex = 149, name = "Falinesti Wayshrine" },
        { poiIndex = 22, nodeIndex = 151, name = "Verrant Morass Wayshrine", traders_cnt = 1, },
        { poiIndex = 23, nodeIndex = 152, name = "Woodhearth Wayshrine" },
        { poiIndex = 24, nodeIndex = 153, name = "Moonhenge Wayshrine" },
        { poiIndex = 25, nodeIndex = 154, name = "Serpent's Grotto Wayshrine" },
        { poiIndex = 39, nodeIndex = 197, name = "Dungeon: City of Ash I" },
        { poiIndex = 58, nodeIndex = 268, name = "Dungeon: City of Ash II" },
        { poiIndex = 59, nodeIndex = 304, name = "Cliffshade" },
        { poiIndex = 60, nodeIndex = 306, name = "Bouldertree Refuge" },
        { poiIndex = 61, nodeIndex = 370, name = "Dungeon: March of Sacrifices" },

    },
    [117] = { -- Shadowfen
        { poiIndex = 20, nodeIndex = 47,  name = "Stillrise Wayshrine" },
        { poiIndex = 21, nodeIndex = 48,  name = "Stormhold Wayshrine", traders_cnt = 5, },
        { poiIndex = 22, nodeIndex = 49,  name = "Hatching Pools Wayshrine" },
        { poiIndex = 23, nodeIndex = 171, name = "Bogmother Wayshrine" },
        { poiIndex = 24, nodeIndex = 50,  name = "Alten Corimont Wayshrine" },
        { poiIndex = 26, nodeIndex = 51,  name = "Percolating Mire Wayshrine" },
        { poiIndex = 27, nodeIndex = 52,  name = "Hissmir Wayshrine", traders_cnt = 1, },
        { poiIndex = 28, nodeIndex = 53,  name = "Loriasel Wayshrine" },
        { poiIndex = 30, nodeIndex = 78,  name = "Venomous Fens Wayshrine", traders_cnt = 1, },
        { poiIndex = 31, nodeIndex = 85,  name = "Forsaken Hamlet Wayshrine" },
        { poiIndex = 39, nodeIndex = 192, name = "Dungeon: Arx Corinium" },
        { poiIndex = 61, nodeIndex = 261, name = "Dungeon: Cradle of Shadows" },
        { poiIndex = 62, nodeIndex = 260, name = "Dungeon: Ruins of Mazzatun" },
        { poiIndex = 63, nodeIndex = 316, name = "Stay-Moist Mansion" },
        { poiIndex = 64, nodeIndex = 305, name = "The Ample Domicile" },

    },
    [181] = { -- Cyrodiil
        { poiIndex = 104, nodeIndex = 236, name = "Dungeon: Imperial City Prison" },
        { poiIndex = 105, nodeIndex = 247, name = "Dungeon: White-Gold Tower" },

    },
    [267] = { -- Eyevea
        { poiIndex = 1, nodeIndex = 215,  name = "Eyevea" },
    },
    [280] = { -- Bleakrock Isle
        { poiIndex = 3, nodeIndex = 172, name = "Bleakrock Wayshrine", traders_cnt = 1, },

    },
    [281] = { -- Bal Foyen
        { poiIndex = 2,  nodeIndex = 173, name = "Dhalmora Wayshrine", traders_cnt = 1, },
        { poiIndex = 3,  nodeIndex = 125, name = "Fort Zeren Wayshrine" },
        { poiIndex = 4,  nodeIndex = 126, name = "Foyen Docks Wayshrine" },
        { poiIndex = 9,  nodeIndex = 295, name = "Humblemud" },

    },
    [347] = { -- Coldharbour
        { poiIndex = 5,  nodeIndex = 128, name = "Library of Dusk Wayshrine" },
        { poiIndex = 6,  nodeIndex = 129, name = "Great Shackle Wayshrine" },
        { poiIndex = 7,  nodeIndex = 130, name = "The Chasm Wayshrine" },
        { poiIndex = 8,  nodeIndex = 131, name = "Hollow City Wayshrine", traders_cnt = 4, },
        { poiIndex = 9,  nodeIndex = 132, name = "Endless Stair Wayshrine" },
        { poiIndex = 10, nodeIndex = 133, name = "Everfull Flagon Wayshrine" },
        { poiIndex = 11, nodeIndex = 134, name = "Moonless Walk Wayshrine" },
        { poiIndex = 12, nodeIndex = 135, name = "Haj Uxith Wayshrine", traders_cnt = 1, },
        { poiIndex = 13, nodeIndex = 136, name = "Manor of Revelry Wayshrine" },
        { poiIndex = 14, nodeIndex = 139, name = "Reaver Citadel Wayshrine" },
        { poiIndex = 15, nodeIndex = 140, name = "The Orchard Wayshrine" },
        { poiIndex = 27, nodeIndex = 145, name = "Shrouded Plains Wayshrine" },
        { poiIndex = 29, nodeIndex = 146, name = "Court of Contempt Wayshrine", traders_cnt = 1, },
        { poiIndex = 39, nodeIndex = 184, name = "Dungeon: Vaults of Madness" },
        { poiIndex = 57, nodeIndex = 344, name = "Coldharbour Surreal Estate" },

    },
    [381] = { -- Auridon
        { poiIndex = 20, nodeIndex = 177, name = "Vulkhel Guard Wayshrine", traders_cnt = 1, },
        { poiIndex = 23, nodeIndex = 178, name = "Phaer Wayshrine" },
        { poiIndex = 24, nodeIndex = 174, name = "Tanzelwil Wayshrine" },
        { poiIndex = 25, nodeIndex = 175, name = "Firsthold Wayshrine", traders_cnt = 1, },
        { poiIndex = 26, nodeIndex = 176, name = "Mathiisen Wayshrine" },
        { poiIndex = 27, nodeIndex = 121, name = "Skywatch Wayshrine", traders_cnt = 5, },
        { poiIndex = 28, nodeIndex = 122, name = "Quendeluun Wayshrine" },
        { poiIndex = 29, nodeIndex = 123, name = "College Wayshrine" },
        { poiIndex = 30, nodeIndex = 124, name = "Greenwater Wayshrine" },
        { poiIndex = 33, nodeIndex = 127, name = "Windy Glade Wayshrine" },
        { poiIndex = 41, nodeIndex = 194, name = "Dungeon: The Banished Cells I" },
        { poiIndex = 42, nodeIndex = 212, name = "The Harborage" },
        { poiIndex = 61, nodeIndex = 262, name = "Dungeon: The Banished Cells II" },
        { poiIndex = 62, nodeIndex = 285, name = "Barbed Hook Private Room" },
        { poiIndex = 63, nodeIndex = 288, name = "Mara's Kiss Public House" },
        { poiIndex = 64, nodeIndex = 315, name = "Mathiisen Manor" },

    },
    [382] = { -- Reaper's March
        { poiIndex = 29, nodeIndex = 185, name = "Dungeon: Selene's Web" },
        { poiIndex = 30, nodeIndex = 144, name = "Vinedusk Wayshrine", traders_cnt = 1, },
        { poiIndex = 31, nodeIndex = 156, name = "Fort Grimwatch Wayshrine" },
        { poiIndex = 32, nodeIndex = 157, name = "Fort Sphinxmoth Wayshrine" },
        { poiIndex = 34, nodeIndex = 158, name = "Arenthia Wayshrine" },
        { poiIndex = 35, nodeIndex = 159, name = "Dune Wayshrine", traders_cnt = 1, },
        { poiIndex = 36, nodeIndex = 160, name = "Willowgrove Wayshrine" },
        { poiIndex = 37, nodeIndex = 161, name = "Moonmont Wayshrine" },
        { poiIndex = 38, nodeIndex = 162, name = "Rawl'kha Wayshrine", traders_cnt = 5, },
        { poiIndex = 39, nodeIndex = 163, name = "S'ren-ja Wayshrine" },
        { poiIndex = 57, nodeIndex = 258, name = "Trial: Maw of Lorkhaj" },
        { poiIndex = 58, nodeIndex = 291, name = "Serenity Falls Estate" },
        { poiIndex = 59, nodeIndex = 320, name = "Strident Springs Demesne" },
        { poiIndex = 60, nodeIndex = 321, name = "Dawnshadow" },
        { poiIndex = 61, nodeIndex = 311, name = "Sleek Creek House" },
        { poiIndex = 62, nodeIndex = 371, name = "Dungeon: Moon Hunter Keep" },

    },
    [383] = { -- Grahtwood
        { poiIndex = 8, nodeIndex = 191,  name = "Dungeon: Elden Hollow I" },
        { poiIndex = 15, nodeIndex = 214, name = "Elden Root Wayshrine", traders_cnt = 7, },
        { poiIndex = 16, nodeIndex = 164, name = "Gil-Var-Delle Wayshrine" },
        { poiIndex = 17, nodeIndex = 21,  name = "Elden Root Temple Wayshrine" },
        { poiIndex = 18, nodeIndex = 165, name = "Haven Wayshrine" },
        { poiIndex = 19, nodeIndex = 166, name = "Redfur Trading Post Wayshrine" },
        { poiIndex = 20, nodeIndex = 167, name = "Southpoint Wayshrine", traders_cnt = 1, },
        { poiIndex = 21, nodeIndex = 168, name = "Cormount Wayshrine", traders_cnt = 1, },
        { poiIndex = 22, nodeIndex = 169, name = "Ossuary Wayshrine" },
        { poiIndex = 40, nodeIndex = 207, name = "Gray Mire Wayshrine" },
        { poiIndex = 41, nodeIndex = 213, name = "Falinesti Winter Wayshrine" },
        { poiIndex = 58, nodeIndex = 265, name = "Dungeon: Elden Hollow II" },
        { poiIndex = 59, nodeIndex = 317, name = "The Gorinir Estate" },
        { poiIndex = 60, nodeIndex = 296, name = "Snugpod" },
        { poiIndex = 61, nodeIndex = 325, name = "Grand Topal Hideaway" },
        { poiIndex = 62, nodeIndex = 398, name = "Dungeon: Lair of Maarselok" },

    },
    [534] = { -- Stros M'Kai
        { poiIndex = 4,  nodeIndex = 138, name = "Port Hunding Wayshrine", traders_cnt = 1, },
        { poiIndex = 6,  nodeIndex = 179, name = "Sandy Grotto Wayshrine" },
        { poiIndex = 7,  nodeIndex = 180, name = "Saintsport Wayshrine" },
        { poiIndex = 11, nodeIndex = 324, name = "Hunding's Palatial Hall" },

    },
    [535] = { -- Betnikh
        { poiIndex = 3,  nodeIndex = 181, name = "Stonetooth Wayshrine", traders_cnt = 1, },
        { poiIndex = 4,  nodeIndex = 182, name = "Grimfield Wayshrine" },
        { poiIndex = 5,  nodeIndex = 183, name = "Carved Hills Wayshrine" },
        { poiIndex = 10, nodeIndex = 499, name = "Seaveil Spire", },

    },
    [537] = { -- Khenarthi's Roost
        { poiIndex = 5,  nodeIndex = 141, name = "Khenarthi's Roost Wayshrine" },
        { poiIndex = 6,  nodeIndex = 142, name = "Mistral Wayshrine", traders_cnt = 2, },
        { poiIndex = 17, nodeIndex = 300, name = "Moonmirth House" },

    },
    [584] = { -- Imperial City
        { poiIndex = 31, nodeIndex = 236, name = "Dungeon: Imperial City Prison" },
        { poiIndex = 50, nodeIndex = 247, name = "Dungeon: White-Gold Tower" },

    },
    [643] = { -- Imperial Sewers
        { poiIndex =  50, nodeIndex = 247, name = "Dungeon: White-Gold Tower", },
        { poiIndex =  51, nodeIndex = 247, name = "Dungeon: White-Gold Tower", },
        { poiIndex =  52, nodeIndex = 247, name = "Dungeon: White-Gold Tower", },
    },
    [684] = { -- Wrothgar
        { poiIndex = 34, nodeIndex = 243, name = "Siege Road Wayshrine" },
        { poiIndex = 35, nodeIndex = 242, name = "Frostbreak Ridge Wayshrine" },
        { poiIndex = 36, nodeIndex = 245, name = "Trader's Road Wayshrine" },
        { poiIndex = 37, nodeIndex = 244, name = "Orsinium Wayshrine", traders_cnt = 6, },
        { poiIndex = 38, nodeIndex = 237, name = "Shatul Wayshrine" },
        { poiIndex = 39, nodeIndex = 241, name = "Great Bay Wayshrine" },
        { poiIndex = 40, nodeIndex = 239, name = "Two Rivers Wayshrine" },
        { poiIndex = 41, nodeIndex = 238, name = "Icy Shore Wayshrine" },
        { poiIndex = 42, nodeIndex = 240, name = "Morkul Plain Wayshrine", traders_cnt = 4, },
        { poiIndex = 54, nodeIndex = 246, name = "Merchant's Gate Wayshrine" },
        { poiIndex = 58, nodeIndex = 348, name = "Pariah's Pinnacle" },
        { poiIndex = 59, nodeIndex = 424, name = "Dungeon: Icereach" },
        { poiIndex = 60, nodeIndex = 428, name = "Forgemaster Falls" },
        { poiIndex =   0, nodeIndex = 250, name = "Maelstrom Arena", },
 
    },
    [726] = { -- Murkmire
        { poiIndex = 5,  nodeIndex = 374, name = "Lilmoth Wayshrine", traders_cnt = 6, },
        { poiIndex = 6,  nodeIndex = 375, name = "Bright-Throat Wayshrine" },
        { poiIndex = 7,  nodeIndex = 376, name = "Dead-Water Wayshrine" },
        { poiIndex = 15, nodeIndex = 377, name = "Root-Whisper Wayshrine" },
        { poiIndex = 23, nodeIndex = 379, name = "Blackrose Prison Wayshrine" },
        { poiIndex = 24, nodeIndex = 388, name = "Lakemire Xanmeer Manor" },
        { poiIndex =   0, nodeIndex = 378, name = "Blackrose Prison", },

    },
    [816] = { -- Hew's Bane
        { poiIndex = 14, nodeIndex = 255, name = "Abah's Landing Wayshrine", traders_cnt = 7, },
        { poiIndex = 15, nodeIndex = 256, name = "Zeht's Displeasure Wayshrine" },
        { poiIndex = 16, nodeIndex = 257, name = "No Shira Citadel Wayshrine" },
        { poiIndex = 25, nodeIndex = 361, name = "Princely Dawnlight Palace" },

    },
    [823] = { -- Gold Coast
        { poiIndex = 1,  nodeIndex = 251, name = "Anvil Wayshrine", traders_cnt = 3, },
        { poiIndex = 2,  nodeIndex = 252, name = "Kvatch Wayshrine", traders_cnt = 3, },
        { poiIndex = 3,  nodeIndex = 253, name = "Strid River Wayshrine" },
        { poiIndex = 4,  nodeIndex = 254, name = "Gold Coast Wayshrine" },
        { poiIndex = 23, nodeIndex = 343, name = "Linchal Grand Manor" },
        { poiIndex = 24, nodeIndex = 362, name = "The Erstwhile Sanctuary" },
        { poiIndex = 25, nodeIndex = 390, name = "Dungeon: Depths of Malatar" },
        { poiIndex = 26, nodeIndex = 437, name = "Dungeon: Black Drake Villa" },
        { poiIndex = 27, nodeIndex = 466, name = "Varlaisvea Ayleid Ruins" },

    },
    [849] = { -- Vvardenfell
        { poiIndex = 9,  nodeIndex = 329, name = "West Gash Wayshrine" },
        { poiIndex = 12, nodeIndex = 331, name = "Trial: Halls of Fabrication" },
        { poiIndex = 13, nodeIndex = 330, name = "Urshilaku Camp Wayshrine" },
        { poiIndex = 22, nodeIndex = 273, name = "Gnisis Wayshrine" },
        { poiIndex = 23, nodeIndex = 274, name = "Ald'ruhn Wayshrine" },
        { poiIndex = 24, nodeIndex = 275, name = "Balmora Wayshrine", traders_cnt = 3, },
        { poiIndex = 25, nodeIndex = 272, name = "Seyda Neen Wayshrine" },
        { poiIndex = 26, nodeIndex = 276, name = "Suran Wayshrine" },
        { poiIndex = 27, nodeIndex = 277, name = "Molag Mar Wayshrine" },
        { poiIndex = 28, nodeIndex = 278, name = "Tel Branora Wayshrine" },
        { poiIndex = 29, nodeIndex = 284, name = "Vivec City Wayshrine", traders_cnt = 6, },
        { poiIndex = 30, nodeIndex = 279, name = "Nchuleftingth Wayshrine" },
        { poiIndex = 31, nodeIndex = 280, name = "Tel Mora Wayshrine" },
        { poiIndex = 32, nodeIndex = 281, name = "Sadrith Mora Wayshrine", traders_cnt = 3, },
        { poiIndex = 36, nodeIndex = 333, name = "Saint Delyn Penthouse" },
        { poiIndex = 37, nodeIndex = 334, name = "Amaya Lake Lodge" },
        { poiIndex = 38, nodeIndex = 335, name = "Ald Velothi Harbor House" },
        { poiIndex = 68, nodeIndex = 336, name = "Tel Galen" },
        { poiIndex = 72, nodeIndex = 282, name = "Valley of the Wind Wayshrine" },
        { poiIndex = 85, nodeIndex = 328, name = "Vivec Temple Wayshrine" },
        { poiIndex = 91, nodeIndex = 465, name = "Kushalit Sanctuary" },

    },
    [888] = { -- Craglorn
        { poiIndex = 11, nodeIndex = 270, name = "Dragonstar Arena" },
        { poiIndex = 31, nodeIndex = 230, name = "Trial: Hel Ra Citadel" },
        { poiIndex = 32, nodeIndex = 231, name = "Trial: Aetherian Archive" },
        { poiIndex = 33, nodeIndex = 232, name = "Trial: Sanctum Ophidia" },
        { poiIndex = 61, nodeIndex = 217, name = "Seeker's Archive Wayshrine" },
        { poiIndex = 62, nodeIndex = 219, name = "Sandy Path Wayshrine" },
        { poiIndex = 63, nodeIndex = 218, name = "Shada's Tear Wayshrine" },
        { poiIndex = 64, nodeIndex = 220, name = "Belkarth Wayshrine", traders_cnt = 7, },
        { poiIndex = 65, nodeIndex = 229, name = "Elinhir Wayshrine" },
        { poiIndex = 66, nodeIndex = 225, name = "Spellscar Wayshrine" },
        { poiIndex = 67, nodeIndex = 226, name = "Mountain Overlook Wayshrine" },
        { poiIndex = 68, nodeIndex = 227, name = "Inazzur's Hold Wayshrine" },
        { poiIndex = 69, nodeIndex = 233, name = "Dragonstar Wayshrine" },
        { poiIndex = 70, nodeIndex = 234, name = "Skyreach Wayshrine" },
        { poiIndex = 71, nodeIndex = 235, name = "Valley of Scars Wayshrine" },
        { poiIndex = 72, nodeIndex = 310, name = "Domus Phrasticus" },
        { poiIndex = 73, nodeIndex = 327, name = "Earthtear Cavern" },
        { poiIndex = 74, nodeIndex = 326, name = "Dungeon: Bloodroot Forge" },
        { poiIndex = 75, nodeIndex = 332, name = "Dungeon: Falkreath Hold" },
        { poiIndex = 76, nodeIndex = 345, name = "Hakkvild's High Hall" },
        { poiIndex = 77, nodeIndex = 395, name = "Elinhir Private Arena" },

    },
    [980] = { -- Clockwork City
        { poiIndex = 4,  nodeIndex = 338, name = "Clockwork Crossroads Wayshrine" },
        { poiIndex = 5,  nodeIndex = 339, name = "Mire Mechanica Wayshrine" },
        { poiIndex = 8,  nodeIndex = 347, name = "The Orbservatory Prior" },
        { poiIndex = 18, nodeIndex = 340, name = "Sanctuary Wayshrine" },

    },
    [981] = { -- The Brass Fortress
        { poiIndex =  2, nodeIndex = 337, name = "Brass Fortress Wayshrine", traders_cnt = 6, },
        { poiIndex =  4, nodeIndex = 346, name = "Trial: Asylum Sanctorium" },
        { poiIndex =  5, nodeIndex = 557, name = "Shadow Queen's Labyrinth", },

    },
    [1011] = { -- Summerset
        { poiIndex = 1,  nodeIndex = 349, name = "King's Haven Pass Wayshrine" },
        { poiIndex = 2,  nodeIndex = 350, name = "Shimmerene Wayshrine", traders_cnt = 3, },
        { poiIndex = 3,  nodeIndex = 351, name = "Sil-Var-Woad Wayshrine" },
        { poiIndex = 4,  nodeIndex = 352, name = "Russafeld Heights Wayshrine" },
        { poiIndex = 5,  nodeIndex = 353, name = "Cey-Tarn Keep Wayshrine" },
        { poiIndex = 6,  nodeIndex = 354, name = "Ebon Stadmont Wayshrine" },
        { poiIndex = 41, nodeIndex = 355, name = "Alinor Wayshrine", traders_cnt = 6, },
        { poiIndex = 42, nodeIndex = 356, name = "Lillandril Wayshrine", traders_cnt = 3, },
        { poiIndex = 43, nodeIndex = 357, name = "Eastern Pass Wayshrine" },
        { poiIndex = 45, nodeIndex = 358, name = "The Crystal Tower Wayshrine" },
        { poiIndex = 47, nodeIndex = 359, name = "Eldbur Ruins Wayshrine" },
        { poiIndex = 54, nodeIndex = 364, name = "Trial: Cloudrest" },
        { poiIndex = 55, nodeIndex = 365, name = "Sunhold Wayshrine" },
        { poiIndex = 57, nodeIndex = 369, name = "Veyond Wyte Wayshrine" },
        { poiIndex = 59, nodeIndex = 366, name = "Golden Gryphon Garret" },
        { poiIndex = 60, nodeIndex = 367, name = "Alinor Crest Townhouse" },
        { poiIndex = 61, nodeIndex = 368, name = "Colossal Aldmeri Grotto" },
        { poiIndex = 62, nodeIndex = 497, name = "Dungeon: Coral Aerie", },

    },
    [1027] = { -- Artaeum
        { poiIndex = 3,  nodeIndex = 360, name = "Artaeum Wayshrine" },
        { poiIndex = 6,  nodeIndex = 373, name = "Grand Psijic Villa" },

    },
    [1086] = { -- Northern Elsweyr
        { poiIndex = 38, nodeIndex = 381, name = "Riverhold Wayshrine" },
        { poiIndex = 39, nodeIndex = 382, name = "Rimmen Wayshrine", traders_cnt = 6, },
        { poiIndex = 40, nodeIndex = 383, name = "The Stitches Wayshrine" },
        { poiIndex = 41, nodeIndex = 384, name = "Tenmar Temple Wayshrine" },
        { poiIndex = 43, nodeIndex = 386, name = "Scar's End Wayshrine" },
        { poiIndex = 44, nodeIndex = 387, name = "Hakoshae Wayshrine" },
        { poiIndex = 47, nodeIndex = 399, name = "Trial: Sunspire" },
        { poiIndex = 48, nodeIndex = 391, name = "Dungeon: Moongrave Fane" },
        { poiIndex = 49, nodeIndex = 396, name = "Sugar Bowl Suite" },
        { poiIndex = 50, nodeIndex = 401, name = "Jode's Embrace" },
        { poiIndex = 51, nodeIndex = 400, name = "Hall of the Lunar Champion" },
        { poiIndex = 52, nodeIndex = 397, name = "Star Haven Wayshrine" },
        { poiIndex = 53, nodeIndex = 410, name = "Moon-Sugar Meadow" },

    },
    [1133] = { -- Southern Elsweyr
        { poiIndex = 1,  nodeIndex = 402, name = "Senchal Wayshrine", traders_cnt = 6, },
        { poiIndex = 2,  nodeIndex = 403, name = "South Guard Ruins Wayshrine" },
        { poiIndex = 3,  nodeIndex = 404, name = "Western Plains Wayshrine" },
        { poiIndex = 4,  nodeIndex = 405, name = "Black Heights Wayshrine" },
        { poiIndex = 5,  nodeIndex = 406, name = "Pridehome Wayshrine" },
        { poiIndex = 23, nodeIndex = 422, name = "Lucky Cat Landing" },
        { poiIndex = 24, nodeIndex = 423, name = "Potentate's Retreat" },

    },
    [1146] = { -- Tideholm
        { poiIndex = 3,  nodeIndex = 407, name = "Dragonguard Sanctum Wayshrine" },

    },
    [1160] = { -- Western Skyrim
        { poiIndex = 17, nodeIndex = 415, name = "Kilkreath Temple Wayshrine" },
        { poiIndex = 18, nodeIndex = 416, name = "Morthal Wayshrine" },
        { poiIndex = 19, nodeIndex = 417, name = "Mor Khazgur Wayshrine" },
        { poiIndex = 20, nodeIndex = 418, name = "Dragon Bridge Wayshrine" },
        { poiIndex = 21, nodeIndex = 419, name = "Southern Watch Wayshrine" },
        { poiIndex = 22, nodeIndex = 420, name = "Frozen Coast Wayshrine" },
        { poiIndex = 23, nodeIndex = 421, name = "Solitude Wayshrine", traders_cnt = 6, },
        { poiIndex = 39, nodeIndex = 434, name = "Trial: Kyne's Aegis" },
        { poiIndex = 40, nodeIndex = 426, name = "Solitude Docks Wayshrine" },
        { poiIndex = 42, nodeIndex = 429, name = "Deepwood Vale Wayshrine" },
        { poiIndex = 55, nodeIndex = 439, name = "Proudspire Manor" },
        { poiIndex = 56, nodeIndex = 438, name = "Snowmelt Suite" },
        { poiIndex = 57, nodeIndex = 436, name = "Dungeon: Castle Thorn" },
        { poiIndex = 58, nodeIndex = 450, name = "Giant's Coast Wayshrine" },
        { poiIndex = 59, nodeIndex = 451, name = "Northern Watch Wayshrine" },
        { poiIndex = 60, nodeIndex = 452, name = "Antiquarian's Alpine Gallery" },
        { poiIndex = 61, nodeIndex = 453, name = "Stillwaters Retreat" },
        { poiIndex = 62, nodeIndex = 455, name = "Shalidor's Shrouded Realm" },

    },
    [1161] = { -- Blackreach: Greymoor Caverns
        { poiIndex = 4,  nodeIndex = 411, name = "Dusktown Wayshrine" },
        { poiIndex = 5,  nodeIndex = 412, name = "Greymoor Keep Wayshrine" },
        { poiIndex = 6,  nodeIndex = 413, name = "Lightless Hollow Wayshrine" },
        { poiIndex = 7,  nodeIndex = 414, name = "Dark Moon Grotto Wayshrine" },
        { poiIndex = 23, nodeIndex = 430, name = "Dwarven Run Wayshrine" },
        { poiIndex = 24, nodeIndex = 431, name = "Grotto Falls Wayshrine" },
        { poiIndex = 25, nodeIndex = 432, name = "Deep Overlook Wayshrine" },
        { poiIndex = 26, nodeIndex = 433, name = "Western Greymoor Wayshrine" },
        { poiIndex = 29, nodeIndex = 440, name = "Bastion Sanguinaris" },
        { poiIndex = 30, nodeIndex = 435, name = "Dungeon: Stone Garden" },

    },
    [1207] = { -- The Reach
        { poiIndex = 25, nodeIndex = 443, name = "North Markarth Wayshrine" },
        { poiIndex = 26, nodeIndex = 445, name = "Karthwasten Wayshrine" },
        { poiIndex = 27, nodeIndex = 441, name = "Briar Rock Wayshrine" },
        { poiIndex = 28, nodeIndex = 447, name = "Rebel's Retreat Wayshrine" },
        { poiIndex = 29, nodeIndex = 444, name = "Lost Valley Wayshrine" },
        { poiIndex = 33, nodeIndex = 442, name = "Druadach Mountains Wayshrine" },
        { poiIndex = 34, nodeIndex = 449, name = "Markarth Wayshrine", traders_cnt = 6 },
        { poiIndex = 35, nodeIndex = 456, name = "Stone Eagle Aerie" },
        { poiIndex =   0, nodeIndex = 457, name = "Vateshran Hollows", },

    },
    [1208] = { -- Blackreach: Arkthzand Cavern
        { poiIndex = 9,  nodeIndex = 446, name = "Arkthzand Wayshrine" },
        { poiIndex = 10, nodeIndex = 448, name = "Nighthollow Wayshrine" },

    },
    [1261] = { -- Blackwood
        { poiIndex = 23, nodeIndex = 462, name = "Bloodrun Wayshrine", },
        { poiIndex = 38, nodeIndex = 468, name = "Trial: Rockgrove", },
        { poiIndex = 43, nodeIndex = 458, name = "Leyawiin Wayshrine", traders_cnt = 6, },
        { poiIndex = 44, nodeIndex = 459, name = "Gideon Wayshrine", },
        { poiIndex = 45, nodeIndex = 460, name = "Borderwatch Wayshrine", },
        { poiIndex = 46, nodeIndex = 461, name = "Fort Redmane Wayshrine", },
        { poiIndex = 47, nodeIndex = 463, name = "Blueblood Wayshrine", },
        { poiIndex = 48, nodeIndex = 464, name = "Stonewastes Wayshrine", },
        { poiIndex = 49, nodeIndex = 467, name = "Leyawiin Outskirts Wayshrine", },
        { poiIndex = 53, nodeIndex = 471, name = "Pilgrim's Rest", },
        { poiIndex = 54, nodeIndex = 472, name = "Water's Edge", },
        { poiIndex = 55, nodeIndex = 473, name = "Pantherfang Chapel", },
        { poiIndex = 67, nodeIndex = 469, name = "Dungeon: The Dread Cellar", },
        { poiIndex = 73, nodeIndex = 481, name = "Doomvault Vulpinaz Wayshrine", },
        { poiIndex = 74, nodeIndex = 482, name = "Blackwood Crossroads Wayshrine", },
        { poiIndex = 75, nodeIndex = 483, name = "Hutan-Tzel Wayshrine", },
        { poiIndex = 76, nodeIndex = 484, name = "Vunalk Wayshrine", },
        { poiIndex = 77, nodeIndex = 486, name = "Sweetwater Cascades", },
      
    },
    [1282] = { -- Fargrave
        { poiIndex = 2, nodeIndex = 487, name = "Fargrave Outskirts Wayshrine", },
		{ poiIndex = 3, nodeIndex = 495, name = "Ossa Accentium", },
		{ poiIndex = 5, nodeIndex = 493, name = "Fargrave Wayshrine", traders_cnt = 6, },

    },
    [1283] = { -- The Shambles
        { poiIndex = 4, nodeIndex = 489, name = "The Shambles Wayshrine", },

    },
    [1286] = { -- The Deadlands
        { poiIndex = 1, nodeIndex = 494, name = "Raging Coast Wayshrine", },
		{ poiIndex = 2, nodeIndex = 476, name = "The Blood Pit Wayshrine", },
		{ poiIndex = 3, nodeIndex = 477, name = "Ardent Hope Wayshrine", },
		{ poiIndex = 4, nodeIndex = 478, name = "Wretched Spire Wayshrine", },
		{ poiIndex = 5, nodeIndex = 479, name = "False Martyrs' Folly Wayshrine", },
		{ poiIndex = 6, nodeIndex = 480, name = "Annihilarch's Summit Wayshrine", },
		{ poiIndex = 21, nodeIndex = 496, name = "Agony's Ascent", },
		{ poiIndex = 29, nodeIndex = 490, name = "Wounded Crossing Wayshrine", },
		{ poiIndex = 30, nodeIndex = 491, name = "The Scourshales Wayshrine", },

    },
    [1318] = { -- High Isle
        { poiIndex = 6, nodeIndex = 517, name = "All Flags Islet", },
        { poiIndex = 26, nodeIndex = 501, name = "Coral Road Wayshrine", },
        { poiIndex = 27, nodeIndex = 502, name = "Tor Draioch Wayshrine", },
        { poiIndex = 28, nodeIndex = 503, name = "Steadfast Manor Wayshrine", },
        { poiIndex = 29, nodeIndex = 504, name = "Castle Navire Wayshrine", },
        { poiIndex = 30, nodeIndex = 505, name = "Garick's Rest Wayshrine", },
        { poiIndex = 31, nodeIndex = 506, name = "Stonelore Grove Wayshrine", },
        { poiIndex = 32, nodeIndex = 507, name = "Dufort Shipyards Wayshrine", },
        { poiIndex = 33, nodeIndex = 508, name = "Amenos Station Wayshrine", },
        { poiIndex = 34, nodeIndex = 509, name = "Brokerock Wayshrine", },
        { poiIndex = 39, nodeIndex = 510, name = "All Flags Wayshrine", },
        { poiIndex = 40, nodeIndex = 488, name = "Trial: Dreadsail Reef", },
        { poiIndex = 48, nodeIndex = 511, name = "Trappers Peak Wayshrine", },
        { poiIndex = 54, nodeIndex = 512, name = "Westbay Wayshrine", },
        { poiIndex = 68, nodeIndex = 513, name = "Gonfalon Square Wayshrine", traders_cnt = 6, },
        { poiIndex = 72, nodeIndex = 518, name = "Serpents Hollow Wayshrine", },
        { poiIndex = 73, nodeIndex = 519, name = "Flooded Coast Wayshrine", },
        { poiIndex = 74, nodeIndex = 520, name = "Dungeon: Earthen Root Enclave", },
        { poiIndex = 75, nodeIndex = 521, name = "Dungeon: Graven Deep", },
        { poiIndex = 76, nodeIndex = 522, name = "Ancient Anchor Berth", },
        { poiIndex = 77, nodeIndex = 523, name = "Highhallow Hold", },
        { poiIndex = 85, nodeIndex = 533, name = "Fogbreak Lighthouse", },

     },
    [1383] = { -- Galen
        { poiIndex = 26, nodeIndex = 524, name = "Vastyr Outskirts Wayshrine", },
        { poiIndex = 27, nodeIndex = 525, name = "Glimmertarn Wayshrine", },
        { poiIndex = 28, nodeIndex = 526, name = "Embervine Wayshrine", },
        { poiIndex = 29, nodeIndex = 527, name = "Llanshara Wayshrine", },
        { poiIndex = 30, nodeIndex = 528, name = "Y'free's Path Wayshrine", },
        { poiIndex = 31, nodeIndex = 529, name = "Vastyr Wayshrine", traders_cnt = 6, },
        { poiIndex = 32, nodeIndex = 530, name = "Eastern Shores Wayshrine", },
        { poiIndex =  34, nodeIndex = 566, name = "Gladesong Arboretum", },

     },	
    [1413] = { -- Apocrypha
        { poiIndex = 27, nodeIndex = 540, name = "Soundless Bight Wayshrine", },
		{ poiIndex = 28, nodeIndex = 542, name = "Cipher's Midden Wayshrine", },
		{ poiIndex = 29, nodeIndex = 543, name = "Speiran Tarn Wayshrine", },
		{ poiIndex = 30, nodeIndex = 544, name = "Writhing Wastes Wayshrine", },
		{ poiIndex = 31, nodeIndex = 545, name = "Tranquil Catalog Wayshrine", },
		{ poiIndex = 32, nodeIndex = 546, name = "Apogee Nadir Wayshrine", },
		{ poiIndex = 33, nodeIndex = 547, name = "Forlorn Palisades Wayshrine", },
		{ poiIndex = 34, nodeIndex = 548, name = "Feral Gallery Wayshrine", },
        { poiIndex =  36, nodeIndex = 550, name = "Endless Archive", },
        { poiIndex =  40, nodeIndex = 567, name = "Tower of Unutterable Truths", },		

    },
    [1414] = { -- Telvanni Peninsula
        { poiIndex = 19, nodeIndex = 534, name = "Trial: Sanity's Edge", },
		{ poiIndex = 21, nodeIndex = 535, name = "Necrom Outskirts Wayshrine", },
		{ poiIndex = 22, nodeIndex = 536, name = "Necrom Wayshrine", traders_cnt = 6, },
		{ poiIndex = 23, nodeIndex = 537, name = "Fungal Lowlands Wayshrine", },
		{ poiIndex = 24, nodeIndex = 538, name = "Ald Isra Wayshrine", },
		{ poiIndex = 25, nodeIndex = 539, name = "Padomaic Crest Wayshrine", },
		{ poiIndex = 26, nodeIndex = 549, name = "Great Arm Wayshrine", },
		{ poiIndex = 28, nodeIndex = 552, name = "Journey's End Lodgings", },
		{ poiIndex = 29, nodeIndex = 553, name = "Emissary's Enclave", },
		{ poiIndex = 30, nodeIndex = 554, name = "Alavelis Wayshrine", },
        { poiIndex =  34, nodeIndex = 555, name = "Kelesan'ruhn", },
 
    },
	 
    [-2147483648]  = { },

}

local _zoneNodeCache = { }

-- cache for formatted wayshrine names
local _nodeNameCache = {}

local function GetNodeName(nodeIndex,name)
    local localeName = _nodeNameCache[nodeIndex]

    if localeName == nil then
        localeName = Utils.FormatStringCurrentLanguage(name)
        _nodeNameCache[nodeIndex] = localeName
    end

    return localeName
end

--[ changed in 2.9.0 to get around constant zoneindex changes ]]--
local function GetNodesByZoneIndex(zoneIndex)
    if zoneIndex ~= nil then
		-- lookup by zoneIndex
        local nodes = _zoneNodeCache[zoneIndex]
        if nodes ~= nil then
            return Utils.copy(nodes)
		end
		-- lookup by zoneId
		local zoneId = GetZoneId(zoneIndex)
		if zoneId ~= nil then
			nodes = _zoneNodeLookup[zoneId]
			if nodes ~= nil then
				-- update cache
				_zoneNodeCache[zoneIndex] = nodes
				return Utils.copy(nodes)
			end
		end
    end
    return {}
end

local function GetNodeInfo(nodeIndex)
    if nodeIndex == nil then return nil end

    local known, name, normalizedX, normalizedY, textureName, textureName, poiType, isShown = GetFastTravelNodeInfo(nodeIndex)

    local nodeName = GetNodeName(nodeIndex,name)

    return known,nodeName,normalizedX, normalizedY, textureName ,textureName,poiType,isShown
end

Data.GetNodesByZoneIndex = GetNodesByZoneIndex
Data.GetNodeInfo = GetNodeInfo

MapSearch.Wayshrine.Data = Data
