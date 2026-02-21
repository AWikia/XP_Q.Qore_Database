#===============================================================================
# Pokémon Box Global Metadata
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :pokebox
  
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
            _INTL("Gain Experience Points in Trainer Battle Wins"),_INTL("Level Up Pokémon in Trainer Battle Wins"),
            _INTL("Defeat Opposing Pokémon in Trainer Battle Wins"),_INTL("Deal Damage to other Pokémon in Trainer Battle Wins"),
            _INTL("Land Super Effectiveness in Trainer Battle Wins"),_INTL("Land Not Very Effectiveness in Trainer Battle Wins"),
            _INTL("Use Physical Moves in Trainer Battle Wins"),_INTL("Use Special Moves in Trainer Battle Wins"),
            _INTL("Use Status Moves in Trainer Battle Wins"),_INTL("Gain Levelup Stat Changes in Trainer Battle Wins"),
            _INTL("Gain Effort Values in Trainer Battle Wins"),_INTL("Use Normal Moves"),
            _INTL("Use Normal Moves in Trainer Battle Wins"),_INTL("Use Grass, Fire or Water Moves"),
            _INTL("Use Grass, Fire or Water Moves in Trainer Battle Wins"),_INTL("Catch Pokémon with Best Skill"),
            _INTL("Defeat Pokémon with Best Skill in First Turn"),_INTL("Defeat Trainers with Best Skill and 6 Pokémon"),
            _INTL("Defeat Pokémon of your Color in First Turn"),_INTL("Use Fighting, Psychic or Dark Moves"),
            _INTL("Use Fighting, Psychic or Dark Moves in Trainer Battle Wins"),_INTL("Use Robot Moves"),
            _INTL("Deal Damage to semi-invulnerable Pokémon"),_INTL("Use Moves with 1 PP"),
            _INTL("Change Abilities in Battle"),_INTL("Change Held Items in Battle"),
            _INTL("Defeat Pokémon of your Gender"),_INTL("Defeat Pokémon of your Gender in First Turn"),
            _INTL("Use Bomb-based Moves"),_INTL("Create Weather or Terrain"),
            _INTL("Gain Experience Points in Battle Wins"),_INTL("Level Up Pokémon in Battle Wins"),
            _INTL("Defeat Opposing Pokémon in Battle Wins"),_INTL("Deal Damage to other Pokémon in Battle Wins"),
            _INTL("Land Super Effectiveness in Battle Wins"),_INTL("Land Not Very Effectiveness in Battle Wins"),
            _INTL("Use Physical Moves in Battle Wins"),_INTL("Use Special Moves in Battle Wins"),
            _INTL("Use Status Moves in Battle Wins"),_INTL("Gain Levelup Stat Changes in Trainer Wins"),
            _INTL("Gain Effort Values in Battle Wins"),_INTL("Use Normal Moves in Battle Wins"),
            _INTL("Use Grass, Fire or Water Moves in Battle Wins"),_INTL("Use Fighting, Psychic or Dark Moves in Battle Wins")]

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
            _INTL("PP Restoration"),_INTL("Sound Move Usage"),
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
            _INTL("G-F-W Move Usage/TB"),_INTL("Skilled Pokémon Catching"),
            _INTL("Instant Skilled Pokémon Defeting"),_INTL("Full-Team Skilled Trainer Defeating"),
            _INTL("Instant Same-Color Pokémon Defeating"),_INTL("Fi-Ps-Da Move Usage"),
            _INTL("Fi-Ps-Da Move Usage/TB"),_INTL("Robot Move Usage"),
            _INTL("Damage Dealing to SI Pokémon"),_INTL("Move with 1 PP Usage"),
            _INTL("Ability Changing"),_INTL("Held Item Changing"),
            _INTL("Same Gender Pokémon Defeats"),_INTL("Instant Same Gender Pokémon Defeats"),
            _INTL("Bomb Move Usage"),_INTL("Weather or Terrain Creation"),
            _INTL("Experience Gaining/Win"),_INTL("Pokémon Leveling/Win"),
            _INTL("Pokémon Defeating/Win"),_INTL("Damage Dealing/Win"),
            _INTL("Super Effective Landing/Wom"),_INTL("Not Very Effective Landing/Win"),
            _INTL("Physical Move Usage/Win"),_INTL("Special Move Usage/Win"),
            _INTL("Status Move Usage/Win"),_INTL("Levelup stat Gaining/Win"),
            _INTL("Effort Values Gaining/Win"),_INTL("Normal Move Usage/Win"),
            _INTL("G-F-W Move Usage/Win"),_INTL("Fi-Ps-Da Move Usage/Win")]

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
            _INTL("Experience Points in Trainer Battle Wins Gained"),_INTL("Pokémon in Trainer Battle Wins Levelled Up"),
            _INTL("Opposing Pokémon in Trainer Battle Wins Defeated"),_INTL("Damage to other Pokémon in Trainer Battle Wins Dealt"),
            _INTL("Super Effectiveness in Trainer Battle Wins Landed"),_INTL("Not Very Effectiveness in Trainer Battle Wins Landed"),
            _INTL("Physical Moves in Trainer Battle Wins Used"),_INTL("Special Moves in Trainer Battle Wins Used"),
            _INTL("Status Moves in Trainer Battle Wins Used"),_INTL("Levelup Stat Changes in Trainer Battle Wins Gained"),
            _INTL("Effort Values in Trainer Battle Wins Gained"),_INTL("Normal Moves Used"),
            _INTL("Normal Moves in Trainer Battle Wins Used"),_INTL("Grass, Fire or Water Moves Used"),
            _INTL("Grass, Fire or Water Moves in Trainer Battle Wins Used"),_INTL("Pokémon with Best Skill Caught"),
            _INTL("Pokémon with Best Skill in First Turn Defeated"),_INTL("Trainers with Best Skill and 6 Pokémon Defeated"),
            _INTL("Pokémon of your Color in First Turn Defeated"),_INTL("Fighting, Psychic or Dark Moves Used"),
            _INTL("Fighting, Psychic or Dark Moves in Trainer Battle Wins Used"),_INTL("Robot Moves Used"),
            _INTL("Damage to semi-invulnerable Pokémon Dealt"),_INTL("Moves with 1 PP Used"),
            _INTL("Abilities in Batle Changed"),_INTL("Held Items in Batle Changed"),
            _INTL("Pokémon of your Gender Defeated"),_INTL("Pokémon of your Gender in First Turn Defeated"),
            _INTL("Bomb-based Moves Used"),_INTL("Weather or Terrain Created"),
            _INTL("Experience Points in Battle Wins Gained"),_INTL("Pokémon in Battle Wins Levelled Up"),
            _INTL("Opposing Pokémon in Battle Wins Defeated"),_INTL("Damage to other Pokémon in Battle Wins Dealt"),
            _INTL("Super Effectiveness in Battle Wins Landed"),_INTL("Not Very Effectiveness in Battle Wins Landed"),
            _INTL("Physical Moves in Battle Wins Used"),_INTL("Special Moves in Battle Wins Used"),
            _INTL("Status Moves in Battle Wins Used"),_INTL("Levelup Stat Changes in Trainer Wins Gained"),
            _INTL("Effort Values in Battle Wins Gained"),_INTL("Normal Moves in Battle Wins Used"),
            _INTL("Grass, Fire or Water Moves in Battle Wins Used"),_INTL("Fighting, Psychic or Dark Moves in Battle Wins Used")]
  end

  def pokeboxDescriptions
    return [_INTL("Defeat Pokémon to gain Experience. Only experience from the first participant counts."),
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
            _INTL("Use your Pokémon's move that take recoil damage upon its usage to reduce its HP and progress."),
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
            _INTL("Defeat Pokémon to gain Effort Values. Only efforts from the first participant counts."),
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
            _INTL("Defeat Pokémon to gain Experience. Only experience from the first participant in Trainer Battle Wins counts."),
            _INTL("Fill the experience bar of a Pokémon in Trainer Battle Wins to level them up."),
            _INTL("Use your moves to defeat opposing Pokémon in Trainer Battle Wins and progress."),
            _INTL("Use your Pokémon's Damaging moves to deal damage to opposing Pokémon in Trainer Battle Wins and progress."),
            _INTL("Trigger super effectiveness using your Pokémon's moves in Trainer Battle Wins to progress."),
            _INTL("Trigger not very effectiveness using your Pokémon's moves in Trainer Battle Wins to progress."),
            _INTL("Use your Pokémon's Physical moves in Trainer Battle Wins to progress. Status moves turned into Physical moves conut too."),
            _INTL("Use your Pokémon's Special moves in Trainer Battle Wins to progress. Status moves tunred into Special moves count too."),
            _INTL("Use your Pokémon's Status moves in Trainer Battle Wins to progress."),
            _INTL("Get stat increases of Base Stata while levelling up a Pokémon in Trainer Battle Wins to progress."),
            _INTL("Defeat Pokémon to gain Effort Values. Only efforts from the first participant in Trainer Battle Wins counts."),
            _INTL("Use your Pokémon's Nomral moves to progress. Status moves turned into Normal moves conut too."),
            _INTL("Use your Pokémon's Nomral moves in Trainer Battle Wins to progress. Status moves turned into Normal moves conut too."),
            _INTL("Use your Pokémon's Grass, Fire or Water moves to progress."),
            _INTL("Use your Pokémon's Grass, Fire or Water moves in Trainer Battle Wins to progress."),
            _INTL("Use your Poké Balls or the Safari Balls on a Safari Game to high-skill Pokémon and capture them to progress."),
            _INTL("Defeat Legendary, Mythical Ultra Beast or Supercharged Pokémon in the turn that appeared to progress."),
            _INTL("Defeat Trainers that have 6 Pokémon and best skill in Battles to progress. It counts once per instance"),
            _INTL("Defeat Pokémon that are of your color in the turn that appeared to progress."),
            _INTL("Use your Pokémon's Fighting, Psychic or Dark moves to progress."),
            _INTL("Use your Pokémon's Fighting, Psychic or Dark moves in Trainer Battle Wins to progress."),
            _INTL("Use your Pokémon's Robot moves to progress."),
            _INTL("Use your Pokémon's Damaging moves to deal damage to Pokémon that are semi-invulrenable and progress."),
            _INTL("Use your Pokémon's moves that have only 1 PP to progress."),
            _INTL("Change your Pokémon ability using its moves, items and forms to progress."),
            _INTL("Change your Pokémon held items using its moves and items to progress."),
            _INTL("Use your moves to defeat opposing Pokémon that are of your gender and progress."),
            _INTL("Defeat Pokémon that are of your gender in the turn that appeared to progress."),
            _INTL("Use your Pokémon's ball or bomb moves to progress."),
            _INTL("Create Weather or Terrains using your Pokémon's moves or Abilities to progress."),
            _INTL("Defeat Pokémon to gain Experience. Only experience from the first participant in Battle Wins counts."),
            _INTL("Fill the experience bar of a Pokémon in Battle Wins to level them up."),
            _INTL("Use your moves to defeat opposing Pokémon in Battle Wins and progress."),
            _INTL("Use your Pokémon's Damaging moves to deal damage to opposing Pokémon in Battle Wins and progress."),
            _INTL("Trigger super effectiveness using your Pokémon's moves in Battle Wins to progress."),
            _INTL("Trigger not very effectiveness using your Pokémon's moves in Battle Wins to progress."),
            _INTL("Use your Pokémon's Physical moves in Battle Wins to progress. Status moves turned into Physical moves conut too."),
            _INTL("Use your Pokémon's Special moves in Battle Wins to progress. Status moves tunred into Special moves count too."),
            _INTL("Use your Pokémon's Status moves in Battle Wins to progress."),
            _INTL("Get stat increases of Base Stata while levelling up a Pokémon in Battle Wins to progress."),
            _INTL("Defeat Pokémon to gain Effort Values. Only efforts from the first participant in Trainer Battle Wins counts."),
            _INTL("Use your Pokémon's Nomral moves in Battle Wins to progress. Status moves turned into Normal moves conut too."),
            _INTL("Use your Pokémon's Grass, Fire or Water moves in Battle Wins to progress."),
            _INTL("Use your Pokémon's Fighting, Psychic or Dark moves in Battle Wins to progress.")]

  end

  def pokeboxData 
    # 0 = Min Value, 
    # 1 = Max Value, 
    # 2 = Scaleup Multiplier (0 is default), 
    # 3 = Padding (1 is default), 
    # 4 = Trainer Task, 
    # 5 = Group (4 to 8 are Universal), 
    # 6 = Min Box Level
    # 7 = Rarity (Groups 3 and 5 never relies on it, Group 4 relies a bit on it)
    return [[200,600,6,10,false,0,0,1],  # Gain Experience
            [1,1.5,0,1,false,0,0,1],     # Level Up Pokemon
            [2.5,5,0,1,false,0,0,1],     # Defeat Pokemon
            [0.5,1,0,1,false,1,1,2],     # Catch Pokemon
            [2,4,0,1,false,1,0,2],       # Activate Abilites
            [2,4,0,1,false,1,0,2],       # Activate Held Items
            [3,6,0,1,false,2,0,1],       # Use Physical Moves
            [3,6,0,1,false,2,0,1],       # Use Special Moves
            [1.5,3,0,1,false,2,0,1],     # Use Status Moves
            [0.2,0.4,0,1,false,3,2,3],   # Use Battle Items
            [1,2,0,1,true,3,0,2],        # Defeat Trainers
            [3,7,0,1,false,3,0,1],       # Lapse Turns
            [0.4,0.65,0,1,false,6,0,2],  # Use Medicine Items
            [1,2,0,1,false,5,2,2],       # Win battles in UK
            [80,240,1.5,10,false,0,0,1], # Deal Damage
            [0.5,1,0,1,false,1,0,2],     # Land Critical Hits
            [2,4,0,1,false,2,0,2],       # Use STAB Moves
            [1,2,0,1,false,3,0,2],       # Defeat Pokemon Instantly
            [0.4,0.65,0,1,false,6,0,2],  # Use Berries
            [0.5,1,0,1,false,4,1,3],     # UNUSED!
            [3,7,0,1,false,0,2,2],       # Increase Stats
            [0.3,0.5,0,1,false,1,2,3],   # Revive Pokemon
            [1,2,0,1,false,2,2,2],       # Use Healing Moves
            [0.09,0.27,0,1,false,3,2,4], # Use One-hit KO Moves 
            [1,2,0,1,false,7,1,1],       # Use Hi Priority Moves
            [3,7,0,1,false,0,2,2],       # Decrease Stats
            [1,1.5,0,1,false,1,2,2],     # Inflict Conditions            
            [1,2,0,1,false,2,1,2],       # Use Moves with Effects
            [0.4,0.65,0,1,false,3,1,3],  # Use Copycat Moves
            [20,60,1.5,10,false,4,1,3],  # Take Recoil Damage
            [40,120,1.5,10,false,0,1,2], # Recover HP
            [1.5,3,0,1,false,1,0,1],     # Land Super Effective
            [1,2,0,1,false,2,1,2],       # Use Multi-hit Moves
            [0.5,1,0,1,true,3,0,3],      # Defeat Best Trainers
            [0.2,0.4,0,1,false,6,2,4],   # Use Sleeping Moves
            [600,1400,1,10,false,0,1,2], # Gain Money
            [1.5,3,0,1,false,1,0,1],     # Land Not Very Effective
            [1,2,0,1,false,2,1,2],       # Use Mutli-Target Moves
            [3,4.5,0,1,true,3,0,2],      # Activate Win Streak
            [0.5,1,0,1,false,7,2,3],     # Change Forms
            [20,30,0,5,false,0,1,1],     # Gain Levelup Stats
            [3,6,0,1,false,2,1,1],       # Gain Effort Values
            [0.5,1,0,1,false,2,1,3],     # Learn Moves in Battle
            [1,2,0,1,false,3,1,2],       # Break the Mold
            [1,2,0,1,false,7,1,3],       # Use Lo Priority Moves
            [1,2,0,1,false,0,2,2],       # Defeat Skilled Pokemon
            [5,10,0,5,false,1,2,2],      # Restore PP
            [1,2,0,1,false,2,2,2],       # Use Sound-based Moves
            [0.4,0.65,0,1,false,3,2,3],  # Supercharge Pokemon
            [0.4,0.65,0,1,false,7,2,3],  # Use Transform
            [0.5,0.8,0,1,false,6,0,2],   # Use any Item
            [2,4,0,1,false,4,0,2],       # Use Perfect Moves
            [1,2,0,1,false,4,1,2],       # Use Variable Moves
            [0.3,0.5,0,1,false,7,1,3],   # Create Substitutes
            [1,2,0,1,false,5,1,2],       # Use Shadow Moves
            [0.5,1,0,1,true,5,1,3],      # Defeat Full Trainers
            [1,2,0,1,false,4,2,2],       # Defeat same-color Pokemon
            [0.4,0.65,0,1,false,4,2,3],  # Confuse or Infatuate
            [0.06,0.12,0,1,true,5,2,4],  # Collect Lucky Bags
            [0.06,0.15,0,1,false,5,2,4], # Use Elder Special Moves
            [200,600,6,10,true,0,2,1],   # Gain Experience/TB
            [1,1.5,0,1,true,0,2,1],      # Level Up Pokemon/TB
            [2.5,5,0,1,true,0,2,1],      # Defeat Pokemon/TB
            [80,240,1.5,10,true,0,2,1],  # Deal Damage/TB
            [1.5,3,0,1,true,1,2,1],      # Land Super Effective/TB
            [1.5,3,0,1,true,1,2,1],      # Land Not Very Effective/TB
            [3,6,0,1,true,2,2,1],        # Use Physical Moves/TB
            [3,6,0,1,true,2,2,1],        # Use Special Moves/TB
            [1.5,3,0,1,true,2,2,1],      # Use Status Moves/TB
            [20,30,0,5,true,0,2,1],      # Gain Levelup Stats/TB
            [3,6,0,1,true,1,2,1],        # Gain Effort Values/TB
            [3,6,0,1,false,2,0,1],       # Use Normal Moves
            [3,6,0,1,true,2,2,1],        # Use Normal Moves/TB
            [3,6,0,1,false,2,1,1],       # Use G-F-W Moves
            [3,6,0,1,true,2,2,1],        # Use G-F-W Moves/TB
            [0.2,0.4,0,1,false,1,2,3],   # Catch Skilled Pokemon
            [0.5,1,0,1,false,3,3,3],     # Defeat Skilled Pokemon Inst.
            [0.2,0.4,0,1,true,3,3,4],    # Defeat Full Skilled Trainers
            [0.5,1,0,1,false,3,3,3],     # Defeat same-color Pokemon Inst.
            [3,6,0,1,false,2,1,1],       # Use Fi-Ps-Da Moves
            [3,6,0,1,true,2,2,1],        # Use Fi-Ps-Da Moves/TB
            [0.06,0.15,0,1,false,3,3,4], # Use Robot Moves
            [20,60,1.5,10,false,1,1,2],  # Deal Damage to SI PKMN
            [0.06,0.15,0,1,false,6,2,4], # Use Moves with 1 PP
            [0.5,1,0,1,false,6,2,3],     # Change Abilities
            [0.5,1,0,1,false,6,2,3],     # Change Held Items
            [1,2,0,1,false,4,2,2],       # Defeat same-gender Pokemon
            [0.5,1,0,1,false,5,3,3],     # Defear same-gender Pokemon Inst.
            [1,2,0,1,false,2,2,2],       # Use Bomb-based Moves
            [0.4,0.65,0,1,false,6,1,3],  # Create Weater or Terrain
            [200,600,6,10,false,0,2,1],  # Gain Experience/Win
            [1,1.5,0,1,false,0,2,1],     # Level Up Pokemon/Win
            [2.5,5,0,1,false,0,2,1],     # Defeat Pokemon/Win
            [80,240,1.5,10,false,0,2,1], # Deal Damage/Win
            [1.5,3,0,1,false,1,2,1],     # Land Super Effective/Win
            [1.5,3,0,1,false,1,2,1],     # Land Not Very Effective/Win
            [3,6,0,1,false,2,2,1],       # Use Physical Moves/Win
            [3,6,0,1,false,2,2,1],       # Use Special Moves/Win
            [1.5,3,0,1,false,2,2,1],     # Use Status Moves/Win
            [20,30,0,5,false,0,2,1],     # Gain Levelup Stats/Win
            [3,6,0,1,false,1,2,1],       # Gain Effort Values/Win
            [3,6,0,1,false,2,2,1],       # Use Normal Moves/win
            [3,6,0,1,false,2,2,1],       # Use G-F-W Moves/Win
            [3,6,0,1,false,2,2,1],       # Use Fi-Ps-Da Moves/Win
            ]
  end
  
