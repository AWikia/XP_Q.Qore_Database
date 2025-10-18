################################################################################
# Mega Evolutions and Primal Reversions are treated as form changes in
# Essentials. The code below is just more of what's in the Pokemon_MultipleForms
# script section, but specifically and only for the Mega Evolution and Primal
# Reversion forms.
################################################################################
class PokeBattle_Pokemon
  def hasMegaForm?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil
  end

  def isMega?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil && v==@form
  end

  def makeMega
    v=MultipleForms.call("getMegaForm",self)
    self.form=v if v!=nil
  end

  def makeUnmega
    v=MultipleForms.call("getUnmegaForm",self)
    if v!=nil; self.form=v
    elsif isMega?; self.form=0
    end
  end

  def megaName
    v=MultipleForms.call("getMegaName",self)
    return (v!=nil) ? v : _INTL("Mega {1}",PBSpecies.getName(self.species))
  end

  def megaMessage
    v=MultipleForms.call("megaMessage",self)
    return (v!=nil) ? v : 0   # 0=default message, 1=Rayquaza message
  end

  def hasPrimalForm?
    v=MultipleForms.call("getPrimalForm",self)
    return v!=nil
  end

  def isPrimal?
    v=MultipleForms.call("getPrimalForm",self)
    return v!=nil && v==@form
  end

  def makePrimal
    v=MultipleForms.call("getPrimalForm",self)
    self.form=v if v!=nil
  end

  def makeUnprimal
    v=MultipleForms.call("getUnprimalForm",self)
    if v!=nil; self.form=v
    elsif isPrimal?; self.form=0
    end
  end
end



# XY Mega Evolution ############################################################

MultipleForms.register(:VENUSAUR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:VENUSAURITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,123,80,122,120] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 24 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1555 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("In order to support its flower, which has grown larger due to Mega Evolution, its back and legs have become stronger.") if pokemon.form==1
}
})

MultipleForms.register(:CHARIZARD,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CHARIZARDITEX)
   next 2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Charizard X") if pokemon.form==1
   next _INTL("Mega Charizard Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,130,111,100,130,85] if pokemon.form==1
   next [78,104,78,100,159,115] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1 # Was Dragon
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
   next [[getID(PBAbilities,:DROUGHT),0]] if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1105 if pokemon.form==1
   next 1005 if pokemon.form==2
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its bond with its Trainer is the source of its power. It boasts speed and maneuverability greater than that of a jet fighter.") if pokemon.form==1 ||  pokemon.form==2
}
})

MultipleForms.register(:BLASTOISE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLASTOISINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [79,103,120,78,135,115] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MEGALAUNCHER),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1011 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The cannon on its back is as powerful as a tank gun. Its tough legs and back enable it to withstand the recoil from firing the cannon.") if pokemon.form==1
}
})

MultipleForms.register(:ALAKAZAM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ALAKAZITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [55,50,65,150,175,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TRACE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 12 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It sends out psychic power from the red organ on its forehead to foresee its opponents' every move.") if pokemon.form==1
}
})

MultipleForms.register(:GENGAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GENGARITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,65,80,130,170,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SHADOWTAG),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It tries to take the lives of anyone and everyone. It will even try to curse the Trainer who is its master!") if pokemon.form==1
}
})

MultipleForms.register(:KANGASKHAN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:KANGASKHANITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,125,100,100,60,100] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PARENTALBOND),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1000 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The explosive energy the child is bathed in causes temporary growth. The mother is beside herself with worry about it.") if pokemon.form==1
}
})

MultipleForms.register(:PINSIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:PINSIRITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,155,120,105,65,90] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1 # Was Flyiong
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:AERILATE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 17 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 590 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After Mega Evolution, it becomes able to fly. Perhaps because it's so happy, it rarely touches the ground.") if pokemon.form==1
}
})

MultipleForms.register(:GYARADOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GYARADOSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,155,109,81,70,130] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DARK) if pokemon.form==1 # Was Dark
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MOLDBREAKER),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3050 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Evolution places a burden on its body. The stress causes it to become all the more ferocious.") if pokemon.form==1
}
})

MultipleForms.register(:AERODACTYL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AERODACTYLITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,135,85,150,70,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 21 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 790 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It will attack anything that moves. Mega Evolution is a burden on its body, so it's incredibly irritated.") if pokemon.form==1
}
})

MultipleForms.register(:MEWTWO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEWTWONITEX)
   next 2 if isConst?(pokemon.item,PBItems,:MEWTWONITEY)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mewtwo X") if pokemon.form==1
   next _INTL("Mega Mewtwo Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [106,190,100,130,154,100] if pokemon.form==1
   next [106,150,70,140,194,120] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1 # Was Fighting
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:STEADFAST),0]] if pokemon.form==1
   next [[getID(PBAbilities,:INSOMNIA),0]] if pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 23 if pokemon.form==1
   next 15 if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1270 if pokemon.form==1
   next 330 if pokemon.form==2
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Psychic power has augmented its muscles. It has a grip strength of one ton and can sprint a hundred meters in two seconds flat!") if pokemon.form==1
   next _INTL("Despite its diminished size, its mental power has grown phenomenally. With a mere thought, it can smash a skyscraper to smithereens.") if pokemon.form==2
}
})

