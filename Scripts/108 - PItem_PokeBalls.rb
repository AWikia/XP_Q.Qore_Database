module BallHandlers
  IsUnconditional = ItemHandlerHash.new
  ModifyCatchRate = ItemHandlerHash.new
  OnCatch         = ItemHandlerHash.new
  OnFailCatch     = ItemHandlerHash.new

  def self.isUnconditional?(ball,battle,battler)
    return false if !IsUnconditional[ball]
    return IsUnconditional.trigger(ball,battle,battler)
  end

  def self.modifyCatchRate(ball,catchRate,battle,battler)
    return catchRate if !ModifyCatchRate[ball]
    return ModifyCatchRate.trigger(ball,catchRate,battle,battler)
  end

  def self.onCatch(ball,battle,pokemon)
    return if !OnCatch[ball]
    OnCatch.trigger(ball,battle,pokemon)
  end

  def self.onFailCatch(ball,battle,battler)
    return if !OnFailCatch[ball]
    OnFailCatch.trigger(ball,battle,battler)
  end
end



def pbBallTypeToBall(balltype)
  if $BallTypes[balltype]
    ret=getID(PBItems,$BallTypes[balltype])
    return ret if ret!=0
  end
  if $BallTypes[0]
    ret=getID(PBItems,$BallTypes[0])
    return ret if ret!=0
  end
  return getID(PBItems,:POKEBALL)
end

def pbGetBallType(ball)
  ball=getID(PBItems,ball)
  for key in $BallTypes.keys
    return key if isConst?(ball,PBItems,$BallTypes[key])
  end
  return 0
end

################################

$BallTypes={
   0=>:POKEBALL,
   1=>:GREATBALL,
   2=>:SAFARIBALL,
   3=>:ULTRABALL,
   4=>:MASTERBALL,
   5=>:NETBALL,
   6=>:DIVEBALL,
   7=>:NESTBALL,
   8=>:REPEATBALL,
   9=>:TIMERBALL,
   10=>:LUXURYBALL,
   11=>:PREMIERBALL,
   12=>:DUSKBALL,
   13=>:HEALBALL,
   14=>:QUICKBALL,
   15=>:CHERISHBALL,
   16=>:FASTBALL,
   17=>:LEVELBALL,
   18=>:LUREBALL,
   19=>:HEAVYBALL,
   20=>:LOVEBALL,
   21=>:FRIENDBALL,
   22=>:MOONBALL,
   23=>:SPORTBALL,
   24=>:NOBELBALL,
   25=>:METABALL,
   26=>:LAYERBALL,
   27=>:PARKBALL,
   28=>:BEASTBALL,
   29=>:SHADOWBALL,
   30=>:DREAMBALL,
   31=>:GREATDUSKBALL,
   32=>:PRALINEBALL,
   33=>:GREATNESTBALL,
   34=>:FLIPNOTEBALL,
   35=>:GREATFLIPNOTEBALL,
   36=>:ULTRAFLIPNOTEBALL,
   37=>:RETURNBONUSBALL
}

BallHandlers::ModifyCatchRate.add(:GREATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*2).floor
})

BallHandlers::ModifyCatchRate.add(:PARKBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3).floor
})


