#===============================================================================
# * The default screen width (at a zoom of 1.0; size is half this at zoom 0.5).
# * The default screen height (at a zoom of 1.0).
# * The default screen zoom. (1.0 means each tile is 32x32 pixels, 0.5 means
#      each tile is 16x16 pixels, 2.0 means each tile is 64x64 pixels.)
# * Whether full-screen display lets the border graphic go outside the edges of
#      the screen (true), or forces the border graphic to always be fully shown
#      (false).
# * The width of each of the left and right sides of the screen border. This is
#      added on to the screen width above, only if the border is turned on.
# * The height of each of the top and bottom sides of the screen border. This is
#      added on to the screen height above, only if the border is turned on.
# * Map view mode (0=original, 1=custom, 2=perspective).
# * The current active channel (0=Stable, 1=Beta, 2=Dev, 3=Canary)
#     this is managed by the Channel value of Game.ini
# * The current active channel variant
#     this is managed by the Channel value of Game.ini
#===============================================================================
class RTP2 # <-- Required by something
  def self.getGameIniValue(section,key)
    val = "\0"*256
    gps = Win32API.new('kernel32', 'GetPrivateProfileString',%w(p p p p l p), 'l')
    gps.call(section, key, "", val, 256, ".\\Game.ini")
    val.delete!("\0")
    return val
  end
end

DEFAULTSCREENWIDTH   = 640 # 512
DEFAULTSCREENHEIGHT  = 384
DEFAULTSCREENZOOM    = 1.0
BORDERWIDTH          = 80
BORDERHEIGHT         = 48 # Was 80
MAPVIEWMODE          = 1
QQORECHANNEL         = 0
QQORECHANNEL         = 1 if  RTP2.getGameIniValue("Qortex", "Channel") == "Beta" # IE Mode throttles channel to beta
QQORECHANNEL         = 2 if (RTP2.getGameIniValue("Qortex", "Channel") == "Dev" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "Alpha")
QQORECHANNEL         = 3 if  RTP2.getGameIniValue("Qortex", "Channel") == "Canary"
QQORECHANNEL         = 4 if (RTP2.getGameIniValue("Qortex", "Channel") == "Internal" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "LTSC" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "Internal Canary")
QQORECHANNEL         = 5 if (RTP2.getGameIniValue("Qortex", "Channel") == "Upgrade Wizard" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "Release Preview")
QQORECHANNELVARIANT  = 0
QQORECHANNELVARIANT  = 1 if (RTP2.getGameIniValue("Qortex", "Channel") == "Internal" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "Upgrade Wizard" ||
                             RTP2.getGameIniValue("Qortex", "Channel") == "RTM")
QQORECHANNELVARIANT  = 2 if  RTP2.getGameIniValue("Qortex", "Channel") == "Internal Canary"


# To forbid the player from changing the screen size themselves, quote out or
# delete the relevant bit of code in the PScreen_Options script section.

#===============================================================================
# * The maximum level Pokémon can reach.
# * The level of newly hatched Pokémon.
# * The odds of a newly generated Pokémon being shiny (out of 65536).
# * The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
# * The odds of a wild Pokémon being a regional forme (out of 65536). This does
#     not incldue Eternal Formes. If value if larger than 5000, it will be capped
#     to 5000 due to combos
#===============================================================================
MAXIMUMLEVEL       = 400
EGGINITIALLEVEL    = 1
SHINYPOKEMONCHANCE = 100
POKERUSCHANCE      = 50
REGIONALCHANCE     = 1000
$FLINTDEX          = false # Disable Pokédex color Customizations made by FLINT (Multi-Colored)

#===============================================================================
# * Whether poisoned Pokémon will lose HP while walking around in the field.
# * Whether poisoned Pokémon will faint while walking around in the field
#      (true), or survive the poisoning with 1HP (false).
# * Whether fishing automatically hooks the Pokémon (if false, there is a
#      reaction test first).
# * Whether the player can surface from anywhere while diving (true), or only in
#      spots where they could dive down from above (false).
# * Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
#      mechanics (false).
# * Whether TMs can be used infinitely as in Gen 5 (true), or are one-use-only
#      as in older Gens (false).
#===============================================================================
POISONINFIELD         = false
POISONFAINTINFIELD    = false
FISHINGAUTOHOOK       = true
DIVINGSURFACEANYWHERE = false
NEWBERRYPLANTS        = true
INFINITETMS           = true

