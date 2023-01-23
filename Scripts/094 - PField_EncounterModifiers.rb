################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[SHINY_WILD_POKEMON_SWITCH]
     pokemon.makeShiny
   end
}


# Deoxys and 10% Zygarde
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[79]
        pokemon.form=1
        pbSeenForm(pokemon)
    end
}

# 100% Zygarde
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[132]
        pokemon.form=2
        pbSeenForm(pokemon)
    end
}


# Make all wild Pokémon have a chance to have their hidden ability.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if rand(100) < 5 &&
     !($game_map.map_id==22 || $game_map.map_id==32 || $game_map.map_id==33 ||
       $game_map.map_id==378 || $game_map.map_id==400)
     pokemon.setAbility([2,3,4][rand(3)])
   end
}


# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_map.map_id==51 || $game_map.map_id==334 ||
     $game_map.map_id==335 || $game_map.map_id==336 ||
     $game_map.map_id==338 || $game_map.map_id==370 ||
     $game_map.map_id==394 || $game_map.map_id==423
     newlevel=pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
     newlevel=1 if newlevel<1
     newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
     pokemon.level=newlevel
     pokemon.calcStats
     pokemon.resetMoves
     # $game_variables[1003] > 0
   end
}

# Used For Link Battle
Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     if  $game_variables[1003] > 0
       leng=(party.length) - 1
       for i in 0..leng
         # Set Level
         pok=party[i]
         sp=rand(PBSpecies.maxValue) # 1255  
         newlevel=pbBalancedLevel($Trainer.party) - [20,15,10,5,5][$game_variables[1003]-1] + rand([5,5,10,15,20][$game_variables[1003]-1])   # For variety
         newlevel=1 if newlevel<1
         newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
       	 pok.species=sp
         pok.name=PBSpecies.getName(sp)
         pok.calcStats
         pok.level=newlevel
         pok.calcStats
         pok.resetMoves
         # End
       end
     end
   end
}


# This is the basis of a trainer modifier.  It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#Events.onTrainerPartyLoad+=proc {|sender,e|
#   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
#     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
#     items=e[0][1]   # An array of the trainer's items they can use
#     party=e[0][2]   # An array of the trainer's Pokémon
#     YOUR CODE HERE
#   end
#}