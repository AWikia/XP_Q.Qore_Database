#===============================================================================
# * Family Tree - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pok?mon Essentials. It displays a sixth page at pok?mon
# summary showing a little info about the pok?mon mother, father, grandmothers
# and grandfathers if the pok?mon has any.
#
#===============================================================================
#
# To this script works, put it above main, put a 512x384 background for this
# screen in "Graphics/Pictures/summary6" and in "Graphics/Pictures/summaryEgg6".
# This last one is only necessary if SHOWFAMILYEGG is true. You also need to
# update the below pictures in order to reflect the summary icon change:
# - summary1
# - summary2
# - summary3
# - summary4
# - summary4details
# - summary5
#
# -At PokemonDayCare, before line '$Trainer.party[$Trainer.party.length]=egg'
# add line 'egg.family = PokemonFamily.new(egg, father, mother)'
#
# -At PokemonSummary, change both lines '@page=4 if @page>4'
# to '@page=5 if @page>5'
#
# -Before line 'if Input.trigger?(Input::UP) && @partyindex>0'
# add line 'handleInputsEgg'
#
# -Change line 'if @page!=0' to 'if @page!=0 && !(SHOWFAMILYEGG && @page==5)'
#
# -After line 'drawPageFive(@pokemon)' add
#
# when 5
#  drawPageSix(@pokemon)
#
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor :family
end

class PokemonFamily
  MAXGENERATIONS = 3 # Tree stored generation limit
  
  attr_reader :mother # PokemonFamily object
  attr_reader :father # PokemonFamily object
  
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :name # nickname
  # You can add more data here and on initialize class. Just 
  # don't store the entire pok?mon object.
  
  def initialize(pokemon, father=nil,mother=nil)
    initializedAsParent = !father || !mother
    if pokemon.family && pokemon.family.father
      @father = pokemon.family.father
    elsif father 
      @father = PokemonFamily.new(father)
    end
    if pokemon.family && pokemon.family.mother
      @mother = pokemon.family.mother
    elsif mother
      @mother = PokemonFamily.new(mother)
    end
    
    # This data is only initialized as a parent in a cub.
    if initializedAsParent 
      @species=pokemon.species
      @gender=pokemon.gender
      @name=pokemon.name
      @form=pokemon.form
    end
    
    applyGenerationLimit(MAXGENERATIONS)
  end
  
  def applyGenerationLimit(generation)
    if generation>1
      father.applyGenerationLimit(generation-1) if @father
      mother.applyGenerationLimit(generation-1) if @mother
    else
      father=nil
      mother=nil
    end  
  end 
  
  def [](value) # [0] = father, [1] = mother
    if value==0
    return @father
    elsif value==1
    return @mother
    end
    return nil
  end
end  

#===============================================================================
# * Day Care
#===============================================================================
def pbEggGenerated?
  return false if pbDayCareDeposited!=2
  return $PokemonGlobal.daycareEgg==1
end

def pbDayCareDeposited
  ret=0
  for i in 0...2
    ret+=1 if $PokemonGlobal.daycare[i][0]
  end
  return ret
end

def pbDayCareDeposit(index)
  for i in 0...2
    if !$PokemonGlobal.daycare[i][0]
      $PokemonGlobal.daycare[i][0]=$Trainer.party[index]
      $PokemonGlobal.daycare[i][1]=$Trainer.party[index].level
      $PokemonGlobal.daycare[i][0].heal
      $Trainer.party[index]=nil
      $Trainer.party.compact!
      $PokemonGlobal.daycareEgg=0
      $PokemonGlobal.daycareEggSteps=0
      return
    end
  end
  raise _INTL("No room to deposit a Pokémon") 
end

def pbDayCareGetLevelGain(index,nameVariable,levelVariable)
  pkmn=$PokemonGlobal.daycare[index][0]
  return false if !pkmn
  $game_variables[nameVariable]=pkmn.name
  $game_variables[levelVariable]=pkmn.level-$PokemonGlobal.daycare[index][1]
  return true
end