BallHandlers::IsUnconditional.add(:MASTERBALL,proc{|ball,battle,battler|
   next true
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:NETBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*7/2).floor if battle.environment==PBEnvironment::Underwater
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL,proc{|ball,catchRate,battle,battler|
   if battler.level<=40
     catchRate*=[(41-battler.level)/10,1].max
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if battle.pbPlayer.owned[battler.species]
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL,proc{|ball,catchRate,battle,battler|
   multiplier=[1+(0.3*battle.turncount),4].min
   catchRate*=multiplier
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=7/2 if PBDayNight.isNight?
   next catchRate
})

BallHandlers::OnCatch.add(:HEALBALL,proc{|ball,battle,pokemon|
   pokemon.heal
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=5 if battle.turncount<=1
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL,proc{|ball,catchRate,battle,battler|
   dexdata=pbOpenDexData
   pbDexDataOffset(dexdata,battler.species,13)
   basespeed=dexdata.fgetb
   dexdata.close
   catchRate*=4 if basespeed>=100
   next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL,proc{|ball,catchRate,battle,battler|
   pbattler=battle.battlers[0].level
   pbattler=battle.battlers[2].level if battle.battlers[2] &&
                                        battle.battlers[2].level>pbattler
   if pbattler>=battler.level*4
     catchRate*=8
   elsif pbattler>=battler.level*2
     catchRate*=4
   elsif pbattler>battler.level
     catchRate*=2
   end
   next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:LUREBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if $PokemonTemp.encounterType==EncounterTypes::OldRod ||
                   $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
                   $PokemonTemp.encounterType==EncounterTypes::SuperRod
   next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL,proc{|ball,catchRate,battle,battler|
   weight=battler.weight
   if weight>=4096
     catchRate+=40
   elsif weight>=3072
     catchRate+=30
   elsif weight>=2048
     catchRate+=20
   else
     catchRate-=20
   end
   catchRate=[catchRate,1].max
   next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL,proc{|ball,catchRate,battle,battler|
   pbattler=battle.battlers[0]
   pbattler2=battle.battlers[2] if battle.battlers[2]
   if pbattler.species==battler.species &&
      ((battler.gender==0 && pbattler.gender==1) ||
      (battler.gender==1 && pbattler.gender==0))
     catchRate*=8
   elsif pbattler2 && pbattler2.species==battler.species &&
      ((battler.gender==0 && pbattler2.gender==1) ||
       (battler.gender==1 && pbattler2.gender==0))
     catchRate*=8
   end
   next [catchRate,255].min
})

BallHandlers::OnCatch.add(:FRIENDBALL,proc{|ball,battle,pokemon|
   pokemon.happiness=200
})

BallHandlers::ModifyCatchRate.add(:MOONBALL,proc{|ball,catchRate,battle,battler|
   if isConst?(battler.species,PBSpecies,:NIDORANfE) ||
      isConst?(battler.species,PBSpecies,:NIDORINA) ||
      isConst?(battler.species,PBSpecies,:NIDOQUEEN) ||
      isConst?(battler.species,PBSpecies,:NIDORANmA) ||
      isConst?(battler.species,PBSpecies,:NIDORINO) ||
      isConst?(battler.species,PBSpecies,:NIDOKING) ||
      isConst?(battler.species,PBSpecies,:CLEFFA) ||
      isConst?(battler.species,PBSpecies,:CLEFAIRY) ||
      isConst?(battler.species,PBSpecies,:CLEFABLE) ||
      isConst?(battler.species,PBSpecies,:IGGLYBUFF) ||
      isConst?(battler.species,PBSpecies,:JIGGLYPUFF) ||
      isConst?(battler.species,PBSpecies,:WIGGLYTUFF) ||
      isConst?(battler.species,PBSpecies,:SKITTY) ||
      isConst?(battler.species,PBSpecies,:DELCATTY) ||
      isConst?(battler.species,PBSpecies,:MUNNA) ||
      isConst?(battler.species,PBSpecies,:MUSHARNA)
     catchRate*=4
   end
   next [catchRate,255].min
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:NOBELBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=4 if battler.pbHasType?(:MAGIC) || battler.pbHasType?(:FAIRY)
   next catchRate
})
BallHandlers::ModifyCatchRate.add(:METABALL,proc{|ball,catchRate,battle,battler|
   if isConst?(battler.species,PBSpecies,:WIKIMEDIA) ||
      isConst?(battler.species,PBSpecies,:WIKIMANIA) ||
      isConst?(battler.species,PBSpecies,:UNCYCLOMEDIA) ||
      isConst?(battler.species,PBSpecies,:WIKIDATA) ||
      isConst?(battler.species,PBSpecies,:UNDATA)
     catchRate*=8
   elsif isConst?(battler.species,PBSpecies,:WIKISPECIES) ||
         isConst?(battler.species,PBSpecies,:UNFORUM) ||
         isConst?(battler.species,PBSpecies,:WIKIFUNCTIONS) ||
         isConst?(battler.species,PBSpecies,:ROOMBA)
     catchRate*=6
   elsif isConst?(battler.species,PBSpecies,:WIKIBOOKS) ||
         isConst?(battler.species,PBSpecies,:UNBOOKS) ||
         isConst?(battler.species,PBSpecies,:WIKIPEDIA) ||
         isConst?(battler.species,PBSpecies,:UNCYCLOPEDIA) ||
         isConst?(battler.species,PBSpecies,:WIKINEWS) ||
         isConst?(battler.species,PBSpecies,:UNNEWS) ||
         isConst?(battler.species,PBSpecies,:WIKTIONARY) ||
         isConst?(battler.species,PBSpecies,:UNDICTIONARY) ||
         isConst?(battler.species,PBSpecies,:WIKIQUOTE) ||
         isConst?(battler.species,PBSpecies,:UNQUOTABLE) ||
         isConst?(battler.species,PBSpecies,:WIKIVERSITY) ||
         isConst?(battler.species,PBSpecies,:UNCYCLOVERSITY) ||
         isConst?(battler.species,PBSpecies,:WIKISOURCE) ||
         isConst?(battler.species,PBSpecies,:UNSCRIPTS) ||
         isConst?(battler.species,PBSpecies,:UNGAME) ||
         isConst?(battler.species,PBSpecies,:WIKIVOYAGE) ||
         isConst?(battler.species,PBSpecies,:UNVOYAGE)
     catchRate*=4
   elsif isConst?(battler.species,PBSpecies,:WIKIMEDIAB) ||
         isConst?(battler.species,PBSpecies,:BOMBOMEDIA)
     catchRate*=2
   end
   next [catchRate,255].min
})

=begin
81 Fusions
4 Fusions with 4 Pkmn
10 Fusions with 3 Pkmn
67 Fusions with 2 Pkmn
=end
BallHandlers::ModifyCatchRate.add(:LAYERBALL,proc{|ball,catchRate,battle,battler|
   if isConst?(battler.species,PBSpecies,:SMNICAKI)  ||
      isConst?(battler.species,PBSpecies,:BULBAMEDIBODIA) ||
      isConst?(battler.species,PBSpecies,:CATERMEDIBODIA) ||
      isConst?(battler.species,PBSpecies,:FABPILHOMEDIA)
     catchRate*=6
   elsif isConst?(battler.species,PBSpecies,:BULBAMANTLE) ||
         isConst?(battler.species,PBSpecies,:IVYMELTLE) ||
         isConst?(battler.species,PBSpecies,:VENURISE) ||
         isConst?(battler.species,PBSpecies,:CHIRPLUP) ||
         isConst?(battler.species,PBSpecies,:MONGLUP) ||
         isConst?(battler.species,PBSpecies,:INTERREON) ||
         isConst?(battler.species,PBSpecies,:FRIKIMANIA) ||
         isConst?(battler.species,PBSpecies,:CROSSMOBILEMEDIA) ||
         isConst?(battler.species,PBSpecies,:FRICYCLOMANIA) ||
         isConst?(battler.species,PBSpecies,:FABPILHOME)
         catchRate*=4.5
   elsif isConst?(battler.species,PBSpecies,:FRIKIVEE) ||
         isConst?(battler.species,PBSpecies,:EMOBOOKS) ||
         isConst?(battler.species,PBSpecies,:CRUSBYSYMANTEC) ||
         isConst?(battler.species,PBSpecies,:OLMER) ||
         isConst?(battler.species,PBSpecies,:SMILORD) ||
         isConst?(battler.species,PBSpecies,:SHELDOS) ||
         isConst?(battler.species,PBSpecies,:BASPARDOS) ||
         isConst?(battler.species,PBSpecies,:KYODON) ||
         isConst?(battler.species,PBSpecies,:CHARMADIA) ||
         isConst?(battler.species,PBSpecies,:CHARMEDIA) ||
         isConst?(battler.species,PBSpecies,:CHARIMANIA) ||
         isConst?(battler.species,PBSpecies,:CATERBOOKS) ||
         isConst?(battler.species,PBSpecies,:YATASAUR) ||
         isConst?(battler.species,PBSpecies,:GEOPINNY) ||
         isConst?(battler.species,PBSpecies,:GRAVSEY) ||
         isConst?(battler.species,PBSpecies,:GOLISSEY) ||
         isConst?(battler.species,PBSpecies,:PONYVERSITY) ||
         isConst?(battler.species,PBSpecies,:RATINEWS) ||
         isConst?(battler.species,PBSpecies,:LEDIGON2) ||
         isConst?(battler.species,PBSpecies,:BRONCHOP) ||
         isConst?(battler.species,PBSpecies,:SNEAWOODO) ||
         isConst?(battler.species,PBSpecies,:RATACHU) ||
         isConst?(battler.species,PBSpecies,:GOLTORB) ||
         isConst?(battler.species,PBSpecies,:HAUNTRODE) ||
         isConst?(battler.species,PBSpecies,:ORAINMEDIA) ||
         isConst?(battler.species,PBSpecies,:CATERSTV) ||
         isConst?(battler.species,PBSpecies,:META6) ||
         isConst?(battler.species,PBSpecies,:BUTTERLE) ||
         isConst?(battler.species,PBSpecies,:LUNAROCK) ||
         isConst?(battler.species,PBSpecies,:STARLIX) ||
         isConst?(battler.species,PBSpecies,:STARAXIO) ||
         isConst?(battler.species,PBSpecies,:STARXRAY) ||
         isConst?(battler.species,PBSpecies,:UNCYCLOVEE) ||
         isConst?(battler.species,PBSpecies,:CROAMOBILEMARKET) ||
         isConst?(battler.species,PBSpecies,:TOXICRUSHSAGA) ||
         isConst?(battler.species,PBSpecies,:TOXIPEDIA) ||
         isConst?(battler.species,PBSpecies,:VSMEDIA) ||
         isConst?(battler.species,PBSpecies,:BOMBKABOO) ||
         isConst?(battler.species,PBSpecies,:UNCYCLOGEIST) ||
         isConst?(battler.species,PBSpecies,:JULKAY) ||
         isConst?(battler.species,PBSpecies,:JUMLAMAR) ||
         isConst?(battler.species,PBSpecies,:PIKIPAZ) ||
         isConst?(battler.species,PBSpecies,:GRAYTRUMPAZ) ||
         isConst?(battler.species,PBSpecies,:OMINETOUPAZ) ||
         isConst?(battler.species,PBSpecies,:EMOCYCLOPEDIA) ||
         isConst?(battler.species,PBSpecies,:SCORMEDIA) ||
         isConst?(battler.species,PBSpecies,:RABMEDIA) ||        
         isConst?(battler.species,PBSpecies,:CINDERMANIA) ||
         isConst?(battler.species,PBSpecies,:LEDYGON) ||
         isConst?(battler.species,PBSpecies,:NEOMEDIA) ||
         isConst?(battler.species,PBSpecies,:MIRAMANIA) ||
         isConst?(battler.species,PBSpecies,:WEEDSTV) ||
         isConst?(battler.species,PBSpecies,:KAKU6) ||
         isConst?(battler.species,PBSpecies,:BEEDRLE) ||
         isConst?(battler.species,PBSpecies,:TOXICLOPEDIA) ||
         isConst?(battler.species,PBSpecies,:SOMANIA) ||
         isConst?(battler.species,PBSpecies,:ZELMEDIA) ||
         isConst?(battler.species,PBSpecies,:ANDROMANIA) ||
         isConst?(battler.species,PBSpecies,:ANDROMANPLUS) ||
         isConst?(battler.species,PBSpecies,:SCORMEDIA) ||
         isConst?(battler.species,PBSpecies,:GASBUNTU) ||
         isConst?(battler.species,PBSpecies,:DHAUNTBUNTU) ||
         isConst?(battler.species,PBSpecies,:BRABUNTU) ||
         isConst?(battler.species,PBSpecies,:BARNMEDIA) ||
         isConst?(battler.species,PBSpecies,:GOTHLOSIS) ||
         isConst?(battler.species,PBSpecies,:YATARYU) ||
         isConst?(battler.species,PBSpecies,:YATARMIE)
         catchRate*=3
    end
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:BEASTBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=5 if isUltraBeast?(battler)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:SHADOWBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=100 if battler.isShadow?
   next catchRate
})

BallHandlers::OnCatch.add(:SHADOWBALL,proc{|ball,battle,pokemon|
   pokemon.makeShadow if !pokemon.isShadow?
})


BallHandlers::ModifyCatchRate.add(:DREAMBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=8 if battler.status==PBStatuses::SLEEP && battler.pbHasType?(:GLIMSE)
   catchRate*=4 if battler.status==PBStatuses::SLEEP || battler.pbHasType?(:GLIMSE)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:GREATDUSKBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*3/2).floor
   catchRate*=7/2 if PBDayNight.isNight?
   next catchRate
})

BallHandlers::OnFailCatch.add(:PRALINEBALL,proc{|ball,battle,battler|
   newhap=battler.happiness+50
   battler.happiness=[newhap,200].min
})

BallHandlers::IsUnconditional.add(:PRALINEBALL,proc{|ball,battle,battler|
   next battler.isShiny? || isRegionalForme?(battler)
})

BallHandlers::OnCatch.add(:PRALINEBALL,proc{|ball,battle,pokemon|
   pokemon.makeShiny if !pokemon.isShiny?
})


BallHandlers::ModifyCatchRate.add(:PRALINEBALL,proc{|ball,catchRate,battle,battler|
   catchRate+=(battler.happiness/5).floor
   if isLegendaryMythicalOrUltra?(battler)
     catchRate*=4 if battler.happiness<101
     catchRate*=2
   end
   catchRate*3/2 if isConst?(battle.battlers[1],PBAbilities,:SHINYGATHER)
   next catchRate
})


BallHandlers::ModifyCatchRate.add(:GREATNESTBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*3/2).floor
  if battler.level<=40
     catchRate*=[(41-battler.level)/10,1].max
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:FLIPNOTEBALL,proc{|ball,catchRate,battle,battler|
   if PBDayNight.isNight?
     colors = [0,1,8]
   else
     colors = [0,1,4]
   end
   catchRate*=7/2 if colors.include?(battler.color)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:GREATFLIPNOTEBALL,proc{|ball,catchRate,battle,battler|
   if PBDayNight.isNight?
     colors = [0,1,2,3,8]
   else
     colors = [0,1,2,3,4]
   end
   catchRate=(catchRate*3/2).floor
   catchRate*=7/2 if colors.include?(battler.color)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:ULTRAFLIPNOTEBALL,proc{|ball,catchRate,battle,battler|
   colors = [0,1,2,3,4,8]
   catchRate=(catchRate*2).floor
   catchRate*=7/2 if colors.include?(battler.color)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:RETURNBONUSBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*3/2).floor
   catchRate*=2 if !battle.pbPlayer.owned[battler.species]
   next catchRate
})