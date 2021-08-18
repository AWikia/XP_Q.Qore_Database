def get_new_index(index)
  if (index>=494 and index<=699 || index>=856) # Banned Pokemon species
    return 1
  #  return index+156
  elsif index>=700
    return index-206
  else
    return index
  end
end


def get_qore_index(index)
    return index
end

def timecapQV # IE => Q.Qore
  drive=ENV["HOMEDRIVE"]
  if !drive
    drive="C:\\"
  end
  home=["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  migrated=""+drive+ENV[home]+"\\Saved Games\\Time Capsule\\migratedQV.txt"
  if !safeExists?(migrated)
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  master=IO.read(migrated)
  master=pbMysteryGiftDecrypt(IO.read(migrated))
  if !master || !master.is_a?(Array) || master.length==0
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  if master.length==1
    Kernel.pbMessage(_INTL("\\rOh! A new Pokémon just arrived."))
  elsif master.length>1
    Kernel.pbMessage(_INTL("\\rOh! New Pokémon have arrived."))
  end
  for pkmn in master
    pkmn.species=get_qore_index(pkmn.species)
    if pkmn.name==PBSpecies.getName(pkmn.species).upcase
      pkmn.name=PBSpecies.getName(pkmn.species)
    end
    pkmn.obtainMode=5
    pkmn.obtainLevel=pkmn.level
    if $game_map
      pkmn.obtainMap=$game_map.map_id
    end
    pkmn.migrated=true
    pbAddPokemon(pkmn)
    newspecies=pbTradeCheckEvolution(pkmn,pkmn)
    if newspecies>0
      evo=PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn,newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen        
      if pkmn.name==PBSpecies.getName(pkmn.species)
        pkmn.name=PBSpecies.getName(newspecies)
      end

    end
  end
  File.delete(migrated)
  Kernel.pbReceiveTrophy(:TMIGTATOR)
  pbSaveScreen
  return true
end

def timecapQQ # Q.Qore => IE
  drive=ENV["HOMEDRIVE"]
  if !drive
    drive="C:\\"
  end
  home=["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  migrated=""+drive+ENV[home]+"\\Saved Games\\Time Capsule\\migratedQQ.txt"
  if !safeExists?(migrated)
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  master=IO.read(migrated)
  master=pbMysteryGiftDecrypt(IO.read(migrated))
  if !master || !master.is_a?(Array) || master.length==0
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  if master.length==1
    Kernel.pbMessage(_INTL("\\rOh! A new Pokémon just arrived."))
  elsif master.length>1
    Kernel.pbMessage(_INTL("\\rOh! New Pokémon have arrived."))
  end
  for pkmn in master
    pkmn.species=get_qore_index(pkmn.species)
    if pkmn.name==PBSpecies.getName(pkmn.species).upcase
      pkmn.name=PBSpecies.getName(pkmn.species)
    end
    pkmn.obtainMode=5
    pkmn.obtainLevel=pkmn.level
    if $game_map
      pkmn.obtainMap=$game_map.map_id
    end
    pkmn.migrated=true
    pbAddPokemon(pkmn)
    newspecies=pbTradeCheckEvolution(pkmn,pkmn)
    if newspecies>0
      if pkmn.name==PBSpecies.getName(pkmn.species)
        pkmn.name=PBSpecies.getName(newspecies)
      end
      evo=PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn,newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen        
    end
  end
  File.delete(migrated)
  Kernel.pbReceiveTrophy(:TMIGTATOR)
  pbSaveScreen
  return true
end



def timecapPF # PFG
  drive=ENV["HOMEDRIVE"]
  if !drive
    drive="C:\\"
  end
  home=["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  migrated=""+drive+ENV[home]+"\\Saved Games\\Time Capsule\\migrated.txt"
  if !safeExists?(migrated)
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  master=IO.read(migrated)
  master=pbMysteryGiftDecrypt(IO.read(migrated))
  if !master || !master.is_a?(Array) || master.length==0
  Kernel.pbMessage(_INTL("\\rWe have no migrated Pokémon at this time."))
  return false
  end
  if master.length==1
    Kernel.pbMessage(_INTL("\\rOh! A new Pokémon just arrived."))
  elsif master.length>1
    Kernel.pbMessage(_INTL("\\rOh! New Pokémon have arrived."))
  end
  for pkmn in master
    pkmn.species=get_new_index(pkmn.species)
    if pkmn.name==PBSpecies.getName(pkmn.species).upcase
      pkmn.name=PBSpecies.getName(pkmn.species)
    end
    pkmn.obtainMode=5
    pkmn.obtainLevel=pkmn.level
    if $game_map
      pkmn.obtainMap=$game_map.map_id
    end
    pkmn.migrated=true
    pbAddPokemon(pkmn)
    newspecies=pbTradeCheckEvolution(pkmn,pkmn)
    if newspecies>0
      if pkmn.name==PBSpecies.getName(pkmn.species)
        pkmn.name=PBSpecies.getName(newspecies)
      end
      evo=PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn,newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen        
    end
  end
  File.delete(migrated)
  Kernel.pbReceiveTrophy(:TMIGTATOR)
  pbSaveScreen
  return true
end
