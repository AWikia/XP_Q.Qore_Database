#===============================================================================
# Global metadata not specific to a map.  This class holds field state data that
# span multiple maps.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :bicycle
  attr_accessor :surfing
  attr_accessor :diving
  attr_accessor :sliding
  attr_accessor :fishing
  attr_accessor :runtoggle
  attr_accessor :repel
  attr_accessor :flashUsed
  attr_accessor :bridge
  attr_accessor :runningShoes
  attr_accessor :snagMachine
  attr_accessor :seenStorageCreator
  attr_accessor :startTime
  attr_accessor :creditsPlayed
  attr_accessor :playerID
  attr_accessor :coins
  attr_accessor :sootsack
  attr_accessor :mailbox
  attr_accessor :pcItemStorage
  attr_accessor :stepcount
  attr_accessor :happinessSteps
  attr_accessor :pokerusTime
  attr_accessor :daycare
  attr_accessor :daycareEgg
  attr_accessor :daycareEggSteps
  attr_accessor :pokedexUnlocked # Array storing which Dexes are unlocked
  attr_accessor :pokedexViable   # All Dexes of non-zero length and unlocked
  attr_accessor :pokedexDex      # Dex currently looking at (-1 is National Dex)
  attr_accessor :pokedexIndex    # Last species viewed per Dex
  attr_accessor :pokedexMode     # Search mode
  attr_accessor :healingSpot
  attr_accessor :escapePoint
  attr_accessor :pokecenterMapId
  attr_accessor :pokecenterX
  attr_accessor :pokecenterY
  attr_accessor :pokecenterDirection
  attr_accessor :visitedMaps
  attr_accessor :mapTrail
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleME
  attr_accessor :nextBattleBack
  attr_accessor :safariState
  attr_accessor :bugContestState
  attr_accessor :partner
  attr_accessor :challenge
  attr_accessor :lastbattle
  attr_accessor :phoneNumbers
  attr_accessor :phoneTime
  attr_accessor :eventvars
  attr_accessor :safesave
  attr_accessor :inPast
  attr_accessor :inFuture
  attr_accessor :adsWatched
  attr_accessor :pokebox

  def initialize
    @bicycle              = false
    @surfing              = false
    @diving               = false
    @sliding              = false
    @fishing              = false
    @runtoggle            = false
    @repel                = 0
    @flashused            = false
    @bridge               = 0
    @runningShoes         = false
    @snagMachine          = false
    @seenStorageCreator   = false
    @startTime            = Time.now
    @creditsPlayed        = false
    @playerID             = -1
    @coins                = 0
    @sootsack             = 0
    @mailbox              = nil
    @pcItemStorage        = nil
    @stepcount            = 0
    @happinessSteps       = 0
    @pokerusTime          = nil
    @daycare              = [[nil,0],[nil,0]]
    @daycareEgg           = false
    @daycareEggSteps      = 0
    numRegions = 0
    pbRgssOpen("Data/regionals.dat","rb"){|f| numRegions = f.fgetw }
    @pokedexUnlocked      = []
    @pokedexViable        = []
    @pokedexDex           = (numRegions==0) ? -1 : 0
    @pokedexIndex         = []
    @pokedexMode          = 0
    for i in 0...numRegions+1     # National Dex isn't a region, but is included
      @pokedexIndex[i]    = 0
      @pokedexUnlocked[i] = (i==0)
    end
    @healingSpot          = nil
    @escapePoint          = []
    @pokecenterMapId      = -1
    @pokecenterX          = -1
    @pokecenterY          = -1
    @pokecenterDirection  = -1
    @visitedMaps          = []
    @mapTrail             = []
    @nextBattleBGM        = nil
    @nextBattleME         = nil
    @nextBattleBack       = nil
    @safariState          = nil
    @bugContestState      = nil
    @partner              = nil
    @challenge            = nil
    @lastbattle           = nil
    @phoneNumbers         = []
    @phoneTime            = 0
    @eventvars            = {}
    @safesave             = false
    @inPast               = false
    @inFuture             = false
    @adsWatched           = 0
    @pokebox              = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] # Items 13 abd 19 are stubbed out
  end

  def bridge
    @bridge=0 if !@bridge
    return @bridge
  end
  
  def adsWatched
    @adsWatched=0 if !@adsWatched
    return @adsWatched
  end
  
  def pokebox
    @pokebox = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] if !@pokebox
    max= pokeboxNames.length - 1
    if !@pokebox[max] # Add the final new tasks for save files without them
      for i in 14...(pokeboxNames.length)
        @pokebox[i]=0 if !@pokebox[i]
      end
    end
    return @pokebox
  end
  
  def pokeboxNames
    return [_INTL("Gain Experience"),_INTL("Level Up Pokémon"),
            _INTL("Defeat Pokémon"),_INTL("Catch Pokémon"),
            _INTL("Activate Abilities"),_INTL("Activate Held Items"),
            _INTL("Use Physical Moves"),_INTL("Use Special Moves"),
            _INTL("Use Status Moves"),_INTL("Use Battle Items"),
            _INTL("Defeat Trainers"),_INTL("Lapse Turns"),
            _INTL("Use Medicine Items"),_INTL("Win PMW3 Battles"),
            _INTL("Deal Damage"),_INTL("Land Critical Hits"),
            _INTL("Use STAB Moves"),_INTL("Defeat Pokémon Instantly"),
            _INTL("Use Berries"),_INTL("Defeat Hordes"),
            _INTL("Increase Stats"),_INTL("Revive Pokémon"),
            _INTL("Use Healing Moves"),_INTL("Use One-hit KO Moves"),
            _INTL("Use Hi Priority Moves"),_INTL("Decrease Stats"),
            _INTL("Inflict Conditions"),_INTL("Use Moves with Effects"),
            _INTL("Use Copycat Moves"),_INTL("Take Recoil Damage")]
  end
  def pokeboxNames2
    return [_INTL("Experience Gaining"),_INTL("Pokémon Leveling"),
            _INTL("Pokémon Defeating"),_INTL("Pokémon Catching"),
            _INTL("Ability Activation"),_INTL("Held Item Activation"),
            _INTL("Physical Move Usage"),_INTL("Special Move Usage"),
            _INTL("Status Move Usage"),_INTL("Battle Item Usage"),
            _INTL("Trainer Defeating"),_INTL("Turn Lapsing"),
            _INTL("Medicine Item Usage"),_INTL("PMW3 Battle Winning"),
            _INTL("Damage Dealing"),_INTL("Critical Hit Landing"),
            _INTL("STAB Move Usage"),_INTL("Instant Pokémon Defeating"),
            _INTL("Berry Usage"),_INTL("Horde Defeating"),
            _INTL("Stat Increasing"),_INTL("Pokémon Revival"),
            _INTL("Healing Move Usage"),_INTL("One-hit KO Move Usage"),
            _INTL("Hi Priority Move Usage"),_INTL("Stat Decreasing"),
            _INTL("Condition Inflicting"),_INTL("Move with Effects Usage"),
            _INTL("Copycat Move Usage"),_INTL("Recoil Damage Taking")]
  end

  def pokeboxDescriptions
    return [_INTL("Defeat Pokémon to gain Experience. Should 2 Trainer's Pokémon participate, experience is counted by half."),
            _INTL("Fill the experience bar of a Pokémon to level them up."),
            _INTL("Use your moves to defeat opposing Pokémon and progress."),
            _INTL("Use your Poké Balls or the Safari Balls on a Safari Game to Pokémon and capture them to progress."),
            _INTL("Use your Pokémon's abilities to progress. It counts only once per use."),
            _INTL("Use your Pokémon's held item to progress. It conuts only once per use."),
            _INTL("Use your Pokémon's Physical moves to progress. Status moves turned into Physical moves conut too."),
            _INTL("Use your Pokémon's Special moves to progress. Status moves tunred into Special moves count too."),
            _INTL("Use your Pokémon's Status moves to progress."),
            _INTL("Use items from the Battle Items pocket in your Pokémon to progress. Held items do not count."),
            _INTL("Complete Trainer Battles to progress. In Trainer Battles with two Trainers, it counts twice."),
            _INTL("Spend turns on the battle to progress. The more the battle lasts, the more will be counted."),
            _INTL("Use items from the Medicine pocket in your Pokémon progress. Held items do not count."),
            _INTL("Complete Wild Battles in the PMW3 Maps to progress. Wild Battles outside of these ones do not count."),
            _INTL("Use your Pokémon's Damaging moves to deal damage to opposing Pokémon and progress."),
            _INTL("Get a critical hit by using your Pokémon's Damaging moves to progress."),
            _INTL("Use your Pokémon's Damaging moves of the same typing as the Pokémon itself to progress."),
            _INTL("Use up one of your moves that can defeat the opposing Pokémon in the turn that appeared to progress."),
            _INTL("Use items from the Berries pocket in your Pokémon to progress. Held items do not count."),
            _INTL("Defeat a group of 5 similar Pokémon to progress. In double battles, it counts twice."),
            _INTL("Increase your Pokémon's stats using moves, abilities or items to progress. Each stat increase counts once."),
            _INTL("Use your revival items or a Pokémon with Revival Blessing to revive out a fainted Pokémon and progress."),
            _INTL("Use your Pokémon's Healing moves to progress. It doesn't have to recover HP in order to be counted."),
            _INTL("Use your Pokémon's moves that will instantly faint the opponent to progress."),
            _INTL("Use your Pokémon's moves with high priority to progress."),
            _INTL("Decrease Pokémon's stats using your moves, abilities or items to progrss. Each stat decrease counts once."),
            _INTL("Pass out a status condition using your moves, abilities or items to progress."),
            _INTL("Use your Pokémon's moves that will have an additional effect chance upon its usage to progress."),
            _INTL("Use your Pokémon's copycat moves or abilities and use other Pokémon's moves to progress."),
            _INTL("Use your Pokémon's move that take recoil damage upon its usage to reduce its HP to progress.")]
  end
  