MultipleForms.register(:AMPHAROS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AMPHAROSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,95,105,45,165,110] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1 # Dragon
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MOLDBREAKER),0]] if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Excess energy from Mega Evolution stimulates its genes, and the wool it had lost grows in again.") if pokemon.form==1
}
})

MultipleForms.register(:SCIZOR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCIZORITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,150,140,75,65,100] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TECHNICIAN),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1250 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It stores the excess energy from Mega Evolution, so after a long time passes, its body starts to melt.") if pokemon.form==1
}
})

MultipleForms.register(:HERACROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HERACRONITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,185,115,75,40,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SKILLLINK),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 17 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 625 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It can grip things with its two horns and lift 500 times its own body weight.") if pokemon.form==1
}
})

MultipleForms.register(:HOUNDOOM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HOUNDOOMINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,90,90,115,140,90] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SOLARPOWER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 495 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its red claws and the tips of its tail are melting from high internal temperatures that are painful to Houndoom itself.") if pokemon.form==1
}
})

MultipleForms.register(:TYRANITAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:TYRANITARITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,164,150,71,95,120] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SANDSTREAM),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2550 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Due to the colossal power poured into it, this Pokémon's back split right open. Its destructive instincts are the only thing keeping it moving.") if pokemon.form==1
}
})

MultipleForms.register(:BLAZIKEN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLAZIKENITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,160,80,100,130,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SPEEDBOOST),0]] if pokemon.form==1
   next
}
})

MultipleForms.register(:GARDEVOIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GARDEVOIRITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,85,65,100,165,135] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PIXILATE),0]] if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When it opens the red plate on its chest and unleashes its heart, its strongest psychic power is released.") if pokemon.form==1
}
})

MultipleForms.register(:MAWILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MAWILITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,105,125,50,55,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:HUGEPOWER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 10 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 235 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It has an extremely vicious disposition. It grips prey in its two sets of jaws and tears them apart with raw power.") if pokemon.form==1
}
})

MultipleForms.register(:AGGRON,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AGGRONITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,230,50,60,80] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:STEEL) if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:FILTER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 22 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3950 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Energy from Mega Evolution has turned the iron inside this Pokémon into steel armor that covers Mega Aggron's whole body.") if pokemon.form==1
}
})

MultipleForms.register(:MEDICHAM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEDICHAMITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,100,85,100,80,85] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PUREPOWER),0]] if pokemon.form==1
   next
}
})

MultipleForms.register(:MANECTRIC,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MANECTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,75,80,135,135,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:INTIMIDATE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 440 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Evolution fills its body with a tremendous amount of electricity, but it's too much for Manectric to fully control.") if pokemon.form==1
}
})

MultipleForms.register(:BANETTE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BANETTTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [64,165,75,75,93,83] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PRANKSTER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 12 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 130 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Extraordinary energy amplifies its cursing power to such an extent that it can't help but curse its own Trainer.") if pokemon.form==1
}
})

MultipleForms.register(:ABSOL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ABSOLITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,60,115,115,60] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 490 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Normally, it dislikes fighting, so it really hates changing to this form for battles.") if pokemon.form==1
}
})

MultipleForms.register(:GARCHOMP,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GARCHOMPITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [108,170,115,92,120,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SANDFORCE),0]] if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its arms and wings melted into something like scythes. Mad with rage, it rampages on and on.") if pokemon.form==1
}
})

MultipleForms.register(:LUCARIO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LUCARIONITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,145,88,112,140,70] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ADAPTABILITY),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 13 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 575 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its aura has expanded due to Mega Evolution. Governed only by its combative instincts, it strikes enemies without mercy.") if pokemon.form==1
}
})

MultipleForms.register(:ABOMASNOW,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ABOMASITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,132,105,30,132,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SNOWWARNING),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 27 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1850 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The buds on its back have sprouted into impressive icicles that can whip up massive blizzards of −22 degrees Fahrenheit.") if pokemon.form==1
}
})

# ORAS Mega Evolution ##########################################################

MultipleForms.register(:BEEDRILL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BEEDRILLITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,40,145,15,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ADAPTABILITY),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 405 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its legs have become poison stingers. It stabs its prey repeatedly with the stingers on its limbs, dealing the final blow with the stinger on its rear.") if pokemon.form==1
}
})

MultipleForms.register(:PIDGEOT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:PIDGEOTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [83,80,80,121,135,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 22 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 505 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("With its muscular strength now greatly increased, it can fly continuously for two weeks without resting.") if pokemon.form==1
}
})