end

#===============================================================================
# Pokémon Box main screen
#===============================================================================
class PokemonBoxScene
  attr_accessor :stages
  attr_accessor :items
  attr_accessor :icons
  attr_accessor :milestoneDay

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def initialize
    heal=[:AWAKENING,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL]
    heal=heal[$Trainer.publicID($Trainer.id)%heal.length]
    heal2=[:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:CHERIBERRY,:ASPEARBERRY]
    heal2=heal2[$Trainer.secretID($Trainer.id)%heal2.length]
    # 0 = Name
    # 1 = Rewards
    # 2 = Dueation (In days)
    # 3 = Amount Multiplier
    # 4 = Difficulty (0 = Beginner, 1 = Intermediate, 2 = Advanced, 3 = Expert, 4 = Master)
    # 5 = Item to be appended when Berry Planting is absent (nil to not add, can be array of two items too)
    @stages = [
    ["Tutorial",[:ORANBERRY,:SITRUSBERRY],13,0.5,0,nil],
    ["Classic",[:POTION,:POKEBALL],10,1,1,:SITRUSBERRY],
    ["Bronze",[:SUPERPOTION,:GREATBALL,heal],7,2.5,1,heal2],
    ["Silver",[:HYPERPOTION,:ULTRABALL,:FULLHEAL,:NORMALGEM],5,7,2,:PERSIMBERRY],
    ["Gold",[:MEGAPOTION,:PARKBALL,:FULLHEAL,:NORMALGEM,:RARECANDY],5,16,2,:PERSIMBERRY],
    # Platinum Mileston
    ["Platinum",[:FULLRESTORE,:PARKBALL,:SUPERBOOSTER,[:NORMALGEM,2],:VICIOUSCANDY],3,20,3,:ENIGMABERRY],
    # Legendary Milestone
    ["Legendary",[:SACREDASH,:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:VICIOUSCANDY],3,25,3,:ENIGMABERRY],
    # Legendary Milestone
    ["Mythical",[[:SACREDASH,2],:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:LOADEDDICE,[:VICIOUSCANDY,2]],3,30,3,:ENIGMABERRY],
    # Demon Milestone
    ["Demon",[[:SACREDASH,3],:MASTERBALL,[:SUPERBOOSTER,3],[:BOTANICSMOKE,2],:LOADEDDICE,[:VICIOUSCANDY,3]],3,40,4,[:ENIGMABERRY,2]]
    ]
    if $Trainer && $Trainer.isFemale?
      @icons=["voltorb","staryu","pikachu","slowpoke"]
    else
      @icons=["magnemite","shellder","pikachu","psyduck"]
    end
    @milestoneDay=pbIsMillenialDate?
  end

  def pbStartScene(expired=false)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    # Viewport for the Task Pane
    @viewportTask=Viewport.new(14,196,(Graphics.width / 2)-28,82)
    @viewportTask.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-140,44,@viewport)
    @sprites["bg"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
#    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_0",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    @sprites["bgM"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
    @sprites["bgM"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_milestone"))
    @sprites["bgM"].opacity= 96
    @sprites["bgM"].visible=@milestoneDay
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    # Task Progress
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132,44,@viewportTask)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress_small"))
    @sprites["progress"].visible=false
    @sprites["progress_icon"]=IconSprite.new((Graphics.width/4)+70,30,@viewportTask)
    @sprites["progress_icon"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/icon_magnemite"))
    @sprites["progress_icon"].visible=false
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132+14,334,@viewport)
    @sprites["progresstime"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["progress_w"]=IconSprite.new((Graphics.width/4)-156,196,@viewport)
    @sprites["progress_w"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_hardtask_wrapper"))
    @sprites["progress_w"].visible=false
    @sprites["bg"].z = 1
    @sprites["bgM"].z = 2
    @sprites["machine"].z = 3
    @sprites["progress_w"].z = 3
    @sprites["progress"].z = 3
    @sprites["progress_icon"].z = 4
    @sprites["progresstime"].z = 4
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("{1} Pokémon Box - Win Streak: {2}",boxName, currentStreak),
       2,-18,400,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayTask"]=BitmapSprite.new((Graphics.width / 2)-28,82,@viewportTask)
    @sprites["overlayTask"].z = 4
    @sprites["overlayTime"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlayTime"].z = 4
    @sprites["overlayItems"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayItems"].z = 4
    @sprites["task0"]=IconSprite.new(@sprites["machine"].x+12,@sprites["machine"].y+70,@viewport)
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[0]))
    @sprites["task0"].z = 4
    @sprites["task1"]=IconSprite.new(@sprites["machine"].x+76,@sprites["machine"].y+70,@viewport)
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[1]))
    @sprites["task1"].z = 4
    @sprites["task2"]=IconSprite.new(@sprites["machine"].x+140,@sprites["machine"].y+70,@viewport)
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[2]))
    @sprites["task2"].z = 4
    @sprites["task3"]=IconSprite.new(@sprites["machine"].x+204,@sprites["machine"].y+70,@viewport)
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[3]))
    @sprites["task3"].z = 4
    expiredbox = pbTimeEventValid(PBOX_VARIABLES[3]) || expired
    welcome=$game_variables[PBOX_VARIABLES[1]] == 0
    updateBalanceMeter if $game_variables[PBOX_VARIABLES[7]] == 0
    if welcome
      $game_variables[PBOX_VARIABLES[2]]=0
      initializeBox
    end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    pbPokemonBoxStart
    pbFadeInAndShow(@sprites) { update }
    if expiredbox
        stage=@stages[0][0]
        Kernel.pbMessage(_INTL("You ran out of time on this box. Start a new {1} box and try again.",stage))
        $game_variables[PBOX_VARIABLES[2]]=0
        oldl = currentBoxBalanceMeter(true)
        $game_variables[PBOX_VARIABLES[6]] = [oldbl] # Clear Balance Points after an expire
        initializeBox
    end
    if welcome
        Kernel.pbMessage(_INTL("Welcome to Pokémon Box where you can complete out tasks by finishing battles."))
        Kernel.pbMessage(_INTL("Finish out four tasks and you'll be getting rewards for your journey and a new Box."))
        Kernel.pbMessage(_INTL("Good Luck!"))
    end
    pbPokemonBoxAdvance
  end
  
  def maxStages
    return @stages.length-4 rescue 4 # 4 Items are Milestone Challenges
  end
  
  def currentStreak
    return $game_variables[PBOX_VARIABLES[2]]
  end
  
  def currentChapter
    return [((currentStreak-1)/10000).floor,0].max
  end
  
  def currentBoxDif # Like currentChapter but is 0 on Level 0 boxes and increases by 1 on milestone days
    return 0 if boxLevel==0
    return [currentChapter,1].max if @milestoneDay
    return [currentChapter,0].max
  end

  def currentStreak2
    return currentStreak - (10000*currentChapter) + 2 if currentChapter>1
    return currentStreak - (10000*currentChapter)
  end

  def currentStage(includeElite=true) # If includeElite is set to false, then currentStage does not increase on Milestone Boxes
    result = [currentStreak2,(maxStages-1)].min
    if includeElite
      result+=1 if isMillenial?
      result+=1 if isMillenial2?
      result+=1 if isMillenial3?
      result+=1 if isMillenial4?
    end
    return result
  end
  
  def getStageNumber(idx=-1)
    return (idx == -1) ? currentStage : idx
  end
  
  def stageSuffix
    return "_demon" if isMillenial4?
    return "_mythical" if isMillenial3?
    return "_legendary" if isMillenial2?
    return "_elite" if isMillenial?
    return ""
  end
  
  def boxName(includeElite=false)
    return @stages[currentStage(includeElite)][0] rescue "Tutorial"
  end
  
  def boxItems(idx=-1)
    if $game_switches[218] && @stages[getStageNumber(idx)][3]>=1
      return @stages[getStageNumber(idx)][1] + [[:GOLDBAR,@stages[getStageNumber(idx)][3].round]] rescue [:ORANBERRY,:SITRUSBERRY]
    elsif !class_exists?(:BerryPlantSprite) && @stages[getStageNumber(idx)][5]
      return @stages[getStageNumber(idx)][1] + [@stages[getStageNumber(idx)][5]] rescue [:ORANBERRY,:SITRUSBERRY]
    else
      return @stages[getStageNumber(idx)][1] rescue [:ORANBERRY,:SITRUSBERRY]
    end
  end
  
  def boxDuration
    return [@stages[currentStage][2]/(1 + (0.5*currentBoxDif) ),3].max rescue 13
  end
  
  def boxMulti
    return @stages[currentStage][3] + (4*currentBoxDif) rescue 0.5
  end
  
  # 0 = Junior and Basic
  # 1 = Classic and Bronze
  # 2 = Silver and Gold
  # 3 = Milestone Gold
  # 4 = Mega Milestone Gold
  # 5 = Final Box
  def boxLevel
    return @stages[currentStage][4]+1 rescue 1 if currentStreak.to_i == 65535
    return @stages[currentStage][4] rescue 0
  end

  # Mlienial Streak Counts:
  # * 10, 20, 30, 40, 50 and anything divisible by 100 starting from 100
  def isMillenial?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%10 == 0 || id2 == 65535
  end
  
  def isMillenial2?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%100 == 0 || id2 == 65535
  end

  def isMillenial3?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%1000 == 0 || id2 == 65535
  end

  def isMillenial4?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%10000 == 0 || id2 == 65535
  end

  def addIncr(num)
    return 0 # rand( ((($game_variables[PBOX_VARIABLES[2]] / 10).floor / 40) * num).floor )
  end

  def stepID
    return $game_variables[PBOX_VARIABLES[0]]
  end
  
  def currentStep
    return stepID + (4*$game_variables[PBOX_VARIABLES[4]])
  end

  def taskID # Task ID
    return $game_variables[PBOX_VARIABLES[1]][currentStep][0]
  end
  
  def taskname
    return $PokemonGlobal.pokeboxNames[$game_variables[PBOX_VARIABLES[1]][currentStep][0]]
  end
  
  def taskstatus # Current Task Status
    return $PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][currentStep][0]] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
  end
  
  def taskstatus2 # Maximum Task Status
    return $game_variables[PBOX_VARIABLES[1]][currentStep][2]
  end
  
  def getTaskLabel(idx,nohardmarkers=false)
    if isHardTask(idx) && !nohardmarkers
      return "_hard"
    elsif $game_variables[PBOX_VARIABLES[0]]>idx
      return ""
    end
    return "_normal"
  end

  def getTaskHue(idx=-1,nohardmarkers=false)
    if isHardTask(idx) && !nohardmarkers
      return [0,295,180,210,0][taskLevel(idx)]
    elsif $game_variables[PBOX_VARIABLES[0]]>idx
      return 0
    end
    return 0
  end

  
  def randIncr(num)
    id = currentStreak2.to_i
    num+=1 # Required
    if boxLevel==3       # Milenial Box, prefer Larger amounts
      return [rand(num),rand(num)].max
    elsif boxLevel==2    # Silver and Gold Boxes, don't prefer anything
      return rand(num)
    elsif boxLevel==1    # Classic and Bronze Boxes, prefer smaller amounts
      return [rand(num),rand(num)].min
    elsif boxLevel==0    # Tutorial Box, prefer even smaller amounts
      return [rand(num),rand(num),rand(num),rand(num)].min
    else                 # Mega Milenial Box, prefer even Larger amounts
      return [rand(num),rand(num),rand(num),rand(num)].max
    end
  end
  
  def valueFromTo(min=1,max=2,scaleup=0,padding=1,trainertask=false,multi=-1)
    multi=boxMulti if multi<0
    multi2=1 + ([($Trainer.numbadges / 2).floor,6].min * scaleup)
    if trainertask && currentBoxBalanceMeter<50
      values=[min.to_f*0.5,
              max.to_f*0.5]
    else
      values=[min.to_f,
              max.to_f]
    end
    min=(values[0]*multi).round
    max=(values[1]*multi).round
    result=min + randIncr((max-min)*multi2) + addIncr(min)
    return [(result/padding).round*padding,padding].max.round
  end

  def valueFromToMiddle(min=1,max=2,scaleup=0,padding=1,trainertask=false,multi=-1)
    multi=boxMulti if multi<0
    multi2=1 + ([($Trainer.numbadges / 2).floor,6].min * scaleup)
    if trainertask && currentBoxBalanceMeter<50
      values=[min.to_f*0.5,
              max.to_f*0.5]
    else
      values=[min.to_f,
              max.to_f]
    end
    min=values[0]*multi # No rounding here, tasks that only yield 1 must have marks
    max=values[1]*multi # No rounding here, tasks that only yield 1 must have marks
    result=((max-min)*multi2)
    return [min + (result * 0.4),
            min + (result * 0.55),
            min + (result * 0.7),
            min + (result * 0.85)]
  end
  
  def taskVals(num=0)
    min=$PokemonGlobal.pokeboxData[num][0]
    max=$PokemonGlobal.pokeboxData[num][1]
    scaleup=$PokemonGlobal.pokeboxData[num][2]
    padding=$PokemonGlobal.pokeboxData[num][3]
    trainertask=$PokemonGlobal.pokeboxData[num][4]
    return valueFromTo(min,max,scaleup,padding,trainertask,-1)

  end

  def taskLevel(idx=-1) # idx is used to identify if the current active task is hard
    return 0 if (currentStep%4 != idx && idx != -1)
    min=$PokemonGlobal.pokeboxData[taskID][0]
    max=$PokemonGlobal.pokeboxData[taskID][1]
    scaleup=$PokemonGlobal.pokeboxData[taskID][2]
    padding=$PokemonGlobal.pokeboxData[taskID][3]
    trainertask=$PokemonGlobal.pokeboxData[taskID][4]
    vals = valueFromToMiddle(min,max,scaleup,padding,trainertask,-1)
    shardv = (boxLevel>1 || currentBoxDif>0) ? 1 : 3
    if taskstatus2 > vals[3] && (boxLevel>1 || currentBoxDif>0)         # Master Task
      return 4
    elsif taskstatus2 > vals[2] && (boxLevel>1 || currentBoxDif>0)      # Expert Task
      return 3
    elsif taskstatus2 > vals[shardv] && (boxLevel>0 || currentBoxDif>0) # Super Hard Task
      return 2
    elsif taskstatus2 > vals[0] && (boxLevel>0 || currentBoxDif>0)      # Hard Task
      return 1
    else                                                                # Normal Task
      return 0
    end
  end


  

  def isHardTask(idx=-1) # idx is used to identify if the current active task is hard
    return taskLevel(idx) > 0
  end
  
  def addBalancePoints(pt)
    $game_variables[PBOX_VARIABLES[6]] = [] if  !$game_variables[PBOX_VARIABLES[6]].is_a?(Array)
    $game_variables[PBOX_VARIABLES[6]].push(pt)
    length=$game_variables[PBOX_VARIABLES[6]].length
    # Restrict to 200 Entries
    $game_variables[PBOX_VARIABLES[6]] = $game_variables[PBOX_VARIABLES[6]][[length-200,0].max...length]
  end
  
  def updateBalanceMeter
    $game_variables[PBOX_VARIABLES[6]] = [] if  !$game_variables[PBOX_VARIABLES[6]].is_a?(Array)
    data = $game_variables[PBOX_VARIABLES[6]]
    $game_variables[PBOX_VARIABLES[7]] = 1 if data==[]
    score = ((data.inject { |sum, n| sum + n }) / data.length) rescue 1
    $game_variables[PBOX_VARIABLES[7]] = [score,1].max
  end
  
  def currentBoxBalanceMeter(instantupdate=false)
    updateBalanceMeter if $game_variables[PBOX_VARIABLES[7]] == 0 # If 0, it must update itself
    data = $game_variables[PBOX_VARIABLES[6]]
    if instantupdate  # Data saved right now
      score = ((data.inject { |sum, n| sum + n }) / data.length) rescue 1
      return [score,1].max
    else              # Data saved at the time of the box's creation
      return $game_variables[PBOX_VARIABLES[7]]
    end
  end
  
  def pbPokemonBoxStart
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    textPositions=[
       [_INTL("How to use:"),(Graphics.width/4)-14,0,2,baseColor,shadowColor],
    ]
    text = _INTL("Win battles, including wild to complete tasks.")
    text2 = _INTL("Finish all four tasks to get rewards and a new box.")
    text3 = _INTL("If the time exipres, your win streak resets.")
    text4 = _INTL("Got stuck? Change task or try with different Pokémon.")
    drawTextEx(overlay,0,32,(Graphics.width/2)-28,2,text,baseColor,shadowColor)
    drawTextEx(overlay,0,112,(Graphics.width/2)-28,2,text2,baseColor,shadowColor)
    drawTextEx(overlay,0,192,(Graphics.width/2)-28,2,text3,baseColor,shadowColor)
    drawTextEx(overlay,0,272,(Graphics.width/2)-28,2,text4,baseColor,shadowColor)
    pbDrawTextPositions(overlay,textPositions)
    pbPokemonBoxUpdate
  end
  
  # Creates a new box instance
  def initializeBox(fromdebug=false)
    updateBalanceMeter
    taskNumbers=(0...$PokemonGlobal.pokeboxNames.length).to_a
    # Tasks that will be excluded from the boxes
    tasksToExclude=[]
    $game_variables[PBOX_VARIABLES[6]] = [] if  !$game_variables[PBOX_VARIABLES[6]].is_a?(Array)
    data = $game_variables[PBOX_VARIABLES[6]]
    boxdata=$PokemonGlobal.pokeboxData
    if boxLevel>4 # Level 5
      tasksToExclude=taskNumbers.find_all {|num| 
                                          ( boxdata[num][7]<4 && [0,1,2,4,6].include?(boxdata[num][5]) ) ||
                                          ( boxdata[num][6]>boxLevel && currentBoxDif==0 )
                                          }
    elsif boxLevel>3 # Level 4
      tasksToExclude=taskNumbers.find_all {|num| 
                                          ( boxdata[num][7]<3 && [0,1,2,4,6].include?(boxdata[num][5]) ) ||
                                          ( boxdata[num][6]>boxLevel && currentBoxDif==0 )
                                          }
    elsif boxLevel>2 #|| currentBoxDif>2 # Level 3 or Rank 4/Tier 3
      tasksToExclude=taskNumbers.find_all {|num| 
                                          ( boxdata[num][7]<2 && [0,1,2,4,6].include?(boxdata[num][5]) ) ||
                                          ( boxdata[num][6]>boxLevel && currentBoxDif==0 )
                                          }
    elsif boxLevel>1
      excludeTrainerBattles = data==[] || currentBoxBalanceMeter< 35 || currentBoxDif>2
      tasksToExclude=taskNumbers.find_all {|num| 
                                          ( boxdata[num][7]<1 && [0,1,2,4,6].include?(boxdata[num][5]) ) ||
                                          ( boxdata[num][7]<2 && ([0,1,2].include?(boxdata[num][5]) && !boxdata[num][4]) && !excludeTrainerBattles ) ||
                                          ( boxdata[num][7]<2 && ([0,1,2].include?(boxdata[num][5]) && (boxdata[num][4] || boxdata[num][6]<2) ) && excludeTrainerBattles ) ||
                                          ( boxdata[num][6]>boxLevel && currentBoxDif==0 )
                                          }
    else # Level 1 and below
      tasksToExclude=taskNumbers.find_all {|num| 
                                          ( boxdata[num][7]<2 && ([0,1,2].include?(boxdata[num][5]) && boxdata[num][4]) ) ||
                                          ( boxdata[num][6]>boxLevel && currentBoxDif==0 )
                                          }

    end
    # Disable the Horde Task as it is unachievable
    tasksToExclude.push(19) # Not applicable
    # List of items that will enable the supercharge task
    supercharger=false
    mRINGS = [:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM,:DYNAMAXBAND] 
    for i in mRINGS
      next if !hasConst?(PBItems,i)
      if $PokemonBag.pbQuantity(i)>0
        supercharger=true
        break
      end
    end
    tasksToExclude.push(48) if !supercharger # Never when not having it
    # List of Pokemon that will enable the robot task
    robot=false
    species = [:CALODIN,:COULUNDIN] # These know Robot-type moves
    for i in species
      next if !hasConst?(PBSpecies,i)
      if $Trainer.hasOwned?(i)
        robot=true
        break
      end
    end
    tasksToExclude.push(81) if !robot # Never when not having it
    tasksToExclude.push(13) if !$PokemonGlobal.upperKingdom
    # Disable "Use Elder Special Moves" when Elder Special Move tutorial isn't done
    tasksToExclude.push(59) if !$game_switches[174]
    # Disable "Use Shadow Moves" when shadow type isn't defined
    tasksToExclude.push(54) if !hasConst?(PBTypes,:SHADOW)
    tasksToExclude.push(3,10,19,23,29,33,34,35,38,42,48,54,55,58,59,60,61,62,63,64,65,66,67,68,69,70,72,74,75,76,77,80,81,83) if $flint_brockopolis_active
    if ($PokemonSystem.battledif>2 rescue false)
      mode=2  # Strict Mode = Tasks can be only on their intended positions
    elsif ($PokemonSystem.battledif>0 rescue false)
      mode=1  # Strict Mode = Tasks can be only on their intended positions
    else
      mode=0  # Normal Mode = Tasks can be anywhere but Special tasks in harder non-milestone boxes can only be on the fourth task
    end
    # Group 0 (Primary Tasks)
    task0 = taskNumbers.find_all {|num| boxdata[num][5]==0 }
    task0.delete_if {|element| tasksToExclude.include?(element) }
    # Group 1 (Secondary Tasks)
    task1 = taskNumbers.find_all {|num| boxdata[num][5]==1 }
    task1.delete_if {|element| tasksToExclude.include?(element) }
    # Group 2 (Move Tasks)
    task2 = taskNumbers.find_all {|num| boxdata[num][5]==2 }
    task2.delete_if {|element| tasksToExclude.include?(element) }
    # Group 3 (Special Tasks)
    task3 = taskNumbers.find_all {|num| boxdata[num][5]==3 }
    task3.delete_if {|element| tasksToExclude.include?(element) }
    # Universal Tasks 0 (Regular Tasks)
    taskU0= taskNumbers.find_all {|num| boxdata[num][5]==4 } # 19 is not applicable in Q.Qore
    taskU0.delete_if {|element| tasksToExclude.include?(element) }
    taskU0.shuffle! # Required 
    taskU2= taskNumbers.find_all {|num| boxdata[num][5]==6 } # 19 is not applicable in Q.Qore
    taskU2.delete_if {|element| tasksToExclude.include?(element) }
    taskU2.shuffle! # Required 
    # Universal Tasks 1 (Special Tasks)
    taskU1= taskNumbers.find_all {|num| boxdata[num][5]==5 }
    taskU1.delete_if {|element| tasksToExclude.include?(element) }
    taskU1.shuffle! # Required 
    taskU3= taskNumbers.find_all {|num| boxdata[num][5]==7 }
    taskU3.delete_if {|element| tasksToExclude.include?(element) }
    taskU3.shuffle! # Required 
    # Common Tasks from Groups 0 to 2
    taskCMN= taskNumbers.find_all {|num| boxdata[num][7]<2 && [0,1,2].include?(boxdata[num][5]) }
    taskCMN.delete_if {|element| tasksToExclude.include?(element) }
    # Uncommon Tasks from Groups 0 to 2
    taskUCM= taskNumbers.find_all {|num| boxdata[num][7]==2 && [0,1,2].include?(boxdata[num][5]) }
    taskUCM.delete_if {|element| tasksToExclude.include?(element) }
    # Rare+ Tasks from Groups 0 to 2
    taskRAR= taskNumbers.find_all {|num| boxdata[num][7]>2 && [0,1,2].include?(boxdata[num][5]) }
    taskRAR.delete_if {|element| tasksToExclude.include?(element) }
    # Universal Tasks for Millenial/Elite/Level 3 Boxes
    if boxLevel>2
      taskU0_1 = task3 | taskU0 | taskU1 | taskU2 | taskU3
      taskU0_1.delete_if {|element| tasksToExclude.include?(element) }
      taskU0_1.shuffle! # Required 
      task3 = [] # Handled elsewhere
      taskU0 = [] # Handled elsewhere
      taskU1 = [] # Handled elsewhere
      taskU2 = [] # Handled elsewhere
      taskU3 = [] # Handled elsewhere
      j=0
      for i in taskU0_1 # 13 and 19 are not applicable in Q.Qore
        if j%2==0
          taskU0.push(i)
        else
          taskU1.push(i)
        end
        j+=1
      end
    end
    # Set Up Tasks
    if mode==2  # Hard Mode (Also similar to the original Box handling)
      # Task 0
      choices0= task0 | taskU0 | taskU2 | taskU3
      choices0.shuffle!
      choices0Offset=0
      # Task 1
      choices1= task1 | taskU0 | taskU2 | taskU3
      choices1.delete_if {|element| choices0[0...4].include?(element) }
      choices1.shuffle!
      choices1Offset=0
      # Task 2
      choices2= task2 | taskU1 | taskU2 | taskU3
      choices2.delete_if {|element| choices0[0...4].include?(element) ||
                                    choices1[0...4].include?(element)}
      choices2.shuffle!      
      choices2Offset=0
      # Task 3
      choices3=task3 | taskU1 | taskU2 | taskU3
      choices3.delete_if {|element| choices0[0...4].include?(element) ||
                                    choices1[0...4].include?(element) ||
                                    choices2[0...4].include?(element)}
      choices3.shuffle!
      choices3Offset=0
    elsif mode==1  # Normal Mode
      if boxLevel==0 # Tutorial Boxes
        # Task 0
        choices0= task0 | task1 | task2 | task3 | taskU0 | taskU1 | taskU2 | taskU3
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1=choices0
        choices1Offset=4
        # Task 2
        choices2=choices0
        choices2Offset=8
        # Task 3
        choices3=choices0
        choices3Offset=12
      elsif boxLevel==1 # Classic and Bronze Boxes
        # Task 0
        choices0= taskCMN | taskUCM | taskU0
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1=choices0
        choices1Offset=4
        # Task 2
        choices2=taskRAR | task3 | taskU1 | taskU2 | taskU3
        choices2.delete_if {|element| choices0[0...8].include?(element) }
        choices2.shuffle!
        choices2Offset=0
        # Task 3
        choices3=choices2
        choices3Offset=4
      elsif boxLevel==2  # Silver and Gold Boxes
        # Task 0
        choices0= taskUCM | taskRAR | taskU0
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1= taskCMN  | taskU0
        choices1.delete_if {|element| choices0[0...4].include?(element) }
        choices1.shuffle!
        choices1Offset=0
        # Task 2
        choices2=task3 | taskU1 | taskU2 | taskU3
        choices2.delete_if {|element| choices0[0...4].include?(element) ||
                                      choices1[0...4].include?(element)}
        choices2.shuffle!
        choices2Offset=0
        # Task 3
        choices3=choices2
        choices3Offset=4
      else  # Milestone Boxes
        # Task 0
        choices0= task0 | task1 | task2 | taskU0
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1=choices0
        choices1Offset=4
        # Task 2
        choices2=task3 | taskU1
        choices2.delete_if {|element| choices0[0...8].include?(element) }
        choices2.shuffle!
        choices2Offset=0
        # Task 3
        choices3=choices2
        choices3Offset=4
      end
    else # Easy Mode
      if boxLevel<2 # Easy Boxes
        # Task 0
        choices0= task0 | task1 | task2 | task3 | taskU0 | taskU1 | taskU2 | taskU3
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1=choices0
        choices1Offset=4
        # Task 2
        choices2=choices0
        choices2Offset=8
        # Task 3
        choices3=choices0
        choices3Offset=12
      else # Hard Boxes
        # Task 0
        choices0= task0 | task1 | task2 | taskU0 | taskU2
        choices0.shuffle!
        choices0Offset=0
        # Task 1
        choices1=choices0
        choices1Offset=4
        # Task 2
        choices2=choices0
        choices2Offset=8
        # Task 3
        choices3=task3 | taskU1 | taskU3
        choices3.delete_if {|element| choices0[0...12].include?(element) }
        choices3.shuffle!
        choices3Offset=0
      end
    end
    length0=choices0.length
    length1=choices1.length
    length2=choices2.length
    length3=choices3.length
    $game_variables[PBOX_VARIABLES[0]]=0
    $game_variables[PBOX_VARIABLES[4]]=0
    $game_variables[PBOX_VARIABLES[1]] = [
      # Task #0
      [choices0[(choices0Offset+0)%length0],$PokemonGlobal.pokebox[choices0[(choices0Offset+0)%length0]],taskVals(choices0[(choices0Offset+0)%length0])],
      [choices1[(choices1Offset+0)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+0)%length1]],taskVals(choices1[(choices1Offset+0)%length1])],
      [choices2[(choices2Offset+0)%length2],$PokemonGlobal.pokebox[choices2[(choices2Offset+0)%length2]],taskVals(choices2[(choices2Offset+0)%length2])],
      [choices3[(choices3Offset+0)%length3],$PokemonGlobal.pokebox[choices3[(choices3Offset+0)%length3]],taskVals(choices3[(choices3Offset+0)%length3])],
      # Task #1
      [choices0[(choices0Offset+1)%length0],$PokemonGlobal.pokebox[choices0[(choices0Offset+1)%length0]],taskVals(choices0[(choices0Offset+1)%length0])],
      [choices1[(choices1Offset+1)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+1)%length1]],taskVals(choices1[(choices1Offset+1)%length1])],
      [choices2[(choices2Offset+1)%length2],$PokemonGlobal.pokebox[choices2[(choices2Offset+1)%length2]],taskVals(choices2[(choices2Offset+1)%length2])],
      [choices3[(choices3Offset+1)%length3],$PokemonGlobal.pokebox[choices3[(choices3Offset+1)%length3]],taskVals(choices3[(choices3Offset+1)%length3])],
      # Task #2
      [choices0[(choices0Offset+2)%length0],$PokemonGlobal.pokebox[choices0[(choices0Offset+2)%length0]],taskVals(choices0[(choices0Offset+2)%length0])],
      [choices1[(choices1Offset+2)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+2)%length1]],taskVals(choices1[(choices1Offset+2)%length1])],
      [choices2[(choices2Offset+2)%length2],$PokemonGlobal.pokebox[choices2[(choices2Offset+2)%length2]],taskVals(choices2[(choices2Offset+2)%length2])],
      [choices3[(choices3Offset+2)%length3],$PokemonGlobal.pokebox[choices3[(choices3Offset+2)%length3]],taskVals(choices3[(choices3Offset+2)%length3])],
      # Task #3
      [choices0[(choices0Offset+3)%length0],$PokemonGlobal.pokebox[choices0[(choices0Offset+3)%length0]],taskVals(choices0[(choices0Offset+3)%length0])],
      [choices1[(choices1Offset+3)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+3)%length1]],taskVals(choices1[(choices1Offset+3)%length1])],
      [choices2[(choices2Offset+3)%length2],$PokemonGlobal.pokebox[choices2[(choices2Offset+3)%length2]],taskVals(choices2[(choices2Offset+3)%length2])],
      [choices3[(choices3Offset+3)%length3],$PokemonGlobal.pokebox[choices3[(choices3Offset+3)%length3]],taskVals(choices3[(choices3Offset+3)%length3])],
                                          ]
    pbTimeEvent(PBOX_VARIABLES[3],boxDuration*86400)
    pbSEPlay("recall") if !fromdebug
    pbPokemonBoxUpdate(true) if !fromdebug
  end

  # Updates the box itself (The progress bar, the text, the task and the icons)
  def pbPokemonBoxUpdate(showMillenialMessage=false)
    @sprites["overlayTask"].bitmap.clear
    @sprites["overlayTime"].bitmap.clear
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    imageposAMT=[]
    progress=[]
    progressTime=[]
    value=$game_variables[PBOX_VARIABLES[3]]
    shadowfract=taskstatus*100/taskstatus2
    remtime = boxDuration*86400
    shadowfract2=(value[1]-(pbGetTimeNow.to_f - value[0]))*100/remtime
    # Draw Task Icons
    progress.push(["Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress_small",@sprites["progress"].x,@sprites["progress"].y,0,0,-1,-1])
    progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_small",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*1.98).floor,-1])
    progress.push(["Graphics/UI/Pokemon Box/icons",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*$game_variables[PBOX_VARIABLES[1]][currentStep][0],34,34])
    progress.push(["Graphics/UI/Pokemon Box/icon_"+@icons[stepID],@sprites["progress_icon"].x,@sprites["progress_icon"].y,0,0,-1,-1])
    progress.push(["Graphics/UI/Pokemon Box/icon_markings",@sprites["progress_icon"].x+26,@sprites["progress_icon"].y+16,0,30*taskLevel(-1),36,30])
    # Draw Time Left graphics
    progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
      progressTime.push(["Graphics/UI/Pokemon Box/icon_clock",@sprites["progresstime"].x-28,@sprites["progresstime"].y-6,0,0,-1,-1])
    x = 116 - ([(boxItems.length - 1),4].min * 24)
    multiamt = 1
    multiamt = 2 if @milestoneDay && boxLevel>0
    for i in boxItems
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+14+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,@sprites["machine"].x+32+x.ceil,@sprites["machine"].y+34,2,Color.new(242,242,242),Color.new(12,12,12),true])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",@sprites["machine"].x+x.ceil,@sprites["machine"].y+14,0,0,-1,-1])
      end
      x+=(96.0/[(boxItems.length - 1),4].max)*2
    end
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
      hardBase=[Color.new(42,0,46),
                Color.new(0,46,46),
                Color.new(0,20,46),
                Color.new(46,0,0)]
      hardShadow=[Color.new(213,136,220),
                  Color.new(136,220,220),
                  Color.new(136,178,220),
                  Color.new(220,136,136)]
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      hardBase=[Color.new(235,199,239),
                Color.new(199,239,239),
                Color.new(199,219,239),
                Color.new(239,199,199)]

      hardShadow=[Color.new(86,0,94),
                  Color.new(0,94,94),
                  Color.new(0,47,94),
                  Color.new(94,0,0)]
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    numberbase=(isHardTask()) ? hardBase[taskLevel() - 1] : baseColor
    numbershadow=(isHardTask()) ? hardShadow[taskLevel() - 1] : shadowColor
    @sprites["progress_w"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_hardtask_wrapper"))
    @sprites["progress_w"].bitmap.hue_change(getTaskHue())
    @sprites["progress_w"].visible=isHardTask()
    
    textpos=[
       [_INTL("{1}/{2}",[taskstatus,taskstatus2].min,taskstatus2),(Graphics.width/4)-39+15,40,2,base2,shadow2,true],
    ]
    pbDrawShadowText(@sprites["overlayTask"].bitmap,0,0,(Graphics.width / 2)-28,38,taskname,numberbase,numbershadow,1)
    textposTime=[
       [_INTL("Time Remaning"),(Graphics.width/4),294,2,baseColor,shadowColor],
       [_INTL("{1}",pbTimeEventRemainingTime(PBOX_VARIABLES[3])),(Graphics.width/4)+15,330,2,base2,shadow2,true],
    ]
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    @sprites["overlayTask"].z = 3
    # Task
    pbDrawImagePositions(@sprites["overlayTask"].bitmap,progress)
    pbDrawTextPositions(@sprites["overlayTask"].bitmap,textpos)
    # Time Left
    pbDrawImagePositions(@sprites["overlayTime"].bitmap,progressTime)
    pbDrawTextPositions(@sprites["overlayTime"].bitmap,textposTime)
    # Other
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    pbDrawTextPositions(@sprites["overlayItems"].bitmap,imageposAMT)
    @sprites["header"].text=_INTL("{1} Pokémon Box - Win Streak: {2}",boxName, currentStreak)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    #@sprites["bgM"].visible=@milestoneDay
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    update_icons
    if showMillenialMessage
      if isMillenial?
        Kernel.pbMessage(_INTL("{1} Milestone Ahead!",boxName(true)))
      end
      Kernel.pbMessage(_INTL("Finish this box within a 3-day interval to receive special rewards.")) if isMillenial?
    end
  end
  
  def animateTaskPane(from=255,into=0)
    zoom=from.to_f
    dec=(from.to_f - into.to_f) / 10.0
    10.times do
      Graphics.update
      Input.update
      zoom-=dec
      @sprites["overlayTask"].opacity=zoom
      @sprites["overlayTask"].zoom_x=zoom / 255
      @sprites["overlayTask"].zoom_y=zoom / 255
      @sprites["overlayTask"].ox=((Graphics.width / 4)-14)*((255-zoom)/-255) * 1/(zoom/255) if zoom !=0
      @sprites["overlayTask"].oy=39*((255-zoom)/-255) * 1/(zoom/255) if zoom !=0
    end
  end
  
  def refreshTask
    pbPlayEquipSE()
    animateTaskPane(255,0)
    $game_variables[PBOX_VARIABLES[1]][currentStep][1] = $PokemonGlobal.pokebox[ $game_variables[PBOX_VARIABLES[1]][currentStep][0] ]
    pbPokemonBoxUpdate(false)
    animateTaskPane(0,255)
  end
  
  # Used to check if the box should advance itself
  def pbPokemonBoxAdvance
    if taskstatus >= taskstatus2
      oldstep =currentStep%4
      hardtask = isHardTask(oldstep)
      oldtasklevel = taskLevel(oldstep)
      $game_variables[PBOX_VARIABLES[0]]+=1
      $game_variables[PBOX_VARIABLES[4]]=0 # Reset Substep
      update_icons(true)
      if oldtasklevel == 4
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Master Task Completed and you've got rewards."))
        quantity = (boxLevel+(4*currentBoxDif))*2
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
        quantity2 = (boxLevel+(4*currentBoxDif)) - 1
        Kernel.pbReceiveItem(:EXPCANDYS,quantity2)
      elsif oldtasklevel == 3
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Expert Task Completed and you've got rewards."))
        quantity = (boxLevel+(4*currentBoxDif))*2
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
        quantity2 = (boxLevel+(4*currentBoxDif)) - 1
        Kernel.pbReceiveItem(:EXPCANDYXS,quantity2)
      elsif oldtasklevel == 2
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Super Hard Task Completed and you've got a reward."))
        quantity = (boxLevel+(4*currentBoxDif))*2
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
      elsif oldtasklevel == 1
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Hard Task Completed and you've got a reward."))
        quantity = (boxLevel+(4*currentBoxDif))
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
      else
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Task Completed"))
      end
      if $game_variables[PBOX_VARIABLES[0]] > 3
        animateTaskPane(255,0)
        close_box
        pbSEPlay("Item3",100,80)
        if isMillenial?
          Kernel.pbMessage(_INTL("{1} Box Completed. Here's your rewards",boxName(true)))
        else
          Kernel.pbMessage(_INTL("Box Completed. Here's your rewards"))
        end
        multiamt = 1
        multiamt = 2 if @milestoneDay && boxLevel>0
        for i in boxItems
          if i.is_a?(Array)
            item=i[0]
            amt=i[1]*multiamt
          else
            item=i
            amt=1*multiamt
          end
          Kernel.pbReceiveItem(item,amt)
        end
        oldstreak = currentStreak
        oldstage  = currentStage
        $game_variables[PBOX_VARIABLES[2]]+=1
        $game_variables[PBOX_VARIABLES[2]]=0 if oldstreak == 65535
        stage=boxName() rescue ""
        if oldstreak == 65535
          pbSEPlay("Battle effect message")
          Kernel.pbMessage(_INTL("Extraodinary! You've maxed out the Pokémon Box. You'll get a special prize."))
          Kernel.pbReceiveItem(:MASTERBALL,5*multiamt)
        end
            scene=PokemonBoxSummaryScene.new
            screen=PokemonBoxSummary.new(scene)
            pbFadeOutIn(99999) { 
              screen.pbStartScreen(oldstage,currentStage)
            }
        initializeBox
        animateTaskPane(0,255)
      else
        # Refresh Task
        refreshTask
      end
    end
  end
  
  # Closes out the Pokemon Box container itself
  def close_box
    @sprites["progress_w"].visible=false
    @sprites["task0"].visible= false
    @sprites["task1"].visible= false
    @sprites["task2"].visible= false
    @sprites["task3"].visible= false
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    imageposAMT=[]
    x = 116 - ([(boxItems.length - 1),4].min * 24)
    idx=0
    multiamt = 1
    multiamt = 2 if @milestoneDay && boxLevel>0
    for i in boxItems
      idx+=1
      if idx == 1 || idx == boxItems.length
        y = 70
      else
        y = 54
      end
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+y+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,@sprites["machine"].x+32+x.ceil,@sprites["machine"].y+y+20,2,Color.new(242,242,242),Color.new(12,12,12),true])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",@sprites["machine"].x+x.ceil,@sprites["machine"].y+y,0,0,-1,-1])
      end
      x+=(96.0/[(boxItems.length - 1),4].max)*2
    end
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    pbDrawTextPositions(@sprites["overlayItems"].bitmap,imageposAMT)
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}_closed",currentStage(false),stageSuffix))
  end
  
  # Updates the icons in the Pokemon Box container itself
  def update_icons(nohardmarkers=false)