def pbDayCareGetDeposited(index,nameVariable,costVariable)
  for i in 0...2
    if (index<0||i==index) && $PokemonGlobal.daycare[i][0]
      cost=$PokemonGlobal.daycare[i][0].level-$PokemonGlobal.daycare[i][1]
      cost+=1
      cost*=100
      $game_variables[costVariable]=cost if costVariable>=0
      $game_variables[nameVariable]=$PokemonGlobal.daycare[i][0].name if nameVariable>=0
      return
    end
  end
  raise _INTL("Can't find deposited Pokémon")
end

def pbIsDitto?(pokemon)
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,pokemon.species,31)
  compat10=dexdata.fgetb
  compat11=dexdata.fgetb
  dexdata.close
  return isConst?(compat10,PBEggGroups,:Ditto) ||
         isConst?(compat11,PBEggGroups,:Ditto)
end

def pbDayCareCompatibleGender(pokemon1,pokemon2)
  if (pokemon1.isFemale? && pokemon2.isMale?) ||
     (pokemon1.isMale? && pokemon2.isFemale?)
    return true
  end
  ditto1=pbIsDitto?(pokemon1)
  ditto2=pbIsDitto?(pokemon2)
  return true if ditto1 && !ditto2
  return true if ditto2 && !ditto1
  return false
end

def pbDayCareGetCompat
  if pbDayCareDeposited==2
    pokemon1=$PokemonGlobal.daycare[0][0]
    pokemon2=$PokemonGlobal.daycare[1][0]
    return 0 if (pokemon1.isShadow? rescue false)
    return 0 if (pokemon2.isShadow? rescue false)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,pokemon1.species,31)
    compat10=dexdata.fgetb
    compat11=dexdata.fgetb
    pbDexDataOffset(dexdata,pokemon2.species,31)
    compat20=dexdata.fgetb
    compat21=dexdata.fgetb
    dexdata.close
    if !isConst?(compat10,PBEggGroups,:Undiscovered) &&
       !isConst?(compat11,PBEggGroups,:Undiscovered) &&
       !isConst?(compat20,PBEggGroups,:Undiscovered) &&
       !isConst?(compat21,PBEggGroups,:Undiscovered)
      if compat10==compat20 || compat11==compat20 ||
         compat10==compat21 || compat11==compat21 ||
         isConst?(compat10,PBEggGroups,:Ditto) ||
         isConst?(compat11,PBEggGroups,:Ditto) ||
         isConst?(compat20,PBEggGroups,:Ditto) ||
         isConst?(compat21,PBEggGroups,:Ditto)
        if pbDayCareCompatibleGender(pokemon1,pokemon2)
          ret=1
          ret+=1 if pokemon1.species==pokemon2.species
          ret+=1 if pokemon1.trainerID!=pokemon2.trainerID
          return ret
        end
      end
    end
  end
  return 0
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable]=pbDayCareGetCompat
end

def pbDayCareWithdraw(index)
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the Pokémon...")
  else
    $Trainer.party[$Trainer.party.length]=$PokemonGlobal.daycare[index][0]
    $PokemonGlobal.daycare[index][0]=nil
    $PokemonGlobal.daycare[index][1]=0
    $PokemonGlobal.daycareEgg=0
  end  
end

def pbDayCareChoose(text,variable)
  count=pbDayCareDeposited
  if count==0
    raise _INTL("There's no Pokémon here...")
  elsif count==1
    $game_variables[variable]=$PokemonGlobal.daycare[0][0] ? 0 : 1
  else
    choices=[]
    for i in 0...2
      pokemon=$PokemonGlobal.daycare[i][0]
      if pokemon.isMale?
        choices.push(_ISPRINTF("{1:s} (♂, Lv{2:d})",pokemon.name,pokemon.level))
      elsif pokemon.isFemale?
        choices.push(_ISPRINTF("{1:s} (♀, Lv{2:d})",pokemon.name,pokemon.level))
      else
        choices.push(_ISPRINTF("{1:s} (Lv{2:d})",pokemon.name,pokemon.level))
      end
    end
    choices.push(_INTL("CANCEL"))
    command=Kernel.pbMessage(text,choices,choices.length)
    $game_variables[variable]=(command==2) ? -1 : command
  end