MultipleForms.register(:SLOWBRO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SLOWBRONITE) && pokemon.form<2
   next
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
     when 2; next getID(PBTypes,:POISON)  # Alola
     else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
     when 2; next getID(PBTypes,:PSYCHIC)  # Alola
     else;   next 
   end
},
"getBaseStats"=>proc{|pokemon|
   next [95,75,180,30,130,80] if pokemon.form==1
   next [95,100,95,30,100,70] if pokemon.form==2
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SHELLARMOR),0]] if pokemon.form==1
   next [[getID(PBAbilities,:GLUTTONY),0],
         [getID(PBAbilities,:OWNTEMPO),1],
         [getID(PBAbilities,:REGENERATOR),2]] if pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1200 if pokemon.form==1
   next 705  if pokemon.form==2
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[0,:SHELLSIDEARM],[1,:CURSE],[1,:YAWN],[1,:TACKLE],
                     [5,:GROWL],[9,:ACID],[14,:CONFUSION],[19,:DISABLE],
                     [23,:HEADBUTT],[28,:WATERPULSE],[32,:ZENHEADBUTT],
                     [36,:SLACKOFF],[43,:AMNESIA],[49,:PSYCHIC],[55,:RAINDANCE],
                     [62,:PSYCHUP],[68,:HEALPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Tremendous energy strengthened the power of the Shellder on its tail, but it doesn't really affect Slowpoke.") if pokemon.form==1
   next _INTL("A Shellder bite set off a chemical reaction with the spices inside Slowbro's body, causing Slowbro to become a Poison-type Pokémon.") if pokemon.form==2 
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:STEELIX,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:STEELIXITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,125,230,30,55,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SANDFORCE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 105 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 7400 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("To protect itself from opponents' attacks, it uses magnetism to control pieces of its hard outer shell that have flaked off.") if pokemon.form==1
}
})

MultipleForms.register(:SCEPTILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCEPTILITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,110,75,145,145,85] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1 # Was Dragon
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:LIGHTNINGROD),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 552 if pokemon.form==1
   next
}
})

MultipleForms.register(:SWAMPERT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SWAMPERTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,150,110,70,95,110] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SWIFTSWIM),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1020 if pokemon.form==1
   next
}
})

MultipleForms.register(:SABLEYE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SABLENITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,85,125,20,85,115] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1610 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Bathed in the energy of Mega Evolution, the gemstone on its chest expands, rips through its skin, and falls out.") if pokemon.form==1
}
})

MultipleForms.register(:SHARPEDO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHARPEDONITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,70,105,110,65] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:STRONGJAW),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1303 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The yellow patterns it bears are old scars. The energy from Mega Evolution runs through them, causing it sharp pain and suffering.") if pokemon.form==1
}
})

MultipleForms.register(:CAMERUPT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CAMERUPTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,120,100,20,145,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SHEERFORCE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3205 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When this Pokémon's rage reaches a boiling point, the huge volcano in the hump on its back erupts violently, spewing molten lava.") if pokemon.form==1
}
})

MultipleForms.register(:ALTARIA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ALTARIANITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,110,110,80,110,105] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1 # Was Fairy
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PIXILATE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its down is so soft, it seems as if a touch could melt it. But it's strong enough that just a few strands could be used to hoist a dump truck.") if pokemon.form==1
}
})

MultipleForms.register(:GLALIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GLALITITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,120,80,100,120,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:REFRIGERATE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 21 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3502 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When it spews stupendously cold air from its broken mouth, the entire area around it gets whited out.") if pokemon.form==1
}
})

MultipleForms.register(:SALAMENCE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SALAMENCITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,145,130,120,120,90] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:AERILATE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1126 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The stress of its two proud wings becoming misshapen and stuck together because of strong energy makes it go on a rampage.") if pokemon.form==1
}
})

MultipleForms.register(:METAGROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:METAGROSSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,145,150,110,105,110] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 9429 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its intellect surpasses its previous level, resulting in battles so cruel, they'll make you want to cover your eyes.") if pokemon.form==1
}
})

MultipleForms.register(:LATIAS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LATIASITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,120,110,140,150] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 520 if pokemon.form==1
   next
}
})

MultipleForms.register(:LATIOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LATIOSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,130,100,110,160,120] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 23 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 700 if pokemon.form==1
   next
}
})

MultipleForms.register(:RAYQUAZA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if pokemon.hasMove?(:DRAGONASCENT)
   next
},
"megaMessage"=>proc{|pokemon|
   next 1
},
"getBaseStats"=>proc{|pokemon|
   next [105,180,100,115,180,100] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:DELTASTREAM),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 108 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3920 if pokemon.form==1
   next
}
})

MultipleForms.register(:LOPUNNY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:LOPUNNITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,136,94,135,54,96] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1 # Was Fighting
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SCRAPPY),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 13 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 283 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It swings its ears like whips and strikes its enemies with them. It has an intensely combative disposition.") if pokemon.form==1
}
})