end



#===============================================================================
# This class keeps track of erased and moved events so their position
# can remain after a game is saved and loaded.  This class also includes
# variables that should remain valid only for the current map.
#===============================================================================
class PokemonMapMetadata
  attr_reader :erasedEvents
  attr_reader :movedEvents    
  attr_accessor :strengthUsed
  attr_accessor :blackFluteUsed
  attr_accessor :whiteFluteUsed

  def initialize
    clear
  end

  def clear
    @erasedEvents={}
    @movedEvents={}
    @strengthUsed=false
    @blackFluteUsed=false
    @whiteFluteUsed=false
  end

  def addErasedEvent(eventID)
    key=[$game_map.map_id,eventID]
    @erasedEvents[key]=true
  end

  def addMovedEvent(eventID)
    key=[$game_map.map_id,eventID]
    event=$game_map.events[eventID]
    @movedEvents[key]=[event.x,event.y,event.direction,event.through]
  end

  def updateMap
    for i in @erasedEvents
      if i[0][0]==$game_map.map_id && i[1]
        event=$game_map.events[i[0][1]]
        event.erase if event
      end
    end
    for i in @movedEvents
      if i[0][0]==$game_map.map_id && i[1]
        next if !$game_map.events[i[0][1]]
        $game_map.events[i[0][1]].moveto(i[1][0],i[1][1])
        case i[1][2]
        when 2
          $game_map.events[i[0][1]].turn_down
        when 4
          $game_map.events[i[0][1]].turn_left
        when 6
          $game_map.events[i[0][1]].turn_right
        when 8
          $game_map.events[i[0][1]].turn_up
        end
      end
      if i[1][3]!=nil
        $game_map.events[i[0][1]].through=i[1][3]
      end
    end
  end
end



#===============================================================================
# Temporary data which is not saved and which is erased when a game restarts.
#===============================================================================
class PokemonTemp
  attr_accessor :menuLastChoice
  attr_accessor :keyItemCalling
  attr_accessor :hiddenMoveEventCalling
  attr_accessor :begunNewGame
  attr_accessor :miniupdate
  attr_accessor :waitingTrainer
  attr_accessor :darknessSprite
  attr_accessor :pokemonDexData
  attr_accessor :pokemonMetadata
  attr_accessor :pokemonPhoneData
  attr_accessor :lastbattle
  attr_accessor :flydata
  attr_accessor :surfJump
  attr_accessor :endSurf

  def initialize
    @menuLastChoice         = 0
    @keyItemCalling         = false
    @hiddenMoveEventCalling = false
    @begunNewGame           = false
    @miniupdate             = false
    @waitingTrainer         = nil
    @darknessSprite         = nil
    @pokemonDexData         = nil
    @pokemonMetadata        = nil
    @pokemonPhoneData       = nil
    @lastbattle             = nil
    @flydata                = nil
    @surfJump               = nil
    @endSurf                = nil
  end
end