#icon_{1}",@icons[0]
    @sprites["task0"].visible= true
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[0],getTaskLabel(0,nohardmarkers)))
    @sprites["task0"].bitmap.hue_change(getTaskHue(0,nohardmarkers))
    @sprites["task1"].visible= true
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[1],getTaskLabel(1,nohardmarkers)))
    @sprites["task1"].bitmap.hue_change(getTaskHue(1,nohardmarkers))
    @sprites["task2"].visible= true
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[2],getTaskLabel(2,nohardmarkers)))
    @sprites["task2"].bitmap.hue_change(getTaskHue(2,nohardmarkers))
    @sprites["task3"].visible= true
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[3],getTaskLabel(3,nohardmarkers)))
    @sprites["task3"].bitmap.hue_change(getTaskHue(3,nohardmarkers))
  end
  
  def changeBoxTask
    maxtimes = ($game_variables[PBOX_VARIABLES[1]].length/4).floor - 1
    availabletimes = maxtimes - $game_variables[PBOX_VARIABLES[4]]
    extratext = (taskstatus==0) ? "" : _INTL(" Any progress done on this one will be lost.")
    if $game_variables[PBOX_VARIABLES[4]]>=maxtimes
      Kernel.pbMessage(_INTL("You can't change this task any longer."))
    elsif Kernel.pbConfirmMessage(_INTL("Are you sure you want to change this task? You can change it {1} times.{2}",availabletimes,extratext))
      $game_variables[PBOX_VARIABLES[4]]+=1
      refreshTask
    end
  end
  
  def showTaskInfo
    Kernel.pbMessage(_INTL("\\l[2]{1}",$PokemonGlobal.pokeboxDescriptions[ $game_variables[PBOX_VARIABLES[1]][currentStep][0] ]))
    if taskLevel() == 4
      quantity = (boxLevel+(4*currentBoxDif))*2
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      quantity2 = (boxLevel+(4*currentBoxDif)) - 1
      itemname2 = (quantity2>1) ? PBItems.getNamePlural(PBItems::EXPCANDYS) : PBItems.getName(PBItems::EXPCANDYS)
      Kernel.pbMessage(_INTL("Completing this Master task gives you {1} {2} and {3} {4}.", quantity, itemname, quantity2, itemname2))
    elsif taskLevel() == 3
      quantity = (boxLevel+(4*currentBoxDif))*2
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      quantity2 = (boxLevel+(4*currentBoxDif)) - 1
      itemname2 = (quantity2>1) ? PBItems.getNamePlural(PBItems::EXPCANDYXS) : PBItems.getName(PBItems::EXPCANDYXS)
      Kernel.pbMessage(_INTL("Completing this Expert task gives you {1} {2} and {3} {4}.", quantity, itemname, quantity2, itemname2))
    elsif taskLevel() == 2
      quantity = (boxLevel+(4*currentBoxDif))*2
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      Kernel.pbMessage(_INTL("Completing this Super Hard task gives you {1} {2}.", quantity, itemname))
    elsif taskLevel() == 1
      quantity = (boxLevel+(4*currentBoxDif))
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      Kernel.pbMessage(_INTL("Completing this Hard task gives you {1} {2}.", quantity, itemname))
    end
  end
  
  def pbPokemonBoxScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::A)
        changeBoxTask
      end
      # Left Mouse Key
      if Input.triggerex?(Input::LeftMouseKey)
        mousepos=Mouse::getMousePos(true)
        # Only if Mouse Position can be found
        if mousepos
          # Task Pane
          taskrect=[4,196,(Graphics.width/2)-8,82]
          if contains2(taskrect,mousepos[0],mousepos[1])
            showTaskInfo
          end
          # Time Pane
          taskrect2=[4,290,(Graphics.width/2)-8,82]
          if contains2(taskrect2,mousepos[0],mousepos[1])
            Kernel.pbMessage(_INTL("Keep an eye on the time. If the time expires, your win streak resets and you'll start over with a {1} box.",@stages[0][0]))
          end
          # Box itself
          boxrect=[@sprites["machine"].x,@sprites["machine"].y,280,140]
          if contains2(boxrect,mousepos[0],mousepos[1])
            pbPlayDecisionSE()
            scene=PokemonBoxSummaryScene.new
            screen=PokemonBoxSummary.new(scene)
            pbFadeOutIn(99999) { 
              screen.pbStartScreen
            }
          end
        end
      end
     # End Left Mouse Key
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

  def contains2(rect,x,y)
    return x>=rect[0] && x<rect[0]+rect[2] &&
           y>=rect[1] && y<rect[1]+rect[3]
  end