MultipleForms.register(:GALLADE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GALLADITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,165,95,110,65,115] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:INNERFOCUS),0]] if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 564 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It gets power from the bond it has with its Trainer. Mega Evolution has given it plates to slice its enemies and a cape to protect its body.") if pokemon.form==1
}
})

MultipleForms.register(:AUDINO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [103,60,126,50,80,126] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:HEALER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 320 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Anyone who touches the secondary feelers that have sprouted from the base of its throat will fall into a deep sleep.") if pokemon.form==1
}
})

MultipleForms.register(:DIANCIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DIANCITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,160,110,110,160,110] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 278 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon is also known as the Royal Pink Princess. The dazzling, sparkling diamond on its forehead is a whopping 2,000 carats.") if pokemon.form==1
}
})

# ZA Mega Evolutions ###########################################################

MultipleForms.register(:CLEFABLE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CLEFABLITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,80,93,70,135,110] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 17 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 423 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It flies by using the power of moonlight to control gravity within a radius of over 32 feet around it.") if pokemon.form==1
}
})

MultipleForms.register(:VICTREEBEL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:VICTREEBELITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,125,85,70,135,95] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 45 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1255 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The volume of this Pokémon's acid has increased due to Mega Evolution, filling its mouth. If it's not careful, the acid will overflow and spill out.") if pokemon.form==1
}
})

MultipleForms.register(:STARMIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:STARMINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,100,105,120,130,105] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 23 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its movements have become more humanlike. Whether it's simply trying to communicate or wants to supplant humanity is unclear.") if pokemon.form==1
}
})

MultipleForms.register(:DRAGONITE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DRAGONINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [91,124,115,100,145,125] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 290 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Evolution has excessively powered up this Pokémon's feelings of kindness. It finishes off its opponents with mercy in its heart.") if pokemon.form==1
}
})

MultipleForms.register(:MEGANIUM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEGANIUMITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,92,115,80,143,115] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FAIRY) if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 24 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2010 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon can fire a tremendously powerful Solar Beam from its four flowers. Another name for this is Mega Sol Cannon.") if pokemon.form==1
}
})

MultipleForms.register(:FERALIGATR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:FERALIGITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [85,160,125,78,89,93] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 1088 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("With its arms and hoodlike fin, this Pokémon forms a gigantic set of jaws with a bite 10 times as powerful as Mega Feraligatr's actual jaws.") if pokemon.form==1
}
})

MultipleForms.register(:SKARMORY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SKARMORITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,140,110,110,40,100] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 404 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It flies faster than the speed of sound. After whipping up shock waves to send enemies flying, it finishes them off with its talons.") if pokemon.form==1
}
})

MultipleForms.register(:FROSLASS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEGANIUMITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,80,70,120,140,100] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 26 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 296 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon can use eerie cold air imbued with ghost energy to freeze even insubstantial things, such as flames or the wind.") if pokemon.form==1
}
})

MultipleForms.register(:EMBOAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:EMBOARITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [110,148,75,75,110,110] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1803 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Brandishing a blazing flame shaped like a serpentine spear, it rushes in to rescue its imperiled allies.") if pokemon.form==1
}
})

MultipleForms.register(:EXCADRILL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:EXCADRITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [110,165,100,103,65,65] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 9 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 600 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("If this Pokémon brings its arms and head together to form a streamlined shape and spins at high speeds, it can destroy anything.") if pokemon.form==1
}
})

MultipleForms.register(:SCOLIPEDE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCOLIPITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,140,149,62,75,99] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 32 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2305 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its deadly venom gives off a faint glow. The venom affects Scolipede's mind, honing its viciousness.") if pokemon.form==1
}
})

MultipleForms.register(:SCRAFTY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCRAFTINITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,130,135,68,55,135] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 310 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Evolution has caused Scrafty's shed skin to turn white, growing tough and supple. Of course, this Pokémon is still as feisty as ever.") if pokemon.form==1
}
})

MultipleForms.register(:EELEKTROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:EELEKTROSSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [85,145,80,80,135,90] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 30 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1800 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It now generates 10 times the electricity it did before Mega Evolving. It discharges this electricity from its false Eelektrik, which are made of mucus.") if pokemon.form==1
}
})

MultipleForms.register(:CHANDELURE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CHANDELURITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,75,110,90,175,110] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 696 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("One of its eyes is a window linking our world with the afterlife. This Pokémon draws in hatred and converts it into power.") if pokemon.form==1
}
})

MultipleForms.register(:CHESNAUGHT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CHESNAUGHTITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [88,147,172,44,74,115] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It has fortified armor and a will to defend at all costs. Both are absurdly strong.") if pokemon.form==1
}
})

MultipleForms.register(:DELPHOX,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DELPHOXITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,69,72,134,159,125] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It wields flaming branches to dazzle its opponents before incinerating them with a huge fireball.") if pokemon.form==1
}
})

