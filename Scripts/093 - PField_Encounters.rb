module EncounterTypes
  Land              = 0
  Cave              = 1
  Water             = 2
  RockSmash         = 3
  OldRod            = 4
  GoodRod           = 5
  SuperRod          = 6
  HeadbuttLow       = 7
  HeadbuttHigh      = 8
  LandMorning       = 9
  LandDay           = 10
  LandNight         = 11
  BugContest        = 12
  CaveNight         = 13
  WaterRare         = 14
  LandRare          = 15
  ScubaDuba         = 16
  ScubaDubaRare     = 17
  CaveLarge         = 18
  CaveLolan         = 19
  CaveNightLarge    = 20
  CaveRare          = 21
  LandLarge         = 22
  LandNightLarge    = 23
  LandMorningLarge  = 24
  CaveXLarge        = 25
  CaveMorningLarge  = 26
  CaveHisui         = 27
  CaveInter         = 28
  CaveMorningXLarge = 29
  CaveNightXLarge   = 30
  LandXLarge        = 31
  LandNightXLarge   = 32
  LandMorningXLarge = 33
  
  Names=[
     "Land",
     "Cave",
     "Water",
     "RockSmash",
     "OldRod",
     "GoodRod",
     "SuperRod",
     "HeadbuttLow",
     "HeadbuttHigh",
     "LandMorning",
     "LandDay",
     "LandNight",
     "BugContest",
     "CaveNight",
     "WaterRare",
     "LandRare",
     "ScubaDuba",
     "ScubaDubaRare",
     "CaveLarge",
     "CaveLolan",
     "CaveNightLarge",
     "CaveRare",
     "LandLarge",
     "LandNightLarge",
     "LandMorningLarge",
     "CaveXLarge",
     "CaveMorningLarge",
     "CaveHisui",
     "CaveInter",
     "CaveMorningXLarge",
     "CaveNightXLarge",
     "LandXLarge",
     "LandNightXLarge",
     "LandMorningXLarge"
  ]
  EnctypeChances=[
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # Land (12)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # Cave (12)
     [60,30,5,4,1],                                                      # Water (5)
     [60,30,5,4,1],                                                      # RockSmash (5)
     [70,30],                                                            # OldRod (2)
     [60,20,20],                                                         # GoodRod (3)
     [40,40,15,4,1],                                                     # SuperRod (5)
     [30,25,20,10,5,5,4,1],                                              # HeadbuttLow (8)
     [30,25,20,10,5,5,4,1],                                              # HeadbuttHigh (8)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # LandMorning (12)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # LandDay (12)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # LandNight (12)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # BugContest (12)
     [20,20,10,10,10,10,5,5,4,4,1,1],                                    # CaveNight (12)
     [70,30],                                                            # WaterRare (2)
     [20,20,15,15,10,10,5,5],                                            # LandRare (8)
     [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],                # ScubaDuba (25)
     [20,20,15,15,10,10,5,5],                                            # ScubaDubaRare (8)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # CaveLarge (20)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,3,1,1,1,1,1,1],                   # CaveLoLan (21)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # CaveNightLarge (20)
     [20,20,15,15,10,10,5,5],                                            # CaveRare (8)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # LandLarge (20)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # LargeNightLarge (20)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # LandMorningLarge (20)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # CaveXLarge (27)
     [10,10,10,10,10,5,5,5,5,5,4,4,4,4,4,1,1,1,1,1],                     # CaveMorningLarge (20)
     [10,10,10,10,5,5,5,5,4,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,1],          # CaveHisui (26)
     [30,30,20,20],                                                      # CaveInter (4)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # CaveMorningXLarge (27)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # CaveNightXLarge (27)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # LandXLarge (27)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # LandNightXLarge (27)
     [8,8,8,8,8,5,5,5,5,4,4,4,4,4,4,2,2,2,2,1,1,1,1,1,1,1,1],            # LandMorningXLarge (27)
  ]
  EnctypeDensities=[25,10,10,0,0,0,0,0,0,25,25,25,25,10,10,25,8,8,10,11,10,10,25,25,25,10,10,10,10,10,10,25,25,25]
  EnctypeCompileDens=[1,2,3,0,0,0,0,0,0,1,1,1,1,2,3,1,0,0,2,2,2,2,1,1,1,2,2,2,2,2,2,1,1,1]
end