class PokemonBoxEvent # Not PokemonBox as it conflicts with another class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(expired=false)
    @scene.pbStartScene(expired)
    @scene.pbPokemonBoxScreen
    @scene.pbEndScene
  end
end

#===============================================================================
# Pokémon Box summary screen
#===============================================================================
class PokemonBoxSummaryScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(oldlevel=-1,newlevel=-1) # OLd level = Last stage | New level = Current Stage
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_menu",@viewport)
    @sprites["bgM"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
    @sprites["bgM"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_milestone_full"))
    @sprites["bgM"].opacity= 96
    @sprites["bgM"].visible=$PokemonBox.milestoneDay
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokémon Box"),
       2,-18,256,64,@viewport)
    if (!isDarkMode?)
      base=Color.new(12,12,12)
      shadow=Color.new(242,242,242)
    else
      base=Color.new(242,242,242)
      shadow=Color.new(12,12,12)
    end
    @sprites["header"].baseColor=base
    @sprites["header"].shadowColor=nil #shadow
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    elite=$PokemonBox.currentStage(false) != $PokemonBox.currentStage
    @currentStage=( (oldlevel != -1) && (newlevel>oldlevel) && !elite) ? oldlevel : $PokemonBox.currentStage
    @maxpages=($PokemonBox.stages.length / 8.0).ceil - 1
    @page=((@currentStage+1) / 8.0).ceil - 1
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = Graphics.width/2 - 14
    @sprites["uparrow"].y = 16
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = Graphics.width/2 - 14
    @sprites["downarrow"].y = Graphics.height - 32
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = @page != @maxpages
    for item in 0...8
      x=[4,324,4,324,4,324,4,324][item%8]
      y=[36,36,126,126,216,216,306,306][item%8]
      @sprites["boxname#{item}"]=Window_AdvancedTextPokemon.newWithSize("",x-3,y-13,128,64,@viewport)
      @sprites["boxname#{item}"].windowskin=nil
      @sprites["boxname#{item}"].z=2
      @sprites["box#{item}"]=IconSprite.new(x+10,y+13,@viewport)
      @sprites["box#{item}"].setBitmap("")
      @sprites["box#{item}"].visible=false
      @sprites["box#{item}"].z=3
      @sprites["padlock#{item}"]=IconSprite.new(x+33,y+9,@viewport)
      @sprites["padlock#{item}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menuwrapper_locked")
      @sprites["padlock#{item}"].visible=false
      @sprites["padlock#{item}"].z=4
    end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawPokemonBoxSummaryContents
    pbFadeInAndShow(@sprites) { update }
    if (oldlevel != -1) && (newlevel>oldlevel) && !elite
      # Close previous level
      pbSEPlay("King's Shield")
      @sprites["boxname#{oldlevel%8}"].text="<ac>"+$PokemonBox.stages[oldlevel][0]+"</ac>"
      @sprites["box#{oldlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + oldlevel.to_s + "_closed")
      @sprites["padlock#{oldlevel%8}"].visible=false
      40.times do
        Graphics.update
      end
      # Switch to new page, if needed
      oldpage=@page
      newpage=((newlevel+1) / 8.0).ceil - 1
      @page=[oldpage,newpage].max
      pbDrawPokemonBoxSummaryContents if @page != oldpage # Redraw contents
      # Unlock new box
      pbSEPlay("Battle effect message")
      @sprites["padlock#{newlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menuwrapper_locked_2")
      20.times do
        Graphics.update
      end
      opa=255
      20.times do
        Graphics.update
        opa-=255/20
        @sprites["padlock#{newlevel%8}"].opacity=opa
      end
      @sprites["boxname#{newlevel%8}"].text=""
      @sprites["box#{newlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + newlevel.to_s)
      @sprites["padlock#{newlevel%8}"].visible=false
      40.times do
        Graphics.update
      end
    elsif (oldlevel != -1) && (newlevel != -1) && (newlevel >= $PokemonBox.stages.length-5)
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("Spectacular! Keep completing out {1} Pokémon Boxes.",$PokemonBox.boxName()))
    elsif (oldlevel != -1) && (oldlevel>newlevel) && !elite
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("You made it! Let's start over from the {1} Pokémon Box.",$PokemonBox.boxName()))
    elsif (oldlevel != -1) && (oldlevel==newlevel) && !elite
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("Awesome! Let's continue with another {1} Pokémon Box.",$PokemonBox.boxName()))
    end
  end

  def pbDrawPokemonBoxSummaryContents
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"].visible = @page != @maxpages
    @overlay=@sprites["overlay"].bitmap
    @overlay.clear
    offset=8*@page
    for item in 0+offset...8+offset
      x=[4,324,4,324,4,324,4,324][item%8]
      y=[36,36,126,126,216,216,306,306][item%8]
      pbDrawBoxContents(x,y,item)
    end
  end

  def pbDrawBoxContents(x,y,stage)
    if stage >= $PokemonBox.stages.length
      @sprites["boxname#{stage%8}"].text=""
      @sprites["box#{stage%8}"].setBitmap("")
      @sprites["padlock#{stage%8}"].visible=false
      return
    end
    filename=stage.to_s
    filename=($PokemonBox.maxStages-1).to_s + "_elite" if stage==$PokemonBox.maxStages
    filename=($PokemonBox.maxStages-1).to_s + "_legendary" if stage==$PokemonBox.maxStages + 1
    filename=($PokemonBox.maxStages-1).to_s + "_mythical" if stage==$PokemonBox.maxStages + 2
    filename=($PokemonBox.maxStages-1).to_s + "_demon" if stage==$PokemonBox.maxStages + 3
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
      hardBase=Color.new(248,56,32)
      hardShadow=Color.new(224,152,144)
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      hardBase=Color.new(224,152,144)
      hardShadow=Color.new(248,56,32)
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    # Box
    imagepos=[
      ["Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_menuwrapper",x,y,0,0,-1,-1],
    ]
    imageposAMT=[]
    boxitems=$PokemonBox.boxItems(stage)
    # Items
    itemx = 182 - ([(boxitems.length - 1),3].min * 24)
    multiamt = 1
    multiamt = 2 if $PokemonBox.milestoneDay && $PokemonBox.stages[stage][4]>0
    for i in boxitems
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),x+itemx.ceil+offsetX,y+13+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,x+32+itemx.ceil,y+33,2,Color.new(242,242,242),Color.new(12,12,12),true])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",x+itemx.ceil,y+13,0,0,-1,-1])
      end
      itemx+=(96.0/[(boxitems.length - 1),3].max)*1.5
    end
    # Box Name
    @sprites["box#{stage%8}"].visible=true
    if @currentStage == stage
      @sprites["boxname#{stage%8}"].text=""
      @sprites["box#{stage%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + filename)
      @sprites["padlock#{stage%8}"].visible=false
    else
      @sprites["boxname#{stage%8}"].text="<ac>"+$PokemonBox.stages[stage][0]+"</ac>"
      @sprites["box#{stage%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + filename + "_closed")
      @sprites["padlock#{stage%8}"].visible=@currentStage<stage
    end
    pbDrawImagePositions(@overlay,imagepos)
    pbSetSmallFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@overlay,imageposAMT)

  end

  def pbPokemonBoxSummaryScreen(oldlevel=-1,newlevel=-1)
    briefmode=(oldlevel != -1) && (newlevel != -1)
    loop do
      Graphics.update
      Input.update
      self.update
      break if briefmode
      if Input.trigger?(Input::DOWN) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page+1)%(@maxpages+1)
        pbDrawPokemonBoxSummaryContents
      end
      if Input.trigger?(Input::UP) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page-1)%(@maxpages+1)
        pbDrawPokemonBoxSummaryContents
      end
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonBoxSummary # Not PokemonBox as it conflicts with another class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(oldlevel=-1,newlevel=-1)
    @scene.pbStartScene(oldlevel,newlevel)
    @scene.pbPokemonBoxSummaryScreen(oldlevel,newlevel)
    @scene.pbEndScene
  end
end