MultipleForms.register(:GRENINJA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GRENINJITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [72,125,77,142,133,81] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon spins a giant shuriken at high speed to make it float, then clings to it upside down to catch opponents unawares.") if pokemon.form==1
}
})

MultipleForms.register(:PYROAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:PYROARITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [86,88,92,126,129,86] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 933 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon spews flames hotter than 18,000 degrees Fahrenheit. It swings around its grand, blazing mane as it protects its allies.") if pokemon.form==1
}
})

MultipleForms.register(:FLOETTE,{
"getMegaForm"=>proc{|pokemon|
   next 7 if isConst?(pokemon.item,PBItems,:FLOETTITE) && pokemon.form==6 || pokemon.form==7
   next
},
"getBaseStats"=>proc{|pokemon|
   next [74,65,67,92,125,128]  if pokemon.form==6  # Eternal Flower
   next [74,85,87,102,155,148] if pokemon.form==7  # Mega Floette
   next                                            # Standard Flowers
},
"baseExp"=>proc{|pokemon|
   next 243 if pokemon.form==6 || pokemon.form==7  # Eternal Flower & Mega Floette
   next                                            # Standard Flowers
},
"height"=>proc{|pokemon|
   next 1008 if pokemon.form==7
   next
},
"getMoveList"=>proc{|pokemon|
   if pokemon.form==6 || pokemon.form==7
     movelist=[[1,:TACKLE],[1,:VINEWHIP],[1,:FAIRYWIND],
               [6,:FAIRYWIND],[10,:LUCKYCHANT],[15,:RAZORLEAF],
               [20,:WISH],[25,:MAGICALLEAF],[27,:GRASSYTERRAIN],
               [33,:PETALBLIZZARD],[38,:AROMATHERAPY],[43,:MISTYTERRAIN],
               [46,:MOONBLAST],[50,:LIGHTOFRUIN],[51,:PETALDANCE],[58,:SOLARBEAM]]
     for i in movelist
       i[1]=getConst(PBMoves,i[1])
     end
     next movelist
   end
   next
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[92,398]  # Maps for Eternal Flower
   next ($game_map && maps.include?($game_map.map_id)) ? 6 : rand(6)
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("This Pokémon can draw forth the power hidden within yellow flowers. This power then becomes the moves Floette uses to protect itself.") if pokemon.form==1
   next _INTL("This Pokémon can draw forth the most power when in sync with orange flowers, compared to flowers of other colors.") if pokemon.form==2
   next _INTL("Whenever this Pokémon finds flowering plants that are withering, it will bring them back to its territory and care for them until they are healthy.") if pokemon.form==3
   next _INTL("Floette that are fond of white flowers can also easily sync with flowers of other colors.") if pokemon.form==4
   next _INTL("This Pokémon can draw forth the most power when in sync with pink flowers, compared to flowers of other colors.") if pokemon.form==5
   next _INTL("This rare Floette holds a plant that died out in ancient times. The Pokémon is said to harbor an incredible power.") if pokemon.form==6
   next _INTL("The Eternal Flower has absorbed all the energy from Mega Evolution. The flower now attacks enemies on its own.") if pokemon.form==7
}
})

MultipleForms.register(:MALAMAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MALAMARITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [86,102,88,88,98,120] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 29 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 698 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It uses its colorful lights to overwrite the personalities and memories of others—and to control them.") if pokemon.form==1
}
})

MultipleForms.register(:BARBARACLE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BARBARACITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [72,140,130,88,64,106] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 22 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1000 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It uses its many arms to toy with its opponents. This keeps the head extremely busy.") if pokemon.form==1
}
})

MultipleForms.register(:DRAGALGE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DRAGALGITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,85,105,44,132,163] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 21 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1003 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It spits a liquid that causes the regenerative power of cells to run wild. The liquid is deadly poison to everything other than itself.") if pokemon.form==1
}
})

MultipleForms.register(:HAWLUCHA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HAWLUCHANITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,137,100,118,74,93] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 10 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 250 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Evolution has pumped up all its muscles. Hawlucha flexes to show off its strength.") if pokemon.form==1
}
})

MultipleForms.register(:ZYGARDE,{
"getMegaForm"=>proc{|pokemon|
   next 3 if isConst?(pokemon.item,PBItems,:ZYGARDITE) && pokemon.form==2 || pokemon.form==3
   next
},
"weight"=>proc{|pokemon|
   next 335 if pokemon.form==1
   next 6100 if pokemon.form==2 || pokemon.form==3
   next # 50%   
},
"height"=>proc{|pokemon|
   next 12 if pokemon.form==1
   next 45 if pokemon.form==2
   next 77 if pokemon.form==3
   next # 50%
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This is Zygarde when about 10% of its species have been assembled. It leaps at its opponents chest and sinks its sharp fangs into them.") if pokemon.form==1
   next _INTL("This is Zygarde's perfect form From the orfice on its chect, it radiates high-powered energy that eliminates everything.") if pokemon.form==2
   next _INTL("In response to people's emotions during an unprecedented crisis, Zygarde Mega Evolves and calms the situation with its unmatched power.") if pokemon.form==3
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0 # 50%
   next [54,100,71,115,61,85] if pokemon.form==1
   next [216,100,121,85,91,95] if pokemon.form==2
   next [216,70,91,100,216,85] if pokemon.form==3
},
"color"=>proc{|pokemon|
   next if pokemon.form==0  # 50%
   next 5                   # The rest
}
})