end

def pbDayCareGenerateEgg
  if pbDayCareDeposited!=2
    return
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the egg")
  end
  pokemon0=$PokemonGlobal.daycare[0][0]
  pokemon1=$PokemonGlobal.daycare[1][0]
  mother=nil
  father=nil
  babyspecies=0
  ditto0=pbIsDitto?(pokemon0)
  ditto1=pbIsDitto?(pokemon1)
  if (pokemon0.isFemale? || ditto0)
    babyspecies=(ditto0) ? pokemon1.species : pokemon0.species
    babyform=(ditto0) ? pokemon1.form : pokemon0.form
    mother=pokemon0
    father=pokemon1
  else
    babyspecies=(ditto1) ? pokemon0.species : pokemon1.species
    babyform=(ditto1) ? pokemon0.form : pokemon1.form
    mother=pokemon1
    father=pokemon0
  end
  babyspecies=pbGetBabySpecies(babyspecies,mother.item,father.item)
  relicflower = false
  if (isConst?(babyspecies,PBSpecies,:MEDIAWIKI)) && babyform == 1 && (isConst?(mother.item,PBItems,:RELICFLOWER) || isConst?(father.item,PBItems,:RELICFLOWER))
    babyspecies=getConst(PBSpecies,:WIKITECH)
    relicflower = true
  elsif (isConst?(babyspecies,PBSpecies,:WIKITECH)) && babyform == 1 && (isConst?(mother.item,PBItems,:RELICFLOWER) || isConst?(father.item,PBItems,:RELICFLOWER))
    babyspecies=getConst(PBSpecies,:MEDIAWIKI)
    relicflower = true
  elsif (isConst?(babyspecies,PBSpecies,:PERILFIRE))
    babyspecies=getConst(PBSpecies,:FOXFIRE)
  elsif (isConst?(babyspecies,PBSpecies,:PERILGRASS))
    babyspecies=getConst(PBSpecies,:BRONGRASS)
  elsif (isConst?(babyspecies,PBSpecies,:PERILWATER))
    babyspecies=getConst(PBSpecies,:TURTLEWATER)
  elsif isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies=getConst(PBSpecies,:PHIONE)
  elsif (isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)) ||
        (isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE))
    babyspecies=[getConst(PBSpecies,:NIDORANmA),
                 getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)) ||
        (isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT))
    babyspecies=[getConst(PBSpecies,:VOLBEAT),
                 getConst(PBSpecies,:ILLUMISE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:KRISKRIS) && hasConst?(PBSpecies,:LG)) ||
        (isConst?(babyspecies,PBSpecies,:LG) && hasConst?(PBSpecies,:KRISKRIS))
    babyspecies=[getConst(PBSpecies,:KRISKRIS),
                 getConst(PBSpecies,:LG)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:SHARPENIX) && hasConst?(PBSpecies,:ROLONIX)) ||
        (isConst?(babyspecies,PBSpecies,:ROLONIX) && hasConst?(PBSpecies,:SHARPENIX))
    babyspecies=[getConst(PBSpecies,:SHARPENIX),
                 getConst(PBSpecies,:ROLONIX)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:ALTERCHANNEl) && hasConst?(PBSpecies,:MEGACHANNEL)) ||
        (isConst?(babyspecies,PBSpecies,:MEGACHANNEL) && hasConst?(PBSpecies,:ALTERCHANNEL))
    babyspecies=[getConst(PBSpecies,:ALTERCHANNEL),
                 getConst(PBSpecies,:MEGACHANNEL)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:GOOGOLOGY) && hasConst?(PBSpecies,:BLOOBLOLOGY)) ||
        (isConst?(babyspecies,PBSpecies,:BLOOBLOLOGY) && hasConst?(PBSpecies,:GOOGOLOGY))
    babyspecies=[getConst(PBSpecies,:GOOGOLOGY),
                 getConst(PBSpecies,:BLOOBLOLOGY)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:XBOX) && (hasConst?(PBSpecies,:BING) && hasConst?(PBSpecies,:AZURE) && hasConst?(PBSpecies,:VISUALSTUDIO) && hasConst?(PBSpecies,:VISUALSTUDIOCODE)) ) ||
        (isConst?(babyspecies,PBSpecies,:BING) && (hasConst?(PBSpecies,:XBOX) && hasConst?(PBSpecies,:AZURE) && hasConst?(PBSpecies,:VISUALSTUDIO) && hasConst?(PBSpecies,:VISUALSTUDIOCODE)) ) ||
        (isConst?(babyspecies,PBSpecies,:AZURE) && (hasConst?(PBSpecies,:XBOX) && hasConst?(PBSpecies,:BING) && hasConst?(PBSpecies,:VISUALSTUDIO) && hasConst?(PBSpecies,:VISUALSTUDIOCODE)) ) ||
        (isConst?(babyspecies,PBSpecies,:VISUALSTUDIO) && (hasConst?(PBSpecies,:XBOX) && hasConst?(PBSpecies,:BING) && hasConst?(PBSpecies,:AZURE) && hasConst?(PBSpecies,:VISUALSTUDIOCODE)) ) ||
        (isConst?(babyspecies,PBSpecies,:VISUALSTUDIOCODE) && (hasConst?(PBSpecies,:XBOX) && hasConst?(PBSpecies,:BING) && hasConst?(PBSpecies,:AZURE) && hasConst?(PBSpecies,:VISUALSTUDIO)) )
    babyspecies=[getConst(PBSpecies,:XBOX),
                 getConst(PBSpecies,:BING),
                 getConst(PBSpecies,:AZURE),
                 getConst(PBSpecies,:VISUALSTUDIO),
                 getConst(PBSpecies,:VISUALSTUDIOCODE)][rand(5)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLKSWAGEN) && (hasConst?(PBSpecies,:DEUTSCHEWELLE) && hasConst?(PBSpecies,:BMW)) ) ||
        (isConst?(babyspecies,PBSpecies,:DEUTSCHEWELLE) && (hasConst?(PBSpecies,:VOLKSWAGEN) && hasConst?(PBSpecies,:BMW)) ) ||
        (isConst?(babyspecies,PBSpecies,:BMW) && (hasConst?(PBSpecies,:DEUTSCHEWELLE) && hasConst?(PBSpecies,:VOLKSWAGEN)) )
    babyspecies=[getConst(PBSpecies,:VOLKSWAGEN),
                 getConst(PBSpecies,:DEUTSCHEWELLE),
                 getConst(PBSpecies,:BMW)][rand(3)]
  elsif (isConst?(babyspecies,PBSpecies,:CARREFOUR) && hasConst?(PBSpecies,:DIA)) ||
        (isConst?(babyspecies,PBSpecies,:DIA) && hasConst?(PBSpecies,:CARREFOUR))
    babyspecies=[getConst(PBSpecies,:CARREFOUR),
                 getConst(PBSpecies,:DIA)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:NAMCO) && hasConst?(PBSpecies,:BANDAI)) ||
        (isConst?(babyspecies,PBSpecies,:BANDAI) && hasConst?(PBSpecies,:NAMCO))
    babyspecies=[getConst(PBSpecies,:NAMCO),
                 getConst(PBSpecies,:BANDAI)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:MOTO) && hasConst?(PBSpecies,:MOTO)) ||
        (isConst?(babyspecies,PBSpecies,:LEGION) && hasConst?(PBSpecies,:LEGION))
    babyspecies=[getConst(PBSpecies,:MOTO),
                 getConst(PBSpecies,:LEGION)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:FABRIC) && (hasConst?(PBSpecies,:COPILOT) && hasConst?(PBSpecies,:DEVHOME)) ) ||
        (isConst?(babyspecies,PBSpecies,:COPILOT) && (hasConst?(PBSpecies,:FABRIC) && hasConst?(PBSpecies,:DEVHOME)) ) ||
        (isConst?(babyspecies,PBSpecies,:DEVHOME) && (hasConst?(PBSpecies,:FABRIC) && hasConst?(PBSpecies,:COPILOT)) )
    babyspecies=[getConst(PBSpecies,:FABRIC),
                 getConst(PBSpecies,:COPILOT),
                 getConst(PBSpecies,:DEVHOME)][rand(3)]