#===============================================================================
# * Pairs of map IDs, where the location signpost isn't shown when moving from
#      one of the maps in a pair to the other (and vice versa). Useful for
#      single long routes/towns that are spread over multiple maps.
# e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
#   Moving between two maps that have the exact same name won't show the
#      location signpost anyway, so you don't need to list those maps here.
#===============================================================================
NOSIGNPOSTS = [110,111]

#===============================================================================
# * Whether a move's physical/special category depends on the move itself as in
#      newer Gens (true), or on its type as in older Gens (false).
# * Whether the critical capture mechanic applies (true) or not (false). Note
#      that it is based on a total of 600+ species (i.e. that many species need
#      to be caught to provide the greatest critical capture chance of 2.5x),
#      and there may be fewer species in your game.
#===============================================================================
USEMOVECATEGORY       = true
USECRITICALCAPTURE    = true

#===============================================================================
# * The minimum number of badges required to boost each stat of a player's
#      Pokémon by 1.1x, while using moves in battle only.
# * Whether the badge restriction on using certain hidden moves is either owning
#      at least a certain number of badges (true), or owning a particular badge
#      (false).
# * Depending on HIDDENMOVESCOUNTBADGES, either the number of badges required to
#      use each hidden move, or the specific badge number required to use each
#      move. Remember that badge 0 is the first badge, badge 1 is the second
#      badge, etc.
# e.g. To require the second badge, put false and 1.
#      To require at least 2 badges, put true and 2.
#===============================================================================
BADGESBOOSTATTACK      = 1
BADGESBOOSTDEFENSE     = 5
BADGESBOOSTSPEED       = 3
BADGESBOOSTSPATK       = 7
BADGESBOOSTSPDEF       = 7
HIDDENMOVESCOUNTBADGES = true
BADGEFORCUT            = 1
BADGEFORFLASH          = 1
BADGEFORROCKSMASH      = 1
BADGEFORSURF           = 1
BADGEFORFLY            = 1
BADGEFORSTRENGTH       = 1
BADGEFORDIVE           = 1
BADGEFORWATERFALL      = 1