MultipleForms.register(:DRAMPA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DRAMPANITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,85,110,36,160,116] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"weight"=>proc{|pokemon|
   next 2405 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Drampa's cells have been invigorated, allowing it to regain its youth. It manipulates the atmosphere to summon storms.") if pokemon.form==1
}
})

MultipleForms.register(:FALINKS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:FALINKSITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,135,135,100,70,65] if pokemon.form==1
   next
},
=begin
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
   next
},
=end
"height"=>proc{|pokemon|
   next 16 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 990 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Mega Falinks has taken on the ultimate battle formation, which can be achieved only if the troopers and brass have the strongest of bonds.") if pokemon.form==1
}
})

# Q.Qore Mega Evolutions #######################################################

MultipleForms.register(:GIRAFARIG,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GIRAFARIGITE)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,90,85,105,110,95] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PARENTALBOND),0]] if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After having undergo Mega Evolution, a second brown Girafarig head had appeared. Its twin body allows attacking its targets twice.") if pokemon.form==1
}
})

MultipleForms.register(:NICKELODEON,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"getPrimalForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:CRYSTALORB)
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:GROUND) if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next getID(PBTypes,:WATER) if pokemon.form==2
   next
},

"getBaseStats"=>proc{|pokemon|
   next [113,29,41,119,127,124] if pokemon.form==1
   next [113,49,41,99,127,144] if pokemon.form==2
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ANTICYCLONE),0]] if pokemon.form==1
   next [[getID(PBAbilities,:PRIMORDIALSEA),0]] if pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next 16 if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 700 if pokemon.form==2
   next
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a Nickelodeon becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
   next _INTL("Ancient Nickelodeon can become more durable if they're kept in an extremely safe place and don't battle too much.") if pokemon.form==2
}
})

MultipleForms.register(:NICKPLUS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"getPrimalForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:CRYSTALORB)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next getID(PBTypes,:WATER) if pokemon.form==2
   next
},

"getBaseStats"=>proc{|pokemon|
   next [225,81,82,220,240,237] if pokemon.form==1
   next [225,101,82,200,240,257] if pokemon.form==2
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ANTICYCLONE),0]] if pokemon.form==1
   next [[getID(PBAbilities,:PRIMORDIALSEA),0]] if pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next 16 if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1050 if pokemon.form==2
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a Nickplus becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
   next _INTL("Ancient Nickplus can become more durable if they're kept in an extremely safe place and don't battle too much.") if pokemon.form==2
}
})


MultipleForms.register(:ANT1,{
"getMegaForm"=>proc{|pokemon|
   natures=[PBNatures::LONELY,PBNatures::BOLD,PBNatures::RELAXED,
            PBNatures::TIMID,PBNatures::SERIOUS,PBNatures::MODEST,
            PBNatures::MILD,PBNatures::QUIET,PBNatures::BASHFUL,
            PBNatures::CALM,PBNatures::GENTLE,
            PBNatures::CAREFUL] # Natures for 2nd form
   next (natures.include?(pokemon.nature)) ? 2 : 1 if isConst?(pokemon.item,PBItems,:ANT1ITE)
   next
},
"getPrimalForm"=>proc{|pokemon|
   next 3 if isConst?(pokemon.item,PBItems,:GOLDORB)
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:MAGIC) if pokemon.form==3
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:ELECTRIC) if pokemon.form==1
   next getID(PBTypes,:ICE) if pokemon.form==2
   next getID(PBTypes,:HERB) if pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,139,203,58,90,110] if pokemon.form==1
   next [100,124,188,68,100,120] if pokemon.form==2
   next [100,154,208,48,90,100] if pokemon.form==3
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:STATIC),0]] if pokemon.form==1
   next [[getID(PBAbilities,:FROZENBODY),0]] if pokemon.form==2
   next [[getID(PBAbilities,:MAGICBLOCK),0]] if pokemon.form==3
   next
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
   next 1 if pokemon.form==2
   next 2 if pokemon.form==3
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   next 10
},
"weight"=>proc{|pokemon|
   next     if pokemon.form==0
   next 500 if pokemon.form==1
   next 515 if pokemon.form==2
   next 510 if pokemon.form==3
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Once ANT1 gets mega-evolved, it became full yellow body with the ability to Paralyze almost any target once one makes contact with it.") if pokemon.form==1
   next _INTL("This ANT1 has the ability to freeze targets if one makes contact with it, something other Mega Evolved Pokémon don't have at the moment.") if pokemon.form==2
   next _INTL("This ANT1 appears to be dated back to the old ages. Nothing else known yet") if pokemon.form==3
}
})