end
  # Generate egg
  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,$Trainer)
  # Randomise personal ID
  pid=rand(65536)
  pid|=(rand(65536)<<16)
  egg.personalID=pid
  # Relic Flower
  if relicflower
    egg.form=1
  end
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) ||
     isConst?(babyspecies,PBSpecies,:SHELLOS) ||
     isConst?(babyspecies,PBSpecies,:BASCULIN) ||
     isConst?(babyspecies,PBSpecies,:FLABEBE) ||
     isConst?(babyspecies,PBSpecies,:PUMPKABOO) ||
     isConst?(babyspecies,PBSpecies,:ORICORIO) ||
     isConst?(babyspecies,PBSpecies,:SQUAWKABILLY) ||
     isConst?(babyspecies,PBSpecies,:TATSUGIRI) ||
     isConst?(babyspecies,PBSpecies,:OK) || 
     isConst?(babyspecies,PBSpecies,:VODAFONE) || 
     isConst?(babyspecies,PBSpecies,:FOURE) || # MS Office Breds to 4E should be able to evolve to different Office forms
     # Wikimedia and Uncyclomedia should inherit forms when bred, 
     # not rollbacking back to Wikimedia Meta form
     isConst?(babyspecies,PBSpecies,:WIKIMEDIA) || 
     isConst?(babyspecies,PBSpecies,:UNCYCLOMEDIA) || 
     # Baby Wikimedia and Bombomedia, while only being single-formed, 
     # this form inherit allows these Pokemon to evolve with different form
     # such as evolving a Baby Wikimedia into a Wikimedia Ombusden.
     isConst?(babyspecies,PBSpecies,:WIKIMEDIAB) ||
     isConst?(babyspecies,PBSpecies,:BOMBOMEDIA) ||
     isConst?(babyspecies,PBSpecies,:KRISKRIS) || 
     isConst?(babyspecies,PBSpecies,:LG) || 
     isConst?(babyspecies,PBSpecies,:ETV) ||
     isConst?(babyspecies,PBSpecies,:PLUNUM) ||
     # Alolan Forms
     isConst?(babyspecies,PBSpecies,:RATTATA) ||
     isConst?(babyspecies,PBSpecies,:PICHU) ||
     isConst?(babyspecies,PBSpecies,:PIKACHU) ||
     isConst?(babyspecies,PBSpecies,:SANDSHREW) ||
     isConst?(babyspecies,PBSpecies,:VULPIX) ||
     isConst?(babyspecies,PBSpecies,:DIGLETT) ||
     isConst?(babyspecies,PBSpecies,:MEOWTH) ||
     isConst?(babyspecies,PBSpecies,:GEODUDE) ||
     isConst?(babyspecies,PBSpecies,:GRIMER) ||
     isConst?(babyspecies,PBSpecies,:EXEGGCUTE) ||
     isConst?(babyspecies,PBSpecies,:CUBONE) ||
     # Galarian Forms
     isConst?(babyspecies,PBSpecies,:MEOWTH) ||
     isConst?(babyspecies,PBSpecies,:PONYTA) ||
     isConst?(babyspecies,PBSpecies,:FARFETCHD) ||
     isConst?(babyspecies,PBSpecies,:KOFFING) ||
     isConst?(babyspecies,PBSpecies,:MRMIME) ||
     isConst?(babyspecies,PBSpecies,:CORSOLA) ||
     isConst?(babyspecies,PBSpecies,:ZIGZAGOON) ||
     isConst?(babyspecies,PBSpecies,:MIMEJR) ||
     isConst?(babyspecies,PBSpecies,:DARUMAKA) ||
     isConst?(babyspecies,PBSpecies,:YAMASK) ||
     # Hisuian Forms
     isConst?(babyspecies,PBSpecies,:GROWLITHE) ||
     isConst?(babyspecies,PBSpecies,:VOLTORB) ||
     isConst?(babyspecies,PBSpecies,:CYNDAQUIL) ||
     isConst?(babyspecies,PBSpecies,:QWILFISH) ||
     isConst?(babyspecies,PBSpecies,:SNEASEL) ||
     isConst?(babyspecies,PBSpecies,:OSHAWOTT) ||
     isConst?(babyspecies,PBSpecies,:PETILIL) ||
     isConst?(babyspecies,PBSpecies,:ZORUA) ||
     isConst?(babyspecies,PBSpecies,:RUFFLET) ||
     isConst?(babyspecies,PBSpecies,:GOOMY) ||
     isConst?(babyspecies,PBSpecies,:BERGMITE) ||
     isConst?(babyspecies,PBSpecies,:ROWLET) ||
     # Paldean Forms
     isConst?(babyspecies,PBSpecies,:TAUROS) ||
     isConst?(babyspecies,PBSpecies,:WOOPER) ||
     # Misc Forms (Phonetic, Yorkbook and Mysterican)
     isConst?(babyspecies,PBSpecies,:EKANS) ||
     isConst?(babyspecies,PBSpecies,:SPRITZEE) ||
     isConst?(babyspecies,PBSpecies,:SWIRLIX) ||
     isConst?(babyspecies,PBSpecies,:PHANTUMP) ||
     isConst?(babyspecies,PBSpecies,:FOMANTIS) ||
     isConst?(babyspecies,PBSpecies,:MORELLUL) ||
     isConst?(babyspecies,PBSpecies,:GROOKEY) ||
     isConst?(babyspecies,PBSpecies,:SCORBUNNY) ||
     isConst?(babyspecies,PBSpecies,:SOBBLE) ||
     isConst?(babyspecies,PBSpecies,:GOSSIFLEUR) ||
     isConst?(babyspecies,PBSpecies,:CLOBBOPUS) ||
     isConst?(babyspecies,PBSpecies,:PINCURCHIN) ||
     isConst?(babyspecies,PBSpecies,:CUFANT) ||
     isConst?(babyspecies,PBSpecies,:SHROODLE)
     egg.form=(ditto0) ? father.form : mother.form
  end
  # Inheriting Moves
  moves=[]
  othermoves=[] 
  movefather=father; movemother=mother
  if pbIsDitto?(movefather) && !mother.isFemale?
    movefather=mother; movemother=father
  end
  # Initial Moves
  initialmoves=egg.getMoveList
  for k in initialmoves
    if k[0]<=EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if mother.hasMove?(k[1]) && father.hasMove?(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  for i in 0...$ItemData.length
    next if !$ItemData[i]
    atk=$ItemData[i][ITEMMACHINE]
    next if !atk || atk==0
    if egg.isCompatibleWithMove?(atk)
      moves.push(atk) if movefather.hasMove?(atk)
    end
  end
  # Inheriting Egg Moves
  if movefather.isMale?
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
       f.pos=(babyspecies-1)*8
       offset=f.fgetdw
       length=f.fgetdw
       if length>0
         f.pos=offset
         i=0; loop do break unless i<length
           atk=f.fgetw
           moves.push(atk) if movefather.hasMove?(atk)
           i+=1
         end
       end
    }
  end
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         moves.push(atk) if movemother.hasMove?(atk)
         i+=1
       end
     end
  }
  # Volt Tackle
  lightball=false
  if (isConst?(father.species,PBSpecies,:PIKACHU) || 
      isConst?(father.species,PBSpecies,:RAICHU)) && 
      isConst?(father.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if (isConst?(mother.species,PBSpecies,:PIKACHU) || 
      isConst?(mother.species,PBSpecies,:RAICHU)) && 
      isConst?(mother.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  # Facade
  facade=false
  if (isConst?(father.species,PBSpecies,:JETAIME) || 
      isConst?(father.species,PBSpecies,:ZAMANFOO)) && 
      isConst?(father.item,PBItems,:ANGLESTONE)
    facade=true
  end
  if (isConst?(mother.species,PBSpecies,:JETAIME) || 
      isConst?(mother.species,PBSpecies,:ZAMANFOO)) && 
      isConst?(mother.item,PBItems,:ANGLESTONE)
    facade=true
  end
  if facade && isConst?(babyspecies,PBSpecies,:AYPNIES) &&
     hasConst?(PBMoves,:FACADE)
    moves.push(getConst(PBMoves,:FACADE))
  end
  moves|=[] # remove duplicates
  # Assembling move list
  finalmoves=[]
  listend=moves.length-4
  listend=0 if listend<0
  j=0
  for i in listend..listend+3
    moveid=(i>=moves.length) ? 0 : moves[i]
    finalmoves[j]=PBMove.new(moveid)
    j+=1
  end 
  # Inheriting Individual Values
  ivs=[]
  for i in 0...6
    ivs[i]=rand(32)
  end
  ivinherit=[]
  for i in 0...2
    parent=[mother,father][i]
    ivinherit[i]=PBStats::HP if isConst?(parent.item,PBItems,:POWERWEIGHT)
    ivinherit[i]=PBStats::ATTACK if isConst?(parent.item,PBItems,:POWERBRACER)
    ivinherit[i]=PBStats::DEFENSE if isConst?(parent.item,PBItems,:POWERBELT)
    ivinherit[i]=PBStats::SPEED if isConst?(parent.item,PBItems,:POWERANKLET)
    ivinherit[i]=PBStats::SPATK if isConst?(parent.item,PBItems,:POWERLENS)
    ivinherit[i]=PBStats::SPDEF if isConst?(parent.item,PBItems,:POWERBAND)
  end
  num=0; r=rand(2)
  for i in 0...2
    if ivinherit[r]!=nil
      parent=[mother,father][r]
      ivs[ivinherit[r]]=parent.iv[ivinherit[r]]
      num+=1
      break
    end
    r=(r+1)%2
  end
  stats=[PBStats::HP,PBStats::ATTACK,PBStats::DEFENSE,
         PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
  limit=(isConst?(mother.item,PBItems,:DESTINYKNOT) ||
         isConst?(father.item,PBItems,:DESTINYKNOT)) ? 5 : 3
  loop do
    freestats=[]
    for i in stats
      freestats.push(i) if !ivinherit.include?(i)
    end
    break if freestats.length==0
    r=freestats[rand(freestats.length)]
    parent=[mother,father][rand(2)]
    ivs[r]=parent.iv[r]
    ivinherit.push(r)
    num+=1
    break if num>=limit
  end
  # Inheriting nature
  newnatures=[]
  newnatures.push(mother.nature) if isConst?(mother.item,PBItems,:EVERSTONE)
  newnatures.push(father.nature) if isConst?(father.item,PBItems,:EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries=0
  shinyretries+=5 if father.language!=mother.language
  shinyretries+=5 if (isConst?(father.ability,PBAbilities,:LIGHTER) ||
                      isConst?(mother.ability,PBAbilities,:LIGHTER))
  shinyretries+=15 if (isConst?(father.ability,PBAbilities,:SHINYGATHER) ||
                      isConst?(mother.ability,PBAbilities,:SHINYGATHER))
  shinyretries+=2 if (isConst?(father.ability,PBAbilities,:KOULUNDIN) ||
                      isConst?(mother.ability,PBAbilities,:KOULUNDIN))
  shinyretries+=2 if hasConst?(PBItems,:SHINYCHARM) &&
                     $PokemonBag.pbQuantity(:SHINYCHARM)>0
  if shinyretries>0
    for i in 0...shinyretries
      break if egg.isShiny?
      egg.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
  if (!ditto0 && !ditto1)
    if mother.hasHiddenAbility?
      egg.setAbility(mother.abilityIndex) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex)
      else
        egg.setAbility((mother.abilityIndex+1)%2)
      end
    end
  elsif ((!ditto0 && ditto1) || (!ditto1 && ditto0))
    parent=(!ditto0) ? mother : father
    if parent.hasHiddenAbility?
      egg.setAbility(parent.abilityIndex) if rand(10)<6
    end
  end
  # Inheriting Poké Ball from the mother
  if mother.isFemale? &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:MASTERBALL) &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:METABALL) &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:SHADOWBALL) &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:CHERISHBALL)
    egg.ballused=mother.ballused
  end
  egg.iv[0]=ivs[0]
  egg.iv[1]=ivs[1]
  egg.iv[2]=ivs[2]
  egg.iv[3]=ivs[3]
  egg.iv[4]=ivs[4]
  egg.iv[5]=ivs[5]
  egg.moves[0]=finalmoves[0]
  egg.moves[1]=finalmoves[1]
  egg.moves[2]=finalmoves[2]
  egg.moves[3]=finalmoves[3]
  egg.calcStats
  egg.obtainText=_INTL("Day-Care Couple")
  egg.name=_INTL("Egg")
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,babyspecies,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  egg.eggsteps=eggsteps
  if rand(65536)<POKERUSCHANCE
    egg.givePokerus
  end
  egg.family = PokemonFamily.new(egg, father, mother)
  $Trainer.party[$Trainer.party.length]=egg
