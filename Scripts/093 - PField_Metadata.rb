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
  attr_accessor :lastSavedTime
  attr_accessor :upperKingdom    # true when one battle in a such map is done

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
    @pokebox              = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] # Items 13 abd 19 are stubbed out
    @lastSavedTime        = Time.now
    @upperKingdom         = false
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
    @pokebox = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] if !@pokebox
    max= pokeboxNames.length - 1
    if !@pokebox[max] # Add the final new tasks for save files without them
      for i in 14...(pokeboxNames.length)
        @pokebox[i]=0 if !@pokebox[i]
      end
    end
    return @pokebox
  end
  
  def pokeboxNames
    return [_INTL("Gain Experience Points"),_INTL("Level Up Pokémon"),
            _INTL("Defeat Opposing Pokémon"),_INTL("Catch Wild Pokémon"),
            _INTL("Activate Pokémon's Abilities"),_INTL("Activate Pokémon's Held Items"),
            _INTL("Use Physical Moves"),_INTL("Use Special Moves"),
            _INTL("Use Status Moves"),_INTL("Use Battle Items"),
            _INTL("Defeat Trainers in Battle Wins"),_INTL("Lapse Turns in Battles"),
            _INTL("Use Medicine Items"),_INTL("Win Battles in Upper Kingdom"),
            _INTL("Deal Damage to other Pokémon"),_INTL("Land Critical Hits"),
            _INTL("Use Moves that receive STAB"),_INTL("Defeat Pokémon in First Turn"),
            _INTL("Use Berries"),_INTL("Defeat Horde Pokémon Groups"),
            _INTL("Increase Pokémon's Stats"),_INTL("Revive Pokémon from Faint"),
            _INTL("Use Healing Moves"),_INTL("Use One-hit KO Moves"),
            _INTL("Use Moves with High Priority"),_INTL("Decrease Pokémon's Stats"),
            _INTL("Inflict Status Conditions"),_INTL("Use Moves with Addtl. Effects"),
            _INTL("Use Moves from other Pokémon"),_INTL("Take Recoil Damage"),
            _INTL("Recover HP"),_INTL("Land Super Effectiveness"),
            _INTL("Use Multi-hit Moves"),_INTL("Defeat Trainers with Best Skill"),
            _INTL("Use Moves while asleep"),_INTL("Gain Money in Battle"),
            _INTL("Land Not Very Effectiveness"),_INTL("Use Multi-Target Moves"),
            _INTL("Activate Win Streak Bags"),_INTL("Change Forms in Battle"),
            _INTL("Gain Levelup Stat Changes"),_INTL("Gain Effort Values"),
            _INTL("Learn moves in Battle"),_INTL("Break the Mold"),
            _INTL("Use Moves with Low Priority"),_INTL("Defeat Pokémon with Best Skill"),
            _INTL("Restore PP"),_INTL("Use Sound-based Moves"),
            _INTL("Supercharge Pokémon in Battle"),_INTL("Transform into other Pokémon"),
            _INTL("Use items from your Bag"),_INTL("Use Moves without Accuracy"),
            _INTL("Use Moves with Variable Power"),_INTL("Create Substitutes"),
            _INTL("Use Shadow Moves"),_INTL("Defeat Trainers with 6 Pokémon"),
            _INTL("Defeat Pokémon of your Color"),_INTL("Inflict Confusion or Infatuation"),
            _INTL("Collect Lucky Bags"),_INTL("Use Elder Special Moves"),
            _INTL("Gain Experience Points in Trainer Battles"),_INTL("Level Up Pokémon in Trainer Battles"),
            _INTL("Defeat Opposing Pokémon in Trainer Battles"),_INTL("Deal Damage to other Pokémon in Trainer Battles"),
            _INTL("Land Super Effectiveness in Trainer Battles"),_INTL("Land Not Very Effectiveness in Trainer Battles"),
            _INTL("Use Physical Moves in Trainer Battles"),_INTL("Use Special Moves in Trainer Battles"),
            _INTL("Use Status Moves in Trainer Battles"),_INTL("Gain Levelup Stat Changes in Trainer Battles"),
            _INTL("Gain Effort Values in Trainer Battles"),_INTL("Use Normal Moves"),
            _INTL("Use Normal Moves in Trainer Battles"),_INTL("Use Grass, Fire or Water Moves"),
            _INTL("Use Grass, Fire or Water Moves in Trainer Battles"),_INTL("Catch Pokémon with Best Skill"),
            _INTL("Defeat Pokémon with Best Skill in First Turn"),_INTL("Defeat Trainers with Best Skill and 6 Pokémon")]
  end
  def pokeboxNames2
    return [_INTL("Experience Gaining"),_INTL("Pokémon Leveling"),
            _INTL("Pokémon Defeating"),_INTL("Pokémon Catching"),
            _INTL("Ability Activation"),_INTL("Held Item Activation"),
            _INTL("Physical Move Usage"),_INTL("Special Move Usage"),
            _INTL("Status Move Usage"),_INTL("Battle Item Usage"),
            _INTL("Trainer Defeating"),_INTL("Turn Lapsing"),
            _INTL("Medicine Item Usage"),_INTL("Upper Kingdom Battle Winning"),
            _INTL("Damage Dealing"),_INTL("Critical Hit Landing"),
            _INTL("STAB Move Usage"),_INTL("Instant Pokémon Defeating"),
            _INTL("Berry Usage"),_INTL("Horde Defeating"),
            _INTL("Stat Increasing"),_INTL("Pokémon Revival"),
            _INTL("Healing Move Usage"),_INTL("One-hit KO Move Usage"),
            _INTL("High Priority Move Usage"),_INTL("Stat Decreasing"),
            _INTL("Condition Inflicting"),_INTL("Move with Effects Usage"),
            _INTL("Copycat Move Usage"),_INTL("Recoil Damage Taking"),
            _INTL("HP Recovering"),_INTL("Super Effective Landing"),
            _INTL("Multi-hit Move Usage"),_INTL("Skilled Trainer Defeating"),
            _INTL("Moves during Sleep Usage"),_INTL("Money Gaining"),
            _INTL("Not Very Effective Landing"),_INTL("Multi-Target Moves Usage"),
            _INTL("Win Streak Activation"),_INTL("Form Changing"),
            _INTL("Levelup stat Gaining"),_INTL("Effort Values Gaining"),
            _INTL("Move Learning"),_INTL("Mold Breaking"),
            _INTL("Low Priority Move Usgae"),_INTL("Skilled Pokémon Defeating"),
            _INTL("PP Restoration"),_INTL("Sund Move Usage"),
            _INTL("Pokémon Supercharging"),_INTL("Transform Usage"),
            _INTL("Item Usage"),_INTL("Perfect Move Usage"),
            _INTL("Variable Move Usage"),_INTL("Substitute Creation"),
            _INTL("Shadow Move Usage"),_INTL("Full-Team Trainer Defeating"),
            _INTL("Same-Color Pokémon Defeating"),_INTL("Confusion or Love Inflicting"),
            _INTL("Lucky Bag Collection"),_INTL("Elder Special Move Usage"),
            _INTL("Experience Gaining in TB"),_INTL("Pokémon Leveling in TB"),
            _INTL("Pokémon Defeatin in TB"),_INTL("Damage Dealing in TB"),
            _INTL("Super Effective in TB Landing"),_INTL("Not Very Effective in TB Landing"),
            _INTL("Physical Move in TB Usage"),_INTL("Special Move in TB Usage"),
            _INTL("Status Move in TB Usage"),_INTL("Levelup stat in TB Gaining"),
            _INTL("Effort Values in TB Gaining"),_INTL("Normal Move Usage"),
            _INTL("Normal Move Usage/TB"),_INTL("G-F-W Move Usage"),
            _INTL("G-f-W Move Usage/TB"),_INTL("Skilled Pokémon Catching"),
            _INTL("Instant Skilled Pokémon Defeting"),_INTL("Full-Team Skilled Trainer Defeating")]
  end
  def pokeboxNames3
    return [_INTL("Experience Points Gained"),_INTL("Pokémon Levelled Up"),
            _INTL("Opposing Pokémon Defeated"),_INTL("Wild Pokémon Caught"),
            _INTL("Pokémon's Abilities Activated"),_INTL("Pokémon's Held Items Activated"),
            _INTL("Physical Moves Used"),_INTL("Special Moves Used"),
            _INTL("Status Moves Used"),_INTL("Battle Items Used"),
            _INTL("Trainers in Battle Wins Defeated"),_INTL("Turns in Battles Lapsed"),
            _INTL("Medicine Items Used"),_INTL("Battles in Upper Kingdom Won"),
            _INTL("Damage to other Pokémon Dealt"),_INTL("Critical Hits Landed"),
            _INTL("Moves that receive STAB Used"),_INTL("Pokémon in First Turn Defeated"),
            _INTL("Berries Used"),_INTL("Horde Pokémon Groups Defeated"),
            _INTL("Pokémon's Stats Increased"),_INTL("Pokémon from Faint Revived"),
            _INTL("Healing Moves Used"),_INTL("One-hit KO Moves Used"),
            _INTL("Moves with High Priority Used"),_INTL("Pokémon's Stats Decreased"),
            _INTL("Status Conditions Inflicted"),_INTL("Moves with Addtl. Effects Used"),
            _INTL("Moves from other Pokémon Used"),_INTL("Recoil Damage Taken"),
            _INTL("HP Recovered"),_INTL("Super Effectiveness Landed"),
            _INTL("Multi-hit Moves Used"),_INTL("Trainers with Best Skill Defeated"),
            _INTL("Moves while asleep Used"),_INTL("Money in Battle Gained"),
            _INTL("Not Very Effectiveness Landed"),_INTL("Multi-Target Moves Used"),
            _INTL("Win Streak Bags Activated"),_INTL("Forms in Battle Changed"),
            _INTL("Levelup Stat Changes Gained"),_INTL("Effort Values Gained"),
            _INTL("Moves in Battle Learnt"),_INTL("The Mold Broken"),
            _INTL("Moves with Low Priority Used"),_INTL("Pokémon with Best Skill Defeated"),
            _INTL("PP Restored"),_INTL("Sound-based Moves Used"),
            _INTL("Pokémon in Battle Supercharged"),_INTL("Into other Pokémon Transformed"),
            _INTL("Items from your Bag Used"),_INTL("Moves without Accuracy Used"),
            _INTL("Moves with Variable Power Used"),_INTL("Substitutes Created"),
            _INTL("Shadow Moves Used"),_INTL("Trainers with 6 Pokémon Defeated"),
            _INTL("Pokémon of your Color Defeated"),_INTL("Confusion or Infatuation Inflicted"),
            _INTL("Lucky Bags Collected"),_INTL("Elder Special Moves Used"),
            _INTL("Experience Points in Trainer Battles Gained"),_INTL("Pokémon in Trainer Battles Levelled Up"),
            _INTL("Opposing Pokémon in Trainer Battles Defeated"),_INTL("Damage to other Pokémon in Trainer Battles Dealt"),
            _INTL("Super Effectiveness in Trainer Battles Landed"),_INTL("Not Very Effectiveness in Trainer Battles Landed"),
            _INTL("Physical Moves in Trainer Battles Used"),_INTL("Special Moves in Trainer Battles Used"),
            _INTL("Status Moves in Trainer Battles Used"),_INTL("Levelup Stat Changes in Trainer Battles Gained"),
            _INTL("Effort Values in Trainer Battles Gained"),_INTL("Normal Moves Used"),
            _INTL("Normal Moves in Trainer Battles Used"),_INTL("Grass, Fire or Water Moves Used"),
            _INTL("Grass, Fire or Water Moves in Trainer Battles Used"),_INTL("Pokémon with Best Skill Caught"),
            _INTL("Pokémon with Best Skill in First Turn Defeated"),_INTL("Trainers with Best Skill and 6 Pokémon Defeated")]
  end

  def pokeboxDescriptions
    return [_INTL("Defeat Pokémon to gain Experience. Only experience from the first participant will count."),
            _INTL("Fill the experience bar of a Pokémon to level them up."),
            _INTL("Use your moves to defeat opposing Pokémon and progress."),
            _INTL("Use your Poké Balls or the Safari Balls on a Safari Game to Pokémon and capture them to progress."),
            _INTL("Use your Pokémon's abilities to progress. It counts only once per use."),
            _INTL("Use your Pokémon's held item to progress. It conuts only once per use."),
            _INTL("Use your Pokémon's Physical moves to progress. Status moves turned into Physical moves conut too."),
            _INTL("Use your Pokémon's Special moves to progress. Status moves tunred into Special moves count too."),
            _INTL("Use your Pokémon's Status moves to progress."),
            _INTL("Use items from the Battle Items pocket in your Pokémon to progress. Held items do not count."),
            _INTL("Defeat Trainers in Battles to progress. The more there're, the better will be progressed."),
            _INTL("Spend turns on the battle to progress. The more the battle lasts, the more will be counted."),
            _INTL("Use items from the Medicine pocket in your Pokémon progress. Held items do not count."),
            _INTL("Complete Battles in Upper Kingdom Maps to progress. Battles outside of these ones do not count."),
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
            _INTL("Use your Pokémon's move that take recoil damage upon its usage to reduce its HP to progress."),
            _INTL("Use your Pokémon's moves, held items, abilities or items from the Bag that restore HP to progress."),
            _INTL("Trigger super effectiveness using your Pokémon's moves to progress."),
            _INTL("Use your Pokémon's moves that hit more than once to progress."),
            _INTL("Defeat Trainers that have the highest skill in Battles to progress. It counts once per instance."),
            _INTL("Use your Pokémon's moves while asleep to progress."),
            _INTL("Earn Money from Battles that award or from your Pokémon's moves that can give money out to progress."),
            _INTL("Trigger not very effectiveness using your Pokémon's moves to progress."),
            _INTL("Use your Pokémon's moves that hit multiple targets to progress."),
            _INTL("Use up a Win Streak Booster Bag on your Pokémon during Battles that use Win Streak to progress."),
            _INTL("Change your Pokémon form using its moves, items and abiilities to progress."),
            _INTL("Get stat increases of Base Stata while levelling up a Pokémon to progress."),
            _INTL("Defeat Pokémon to gain Effort Values. Only efforts from the first participant will count."),
            _INTL("Learn moves while levelling up or using Sketch or Mimic to progress."),
            _INTL("Activate an Ability that ignores other Pokémon's abilities to progress."),
            _INTL("Use your Pokémon's moves with low priority to progress."),
            _INTL("Defeat Legendary, Mythical Ultra Beast or Supercharged Pokémon to progress."),
            _INTL("Use your Pokémon's held items or items from the Bag that restore PP to Moves to progress."),
            _INTL("Use your Pokémon's moves that produce sound to progress."),
            _INTL("Trigger Mega Evolution, Primal Reversion, Dynamax, Gigantamax or Terastralization to progress."),
            _INTL("Use your Pokémon's moves, held items or abilities that can transform inro other Pokémon to progress."),
            _INTL("Use items from the bag in your Pokémon to progress. Held items do not count."),
            _INTL("Use your Pokémon's moves that have no accuracy check to progress."),
            _INTL("Use your Pokémon's Damaging moves that have a variable base power to progress."),
            _INTL("Create Substitute using your Pokémon's moves to progress."),
            _INTL("Use your Pokémon's Shadow moves to progress."),
            _INTL("Defeat Trainers that have 6 Pokémon in Battles to progress. It counts once per instance."),
            _INTL("Use your moves to defeat opposing Pokémon that are of your color and progress."),
            _INTL("Confuse or infatuate opposing Pokémon to progress."),
            _INTL("Collect Lucky Bags at every 11th Win Streak count to progress."),
            _INTL("Use your Pokémon's Elder Special Moves to progress."),
            _INTL("Defeat Pokémon to gain Experience. Only experience from the first participant in Trainer Battles will count."),
            _INTL("Fill the experience bar of a Pokémon in Trainer Battles to level them up."),
            _INTL("Use your moves to defeat opposing Pokémon in Trainer Battles and progress."),
            _INTL("Use your Pokémon's Damaging moves to deal damage to opposing Pokémon in Trainer Battles and progress."),
            _INTL("Trigger super effectiveness using your Pokémon's moves in Trainer Battles to progress."),
            _INTL("Trigger not very effectiveness using your Pokémon's moves in Trainer Battles to progress."),
            _INTL("Use your Pokémon's Physical moves in Trainer Battles to progress. Status moves turned into Physical moves conut too."),
            _INTL("Use your Pokémon's Special moves in Trainer Battles to progress. Status moves tunred into Special moves count too."),
            _INTL("Use your Pokémon's Status moves in Trainer Battles to progress."),
            _INTL("Get stat increases of Base Stata while levelling up a Pokémon in Trainer Battles to progress."),
            _INTL("Defeat Pokémon to gain Effort Values. Only efforts from the first participant in Trainer Battles will count."),
            _INTL("Use your Pokémon's Nomral moves to progress. Status moves turned into Normal moves conut too."),
            _INTL("Use your Pokémon's Nomral moves in Trainer Battles to progress. Status moves turned into Normal moves conut too."),
            _INTL("Use your Pokémon's Grass, Fire or Water moves to progress."),
            _INTL("Use your Pokémon's Grass, Fire or Water moves in Trainer Battles to progress."),
            _INTL("Use your Poké Balls or the Safari Balls on a Safari Game to high-skill Pokémon and capture them to progress."),
            _INTL("Defeat Legendary, Mythical Ultra Beast or Supercharged Pokémon in the turn that appeared to progress."),
            _INTL("Defeat Trainers that have 6 Pokémon and best skill in Battles to progress. It counts once per instance")]
  end

  def upperKingdom
    @upperKingdom=false if !@upperKingdom
    return @upperKingdom    
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