MultipleForms.register(:MAKTV,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MAKITE)
   next
},
"getPrimalForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:SILVERORB)
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:STEEL) if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:PSYCHIC) if pokemon.form==1
   next getID(PBTypes,:SHARPENER) if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,105,90,78,149,178] if pokemon.form==1
   next [100,80,100,48,144,218] if pokemon.form==2
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ASSAULTSPIRIT),0]] if pokemon.form==1
   next [[getID(PBAbilities,:SOUPRSOWL),0]] if pokemon.form==2
   next
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
   next 7 if pokemon.form==2
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   next 9 if pokemon.form==1
},
"weight"=>proc{|pokemon|
   next     if pokemon.form==0
   next 100 if pokemon.form==1
   next 70  if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Once a Mak TV gets mega-evolved, it became a pure pink body with the ability to protect others from Pokémon with dangerous abilities.") if pokemon.form==1
   next _INTL("This Makedonia TV appears to be dated back to the old ages. Nothing else known yet") if pokemon.form==2
}
})

MultipleForms.register(:NICKJR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [180,55,65,120,65,145] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:BIGPECKS),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a Nick Jr. becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
}
})


MultipleForms.register(:ANDROID,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ANDROIDITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,175,50,0,65,77] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ANTICYCLONE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1000 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After mega evolving, Android becomes a true 3D human bot with many fighting capabilities. How this happened is unknown.") if pokemon.form==1
}
})

MultipleForms.register(:ANDROPLUS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ANDROIDITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIGHTING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [200,255,90,45,120,134] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ANTICYCLONE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1500 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After mega evolving, Android becomes a true 3D human bot with many fighting capabilities. How this happened is unknown.") if pokemon.form==1
}
})

MultipleForms.register(:HEARTBRAND,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE)
   next 2 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE2)
   next 3 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE3)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Heartbrand2") if pokemon.form==2
   next _INTL("Mega Heartbrand3") if pokemon.form==3
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:MAGIC) if pokemon.form==3
   next
},

"type2"=>proc{|pokemon|
   next getID(PBTypes,:ELECTRIC) if pokemon.form==1
   next getID(PBTypes,:MAGIC) if pokemon.form==2 || pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,70,75,30,70,75] if pokemon.form==1
   next [100,65,80,30,65,80] if pokemon.form==2
   next [100,70,70,40,70,70] if pokemon.form==3
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TRUMMETSPIRIT),0]] if pokemon.form==1
   next [[getID(PBAbilities,:SOUFLIZ),0]] if pokemon.form==2
   next [[getID(PBAbilities,:MAGICBLOCK),0]] if pokemon.form==3
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After having undergo Mega Evolution, a yellow glow started appearing inside Heartbrand's body.") if pokemon.form==1
   next _INTL("Moments after mega-evolving and after a yellow glow started appearing inside Heartbrand's body, its body then became darker and magical.") if pokemon.form==2
   next _INTL("After Mega Evovling into this form, this Pokemon started to block any Magical attack he found.") if pokemon.form==3
}
})

MultipleForms.register(:HEARTPLUS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE)
   next 2 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE2)
   next 3 if isConst?(pokemon.item,PBItems,:HEARTBRANDITE3)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Heartplus2") if pokemon.form==2
   next _INTL("Mega Heartplus3") if pokemon.form==3
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:ELECTRIC) if pokemon.form==1
   next getID(PBTypes,:MAGIC) if pokemon.form==2 || pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   next [212,125,141,72,125,141] if pokemon.form==1
   next [212,120,146,72,120,146] if pokemon.form==2
   next [212,125,136,82,125,136] if pokemon.form==3
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:TRUMMETSPIRIT),0]] if pokemon.form==1
   next [[getID(PBAbilities,:SOUFLIZ),0]] if pokemon.form==2
   next [[getID(PBAbilities,:MAGICBLOCK),0]] if pokemon.form==3
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After having undergo Mega Evolution, a yellow glow started appearing inside Heartbrand's body.") if pokemon.form==1
   next _INTL("Moments after mega-evolving and after a yellow glow started appearing inside Heartbrand's body, its body then became darker and magical.") if pokemon.form==2
   next _INTL("After Mega Evovling into this form, this Pokemon started to block any Magical attack he found.") if pokemon.form==3
}
})

MultipleForms.register(:BARNEY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BARNEYITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:PSYCHIC) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,110,90,40,130,110] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:MINDYGLOPS),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 600 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After having undergo Mega Evolution, Barney gains purple and green ovals.") if pokemon.form==1
}
})