class PokemonEncounters
  def initialize
    @enctypes=[]
    @density=nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount=0
  end

  def hasEncounter?(enc)
    return false if @density==nil || enc<0
    return @enctypes[enc] ? true : false  
  end

  def isCave?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Cave] ||
            @enctypes[EncounterTypes::CaveNight] ||
            @enctypes[EncounterTypes::ScubaDuba] ||
            @enctypes[EncounterTypes::ScubaDubaRare] ||
            @enctypes[EncounterTypes::CaveLarge] ||
            @enctypes[EncounterTypes::CaveLolan] ||
            @enctypes[EncounterTypes::CaveHisui] ||
            @enctypes[EncounterTypes::CaveNightLarge] ||
            @enctypes[EncounterTypes::CaveMorningLarge] ||
            @enctypes[EncounterTypes::CaveRare] || 
            @enctypes[EncounterTypes::CaveXLarge] ||
            @enctypes[EncounterTypes::CaveMorningXLarge] ||
            @enctypes[EncounterTypes::CaveNightXLarge] ||
            @enctypes[EncounterTypes::CaveInter]) ? true : false
  end

  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest] ||
            @enctypes[EncounterTypes::LandRare] ||
            @enctypes[EncounterTypes::LandLarge] ||
            @enctypes[EncounterTypes::LandNightLarge] ||
            @enctypes[EncounterTypes::LandMorningLarge] ||
            @enctypes[EncounterTypes::LandXLarge] ||
            @enctypes[EncounterTypes::LandMorningXLarge] ||
            @enctypes[EncounterTypes::LandNightXLarge]) ? true : false
  end

  def isRegularGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::LandRare] ||
            @enctypes[EncounterTypes::LandLarge] ||
            @enctypes[EncounterTypes::LandNightLarge] ||
            @enctypes[EncounterTypes::LandMorningLarge] ||
            @enctypes[EncounterTypes::LandXLarge] ||
            @enctypes[EncounterTypes::LandMorningXLarge] ||
            @enctypes[EncounterTypes::LandNightXLarge]) ? true : false
  end

  def isWater?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Water] ||
            @enctypes[EncounterTypes::WaterRare]) ? true : false
  end

  def pbEncounterType
    dubamaps=[334,335,336,338,370,394] # Maps for Scuba Duba encounters
    if $PokemonGlobal && $PokemonGlobal.surfing
      enctype=EncounterTypes::Water
      enctype=EncounterTypes::WaterRare if self.hasEncounter?(EncounterTypes::WaterRare) && (rand(15) < 2) && $game_switches[72]==true
      return enctype
    elsif self.isCave?
      time=pbGetTimeNow
      enctype=EncounterTypes::Cave
      enctype=EncounterTypes::CaveNight if self.hasEncounter?(EncounterTypes::CaveNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::ScubaDuba if self.hasEncounter?(EncounterTypes::ScubaDuba) && dubamaps.include?($game_map.map_id)
      enctype=EncounterTypes::ScubaDubaRare if self.hasEncounter?(EncounterTypes::ScubaDubaRare) && (rand(15) < 2) && dubamaps.include?($game_map.map_id)
      enctype=EncounterTypes::CaveLarge if self.hasEncounter?(EncounterTypes::CaveLarge)
      enctype=EncounterTypes::CaveLolan if self.hasEncounter?(EncounterTypes::CaveLolan)
      enctype=EncounterTypes::CaveHisui if self.hasEncounter?(EncounterTypes::CaveHisui)
      enctype=EncounterTypes::CaveNightLarge if self.hasEncounter?(EncounterTypes::CaveNightLarge) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::CaveMorningLarge if self.hasEncounter?(EncounterTypes::CaveMorningLarge) && PBDayNight.isMorning?(time)
      enctype=EncounterTypes::CaveXLarge if self.hasEncounter?(EncounterTypes::CaveXLarge)
      enctype=EncounterTypes::CaveRare if self.hasEncounter?(EncounterTypes::CaveRare) && (rand(15) < 2) && $game_switches[70]==true
      enctype=EncounterTypes::CaveNightXLarge if self.hasEncounter?(EncounterTypes::CaveNightXLarge) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::CaveMorningXLarge if self.hasEncounter?(EncounterTypes::CaveMorningXLarge) && PBDayNight.isMorning?(time)
      enctype=EncounterTypes::CaveInter if self.hasEncounter?(EncounterTypes::CaveInter)
      return enctype
    elsif self.isGrass? 
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      enctype=EncounterTypes::LandLarge if self.hasEncounter?(EncounterTypes::LandLarge)
      enctype=EncounterTypes::LandNightLarge if self.hasEncounter?(EncounterTypes::LandNightLarge) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandMorningLarge if self.hasEncounter?(EncounterTypes::LandMorningLarge) && PBDayNight.isMorning?(time)
      enctype=EncounterTypes::LandRare if self.hasEncounter?(EncounterTypes::LandRare) && (rand(15) < 2) && $game_switches[70]==true
      enctype=EncounterTypes::LandXLarge if self.hasEncounter?(EncounterTypes::LandXLarge)
      enctype=EncounterTypes::LandNightXLarge if self.hasEncounter?(EncounterTypes::LandNightXLarge) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandMorningXLarge if self.hasEncounter?(EncounterTypes::LandMorningXLarge) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype=EncounterTypes::BugContest
      end
      return enctype
    end
    return -1
  end

  def isEncounterPossibleHere?
    if $PokemonGlobal && $PokemonGlobal.surfing
      return true
    elsif PBTerrain.isIce?(pbGetTerrainTag($game_player))
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return PBTerrain.isGrass?($game_map.terrain_tag($game_player.x,$game_player.y))
    end
    return false
  end

  def setup(mapID)
    @density=nil
    @stepcount=0
    @enctypes=[]
    begin
      data=load_data("Data/encounters.dat")
      if data.is_a?(Hash) && data[mapID]
        @density=data[mapID][0]
        @enctypes=data[mapID][1]
      else
        @density=nil
        @enctypes=[]
      end
    rescue
      @density=nil
      @enctypes=[]
    end
  end

  def pbMapHasEncounter?(mapID,enctype)
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
      density=data[mapID][0]
    else
      return false
    end
    return false if density==nil || enctype<0
    return enctypes[enctype] ? true : false  
  end

  def pbMapEncounter(mapID,enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
    else
      return nil
    end
    return nil if enctypes[enctype]==nil
    chances=EncounterTypes::EnctypeChances[enctype]
    chancetotal=0
    chances.each {|a| chancetotal+=a}
    rnd=rand(chancetotal)
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=enctypes[enctype][chosenpkmn]
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

  def pbEncounteredPokemon(enctype,tries=1)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @enctypes[enctype]==nil
    encounters=@enctypes[enctype]
    chances=EncounterTypes::EnctypeChances[enctype]
    firstpoke=$Trainer.firstParty
    if firstpoke && !firstpoke.isEgg? && rand(2)==0
      if isConst?(firstpoke.ability,PBAbilities,:STATIC) ||
         (isConst?(firstpoke.ability,PBAbilities,:LIGHTINGROD) && $USENEWBATTLEMECHANICS)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:ELECTRIC) || isConst?(t2,PBTypes,:ELECTRIC)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:DOOMER) ||
         (isConst?(firstpoke.ability,PBAbilities,:DOOMELIST) && $USENEWBATTLEMECHANICS)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:DOOM) || isConst?(t2,PBTypes,:DOOM)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:STORMDRAIN) && $USENEWBATTLEMECHANICS
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:WATER) || isConst?(t2,PBTypes,:WATER)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:FLASHFIRE) && $USENEWBATTLEMECHANICS
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:FIRE) || isConst?(t2,PBTypes,:FIRE)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if (isConst?(firstpoke.ability,PBAbilities,:HARVEST) && $USENEWBATTLEMECHANICS) ||
          isConst?(firstpoke.ability,PBAbilities,:LONGGRASS)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:GRASS) || isConst?(t2,PBTypes,:GRASS)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:HERBALILITY) ||
         isConst?(firstpoke.item,PBItems,:BOTANICSMOKE) ||
         isConst?(firstpoke.ability,PBAbilities,:BOTANOTHERAPY)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:HERB) || isConst?(t2,PBTypes,:HERB)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:HERALINA) ||
         isConst?(firstpoke.ability,PBAbilities,:CHIKOLINI) ||
         isConst?(firstpoke.ability,PBAbilities,:FERFATINA)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:MIND) || isConst?(t2,PBTypes,:MIND)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:ANTISHARPNESS)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if !(isConst?(t1,PBTypes,:SHARPENER) || isConst?(t2,PBTypes,:SHARPENER))
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:SOUPRSOWL)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:SHARPENER) || isConst?(t2,PBTypes,:SHARPENER)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:SINISTRO) ||
        isConst?(firstpoke.ability,PBAbilities,:PROTEINCROTELINE) ||
        isConst?(firstpoke.item,PBItems,:COLORCATCHER)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,firstpoke.type1) || isConst?(t2,PBTypes,firstpoke.type1) ||
             isConst?(t1,PBTypes,firstpoke.type2) || isConst?(t2,PBTypes,firstpoke.type2)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
      if isConst?(firstpoke.ability,PBAbilities,:MAGNETPULL)
        newencs=[]; newchances=[]
        dexdata=pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1=dexdata.fgetb
          t2=dexdata.fgetb
          if isConst?(t1,PBTypes,:STEEL) || isConst?(t2,PBTypes,:STEEL)
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters=newencs
          chances=newchances
        end
      end
    end
    chancetotal=0
    chances.each {|a| chancetotal+=a}
    rnd=0
    tries.times do
      r=rand(chancetotal)
      rnd=r if rnd<r
    end
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=encounters[chosenpkmn]
    return nil if !encounter
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    if $Trainer.firstParty && !$Trainer.firstParty.isEgg? &&
       (isConst?($Trainer.firstParty.ability,PBAbilities,:HUSTLE) ||
       isConst?($Trainer.firstParty.ability,PBAbilities,:VITALSPIRIT) ||
       isConst?($Trainer.firstParty.ability,PBAbilities,:PRESSURE) ||
       isConst?($Trainer.firstParty.ability,PBAbilities,:ALLERGY)) &&
       rand(2)==0
      level2=encounter[1]+rand(1+encounter[2]-encounter[1])
      level=[level,level2].max
    end
    if $PokemonMap.blackFluteUsed && $USENEWBATTLEMECHANICS
      level=[level+1+rand(3),PBExperience::MAXLEVEL].min
    elsif $PokemonMap.whiteFluteUsed && $USENEWBATTLEMECHANICS
      level=[level-1-rand(3),1].max
    end
    return [encounter[0],level]
  end

  def pbCanEncounter?(encounter)
    return false if $game_system.encounter_disabled
    return false if !encounter || !$Trainer
    return false if ($DEBUG || $TEST) && Input.press?(Input::CTRL)
    if !pbPokeRadarOnShakingGrass
      return false if $PokemonGlobal.repel>0 && $Trainer.ablePokemonCount>0 &&
                      encounter[1]<=$Trainer.ablePokemonParty[0].level
    end
    return true
  end

  def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    @stepcount+=1
    return nil if @stepcount<=3 # Check three steps after battle ends
    encount=@density[enctype]*16
    if $PokemonGlobal.bicycle
      encount=(encount*0.8)
    end
    if $PokemonMap.blackFluteUsed && !$USENEWBATTLEMECHANICS
      encount=(encount/2)
    elsif $PokemonMap.whiteFluteUsed && !$USENEWBATTLEMECHANICS
      encount=(encount*1.5)
    end
    firstpoke=$Trainer.firstParty
    if firstpoke && !firstpoke.isEgg?
      if (isConst?(firstpoke.item,PBItems,:CLEANSETAG) || 
          isConst?(firstpoke.ability,PBAbilities,:ALLERGY))
        encount=(encount*2/3)
      elsif isConst?(firstpoke.item,PBItems,:PUREINCENSE) ||
            isConst?(firstpoke.item,PBItems,:WHITEPLUS)
        encount=(encount*2/3)
      else   # Ignore ability effects if an item effect applies
        if isConst?(firstpoke.ability,PBAbilities,:STENCH)
          encount=(encount/2)
        elsif isConst?(firstpoke.ability,PBAbilities,:WHITESMOKE)
          encount=(encount/2)
        elsif isConst?(firstpoke.ability,PBAbilities,:ALONELY) && $USENEWBATTLEMECHANICS
          encount=(encount/10)
        elsif isConst?(firstpoke.ability,PBAbilities,:QUICKFEET)
          encount=(encount/2)
        elsif isConst?(firstpoke.ability,PBAbilities,:KOULUNDIN)
          encount=(encount/4)
        elsif isConst?(firstpoke.ability,PBAbilities,:SNOWCLOAK) &&
           ($game_screen.weather_type==PBFieldWeather::Snow ||
           $game_screen.weather_type==PBFieldWeather::Blizzard)
          encount=(encount/2)
        elsif isConst?(firstpoke.ability,PBAbilities,:SANDVEIL) &&
           $game_screen.weather_type==PBFieldWeather::Sandstorm
          encount=(encount/2)
        elsif isConst?(firstpoke.ability,PBAbilities,:SWARM)
          encount=(encount*1.5)
        elsif isConst?(firstpoke.ability,PBAbilities,:ILLUMINATE)
          encount=(encount*2)
        elsif isConst?(firstpoke.ability,PBAbilities,:ARENATRAP)
          encount=(encount*2)
        elsif isConst?(firstpoke.ability,PBAbilities,:NOGUARD)
          encount=(encount*2)
        elsif isConst?(firstpoke.ability,PBAbilities,:BOTANOTHERAPY)
          encount=(encount*10)
        end
      end
    end
    return nil if rand(180*16)>=encount
    encpoke=pbEncounteredPokemon(enctype)
    if encpoke && firstpoke && !firstpoke.isEgg?
      if isConst?(firstpoke.ability,PBAbilities,:INTIMIDATE) ||
         isConst?(firstpoke.ability,PBAbilities,:KEENEYE) ||
         isConst?(firstpoke.ability,PBAbilities,:KOULUNDIN)
        if encpoke[1]<=firstpoke.level-5 && rand(2)==0
          encpoke=nil
        end
      end
    end
    return encpoke
  end
end