end

Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   deposited=pbDayCareDeposited
   if deposited==2 && $PokemonGlobal.daycareEgg==0
    # Changed
    pokemon0=$PokemonGlobal.daycare[0][0]
    pokemon1=$PokemonGlobal.daycare[1][0]
    mother=nil
    father=nil
    babyspecies=0
    ditto0=pbIsDitto?(pokemon0)
    ditto1=pbIsDitto?(pokemon1)
    if (pokemon0.isFemale? || ditto0)
      babyspecies=(ditto0) ? pokemon1.species : pokemon0.species
      mother=pokemon0
      father=pokemon1
    else
      babyspecies=(ditto1) ? pokemon0.species : pokemon1.species
      mother=pokemon1
      father=pokemon0
    end
    # Chenged end
     $PokemonGlobal.daycareEggSteps=0 if !$PokemonGlobal.daycareEggSteps
     $PokemonGlobal.daycareEggSteps+=1
     if $PokemonGlobal.daycareEggSteps==256
       extraoval=(isConst?(father.ability,PBAbilities,:KOURTINA) ||
           isConst?(mother.ability,PBAbilities,:KOURTINA))
       extraoval2=(isConst?(father.item,PBItems,:LECTROBALL) ||
           isConst?(mother.item,PBItems,:LECTROBALL))
       $PokemonGlobal.daycareEggSteps=0
       compatval=[0,20,50,70][pbDayCareGetCompat]
       if extraoval || extraoval2
         compatval=[0,30,60,77][pbDayCareGetCompat]
       end
       if hasConst?(PBItems,:OVALCHARM) && $PokemonBag.pbQuantity(:OVALCHARM)>0
         compatval=[0,40,80,88][pbDayCareGetCompat]
         if extraoval || extraoval2
           compatval=[0,50,90,95][pbDayCareGetCompat]
         end
       end
       rnd=rand(100)
       if rnd<compatval
         # Egg is generated
         $PokemonGlobal.daycareEgg=1
       end
     end
   end
   for i in 0...2
     pkmn=$PokemonGlobal.daycare[i][0]
     next if !pkmn
     maxexp=PBExperience.pbGetMaxExperience(pkmn.growthrate)
     if pkmn.exp<maxexp
       oldlevel=pkmn.level
       pkmn.exp+=1
       pkmn.exp+=1 if rand(1000) < 15 # QQC Change
       if pkmn.level!=oldlevel
         pkmn.calcStats
         movelist=pkmn.getMoveList
         for i in movelist
           pkmn.pbLearnMove(i[1]) if i[0]==pkmn.level       # Learned a new move
         end
       end
     end
   end
}