MultipleForms.register(:COPILOT,{
"getMegaForm"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   form = (d%5==0) ? 1 : (d%4==0) ? 2 : (d%3==0) ? 3 : (d%2==0) ? 4 : 5
   next form if isConst?(pokemon.item,PBItems,:COPILOTITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIRE)  if pokemon.form==1
   next getID(PBTypes,:GRASS) if pokemon.form==2
   next getID(PBTypes,:ICE)   if pokemon.form==3
   next getID(PBTypes,:BOLT)  if pokemon.form==4
   next getID(PBTypes,:MAGIC) if pokemon.form==5
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,135,95,85,95,95]    if pokemon.form==1
   next [105,95,135,85,95,95]    if pokemon.form==2
   next [105,95,95,85,135,95]    if pokemon.form==3
   next [105,95,95,85,95,135]    if pokemon.form==4
   next [105,105,105,85,105,105] if pokemon.form==5
   next
},
"color"=>proc{|pokemon|
   next 0 if pokemon.form==1
   next 3 if pokemon.form==2
   next 1 if pokemon.form==3
   next 6 if pokemon.form==4
   next 0 if pokemon.form==5
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:FLAMEBODY),0]] if pokemon.form==1
   next [[getID(PBAbilities,:EFFECTSPORE),0]] if pokemon.form==2
   next [[getID(PBAbilities,:FROZENBODY),0]] if pokemon.form==3
   next [[getID(PBAbilities,:STATIC),0]] if pokemon.form==4
   next [[getID(PBAbilities,:SOUFLAZ),0]] if pokemon.form==5
   next
},
"height"=>proc{|pokemon|
   next 17 if pokemon.form>0
   next
},
"weight"=>proc{|pokemon|
   next 4750 if pokemon.form>0
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Once Copilot gets mega evolved, it becomes a specialized O shape. The Reds excel in attacking.")                     if pokemon.form==1
   next _INTL("Once Copilot gets mega evolved, it becomes a specialized O shape. The Greens excel in defensing.")                   if pokemon.form==2
   next _INTL("Once Copilot gets mega evolved, it becomes a specialized O shape. The Blues excel in magic attacking.")              if pokemon.form==3
   next _INTL("Once Copilot gets mega evolved, it becomes a specialized O shape. The Purples excel in magic defensing.")            if pokemon.form==4
   next _INTL("Once Copilot gets mega evolved, it becomes a specialized O shape. The Rainbows do not appear to excel in anything.") if pokemon.form==5
}
})

MultipleForms.register(:TEENNICK,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,90,90,53,60,60] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:LOVINGCLUSTER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a TeenNick becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
}
})

MultipleForms.register(:NICKTEEN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,60,60,53,90,90] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:LOVINGCLUSTER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a NickTeen becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
}
})

MultipleForms.register(:NICKATNITE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"type1"=>proc{|pokemon|
   next if pokemon.isMale?
   next getID(PBTypes,:CHLOROPHYLL) # Eternal
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [160,85,60,119,97,68] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:OPPORTUNIST),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"getMoveList"=>proc{|pokemon|
   if pokemon.isFemale?
     movelist=[[1,:LICK],[1,:LEER],[6,:CHLOROPHYLL],[12,:ROLLOUT],[18,:MIMIC],
               [30,:AROMATHERAPY],[35,:CHLOROSTRENGTH],[45,:LICKINGLICK],
               [50,:SUPERCHLOROPHYLL],[60,:CASTLEMANIA],[75,:LICKSTART]]
     for i in movelist
       i[1]=getConst(PBMoves,i[1])
     end
     next movelist
   end
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a Nick@Nite becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
}
})

MultipleForms.register(:NICKMUSIC,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:NICKITE)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FLYING) if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [120,85,85,75,145,145] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SOUNDPROOF),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 101 if pokemon.form==1
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When a NickMusic becomes Mega Evolved, it gains a splat-like appearance to increase its mind and fly everywhere.") if pokemon.form==1
}
})

# Primal Reversion #############################################################

MultipleForms.register(:KYOGRE,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLUEORB)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,150,90,90,180,160] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PRIMORDIALSEA),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 98 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 4300 if pokemon.form==1
   next
}
})

MultipleForms.register(:GROUDON,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:REDORB)
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,180,160,90,150,90] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:FIRE) if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:DESOLATELAND),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 50 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 9997 if pokemon.form==1
   next
}
})

MultipleForms.register(:WINDOWS10,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MICROSOFTORB)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:MAGIC) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:TRUMMETSPIRIT)
     else;   next 
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next [159,125,179,10,145,156]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Windows 10 have undergone Primal Reversion. When it gets Microsoft-colored, no one will ever know that Windows have been transfromed into a Microsoft-like appearance.") if pokemon.form==1
}
})



MultipleForms.register(:WINDOWS11,{
"getPrimalForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MICROSOFTORB)
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:MAGIC) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:TRUMMETSPIRIT)
     else;   next 
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next [209,175,229,10,195,206]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Windows 11 have undergone Primal Reversion. When it gets Microsoft-colored, no one will ever know that Windows have been transfromed into a Microsoft-like appearance.") if pokemon.form==1
}

})