#===============================================================================
# * The names of each pocket of the Bag. Leave the first entry blank.
# * The maximum number of slots per pocket (-1 means infinite number). Ignore
#      the first number (0).
# * The maximum number of items each slot in the Bag can hold.
# * Whether each pocket in turn auto-sorts itself by item ID number. Ignore the
#      first entry (the 0).
# * The pocket number containing all berries. Is opened when choosing one to
#      plant, and cannot view a different pocket while doing so.
#===============================================================================
def pbPocketNames; return ["",
   _INTL("Items"),
   _INTL("Medicine"),
   _INTL("Poké Balls"),
   _INTL("TMs, HMs & TDs"),
   _INTL("Berries"),
   _INTL("Trophies"), # Was Mail
   _INTL("Battle Items"),
   _INTL("Key Items")
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 999
POCKETAUTOSORT = [0,false,false,false,true,true,true,false,false]
BERRYPOCKET    = 5

#===============================================================================
# * The name of the person who created the Pokémon storage system.
# * The number of boxes in Pokémon storage.
#===============================================================================
def pbStorageCreator
  return _INTL("Bill")
end
STORAGEBOXES = 999

#===============================================================================
# * Whether the Pokédex list shown is the one for the player's current region
#      (true), or whether a menu pops up for the player to manually choose which
#      Dex list to view when appropriate (false).
# * The names of each Dex list in the game, in order and with National Dex at
#      the end. This is also the order that $PokemonGlobal.pokedexUnlocked is
#      in, which records which Dexes have been unlocked (first is unlocked by
#      default).
#      You can define which region a particular Dex list is linked to. This
#      means the area map shown while viewing that Dex list will ALWAYS be that
#      of the defined region, rather than whichever region the player is
#      currently in. To define this, put the Dex name and the region number in
#      an array, like the Kanto and Johto Dexes are. The National Dex isn't in
#      an array with a region number, therefore its area map is whichever region
#      the player is currently in.
# * Whether all forms of a given species will be immediately available to view
#      in the Pokédex so long as that species has been seen at all (true), or
#      whether each form needs to be seen specifically before that form appears
#      in the Pokédex (false).
# * An array of numbers, where each number is that of a Dex list (National Dex
#      is -1). All Dex lists included here have the species numbers in them
#      reduced by 1, thus making the first listed species have a species number
#      of 0 (e.g. Victini in Unova's Dex).
#===============================================================================
DEXDEPENDSONLOCATION = false
def pbDexNames; return [
   [_INTL("Kanto"),0],
   [_INTL("Johto"),1],
   [_INTL("Quora"),2],
   [_INTL("Swuora"),3],
   [_INTL("Semuora"),4],
   [_INTL("Kenuora"),5],
   [_INTL("Xenuora"),6],
   [_INTL("Annuora"),7],
   [_INTL("Keniora"),8],
   [_INTL("Xeniora"),9],
   [_INTL("Johto"),10],
   [_INTL("Hoenn"),11],
   [_INTL("Maxuora"),12],
   [_INTL("Cindyora"),13],
   [_INTL("Sanuora"),14],
   [_INTL("Saniora"),15],
   [_INTL("Maxiora"),16],
   [_INTL("Daxuora"),17],
   [_INTL("Sannioura"),18],
   [_INTL("Saxora"),19],
   _INTL("National") # Pokédex
]; end
ALWAYSSHOWALLFORMS = false
DEXINDEXOFFSETS    = [2,10]

#===============================================================================
# * The amount of money the player starts the game with.
# * The maximum amount of money the player can have.
# * The maximum number of Game Corner coins the player can have.
#===============================================================================
INITIALMONEY = 3000
MAXMONEY     = 9999999
MAXCOINS     = 999999

#===============================================================================
# * A set of arrays each containing a trainer type followed by a Global Variable
#      number. If the variable isn't set to 0, then all trainers with the
#      associated trainer type will be named as whatever is in that variable.
#===============================================================================
RIVALNAMES = [
   [:RIVAL1,12],
   [:RIVAL2,12],
   [:CHAMPION,12],
   [:POKEMONTRAINER_Lyrithya,15],
   [:POKEMONTRAINER_Raptor,16],
   [:LINKER,1004]
]

#===============================================================================
# * A list of maps used by roaming Pokémon. Each map has an array of other maps
#      it can lead to.
# * A set of arrays each containing the details of a roaming Pokémon. The
#      information within is as follows:
#      - Species.
#      - Level.
#      - Global Switch; the Pokémon roams while this is ON.
#      - Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
#           4=surfing/fishing). See bottom of PField_RoamingPokemon for lists.
#      - Name of BGM to play for that encounter (optional).
#      - Roaming areas specifically for this Pokémon (optional).
#===============================================================================
RoamingAreas = {
   5  => [21,28,31,39,41,44,47,66,69],
   21 => [5,28,31,39,41,44,47,66,69],
   28 => [5,21,31,39,41,44,47,66,69],
   31 => [5,21,28,39,41,44,47,66,69],
   39 => [5,21,28,31,41,44,47,66,69],
   41 => [5,21,28,31,39,44,47,66,69],
   44 => [5,21,28,31,39,41,47,66,69],
   47 => [5,21,28,31,39,41,44,66,69],
   66 => [5,21,28,31,39,41,44,47,69],
   69 => [5,21,28,31,39,41,44,47,66]
}
RoamingSpecies = [
   [:LATIAS, 30, 53, 0, "002-Battle02x"],
   [:LATIOS, 30, 53, 0, "002-Battle02x"],
   [:KYOGRE, 40, 54, 2, nil, {
       2  => [21,31],
       21 => [2,31,69],
       31 => [2,21,69],
       69 => [21,31]
       }],
   [:ENTEI, 40, 55, 1, nil],
   [:KYODON, 134, 74, 0, "Battle - Wild Pokemon (Nebula Cave)", {
       186  => [187],
       187  => [186],
       189  => [191,194,196],
       194  => [189,191,196],
       196  => [189,191,194],
       206  => [206],
       215  => [216,217],
       217  => [215,216]
       }],
   [:REGIDRAGO, 256, 151, 0, "Battle - Wild Pokemon (Nebula Cave)", {
       22  => [22],
       32  => [32],
       400 => [400],
       33  => [33],
       105 => [105],
       106 => [107],
       107 => [106],
       108 => [108],
       109 => [109]
       }],
   [:REGIELEKI, 256, 152, 0, "Battle - Wild Pokemon (Nebula Cave)", {
       22  => [22],
       32  => [32],
       400 => [400],
       33  => [33],
       105 => [105],
       106 => [107],
       107 => [106],
       108 => [108],
       109 => [109]
       }],
   [:GLASTRIER, 400, 175, 0, "Battle - Wild Pokemon (Nebula Cave)", {
       42  => [42],
       43  => [43],
       76  => [76],
       124 => [124],
       128 => [128],
       134 => [342],
       342 => [134],
       343 => [343],
       344 => [344]
       }],
   [:SPECTRIER, 400, 176, 0, "Battle - Wild Pokemon (Nebula Cave)", {
       42  => [42],
       43  => [43],
       76  => [76],
       124 => [124],
       128 => [128],
       134 => [342],
       342 => [134],
       343 => [343],
       344 => [344]
       }]
]

#===============================================================================
# * A set of arrays each containing details of a wild encounter that can only
#      occur via using the Poké Radar. The information within is as follows:
#      - Map ID on which this encounter can occur.
#      - Probability that this encounter will occur (as a percentage).
#      - Species.
#      - Minimum possible level.
#      - Maximum possible level (optional).
#===============================================================================
POKERADAREXCLUSIVES=[
   [5,  20,  :STARLY,     12, 15],
   [21, 10,  :STANTLER,   14],
   [28, 20,  :BUTTERFREE, 15, 18],
   [28, 20,  :BEEDRILL,   15, 18],
   [143, 35, :WIKIAS,   3, 10],
   [143, 35, :STARLIX,   3, 10],
   [160, 35, :WIKIAS,   8, 14],
   [160, 20, :SPINDA,   8, 16],
   [160, 20, :THREADS,   8, 16],
   [161, 35, :WIKIAS,   9, 15],
   [161, 20, :SPINDA,   9, 17],
   [161, 20, :THREADS,   9, 17],
   [162, 35, :WIKIAS,   10, 17],
   [162, 40, :SPINDA,   10, 19],
   [88, 45,  :SHARPENIX,   25, 35],
   [90, 25,  :PRINGLES,   30, 34],
   [90,  5,  :MTV,   30, 35],
   [232, 17, :SPINDA,   20, 100],   
   [232, 18, :THREADS,   20, 100],   
   [232, 30, :IRIDA,   24, 80],
   [258, 17, :SPINDA,   80, 200],  
   [258, 18, :THREADS,   80, 200],  
   [262, 25, :SPINDA,   100, 220],
   [262, 25, :THREADS,   100, 220],
   [142, 20, :SPINDA,   55, 80],
   [142, 20, :THREADS,   55, 80],
   [173, 45, :ANT1,   30, 80],
   [22, 7,  :NAMCO,       1,3],
   [22, 7,  :BANDAI,       1,3],
   [22, 7,  :FOXKIDS,       1,3],
   [22, 5,  :TV5,       1,3],
   [300, 40, :WIKIAS,     2, 6],
   [300, 45, :WIKICITIE,  1,  3],
   [300, 30, :WIKICITIES,  1,  5],
   [105, 30, :FENEBLOOX,    1,7],
   [32, 10 , :TVM,    1,3],
   [32, 20 , :TV100,    1,3],
   [32, 30 , :BULBAGARDEN,    1,3],
   [177, 25, :MUNCHLAX,    5,45],
   [177, 25, :WIKIALANGUAGEBRIGADE,    5,45],
   [177, 25, :WVSTF,    5,45],
   [179, 25, :HAPPINY,    5,45],
   [179, 25, :WIKIALANGUAGEBRIGADE,    5,45],
   [179, 25, :WVSTF,    5,45],
   [42, 25,  :NETSCAPE,    1,6],
   [42, 25,  :MAXTHON,    1,7],
   [42, 25,  :SNAP,    1,8],
   [256, 10, :SPINDA,         20,30],
   [256, 10, :THREADS,         20,30],
   [344, 30, :ALCREMIE,     20,40],
   [174, 40, :SHARPENIX,    20,45],
   [174, 10, :SPINDA,       30,45],
   [174, 10, :THREADS,       30,45],
   [83,  8, :BING,       30,45],
   [83,  8, :XBOX,       30,45],
   [83,  8, :AZURE,       30,45],
   [83,  8, :VISUALSTUDIO,       30,45],
   [83,  8, :VISUALSTUDIOCODE,       30,45],
   [86,  35, :GEOMETRYDASH,       10,40],
   [88,  35, :MICROSOFT,       10,40],
   [90,  30, :NOVA,   30, 35],
   [90,  10, :SPINDA,   30, 35],
   [90,  10, :THREADS,   30, 35],
   [90,  20, :BULBAPEDIA,   34, 37],
   [400, 30, :INTERNETEXPLORER,    1,4],
   [400, 30, :BLUEGHOST,    1,4],
   [117, 10, :META,    10,60],
   [117, 10, :BANDAINAMCO, 10,60],
   [117, 10, :VOLKSWAGEN,    10,60],
   [117, 10, :DEUTSCHEWELLE,    10,60],
   [131, 5, :NOGGIN,   20, 40],   
   [131, 5, :NICKJR,   20, 40],   
   [131, 5, :ZELDA,   20, 40],   
   [131, 5, :BRAVE,   20, 40],   
   [131, 5, :THUNDERBIRD,   20, 40],   
   [131, 5, :ANDROID,   20, 40],   
]

FUSIONFINDEREXCLUSIVES=[
   [160, 35, :GOLTORB,   10, 20],
   [161, 35, :GOLTORB,   11, 21],
   [162, 35, :GOLTORB,   12, 23], 
   [141, 40, :GEOPINY,   17, 30],
   [141, 35, :BRONCHOP,   45, 70],
   [142, 40, :SNEAWOODO,   50, 76],
   [124, 45, :RATACHU,   39, 70], 
   [173, 25, :ORAINMEDIA,   30, 80],
   [173, 25, :VSMEDIA,   30, 80],
   [173, 35, :RATINEWS,   35, 77],
   [173, 30, :PONYVERSITY,   35, 84],
   [22, 20,  :CATERSTV,     1, 3],
   [22, 20,  :WEEDSTV,     1, 3],
   [22, 10,  :META6,       3],
   [22, 10,  :KAKU6,       3],
   [300, 40, :CHIRPLUP,    2, 5],
   [42, 35,  :CROAMARKET,       1,6],
   [256, 30, :PIKIPAZ,    5,15],
   [256, 20, :GRAYTRUMPAZ,    20,30],
]

#===============================================================================
# * A set of arrays each containing details of a graphic to be shown on the
#      region map if appropriate. The values for each array are as follows:
#      - Region number.
#      - Global Switch; the graphic is shown if this is ON (non-wall maps only).
#      - X coordinate of the graphic on the map, in squares.
#      - Y coordinate of the graphic on the map, in squares.
#      - Name of the graphic, found in the Graphics/Pictures folder.
#      - The graphic will always (true) or never (false) be shown on a wall map.
#===============================================================================
REGIONMAPEXTRAS = [
   [0,51,16,15,"mapHiddenBerth",false],
   [0,52,20,14,"mapHiddenFaraday",false],
   [17,221,7,4,"Anniversary",false]
]

#===============================================================================
# * The number of steps allowed before a Safari Zone game is over (0=infinite).
# * The number of seconds a Bug Catching Contest lasts for (0=infinite).
#===============================================================================
SAFARISTEPS    = 9999
BUGCONTESTTIME = 9999

#===============================================================================
# * The Global Switch that is set to ON when the player whites out.
# * The Global Switch that is set to ON when the player has seen Pokérus in the
#      Poké Center, and doesn't need to be told about it again.
# * The Global Switch which, while ON, makes all wild Pokémon created be
#      shiny.
# * The Global Switch which, while ON, makes all Pokémon created considered to
#      be met via a fateful encounter.
# * The Global Switch which determines whether the player will lose money if
#      they lose a battle (they can still gain money from trainers for winning).
# * The Global Switch which, while ON, prevents all Pokémon in battle from Mega
#      Evolving even if they otherwise could.
# * The Global Switch which, while ON prevents Win Streak feature from working
#      as well as preventing any money gain from battles
#===============================================================================
STARTING_OVER_SWITCH      = 1
SEEN_POKERUS_SWITCH       = 2
SHINY_WILD_POKEMON_SWITCH = 31
FATEFUL_ENCOUNTER_SWITCH  = 32
NO_MONEY_LOSS             = 33
NO_MEGA_EVOLUTION         = 34
SEMI_INTERNAL_BATTLE      = 205

#===============================================================================
# * The Global Variable that is used for the Win Streak Feature
# * The Global Variables that is used for the Daily Treat Machine Feature
#      - The Global Variable that is used to record the amount of days Daily
#            Treat Machine was used in a row
#      - The Global Variable that is used to store the timed event that will
#            reset the login count after two days of inactivity
#      - The Global Variable that is used to record the last date Daily Treat
#            Machine was used (Kept for compatibility purposs)
# * The Global Variables that is used for the Pokemon Box Feature
#      - The Global Variable that is used to record the stage of the Box
#      - The Global Variable that is used to record the tasks of the box
#      - The Global Variable that is used to store the streak count
#      - The Global Variable that is used to store the duration
#      - The Global Variable that is used to record the sub-stage of the Box
#      - The Global Variable that is used to record the last state of the Box
#      - The Global Variable that is used to record the balance of Battles
#           (Used to to check which version of the Common tasks will show on
#           level 2 boxes)
# * The Global Variables that is used for the Daily Win Feature
#      - The Global Variable that is used to record the amont of Stamps collected
#      - The Global Variable that is used to record the cooldown of the feature
#      - The Global Variable that is used to record the last state of the feature
#===============================================================================
WIN_STREAK_VARIABLE       = 1007
DTM_VARIABLES             = [1009,1010,1008]
PBOX_VARIABLES            = [1012,1013,1014,1015,1016,1017,1018]
DWIN_VARIABLES            = [1019,1020,1021]

#===============================================================================
# * The ID of the common event that runs when the player starts fishing (runs
#      instead of showing the casting animation).
# * The ID of the common event that runs when the player stops fishing (runs
#      instead of showing the reeling in animation).
#===============================================================================
FISHINGBEGINCOMMONEVENT   = -1
FISHINGENDCOMMONEVENT     = -1

#===============================================================================
# * The ID of the animation played when the player steps on grass (shows grass
#      rustling).
# * The ID of the animation played when the player lands on the ground after
#      hopping over a ledge (shows a dust impact).
# * The ID of the animation played when a trainer notices the player (an
#      exclamation bubble).
# * The ID of the animation played when a patch of grass rustles due to using
#      the Poké Radar.
# * The ID of the animation played when a patch of grass rustles vigorously due
#      to using the Poké Radar. (Rarer species)
# * The ID of the animation played when a patch of grass rustles and shines due
#      to using the Poké Radar. (Shiny encounter)
# * The ID of the animation played when a berry tree grows a stage while the
#      player is on the map (for new plant growth mechanics only).
#===============================================================================
GRASS_ANIMATION_ID           = 1
DUST_ANIMATION_ID            = 2
EXCLAMATION_ANIMATION_ID     = 3
RUSTLE_NORMAL_ANIMATION_ID   = 1
RUSTLE_VIGOROUS_ANIMATION_ID = 5
RUSTLE_SHINY_ANIMATION_ID    = 6
PLANT_SPARKLE_ANIMATION_ID   = 7

#===============================================================================
# * An array of available languages in the game, and their corresponding
#      message file in the Data folder. Edit only if you have 2 or more
#      languages to choose from.
#===============================================================================
LANGUAGES = [  
#  ["English","english.dat"],
#  ["Deutsch","deutsch.dat"]
]