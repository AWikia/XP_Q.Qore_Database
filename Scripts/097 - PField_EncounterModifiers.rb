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


# Species Alias (Replaces it with another one when a condition is met but only 
# when not using the Test Wild Battle or Test Double Wild Battle Debug options)
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   species=pokemon.species
   time=pbGetTimeNow if !time
   # Some Common Species evolutions
   ghosts = [PBSpecies::BLINKY,
             PBSpecies::INKY,
             PBSpecies::CLYDE,
             PBSpecies::PINKY,
             PBSpecies::SUE,
             PBSpecies::FUNKY,
             PBSpecies::SPUNKY,
             PBSpecies::ORSON]
   # pokemons var is an associative array. Each item has a key, followed by an
   # arry of two items. The first item includes the species and the second one
   # includes the condition required to replace the species
   pokemons = {
     # Wikiboos - Unbooks
     PBSpecies::WIKIBOOKS => [PBSpecies::UNBOOKS,(rand(100)<50)],
     PBSpecies::UNBOOKS => [PBSpecies::WIKIBOOKS,(rand(100)<50)],
     # Wikipedia - Uncyclopedia
     PBSpecies::WIKIPEDIA => [PBSpecies::UNCYCLOPEDIA,(rand(100)<50)],
     PBSpecies::UNCYCLOPEDIA => [PBSpecies::WIKIPEDIA,(rand(100)<50)],
     # Wikinews - Unnews
     PBSpecies::WIKINEWS => [PBSpecies::UNNEWS,(rand(100)<50)],
     PBSpecies::UNNEWS => [PBSpecies::WIKINEWS,(rand(100)<50)],
     # Wiktionary - Undictionary
     PBSpecies::WIKTIONARY => [PBSpecies::UNDICTIONARY,(rand(100)<50)],
     PBSpecies::UNDICTIONARY => [PBSpecies::WIKTIONARY,(rand(100)<50)],
     # Wikidata - Undata
     PBSpecies::WIKIDATA => [PBSpecies::UNDATA,(rand(100)<50)],
     PBSpecies::UNDATA => [PBSpecies::WIKIDATA,(rand(100)<50)],
     # Wikiquote - Unquotable
     PBSpecies::WIKIQUOTE => [PBSpecies::UNQUOTABLE,(rand(100)<50)],
     PBSpecies::UNQUOTABLE => [PBSpecies::WIKIQUOTE,(rand(100)<50)],
     # Wikiversity - Uncycloversity
     PBSpecies::WIKIVERSITY => [PBSpecies::UNCYCLOVERSITY,(rand(100)<50)],
     PBSpecies::UNCYCLOVERSITY => [PBSpecies::WIKIVERSITY,(rand(100)<50)],
     # Wikivoyage - Unvoyage
     PBSpecies::WIKIVOYAGE => [PBSpecies::UNVOYAGE,(rand(100)<50)],
     PBSpecies::UNVOYAGE => [PBSpecies::WIKIVOYAGE,(rand(100)<50)],
     # Wikispecies - Unforum
     PBSpecies::WIKISPECIES => [PBSpecies::UNFORUM,(rand(100)<50)],
     PBSpecies::UNFORUM => [PBSpecies::WIKISPECIES,(rand(100)<50)],
     # Frikimania - Fricyclomania
     PBSpecies::FRIKIMANIA => [PBSpecies::FRICYCLOMANIA,(rand(100)<50)],
     PBSpecies::FRICYCLOMANIA => [PBSpecies::FRIKIMANIA,(rand(100)<50)],
     # Sharpenix - Rolonix
     PBSpecies::SHARPENIX => [PBSpecies::ROLONIX,(rand(100)<50)],
     PBSpecies::ROLONIX => [PBSpecies::SHARPENIX,(rand(100)<50)],
     # MTV - WTV
     PBSpecies::MTV => [PBSpecies::WTV, (time.mon == 3 && time.day == 8)],
     PBSpecies::WTV => [PBSpecies::MTV, (time.mon == 3 && time.day == 8)],
     # Delia MTV - Delia WTV
     PBSpecies::DMTV => [PBSpecies::DWTV, (time.mon == 3 && time.day == 8)],
     PBSpecies::DWTV => [PBSpecies::DMTV, (time.mon == 3 && time.day == 8)],
     # Blueshost - Any of its evolutions
     PBSpecies::BLUEGHOST => [ghosts[rand(8)], (time.mon == 4 && time.day == 1)]
   }
   if pokemons.key?(species) && !$game_switches[40]
     if pokemons[species][1]
       	 pokemon.species=pokemons[species][0]
         pokemon.name=PBSpecies.getName(pokemon.species)
         pokemon.calcStats
         pokemon.resetMoves
      end
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
         newlevel=pbBalancedLevel($Trainer.party) - [20,15,10,5,5][[$game_variables[1003]-1,4].min] + rand([5,5,10,15,20][[$game_variables[1003]-1,4].min])   # For variety
         newlevel=1 if newlevel<1
         newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
       	 pok.species=sp
         pok.name=PBSpecies.getName(sp)
         pok.calcStats
         pok.level=newlevel
         pok.calcStats
         pok.resetMoves
         if $game_variables[1003] > 5
           pok.pbLearnMove(:REVIVALBLESSING)
           pok.setItem(:PHOTONCLAW)  if rand(100)<25
         end
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