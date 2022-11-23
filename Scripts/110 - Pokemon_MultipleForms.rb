class PokeBattle_Pokemon
  attr_accessor(:formTime)   # Time when Furfrou's/Hoopa's form was set
  def form
    return @forcedform if @forcedform!=nil
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end

  def form=(value)
    @form=value
    MultipleForms.call("onSetForm",self,value)
    self.calcStats
    pbSeenForm(self)
  end

  def formNoCall=(value)
    @form=value
    self.calcStats
  end

  def forceForm(value)   # Used by the Pokédex only
    @forcedform=value
  end

  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_getAbilityList getAbilityList
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_color color
  alias __mf_height height
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_isCompatibleWithMove? isCompatibleWithMove?
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_kind kind
  alias __mf_dexEntry dexEntry
  alias __mf_initialize initialize

  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end

  def ability   # DEPRECATED - do not use
    v=MultipleForms.call("ability",self)
    return v if v!=nil
    return self.__mf_ability
  end

  def getAbilityList
    v=MultipleForms.call("getAbilityList",self)
    return v if v!=nil && v.length>0
    return self.__mf_getAbilityList
  end

  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end

  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end

  def color
    v=MultipleForms.call("color",self)
    return v if v!=nil
    return self.__mf_color
  end
  
  def height
    v=MultipleForms.call("height",self)
    return v if v!=nil
    return self.__mf_height
  end

  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil
    return self.__mf_weight
  end

  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end

  def isCompatibleWithMove?(move)
    v=MultipleForms.call("getMoveCompatibility",self)
    if v!=nil
      return v.any? {|j| j==move }
    end
    return self.__mf_isCompatibleWithMove?(move)
  end

  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end

  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end

  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end

  def kind
    v=MultipleForms.call("kind",self)
    return v if v!=nil
    return self.__mf_kind
  end

  def dexEntry
    v=MultipleForms.call("dexEntry",self)
    return v if v!=nil
    return self.__mf_dexEntry
  end

  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    if f
      self.form=f
      self.resetMoves
    end
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
    end
  end
end



module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)

  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end

  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end

  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end

  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end

  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end

  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end   
    end
  end
end

def pbDimosiaSpots(pokemon,bitmap)  # ΔΤ's Spots (Eight spots maxinum)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isFemale?
    if pokemon.isShiny?
      drawSpot(bitmap,spot3,b+32,a+26,-255,-255,-255)
      drawSpot(bitmap,spot4,d+20,c+24,-255,-255,-255)
      drawSpot(bitmap,spot3,f+38,e+6,-255,-255,-255)
      drawSpot(bitmap,spot4,h+14,g+8,-255,-255,-255)
      drawSpot(bitmap,spot3,a+32,b+26,-255,-255,-255)
      drawSpot(bitmap,spot4,c+20,d+24,-255,-255,-255)
      drawSpot(bitmap,spot3,e+38,f+6,-255,-255,-255)
      drawSpot(bitmap,spot4,g+14,h+8,-255,-255,-255)
    else
      drawSpot(bitmap,spot3,b+32,a+26,255,255,255)
      drawSpot(bitmap,spot4,d+20,c+24,255,255,255)
      drawSpot(bitmap,spot3,f+38,e+6,255,255,255)
      drawSpot(bitmap,spot4,h+14,g+8,255,255,255)
      drawSpot(bitmap,spot3,a+32,b+26,255,255,255)
      drawSpot(bitmap,spot4,c+20,d+24,255,255,255)
      drawSpot(bitmap,spot3,e+38,f+6,255,255,255)
      drawSpot(bitmap,spot4,g+14,h+8,255,255,255)
    end
  else
    if pokemon.isShiny?
      drawSpot(bitmap,spot1,b+32,a+26,-255,-255,-255)
      drawSpot(bitmap,spot2,d+20,c+24,-255,-255,-255)
      drawSpot(bitmap,spot1,f+38,e+6,-255,-255,-255)
      drawSpot(bitmap,spot2,h+14,g+8,-255,-255,-255)
      drawSpot(bitmap,spot1,a+32,b+26,-255,-255,-255)
      drawSpot(bitmap,spot2,c+20,d+24,-255,-255,-255)
      drawSpot(bitmap,spot1,e+38,f+6,-255,-255,-255)
      drawSpot(bitmap,spot2,g+14,h+8,-255,-255,-255)
    else
      drawSpot(bitmap,spot1,b+32,a+26,255,255,255)
      drawSpot(bitmap,spot2,d+20,c+24,255,255,255)
      drawSpot(bitmap,spot1,f+38,e+6,255,255,255)
      drawSpot(bitmap,spot2,h+14,g+8,255,255,255)
      drawSpot(bitmap,spot1,a+32,b+26,255,255,255)
      drawSpot(bitmap,spot2,c+20,d+24,255,255,255)
      drawSpot(bitmap,spot1,e+38,f+6,255,255,255)
      drawSpot(bitmap,spot2,g+14,h+8,255,255,255)
    end
  end
end

def pbSylviaSpots(pokemon,bitmap)
  spot2=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot1=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot4=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot3=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,200,200,200)
    drawSpot(bitmap,spot2,d+21,c+24,200,200,200)
    drawSpot(bitmap,spot3,f+39,e+7,200,200,200)
    drawSpot(bitmap,spot4,h+15,g+6,200,200,200)

    drawSpot(bitmap,spot1,a+33,b+25,200,200,200)
    drawSpot(bitmap,spot2,c+21,d+24,200,200,200)
    drawSpot(bitmap,spot3,e+39,f+7,200,200,200)
    drawSpot(bitmap,spot4,g+15,h+6,200,200,200)

  else
    drawSpot(bitmap,spot1,b+33,a+25,190,190,190)
    drawSpot(bitmap,spot2,d+21,c+24,190,190,190)
    drawSpot(bitmap,spot3,f+39,e+7,190,190,190)
    drawSpot(bitmap,spot4,h+15,g+6,190,190,190)

    drawSpot(bitmap,spot1,a+33,b+25,190,190,190)
    drawSpot(bitmap,spot2,c+21,d+24,190,190,190)
    drawSpot(bitmap,spot3,e+39,f+7,190,190,190)
    drawSpot(bitmap,spot4,g+15,h+6,190,190,190)
  end
end



def pbSpindaSpots(pokemon,bitmap)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
    drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
    drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
    drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end


################################################################################
# Regional Forms
################################################################################

########################################
# Generation I
########################################

MultipleForms.register(:RATTATA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:NORMAL)  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 38                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:GLUTTONY),0],
         [getID(PBAbilities,:HUSTLE),1],
         [getID(PBAbilities,:THICHFAT),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:PECHABERRY),
         0] if pokemon.form==1 # Eternal
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its incisors grow continuously throughout its life. If its incisors get too long, this Pokémon becomes unable to eat, and it starves to death.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ASSURANCE,:ATTRACT,:BITE,:BLIZZARD,:CONFIDE,:COUNTER,:COVET,
             :CRUNCH,:DARKPULSE,:DOUBLEEDGE,:DOUBLETEAM,:EMBARGO,:ENDEAVOR,
             :FACADE,:FINALGAMBIT,:FOCUSENERGY,:FRUSTRATION,:FURYSWIPES,
             :GRASSKNOT,:HIDDENPOWER,:HYPERFANG,:ICEBEAM,:ICYWIND,:IRONTAIL,
             :LASTRESORT,:MEFIRST,:PROTECT,:PURSUIT,:QUASH,:QUICKATTACK,
             :RAINDANCE,:REST,:RETURN,:REVENGE,:REVERSAL,:ROUND,:SHADOWBALL,
             :SHADOWCLAW,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SNARL,:SNATCH,
             :SNORE,:STOCKPILE,:SUBSTITUTE,:SUCKERPUNCH,:SUNNYDAY,:SUPERFANG,
             :SWAGGER,:SWALLOW,:SWITCHEROO,:TACKLE,:TAILWHIP,:TAUNT,:THIEF,
             :TORMENT,:TOXIC,:UPROAR,:UTURN,:ZENHEADBUTT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:RATICATE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:NORMAL)  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 255                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:GLUTTONY),0],
         [getID(PBAbilities,:HUSTLE),1],
         [getID(PBAbilities,:THICHFAT),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:PECHABERRY),
         0] if pokemon.form==1 # Eternal
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [75,71,70,77,40,80] # Sandy Cloak
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It has an incredibly greedy personality. Its nest is filled with so much food gathered by Rattata at its direction, it can't possibly eat it all.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ASSURANCE,:ATTRACT,:BITE,:BLIZZARD,:BULKUP,:CONFIDE,:COUNTER,
             :COVET,:CRUNCH,:DARKPULSE,:DOUBLEEDGE,:DOUBLETEAM,:EMBARGO,
             :ENDEAVOR,:FACADE,:FINALGAMBIT,:FOCUSENERGY,:FRUSTRATION,
             :FURYSWIPES,:GIGAIMPACT,:GRASSKNOT,:HIDDENPOWER,:HYPERBEAM,
             :HYPERFANG,:ICEBEAM,:ICYWIND,:IRONTAIL,:KNOCKOFF,:LASTRESORT,
             :MEFIRST,:PROTECT,:PURSUIT,:QUASH,:QUICKATTACK,:RAINDANCE,:REST,
             :RETURN,:REVENGE,:REVERSAL,:ROAR,:ROUND,:SCARYFACE,:SHADOWBALL,
             :SHADOWCLAW,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNARL,
             :SNATCH,:SNORE,:STOCKPILE,:STOMPINGTANTRUM,:SUBSTITUTE,
             :SUCKERPUNCH,:SUNNYDAY,:SUPERFANG,:SWAGGER,:SWALLOW,:SWITCHEROO,
             :SWORDSDANCE,:TACKLE,:TAILWHIP,:TAUNT,:THIEF,:THROATCHOP,:TORMENT,
             :TOXIC,:UPROAR,:UTURN,:VENOSHOCK,:ZENHEADBUTT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:EKANS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:POISONFANG],
                     [10,:LIGHTBALL],[15,:LEECHSEED],[20,:MOONBLAST],
                     [25,:POISONGAS],[30,:REVELATIONDANCE],[35,:GRASSKNOT],
                     [40,:DRAGONBREATH],[45,:GRASSYTERRAIN],[45,:BARNETTGREENHOUSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:POISONTOUCH),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Ekans has become green. It has the power of leafy terrain and the ability of causing a lot of acid into the battlefield.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 1 if rand(65536)<$REGIONALCOMBO
     next 0 
   end
}
})

MultipleForms.register(:ARBOK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:POISONFANG],
                     [10,:LIGHTBALL],[15,:LEECHSEED],[20,:MOONBLAST],
                     [25,:POISONGAS],[30,:REVELATIONDANCE],[35,:GRASSKNOT],
                     [40,:DRAGONBREATH],[45,:GRASSYTERRAIN],[45,:BARNETTGREENHOUSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:POISONTOUCH),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After being evolved into this form, its Gastro power came true. Like Ekans, it can create a lot of Greenhouse effects when needed.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 1 if rand(65536)<$REGIONALCOMBO
     next 0 
   end
}
})



# Form 0    - Kantonian
# Form 1    - Alolan
# Form 2    - Cosplay Pikachu w/o costume
# Forms 3-7 - Cosplay Pikachu w/costume

MultipleForms.register(:PIKACHU,{
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   env=pbGetEnvironment()
   next 0 unless env==PBEnvironment::Alola
   next 1
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 50                          # Alola
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [35,50,35,90,55,55] # Sandy Cloak
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0  || pokemon.form>1                 
   next [[getID(PBAbilities,:ELECTRICSURGE),0],
         [getID(PBAbilities,:LIGHTNINGROD),2]]
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TAILWHIP],[1,:THUNDERSHOCK],[5,:GROWL],[7,:PLAYNICE],
                     [10,:QUICKATTACK],[13,:ELECTROBALL],[18,:THUNDERWAVE],
                     [21,:REST],[23,:DOUBLETEAM],[26,:NUZZLE],[29,:SNORE],
                     [34,:DISCHARGE],[37,:SLAM],[42,:THUNDERBOLT],[45,:AGILITY],
                     [50,:SPEEDSWAP],[53,:LIGHTSCREEN],[56,:THUNDER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"onSetForm"=>proc{|pokemon,form|
   moves=[
      :METEORMASH,
      :ICICLECRASH,
      :DRAININGKISS,
      :ELECTRICTERRAIN,
      :FLYINGPRESS
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if form>2
     newmove=moves[form-3]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename=PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove]=PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   elsif form==2
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
       end
     end
   end
}
})

MultipleForms.register(:RAICHU,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 70                          # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 210                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SURGESURFER),0],
         [getID(PBAbilities,:LIGHTNINGROD),2]] # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,85,50,110,95,85] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:PSYCHIC],[1,:PSYCHIC],[1,:SPEEDSWAP],
                     [1,:THUNDERSHOCK],[1,:TAILWHIP],[1,:QUICKATTACK],
                     [1,:THUNDERBOLT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It focuses psychic energy into its tail and rides it like it's surfing. Another name for this Pokémon is \“hodad.\"") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AGILITY,:ALLYSWITCH,:ATTRACT,:BESTOW,:BIDE,:BODYSLAM,:BRICKBREAK,
             :CALMMIND,:CAPTIVATE,:CELEBRATE,:CHARGE,:CHARGEBEAM,:CHARM,
             :CONFIDE,:COUNTER,:COVET,:DEFENSECURL,:DIG,:DISARMINGVOICE,
             :DISCHARGE,:DOUBLEEDGE,:DOUBLESLAP,:DOUBLETEAM,:DYNAMICPUNCH,
             :ECHOEDVOICE,:ELECTRICTERRAIN,:ELECTROBALL,:ELECTROWEB,:ENCORE,
             :ENDEAVOR,:ENDURE,:EXTREMESPEED,:FACADE,:FAKEOUT,:FEINT,:FLAIL,
             :FLASH,:FLING,:FLY,:FOCUSBLAST,:FOCUSPUNCH,:FOLLOWME,:FRUSTRATION,
             :GIGAIMPACT,:GRASSKNOT,:GROWL,:HAPPYHOUR,:HEADBUTT,:HEARTSTAMP,
             :HELPINGHAND,:HIDDENPOWER,:HOLDHANDS,:HYPERBEAM,:IRONTAIL,
             :KNOCKOFF,:LASERFOCUS,:LASTRESORT,:LIGHTSCREEN,:LUCKYCHANT,
             :MAGICCOAT,:MAGICROOM,:MAGNETRISE,:MEGAKICK,:MEGAPUNCH,:MIMIC,
             :MUDSLAP,:NASTYPLOT,:NATURALGIFT,:NUZZLE,:PAYDAY,:PLAYNICE,
             :PRESENT,:PROTECT,:PSYCHIC,:PSYSHOCK,:QUICKATTACK,:RAGE,:RAINDANCE,
             :RECYCLE,:REFLECT,:REST,:RETURN,:REVERSAL,:ROCKSMASH,:ROLLOUT,
             :ROUND,:SAFEGUARD,:SECRETPOWER,:SEISMICTOSS,:SHOCKWAVE,:SIGNALBEAM,
             :SING,:SKULLBASH,:SLAM,:SLEEPTALK,:SNORE,:SPARK,:SPEEDSWAP,
             :STRENGTH,:SUBMISSION,:SUBSTITUTE,:SURF,:SWAGGER,:SWEETKISS,:SWIFT,
             :TAILWHIP,:TAKEDOWN,:TEETERDANCE,:TELEKINESIS,:THIEF,:THUNDER,
             :THUNDERBOLT,:THUNDERPUNCH,:THUNDERSHOCK,:THUNDERWAVE,:TICKLE,
             :TOXIC,:UPROAR,:VOLTSWITCH,:VOLTTACKLE,:WILDCHARGE,:WISH,:YAWN,
             :EXPANDINGFORCE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:SANDSHREW,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 7                          # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 400                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SNOWCLOAK),0],
         [getID(PBAbilities,:SLUSHRUSH),2]]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [50,75,90,40,10,35] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SCRATCH],[1,:DEFENSECURL],[3,:BIDE],
                     [5,:POWDERSNOW],[7,:ICEBALL],[9,:RAPIDSPIN],
                     [11,:FURYCUTTER],[14,:METALCLAW],[17,:SWIFT],
                     [20,:FURYSWIPES],[23,:IRONDEFENSE],[26,:SLASH],
                     [30,:IRONHEAD],[34,:GYROBALL],[38,:SWORDSDANCE],
                     [42,:HAIL],[46,:BLIZZARD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After fleeing a volcanic eruption, it ended up moving to an area of snowy mountains. Its ice shell is as hard as steel.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:AMNESIA,:AQUATAIL,:ATTRACT,:AURORAVEIL,:BIDE,:BLIZZARD,
             :BRICKBREAK,:BULLDOZE,:CHIPAWAY,:CONFIDE,:COUNTER,:COVET,
             :CRUSHCLAW,:CURSE,:DEFENSECURL,:DOUBLETEAM,:EARTHQUAKE,:ENDURE,
             :FACADE,:FLAIL,:FLING,:FOCUSPUNCH,:FROSTBREATH,:FRUSTRATION,
             :FURYCUTTER,:FURYSWIPES,:GYROBALL,:HAIL,:HIDDENPOWER,:HONECLAWS,
             :ICEBALL,:ICEPUNCH,:ICICLECRASH,:ICICLESPEAR,:ICYWIND,:IRONDEFENSE,
             :IRONHEAD,:IRONTAIL,:KNOCKOFF,:LEECHLIFE,:METALCLAW,:NIGHTSLASH,
             :POISONJAB,:POWDERSNOW,:PROTECT,:RAPIDSPIN,:REST,:RETURN,
             :ROCKSLIDE,:ROUND,:SAFEGUARD,:SCRATCH,:SHADOWCLAW,:SLASH,
             :SLEEPTALK,:SNORE,:STEALTHROCK,:SUBSTITUTE,:SUNNYDAY,:SUPERFANG,
             :SWAGGER,:SWIFT,:SWORDSDANCE,:THIEF,:THROATCHOP,:TOXIC,:WORKUP,
             :XSCISSOR,:IRONCARB,:STEELBEAM,:TRIPLEAXEL,:STEELROLLER]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:SANDSLASH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 12                          # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 550                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SNOWCLOAK),0],
         [getID(PBAbilities,:SLUSHRUSH),2]]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [75,100,120,65,25,65] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:ICICLESPEAR],[1,:ICICLESPEAR],[1,:METALBURST],
                     [1,:ICICLECRASH],[1,:SLASH],[1,:DEFENSECURL],
                     [1,:ICEBALL],[1,:METALCLAW]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It runs across snow-covered plains at high speeds. It developed thick, sharp claws to plow through the snow.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:AMNESIA,:AQUATAIL,:ATTRACT,:AURORAVEIL,:BIDE,:BLIZZARD,
             :BRICKBREAK,:BULLDOZE,:CHIPAWAY,:CONFIDE,:COUNTER,:COVET,
             :CRUSHCLAW,:CURSE,:DEFENSECURL,:DOUBLETEAM,:DRILLRUN,:EARTHQUAKE,
             :ENDURE,:FACADE,:FLAIL,:FLING,:FOCUSBLAST,:FOCUSPUNCH,:FROSTBREATH,
             :FRUSTRATION,:FURYCUTTER,:FURYSWIPES,:GIGAIMPACT,:GYROBALL,:HAIL,
             :HIDDENPOWER,:HONECLAWS,:HYPERBEAM,:ICEBALL,:ICEPUNCH,:ICICLECRASH,
             :ICICLESPEAR,:ICYWIND,:IRONDEFENSE,:IRONHEAD,:IRONTAIL,:KNOCKOFF,
             :LEECHLIFE,:METALBURST,:METALCLAW,:NIGHTSLASH,:POISONJAB,
             :POWDERSNOW,:PROTECT,:RAPIDSPIN,:REST,:RETURN,:ROCKSLIDE,:ROUND,
             :SAFEGUARD,:SCRATCH,:SHADOWCLAW,:SLASH,:SLEEPTALK,:SNORE,
             :STEALTHROCK,:SUBSTITUTE,:SUNNYDAY,:SUPERFANG,:SWAGGER,:SWIFT,
             :SWORDSDANCE,:THIEF,:THROATCHOP,:TOXIC,:WORKUP,:XSCISSOR,
             :IRONCARB,:STEELBEAM,:TRIPLEAXEL,:STEELROLLER]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:VULPIX,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SNOWCLOAK),0],
         [getID(PBAbilities,:SNOWWARNING),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:SNOWBALL),
         0] if pokemon.form==1 # Eternal
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[4,:TAILWHIP],[7,:ROAR],
                     [9,:BABYDOLLEYES],[10,:ICESHARD],[12,:CONFUSERAY],
                     [15,:ICYWIND],[18,:PAYBACK],[20,:MIST],
                     [23,:FEINTATTACK],[26,:HEX],[28,:AURORABEAM],
                     [31,:EXTRASENSORY],[34,:SAFEGUARD],[36,:ICEBEAM],
                     [39,:IMPRISON],[42,:BLIZZARD],[44,:GRUDGE],
                     [47,:CAPTIVATE],[50,:SHEERCOLD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("If you carelessly approach it because it's cute, the boss of the pack, Ninetales, will appear and freeze you.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AGILITY,:AQUATAIL,:ATTRACT,:AURORABEAM,:AURORAVEIL,:BABYDOLLEYES,
             :BLIZZARD,:CAPTIVATE,:CELEBRATE,:CHARM,:CONFIDE,:CONFUSERAY,:COVET,
             :DARKPULSE,:DISABLE,:DOUBLETEAM,:ENCORE,:EXTRASENSORY,:FACADE,
             :FEINTATTACK,:FLAIL,:FOULPLAY,:FREEZEDRY,:FROSTBREATH,:FRUSTRATION,
             :GRUDGE,:HAIL,:HEALBELL,:HEX,:HIDDENPOWER,:HOWL,:HYPNOSIS,:ICEBEAM,
             :ICESHARD,:ICYWIND,:IMPRISON,:IRONTAIL,:MIST,:MOONBLAST,:PAINSPLIT,
             :PAYBACK,:POWDERSNOW,:POWERSWAP,:PROTECT,:PSYCHUP,:RAINDANCE,:REST,
             :RETURN,:ROAR,:ROLEPLAY,:ROUND,:SAFEGUARD,:SECRETPOWER,:SHEERCOLD,
             :SLEEPTALK,:SNORE,:SPITE,:SUBSTITUTE,:SWAGGER,:TAILSLAP,:TAILWHIP,
             :TOXIC,:ZENHEADBUTT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:NINETALES,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SNOWCLOAK),0],
         [getID(PBAbilities,:SNOWWARNING),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:SNOWBALL),
         0] if pokemon.form==1 # Eternal
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [73,67,75,109,81,100] # Sandy Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [0,0,0,2,0,0] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:DAZZLINGGLEAM],[1,:DAZZLINGGLEAM],[1,:IMPRISON],
                     [1,:NASTYPLOT],[1,:ICEBEAM],[1,:ICESHARD],
                     [1,:CONFUSERAY],[1,:SAFEGUARD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The reason it guides people all the way down to the mountain's base is that it wants them to hurry up and leave.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AGILITY,:AQUATAIL,:ATTRACT,:AURORABEAM,:AURORAVEIL,:BABYDOLLEYES,
             :BLIZZARD,:CALMMIND,:CAPTIVATE,:CELEBRATE,:CHARM,:CONFIDE,
             :CONFUSERAY,:COVET,:DARKPULSE,:DAZZLINGGLEAM,:DISABLE,:DOUBLETEAM,
             :DREAMEATER,:ENCORE,:EXTRASENSORY,:FACADE,:FEINTATTACK,:FLAIL,
             :FOULPLAY,:FREEZEDRY,:FROSTBREATH,:FRUSTRATION,:GIGAIMPACT,:GRUDGE,
             :HAIL,:HEALBELL,:HEX,:HIDDENPOWER,:HOWL,:HYPERBEAM,:HYPNOSIS,
             :ICEBEAM,:ICESHARD,:ICYWIND,:IMPRISON,:IRONTAIL,:LASERFOCUS,:MIST,
             :MOONBLAST,:NASTYPLOT,:PAINSPLIT,:PAYBACK,:POWDERSNOW,:POWERSWAP,
             :PROTECT,:PSYCHUP,:PSYSHOCK,:RAINDANCE,:REST,:RETURN,:ROAR,
             :ROLEPLAY,:ROUND,:SAFEGUARD,:SECRETPOWER,:SHEERCOLD,:SLEEPTALK,
             :SNORE,:SPITE,:SUBSTITUTE,:SWAGGER,:TAILSLAP,:TAILWHIP,:TOXIC,
             :WONDERROOM,:ZENHEADBUTT,:TRIPLEAXEL]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:GROWLITHE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 8                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 227                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:INTIMIDATE),0],
         [getID(PBAbilities,:FLASHFIRE),1],
         [getID(PBAbilities,:ROCKHEAD),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,75,45,55,65,50] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:BITE],[1,:ROAR],[6,:EMBER],[8,:LEER],[10,:ODORSLEUTH],[12,:HELPINGHAND],
                     [17,:FLAMEWHEEL],[19,:ROCKSLIDE],[21,:FIREFANG],
                     [23,:TAKEDOWN],[28,:FLAMEBURST],[30,:AGILITY],
                     [32,:RETALIATE],[34,:FLAMETHROWER],[39,:CRUNCH],
                     [41,:HEATWAVE],[43,:OUTRAGE],[45,:FLAREBLITZ]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Scout")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("They patrol their territory in pairs. I believe the igneous rock components in the fur of this species are the result of volcanic activity in its habitat.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:ARCANINE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 19                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 1550                         # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:INTIMIDATE),0],
         [getID(PBAbilities,:FLASHFIRE),1],
         [getID(PBAbilities,:ROCKHEAD),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [95,115,80,90,95,80] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:RAGINGFURY],[1,:THUNDERFANG],[1,:BITE],[1,:ROAR],
                     [1,:ODORSLEUTH],[1,:FIREFANG],[34,:ROCKSLIDE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Legendary")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Snaps at its foes with fangs cloaked in blazing flame. Despite its bulk, it deftly feints every which way, leading opponents on a deceptively merry chase as it all but dances around them.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


MultipleForms.register(:DIGLETT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 10                           # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SANDVEIL),0],
         [getID(PBAbilities,:TANGLINGHAIR),1],
         [getID(PBAbilities,:SANDRUSH),2]]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [10,55,30,90,35,45] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SANDATTACK],[1,:METALCLAW],[4,:GROWL],
                     [7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
                     [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
                     [28,:EARTHPOWER],[31,:DIG],[35,:IRONHEAD],
                     [39,:EARTHQUAKE],[43,:FISSURE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:ANCIENTPOWER,:ASTONISH,:ATTRACT,:BEATUP,:BULLDOZE,
             :CONFIDE,:DIG,:DOUBLETEAM,:EARTHPOWER,:EARTHQUAKE,:ECHOEDVOICE,
             :ENDURE,:FACADE,:FEINTATTACK,:FINALGAMBIT,:FISSURE,:FLASHCANNON,
             :FRUSTRATION,:GROWL,:HEADBUTT,:HIDDENPOWER,:IRONDEFENSE,:IRONHEAD,
             :MAGNITUDE,:MEMENTO,:METALCLAW,:METALSOUND,:MUDBOMB,:MUDSLAP,
             :PROTECT,:PURSUIT,:REST,:RETURN,:REVERSAL,:ROCKSLIDE,:ROCKTOMB,
             :ROUND,:SANDATTACK,:SANDSTORM,:SHADOWCLAW,:SLEEPTALK,:SLUDGEBOMB,
             :SNORE,:STEALTHROCK,:STOMPINGTANTRUM,:SUBSTITUTE,:SUCKERPUNCH,
             :SUNNYDAY,:SWAGGER,:THIEF,:THRASH,:TOXIC,:WORKUP,:IRONCARB,
             :STEELBEAM,:SCORCHINGSANDS]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Although it's powerful enough to dig right through volcanic rock, it doesn't allow itself to be seen very often.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:DUGTRIO,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 666                           # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SANDVEIL),0],
         [getID(PBAbilities,:TANGLINGHAIR),1],
         [getID(PBAbilities,:SANDRUSH),2]]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [35,100,60,110,50,70] # Sandy Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [0,2,0,0,0,0] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:SANDTOMB],[1,:SANDTOMB],[1,:ROTOTILLER],
                     [1,:NIGHTSLASH],[1,:TRIATTACK],[1,:SANDATTACK],
                     [1,:METALCLAW],[1,:GROWL],[4,:GROWL],
                     [7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
                     [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
                     [30,:EARTHPOWER],[35,:DIG],[41,:IRONHEAD],
                     [47,:EARTHQUAKE],[53,:FISSURE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its metallic whiskers are heavy, so it's not very fast, but it has the power to dig through bedrock.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:ANCIENTPOWER,:ASTONISH,:ATTRACT,:BEATUP,:BULLDOZE,
             :CONFIDE,:DIG,:DOUBLETEAM,:EARTHPOWER,:EARTHQUAKE,:ECHOEDVOICE,
             :ENDURE,:FACADE,:FEINTATTACK,:FINALGAMBIT,:FISSURE,:FLASHCANNON,
             :FRUSTRATION,:GIGAIMPACT,:GROWL,:HEADBUTT,:HIDDENPOWER,:HYPERBEAM,
             :IRONDEFENSE,:IRONHEAD,:MAGNITUDE,:MEMENTO,:METALCLAW,:METALSOUND,
             :MUDBOMB,:MUDSLAP,:NIGHTSLASH,:PROTECT,:PURSUIT,:REST,:RETURN,
             :REVERSAL,:ROCKSLIDE,:ROCKTOMB,:ROTOTILLER,:ROUND,:SANDATTACK,
             :SANDSTORM,:SANDTOMB,:SHADOWCLAW,:SLEEPTALK,:SLUDGEBOMB,
             :SLUDGEWAVE,:SNORE,:STEALTHROCK,:STOMPINGTANTRUM,:STONEEDGE,
             :SUBSTITUTE,:SUCKERPUNCH,:SUNNYDAY,:SWAGGER,:THIEF,:THRASH,:TOXIC,
             :TRIATTACK,:WORKUP,:IRONCARB,:STEELBEAM,:SCORCHINGSANDS]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:MEOWTH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   when 2; next getID(PBTypes,:STEEL)  # Galar
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   when 2; next getID(PBTypes,:STEEL)  # Galar
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 75                           # Galar
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
   next 5 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PICKUP),0],
         [getID(PBAbilities,:TECHNICIAN),1],
         [getID(PBAbilities,:RATTLED),2]] if pokemon.form==1
   next [[getID(PBAbilities,:PICKUP),0],
         [getID(PBAbilities,:TOUGHCLAWS),1],
         [getID(PBAbilities,:UNNERVE),2]] if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [40,35,35,90,50,40] # Sandy Cloak
   when 2; next [60,65,55,40,40,40] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SCRATCH],[1,:GROWL],[6,:BITE],[9,:FAKEOUT],
                     [14,:FURYSWIPES],[17,:SCREECH],[22,:FEINTATTACK],
                     [25,:TAUNT],[30,:PAYDAY],[33,:SLASH],[38,:NASTYPLOT],
                     [41,:ASSURANCE],[46,:CAPTIVATE],[49,:NIGHTSLASH],
                     [50,:FEINT],[55,:DARKPULSE]]
   when 2; movelist=[[1,:FAKEOUT],[1,:GROWL],[4,:HONECLAWS],[8,:SCRATCH],
                     [12,:PAYDAY],[16,:METALCLAW],[20,:TAUNT],[24,:SWAGGER],
                     [29,:FURYSWIPES],[32,:SCREECH],[36,:SLASH],[40,:METALSOUND],
                     [44,:THRASH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It's impulsive, selfish, and fickle. It's very popular with some Trainers who like giving it the attention it needs.") if pokemon.form==1 # Eternal
   next _INTL("Living with a savage, seafaring people has toughened this Pokémon's body so much that parts of it have turned to iron.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:AMNESIA,:ASSIST,:ASSURANCE,:ATTRACT,:BITE,:CAPTIVATE,
             :CHARM,:CONFIDE,:COVET,:DARKPULSE,:DOUBLETEAM,:DREAMEATER,
             :ECHOEDVOICE,:EMBARGO,:FACADE,:FAKEOUT,:FEINT,:FEINTATTACK,:FLAIL,
             :FLATTER,:FOULPLAY,:FRUSTRATION,:FURYSWIPES,:GROWL,:GUNKSHOT,
             :HIDDENPOWER,:HYPERVOICE,:HYPNOSIS,:ICYWIND,:IRONTAIL,:KNOCKOFF,
             :LASTRESORT,:NASTYPLOT,:NIGHTSLASH,:PARTINGSHOT,:PAYBACK,:PAYDAY,
             :PROTECT,:PSYCHUP,:PUNISHMENT,:QUASH,:RAINDANCE,:REST,:RETURN,
             :ROUND,:SCRATCH,:SCREECH,:SEEDBOMB,:SHADOWBALL,:SHADOWCLAW,
             :SHOCKWAVE,:SLASH,:SLEEPTALK,:SNATCH,:SNORE,:SPITE,:SUBSTITUTE,
             :SUNNYDAY,:SWAGGER,:TAUNT,:THIEF,:THROATCHOP,:THUNDER,:THUNDERBOLT,
             :TORMENT,:TOXIC,:UPROAR,:UTURN,:WATERPULSE,:WORKUP,
             :LASHOUT] if pokemon.form==1
   movelist=[:PAYDAY,:DIG,:SCREECH,:REST,:THIEF,:SNORE,:PROTECT,:ATTRACT,
             :RAINDANCE,:SUNNYDAY,:FACADE,:UTURN,:PAYBACK,:ASSURANCE,:SHADOWCLAW,
             :ROUND,:RETALIATE,:SWORDSDANCE,:BODYSLAM,:THUNDERBOLT,:THUNDER,
             :AMNESIA,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:IRONTAIL,:CRUNCH,
             :SHADOWBALL,:UPROAR,:TAUNT,:HYPERVOICE,:IRONDEFENSE,:GYROBALL,
             :DARKPULSE,:SEEDBOMB,:NASTYPLOT,:GUNKSHOT,:FOULPLAY,:WORKUP,
             :PLAYROUGH,:THROATCHOP,:FAKEOUT,:GROWL,:HONECLAWS,:SCRATCH,
             :METALCLAW,:SWAGGER,:FURYSWIPES,:SLASH,:METALSOUND,:THRASH,
             :STEELBEAM,:LASHOUT] if pokemon.form==2
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next [1,2][rand(2)] if rand(65536)<$REGIONALCOMBO &&
                        !(env==PBEnvironment::Alola || 
                          env==PBEnvironment::Galar)
   next 0 unless env==PBEnvironment::Alola || env==PBEnvironment::Galar
   next 1 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:PERSIAN,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:FURCOAT),0],
         [getID(PBAbilities,:TECHNICIAN),1],
         [getID(PBAbilities,:RATTLED),2]]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [65,60,60,115,75,65] # Sandy Cloak
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 11                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 330                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:SWIFT],[1,:SWIFT],[1,:QUASH],[1,:PLAYROUGH],
                     [1,:SWITCHEROO],[1,:SCRATCH],[1,:GROWL],[1,:BITE],
                     [1,:FAKEOUT],[6,:BITE],[9,:FAKEOUT],[14,:FURYSWIPES],
                     [17,:SCREECH],[22,:FEINTATTACK],[25,:TAUNT],
                     [32,:POWERGEM],[37,:SLASH],[44,:NASTYPLOT],[49,:ASSURANCE],
                     [56,:CAPTIVATE],[61,:NIGHTSLASH],[65,:FEINT],[69,:DARKPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("In contrast to its lovely face, it's so brutal that it tortures its weakened prey rather than finishing them off.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:AMNESIA,:ASSIST,:ASSURANCE,:ATTRACT,:BITE,:CAPTIVATE,
             :CHARM,:CONFIDE,:COVET,:DARKPULSE,:DOUBLETEAM,:DREAMEATER,
             :ECHOEDVOICE,:EMBARGO,:FACADE,:FAKEOUT,:FEINT,:FEINTATTACK,:FLAIL,
             :FLATTER,:FOULPLAY,:FRUSTRATION,:FURYSWIPES,:GIGAIMPACT,:GROWL,
             :GUNKSHOT,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:HYPNOSIS,:ICYWIND,
             :IRONTAIL,:KNOCKOFF,:LASTRESORT,:NASTYPLOT,:NIGHTSLASH,
             :PARTINGSHOT,:PAYBACK,:PAYDAY,:PLAYROUGH,:POWERGEM,:PROTECT,
             :PSYCHUP,:PUNISHMENT,:QUASH,:RAINDANCE,:REST,:RETURN,:ROAR,:ROUND,
             :SCRATCH,:SCREECH,:SEEDBOMB,:SHADOWBALL,:SHADOWCLAW,:SHOCKWAVE,
             :SLASH,:SLEEPTALK,:SNARL,:SNATCH,:SNORE,:SPITE,:SUBSTITUTE,
             :SUNNYDAY,:SWAGGER,:SWIFT,:SWITCHEROO,:TAUNT,:THIEF,:THROATCHOP,
             :THUNDER,:THUNDERBOLT,:TORMENT,:TOXIC,:UPROAR,:UTURN,:WATERPULSE,
             :WORKUP,:BURNINGJEALOUSY,:LASHOUT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:GEODUDE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:MAGNETPULL),0],
         [getID(PBAbilities,:STURDY),1],
         [getID(PBAbilities,:GALVANIZE),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:CELLBATTERY),
         0] if pokemon.form==1 # Eternal
   next
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 203                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[4,:CHARGE],
                     [6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
                     [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
                     [24,:SELFDESTRUCT],[28,:STEALTHROCK],[30,:ROCKBLAST],
                     [34,:DISCHARGE],[36,:EXPLOSION],[40,:DOUBLEEDGE],
                     [42,:STONEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("If you mistake it for a rock and step on it, it will headbutt you in anger. In addition to the pain, it will also zap you with a shock.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ATTRACT,:AUTOTOMIZE,:BLOCK,:BRICKBREAK,:BRUTALSWING,:BULLDOZE,
             :CHARGE,:CHARGEBEAM,:CONFIDE,:COUNTER,:CURSE,:DEFENSECURL,
             :DISCHARGE,:DOUBLEEDGE,:DOUBLETEAM,:EARTHPOWER,:EARTHQUAKE,
             :ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,:FIREBLAST,:FIREPUNCH,
             :FLAIL,:FLAMETHROWER,:FLING,:FOCUSPUNCH,:FRUSTRATION,:GYROBALL,
             :HIDDENPOWER,:IRONDEFENSE,:MAGNETRISE,:NATUREPOWER,:PROTECT,:REST,
             :RETURN,:ROCKBLAST,:ROCKCLIMB,:ROCKPOLISH,:ROCKSLIDE,:ROCKTHROW,
             :ROCKTOMB,:ROLLOUT,:ROUND,:SANDSTORM,:SCREECH,:SELFDESTRUCT,
             :SLEEPTALK,:SMACKDOWN,:SNORE,:SPARK,:STEALTHROCK,:STONEEDGE,
             :SUBSTITUTE,:SUNNYDAY,:SUPERPOWER,:SWAGGER,:TACKLE,:THUNDER,
             :THUNDERBOLT,:THUNDERPUNCH,:TOXIC,:VOLTSWITCH,:WIDEGUARD]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:GRAVELER,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:MAGNETPULL),0],
         [getID(PBAbilities,:STURDY),1],
         [getID(PBAbilities,:GALVANIZE),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:CELLBATTERY),
         0] if pokemon.form==1 # Eternal
   next
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 1100                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],[1,:ROCKPOLISH],
                     [4,:CHARGE],[6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
                     [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
                     [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
                     [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
                     [54,:STONEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It climbs up cliffs as it heads toward the peak of a mountain. As soon as it reaches the summit, it rolls back down the way it came.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ALLYSWITCH,:ATTRACT,:AUTOTOMIZE,:BLOCK,:BRICKBREAK,:BRUTALSWING,
             :BULLDOZE,:CHARGE,:CHARGEBEAM,:CONFIDE,:COUNTER,:CURSE,
             :DEFENSECURL,:DISCHARGE,:DOUBLEEDGE,:DOUBLETEAM,:EARTHPOWER,
             :EARTHQUAKE,:ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,:FIREBLAST,
             :FIREPUNCH,:FLAIL,:FLAMETHROWER,:FLING,:FOCUSPUNCH,:FRUSTRATION,
             :GYROBALL,:HIDDENPOWER,:IRONDEFENSE,:MAGNETRISE,:NATUREPOWER,
             :PROTECT,:REST,:RETURN,:ROCKBLAST,:ROCKCLIMB,:ROCKPOLISH,
             :ROCKSLIDE,:ROCKTHROW,:ROCKTOMB,:ROLLOUT,:ROUND,:SANDSTORM,
             :SCREECH,:SELFDESTRUCT,:SHOCKWAVE,:SLEEPTALK,:SMACKDOWN,:SNORE,
             :SPARK,:STEALTHROCK,:STOMPINGTANTRUM,:STONEEDGE,:SUBSTITUTE,
             :SUNNYDAY,:SUPERPOWER,:SWAGGER,:TACKLE,:THUNDER,:THUNDERBOLT,
             :THUNDERPUNCH,:TOXIC,:VOLTSWITCH,:WIDEGUARD]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:GOLEM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:MAGNETPULL),0],
         [getID(PBAbilities,:STURDY),1],
         [getID(PBAbilities,:GALVANIZE),2]]
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:CELLBATTERY),
         0] if pokemon.form==1 # Eternal
   next
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 17                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 3160                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:HEAVYSLAM],[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],
                     [1,:ROCKPOLISH],[4,:CHARGE],[6,:ROCKPOLISH],[10,:STEAMROLLER],
                     [12,:SPARK],[16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
                     [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
                     [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
                     [54,:STONEEDGE],[60,:HEAVYSLAM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It's grumpy and stubborn. If you upset it, it discharges electricity from the surface of its body and growls with a voice like thunder.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ALLYSWITCH,:ATTRACT,:AUTOTOMIZE,:BLOCK,:BRICKBREAK,:BRUTALSWING,
             :BULLDOZE,:CHARGE,:CHARGEBEAM,:CONFIDE,:COUNTER,:CURSE,
             :DEFENSECURL,:DISCHARGE,:DOUBLEEDGE,:DOUBLETEAM,:EARTHPOWER,
             :EARTHQUAKE,:ECHOEDVOICE,:ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,
             :FIREBLAST,:FIREPUNCH,:FLAIL,:FLAMETHROWER,:FLING,:FOCUSBLAST,
             :FOCUSPUNCH,:FRUSTRATION,:GIGAIMPACT,:GYROBALL,:HEAVYSLAM,
             :HIDDENPOWER,:HYPERBEAM,:IRONDEFENSE,:IRONHEAD,:MAGNETRISE,
             :NATUREPOWER,:PROTECT,:REST,:RETURN,:ROAR,:ROCKBLAST,:ROCKCLIMB,
             :ROCKPOLISH,:ROCKSLIDE,:ROCKTHROW,:ROCKTOMB,:ROLLOUT,:ROUND,
             :SANDSTORM,:SCREECH,:SELFDESTRUCT,:SHOCKWAVE,:SLEEPTALK,:SMACKDOWN,
             :SNORE,:SPARK,:STEALTHROCK,:STEAMROLLER,:STOMPINGTANTRUM,
             :STONEEDGE,:SUBSTITUTE,:SUNNYDAY,:SUPERPOWER,:SWAGGER,:TACKLE,
             :THUNDER,:THUNDERBOLT,:THUNDERPUNCH,:TOXIC,:VOLTSWITCH,
             :WIDEGUARD,:WILDCHARGE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:PONYTA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
   next 8 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0  
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:WATERBUBBLE),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
   next [[getID(PBAbilities,:RUNAWAY),0],
         [getID(PBAbilities,:PASTELVEIL),1],
         [getID(PBAbilities,:ANTICIPATION),2]] if pokemon.form==2
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   next _INTL("Unique Horn")
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 8                           # Alola
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 240                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:WATERGUN],
                     [10,:LIGHTBALL],[15,:WILLOWISP],[20,:MOONBLAST],
                     [25,:WATERBUBBLE],[30,:REVELATIONDANCE],[35,:FLAMECHARGE],
                     [40,:DRAGONBREATH],[45,:VOLCANICTERRAIN],[45,:HERBALSMOKE]]
   when 2; movelist=[[1,:TACKLE],[1,:GROWL],[5,:TAILWHIP],[10,:CONFUSION],
                     [15,:FAIRYWIND],[20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
                     [35,:HEALPULSE],[41,:TAKEDOWN],[45,:DAZZLINGGLEAM],
                     [50,:PSYCHIC],[55,:HEALINGWISH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its unique horn is made of watery bubbles that don't burn anyone. This Pokémon may also be capable of healing burns from itself or others.") if pokemon.form==1 # Eternal
   next _INTL("Its small horn hides a healing power. With a few rubs from this Pokémon's horn, any slight wound you have will be healed.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:REST,:SNORE,:PROTECT,:CHARM,:ATTRACT,:FACADE,:SWIFT,:IMPRISON,
             :BOUNCE,:ROUND,:MYSTICALFIRE,:BODYSLAM,:LOWKICK,:PSYCHIC,:AGILITY,
             :SUBSTITUTE,:ENDURE,:SLEEPTALK,:IRONTAIL,:FUTURESIGHT,:CALMMIND,
             :ZENHEADBUTT,:STOREDPOWER,:ALLYSWITCH,:WILDCHARGE,:PLAYROUGH,
             :DAZZLINGGLEAM,:HIGHHORSEPOWER,:TACKLE,:GROWL,:TAILWHIP,:CONFUSION,
             :FAIRYWIND,:PSYBEAM,:STOMP,:HEALPULSE,:TAKEDOWN,:PSYCHIC,
             :HEALINGWISH,:EXPANDINGFORCE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},

"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next [1,2][rand(2)] if rand(65536)<$REGIONALCOMBO &&
                        !(env==PBEnvironment::Alola || 
                          env==PBEnvironment::Galar)
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Mysterical
   end
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:RAPIDASH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER) # (Was Water) 
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola (Was Psychic)
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  
   when 2; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
   next 8 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                  
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:FIERYSPIRIT),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
   next [[getID(PBAbilities,:RUNAWAY),0],
         [getID(PBAbilities,:PASTELVEIL),1],
         [getID(PBAbilities,:ANTICIPATION),2]] if pokemon.form==2
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Flame Horn") if pokemon.form==1
   next _INTL("Unique Horn") if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 800                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:WATERGUN],
                     [10,:LIGHTBALL],[15,:WILLOWISP],[20,:MOONBLAST],
                     [25,:WATERBUBBLE],[30,:REVELATIONDANCE],[35,:FLAMECHARGE],
                     [40,:DRAGONBREATH],[45,:VOLCANICTERRAIN],[45,:HERBALSMOKE]]
   when 2; movelist=[[0,:PSYCHOCUT],[1,:PSYCHOCUT],[1,:MEGAHORN],[1,:TACKLE],
                     [1,:GROWL],[1,:TAILWHIP],[1,:CONFUSION],
                     [15,:FAIRYWIND],[20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
                     [35,:HEALPULSE],[43,:TAKEDOWN],[49,:DAZZLINGGLEAM],
                     [56,:PSYCHIC],[63,:HEALINGWISH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After surviving hundreds of water, it evolves into this form. Its flaring boost gives him a lot power than in the water..") if pokemon.form==1 # Eternal
   next _INTL("Little can stand up to its psycho cut. Unleashed from this Pokémon's horn, the move will punch a hole right through a thick metal sheet.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:PAYDAY,:HYPERBEAM,:GIGAIMPACT,:REST,:SNORE,:PROTECT,:CHARM,
             :ATTRACT,:FACADE,:SWIFT,:IMPRISON,:BOUNCE,:PSYCHOCUT,:TRICKROOM,
             :WONDERROOM,:MAGICROOM,:ROUND,:MISTYTERRAIN,:PSYCHICTERRAIN,
             :MYSTICALFIRE,:SMARTSTRIKE,:SWORDSDANCE,:BODYSLAM,:LOWKICK,:PSYCHIC,
             :AGILITY,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:MEGAHORN,:BATONPASS,
             :IRONTAIL,:FUTURESIGHT,:CALMMIND,:ZENHEADBUTT,:STOREDPOWER,
             :ALLYSWITCH,:WILDCHARGE,:DRILLRUN,:PLAYROUGH,:DAZZLINGGLEAM,
             :HIGHHORSEPOWER,:THROATCHOP,:PSYCHOCUT,:TACKLE,:QUICKATTACK,:GROWL,
             :TAILWHIP,:CONFUSION,:FAIRYWIND,:PSYBEAM,:STOMP,:HEALPULSE,:TAKEDOWN,
             :PSYCHIC,:HEALINGWISH,:EXPANDINGFORCE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},

"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next [1,2][rand(2)] if rand(65536)<$REGIONALCOMBO &&
                        !(env==PBEnvironment::Alola || 
                          env==PBEnvironment::Galar)
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Mysterical
   end
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


MultipleForms.register(:SLOWPOKE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola
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
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0  
   next [[getID(PBAbilities,:GLUTTONY),0],
         [getID(PBAbilities,:OWNTEMPO),1],
         [getID(PBAbilities,:REGENERATOR),2]] if pokemon.form==2
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:CURSE],[1,:YAWN],[1,:TACKLE],[5,:GROWL],[9,:ACID],
                     [14,:CONFUSION],[19,:DISABLE],[23,:HEADBUTT],
                     [28,:WATERPULSE],[32,:ZENHEADBUTT],[36,:SLACKOFF],
                     [41,:AMNESIA],[45,:PSYCHIC],[49,:RAINDANCE],
                     [54,:PSYCHUP],[58,:HEALPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Although this Pokémon is normally zoned out, its expression abruptly sharpens on occasion. The cause for this seems to lie in Slowpoke's diet.") if pokemon.form==2 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

# Slowbro is Handled Elsewhere

MultipleForms.register(:FARFETCHD,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FIGHTING)  # Alola (Was Steel)
   else;   next 
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==00                   
   next [[getID(PBAbilities,:STEADFAST),0],
#         [getID(PBAbilities,:STEADFAST),1],
         [getID(PBAbilities,:SCRAPPY),2]] if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [52,95,55,60,58,62] # Sandy 
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 420                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:PECK],[1,:SANDATTACK],[5,:LEER],[10,:FURYCUTTER],
                     [15,:ROCKSMASH],[20,:BRUTALSWING],[25,:DETECT],
                     [30,:KNOCKOFF],[35,:DEFOG],[40,:BRICKBREAK],
                     [45,:SWORDSDANCE],[50,:SLAM],[55,:LEAFBLADE],
                     [60,:FINALGAMBIT],[65,:BRAVEBIRD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The Farfetch'd of the Galar region are brave warriors, and they wield thick, tough leeks in battle.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:SOLARBLADE,:REST,:SNORE,:PROTECT,:STEELWING,:ATTRACT,:SUNNYDAY,
             :FACADE,:HELPINGHAND,:REVENGE,:BRICKBREAK,:ASSURANCE,:ROUND,
             :RETALIATE,:BRUTALSWING,:SWORDSDANCE,:BODYSLAM,:FOCUSENERGY,
             :SUBSTITUTE,:ENDURE,:SLEEPTALK,:SUPERPOWER,:LEAFBLADE,:CLOSECOMBAT,
             :POISONJAB,:BRAVEBIRD,:WORKUP,:THROATCHOP,:PECK,:SANDATTACK,:LEER,
             :FURYCUTTER,:ROCKSMASH,:DETECT,:KNOCKOFF,:DEFOG,:SLAM,:FINALGAMBIT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},

"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})



MultipleForms.register(:GRIMER,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:POISONTOUCH),0],
         [getID(PBAbilities,:GLUTTONY),1],
         [getID(PBAbilities,:POWEROFALCHEMY),2]]
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 7                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 420                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POUND],[1,:POISONGAS],[4,:HARDEN],[7,:BITE],[12,:DISABLE],
                     [15,:ACIDSPRAY],[18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],
                     [29,:KNOCKOFF],[32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],
                     [43,:ACIDARMOR],[46,:BELCH],[48,:MEMENTO]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It was born from sludge on the ocean floor. In a sterile environment, the germs within its body can't multiply, and it dies.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ACIDARMOR,:ACIDSPRAY,:ASSURANCE,:ATTRACT,:BELCH,:BITE,
             :BRUTALSWING,:CLEARSMOG,:CONFIDE,:CRUNCH,:CURSE,:DISABLE,
             :DOUBLETEAM,:EMBARGO,:EXPLOSION,:FACADE,:FIREBLAST,:FIREPUNCH,
             :FLAMETHROWER,:FLING,:FRUSTRATION,:GASTROACID,:GIGADRAIN,:GUNKSHOT,
             :HARDEN,:HIDDENPOWER,:ICEPUNCH,:IMPRISON,:INFESTATION,:KNOCKOFF,
             :MEANLOOK,:MEMENTO,:MINIMIZE,:PAINSPLIT,:PAYBACK,:POISONFANG,
             :POISONGAS,:POISONJAB,:POUND,:POWERUPPUNCH,:PROTECT,:PURSUIT,
             :QUASH,:RAINDANCE,:REST,:RETURN,:ROCKPOLISH,:ROCKSLIDE,:ROCKTOMB,
             :ROUND,:SCARYFACE,:SCREECH,:SHADOWBALL,:SHADOWSNEAK,:SHOCKWAVE,
             :SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNARL,:SNORE,:SPITE,:SPITUP,
             :STOCKPILE,:STONEEDGE,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:SWALLOW,
             :TAUNT,:THIEF,:THUNDERPUNCH,:TORMENT,:TOXIC,:VENOSHOCK]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:MUK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:POISONTOUCH),0],
         [getID(PBAbilities,:GLUTTONY),1],
         [getID(PBAbilities,:POWEROFALCHEMY),2]]
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 10                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 520                          # Alola
   end
},
"wildHoldItems"=>proc{|pokemon|
   next [0,
         getID(PBItems,:BLACKSLUDGE),
         0] if pokemon.form==1 # Eternal
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:VENOMDRENCH],[1,:VENOMDRENCH],[1,:POUND],[1,:POISONGAS],
                     [1,:HARDEN],[1,:BITE],[4,:HARDEN],[7,:BITE],[12,:DISABLE],
                     [15,:ACIDSPRAY],[18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],
                     [29,:KNOCKOFF],[32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],
                     [46,:ACIDARMOR],[52,:BELCH],[57,:MEMENTO]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Their food sources have decreased, and their numbers have declined sharply. Sludge ponds are being built to prevent their extinction.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ACIDARMOR,:ACIDSPRAY,:ASSURANCE,:ATTRACT,:BELCH,:BITE,:BLOCK,
             :BRICKBREAK,:BRUTALSWING,:CLEARSMOG,:CONFIDE,:CRUNCH,:CURSE,
             :DARKPULSE,:DISABLE,:DOUBLETEAM,:EMBARGO,:EXPLOSION,:FACADE,
             :FIREBLAST,:FIREPUNCH,:FLAMETHROWER,:FLING,:FOCUSBLAST,:FOCUSPUNCH,
             :FRUSTRATION,:GASTROACID,:GIGADRAIN,:GIGAIMPACT,:GUNKSHOT,:HARDEN,
             :HIDDENPOWER,:HYPERBEAM,:ICEPUNCH,:IMPRISON,:INFESTATION,:KNOCKOFF,
             :MEANLOOK,:MEMENTO,:MINIMIZE,:PAINSPLIT,:PAYBACK,:POISONFANG,
             :POISONGAS,:POISONJAB,:POUND,:POWERUPPUNCH,:PROTECT,:PURSUIT,
             :QUASH,:RAINDANCE,:RECYCLE,:REST,:RETURN,:ROCKPOLISH,:ROCKSLIDE,
             :ROCKTOMB,:ROUND,:SCARYFACE,:SCREECH,:SHADOWBALL,:SHADOWSNEAK,
             :SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNARL,:SNORE,:SPITE,
             :SPITUP,:STOCKPILE,:STONEEDGE,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,
             :SWALLOW,:TAUNT,:THIEF,:THUNDERPUNCH,:TORMENT,:TOXIC,:VENOMDRENCH,
             :VENOSHOCK]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:VOLTORB,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 130                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SOUNDPROOF),0],
         [getID(PBAbilities,:STATIC),1],
         [getID(PBAbilities,:AFTERMATH),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [40,30,50,100,55,55] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:CHARGE],[1,:TACKLE],[4,:SONICBOOM],[6,:EERIEIMPULSE],
                     [9,:SPARK],[11,:ROLLOUT],[13,:SCREECH],[16,:CHARGEBEAM],
                     [20,:SWIFT],[22,:ENERGYBALL],[26,:SELFDESTRUCT],
                     [29,:LIGHTSCREEN],[34,:MAGNETRISE],[37,:DISCHARGE],
                     [41,:EXPLOSION],[46,:GYROBALL],[48,:MIRRORCOAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Sphere")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("An enigmatic Pokémon that happens to bear a resemblance to a Poké Ball. When excited, it discharges the electric current it has stored in its belly, then lets out a great, uproarious laugh.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:ELECTRODE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 12                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 666                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SOUNDPROOF),0],
         [getID(PBAbilities,:STATIC),1],
         [getID(PBAbilities,:AFTERMATH),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,50,70,150,80,80] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:CHLOROBLAST],[1,:MAGNETICFLUX],[1,:CHARGE],[1,:TACKLE],
                     [1,:SONICBOOM],[4,:SONICBOOM],[6,:EERIEIMPULSE],
                     [9,:SPARK],[11,:ROLLOUT],[13,:SCREECH],[16,:CHARGEBEAM],
                     [20,:SWIFT],[22,:ENERGYBALL],[26,:SELFDESTRUCT],
                     [29,:LIGHTSCREEN],[36,:MAGNETRISE],[41,:DISCHARGE],
                     [47,:EXPLOSION],[54,:GYROBALL],[58,:MIRRORCOAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Sphere")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("An enigmatic Pokémon that happens to bear a resemblance to a Poké Ball. When excited, it discharges the electric current it has stored in its belly, then lets out a great, uproarious laugh.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


MultipleForms.register(:EXEGGCUTE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DRAGON)  # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:FRISK),0],
         [getID(PBAbilities,:HARVEST),2]]
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 6                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 30                          # Alola
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,50,80,40,70,45] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:BARRAGE],[1,:UPROAR],[1,:HYPNOSIS],[7,:DRAGONPULSE],
                     [11,:LEECHSEED],[17,:BULLETSEED],[19,:STUNSPORE],
                     [21,:POISONPOWDER],[23,:SLEEPPOWDER],[27,:CONFUSION],
                     [33,:WORRYSEED],[37,:DRAGONDANCE],[43,:SOLARBEAM],
                     [47,:EXTRASENSORY],[50,:BESTOW]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})


MultipleForms.register(:EXEGGUTOR,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DRAGON)  # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:FRISK),0],
         [getID(PBAbilities,:HARVEST),2]]
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 109                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 4156                          # Alola
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [95,105,85,45,125,75] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:DRAGONHAMMER],[1,:DRAGONHAMMER],[1,:SEEDBOMB],
                     [1,:BARRAGE],[1,:HYPNOSIS],[1,:CONFUSION],[17,:PSYSHOCK],
                     [27,:EGGBOMB],[37,:WOODHAMMER],[47,:LEAFSTORM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Exeggutor is the pride of the Alolan people. Its image is carved into historical buildings and murals.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:ANCIENTPOWER,:ATTRACT,:BARRAGE,:BESTOW,:BIDE,:BLOCK,:BRICKBREAK,
             :BRUTALSWING,:BULLDOZE,:BULLETSEED,:CAPTIVATE,:CELEBRATE,:CONFIDE,
             :CONFUSION,:CURSE,:DOUBLEEDGE,:DOUBLETEAM,:DRACOMETEOR,
             :DRAGONHAMMER,:DRAGONPULSE,:DRAGONTAIL,:DREAMEATER,:EARTHQUAKE,
             :EGGBOMB,:ENDURE,:ENERGYBALL,:EXPLOSION,:EXTRASENSORY,:FACADE,
             :FLAMETHROWER,:FLASH,:FRUSTRATION,:GIGADRAIN,:GIGAIMPACT,
             :GRASSKNOT,:GRASSYTERRAIN,:GRAVITY,:HIDDENPOWER,:HYPERBEAM,
             :HYPNOSIS,:INFESTATION,:INGRAIN,:IRONHEAD,:IRONTAIL,:KNOCKOFF,
             :LEAFSTORM,:LEECHSEED,:LIGHTSCREEN,:LOWKICK,:LUCKYCHANT,:MIMIC,
             :MOONLIGHT,:NATURALGIFT,:NATUREPOWER,:NIGHTMARE,:OUTRAGE,
             :POISONPOWDER,:POWERSWAP,:PROTECT,:PSYCHIC,:PSYCHUP,:PSYSHOCK,
             :PSYWAVE,:RAGE,:REFLECT,:REST,:RETURN,:ROLLOUT,:ROUND,:SECRETPOWER,
             :SEEDBOMB,:SELFDESTRUCT,:SKILLSWAP,:SLEEPPOWDER,:SLEEPTALK,
             :SLUDGEBOMB,:SNORE,:SOLARBEAM,:STOMPINGTANTRUM,:STRENGTH,
             :STUNSPORE,:SUBSTITUTE,:SUNNYDAY,:SUPERPOWER,:SWAGGER,:SWEETSCENT,
             :SWORDSDANCE,:SYNTHESIS,:TAKEDOWN,:TELEKINESIS,:TELEPORT,:THIEF,
             :TOXIC,:TRICKROOM,:UPROAR,:WISH,:WOODHAMMER,:WORRYSEED,
             :ZENHEADBUTT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:CUBONE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CURSEDBODY),0],
         [getID(PBAbilities,:LIGHTINGROD),1],
         [getID(PBAbilities,:ROCKHEAD),2]]
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 40                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GROWL],[3,:TAILWHIP],[7,:BONECLUB],
                     [11,:FLAMEWHEEL],[13,:LEER],[17,:HEX],[21,:BONEMERANG],
                     [23,:WILLOWISP],[27,:SHADOWBONE],[31,:THRASH],[33,:FLING],
                     [37,:STOMPINGTANTRUM],[41,:ENDEAVOR],[43,:FLAREBLITZ],
                     [47,:RETALIATE],[51,:BONERUSH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})


MultipleForms.register(:MAROWAK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CURSEDBODY),0],
         [getID(PBAbilities,:LIGHTINGROD),1],
         [getID(PBAbilities,:ROCKHEAD),2]]
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 340                          # Alola
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GROWL],[1,:TAILWHIP],[1,:BONECLUB],[1,:FLAMEWHEEL],
                     [3,:TAILWHIP],[7,:BONECLUB],[11,:FLAMEWHEEL],[13,:LEER],
                     [17,:HEX],[21,:BONEMERANG],[23,:WILLOWISP],[27,:SHADOWBONE],
                     [33,:THRASH],[37,:FLING],[43,:STOMPINGTANTRUM],[49,:ENDEAVOR],
                     [53,:FLAREBLITZ],[59,:RETALIATE],[65,:BONERUSH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The rich greenery of the Alola region is hard on Marowak. It controls fire to stay alive.") if pokemon.form==1 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[:AERIALACE,:ALLYSWITCH,:ANCIENTPOWER,:ATTRACT,:BELLYDRUM,:BIDE,
             :BLIZZARD,:BODYSLAM,:BONECLUB,:BONEMERANG,:BONERUSH,:BRICKBREAK,
             :BRUTALSWING,:BUBBLEBEAM,:BULLDOZE,:CAPTIVATE,:CHIPAWAY,:CONFIDE,
             :COUNTER,:CURSE,:DARKPULSE,:DETECT,:DIG,:DOUBLEEDGE,:DOUBLEKICK,
             :DOUBLETEAM,:DREAMEATER,:DYNAMICPUNCH,:EARTHPOWER,:EARTHQUAKE,
             :ECHOEDVOICE,:ENDEAVOR,:ENDURE,:FACADE,:FALSESWIPE,:FIREBLAST,
             :FIREPUNCH,:FISSURE,:FLAMECHARGE,:FLAMETHROWER,:FLAMEWHEEL,
             :FLAREBLITZ,:FLING,:FOCUSBLAST,:FOCUSENERGY,:FOCUSPUNCH,
             :FRUSTRATION,:FURYCUTTER,:GIGAIMPACT,:GROWL,:HEADBUTT,:HEATWAVE,
             :HEX,:HIDDENPOWER,:HYPERBEAM,:ICEBEAM,:ICYWIND,:INCINERATE,
             :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:KNOCKOFF,:LASERFOCUS,:LEER,
             :LOWKICK,:MEGAKICK,:MEGAPUNCH,:MIMIC,:MUDSLAP,:NATURALGIFT,
             :OUTRAGE,:PAINSPLIT,:PERISHSONG,:POWERUPPUNCH,:PROTECT,:RAGE,
             :RAINDANCE,:REST,:RETALIATE,:RETURN,:ROCKCLIMB,:ROCKSLIDE,
             :ROCKSMASH,:ROCKTOMB,:ROUND,:SANDSTORM,:SCREECH,:SECRETPOWER,
             :SEISMICTOSS,:SHADOWBALL,:SHADOWBONE,:SKULLBASH,:SLEEPTALK,
             :SMACKDOWN,:SNORE,:SPITE,:STEALTHROCK,:STOMPINGTANTRUM,:STONEEDGE,
             :STRENGTH,:SUBMISSION,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:SWORDSDANCE,
             :TAILWHIP,:TAKEDOWN,:THIEF,:THRASH,:THROATCHOP,:THUNDER,
             :THUNDERBOLT,:THUNDERPUNCH,:TOXIC,:UPROAR,:WATERGUN,:WILLOWISP,
             :BURNINGJEALOUSY,:SCORCHINGSANDS,:POLTERGEIST]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Alola
   next 1
}
})

MultipleForms.register(:KOFFING,{
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
   when 2; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                
   next [[getID(PBAbilities,:LEVITATE),0],
         [getID(PBAbilities,:NEUTRALIZINGGAS),1],
         [getID(PBAbilities,:MISTYSURGE),2]] if pokemon.form==2
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,getID(PBItems,:MISTYSEED),0] # Blue-Striped
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 12                          # Alola
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 17                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:POISONGAS],[1,:TACKLE],[4,:FAIRYWIND],[8,:AROMATICMIST],
                     [12,:CLEARSMOG],[16,:ASSURANCE],[20,:SLUDGE],
                     [24,:AROMATHERAPY],[28,:SELFDESTRUCT],[32,:SLUDGEBOMB],
                     [36,:TOXIC],[40,:BELCH],[44,:EXPLOSION],[48,:MEMENTO],
                     [52,:DESTINYBOND],[56,:MISTYTERRAIN]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


MultipleForms.register(:WEEZING,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:POISON)  # Alola (Was Poison)
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                
   next [[getID(PBAbilities,:LEVITATE),0],
         [getID(PBAbilities,:NEUTRALIZINGGAS),1],
         [getID(PBAbilities,:MISTYSURGE),2]] if pokemon.form==2
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,getID(PBItems,:MISTYSEED),0] # Blue-Striped
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 30                          # Alola
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 160                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[0,:DOUBLEHIT],[1,:DOUBLEHIT],[1,:STRANGESTEAM],[1,:DEFOG],
                     [1,:HEATWAVE],[1,:SMOG],[1,:SMOKESCREEN],[1,:HAZE],
                     [1,:POISONGAS],[1,:TACKLE],[1,:FAIRYWIND],[1,:AROMATICMIST],
                     [12,:CLEARSMOG],[16,:ASSURANCE],[20,:SLUDGE],
                     [24,:AROMATHERAPY],[28,:SELFDESTRUCT],[32,:SLUDGEBOMB],
                     [38,:TOXIC],[44,:BELCH],[50,:EXPLOSION],[56,:MEMENTO],
                     [62,:DESTINYBOND],[68,:MISTYTERRAIN]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon consumes particles that contaminate the air. Instead of leaving droppings, it expels clean air.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:HYPERBEAM,:GIGAIMPACT,:SCREECH,:SELFDESTRUCT,:REST,:THIEF,:SNORE,
             :PROTECT,:ATTRACT,:RAINDANCE,:SUNNYDAY,:WILLOWISP,:FACADE,:PAYBACK,
             :ASSURANCE,:VENOSHOCK,:ROUND,:MISTYTERRAIN,:BRUTALSWING,
             :FLAMETHROWER,:THUNDERBOLT,:THUNDER,:FIREBLAST,:SUBSTITUTE,:SLUDGEBOMB,:ENDURE,:SLEEPTALK,:SHADOWBALL,
             :UPROAR,:HEATWAVE,:TAUNT,:GYROBALL,:TOXICSPIKES,:SARKPULSE,
             :SLUDGEWAVE,:PLAYROUGH,:VENOMDRENCH,:DAZZLINGGLEAM,:DOUBLEHIT,
             :STRANGESTEAM,:DEFOG,:SMOG,:SMOKESCREEN,:HAZE,:CLEARSMOG,:SLUDGE,
             :AROMATHERAPY,:TOXIC,:BELCH,:EXPLOSION,:MEMENTO,:DESTINYBOND,
             :CORROSIVEGAS,:MISTYEXPLOSION]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},

"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


MultipleForms.register(:MRMIME,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola (Was Psychic)
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [50,65,65,100,90,90] # Sandy Cloak
   else next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:VITALSPIRIT),0],
         [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:ICEBODY),2]] if pokemon.form==2
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 14                          # Alola
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 568                          # Alola
   else;   next 
   end
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Dancing") if pokemon.form==2
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:COPYCAT],[1,:ENCORE],[1,:ROLEPLAY],[1,:PROTECT],
                     [1,:MIMIC],[1,:LIGHTSCREEEN],[1,:REFLECT],[1,:SAFEGUARD],
                     [1,:DAZZLINGGLEAM],[1,:MISTYTERRAIN],[1,:POUND],
                     [1,:RAPIDSPIN],[1,:BATONPASS],[1,:ICESHARD],
                     [12,:CONFUSION],[16,:ALLYSWITCH],[20,:ICYWIND],
                     [24,:DOUBLEKICK],[28,:PSYBEAM],[32,:HYPNOSIS],
                     [36,:MIRRORCOAT],[40,:SUCKERPUNCH],[44,:FREEZEDRY],
                     [48,:PSYCHIC],[52,:TEETERDANCE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its talent is tap-dancing. It can also manipulate temperatures to create a floor of ice, which this Pokémon can kick up to use as a barrier.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:MEGAPUNCH,:MEGAKICK,:ICEPUNCH,:HYPERBEAM,:GIGAIMPACT,:SOLARBEAM,
             :THUNDERWAVE,:SCREECH,:LIGHTSCREEN,:REFLECT,:SAFEGUARD,:REST,
             :THIEF,SNORE,:PROTECT,:ICYWIND,:CHARM,:ATTRACT,:RAINDANCE,:SUNNYDAY,
             :HAIL,FACADE,:HELPINGHAND,:BRICKBREAK,:ICICLESPEAR,:PAYBACK,:FLING,
             :POWERSWAP,:GUARDSWAP,:DRAINPUNCH,:AVALANCHE,:TRICKROOM,:WONDEROOM,
             :MAGICROOM,:ROUND,:MISTYTERRAIN,:PSYCHICTERRAIN,:STOMPINGTANTRUM,
             :BODYSLAM,:ICEBEAM,:BLIZZARD,:THUNDERBOLT,:THUNDER,:PSYCHIC,
             :METRONOME,:SUBSTITUTE,:PSYSHOCK,:ENDURE,:SLEEPTALK,:BATONPASS,
             :ENCORE,:SHADOWBALL,:FUTURESIGHT,:UPROAR,:TAUNT,:TRICK,:SKILLSWAP,
             :IRONDEFENSE,:CALMMIND,:FOCUSBLAST,:ENERGYBALL,:NASTYPLOT,
             :ZENHEADBUTT,:GRASSKNOT,:FOULPLAY,:STOREDPOWER,:ALLYSWITCH,
             :DAZZLINGGLEAM,:COPYCAT,:ROLEPLAY,:MIMIC,:POUND,:RAPIDSPIN,
             :ICESHARD,:CONFUSION,:ICYWIND,:DOUBLEKICK,:PSYBEAM,:HYPNOSIS,
             :MIRRORCOAT,:SUCKERPUNCH,:FREEZEDRY,:PSYCHIC,:TEETERDANCE,
             :TRIPLEAXEL,:EXPANDINGFORCE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:TAUROS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   when 2; next getID(PBTypes,:FIGHTING)  # Alola
   when 3; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   when 2; next getID(PBTypes,:FIRE)	  # Alola
   when 3; next getID(PBTypes,:WATER)	  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 1150                          # Alola
   when 2; 850                          # Alola
   when 3; 1100                          # Alola
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:INTIMIDATE),0],
         [getID(PBAbilities,:ANGERPOINT),1],
         [getID(PBAbilities,:CUDCHEW),2]] if pokemon.form==1 || 
											 pokemon.form==2 ||
											 pokemon.form==3 # Was SURGESURFER
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:TAILWHIP],[5,:WORKUP],
					 [10,:DOUBLEKICK],[15,:ASSURANCE],[20,:HEADBUTT],
					 [25,:SCARYFACE],[30,:ZENHEADBUTT],[35,:RAGINGBULL],
					 [40,:REST],[45,:SWAGGER],[50,:THRASH],
					 [55,:DOUBLEEDGE],[60,:CLOSECOMBAT]]
   when 2; movelist=[[1,:TACKLE],[1,:TAILWHIP],[5,:WORKUP],
					 [10,:DOUBLEKICK],[15,:FLAMECHARGE],[20,:HEADBUTT],
					 [25,:SCARYFACE],[30,:ZENHEADBUTT],[35,:RAGINGBULL],
					 [40,:REST],[45,:SWAGGER],[50,:THRASH],
					 [55,:FLAREBLITZ],[60,:CLOSECOMBAT]]
   when 3; movelist=[[1,:TACKLE],[1,:TAILWHIP],[5,:WORKUP],
					 [10,:DOUBLEKICK],[15,:AQUAJET],[20,:HEADBUTT],
					 [25,:SCARYFACE],[30,:ZENHEADBUTT],[35,:RAGINGBULL],
					 [40,:REST],[45,:SWAGGER],[50,:THRASH],
					 [55,:WAVECRASH],[60,:CLOSECOMBAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon has a muscular body and excels at close-quarters combat. It uses its short horns to strike the opponent’s weak spots.") if pokemon.form==1 # Eternal
   next _INTL("When heated by fire energy, its horns can get hotter than 1,800 degrees Fahrenheit. Those gored by them will suffer both wounds and burns.") if pokemon.form==2 # Eternal
   next _INTL("This Pokémon blasts water from holes on the tips of its horns—the high-pressure jets pierce right through Tauros’s enemies.") if pokemon.form==3 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next [1,2,3][rand(3)] if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Paldea
   next [1,2,3][rand(3)]
}
})


# TODO: Movelist and dex entries

MultipleForms.register(:ARTICUNO,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   when 2; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FLYING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:BIGVOLCANO),0],
         [getID(PBAbilities,:HEALTHYTUNNEL),1],
         [getID(PBAbilities,:LOVINGCLUSTER),2]] if pokemon.form==1
   next [[getID(PBAbilities,:COMPETITIVE),0],
   #      [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:COMPETITIVE),2]] if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 509                          # Alola
   else;   next 
   end
},
"kind"=>proc{|pokemon|
   next if pokemon.form<2                         # Unova Formes
   next _INTL("Firefly") if pokemon.form==1       # Galar Formes
   next _INTL("Cruel")                            # Galar Formes
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:CASTLEMANIA],[1,:EMBER],[5,:MINDREADER],
                     [10,:BRUNALWINGS],[15,:AGILITY],[20,:FIERYMANIA],
                     [25,:ANCIENTPOWER],[30,:ACROBATICS],[35,:SUPERDISABLE],
                     [40,:VOLCANICTERRAIN],[45,:BADDREAMS],[50,:TORCHWOOD],
                     [50,:MASCUGLASS],[60,:GLIMMYGALAXY],[70,:AERO],
                     [80,:CONFIDE],[90,:ROASTJUMP],[100,:PSYCHICFANGS],
                     [400,:LOVELYTERRAIN]]
   when 2; movelist=[[1,:GUST],[1,:PSYCHOSHIFT],[8,:CONFUSION],[15,:HYPNOSIS],
                     [22,:MINDREADER],[29,:ANCIENTPOWER],[36,:AGILITY],
                     [43,:PSYCHOCUT],[50,:REFLECT],[57,:DREAMEATER],
                     [64,:TAILWIND],[71,:FREEZINGGLARE],[78,:FUTURESIGHT],
                     [85,:RECOVER],[92,:HURRICANE],[99,:TRICKROOM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [90,85,85,95,125,100] # Sandy Cloak
   else next
   end
},
=begin
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Watch your step when wandering areas oceans once covered. What looks like a stone could be this Pokémon, and it will curse you if you kick it.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:DIG,:SCREECH,:LIGHTSCREEN,:REFLECT,:SAFEGUARD,:SELFDESTRUCT,
             :REST,:ROCKSLIDE,:SNORE,:PROTECT,:ICYWIND,:GIGADRAIN,:ATTRACT,
             :SANDSTORM,:RAINDANCE,:SUNNYDAY,:HAIL,:WILLOWISP,:FACADE,:ROCKTOMB,
             :ICICLESPEAR,:ROCKBLAST,:BRINE,:ROUND,:HEX,:BULLDOZE,
             :STOMPINGTANTRUM,:BODYSLAM,:HYDROPUMP,:SURF,:ICEBEAM,:BLIZZARD,
             :EARTHQUAKE,:PSYCHIC,:AMNESIA,:SUBSTITUTE,:ENDURE,:SLEEPTALK,
             :SHADOWBALL,:IRONDEFENSE,:CALMMIND,:POWERGEM,:EARTHPOWER,:STONEEDGE,
             :STEALTHROCK,:SCALD,:THROATCHOP,:LIQUIDATION,:TACKLE,:HARDEN,
             :ASTONISH,:DISABLE,:SPITE,:ANCIENTPOWER,:CURSE,:STRENGTHSAP,
             :POWERGEM,:NIGHTSHADE,:GRUDGE,:MIRRORCOAT,:METEORBEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
=end
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   maps=[421]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   end
#   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


MultipleForms.register(:ZAPDOS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   when 2; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FLYING)  # Alola
   else;   next 
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0 
   next [[getID(PBAbilities,:PASTRYSUN),0],
         [getID(PBAbilities,:HEALTHYTUNNEL),1],
         [getID(PBAbilities,:LOVINGCLUSTER),2]] if pokemon.form==1
   next [[getID(PBAbilities,:DEFIANT),0],
   #      [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:DEFIANT),2]] if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 582                          # Alola
   else;   next 
   end
},
"kind"=>proc{|pokemon|
   next if pokemon.form<1                         # Unova Formes
   next _INTL("Strong Legs")                        # Galar Formes
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:CASTLEMANIA],[1,:STEELWING],[5,:MINDREADER],
                     [10,:BRUNALWINGS],[15,:AGILITY],[20,:SILVERCAGE],
                     [25,:ANCIENTPOWER],[30,:ACROBATICS],[35,:SUPERDISABLE],
                     [40,:DOOMSURPLETE],[45,:BADDREAMS],[50,:WHEELOFFORTUNE],
                     [50,:MESCUGLESS],[60,:GLIMMYGALAXY],[70,:AERO],
                     [80,:CONFIDE],[90,:SPEEDYJUMP],[100,:PSYCHICFANGS],
                     [400,:LOVELYTERRAIN]]
   when 2; movelist=[[1,:PECK],[1,:FOCUSENERGY],[8,:ROCKSMASH],[15,:DETECT],
                     [22,:PLUCK],[29,:ANCIENTPOWER],[36,:BRICKBREAK],
                     [43,:AGILITY],[50,:THUNDEROUSKICK],[57,:BULKUP],
                     [64,:LIGHTSCREEN],[71,:DRILLPECK],[78,:COUNTER],
                     [85,:QUICKGUARD],[92,:CLOSECOMBAT],[99,:REVERSAL]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [90,125,90,100,85,90] # Sandy Cloak
   else next
   end
},
=begin
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Watch your step when wandering areas oceans once covered. What looks like a stone could be this Pokémon, and it will curse you if you kick it.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:DIG,:SCREECH,:LIGHTSCREEN,:REFLECT,:SAFEGUARD,:SELFDESTRUCT,
             :REST,:ROCKSLIDE,:SNORE,:PROTECT,:ICYWIND,:GIGADRAIN,:ATTRACT,
             :SANDSTORM,:RAINDANCE,:SUNNYDAY,:HAIL,:WILLOWISP,:FACADE,:ROCKTOMB,
             :ICICLESPEAR,:ROCKBLAST,:BRINE,:ROUND,:HEX,:BULLDOZE,
             :STOMPINGTANTRUM,:BODYSLAM,:HYDROPUMP,:SURF,:ICEBEAM,:BLIZZARD,
             :EARTHQUAKE,:PSYCHIC,:AMNESIA,:SUBSTITUTE,:ENDURE,:SLEEPTALK,
             :SHADOWBALL,:IRONDEFENSE,:CALMMIND,:POWERGEM,:EARTHPOWER,:STONEEDGE,
             :STEALTHROCK,:SCALD,:THROATCHOP,:LIQUIDATION,:TACKLE,:HARDEN,
             :ASTONISH,:DISABLE,:SPITE,:ANCIENTPOWER,:CURSE,:STRENGTHSAP,
             :POWERGEM,:NIGHTSHADE,:GRUDGE,:MIRRORCOAT,:METEORBEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
=end
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   maps=[421]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   end
#   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:MOLTRES,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   when 2; next getID(PBTypes,:DARK)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:FLYING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHANTOMSPIRIT),0],
         [getID(PBAbilities,:HEALTHYTUNNEL),1],
         [getID(PBAbilities,:LOVINGCLUSTER),2]] if pokemon.form==1
   next [[getID(PBAbilities,:BERSERK),0],
   #      [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:BERSERK),2]] if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 660                          # Alola
   else;   next 
   end
},
"kind"=>proc{|pokemon|
   next if pokemon.form<1                         # Unova Formes
   next _INTL("Malevolent")                        # Galar Formes
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:CASTLEMANIA],[1,:NIGHTSHADE],[5,:MINDREADER],
                     [10,:BRUNALWINGS],[15,:AGILITY],[20,:CURSE],
                     [25,:ANCIENTPOWER],[30,:ACROBATICS],[35,:SUPERDISABLE],
                     [40,:NIGHTMOON],[45,:BADDREAMS],[50,:DESTINYBOND],
                     [50,:MOSCUGLOSS],[60,:GLIMMYGALAXY],[70,:AERO],
                     [80,:CONFIDE],[90,:GHOSTLYAEROBICS],[100,:PSYCHICFANGS],
                     [400,:LOVELYTERRAIN]]
   when 2; movelist=[[1,:WINGATTACK],[1,:PAYBACK],[8,:SUCKERPUNCH],[15,:AGILITY],
                     [22,:ENDURE],[29,:ANCIENTPOWER],[36,:DARKPULSE],
                     [43,:SAFEGUARD],[50,:AIRSLASH],[57,:NASTYPILOT],
                     [64,:FIERYWRATH],[71,:SOLARBEAM],[78,:SKYATTACK],
                     [85,:AFTERYOU],[92,:HURRICANE],[99,:MEMENTO]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [90,85,90,90,100,125] # Sandy Cloak
   else next
   end
},
=begin
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Watch your step when wandering areas oceans once covered. What looks like a stone could be this Pokémon, and it will curse you if you kick it.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:DIG,:SCREECH,:LIGHTSCREEN,:REFLECT,:SAFEGUARD,:SELFDESTRUCT,
             :REST,:ROCKSLIDE,:SNORE,:PROTECT,:ICYWIND,:GIGADRAIN,:ATTRACT,
             :SANDSTORM,:RAINDANCE,:SUNNYDAY,:HAIL,:WILLOWISP,:FACADE,:ROCKTOMB,
             :ICICLESPEAR,:ROCKBLAST,:BRINE,:ROUND,:HEX,:BULLDOZE,
             :STOMPINGTANTRUM,:BODYSLAM,:HYDROPUMP,:SURF,:ICEBEAM,:BLIZZARD,
             :EARTHQUAKE,:PSYCHIC,:AMNESIA,:SUBSTITUTE,:ENDURE,:SLEEPTALK,
             :SHADOWBALL,:IRONDEFENSE,:CALMMIND,:POWERGEM,:EARTHPOWER,:STONEEDGE,
             :STEALTHROCK,:SCALD,:THROATCHOP,:LIQUIDATION,:TACKLE,:HARDEN,
             :ASTONISH,:DISABLE,:SPITE,:ANCIENTPOWER,:CURSE,:STRENGTHSAP,
             :POWERGEM,:NIGHTSHADE,:GRUDGE,:MIRRORCOAT,:METEORBEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
=end
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   maps=[421]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   end
#   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

########################################
# Generation II
########################################

MultipleForms.register(:CYNDAQUIL,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
=begin
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 130                          # Alola
   end
},
=end
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:BLAZE),0],
         [getID(PBAbilities,:BLAZE),1],
         [getID(PBAbilities,:FRISK),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [39,52,43,65,60,50] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:LEER],[6,:SMOKESCREEN],[10,:EMBER],
                     [13,:QUICKATTACK],[19,:FLAMEWHEEL],[22,:DEFENSECURL],
                     [28,:FLAMECHARGE],[31,:SWIFT],[37,:SHADOWBALL],
                     [40,:FLAMETHROWER],[46,:INFERNO],[49,:ROLLOUT],
                     [55,:DOUBLEEDGE],[58,:BURNUP],[64,:ERUPTION]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Ghostly Mouse")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Hails from the Johto region. Though usually curled into a ball due to its timid disposition, it harbors tremendous firepower.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:QUILAVA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
=begin
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 130                          # Alola
   end
},
=end
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:BLAZE),0],
         [getID(PBAbilities,:BLAZE),1],
         [getID(PBAbilities,:FRISK),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [53,64,58,80,85,65] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:INFERNALPARADE],[1,:TACKLE],[1,:LEER],[6,:SMOKESCREEN],
                     [10,:EMBER],[13,:QUICKATTACK],[20,:FLAMEWHEEL],
                     [24,:DEFENSECURL],[31,:FLAMECHARGE],[35,:SWIFT],
                     [42,:SHADOWBALL],[46,:FLAMETHROWER],[53,:INFERNO],
                     [57,:ROLLOUT],[64,:DOUBLEEDGE],[68,:BURNUP],
                     [75,:ERUPTION]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Ghost Flame")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This creature's fur is most mysterious—it is wholly impervious to the burning touch of flame. Should Quilava turn its back to you, take heed! Such a posture indicates a forthcoming attack.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:TYPHLOSION,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
=begin
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 130                          # Alola
   end
},
=end
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:BLAZE),0],
         [getID(PBAbilities,:BLAZE),1],
         [getID(PBAbilities,:FRISK),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [73,84,78,95,119,85] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:HEX],[1,:INFERNALPARADE],[1,:TACKLE],[1,:LEER],
                     [6,:SMOKESCREEN],[10,:EMBER],[13,:QUICKATTACK],
                     [20,:FLAMEWHEEL],[24,:DEFENSECURL],[31,:FLAMECHARGE],
                     [35,:SWIFT],[43,:SHADOWBALL],[48,:FLAMETHROWER],
                     [56,:INFERNO],[61,:ROLLOUT],[69,:DOUBLEEDGE],[74,:BURNUP],
                     [82,:ERUPTION]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Ghost Flame")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Said to purify lost, forsaken souls with its flames and guide them to the afterlife. I believe its form has been influenced by the energy of the sacred mountain towering at Hisui's center.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


# Form 0    - Johtonian
# Form 1    - Alolan
# Form 2    - Spikey-Earned (Unreleased)

MultipleForms.register(:PICHU,{
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   env=pbGetEnvironment()
   next 0 unless env==PBEnvironment::Alola
   next 1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0  || pokemon.form>1                 
   next [[getID(PBAbilities,:ELECTRICSURGE),0],
         [getID(PBAbilities,:ELECTRICSURGE),2]]
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:THUNDERSHOCK],[1,:CHARM],[5,:TAILWHIP],[10,:REST],
                     [13,:SNORE],[18,:SWEETKISS]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})



MultipleForms.register(:SLOWKING,{
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
"kind"=>proc{|pokemon|
   next if pokemon.form!=2                         # Kanto Formes
   next _INTL("Hexpert")                           # Galar Formes
},
"getBaseStats"=>proc{|pokemon|
   next [95,65,80,30,110,110] if pokemon.form==2
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:CURIOUSMEDICINE),0],
         [getID(PBAbilities,:OWNTEMPO),1],
         [getID(PBAbilities,:REGENERATOR),2]] if pokemon.form==2
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[0,:EERIESPELL],[1,:POWERGEM],[1,:NASTYPLOT],[1,:SWAGGER],
                     [1,:TACKLE],[1,:CURSE],[1,:GROWL],[1,:ACID],[9,:YAWN],
                     [12,:CONFUSION],[15,:DISABLE],[18,:WATERPULSE],[21,:HEADBUTT],
                     [24,:ZENHEADBUTT],[27,:AMNESIA],[30,:SURF],[33,:SLACKOFF],
                     [36,:PSYCHIC],[39,:PSYCHUP],[42,:RAINDANCE],[45,:HEALPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A combination of toxins and the shock of evolving has increased Shellder's intelligence to the point that Shellder now controls Slowking.") if pokemon.form==2 
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:WOOPER,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 110                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:POISONPOINT),0],
         [getID(PBAbilities,:WATERABSORB),1],
         [getID(PBAbilities,:UNAWARE),2]] if pokemon.form==1 # Was SURGESURFER
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:MUDSHOT],[1,:TAILWHIP],[4,:TACKLE],[8,:POISONTAIL],
                     [12,:TOXICSPIKES],[16,:SLAM],[21,:YAWN],
                     [24,:POISONJAB],[28,:SLUDGEWAVE],[32,:AMNESIA],
                     [36,:TOXIC],[40,:EARTHQUAKE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Poison Fish")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After losing a territorial struggle, Wooper began living on land. The Pokémon changed over time, developing a poisonous film to protect its body.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Paldea
   next 1
}
})



MultipleForms.register(:QWILFISH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 39                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:POISONPOINT),0],
         [getID(PBAbilities,:SWIFTSWIM),1],
         [getID(PBAbilities,:INTIMIDATE),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [65,95,85,85,55,55] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:FELLSTINGER],[1,:HYDROPUMP],[1,:DESTINYBOND],
                     [1,:WATERGUN],[1,:SPIKES],[1,:TACKLE],[1,:POISONSTING],
                     [9,:HARDEN],[9,:MINIMIZE],[13,:BARBBARRAGE],[17,:ROLLOUT],
                     [21,:TOXICSPIKES],[25,:STOCKPILE],[25,:SPITUP],[29,:REVENGE],
                     [33,:DARKPULSE],[37,:PINMISSILE],[41,:TAKEDOWN],
                     [45,:AQUATAIL],[49,:POISONJAB],[53,:DESTINYBOND],
                     [57,:HYDROPUMP],[60,:FELLSTINGER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Balloon")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Fishers detest this troublesome Pokémon because it sprays poison from its spines, getting it everywhere. A different form of Qwilfish lives in other regions.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:SNEASEL,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 9                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 28                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:INNERFOCUS),0],
         [getID(PBAbilities,:KEENEYE),1],
         [getID(PBAbilities,:PICKPOCKET),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [55,95,55,115,35,75] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SCRATCH],[1,:LEER],[1,:TAUNT],[8,:QUICKATTACK],
                     [10,:FEINTATTACK],[14,:ROCKSMASH],[16,:FURYSWIPES],
                     [20,:AGILITY],[22,:METALCLAW],[25,:HONECLAWS],[28,:BEATUP],
                     [32,:SCREECH],[35,:SLASH],[40,:POISONJAB],[44,:PUNISHMENT],
                     [47,:CLOSECOMBAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Sharp Claw")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its sturdy, curved claws are ideal for traversing precipitous cliffs. From the tips of these claws drips a venom that infiltrates the nerves of any prey caught in Sneasel’s grasp.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})



MultipleForms.register(:CORSOLA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:GHOST)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:GHOST)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [50,65,65,100,90,90] # Sandy Cloak
   else next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:WEAKARMOR),0],
   #      [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:CURSEDBODY),2]] if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 5                          # Alola
   else;   next 
   end
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:TACKLE],[1,:HARDEN],[5,:ASTONISH],[10,:DISABLE],
                     [15,:SPITE],[20,:ANCIENTPOWER],[25,:HEX],[30,:CURSE],
                     [35,:STRENGTHSAP],[40,:POWERGEM],[45,:NIGHTSHADE],
                     [50,:GRUDGE],[55,:MIRRORCOAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Watch your step when wandering areas oceans once covered. What looks like a stone could be this Pokémon, and it will curse you if you kick it.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:DIG,:SCREECH,:LIGHTSCREEN,:REFLECT,:SAFEGUARD,:SELFDESTRUCT,
             :REST,:ROCKSLIDE,:SNORE,:PROTECT,:ICYWIND,:GIGADRAIN,:ATTRACT,
             :SANDSTORM,:RAINDANCE,:SUNNYDAY,:HAIL,:WILLOWISP,:FACADE,:ROCKTOMB,
             :ICICLESPEAR,:ROCKBLAST,:BRINE,:ROUND,:HEX,:BULLDOZE,
             :STOMPINGTANTRUM,:BODYSLAM,:HYDROPUMP,:SURF,:ICEBEAM,:BLIZZARD,
             :EARTHQUAKE,:PSYCHIC,:AMNESIA,:SUBSTITUTE,:ENDURE,:SLEEPTALK,
             :SHADOWBALL,:IRONDEFENSE,:CALMMIND,:POWERGEM,:EARTHPOWER,:STONEEDGE,
             :STEALTHROCK,:SCALD,:THROATCHOP,:LIQUIDATION,:TACKLE,:HARDEN,
             :ASTONISH,:DISABLE,:SPITE,:ANCIENTPOWER,:CURSE,:STRENGTHSAP,
             :POWERGEM,:NIGHTSHADE,:GRUDGE,:MIRRORCOAT,:METEORBEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


########################################
# Generation III
########################################

MultipleForms.register(:ZIGZAGOON,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:DARK)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:NORMAL)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==2
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:TACKLE],[1,:LEER],[3,:SANDATTACK],[6,:LICK],[9,:SNARL],
                     [12,:HEADBUTT],[15,:BABYDOLLEYES],[18,:PINMISSILE],
                     [21,:REST],[24,:TAKEDOWN],[27,:SCARYFACE],[30,:COUNTER],
                     [33,:TAUNT],[36,:DOUBLEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its restlessness has it constantly running around. If it sees another Pokémon, it will purposely run into them in order to start a fight.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:PINMISSILE,:THUNDERWAVE,:DIG,:SCREECH,:REST,:THIEF,:SNORE,:PROTECT,
             :SCARYFACE,:ICYWIND,:ATTRACT,:RAINDANCE,:SUNNYDAY,:WHIRLPOOL,
             :FACADE,:SWIFT,:HELPINGHAND,:FAKETEARS,:MUDSHOT,:PAYBACK,:ASSURANCE,
             :FLING,:ROUND,:RETALIATE,:SNARL,:BODYSLAM,:SURF,:ICEBEAM,:BLIZZARD,
             :THUNDERBOLT,:THUNDER,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:IRONTAIL,
             :SHADOWBALL,:TAUNT,:TRICK,:HYPERVOICE,:SEEDBOMB,:GUNKSHOT,:GRASSKNOT,
             :WORKUP,:TACKLE,:LEER,:SANDATTACK,:LICK,:HEADBUTT,:BABYDOLLEYES,
             :TAKEDOWN,:SCARYFACE,:COUNTER,:DOUBLEEDGE,:LASHOUT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:LINOONE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:DARK)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:NORMAL)  # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[0,:NIGHTSLASH],[1,:NIGHTSLASH],[1,:SWITCHEROO],
                     [1,:PINMISSILE],[1,:BABYDOLLEYES],[1,:TACKLE],[1,:LEER],
                     [1,:SANDATTACK],[1,:LICK],[9,:SNARL],[12,:HEADBUTT],
                     [15,:HONECLAWS],[18,:FURYSWIPES],[23,:REST],[28,:TAKEDOWN],
                     [33,:SCARYFACE],[38,:COUNTER],[43,:TAUNT],[48,:DOUBLEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It uses its long tongue to taunt opponents. Once the opposition is enraged, this Pokémon hurls itself at the opponent, tackling them forcefully.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:PINMISSILE,:HYPERBEAM,:GIGAIMPACT,:THUNDERWAVE,:DIG,:SCREECH,:REST,
             :THIEF,:SNORE,:PROTECT,:SCARYFACE,:ICYWIND,:ATTRACT,:RAINDANCE,
             :SUNNYDAY,:WHIRLPOOL,:FACADE,:SWIFT,:HELPINGHAND,:FAKETEARS,
             :MUDSHOT,:PAYBACK,:ASSURANCE,:FLING,:SHADOWCLAW,:ROUND,:RETALIATE,
             :SNARL,:STOMPINGTANTRUM,:BODYSLAM,:SURF,:ICEBEAM,:BLIZZARD,
             :THUNDERBOLT,:THUNDER,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:IRONTAIL,
             :SHADOWBALL,:TAUNT,:TRICK,:HYPERVOICE,:SEEDBOMB,:GUNKSHOT,:GRASSKNOT,
             :WORKUP,:THROATCHOP,:BODYPRESS,:NIGHTSLASH,:TACKLE,:LEER,:SANDATTACK,
             :LICK,:HEADBUTT,:BABYDOLLEYES,:TAKEDOWN,:SCARYFACE,:COUNTER,
             :DOUBLEEDGE,:LASHOUT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

########################################
# Generation IV
########################################

MultipleForms.register(:MIMEJR,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:ICE)  # Alola
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
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [25,35,45,65,65,80] # Sandy Cloak
   else next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:VITALSPIRIT),0],
         [getID(PBAbilities,:SNOWCLOAK),1],
         [getID(PBAbilities,:ICEBODY),2]] if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 14                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:POUND],[1,:COPYAT],[4,:BATONPASS],[8,:ICESHARD],
                     [12,:CONFUSION],[16,:ALLYSWITCH],[20,:ICYWIND],
                     [24,:DOUBLEKICK],[28,:PSYBEAM],[32,:MIMIC],
                     [36,:MIRRORCOAT],[40,:SUCKERPUNCH],[44,:FREEZEDRY],
                     [48,:PSYCHIC],[52,:TEETERDANCE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


########################################
# Generation V
########################################
MultipleForms.register(:OSHAWOTT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 59                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:TORRENT),0],
         [getID(PBAbilities,:TORRENT),1],
         [getID(PBAbilities,:SHARPNESS),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [55,63,45,50,55,40] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[5,:TAILWHIP],[7,:WATERGUN],[11,:WATERSPORT],
                     [13,:FOCUSENERGY],[17,:RAZORSHELL],[19,:FURYCUTTER],
                     [23,:WATERPULSE],[25,:REVENGE],[29,:AQUAJET],[31,:ENCORE],
                     [35,:AQUATAIL],[37,:DARKPULSE],[41,:SWORDSDANCE],
                     [43,:HYDROPUMP]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Sea Otter")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon from the Unova region uses the shell on its belly as a weapon to cut down its foes. Thus, I've conferred upon this shell the name \"scalchop.\"") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:DEWOTT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 8                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 245                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:TORRENT),0],
         [getID(PBAbilities,:TORRENT),1],
         [getID(PBAbilities,:SHARPNESS),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [70,83,60,70,75,55] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:CEASELESSEDGE],[1,:TACKLE],[5,:TAILWHIP],[7,:WATERGUN],
                     [11,:WATERSPORT],[13,:FOCUSENERGY],[18,:RAZORSHELL],
                     [21,:FURYCUTTER],[26,:WATERPULSE],[29,:REVENGE],
                     [34,:AQUAJET],[37,:ENCORE],[42,:AQUATAIL],[45,:DARKPULSE],
                     [50,:SWORDSDANCE],[53,:HYDROPUMP]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Discipline")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its exquisite double-scalchop technique is likely the result of daily training, and it can send even masters of the blade fleeing in defeat.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:SAMUROTT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:WATER)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 15                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 946                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:TORRENT),0],
         [getID(PBAbilities,:TORRENT),1],
         [getID(PBAbilities,:SHARPNESS),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [90,108,80,85,100,65] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:NIGHTSLASH],[1,:CEASELESSEDGE],[1,:TACKLE],[5,:TAILWHIP],
                     [7,:WATERGUN],[11,:WATERSPORT],[13,:FOCUSENERGY],
                     [18,:RAZORSHELL],[21,:FURYCUTTER],[26,:WATERPULSE],
                     [29,:REVENGE],[34,:AQUAJET],[39,:ENCORE],[46,:AQUATAIL],
                     [51,:DARKPULSE],[58,:SWORDSDANCE],[63,:HYDROPUMP]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Formidable")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Hard of heart and deft of blade, this rare form of Samurott is a product of the Pokémon's evolution in the region of Hisui. Its turbulent blows crash into foes like ceaseless pounding waves.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:PETILIL,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 66                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CHLOROPHYLL),0],
         [getID(PBAbilities,:HUSTELE),1],
         [getID(PBAbilities,:LEAFGUARD),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [45,60,50,40,35,50] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:ABSORB],[4,:GROWTH],[8,:LEECHSEED],[10,:SLEEPPOWDER],
                     [13,:MEGADRAIN],[17,:SYNTHESIS],[19,:ROCKSMASH],
                     [22,:STUNSPORE],[26,:GIGADRAIN],[28,:AROMATHERAPY],
                     [31,:DRAINPUNCH],[35,:ENERGYBALL],[37,:ENTRAINMENT],
                     [40,:SUNNYDAY],[44,:AFTERYOU],[46,:LEAFSTORM],
                     [50,:CLOSECOMBAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Bulb")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The leaves on its head are highly valued for medicinal purposes. Dry the leaves in the sun, boil them, and then drink the bitter decoction for remarkably effective relief from fatigue.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:LILLIGANT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 11                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 163                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CHLOROPHYLL),0],
         [getID(PBAbilities,:HUSTELE),1],
         [getID(PBAbilities,:LEAFGUARD),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [70,105,75,105,50,75] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:VICTORYDANCE],[1,:ABSORB],[4,:GROWTH],[8,:LEECHSEED],
                     [10,:SLEEPPOWDER],[13,:MEGADRAIN],[17,:SYNTHESIS],
                     [19,:ROCKSMASH],[22,:STUNSPORE],[26,:GIGADRAIN],
                     [28,:AROMATHERAPY],[31,:DRAINPUNCH],[35,:ENERGYBALL],
                     [37,:ENTRAINMENT],[40,:SUNNYDAY],[44,:AFTERYOU],
                     [46,:LEAFSTORM],[50,:CLOSECOMBAT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Flowering")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("I suspect that its well-developed legs are the result of a life spent on mountains covered in deep snow. The scent it exudes from its flower crown heartens those in proximity.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:DARUMAKA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==2
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 7                          # Alola
   else;   next 
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 40                          # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:POWDERSNOW],[1,:TACKLE],[4,:TAUNT],[8,:BITE],
                     [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
                     [32,:UPROAR],[36,:BELLYDRUM],[40,:BLIZZARD],[44,:THRASH],
                     [48,:SUPERPOWER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It lived in snowy areas for so long that its fire sac cooled off and atrophied. It now has an organ that generates cold instead.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:MEGAPUNCH,:MEGAKICK,:FIREPUNCH,:ICEPUNCH,:SOLARBEAM,:FIRESPIN,:DIG,
             :REST,:ROCKSLIDE,:THIEF,:SNORE,:PROTECT,:ATTRACT,:SUNNYDAY,
             :WILLOWISP,:FACADE,:BRICKBREAK,:ROCKTOMB,:UTURN,:FLING,:AVALANCHE,
             :ICEFANG,:FIREFANG,:ROUND,:FLAMETHROWER,:ICEBEAM,:BLIZZARD,
             :FOCUSENERGY,:FIREBLAST,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:ENCORE,
             :UPROAR,:HEATWAVE,:TAUNT,:SUPERPOWER,:OVERHEAT,LGYROBALL,:FLAREBLITZ,
             :ZENHEADBUTT,:GRASSKNOT,:WORKUP,:POWDERSNOW,:TACKLE,:BITE,:HEADBUTT,
             :BELLYDRUM,:THRASH]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})


MultipleForms.register(:DARMANITAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==2      # Standard Modes
   next [105,30,105,55,140,105] if pokemon.form==1 # Zen Mode (Unovan)
   next [105,160,55,135,30,55]  if pokemon.form==3 # Zen Mode (Galarian)
},
"height"=>proc{|pokemon|
   next if pokemon.form<2                          # Unova Formes
   next 17                                         # Galar Formes
},
"weight"=>proc{|pokemon|
   next if pokemon.form<2                          # Unova Formes
   next 1200                                       # Galar Formes
},
"color"=>proc{|pokemon|
   next if pokemon.form==0                         # Standard Mode (Unovan)
   next 1 if pokemon.form==1                       # Zen Mode (Unovan)
   next 8 if pokemon.form>1                        # Galar Formes
},

"type1"=>proc{|pokemon|
   next if pokemon.form<2                          # Unova Formes
   next getID(PBTypes,:ICE)                        # Galar Formes (Was Ice)
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0                           # Standard Mode (Unovan)
   next getID(PBTypes,:PSYCHIC)   if pokemon.form==1 # Zen Mode (Unovan, Was Psychic)
   next getID(PBTypes,:ICE)       if pokemon.form==2 # Standard Mode (Galarian)
   next getID(PBTypes,:FIRE)      if pokemon.form==3 # Zen Mode (Galarian)
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==2      # Standard Modes
   next [0,0,0,0,2,0]                              # Zen Modes
},
"kind"=>proc{|pokemon|
   next if pokemon.form<2                         # Unova Formes
   next _INTL("Zen Charm")                        # Galar Formes
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form<2                   
   next [[getID(PBAbilities,:GORILLATACTICS),0],
   #      [getID(PBAbilities,:SCREENCLEANER),1],
         [getID(PBAbilities,:ZENMODE),2]]
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form<2
   movelist=[]
   case pokemon.form
   when 2,3; movelist=[[0,:ICICLECRASH],[1,:ICICLECRASH],[1,:POWDERSNOW],
                       [1,:TACKLE],[1,:TAUNT],[1,:BITE],
                       [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
                       [32,:UPROAR],[38,:BELLYDRUM],[44,:BLIZZARD],[50,:THRASH],
                       [56,:SUPERPOWER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Through meditation, it calms its raging spirit and hones its psychic powers.") if pokemon.form==1 # Eternal
   next _INTL("On days when blizzards blow through, it comes down to where people live. It stashes food in the snowball on its head, taking it home for later.") if pokemon.form==2 # Eternal
   next _INTL("Anger has reignited its atrophied flame sac. This Pokémon spews fire everywhere as it rampages indiscriminately.") if pokemon.form==3 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form<2 # Unovan Forms
   movelist=[:MEGAPUNCH,:MEGAKICK,:FIREPUNCH,:ICEPUNCH,:HYPERBEAM,:GIGAIMPACT,
             :SOLARBEAM,:FIRESPIN,:DIG,:REST,:ROCKSLIDE,:THIEF,:SNORE,:PROTECT,
             :ATTRACT,:SUNNYDAY,:WILLOWISP,:FACADE,:BRICKBREAK,:ROCKTOMB,
             :UTURN,:PAYBACK,:FLING,:AVALANCHE,:ICEFANG,:FIREFANG,:ROUND,
             :BULLSOZE,:BODYSLAM,:FLAMETHROWER,:ICEBEAM,:BLIZZARD,
             :EARTHQUAKE,:PSYCHIC,:FOCUSENERGY,:FIREBLAST,:SUBSTITUTE,:REVERSAL,
             :ENDURE,:SLEEPTALK,:ENCORE,:UPROAR,:HEATWAVE,:TAUNT,:SUPERPOWER,
             :OVERHEAT,:IRONDEFENSE,:BULKUP,:GYROBALL,:FLAREBLITZ,:FOCUSBLAST,
             :ZENHEADBUTT,:IRONHEAD,:STONEEDGE,:GRASSKNOT,:WORKUP,:BODYPRESS,
             :ICICLECRASH,:POWDERSNOW,:TACKLE,:BITE,:HEADBUTT,:BELLYDRUM,:THRASH,
             :DARMANITAN]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:ZORUA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:NORMAL)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 7                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 125                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:ILLUSION),0],
         [getID(PBAbilities,:ILLUSION),1],
         [getID(PBAbilities,:ILLUSION),2]] if pokemon.form==1 # Was SURGESURFER
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SHADOWSNEAK],[1,:LEER],[5,:PURSUIT],[9,:FAKETEARS],
                     [13,:SNARL],[17,:BITTERMALICE],[21,:SCARYFACE],[25,:TAUNT],
                     [29,:SLASH],[33,:TORMENT],[37,:AGILITY],[41,:EMBARGO],
                     [45,:SHADOWCLAW],[49,:NASTYPLOT],[53,:IMPRISON],
                     [57,:NIGHTDAZE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Spiteful Fox")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A once-departed soul, returned to life in Hisui. Derives power from resentment, which rises as energy atop its head and takes on the forms of foes. In this way, Zorua vents lingering malice.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:ZOROARK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:NORMAL)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 16                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 730                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:ILLUSION),0],
         [getID(PBAbilities,:ILLUSION),1],
         [getID(PBAbilities,:ILLUSION),2]] if pokemon.form==1 # Was SURGESURFER
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:SHADOWBALL],[1,:SHADOWSNEAK],[1,:LEER],[5,:PURSUIT],
                     [9,:FAKETEARS],[13,:SNARL],[17,:BITTERMALICE],
                     [21,:SCARYFACE],[25,:TAUNT],[29,:SLASH],[34,:TORMENT],
                     [39,:AGILITY],[44,:EMBARGO],[49,:SHADOWCLAW],
                     [54,:NASTYPLOT],[59,:IMPRISON],[64,:NIGHTDAZE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Baneful Fox")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("With its disheveled white fur, it looks like an embodiment of death. Heedless of its own safety, Zoroark attacks its nemeses with a bitter energy so intense, it lacerates Zoroark's own body.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


MultipleForms.register(:YAMASK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:GROUND)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:GHOST)  # Alola
   else;   next 
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:ASTONISH],[1,:PROTECT],[4,:HAZE],[8,:NIGHTSHADE],
                     [12,:DISABLE],[16,:WILLOWISP],[20,:CRAFTYSHIELD],[24,:HEX],
                     [28,:MEANLOOK],[32,:GRUDGE],[36,:CURSE],[40,:SHADOWBALL],
                     [44,:DARKPULSE],[48,:POWERSPLIT],[48,:GUARDSPLIT],
                     [52,:DESTINYBOND]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A clay slab with cursed engravings took possession of a Yamask. The slab is said to be absorbing the Yamask's dark power.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:SAFEGUARD,:REST,:ROCKSLIDE,:THIEF,:SNORE,:PROTECT,:ATTRACT,:SANDSTORM,
             :RAINDANCE,:WILLOWISP,:FACADE,:IMPRISON,:FAKETEARS,:ROCKTOMB,
             :PAYBACK,:TRICKROOM,:WONDERROOM,:ROUND,:HEX,:BRUTALSWING,:EARTHQUAKE,
             :PSYCHIC,:SUBSTITUTE,:ENDURE,:SLEEPTALK,:SHADOWBALL,:TRICK,
             :SKILLSWAP,:IRONDEFENSE,:CALMMIND,:TOXICSPIKES,:DARKPULSE,
             :ENERGYBALL,:EARTHPOWER,:NASTYPLOT,:ZENHEADBUTT,:ALLYSWITCH,
             :ASTONISH,:HAZE,:NIGHTSHADE,:DISABLE,:CRAFTYSHIELD,:MEANLOOK,:GRUDGE,
             :CURSE,POWERSPLIT,:GUARDSPLIT,:DESTINYBOND,:POLTERGEIST]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})
MultipleForms.register(:STUNFISK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:GROUND)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==2
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; next getID(PBTypes,:STEEL)  # Alola (Was Steel)
   else;   next 
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 2; 205                          # Alola
   else;   next 
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 2; next [109,81,99,32,66,84] # Sandy Cloak
   else next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form<2                   
   next [[getID(PBAbilities,:MIMICRY),0]]
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[]
   case pokemon.form
   when 2; movelist=[[1,:MUDSLAP],[1,:TACKLE],[1,:WATERGUN],[1,:METALCLAW],
                     [5,:ENDURE],[10,:MUDSHOT],[15,:REVENGE],[20,:METALSOUND],
                     [25,:SUCKERPUNCH],[30,:IRONDEFENSE],[35,:BOUNCE],
                     [40,:MUDDYWATER],[45,:SNAPTRAP],[50,:FLAIL],[55,:FISSURE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Living in mud with a high iron content has given it a strong steel body.") if pokemon.form==2 # Eternal
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=2
   movelist=[:THUNDERWAVE,:DIG,:SCREECH,:REST,:ROCKSLIDE,:SNORE,:PROTECT,:ATTRACT,
             :SANDSTORM,:RAINDANCE,:FACADE,:REVENGE,:ROCKTOMB,:BOUNCE,:MUDSHOT,
             :PAYBACK,:ICEFANG,:ROUND,:BULLDOZE,:STOMPINGTANTRUM,:SURF,
             :EARTHQUAKE,:SUBSTITUTE,:SLUDGEBOMB,:ENDURE,:SLEEPTALK,:CRUNCH,
             :UPROAR,:MUDDYWATER,:IRONDEFENSE,:EARTHPOWER,:FLASHCANNON,:STONEEDGE,
             :STEALTHROCK,:SLUDGEWAVE,:FOULPLAY,:SCALD,:MUDSLAP,:TACKLE,:WATERGUN,
             :METALCLAW,:METALSOUND,:SUCKERPUNCH,:SNAPTRAP,:FLAIL,:FISSURE,
             :TERRAINPULSE,:LASHOUT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 2 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Galar
   next 2
}
})

MultipleForms.register(:RUFFLET,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FLYING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 5                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 110                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:KEENEYE),0],
         [getID(PBAbilities,:SHEERFORCE),1],
         [getID(PBAbilities,:TINTEDLENS),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [75,55,45,50,80,45] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:PECK],[1,:LEER],[5,:FURYATTACK],[10,:WINGATTACK],
                     [14,:HONECLAWS],[19,:SCARYFACE],[23,:AERIALACE],
                     [28,:ESPERWING],[28,:SLASH],[32,:DEFOG],[37,:TAILWIND],
                     [41,:AIRSLASH],[46,:CRUSHCLAW],[50,:SKYDROP],[55,:WHIRLWIND],
                     [59,:BRAVEBIRD],[64,:THRASH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Eaglet")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its chick-like looks belie its hotheadedness. It challenges its parents at every opportunity, desperate to prove its strength.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:BRAVIARY,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FLYING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 17                           # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 434                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:KEENEYE),0],
         [getID(PBAbilities,:SHEERFORCE),1],
         [getID(PBAbilities,:TINTEDLENS),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [110,83,70,65,112,70] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:SUPERPOWER],[1,:PECK],[1,:LEER],[5,:FURYATTACK],
                     [10,:WINGATTACK],[14,:HONECLAWS],[19,:SCARYFACE],
                     [23,:AERIALACE],[28,:ESPERWING],[28,:SLASH],[32,:DEFOG],
                     [37,:TAILWIND],[41,:AIRSLASH],[46,:CRUSHCLAW],
                     [50,:SKYDROP],[57,:WHIRLWIND],[63,:BRAVEBIRD],[70,:THRASH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Battle Cry")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Screaming a bloodcurdling battle cry, this huge and ferocious bird Pokémon goes out on the hunt. It blasts lakes with shock waves, then scoops up any prey that float to the water's surface.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


########################################
# Generation VI
########################################

MultipleForms.register(:SPRITZEE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Unique Horn") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:HAIL],
                     [10,:FAIRYWIND],[10,:AURORAVEIL],[15,:LASERFOCUS],
                     [15,:FREEZEDRY],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:MAGICSTORM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When Spritzee was found in the snow, something accidentally happened, leading into this form.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:AROMATISSE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0           # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Frozen Fairy") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:HAIL],
                     [10,:FAIRYWIND],[10,:AURORAVEIL],[15,:LASERFOCUS],
                     [15,:FREEZEDRY],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:MAGICSTORM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After evolving into this form, it suddenly turned out to be green. It is unknown how this happened.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:SWIRLIX,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   when 2; next getID(PBTypes,:GHOST)
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   when 2; next getID(PBTypes,:GHOST)
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
   next 0 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:ANTIFOGGER),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==2
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Snowball") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ICEPUNCH],
                     [10,:FAIRYWIND],[10,:HAIL],[15,:LASERFOCUS],
                     [15,:ICEHAMMER],[20,:LIGHTBALL],[20,:MIST],
                     [30,:POUND],[38,:HERBSLAM]]
   when 2; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:NIGHTSHADE],
                     [10,:LIGHTBALL],[15,:CONFUSERAY],[20,:MOONBLAST],
                     [25,:SHADOWPUNCH],[30,:REVELATIONDANCE],[35,:DESTINYBOND],
                     [40,:DRAGONBREATH],[45,:MISTYTERRAIN],[45,:DREAMYRECOVERCY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This swirlix seems to be fully uncovered with ice. It seems that it lost its tail to transform into a snowball.") if pokemon.form==1 # Eternal
   next _INTL("Scaring other People seems the intention why this Swirlix may give some Glimsery Treats to the others. Why this one happens is unknown.") if pokemon.form==2
},
"getFormOnCreation"=>proc{|pokemon|
   next [1,2][rand(2)] if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 2 # Mysterical
   end
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:SLURPUFF,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   when 2; next getID(PBTypes,:GHOST)
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   when 2; next getID(PBTypes,:GHOST)
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
   next 0 if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:ANTIFOGGER),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==2
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Frozen Yoghurt") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ICEPUNCH],
                     [10,:FAIRYWIND],[10,:HAIL],[15,:LASERFOCUS],
                     [15,:ICEHAMMER],[20,:LIGHTBALL],[20,:MIST],
                     [30,:POUND],[38,:HERBSLAM]]
   when 2; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:NIGHTSHADE],
                     [10,:LIGHTBALL],[15,:CONFUSERAY],[20,:MOONBLAST],
                     [25,:SHADOWPUNCH],[30,:REVELATIONDANCE],[35,:DESTINYBOND],
                     [40,:DRAGONBREATH],[45,:MISTYTERRAIN],[45,:DREAMYRECOVERCY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After being evolved, its sudden transformation into a frozen yoghurt seems unknown.") if pokemon.form==1 # Eternal
   next _INTL("This is the form that Slurpuff takes when Swirlix was traded while holding a Genie ball. What made this possible is unknown.") if pokemon.form==2
},
"getFormOnCreation"=>proc{|pokemon|
   next [1,2][rand(2)] if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 2 # Mysterical
   end
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:GOOMY,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DRAGON)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 3                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 28                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SAPSIPPER),0],
         [getID(PBAbilities,:SHELLARMOR),1],
         [getID(PBAbilities,:GOOEY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [35,50,65,20,55,75] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:BUBBLE],[5,:ABSORB],[9,:PROTECT],
                     [13,:ACIDARMOR],[18,:DRAGONBREATH],[25,:RAINDANCE],
                     [28,:SHELTER],[32,:BODYSLAM],[38,:MUDDYWATER],
                     [42,:DRAGONPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Snail")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Goomy hides away in the shade of trees, where it's nice and humid. If the slime coating its body dries out, the Pokémon instantly becomes lethargic.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:SLIGGOO,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DRAGON)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 8                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 175                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SAPSIPPER),0],
         [getID(PBAbilities,:SHELLARMOR),1],
         [getID(PBAbilities,:GOOEY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [58,75,83,40,83,113] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:ACIDSPRAY],[1,:TACKLE],[1,:BUBBLE],[5,:ABSORB],
                     [9,:PROTECT],[13,:ACIDARMOR],[18,:DRAGONBREATH],
                     [25,:RAINDANCE],[28,:SHELTER],[32,:BODYSLAM],
                     [38,:MUDDYWATER],[47,:DRAGONPULSE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Snail")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A creature given to melancholy. I suspect its metallic shell developed as a result of the mucus on its skin reacting with the iron in Hisui's water.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:GOODRA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DRAGON)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 27                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 6415                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SAPSIPPER),0],
         [getID(PBAbilities,:SHELLARMOR),1],
         [getID(PBAbilities,:GOOEY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [80,100,100,60,110,150] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:AQUATAIL],[1,:ACIDSPRAY],[1,:TACKLE],[1,:BUBBLE],
                     [5,:ABSORB],[9,:PROTECT],[13,:ACIDARMOR],[18,:DRAGONBREATH],
                     [25,:RAINDANCE],[28,:SHELTER],[32,:BODYSLAM],
                     [38,:MUDDYWATER],[47,:DRAGONPULSE],[50,:POWERWHIP],
                     [55,:OUTRAGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Shell Bunker")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Able to freely control the hardness of its metallic shell. It loathes solitude and is extremely clingy—it will fume and run riot if those dearest to it ever leave its side.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:PHANTUMP,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:PHANTOMFORCE],
                     [10,:LIGHTBALL],[15,:MAGMATRIIVERSE],[20,:MOONBLAST],
                     [25,:CURSE],[30,:REVELATIONDANCE],[35,:FIREBLAST],
                     [40,:DRAGONBREATH],[45,:ELECTRICTERRAIN],[45,:LAVAOVER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:PHANTOMSPIRIT),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Phantump is capable of learning up to 500.000 tricks a year. Still deos have the ability to frisk the people if they wanted to do it so.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:TREVENANT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GHOST)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:PHANTOMFORCE],
                     [10,:LIGHTBALL],[15,:MAGMATRIIVERSE],[20,:MOONBLAST],
                     [25,:CURSE],[30,:REVELATIONDANCE],[35,:FIREBLAST],
                     [40,:DRAGONBREATH],[45,:ELECTRICTERRAIN],[45,:LAVAOVER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:PHANTOMSPIRIT),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This tree wears its fiery clothes. But it can still take down foes if this Trevenant becomes angry.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:BERGMITE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 10                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 900                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:STRONGJAW),0],
         [getID(PBAbilities,:ICEBODY),1],
         [getID(PBAbilities,:STURDY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [55,79,85,38,22,25] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:BITE],[1,:HARDEN],[5,:POWDERSNOW],
                     [10,:ICYWIND],[15,:TAKEDOWN],[20,:SHARPEN],[22,:CURSE],
                     [26,:ICEFANG],[30,:ROLLOUT],[35,:RAPIDSPIN],[39,:ROCKSLIDE],
                     [43,:BLIZZARD],[47,:RECOVER],[49,:DOUBLEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Ice Chunk")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Lives on mountains blanketed in perennial snow. It freezes water vapor in the air to make the ice helmet that it dons for defense.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:AVALUGG,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ROCK)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 14                            # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 2786                          # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:STRONGJAW),0],
         [getID(PBAbilities,:ICEBODY),1],
         [getID(PBAbilities,:STURDY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [95,127,184,38,34,35] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:MOUNUTAINGALE],[1,:TACKLE],[1,:BITE],[1,:HARDEN],
                     [5,:POWDERSNOW],[10,:ICYWIND],[15,:TAKEDOWN],[20,:SHARPEN],
                     [22,:CURSE],[26,:ICEFANG],[30,:ROLLOUT],[35,:RAPIDSPIN],
                     [42,:ROCKSLIDE],[46,:BLIZZARD],[51,:RECOVER],
                     [56,:DOUBLEEDGE],[60,:SKYLLBASH],[65,:STONEEDGE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Iceberg")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The armor of ice covering its lower jaw puts steel to shame and can shatter rocks with ease. This Pokémon barrels along steep mountain paths, cleaving through the deep snow.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


########################################
# Generation VII
########################################

MultipleForms.register(:ROWLET,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 3;                             # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 15                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:OVERGROW),0],
         [getID(PBAbilities,:OVERGROW),1],
         [getID(PBAbilities,:SCRAPPY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [78,59,60,32,45,45] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:LEAFAGE],[4,:GROWL],[8,:PECK],[11,:ASTONISH],
                     [14,:RAZORLEAF],[16,:AERIALACE],[18,:FORESIGHT],[22,:PLUCK],
                     [25,:SYNTHESIS],[29,:AURASPHERE],[32,:SUCKERPUNCH],
                     [36,:LEAFBLADE],[39,:FEATHERDANCE],[43,:BRAVEBIRD],
                     [46,:NASTYPLOT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Grass Quil")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Flies noiselessly on delicate wings. It has mastered the art of deftly launching dagger-sharp feathers from those same wings.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:DARTRIX,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 7;                             # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 16                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:OVERGROW),0],
         [getID(PBAbilities,:OVERGROW),1],
         [getID(PBAbilities,:SCRAPPY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [88,80,80,42,65,65] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:TRIPLEARROWS],[1,:TACKLE],[1,:LEAFAGE],[4,:GROWL],
                     [8,:PECK],[11,:ASTONISH],[14,:RAZORLEAF],[16,:AERIALACE],
                     [19,:FORESIGHT],[24,:PLUCK],[28,:SYNTHESIS],[33,:AURASPHERE],
                     [37,:SUCKERPUNCH],[42,:LEAFBLADE],[46,:FEATHERDANCE],
                     [51,:BRAVEBIRD],[55,:NASTYPLOT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Blade Quil")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Regularly basks in sunlight to gather power—presumably due to the frigid climate. Nonetheless, the edges of the blade quills set into its wings are keen as ever.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})

MultipleForms.register(:DECIDUEYE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GRASS)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 7;                             # Alola
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; 16                           # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:OVERGROW),0],
         [getID(PBAbilities,:OVERGROW),1],
         [getID(PBAbilities,:SCRAPPY),2]] if pokemon.form==1 # Was SURGESURFER
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [88,112,80,60,95,95] # Sandy Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:ROCKSMASH],[1,:TRIPLEARROWS],[1,:TACKLE],[1,:LEAFAGE],
                     [4,:GROWL],[8,:PECK],[11,:ASTONISH],[14,:RAZORLEAF],
                     [16,:AERIALACE],[19,:FORESIGHT],[24,:PLUCK],[28,:SYNTHESIS],
                     [33,:AURASPHERE],[38,:SUCKERPUNCH],[44,:LEAFBLADE],
                     [49,:FEATHERDANCE],[55,:BRAVEBIRD],[60,:NASTYPLOT]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=1
   next _INTL("Arrow Quill")
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The air stored inside the rachises of Decidueye's feathers insulates the Pokémon against Hisui's extreme cold. This is firm proof that evolution can be influenced by environment.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
#   next 1 if rand(65536)<$REGIONALCOMBO
   next 0 unless env==PBEnvironment::Hisui
   next 1
}
})


MultipleForms.register(:FOMANTIS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Steely Spirit") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:STEELWING],
                     [10,:FAIRYWIND],[10,:ICEFANG],[15,:LASERFOCUS],
                     [15,:METALSOUND],[20,:LIGHTBALL],[20,:ICEBALL],
                     [30,:POUND],[38,:DOOMSURPLETE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Possesing out in the steely spirit, this Fomantis appears to be snowed under a powder snow.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:LURANTIS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:STEEL)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Doomy Snowy") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:STEELWING],
                     [10,:FAIRYWIND],[10,:ICEFANG],[15,:LASERFOCUS],
                     [15,:METALSOUND],[20,:LIGHTBALL],[20,:ICEBALL],
                     [30,:POUND],[38,:DOOMSURPLETE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After attaining this evolution, no one knows where the steely spirit went.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:MORELULL,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:FIREPUNCH],
                     [10,:FAIRYWIND],[10,:ICEPUNCH],[15,:LASERFOCUS],
                     [15,:SUNNYDAY],[20,:LIGHTBALL],[20,:FREEZEDRY],
                     [30,:POUND],[38,:LAVAOVER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Morelull appears to use the Fire spirit in addition to the Ice spirit. Why that happens is unkwnown.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:SHIINOTIC,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:FIREPUNCH],
                     [10,:FAIRYWIND],[10,:ICEPUNCH],[15,:LASERFOCUS],
                     [15,:SUNNYDAY],[20,:LIGHTBALL],[20,:FREEZEDRY],
                     [30,:POUND],[38,:LAVAOVER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A Shinnotic of the Phonetic appears to be the solo worker in the Fiery and Lava carvens, in addition to the now called Icey Spirit.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:BRUXISH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola (Fairy)
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:DARK)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:AROMATICMIST],
                     [10,:LIGHTBALL],[15,:TOPSYDAMAGE],[20,:MOONBLAST],
                     [25,:CASANOVA],[30,:REVELATIONDANCE],[35,:TAUNT],
                     [40,:DRAGONBREATH],[45,:KHLERI],[45,:BRAINOLOGIC]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:MINDYGLOPS),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Under what circumstances should Bruxish dodge attacks. It seems that it had bounced back several attacks years ago.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


########################################
# Generation VIII
########################################

MultipleForms.register(:GROOKEY,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:STATIC),0],
    #    [getID(PBAbilities,:TECHNICIAN),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:SCRATCH],[1,:SPARK],[5,:QUICKATTACK],
                     [10,:KARATECHOP],[15,:SILVERYBLISS],[20,:THUNDERWAVE],
                     [25,:DOUBLEHIT],[30,:BULKUP],[35,:METRONOME],
                     [40,:LIGHTBALL],[45,:MASCUGLASS],[50,:BODYPRESS],
                     [55,:CINAMENT],[55,:BOLTYDREAM],[60,:ELECTRICTERRAIN],
                     [65,:BOLTOPIA],[70,:QUICKGUARD],[75,:BOLTYSNIPE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:THWACKEY,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:STATIC),0],
         [getID(PBAbilities,:TECHNICIAN),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:BRICKBREAK],[1,:SCRATCH],[1,:SPARK],[1,:QUICKATTACK],
                     [1,:KARATECHOP],[1,:SILVERYBLISS],[21,:THUNDERWAVE],
                     [27,:DOUBLEHIT],[33,:BULKUP],[39,:METRONOME],
                     [45,:LIGHTBALL],[51,:MASCUGLASS],[57,:BODYPRESS],
                     [63,:CINAMENT],[63,:BOLTYDREAM],[69,:ELECTRICTERRAIN],
                     [75,:BOLTOPIA],[81,:QUICKGUARD],[87,:BOLTYSNIPE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:RILLABOOM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:STATIC),0],
         [getID(PBAbilities,:TECHNICIAN),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:JELLYWAVE],
                     [1,:BRICKBREAK],[1,:SCRATCH],[1,:SPARK],[1,:QUICKATTACK],
                     [1,:KARATECHOP],[1,:SILVERYBLISS],[1,:THUNDERWAVE],
                     [1,:DOUBLEHIT],[1,:BULKUP],[40,:METRONOME],
                     [47,:LIGHTBALL],[54,:MASCUGLASS],[61,:BODYPRESS],
                     [68,:CINAMENT],[68,:BOLTYDREAM],[75,:ELECTRICTERRAIN],
                     [82,:BOLTOPIA],[89,:QUICKGUARD],[96,:BOLTYSNIPE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:SCORBUNNY,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SYNCHRONIZE),0],
    #    [getID(PBAbilities,:POISONTOUCH),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:HYPNOSIS],[5,:QUICKATTACK],
                     [10,:POISONAS],[15,:SILVERYBLISS],[20,:PSYCHOSLASH],
                     [25,:DOUBLEHIT],[30,:SODASWAMP],[35,:METRONOME],
                     [40,:PSYCHICTERRAIN],[45,:MESCUGLESS],[50,:TOXIC],
                     [55,:CINAMENT],[55,:BOLTYDREAM],[60,:PSYCHICFANGS],
                     [65,:BOLTOPIA],[70,:GALINSPOISON],[75,:DREAMTOPIA]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:RABOOT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SYNCHRONIZE),0],
         [getID(PBAbilities,:POISONTOUCH),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:POISONJAB],[1,:TACKLE],[1,:HYPNOSIS],[1,:QUICKATTACK],
                     [1,:POISONAS],[1,:SILVERYBLISS],[21,:PSYCHOSLASH],
                     [27,:DOUBLEHIT],[33,:SODASWAMP],[39,:METRONOME],
                     [45,:PSYCHICTERRAIN],[51,:MESCUGLESS],[57,:TOXIC],
                     [63,:CINAMENT],[63,:BOLTYDREAM],[69,:PSYCHICFANGS],
                     [75,:BOLTOPIA],[81,:GALINSPOISON],[87,:DREAMTOPIA]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:CINDERACE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:PSYCHIC)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 7 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SYNCHRONIZE),0],
         [getID(PBAbilities,:POISONTOUCH),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Toxic Striker") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:MARINEGASTRO],
                     [1,:POISONJAB],[1,:TACKLE],[1,:HYPNOSIS],[1,:QUICKATTACK],
                     [1,:POISONAS],[1,:SILVERYBLISS],[1,:PSYCHOSLASH],
                     [1,:DOUBLEHIT],[1,:SODASWAMP],[40,:METRONOME],
                     [47,:PSYCHICTERRAIN],[54,:MESCUGLESS],[61,:TOXIC],
                     [68,:CINAMENT],[68,:BOLTYDREAM],[75,:PSYCHICFANGS],
                     [82,:BOLTOPIA],[89,:GALINSPOISON],[96,:DREAMTOPIA]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:SOBBLE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CUTECHARM),0],
    #    [getID(PBAbilities,:SANDFORCE),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Fairy Lizard") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[1,:FAIRYWIND],[5,:QUICKATTACK],
                     [10,:TECHNICBROS],[15,:SILVERYBLISS],[20,:AROMATICMIST],
                     [25,:DOUBLEHIT],[30,:SHOREUP],[35,:METRONOME],
                     [40,:CASANOVA],[45,:MOSCUGLOSS],[50,:SANDTOMB],
                     [55,:CINAMENT],[55,:BOLTYDREAM],[60,:MISTYTERRAIN],
                     [65,:BOLTOPIA],[70,:SANDATTACK],[75,:FAIRYFORCE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:DRIZZILE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CUTECHARM),0],
         [getID(PBAbilities,:SANDFORCE),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Fairy Lizard") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:MAGNITUDE],[1,:TACKLE],[1,:FAIRYWIND],[1,:QUICKATTACK],
                     [1,:TECHNICBROS],[1,:SILVERYBLISS],[21,:AROMATICMIST],
                     [27,:DOUBLEHIT],[33,:SHOREUP],[39,:METRONOME],
                     [45,:CASANOVA],[51,:MOSCUGLOSS],[57,:SANDTOMB],
                     [63,:CINAMENT],[63,:BOLTYDREAM],[69,:MISTYTERRAIN],
                     [75,:BOLTOPIA],[81,:SANDATTACK],[87,:FAIRYFORCE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:INTELEON,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FAIRY)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:CUTECHARM),0],
         [getID(PBAbilities,:SANDFORCE),1],
         [getID(PBAbilities,:METRONOME),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Sharpen Agent") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[0,:TRIFFINTO],
                     [1,:MAGNITUDE],[1,:TACKLE],[1,:FAIRYWIND],[1,:QUICKATTACK],
                     [1,:TECHNICBROS],[1,:SILVERYBLISS],[1,:AROMATICMIST],
                     [1,:DOUBLEHIT],[1,:SHOREUP],[40,:METRONOME],
                     [47,:CASANOVA],[54,:MOSCUGLOSS],[61,:SANDTOMB],
                     [68,:CINAMENT],[68,:BOLTYDREAM],[75,:MISTYTERRAIN],
                     [82,:BOLTOPIA],[89,:SANDATTACK],[96,:FAIRYFORCE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[399]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:GOSSIFLEUR,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ICEPUNCH],
                     [10,:FAIRYWIND],[10,:HAIL],[15,:LASERFOCUS],
                     [15,:AURORAVEIL],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:GENIEDREAM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("In the heart of the ice, Gossifleur was accidentaly got freezed by the Phonetic Spirit. Who knows that fact?.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:ELDEGOSS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ICEPUNCH],
                     [10,:FAIRYWIND],[10,:HAIL],[15,:LASERFOCUS],
                     [15,:AURORAVEIL],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:GENIEDREAM]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("When this Gossifleur evolved into an Eldegoss, its Moon Power was came true. We don't know why this happened?") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:CLOBBOPUS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Aurora Tantrum") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:BRICKBREAK],
                     [10,:FAIRYWIND],[10,:ICYWIND],[15,:LASERFOCUS],
                     [15,:SUBMISSION],[20,:LIGHTBALL],[20,:ICEPUNCH],
                     [30,:POUND],[38,:JELLYPLODER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Clobbopus appears to be have covered with snow. However, it still fights with other species despite have known how to snow things.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:GRAPPLOCT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIGHTING)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Jellylicious Snowman") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:BRICKBREAK],
                     [10,:FAIRYWIND],[10,:ICYWIND],[15,:LASERFOCUS],
                     [15,:SUBMISSION],[20,:LIGHTBALL],[20,:ICEPUNCH],
                     [30,:POUND],[38,:JELLYPLODER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After a Phonetican Clobbopus evolves into this Grapploct, it starts licking too much jelly in order to cast a huge Jellylicious Bomb, known as Jelly Ploder.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:PINCURCHIN,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Alola
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GLIMSETREAT],[1,:LEER],[5,:EMBER],
                     [10,:LIGHTBALL],[15,:FIREPUNCH],[20,:MOONBLAST],
                     [25,:FLAMETHROWER],[30,:REVELATIONDANCE],[35,:SUNNYDAY],
                     [40,:DRAGONBREATH],[45,:PSYCHICTERRAIN],[45,:MIMIC]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:PHOTONFORCE),0],
         [getID(PBAbilities,:ADAPTABILITY),1],
         [getID(PBAbilities,:BEASTBOOST),2]] if pokemon.form==1
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps2=[394]   # Map IDs for Eternal Forme
   if $game_map && maps2.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:CUFANT,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [72,80,49,35,49,45] # Sandy 
   else;   next 
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ELECTROBALL],
                     [10,:FAIRYWIND],[10,:ICEBALL],[15,:LASERFOCUS],
                     [15,:ELECTROMANIA],[20,:LIGHTBALL],[20,:COLDWATER],
                     [30,:POUND],[38,:LOVELYBLISS]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("When this Gossifleur evolved into an Eldegoss, its Moon Power was came true. We don't know why this happened?") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:COPPERAJAH,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ELECTRIC)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [122,130,69,35,80,64] # Sandy 
   else;   next 
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("Icy Flower") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:ELECTROBALL],
                     [10,:FAIRYWIND],[10,:ICEBALL],[15,:LASERFOCUS],
                     [15,:ELECTROMANIA],[20,:LIGHTBALL],[20,:COLDWATER],
                     [30,:POUND],[38,:LOVELYBLISS]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
#   next _INTL("When this Gossifleur evolved into an Eldegoss, its Moon Power was came true. We don't know why this happened?") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

########################################
# Generation IX
########################################

MultipleForms.register(:SHROODLE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Icy Mouse") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form

   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:POISONFANG],
                     [10,:FAIRYWIND],[10,:ICEBALL],[15,:LASERFOCUS],
                     [15,:TOXICSWAMP],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:AFROFUMES]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Shroodle appears to be covered in both Ice and Poison. Who know what was the cause of this?") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:GRAFAIAI,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:ICE)  # Alola
   else;   next 
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Kanto
   case pokemon.form
   when 1; next getID(PBTypes,:POISON)  # Alola
   else;   next 
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   
   next [[getID(PBAbilities,:SHEERCOLD),0],
         [getID(PBAbilities,:SLUSHRUSH),2]] if pokemon.form==1
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Icy Monkey") if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1
   movelist=[]
   case pokemon.form

   when 1; movelist=[[1,:POWDERSNOW],[1,:AROMATICMIST],[5,:SWIFT],[5,:POISONFANG],
                     [10,:FAIRYWIND],[10,:ICEBALL],[15,:LASERFOCUS],
                     [15,:TOXICSWAMP],[20,:LIGHTBALL],[20,:ICYWIND],
                     [30,:POUND],[38,:AFROFUMES]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After evolution, it evolved into this new Monkey Pokémon known as Grafaiai. This variant of Grafaiai was found recently by an MTV and a Crabominable.") if pokemon.form==1 # Eternal
},
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(65536)<$REGIONALCOMBO
   maps=[391]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


################################################################################
# Other Forms (Ordinal Pokemon)
################################################################################

########################################
# Generation I
########################################

# None currently

########################################
# Generation II
########################################

MultipleForms.register(:UNOWN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(28)
}
})

########################################
# Generation III
########################################

MultipleForms.register(:SPINDA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbSpindaSpots(pokemon,bitmap)
}
})

MultipleForms.register(:CASTFORM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Sunny Form
   when 2; next getID(PBTypes,:WATER) # Rainy Form
   when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0            # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Sunny Form
   when 2; next getID(PBTypes,:WATER) # Rainy Form
   when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==3
   next 0 if pokemon.form==1
   next 1 if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("This is the form Castform takes on the brightest of days. Its skin is unexpectedly hot to the touch, so approach with care") if pokemon.form==1
   next _INTL("This is the form Castform takes when soaked with rain. When its body is compressed, water will seep out as if form a sponge") if pokemon.form==2
   next _INTL("This is the form Castform takes when covered in snow. Its body becomes an ice-like material, with a temperature near 23 degrees Fahrenheit") if pokemon.form==3
}
})

MultipleForms.register(:DEOXYS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0               # Normal Forme
   case pokemon.form
   when 1; next [50,180, 20,150,180, 20] # Attack Forme
   when 2; next [50, 70,160, 90, 70,160] # Defense Forme
   when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0    # Normal Forme
   case pokemon.form
   when 1; next [0,2,0,0,1,0] # Attack Forme
   when 2; next [0,0,2,0,0,1] # Defense Forme
   when 3; next [0,0,0,3,0,0] # Speed Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                     [25,:TAUNT],[33,:PURSUIT],[41,:PSYCHIC],[49,:SUPERPOWER],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:COSMICPOWER],
                     [81,:ZAPCANNON],[89,:PSYCHOBOOST],[97,:HYPERBEAM]]
   when 2; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                     [25,:KNOCKOFF],[33,:SPIKES],[41,:PSYCHIC],[49,:SNATCH],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:IRONDEFENSE],
                     [73,:AMNESIA],[81,:RECOVER],[89,:PSYCHOBOOST],
                     [97,:COUNTER],[97,:MIRRORCOAT]]
   when 3; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:DOUBLETEAM],
                     [25,:KNOCKOFF],[33,:PURSUIT],[41,:PSYCHIC],[49,:SWIFT],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:AGILITY],
                     [81,:RECOVER],[89,:PSYCHOBOOST],[97,:EXTREMESPEED]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

########################################
# Generation IV
########################################

MultipleForms.register(:BURMY,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"getFormOnEnteringBattle"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("It creates a cloak by weaving together sand, mud, and silk it has spat out. This earthen cloak is ruined by wind and rain, so the Pokémon hides away in caves and other such places.") if pokemon.form==1
   next _INTL("When confronted by a lack of other materials, Burmy will create its cloak using dust and refuse. The cloak seems to be more comfortable than one would think.") if pokemon.form==2
}

})

MultipleForms.register(:WORMADAM,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
      env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Plant Cloak
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
   when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
   next 0 if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,79,105,36,59, 85] # Sandy Cloak
   when 2; next [60,69, 95,36,69, 95] # Trash Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0    # Plant Cloak
   case pokemon.form
   when 1; next [0,0,2,0,0,0] # Sandy Cloak
   when 2; next [0,0,1,0,0,1] # Trash Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                     [23,:CONFUSION],[26,:ROCKBLAST],[29,:HARDEN],[32,:PSYBEAM],
                     [35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],[44,:PSYCHIC],
                     [47,:FISSURE]]
   when 2; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                     [23,:CONFUSION],[26,:MIRRORSHOT],[29,:METALSOUND],
                     [32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],
                     [44,:PSYCHIC],[47,:IRONHEAD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[# TMs
                     :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
                     :PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,
                     :RETURN,:DIG,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,
                     :SANDSTORM,:ROCKTOMB,:FACADE,:REST,:ATTRACT,
                     :THIEF,:ROUND,:GIGAIMPACT,:FLASH,:STRUGGLEBUG,
                     :PSYCHUP,:BULLDOZE,:DREAMEATER,:SWAGGER,:SUBSTITUTE,
                     # Move Tutors
                     :BUGBITE,:EARTHPOWER,:ELECTROWEB,:ENDEAVOR,:MUDSLAP,
                     :SIGNALBEAM,:SKILLSWAP,:SLEEPTALK,:SNORE,:STEALTHROCK,
                     :STRINGSHOT,:SUCKERPUNCH,:UPROAR]
   when 2; movelist=[# TMs
                     :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
                     :PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,:RETURN,
                     :PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:FACADE,:REST,
                     :ATTRACT,:THIEF,:ROUND,:GIGAIMPACT,:FLASH,
                     :GYROBALL,:STRUGGLEBUG,:PSYCHUP,:DREAMEATER,:SWAGGER,
                     :SUBSTITUTE,:FLASHCANNON,
                     # Move Tutors
                     :BUGBITE,:ELECTROWEB,:ENDEAVOR,:GUNKSHOT,:IRONDEFENSE,
                     :IRONHEAD,:MAGNETRISE,:SIGNALBEAM,:SKILLSWAP,:SLEEPTALK,
                     :SNORE,:STEALTHROCK,:STRINGSHOT,:SUCKERPUNCH,:UPROAR,
                     :IRONCARB,:STEELBEAM]
   end
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Its earthen skin is reasonably hard—it has no problem repelling a Starly's pecking, at least.") if pokemon.form==1
   next _INTL("Its body, composed of refuse, blends in to the scenery so much as to be inconspicuous. This seems to be the perfect way for the Pokémon to evade the detection of predators.") if pokemon.form==2
}
})

MultipleForms.register(:CHERRIM,{
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 9 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("After absorbing plenty of sunlight, Cherrim takes this form. It's full of energy while it's like this, and its liveliness will go on until sundown") if pokemon.form==1
}
})


MultipleForms.register(:SHELLOS,{
"getFormOnCreation"=>proc{|pokemon|
   formrations= ($Trainer.isFemale?) ? [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1] : [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1]
   next formrations[rand(15)]
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("When it senses danger, it gushes a purple liquid. Some theories suggest this liquid is a greasy sweat induced by stress.") if pokemon.form==1
}
})

MultipleForms.register(:GASTRODON,{
"getFormOnCreation"=>proc{|pokemon|
   formrations= ($Trainer.isFemale?) ? [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1] : [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1]
   next formrations[rand(15)]
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("When it's attacked, it gushes a purple liquid that's not poisonous but makes Gastrodon's meat bitter and inedible.") if pokemon.form==1
}
})

MultipleForms.register(:ROTOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Normal Form
   next [50,65,107,86,105,107] # All alternate forms
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
   when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
   when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
   when 4; next getID(PBTypes,:FLYING) # Fan
   when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("This Rotom has possessed a convection microwave oven that uses a special motor. It also has a flair for manipulating flames.") if pokemon.form==1                    # Heat, Microwave
   next _INTL("This form of Rotom enjoys coming up with water-based pranks. Be careful with it if you don’t want your room flooded.") if pokemon.form==2                            # Wash, Washing Machine
   next _INTL("Rotom assumes this form when it takes over a refrigerator powered by a special motor. It battles by spewing cold air.") if pokemon.form==3                           # Frost, Refrigerator
   next _INTL("In this form, Rotom applies its new power over wind to its love of pranks. It will happily blow away any important documents it can find.") if pokemon.form==4       # Fan
   next _INTL("This is Rotom after it’s seized control of a lawn mower that has a special motor. As it mows down grass, it scatters the clippings everywhere.") if pokemon.form==5  # Mow, Lawnmower
},
"onSetForm"=>proc{|pokemon,form|
   moves=[
      :OVERHEAT,  # Heat, Microwave
      :HYDROPUMP, # Wash, Washing Machine
      :BLIZZARD,  # Frost, Refrigerator
      :AIRSLASH,  # Fan
      :LEAFSTORM  # Mow, Lawnmower
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if form>0
     newmove=moves[form-1]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename=PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove]=PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   else
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
       end
     end
   end
}
})

MultipleForms.register(:DIALGA,{
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 70                 # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 8487               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [100,100,120,90,150,120] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73,420,412,413,414,415,416,417,418,445,446]   # Map IDs for Origin Forme
   if isConst?(pokemon.item,PBItems,:ADAMANTORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Radiant light caused Dialga to take on a form bearing a striking resemblance to the creator Pokémon. Dialga now wields such colossal strength that one must conclude this is its true form.") if pokemon.form==1                    # Heat, Microwave
}
})

MultipleForms.register(:PALKIA,{
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 63                 # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6590               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [90,100,100,120,150,120] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73,420,412,413,414,415,416,417,418,445,446]   # Map IDs for Origin Forme
   if isConst?(pokemon.item,PBItems,:LUSTROUSORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("It soars across the sky in a form that greatly resembles the creator of all things. Perhaps this imitation of appearance is Palkia's strategy for gaining Arceus's powers.") if pokemon.form==1                    # Heat, Microwave
}
})

MultipleForms.register(:GIRATINA,{
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                  # Altered Forme
   next [[getID(PBAbilities,:LEVITATE),0],
         [getID(PBAbilities,:TELEPATHY),2]] # Origin Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 69                 # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,120,100,90,120,100,420,412,413,414,415,416,417,418,445,446] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73]   # Map IDs for Origin Forme
   if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Giratina loses its legs upon changing into this form. I believe this Pokémon must hail from a world where the heavens and the earth are as one, though I have no way of proving it.") if pokemon.form==1                    # Heat, Microwave
}
})

MultipleForms.register(:SHAYMIN,{
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Land Forme
   next getID(PBTypes,:FLYING) # Sky Forme
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                    # Land Forme
   next [[getID(PBAbilities,:SERENEGRACE),0]] # Sky Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 69                 # Sky Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 4                  # Sky Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,103,75,127,120,75] # Sky Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next [0,0,0,3,0,0]      # Sky Forme
},
"getForm"=>proc{|pokemon|
   next 0 if pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN ||
             PBDayNight.isNight?
   next nil
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
                     [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
                     [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
                     [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Upon taking in the scent of a particular rare flower, Shaymin is enveloped in light, and its tiny body transforms. I took a whiff of the flower myself, but alas, my body remained unchanged.") if pokemon.form==1                    # Heat, Microwave
}
})

MultipleForms.register(:ARCEUS,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,
          :DOOM,:JELLY,:SHARPENER,:lAVA,:WIND,
          :LICK,:BOLT,:HERB,:CHLORPHYLL,:GUST,
          :SUN,:MOON,:MIND,:HEART,:BLIZZARD,
          :GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,
          :DOOM,:JELLY,:SHARPENER,:lAVA,:WIND,
          :LICK,:BOLT,:HERB,:CHLORPHYLL,:GUST,
          :SUN,:MOON,:MIND,:HEART,:BLIZZARD,
          :GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE)
   next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE)
   next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
   next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
   next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE)
   next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
   next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
   next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE)
   next 9 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
   next 10 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
   next 11 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
   next 12 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
   next 13 if isConst?(pokemon.item,PBItems,:MINDPLATE)
   next 14 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
   next 15 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
   next 16 if isConst?(pokemon.item,PBItems,:DREADPLATE)
   next 17 if isConst?(pokemon.item,PBItems,:PIXIEPLATE)
  # FLINT
   next 18 if isConst?(pokemon.item,PBItems,:WIZARDPLATE)
   next 19 if isConst?(pokemon.item,PBItems,:BOMBPLATE)
   next 20 if isConst?(pokemon.item,PBItems,:JELLYLICIOUSPLATE)
   next 21 if isConst?(pokemon.item,PBItems,:GYROPLATE)
   next 22 if isConst?(pokemon.item,PBItems,:VOLCANOPLATE)
   next 23 if isConst?(pokemon.item,PBItems,:WHIRLWINDPLATE)
   next 24 if isConst?(pokemon.item,PBItems,:CANDLEPLATE)
   next 25 if isConst?(pokemon.item,PBItems,:CHARGINGPLATE)
   next 26 if isConst?(pokemon.item,PBItems,:BOTANICPLATE)
   next 27 if isConst?(pokemon.item,PBItems,:MENTALPLATE)
   next 28 if isConst?(pokemon.item,PBItems,:FISSIONPLATE)
   next 29 if isConst?(pokemon.item,PBItems,:SUNSHINEPLATE)
   next 30 if isConst?(pokemon.item,PBItems,:LUNARPLATE)
   next 31 if isConst?(pokemon.item,PBItems,:BRAINPLATE)
   next 32 if isConst?(pokemon.item,PBItems,:LOVEPLATE)
   next 33 if isConst?(pokemon.item,PBItems,:COLDPLATE)
   next 34 if isConst?(pokemon.item,PBItems,:CARBONPLATE)
   next 35 if isConst?(pokemon.item,PBItems,:GALAXYPLATE)

   next 0
}
})

########################################
# Generation V
########################################

MultipleForms.register(:BASCULIN,{
"getFormOnCreation"=>proc{|pokemon|
   next [rand(2),rand(2),3][rand(3)]
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                                       # Red-Striped
   next [[getID(PBAbilities,:ROCKHEAD),0],
         [getID(PBAbilities,:ADAPTABILITY),1],
         [getID(PBAbilities,:MOLDBREAKER),2]] if pokemon.form==1 # Blue-Striped
   next [[getID(PBAbilities,:RATTLED),0],
         [getID(PBAbilities,:ADAPTABILITY),1],
         [getID(PBAbilities,:MOLDBREAKER),2]] if pokemon.form==2 # White-Striped

},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                                    # Red-Striped
   next [0,getID(PBItems,:DEEPSEASCALE),0] if pokemon.form==1 # Blue-Striped
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Even Basculin, which devours everything it can with its huge jaws, is nothing more than food to organisms stronger than itself.") if pokemon.form==1
   next _INTL("Though it differs from other Basculin in several respects, including demeanor—this one is gentle—I have categorized it as a regional form given the vast array of shared qualities.") if pokemon.form==2
}
})

MultipleForms.register(:DEERLING,{
"getForm"=>proc{|pokemon|
   time=pbGetTimeNow
   next (time.month-1)%4
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("To prevent Deerling from entering their fields, many farmers will have several Lycanroc stand guard, as they are the natural enemy of Deerling.") if pokemon.form==1
   next _INTL("These Pokémon are not shy—they will behave as they please, even in front of people. If you feed one of them, it will quickly take a liking to you.") if pokemon.form==2
   next _INTL("Deerling’s scent changes with the seasons, but when the Pokémon is in its Winter Form, it has hardly any scent at all.") if pokemon.form==3
}
})

MultipleForms.register(:SAWSBUCK,{
"getForm"=>proc{|pokemon|
   time=pbGetTimeNow
   next (time.month-1)%4
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("There are many Sawsbuck enthusiasts. The thicker and larger the branches and leaves on its antlers, the more majestic the Sawsbuck is thought to be.") if pokemon.form==1
   next _INTL("There are many Sawsbuck enthusiasts. The darker the red of the foliage that hangs from its antlers, the more stylish the Sawsbuck is thought to be.") if pokemon.form==2
   next _INTL("It’s said that Sawsbuck are calm and easy to tame during the season when they take on this form, so it’s the perfect time to make one your partner.") if pokemon.form==3
}
})

MultipleForms.register(:TORNADUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,100,80,121,110,90] # Therian Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next 14                 # Therian Forme
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                    # Incarnate Forme
   next [[getID(PBAbilities,:REGENERATOR),0],
         [getID(PBAbilities,:DEFIANT),2]]     # Therian Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("An example of what is known as a “form change,” though I suspect this strange avian guise to be Tornadus's true form. Tornadus has been sighted crossing the ocean while in this form.") if pokemon.form==1
}
})

MultipleForms.register(:THUNDURUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,105,70,101,145,80] # Therian Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next 30                 # Therian Forme
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   # Incarnate Forme
   next [[getID(PBAbilities,:VOLTABSORB),0],
         [getID(PBAbilities,:DEFIANT),2]]    # Therian Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,0,3,0]      # Therian Forme
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Quick as a flash, it materializes out of nowhere. It pulverizes foes into nothingness with showers of devastatingly powerful lightning bolts launched from the string of orbs on its tail.") if pokemon.form==1
}
})

MultipleForms.register(:LANDORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0    # Incarnate Forme
   next [89,145,90,71,105,80] # Therian Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next 13                 # Therian Forme
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                   # Incarnate Forme
   next [[getID(PBAbilities,:INTIMIDATE),0],
         [getID(PBAbilities,:SHEERFORCE),2]] # Therian Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,3,0,0,0,0]      # Therian Forme
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Landorus soars through the sky in this form, bestowing plentiful harvests upon the land and earning the people's reverence. It can traverse the whole of Hisui in a mere couple of hours.") if pokemon.form==1
}
})

MultipleForms.register(:KYUREM,{
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
   when 1; next [125,120, 90,95,170,100] # White Kyurem
   when 2; next [125,170,100,95,120, 90] # Black Kyurem
   else;   next                          # Kyurem
   end
},
"height"=>proc{|pokemon|
   case pokemon.form
   when 1; next 36 # White Kyurem
   when 2; next 33 # Black Kyurem
   else;   next    # Kyurem
   end
},
"getAbilityList"=>proc{|pokemon|
   case pokemon.form
   when 1; next [[getID(PBAbilities,:PRESSURE),0],
                 [getID(PBAbilities,:TURBOBLAZE),2]] # White Kyurem
   when 2; next [[getID(PBAbilities,:PRESSURE),0],
                 [getID(PBAbilities,:TERAVOLT),2]]   # Black Kyurem
   else;   next                                      # Kyurem
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
   when 1; next [0,0,0,0,3,0] # White Kyurem
   when 2; next [0,3,0,0,0,0] # Black Kyurem
   else;   next               # Kyurem
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                     [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                     [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
                     [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                     [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                     [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                     [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
                     [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                     [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("The sameness of Reshiram’s and Kyurem’s genes allowed Kyurem to absorb Reshiram. Kyurem can now use the power of both fire and ice.") if pokemon.form==1
   next _INTL("It’s said that this Pokémon battles in order to protect the ideal world that will exist in the future for people and Pokémon.") if pokemon.form==2
}
})

MultipleForms.register(:KELDEO,{
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
   next 0                                     # Ordinary Form
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Keldeo has strengthened its resolve for battle, filling its body with power and changing its form.") if pokemon.form==1
}
})

MultipleForms.register(:MELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,128,90,128,77,77] # Pirouette Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:FIGHTING) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,1,1,1,0,0]      # Pirouette Forme
}
})

MultipleForms.register(:GENESECT,{
"getForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
   next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
   next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
   next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
   next 0
}
})

########################################
# Generation VI
########################################

MultipleForms.register(:SCATTERBUG,{
"getFormOnCreation"=>proc{|pokemon|
#  ret=$Trainer.secretID%18
   ret=pokemon.personalID&3
   ret|=((pokemon.personalID>>8)&3)<<2
   ret|=((pokemon.personalID>>16)&3)<<4
   ret|=((pokemon.personalID>>24)&3)<<6
   ret%=18
   r=rand(1000)
   if r < 30
     ret=[18,19][rand(2)] # 3% chance of having Fancy or PokeBall Pattern
   end
   next ret
},
})

MultipleForms.copy(:SCATTERBUG,:SPEWPA)

MultipleForms.register(:VIVILLON,{
"getFormOnCreation"=>proc{|pokemon|
#  ret=$Trainer.secretID%18
   ret=pokemon.personalID&3
   ret|=((pokemon.personalID>>8)&3)<<2
   ret|=((pokemon.personalID>>16)&3)<<4
   ret|=((pokemon.personalID>>24)&3)<<6
   ret%=18
   r=rand(1000)
   if r < 30
     ret=[18,19][rand(2)] # 3% chance of having Fancy or PokeBall Pattern
   end
   next ret
},
"dexEntry"=>proc{|pokemon|
   next                                                                                                                                                           if pokemon.form==0 
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from snowy lands.")                     if pokemon.form==1
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands of severe cold.")            if pokemon.form==2
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands of vast space.")             if pokemon.form==3
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from verdant lands.")                   if pokemon.form==4
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands with distinct seasons.")     if pokemon.form==5
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands where flowers bloom.")       if pokemon.form==6
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from sun-drenched lands.")              if pokemon.form==7
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands with ocean breezes.")        if pokemon.form==8
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from places with many islands.")        if pokemon.form==9
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands with little rain.")          if pokemon.form==10
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from parched lands.")                   if pokemon.form==11
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands where large rivers flow.")   if pokemon.form==12
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands with intense rainfall.")     if pokemon.form==13
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands with a tropical climate.")   if pokemon.form==14
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands bathed in light.")           if pokemon.form==15
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands of perpetual summer.")       if pokemon.form==16
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from lands of tropical rain forests.")  if pokemon.form==17
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from a mysterious land.")               if pokemon.form==18
   next _INTL("The patterns on this Pokémon depend on the climate and topography of the land it was born in. This form is from a special land.")                  if pokemon.form==19
}
})


MultipleForms.register(:FLABEBE,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(6)
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("This Flabébé rides a yellow flower. The Pokémon is defenseless and vulnerable before it has found and received power from a flower.") if pokemon.form==1
   next _INTL("This Flabébé rides an orange flower. On its head, it wears a crown of pollen that has healing properties.") if pokemon.form==2
   next _INTL("Once it finds a flower it likes, this Pokémon will spend the rest of its life taking care of its flower. This Flabébé rides a blue flower.") if pokemon.form==3
   next _INTL("This Flabébé rides a white flower. The wind blows this Pokémon around as it drifts in search of flower gardens.") if pokemon.form==4
   next _INTL("This Flabébé rides a pink flower. On its head, it wears a crown of pollen that has loving properties.") if pokemon.form==5
}
})


MultipleForms.register(:FLOETTE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form!=6     # Standard Flowers
   next [74,65,67,92,125,128]  # Eternal Flower
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form!=6     # Standard Flowers
   next 243                    # Eternal Flower
},
"getMoveList"=>proc{|pokemon|
   if pokemon.form==6
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
   next _INTL("This Pokémon can draw forth the most power when in sync with pink flowers, compared to flowers of other colors..") if pokemon.form==5
}
})

MultipleForms.register(:FLORGES,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(6)
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("It is said that there was once a Florges that protected the garden of a castle for over 300 years.") if pokemon.form==1
   next _INTL("Its orange flowers fire off powerful beams, attacking as if they were a battery of artillery.") if pokemon.form==2
   next _INTL("Though usually compassionate, Florges will hunt down anyone who vandalizes its flower garden, showing no mercy even if they beg for their lives.") if pokemon.form==3
   next _INTL("A flower garden made by a white-flowered Florges will be beautifully decorated with flowering plants of many different colors.") if pokemon.form==4
   next _INTL("Its pink flowers fire off powerful loving beams, attacking as if they were a battery of artillery.") if pokemon.form==5
}
})


=begin
MultipleForms.register(:FURFROU,{
"getForm"=>proc{|pokemon|
   if  (!pokemon.formTime || pbGetTimeNow.to_i>pokemon.formTime.to_i+60*60*24*5) # 5 days
     next 0
   end
   next
},
"onSetForm"=>proc{|pokemon,form|
   pokemon.formTime=(form>0) ? pbGetTimeNow.to_i : nil
}
})
=end


MultipleForms.register(:MEOWSTIC,{
"getAbilityList"=>proc{|pokemon|
   next if pokemon.isMale?
   next [[getID(PBAbilities,:KEENEYE),0],
         [getID(PBAbilities,:INFILTRATOR),1],
         [getID(PBAbilities,:COMPETITIVE),2]]
},
"getMoveList"=>proc{|pokemon|
   if pokemon.isFemale?
     movelist=[[1,:STOREDPOWER],[1,:MEFIRST],[1,:MAGICALLEAF],[1,:SCRATCH],
               [1,:LEER],[5,:COVET],[9,:CONFUSION],[13,:LIGHTSCREEN],
               [17,:PSYBEAM],[19,:FAKEOUT],[22,:DISARMINGVOICE],[25,:PSYSHOCK],
               [28,:CHARGEBEAM],[31,:SHADOWBALL],[35,:EXTRASENSORY],
               [40,:PSYCHIC],[43,:ROLEPLAY],[45,:SIGNALBEAM],[48,:SUCKERPUNCH],
               [50,:FUTURESIGHT],[53,:STOREDPOWER]]
     for i in movelist
       i[1]=getConst(PBMoves,i[1])
     end
     next movelist
   end
   next
},
"color"=>proc{|pokemon|
   next if pokemon.isMale?
   next 8
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.isMale?
   next _INTL("Females are a bit more selfish and aggressive than males. If they don't get what they want, they will torment you with their psychic abilities.")
}
})

MultipleForms.register(:AEGISLASH,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Shield Forme
   next [60,140,50,60,140,50]   # Blade Forme
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("This stance is dedicated to offense. It can cleave any opponent with the strength and weight of its steel blade.") if pokemon.form==1
}
})

MultipleForms.register(:PUMPKABOO,{
#"getFormOnCreation"=>proc{|pokemon|
#   next [rand(4),rand(4)].min
#},
"getFormOnCreation"=>proc{|pokemon|
   r = rand(20)
   if r==0;    next 3   # Super Size (5%)
   elsif r<4;  next 2   # Large (15%)
   elsif r<13; next 1   # Average (45%)
   end
   next 0               # Small (35%)
},
"height"=>proc{|pokemon|
   next if pokemon.form==0     # Small Size
   next 4 if pokemon.form==1   # Average Size
   next 5 if pokemon.form==2   # Large Size
   next 8 if pokemon.form==3   # Super Size
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0       # Small Size
   next 50 if pokemon.form==1    # Average Size
   next 75 if pokemon.form==2    # Large Size
   next 150 if pokemon.form==3   # Super Size
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                       # Small Size
   next [49,66,70,51,44,55] if pokemon.form==1   # Average Size
   next [54,66,70,46,44,55] if pokemon.form==2   # Large Size
   next [59,66,70,41,44,55] if pokemon.form==3   # Super Size
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:MIRACLESEED),
         getID(PBItems,:MIRACLESEED),
         getID(PBItems,:MIRACLESEED)] if pokemon.form==3 # Super Size
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Spirits that wander this world are placed into Pumpkaboo's body. They're then moved on to the afterlife.") if pokemon.form==1
   next _INTL("When taking spirits to the afterlife, large Pumpkaboo prefer the spirits of adults to those of children.") if pokemon.form==2
   next _INTL("Supersized Pumpkaboo are very partial to the spirits of people who were of similarly superior proportions.") if pokemon.form==3
}
})

MultipleForms.register(:GOURGEIST,{
#"getFormOnCreation"=>proc{|pokemon|
#   next [rand(4),rand(4)].min
#},
"getFormOnCreation"=>proc{|pokemon|
   r = rand(20)
   if r==0;    next 3   # Super Size (5%)
   elsif r<4;  next 2   # Large (15%)
   elsif r<13; next 1   # Average (45%)
   end
   next 0               # Small (35%)
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Small Size
   next 9 if pokemon.form==1    # Average Size
   next 11 if pokemon.form==2   # Large Size
   next 17 if pokemon.form==3   # Super Size
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0       # Small Size
   next 125 if pokemon.form==1   # Average Size
   next 140 if pokemon.form==2   # Large Size
   next 390 if pokemon.form==3   # Super Size
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                         # Small Size
   next [65,90,122,84,58,75] if pokemon.form==1    # Average Size
   next [75,95,122,69,58,75] if pokemon.form==2    # Large Size
   next [85,100,122,54,58,75] if pokemon.form==3   # Super Size
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:MIRACLESEED),
         getID(PBItems,:MIRACLESEED),
         getID(PBItems,:MIRACLESEED)] if pokemon.form==3 # Super Size
   next
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("Eerie cries emanate from its body in the dead of night. The sounds are said to be the wails of spirits who are suffering in the afterlife.") if pokemon.form==1
   next _INTL("Large Gourgeist put on the guise of adults, taking the hands of children to lead them to the afterlife.") if pokemon.form==2
   next _INTL("Supersized Gourgeist aren't picky. They will forcefully drag anyone off to the afterlife.") if pokemon.form==3
}
})

MultipleForms.register(:XERNEAS,{
"getFormOnEnteringBattle"=>proc{|pokemon|
   next 1
}
})

MultipleForms.register(:ZYGARDE,{
"weight"=>proc{|pokemon|
   next if pokemon.form==0  # 50%
   next 335 if pokemon.form==1
   next 6100 if pokemon.form==2
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # 50%
   next 12 if pokemon.form==1
   next 45 if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This is Zygarde when about 10% of its species have been assembled. It leaps at its opponents chest and sinks its sharp fangs into them.") if pokemon.form==1
   next _INTL("This is Zygarde's perfect form From the orfice on its chect, it radiates high-powered energy that eliminates everything.") if pokemon.form==2
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0 # 50%
   next [54,100,71,115,61,85] if pokemon.form==1
   next [216,100,121,91,95,85] if pokemon.form==2
},
"color"=>proc{|pokemon|
   next if pokemon.form==0  # 50%
   next 5                   # The rest
},
"type2"=>proc{|pokemon|
   next if pokemon.form!=1              # others
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND)  # 10% forme
   else;   next 
   end
}
})


MultipleForms.register(:HOOPA,{
"getForm"=>proc{|pokemon|
   if  (!pokemon.formTime || pbGetTimeNow.to_i>pokemon.formTime.to_i+60*60*24*3) # 3 days
     next 0
   end
   next
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0        # Confined
   next getID(PBTypes,:DARK)   # Unbound (Was Dark)
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Confined
   next [80,160,60,80,170,130]   # Unbound
},
"height"=>proc{|pokemon|
   next if pokemon.form==0   # Confined
   next 65                   # Unbound
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0   # Confined
   next 4900                 # Unbound
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:HYPERSPACEFURY],[1,:TRICK],[1,:DESTINYBOND],[1,:ALLYSWITCH],
             [1,:CONFUSION],[6,:ASTONISH],[10,:MAGICCOAT],[15,:LIGHTSCREEN],
             [19,:PSYBEAM],[25,:SKILLSWAP],[29,:POWERSPLIT],[29,:GUARDSPLIT],
             [46,:KNOCKOFF],[50,:WONDERROOM],[50,:TRICKROOM],[55,:DARKPULSE],
             [75,:PSYCHIC],[85,:HYPERSPACEFURY]]
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0   # Confined
   next _INTL("Djinn")       # Unbound
},
"onSetForm"=>proc{|pokemon,form|
   pokemon.formTime=(form>-1) ? pbGetTimeNow.to_i : nil
}
})

########################################
# Generation VII
########################################

MultipleForms.register(:ORICORIO,{
"type1"=>proc{|pokemon|
   types=[:FIRE,:ELECTRIC,:PSYCHIC,:GHOST]
   next getID(PBTypes,types[pokemon.form])
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   colors=[2,9,6]
   next colors[pokemon.form-1]
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It lifts its opponents' spirits with its cheerful dance moves. When they let their guard down, it electrocutes them with a jolt.") if pokemon.form==1
   next _INTL("It relaxes its opponents with its elegant dancing. When they let their guard down, it showers them with psychic energy.") if pokemon.form==2
   next _INTL("It charms its opponents with its refined dancing. When they let their guard down, it places a curse on them that will bring on their demise.") if pokemon.form==3
},
"getFormOnCreation"=>proc{|pokemon|
   next rand(4)
}
})

MultipleForms.register(:ROCKRUFF,{
"getForm"=>proc{|pokemon| # Needs to use getForm in order to determine the final form
   env=pbGetEnvironment()
   next 1 if PBDayNight.isNight? || env==PBEnvironment::Galaxy
   next 2 if PBDayNight.isEvening?
   next 0
}
})


MultipleForms.register(:LYCANROC,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [85,115,75,82,55,75]
     when 2; next  [75,117,65,110,55,65]
     else;   next
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form!=1
   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It has no problem ignoring orders it doesn't like. It doesn't seem to mind getting hurt at all-as long as it can finish off its opponent.") if pokemon.form==1
   next _INTL("Bathed in the setting sun of evening. Lycanroc has undergone a special kind of evolution. An intense fighting spirit underlies its clamness.") if pokemon.form==2
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:KEENEYE),0],
         [getID(PBAbilities,:VITALSPIRIT),1],
         [getID(PBAbilities,:NOGUARD),2]] if pokemon.form==1
   next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==2
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1; movelist=[[0,:COUNTER],[1,:COUNTER],[1,:REVERSAL],
                       [1,:TAUNT],[1,:TACKLE],[1,:LEER],
                       [1,:SANDATTACK],[1,:BITE],[4,:SANDATTACK],
                       [7,:BITE],[12,:HOWL],[15,:ROCKTHROW],
                       [18,:ODORSLEUTH],[23,:ROCKTOMB],[26,:ROAR],
                       [29,:STEALTHROCK],[34,:ROCKSLIDE],[37,:SCARYFACE],
                       [40,:CRUNCH],[45,:ROCKCLIMB],[48,:STONEEDGE]]
     when 2; movelist=[[0,:THRASH],[1,:THRASH],[1,:ACCELEROCK],
                       [1,:COUNTER],[1,:TACKLE],[1,:LEER],
                       [1,:SANDATTACK],[1,:BITE],[4,:SANDATTACK],
                       [7,:BITE],[12,:HOWL],[15,:ROCKTHROW],
                       [18,:ODORSLEUTH],[23,:ROCKTOMB],[26,:ROAR],
                       [29,:STEALTHROCK],[34,:ROCKSLIDE],[37,:SCARYFACE],
                       [40,:CRUNCH],[45,:ROCKCLIMB],[48,:STONEEDGE]]                  
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[:ATTRACT,:BITE,:BRICKBREAK,:BULKUP,:CONFIDE,:COUNTER,
                     :COVET,:CRUNCH,:CRUSHCLAW,:DOUBLETEAM,:DUALCHOP,
                     :EARTHPOWER,:ECHOEDVOICE,:ENDEAVOR,:FACADE,:FIREFANG,
                     :FIREPUNCH,:FOCUSPUNCH,:FOULPLAY,:FRUSTRATION,:HIDDENPOWER,
                     :HOWL,:HYPERVOICE,:IRONDEFENSE,:IRONHEAD,:IRONTAIL,
                     :LASERFOCUS,:LASTRESORT,:LEER,:ODORSLEUTH,:OUTRAGE,
                     :PROTECT,:REST,:RETURN,:REVERSAL,:ROAR,:ROCKCLIMB,
                     :ROCKPOLISH,:ROCKSLIDE,:ROCKTHROW,:ROCKTOMB,:ROUND,
                     :SANDATTACK,:SCARYFACE,:SLEEPTALK,:SNARL,:SNORE,
                     :STEALTHROCK,:STOMPINGTANTRUM,:STONEEDGE,:SUBSTITUTE,
                     :SUCKERPUNCH,:SWAGGER,:SWORDSDANCE,:TACKLE,:TAUNT,:THRASH,
                     :THROATCHOP,:THUNDERFANG,:THUNDERPUNCH,:TOXIC,:UPROAR,
                     :ZENHEADBUTT,:LASHOUT,:FOCUSPUNCH]
   when 2; movelist=[:ACCELEROCK,:ATTRACT,:BITE,:BRICKBREAK,:BULKUP,:CONFIDE,
                     :COUNTER,:COVET,:CRUNCH,:CRUSHCLAW,:DOUBLETEAM,:DRILLRUN,
                     :EARTHPOWER,:ECHOEDVOICE,:ENDEAVOR,:FACADE,:FIREFANG,
                     :FRUSTRATION,:HAPPYHOUR,:HIDDENPOWER,:HOWL,:HYPERVOICE,
                     :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:LASTRESORT,:LEER,
                     :ODORSLEUTH,:OUTRAGE,:PROTECT,:REST,:RETURN,:ROAR,
                     :ROCKCLIMB,:ROCKPOLISH,:ROCKSLIDE,:ROCKTHROW,:ROCKTOMB,
                     :ROUND,:SANDATTACK,:SCARYFACE,:SLEEPTALK,:SNARL,:SNORE,
                     :STEALTHROCK,:STOMPINGTANTRUM,:STONEEDGE,:SUBSTITUTE,
                     :SUCKERPUNCH,:SWAGGER,:SWORDSDANCE,:TACKLE,:TAUNT,:THRASH,
                     :THUNDERFANG,:TOXIC,:ZENHEADBUTT]
   end   
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   next 1 if PBDayNight.isNight? || env==PBEnvironment::Galaxy
   next 2 if PBDayNight.isEvening?
   next 0
}
})

MultipleForms.register(:WISHIWASHI,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [45,140,130,30,140,135]
     else;   next
   end
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  217
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Wishiwashi assemble in this formation to face off against strong foes. It boasts a strngth that earned it the name \"demon of the sea\".") if pokemon.form==1
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  82
     else;   next
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  786
     else;   next
   end
}
})

MultipleForms.register(:SILVALLY,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,:DOOM,:JELLY,
          :SHARPENER,:LAVA,:WIND,:LICK,:BOLT,:HERB,:CHLOROPHYLL,
          :GUST,:SUN,:MOON,:MIND,:HEART,:BLIZZARD,:GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,:DOOM,:JELLY,
          :SHARPENER,:LAVA,:WIND,:LICK,:BOLT,:HERB,:CHLOROPHYLL,
          :GUST,:SUN,:MOON,:MIND,:HEART,:BLIZZARD,:GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:FIGHTINGMEMORY)
   next 2  if isConst?(pokemon.item,PBItems,:FLYINGMEMORY)
   next 3  if isConst?(pokemon.item,PBItems,:POISONMEMORY)
   next 4  if isConst?(pokemon.item,PBItems,:GROUNDMEMORY)
   next 5  if isConst?(pokemon.item,PBItems,:ROCKMEMORY)
   next 6  if isConst?(pokemon.item,PBItems,:BUGMEMORY)
   next 7  if isConst?(pokemon.item,PBItems,:GHOSTMEMORY)
   next 8  if isConst?(pokemon.item,PBItems,:STEELMEMORY)
   next 9  if isConst?(pokemon.item,PBItems,:FIREMEMORY)
   next 10 if isConst?(pokemon.item,PBItems,:WATERMEMORY)
   next 11 if isConst?(pokemon.item,PBItems,:GRASSMEMORY)
   next 12 if isConst?(pokemon.item,PBItems,:ELECTRICMEMORY)
   next 13 if isConst?(pokemon.item,PBItems,:PSYCHICMEMORY)
   next 14 if isConst?(pokemon.item,PBItems,:ICEMEMORY)
   next 15 if isConst?(pokemon.item,PBItems,:DRAGONMEMORY)
   next 16 if isConst?(pokemon.item,PBItems,:DARKMEMORY)
   next 17 if isConst?(pokemon.item,PBItems,:FAIRYMEMORY)
   next 18 if isConst?(pokemon.item,PBItems,:MAGICMEMORY)
   next 19 if isConst?(pokemon.item,PBItems,:DOOMMEMORY)
   next 20 if isConst?(pokemon.item,PBItems,:JELLYMEMORY)
   next 21 if isConst?(pokemon.item,PBItems,:SHARPENERMEMORY)
   next 22 if isConst?(pokemon.item,PBItems,:LAVAMEMORY)
   next 23 if isConst?(pokemon.item,PBItems,:WINDMEMORY)
   next 24 if isConst?(pokemon.item,PBItems,:LICKMEMORY)
   next 25 if isConst?(pokemon.item,PBItems,:BOLTMEMORY)
   next 26 if isConst?(pokemon.item,PBItems,:HERBMEMORY)
   next 27 if isConst?(pokemon.item,PBItems,:CHLOROPHYLLMEMORY)
   next 28 if isConst?(pokemon.item,PBItems,:GUSTMEMORY)
   next 29 if isConst?(pokemon.item,PBItems,:SUNMEMORY)
   next 30 if isConst?(pokemon.item,PBItems,:MOONMEMORY)
   next 31 if isConst?(pokemon.item,PBItems,:MINDMEMORY)
   next 32 if isConst?(pokemon.item,PBItems,:HEARTMEMORY)
   next 33 if isConst?(pokemon.item,PBItems,:BLIZZARDMEMORY)
   next 34 if isConst?(pokemon.item,PBItems,:GASMEMORY)
   next 35 if isConst?(pokemon.item,PBItems,:GLIMSEMEMORY)
   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Having been awalened successfully, it can change its type and battle-just like a certain Pokémon depicted in legends.")
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=15
   movelist=[:AERIALACE,:AIRSLASH,:BITE,:CONFIDE,:CRUNCH,:CRUSHCLAW,:DEFOG,
             :DOUBLEEDGE,:DOUBLEHIT,:DOUBLETEAM,:DRACOMETEOR,:DRAGONCLAW,
             :EXPLOSION,:FACADE,:FIREFANG,:FLAMECHARGE,:FLAMETHROWER,
             :FLASHCANNON,:FRUSTRATION,:GIGAIMPACT,:GRASSPLEDGE,:HAIL,
             :HEALBLOCK,:HEATWAVE,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:ICEBEAM,
             :ICEFANG,:ICYWIND,:IMPRISON,:IRONDEFENSE,:IRONHEAD,:LASERFOCUS,
             :LASTRESORT,:MAGICCOAT,:METALSOUND,:MULTIATTACK,:OUTRAGE,
             :PARTINGSHOT,:PAYBACK,:POISONFANG,:PROTECT,:PUNISHMENT,:PURSUIT,
             :RAGE,:RAINDANCE,:RAZORWIND,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROUND,
             :SANDSTORM,:SCARYFACE,:SHADOWBALL,:SHADOWCLAW,:SIGNALBEAM,
             :SLEEPTALK,:SNARL,:SNORE,:STEELWING,:SUBSTITUTE,:SUNNYDAY,:SURF,
             :SWAGGER,:SWORDSDANCE,:TACKLE,:TAILWIND,:TAKEDOWN,:THUNDERBOLT,
             :THUNDERFANG,:THUNDERWAVE,:TOXIC,:TRIATTACK,:UTURN,:WORKUP,
             :XSCISSOR,:ZENHEADBUTT,:STEELBEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
}
})

MultipleForms.register(:MINIOR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form < 7     # Meteor Form
   next [60,100,60,120,100,60]  # Colored Cores
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form < 7     # Meteor Form
   next 175                     # Colored Cores
},
"evYield"=>proc{|pokemon|
   next if pokemon.form < 7     # Meteor Form
   next [0,1,0,0,1,0]           # Colored Cores
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form < 7
   next _INTL("Places where Minior fall from the night sky are few and far between, with Alola being one of the precious few.")
},
"color"=>proc{|pokemon|
   next if pokemon.form<7
   colors=[0,0,2,3,1,1,6]
   next colors[pokemon.form-7]
},
"getFormOnCreation"=>proc{|pokemon|
   next 7+rand(7)
}
})


# Dusk Mane Necrozma is obtainable by fusing Necrozma with Solgaleo
# Dawn Wings Necrozma is obtainable by fusing Necrozma with Lunala
# Ultra Necrozma is obtainable by using Photon Geyser while being fused. This
# will keep it unti the next turn, including the base turn. Regular Necrozma
# can't do this

MultipleForms.register(:NECROZMA,{
"type2"=>proc{|pokemon|
   types=[:PSYCHIC,:STEEL,:GHOST,:DRAGON]
   next getID(PBTypes,types[pokemon.form])
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  306
     when 2; next  306
     when 3; next  339
     else;   next
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [97,157,127,77,113,109]
     when 2; next  [97,113,109,77,157,127]
     when 3; next  [97,167,97,129,167,97]
     else;   next
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [0,3,0,0,0,0]
     when 2; next  [0,0,0,0,3,0]
     when 3; next  [0,1,0,1,1,0]
     else;   next
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next   38
     when 2; next   42
     when 3; next   75
     else;   next
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  4600
     when 2; next  3500
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form!=3
   next [[getID(PBAbilities,:NEUROFORCE),0]]
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1 || pokemon.form==3
   next 1 if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This is its form while it is devouring the light of Solgaleo. It pounces on foes and then slashes them with the claws on its limbs and back.") if pokemon.form==1 # Dusk Mane
   next _INTL("This is its form while it is devouring the light of Lunala. It grasps on foes in its giant claws and rips them apart with brute force.") if pokemon.form==2 # Dawn Wings
   next _INTL("This is its form when it has absorbed overwhelming light energy. It fires laser beams from all over its body.") if pokemon.form==3 # Ultrs
},
"onSetForm"=>proc{|pokemon,form|
   moves=[
      :SUNSTEELSTRIKE, # Dusk Mane
      :MOONGEISTBEAM   # Dawn Wings
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if (form==1 || form==2) && !$inbattle
     newmove = moves[form-1]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename = PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename = PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove] = PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   elsif form==0
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:CONFUSION))
       end
     end
   end
}
})


# Magearna starts at form 0. When it enters on battle, it can change its forms

MultipleForms.register(:MAGEARNA,{
"getFormOnCreation"=>proc{|pokemon|
   next 0
},
"getFormOnEnteringBattle"=>proc{|pokemon|
   next rand(2)
},
"getFormOnCroteline"=>proc{|pokemon|
   next rand(2)
},
"getFormOnPES"=>proc{|pokemon|
   next rand(2)
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This is its form from almost 500 years ago. Its body is nothing more than a container—its artificial heart is the actual life-form.") if pokemon.form==1 # Dusk Mane
}
})

########################################
# Generation VIII
########################################

# Applin does not have any forms but can depend on item

MultipleForms.register(:APPLIN,{
"getFormOnCreation"=>proc{|pokemon|
   next ($Trainer.isFemale?) ? 1 : 0  # Form depends on Player Character
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:SWEETAPPLE),
         getID(PBItems,:TARTAPPLE),
         0] if pokemon.form==1 # Female Player Character
   next                        # Male Player Character
}
})

MultipleForms.copy(:APPLIN,:FLAPPLE,:APPLETUN)

MultipleForms.register(:CRAMORANT,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Cramorant's gluttony led it to try to swallow an Arrokuda whole, which in turn led to Cramorant getting an Arrokuda stuck in its throat.") if pokemon.form==1
   next _INTL("This Cramorant has accidentally gotten a Pikachu lodge in its gullet. Cramorant is choking a little, but it isn't really bothered.") if pokemon.form==2
}
})


# Toxel has no virtual alt forms but used for Toxtricity

MultipleForms.register(:TOXEL,{
"getFormOnCreation"=>proc{|pokemon|
   natures=[PBNatures::LONELY,PBNatures::BOLD,PBNatures::RELAXED,
            PBNatures::TIMID,PBNatures::SERIOUS,PBNatures::MODEST,
            PBNatures::MILD,PBNatures::QUIET,PBNatures::BASHFUL,
            PBNatures::CALM,PBNatures::GENTLE,
            PBNatures::CAREFUL] # Natures for 2nd form
   if natures.include?(pokemon.nature)
     next 1 # Low Key Form
   else
     next 0  # Amped Form
  end
}
})

MultipleForms.register(:TOXTRICITY,{
"getFormOnCreation"=>proc{|pokemon|
   natures=[PBNatures::LONELY,PBNatures::BOLD,PBNatures::RELAXED,
            PBNatures::TIMID,PBNatures::SERIOUS,PBNatures::MODEST,
            PBNatures::MILD,PBNatures::QUIET,PBNatures::BASHFUL,
            PBNatures::CALM,PBNatures::GENTLE,
            PBNatures::CAREFUL] # Natures for 2nd form
   if natures.include?(pokemon.nature)
     next 1 # Low Key Form
   else
     next 0  # Amped Form
  end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:PUNKROCK),0],
         [getID(PBAbilities,:MINUS),1],
         [getID(PBAbilities,:TECHNICIAN),2]]
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[0,:SPARK],[1,:SPARK],[1,:EERIEIMPULSE],[1,:BELCH],[1,:TEARFULLOOK],
             [1,:NUZZLE],[1,:GROWL],[1,:FLAIL],[1,:ACID],[1,:THUNDERSHOCK],
             [1,:ACIDSPRAY],[1,:LEER],[1,:NOBLEROAR],[4,:CHARGE],
             [8,:SHOCKWAVE],[12,:SCARYFACE],[16,:TAUNT],[20,:VEMONDRENCH],
             [24,:SCREECH],[28,:SWAGGER],[32,:TOXIC],[36,:DISCHARGE],
             [40,:POISONJAB],[44,:OVERDRIVE],[48,:BOOMBURST],[52,:MAGNETICFLUX]]
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Capable of generating 15.000 volts of electricity, this Pokémon looks down on all that would challenge it.") if pokemon.form==1
}
})


MultipleForms.register(:POLTEAGEIST,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [60,110,110,70,208,164]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("After being reunited with four Sinistea, Polteagesit seem to became even stronger than before.") if pokemon.form==1
}
})


MultipleForms.register(:OBSTAGOON,{
"getForm"=>proc{|pokemon|
   next 2 # Required in order for Galar Forms to work
}
})

MultipleForms.copy(:OBSTAGOON,:MRRIME,:CURSOLA,:PERRSERKER,:SIRFETCHD,:RUNERIGUS)

MultipleForms.register(:MILCERY,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   flavour=0
   topping=0
   if PBDayNight.isRainbow?
     flavour=[0,0,0,0,1,1,1,1,6.6,7,7,8][rand(13)]
     flavour=[2,2,2,2,3,3,4,4,5,5,5,5,8][rand(13)] if env==PBEnvironment::Galaxy
   else
     flavour=[0,0,0,0,1,1,1,1,6.6,7,7][rand(12)]
     flavour=[2,2,2,2,3,3,4,4,5,5,5,5][rand(12)] if PBDayNight.isNight? || env==PBEnvironment::Galaxy
   end
   topping=[0,9,18,27,36,45,54][rand(7)]
   next flavour if !topping
   next topping if !flavour
   next flavour+topping
}
})

MultipleForms.register(:ALCREMIE,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   flavour=0
   topping=0
   if PBDayNight.isRainbow?
     flavour=[0,0,0,0,1,1,1,1,6.6,7,7,8][rand(13)]
     flavour=[2,2,2,2,3,3,4,4,5,5,5,5,8][rand(13)] if env==PBEnvironment::Galaxy
   else
     flavour=[0,0,0,0,1,1,1,1,6.6,7,7][rand(12)]
     flavour=[2,2,2,2,3,3,4,4,5,5,5,5][rand(12)] if PBDayNight.isNight? || env==PBEnvironment::Galaxy
   end
   topping=[0,9,18,27,36,45,54][rand(7)]
   next flavour if !topping
   next topping if !flavour
   next flavour+topping
},
"color"=>proc{|pokemon|
   next   if pokemon.form%9==0 || pokemon.form%9==5 # Vanilla and Salted Flavours
   next 9 if pokemon.form%9==1                      # Ruby Flavour
   next 3 if pokemon.form%9==2                      # Matcha Flavour
   next 1 if pokemon.form%9==3                      # Mint Flavour
   next 2 if pokemon.form%9==4                      # Lemon Flavour
   next 2 if pokemon.form%9==6                      # Ruby Swirl
   next 5 if pokemon.form%9==7                      # Caramel Swirl
   next 2 if pokemon.form%9==8                      # Rainbown Swirl

},
"dexEntry"=>proc{|pokemon|
   next                                                                                                                                                  if pokemon.form%9==0   # Vanilla Flavour
   next _INTL("The moment it evolved, it took on a sweet and tart flavor. This is because of the way its cells spontaneously shifted during evolution.") if pokemon.form%9==1   # Ruby Flavour
   next _INTL("The moment it evolved, it took on an aromatic flavor. This is because of the way its cells spontaneously shifted during evolution.")      if pokemon.form%9==2   # Matcha Flavour
   next _INTL("The moment it evolved, it took on a refreshing flavor. This is because of the way its cells spontaneously shifted during evolution.")     if pokemon.form%9==3   # Mint Flavour
   next _INTL("The moment it evolved, it took on a sour flavor. This is because of the way its cells spontaneously shifted during evolution.")           if pokemon.form%9==4   # Lemon Flavour
   next _INTL("The moment it evolved, it took on a salty flavor. This is because of the way its cells spontaneously shifted during evolution.")          if pokemon.form%9==5   # Salted Flavour
   next _INTL("The moment it evolved, it took on a mixed flavor. This is because of the way its cells spontaneously shifted during evolution.")          if pokemon.form%9==6   # Ruby Swirl
   next _INTL("The moment it evolved, it took on a bitter flavor. This is because of the way its cells spontaneously shifted during evolution.")         if pokemon.form%9==7   # Caramel Swirl
   next _INTL("The moment it evolved, it took on a complex flavor. This is because of the way its cells spontaneously shifted during evolution.")        if pokemon.form%9==8   # Rainbown Swirl

}
})


MultipleForms.register(:EISCUE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [75,80,70,130,65,90]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The ice covering this Pokémon face has shattered, revealing a slightly worries expression that many people are enamored with.") if pokemon.form==1
}
})

MultipleForms.register(:INDEEDEE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [70,55,65,85,95,105]
     else;   next
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:STOREDPOWER],[1,:PLAYNICE],[5,:BATONPASS],
             [10,:DISARMINGVOICE],[15,:PSYBEAM],[20,:HELPINGHAND],
             [25,:FOLLOWME],[30,:AROMATHERAPY],[35,:PSYCHIC],
             [40,:CALMMIND],[45,:GUARDSPLIT],[50,:PSYCHICTERRAIN],
             [55,:HEALINGWISH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:OWNTEMPO),0],
         [getID(PBAbilities,:SYNCHRONIZE),1],
         [getID(PBAbilities,:PSYCHICSURGE),2]] if pokemon.form==1 # Eternal
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("These intelligent Pokémon touch horns wirh each other to share information between them.") if pokemon.form==1
}
})

MultipleForms.register(:MORPEKO,{
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Intense hunger drives it to extremes of violence, and the electricity in its cheek sacs has converted into a Dark-type energy.") if pokemon.form==1
}
})

MultipleForms.register(:ZACIAN,{
"getFormOnEnteringBattle"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSWORD)  # Crowned Sword
   next 0                                                  # Hero of many battles
},
"type2"=>proc{|pokemon|
   types=[:FAIRY,:STEEL]
   next getID(PBTypes,types[pokemon.form])
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  3550
     else;   next
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [92,150,115,148,80,115]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Now armed with a weapon it used in ancient times, this Pokémon needs only a single strike to fell even Gigantamax Pokémon.") if pokemon.form==1
}
})


MultipleForms.register(:ZAMAZENTA,{
"getFormOnEnteringBattle"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSHIELD)  # Crowned Shield
   next 0                                                   # Hero of many battles
},
"type2"=>proc{|pokemon|
   types=[:FIGHTING,:STEEL]
   next getID(PBTypes,types[pokemon.form])
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  7850
     else;   next
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [92,120,140,128,80,140]
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Its ability to deflect any attack led to it being known as the Fighting Master's Shield. It was feared and respected by all.") if pokemon.form==1
}
})

MultipleForms.register(:ETERNATUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [255,115,250,130,125,250]
     else;   next
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  9500
     else;   next
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  1000
     else;   next
   end
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("As a result of Rose's meddling, Eternatus absorbed all the energy in the Galar region. It's now in a state of power overload.") if pokemon.form==1
}
})

MultipleForms.register(:KUBFU,{
"getForm"=>proc{|pokemon|
   next 1  if $Trainer.isFemale?    # Fire
   next 0
}
})


MultipleForms.register(:URSHIFU,{
"type2"=>proc{|pokemon|
   types=[:DARK,:WATER]
   next getID(PBTypes,types[pokemon.form])
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[0,:SURGINGSTRIKES],[1,:AQUAJET],[1,:ROCKSMASH],
             [1,:LEER],[1,:ENDURE],[1,:FOCUSENERGY],
             [12,:AERIALACE],[16,:SCARYFACE],[20,:HEADBUTT],
             [24,:BRICKBREAK],[28,:DETECT],[32,:BULKUP],
             [36,:IRONHEAD],[40,:DYNAMICPUNCH],[44,:COUNTER],
             [48,:CLOSECOMBAT],[52,:FOCUSPUNCH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("It's believed that this Pokémon modeled its fighting style on the flow of a river — sometimes rapid, sometimes calm.") if pokemon.form==1
}
})

MultipleForms.register(:CALYREX,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [100,165,150,50,85,130]
     when 2; next  [100,85,80,150,165,100]
     else;   next
   end
},
"type2"=>proc{|pokemon|
   types=[:GRASS,:ICE,:GHOST] # [:CHLOROPHYLL,:BLIZZARD,:MOON]
   next getID(PBTypes,types[pokemon.form])
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:GLACIALLANCE],[1,:TACKLE],[1,:TAILWHIP],[1,:DOUBLEKICK],
             [1,:AVALANCHE],[1,:STOMP],[1,:TORMENT],[1,:MIST],
             [1,:ICICLECRASH],[1,:TAKEDOWN],[1,:IRONDEFENSE],[1,:TRASH],
             [1,TAUNT],[1,:DOUBLEEDGE],[1,:SWORDSDANCE],
             # Regular Learnest
             [1,:POUND],[1,:MEGADRAIN],[1,:CONFUSION],[1,:GROWTH],[8,:LIFEDEW],
             [16,:GIGADRAIN],[24,:PSYSHOCK],[32,:HELPINGHAND],[40,:AROMATHERAPY],
             [48,:ENERGYBALL],[56,:PSYCHIC],[64,:LEECHSEED],[72,HEALPULSE],
             [80,:SOLARBEAM],[88,:FUTURESIGHT]] if pokemon.form==1 # Eternal
   movelist=[[1,:ASTRALBARRAGE],[1,:TACKLE],[1,:TAILWHIP],[1,:DOUBLEKICK],
             [1,:HEX],[1,:STOMP],[1,:CONFUSERAY],[1,:MIST],
             [1,:SHADOWBALL],[1,:TAKEDOWN],[1,:AGILITY],[1,:TRASH],
             [1,DISABLE],[1,:DOUBLEEDGE],[1,:NASTYPLOT],
             # Regular Learnest
             [1,:POUND],[1,:MEGADRAIN],[1,:CONFUSION],[1,:GROWTH],[8,:LIFEDEW],
             [16,:GIGADRAIN],[24,:PSYSHOCK],[32,:HELPINGHAND],[40,:AROMATHERAPY],
             [48,:ENERGYBALL],[56,:PSYCHIC],[64,:LEECHSEED],[72,HEALPULSE],
             [80,:SOLARBEAM],[88,:FUTURESIGHT]] if pokemon.form==2 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:ASONE1),0]] if pokemon.form==1 # Eternal (CHEELINGNEIGH)
   next [[getID(PBAbilities,:ASONE2),0]] if pokemon.form==2 # Eternal (GRIMNEIGH)
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("According to lore, this Pokémon showed no mercy to those who got in its way, yet it would heal its opponents' wounds after battle.") if pokemon.form==1
   next _INTL("It's said that Calyrex and a Pokémon that had bonded with it ran all across the Galar region to bring green to the wastelands.") if pokemon.form==2
},
"onSetForm"=>proc{|pokemon,form|
    moves = [
       :GLACIALLANCE, # Ice Rider (with Glastrier) (form 1)
       :ASTRALBARRAGE,# Shadow Rider (with Spectrier) (form 2)
       # Both forms
       :TACKLE,:TAILWHIP,:DOUBLEKICK,:STOMP,:TAKEDOWN,:THRASH,:DOUBLEEDGE,
       :AVALANCHE,:TORMENT,:MIST,:ICICLECRASH,:IRONDEFENSE,:TAUNT,:SWORDSDANCE,
       :HEX,:CONFUSERAY,:HAZE,:SHADOWBALL,:AGILITY,:DISABLE,:NASTYPLOT
    ]
    if form==0 
      4.times do
        idxMoveToReplace = -1
        pokemon.moves.each_with_index do |move,i|
          next if !move
          moves.each do |newMove|
            next if !isConst?(move.id,PBMoves,newMove)
            idxMoveToReplace = i
            break
          end
          break if idxMoveToReplace>=0
        end
        if idxMoveToReplace>=0
          moveName = PBMoves.getName(pokemon.moves[idxMoveToReplace].id)
          pokemon.pbDeleteMoveAtIndex(idxMoveToReplace)
          Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,moveName))
        end
      end
      pbLearnMove(pokemon,getID(PBMoves,:CONFUSION)) if pokemon.numMoves==0
    else
      newMove = getConst(PBMoves,moves[form-1])
      if newMove && newMove>0
        pbLearnMove(pokemon,newMove,true)
      end
    end
}

})


MultipleForms.register(:BASCULEGION,{
"getForm"=>proc{|pokemon|
   next 2 # Required in order for White-Striped form of Basculin to work
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.isMale?
   next  [75,15,60,10,39,45]
},

})

MultipleForms.register(:SNEASLER,{
"getForm"=>proc{|pokemon|
   next 1 # Required in order for Hisui Forms to work
}
})

MultipleForms.copy(:SNEASLER,:OVERQWIL)

MultipleForms.register(:ENAMORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [74,115,110,46,135,100] # Therian Forme
},
"height"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next 14                 # Therian Forme
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                    # Incarnate Forme
   next [[getID(PBAbilities,:OVERCOAT),0],
         [getID(PBAbilities,:CONTRARY),2]]     # Therian Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("A different guise from its feminine humanoid form. From the clouds, it descends upon those who treat any form of life with disrespect and metes out wrathful, ruthless punishment.") if pokemon.form==1
}
})

########################################
# Generation IX
########################################

MultipleForms.register(:OINKOLOGNE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [115,90,70,65,59,90]
     else;   next
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:TACKLE],[1,:TAILWHIP],[3,:DISARMINGVOICE],
			 [6,:ECHOEDVOICE],[9,:MUDSHOT],[12,:COVET],[15,:DIG],
			 [17,:HEADBUTT],[23,:YAWN],[28,:TAKEDOWN],[30,:WORKUP],
			 [34,:UPROAR],[39,:DOUBLEEDGE],[45,:EARTHPOWER],
			 [51,:BELCH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:AROMAVEIL),0],
         [getID(PBAbilities,:GLUTTONY),1],
         [getID(PBAbilities,:THICKFAT),2],
         [getID(PBAbilities,:TRAMPOLINE),3]] if pokemon.form==1 # Eternal
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon sends a flowerlike scent wafting about. Well-developed muscles in its legs allow it to leap more than 16 feet with no trouble at all.") if pokemon.form==1
}
})

# Form 0 is Family of Three while Form 1 is Family of Four
MultipleForms.register(:MAUSHOLD,{
"getForm"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   d%=25
   next [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1][d]
},

"weight"=>proc{|pokemon|
   next if pokemon.form==0
   next 28
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The two little ones just appeared one day. The group might be a family of related Pokémon, but nobody knows for sure.") if pokemon.form==1
}
})

MultipleForms.register(:SQUAWKABILLY,{
"getFormOnCreation"=>proc{|pokemon|
	next rand(4)
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
   next 2 if pokemon.form==2
   next 8 if pokemon.form==3
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==1
   next [[getID(PBAbilities,:INTIMIDATE),0],
		 [getID(PBAbilities,:HUSTLE),1],
		 [getID(PBAbilities,:SHEERFORCE),2]]
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("The largest of their flocks can contain more than 50 individuals. They fly around towns and forests, searching for food and making a racket.") if pokemon.form==1
   next _INTL("These Squawkabilly are hotheaded, and their fighting style is vicious. They’ll leap within reach of their foes to engage in close combat.") if pokemon.form==2
   next _INTL("This Pokémon dislikes being alone. It has a strong sense of community and survives by cooperating with allies.") if pokemon.form==3
}
})

MultipleForms.register(:PALAFIN,{
"height"=>proc{|pokemon|
   next if pokemon.form==0
   next 18
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   next 974
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This Pokémon’s ancient genes have awakened. It is now so extraordinarily strong that it can easily lift a cruise ship with one fin.") if pokemon.form==1
}
})

MultipleForms.register(:TATSUGIRI,{
"getFormOnCreation"=>proc{|pokemon|
	next rand(3)
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
   next 2 if pokemon.form==2
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("This species’ differing colors and patterns are apparently the result of Tatsugiri changing itself to suit the preferences of the prey it lures in.") if pokemon.form==1
   next _INTL("This species’ differing colors and patterns are apparently the result of Tatsugiri changing itself to suit the preferences of the prey it lures in.") if pokemon.form==2
}
})


MultipleForms.register(:CLODSIRE,{
"getForm"=>proc{|pokemon|
   next 1 # Required in order for Paldean Wooper form of Basculin to work
}
})


# Form 0 is Two-Segment while Form 1 is Three-Segement
MultipleForms.register(:DUDUNSPARCE,{
"getForm"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   d%=25
   next [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0][d]
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   next 45
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   next 474
}
})


################################################################################
# Other Forms (Q.Qore Pokemon)
################################################################################
MultipleForms.register(:SUNNYCHANNEL,{
"type1"=>proc{|pokemon|
   types=[:SUN,:NORMAL]
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [75,15,60,10,39,45]
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:SOLARPOWER),0]]
},

"getForm"=>proc{|pokemon|
   env=pbGetEnvironment()
   if (PBDayNight.isDay? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
       (isConst?(pokemon.item,PBItems,:SUNNYORB) || env==PBEnvironment::Volcano ||
       $game_screen.weather_type==PBFieldWeather::Sun) && env!=PBEnvironment::Galaxy
     next 0 # Sun
   else
     next 1 # No Sun (Cannot evolve into SBC or Alert TV)
   end
}
})

MultipleForms.register(:SBC,{
"type1"=>proc{|pokemon|
   types=[:HEART,:FIRE,:GRASS,:ELECTRIC,:WATER,:CHLOROPHYLL,:MIND,:DARK,:SUN,:DOOM,:ICE]
   next getID(PBTypes,types[pokemon.form])
},  
 "type2"=>proc{|pokemon|
   types=[:SHARPENER,:LAVA,:WIND,:BOLT,:ICE,:SUN,:PSYCHIC,:LICK,:GUST,:GHOST,:BLIZZARD]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==4 || pokemon.form==10
   next 0 if pokemon.form==1
   next 2 if pokemon.form==3
   next 3 if pokemon.form==2 || pokemon.form==5 || pokemon.form==8
   next 4 if pokemon.form==9
   next 6 if pokemon.form==7
   next 9 if pokemon.form==6
},
"getForm"=>proc{|pokemon|
   next 1  if (isConst?(pokemon.item,PBItems,:FIRESTONE) ||
               isConst?(pokemon.item,PBItems,:FLAMEPLATE))   # Fire
   next 2  if (isConst?(pokemon.item,PBItems,:LEAFSTONE) ||
               isConst?(pokemon.item,PBItems,:MEADOWPLATE))  # Grass
   next 3  if (isConst?(pokemon.item,PBItems,:THUNDERSTONE) ||
              isConst?(pokemon.item,PBItems,:ZAPPLATE))      # Thunder
   next 4  if (isConst?(pokemon.item,PBItems,:WATERSTONE) ||
              isConst?(pokemon.item,PBItems,:SPLASHPLATE))   # Water
   next 5  if (isConst?(pokemon.item,PBItems,:SUNSTONE) ||
              isConst?(pokemon.item,PBItems,:MENTALPLATE))   # Sunny
   next 6  if (isConst?(pokemon.item,PBItems,:DAWNSTONE) ||
              isConst?(pokemon.item,PBItems,:BRAINPLATE))    # Psycho
   next 7  if (isConst?(pokemon.item,PBItems,:DUSKSTONE) ||
              isConst?(pokemon.item,PBItems,:DREADPLATE))    # Dusk
   next 8  if (isConst?(pokemon.item,PBItems,:SHINYSTONE) ||
              isConst?(pokemon.item,PBItems,:SUNSHINEPLATE)) # Brighter
   next 9  if (isConst?(pokemon.item,PBItems,:DOOMSTONE) ||
              isConst?(pokemon.item,PBItems,:BOMBPLATE))     # Doomy
   next 10 if (isConst?(pokemon.item,PBItems,:ICESTONE) ||
              isConst?(pokemon.item,PBItems,:ICICLEPLATE))   # Icey
   next 0
},
=begin
# Old ability list
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:FLASHFIRE)
     when 2; next getID(PBAbilities,:AROMAVEIL)
     when 3; next getID(PBAbilities,:STATIC) 
     when 4; next getID(PBAbilities,:WATERVEIL)   
     when 5; next getID(PBAbilities,:CHLOROPHYLL) 
     when 6; next getID(PBAbilities,:SYNCHRONIZE) 
     when 7; next getID(PBAbilities,:JUSTIFIED) 
     when 8; next getID(PBAbilities,:NATURALCURE) 
     when 9; next getID(PBAbilities,:DOOMELIST) 
     when 10; next getID(PBAbilities,:ICEBODY)
     else;   next                                 
   end
},
=end

# SBC Elemental may have either of the abilies listed below, depending on the form
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:FLASHFIRE),0],
         [getID(PBAbilities,:FLAMEBODY),1]] if pokemon.form==1
   next [[getID(PBAbilities,:AROMAVEIL),0],
         [getID(PBAbilities,:SWEETVEIL),1]] if pokemon.form==2
   next [[getID(PBAbilities,:STATIC),0],
         [getID(PBAbilities,:VOLTABSORB),1]] if pokemon.form==3
   next [[getID(PBAbilities,:WATERVEIL),0],
         [getID(PBAbilities,:WATERABSORB),1]] if pokemon.form==4
   next [[getID(PBAbilities,:CHLOROPHYLL),0],
         [getID(PBAbilities,:EFFECTSPORE),1]] if pokemon.form==5
   next [[getID(PBAbilities,:SYNCHRIONIZE),0],
         [getID(PBAbilities,:ALONELY),1]] if pokemon.form==6
   next [[getID(PBAbilities,:JUSTIFIED),0],
         [getID(PBAbilities,:PRANKSTER),1]] if pokemon.form==7
   next [[getID(PBAbilities,:NATURALCURE),0],
         [getID(PBAbilities,:HERBLOBBY),1]] if pokemon.form==8
   next [[getID(PBAbilities,:DOOMELIST),0],
         [getID(PBAbilities,:DOOMER),1]] if pokemon.form==9
   next [[getID(PBAbilities,:ICEBODY),0],
         [getID(PBAbilities,:SNOWCLOAK),1]] if pokemon.form==10
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves1=[
      :MAGMATRIIVERSE,  # Fire
      :SEEDBOMB,        # Grass (Used to be Grass Knot)
      :THUNDERSHOCK,    # Thunder (Used to be Thunder Punch)
      :WATERLOGO,       # Water
      :CHLOROPHYLL,     # Sunny
      :MINDREADER,      # Psycho
      :TOPSYDAMAGE,     # Dusk (Used to be Pursuit)
      :SUNNYDRAIN,      # Brighter
      :DOOMPRETZEL,     # Doomy (Used to be Doom Tackle)
      :COLDWATER        # Icey
   ]
   moves2=[
      :LAVAPLUME,       # Fire
      :DAMADON,         # Grass
      :BOLTOPIA,        # Thunder (Used to be Thunderbolt)
      :ICEBEAM,         # Water (Used to be Ice Punch)
      :MORNINGSUN,      # Sunny
      :PSYCHIC,         # Psycho
      :LICK,            # Dusk
      :GIERYFIST,       # Brighter (Used to be Gusting Pond)
      :NIGHTSHADE,      # Doomy (Used to be Spite)
      :BLIZZARDOUSOCEAN # Icey
   ]
   # 1st Special Move
if !$inbattle # Avoid Glitches with trainer battles
   hasoldmove1=-1
   for i in 0...4
     for j in 0...moves1.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves1[j])
         hasoldmove1=i; break
       end
     end
     break if hasoldmove1>=0
   end
   if form>0 
     newmove1=moves1[form-1]
     if newmove1!=nil && hasConst?(PBMoves,newmove1)
       if hasoldmove1>=0
         # Automatically replace the old form's 1st special move with the new one's
         oldmovename1=PBMoves.getName(pokemon.moves[hasoldmove1].id)
         newmovename1=PBMoves.getName(getID(PBMoves,newmove1))
         pokemon.moves[hasoldmove1]=PBMove.new(getID(PBMoves,newmove1))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename1))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename1))
       else
         # Try to learn the new form's 1st special move
         pbLearnMove(pokemon,getID(PBMoves,newmove1),true)
       end
     end
   else
     if hasoldmove1>=0
       # Forget the old form's 1st special move
       oldmovename1=PBMoves.getName(pokemon.moves[hasoldmove1].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove1)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename1))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:HEARTSTAMP))
       end
     end
   end
   # 2nd Special Move
   hasoldmove2=-1
   for i in 0...4
     for j in 0...moves2.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves2[j])
         hasoldmove2=i; break
       end
     end
     break if hasoldmove2>=0
   end
   if form>0
     newmove2=moves2[form-1]
     if newmove2!=nil && hasConst?(PBMoves,newmove2)
       if hasoldmove2>=0
         # Automatically replace the old form's 2nd special move with the new one's
         oldmovename2=PBMoves.getName(pokemon.moves[hasoldmove2].id)
         newmovename2=PBMoves.getName(getID(PBMoves,newmove2))
         pokemon.moves[hasoldmove2]=PBMove.new(getID(PBMoves,newmove2))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename2))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename2))
       else
         # Try to learn the new form's 1st special move
         pbLearnMove(pokemon,getID(PBMoves,newmove2),true)
       end
     end
   else
     if hasoldmove2>=0
       # Forget the old form's 2nd special move
       oldmovename2=PBMoves.getName(pokemon.moves[hasoldmove2].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove2)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename2))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:SHARPTACKLE))
       end
     end
   end
end
}

})

MultipleForms.register(:OK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:FAIRY) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:FIRE) if pokemon.form==1 # Eternal
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [70,10,15,70,80,60] # Eternal
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:INFILTRATOR),0],
         [getID(PBAbilities,:ANTISHARPNESS),1],
         [getID(PBAbilities,:FLOERYGIST),2],
         [getID(PBAbilities,:SUPERCLEARBODY),3],
         [getID(PBAbilities,:TOUGHCLAWS),4]] if pokemon.form==1 # Eternal
},

"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE)] if pokemon.form==1 # Eternal
   next
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:SWEETSODA],[1,:MOONBLAST],[5,:BURNUP],[5,:DRAININGKISS],
             [10,:PSYCHOTRACK],[10,:EMBER],[20,:ATTRACT],[20,:FAIRYWIND],
             [40,:PSYBEAM],[40,:INTIMIDATE],[80,:CASANOVA],[80,:LAVAPLUME],
             [160,:SUNNYBLAST],[160,:MOONBLOVER],[320,:BURNUP],[320,:PSYCHOTRACK]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Who know the fact about the ancient 0-6? It was recently found on the MYSTERY ZONE building out an alternative world that wasn't found out yet.") if pokemon.form==1 # Eternal
},


"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Distortion") if pokemon.form==1  # Eternal
},


"getFormOnCreation"=>proc{|pokemon|
   maps=[112]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})

MultipleForms.register(:MEDIAWIKI,{
# Affects this Pokémon and its evolution (Wikimedia)
"getFormOnCreation"=>proc{|pokemon|
   next 1 if rand(100) < 1
   next 0
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:FIRE) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:WIND) if pokemon.form==1 # Eternal
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [170,160,6,30,35,40] # Eternal
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:ENIGMATACTICS),0],
         [getID(PBAbilities,:HEATPROOF),1],
         [getID(PBAbilities,:CONTRARY),2],
         [getID(PBAbilities,:MASKEDHERB),3]] if pokemon.form==1 # Eternal
},

"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:PHOTONCLAW),
         getID(PBItems,:PHOTONCLAW),
         getID(PBItems,:PHOTONCLAW)] if pokemon.form==1 # Eternal
   next
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:TORCHWOOD],[1,:TACKLE],[2,:CASTLEMANIA],[5,:CHLOROPHYLL],
             [9,:AEROBICS],[14,:FLAMEWHEEL],[17,:MOONLIGHT],[20,:HOWL],[25,:SLAM],
             [30,:FIERYMANIA],[35,:DEFENDORDER],[40,:SUPERDAMADON],
             [45,:WINDYAEROBICS],[59,:DOOMSTAR],[66,:WINDSLASH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})


MultipleForms.register(:WIKIMEDIA,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:HEART,:ELECTRIC,:WATER,:GHOST,:BUG,:FAIRY,:DRAGON,:NORMAL,:GRASS,:DARK,:GHOST,:MIND]
   next getID(PBTypes,types[pokemon.form])
},  
 "type2"=>proc{|pokemon|
   types=[:NORMAL,:GLIMSE,:DARK,:WATER,:NORMAL,:BLIZZARD,:MAGIC,:DRAGON,:NORMAL,:FIRE,:SUN,:BOLT,:FIGHTING]
   next getID(PBTypes,types[pokemon.form])  
},

"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                                       # Meta (Normal)
   next [[getID(PBAbilities,:LEVITATE),0],
         [getID(PBAbilities,:FLOERYGIST),1],
         [getID(PBAbilities,:FIERYGIST),2]] if pokemon.form==1   # Foundation (Heart/Glimse)
   next [[getID(PBAbilities,:INTIMIDOOM),0],
         [getID(PBAbilities,:INTIMIDATE),1],
         [getID(PBAbilities,:INTIMILOW),2]] if pokemon.form==2   # Ombudsen (Electric/Dark)
   next [[getID(PBAbilities,:TRACE),0],
         [getID(PBAbilities,:WATERABSORB),1],
         [getID(PBAbilities,:WATERSPLASH),2]] if pokemon.form==3 # Commons (Water)
   next [[getID(PBAbilities,:STARPUNNY),0],
         [getID(PBAbilities,:SOLBEYU),1],
         [getID(PBAbilities,:LONGREACH),2]] if pokemon.form==4   # Otrs (Ghost/Normal)
   next [[getID(PBAbilities,:SOUNDTRACK),0],
         [getID(PBAbilities,:MINIMALIST),1],
         [getID(PBAbilities,:HERBLOBBY),2]] if pokemon.form==5   # Incubator (Bug/Blizzard)
   next [[getID(PBAbilities,:PICKUP),0],
         [getID(PBAbilities,:RIPEN),1],
         [getID(PBAbilities,:MAGICIAN),2]] if pokemon.form==6    # FDC (Fairy/Magic)
   next [[getID(PBAbilities,:RUNAWAY),0],
         [getID(PBAbilities,:METRONOME),1],
         [getID(PBAbilities,:ANTIFOGGER),2]] if pokemon.form==7  # Outreach (Dragon)
   next [[getID(PBAbilities,:SOUNDPROOF),0],
         [getID(PBAbilities,:PUNKROCK),1],
         [getID(PBAbilities,:UPLOAD),2]] if pokemon.form==8      # Quality (Normal)
   next [[getID(PBAbilities,:SLOWSTART),0],
         [getID(PBAbilities,:SPPEDBOOST),1],
         [getID(PBAbilities,:GOOEY),2]] if pokemon.form==9       # Strategic Planning (Grass/Fire)
   next [[getID(PBAbilities,:SINISTRO),0],
         [getID(PBAbilities,:LONGGRASS),1],
         [getID(PBAbilities,:FLASHFIRE),2]] if pokemon.form==10  # Strategic Planning (Grass/Fire)
   next [[getID(PBAbilities,:CURSEDBODY),0],
         [getID(PBAbilities,:CINEMALINTER),1],
         [getID(PBAbilities,:VERGINI),2]] if pokemon.form==11    # Movement Affiliates (Ghost/Bolt)
   next [[getID(PBAbilities,:SUPERCLEARBODY),0],
         [getID(PBAbilities,:SONIKO),1],
         [getID(PBAbilities,:MORFAT),2]] if pokemon.form==12     # Community User Group Sri Lanka (Mind/Fighting)
},
=begin
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:LEVITATE) # Foundation (Heart/Glimse)
     when 2; next getID(PBAbilities,:INTIMIDOOM) # Ombudsen (Electric/Dark)
     when 3; next getID(PBAbilities,:TRACE) # Commons (Water)
     when 4; next getID(PBAbilities,:STARPUNNY) # Otrs (Ghost/Normal)
     when 5; next getID(PBAbilities,:SOUNDTRACK) # Incubator (Bug/Blizzard)
     when 6; next getID(PBAbilities,:PICKUP) # FDC (Fairy/Magic)
     when 7; next getID(PBAbilities,:RUNAWAY) # Outreach (Dragon)
     when 8; next getID(PBAbilities,:SOUNDPROOF) # Quality (Normal)
     when 9; next getID(PBAbilities,:SLOWSTART) # Strategic Planning (Grass/Fire)
     when 10; next getID(PBAbilities,:SINISTRO) # Pennsylvania (Dark/Sun)
     when 11; next getID(PBAbilities,:CURSEDBODY) # Movement Affiliates (Ghost/Bolt)
     when 12; next getID(PBAbilities,:SUPERCLEARBODY) # Community User Group Sri Lanka (Mind/Fighting)
     else;   next # Meta (Normal)
   end
},
#"getFormOnCreation"=>proc{|pokemon|
#   d=pokemon.personalID&3
#   d|=((pokemon.personalID>>8)&3)<<2
#   d|=((pokemon.personalID>>16)&3)<<4
#   d|=((pokemon.personalID>>24)&3)<<6
#   d%=13
#   next d
#},
#"getFormOnCreation"=>proc{|pokemon|
#   next rand(11)
#},
#"getFormOnCreation"=>proc{|pokemon|
#   d=pokemon.personalID&3
#   d|=((pokemon.personalID>>8)&3)<<2
#   d|=((pokemon.personalID>>16)&3)<<4
#   d|=((pokemon.personalID>>24)&3)<<6
#   d%=12
#   r=rand(100)
#   if r==100;  next 0
#   elsif r<75; next d
#   elsif r<50;  next [rand(13),d].min
#   elsif r<25;  next rand(13)
#   end
#   next [rand(13),d].max
#
#},
=end

"getFormOnCreation"=>proc{|pokemon|
   formrations=[12,11,10,10,9,9,8,8,8,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0]
   next formrations[rand(48)]

},
"color"=>proc{|pokemon|
   next if !(pokemon.form==3 || pokemon.form==1)
   next 4 if pokemon.form==1
   next 1 if pokemon.form==3
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [95,54,100,38,15,15]
     when 2; next  [95,45,95,43,98,11]
     when 3; next  [95,75,29,48,75,37]
     when 4; next  [95,66,95,38,45,92]
     when 5; next  [95,70,70,50,45,15]
     when 6; next  [95,75,70,51,65,45]
     when 7; next  [95,75,45,49,20,40]
     when 8; next  [95,75,60,60,55,58]       
     when 9; next  [95,70,50,50,40,20]
     when 10; next [95,100,90,44,32,24]
     when 11; next [95,95,50,65,120,80]
     when 12; next [95,35,70,10,35,100]
     else;   next
   end
},

=begin
==WIKIMEDIA MOVELISTS==
Old Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:FLASH],[7,:GLARE],[10,:SLASH],
                       [14,:HIDDENPOWER],[17,:NATUREPOWER],[20,:THIEF],
                       [21,:HEALBLOCK],[25,:ICEFANG],[30,:FAIRYWIND],
                       [33,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:SING],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
Semi-New Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
New Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]
Meta/Lanka Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:NEUTRALIZINGGAS],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]
Incubator Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:FLASH],[7,:BLIZZARD],[10,:SLASH],
                       [14,:HIDDENPOWER],[17,:NATUREPOWER],[20,:THIEF],
                       [21,:HEALBLOCK],[25,:ICEFANG],[30,:FAIRYWIND],
                       [33,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:SING],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
Commons Learnest: movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:TACKLE],[8,:GROWL],[13,:HIDDENPOWER],
                       [15,:NATUREPOWER],[20,:HEALBLOCK],[20,:WATERGUN],[23,:STEELWING],
                       [30,:SOAK],[30,:FAIRYWIND],[37,:NIGHTSHADE],[40,:SNARL],
                       [45,:PINMISSILE],[47,:QUIVERDANCE],[56, :HEX],
                       [62,:MINDRECOVERCY]]
Old Learnest:        Form 4/7
Semi-New Learnest:   Form 8/9/11
New Learnest:        Form 1/2/6
Meta/Lanka Learnest: Form 0/12
Incubator Learnest:  Form 5
Commons Learnest:    Form 3/10
=end
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]
     when 2; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]                  
     when 3; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:TACKLE],[8,:GROWL],[13,:HIDDENPOWER],
                       [15,:NATUREPOWER],[20,:HEALBLOCK],[20,:WATERGUN],[23,:STEELWING],
                       [30,:SOAK],[30,:FAIRYWIND],[37,:NIGHTSHADE],[40,:SNARL],
                       [45,:PINMISSILE],[47,:QUIVERDANCE],[56, :HEX],
                       [62,:MINDRECOVERCY]]
     when 4; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:FLASH],[7,:GLARE],[10,:SLASH],
                       [14,:HIDDENPOWER],[17,:NATUREPOWER],[20,:THIEF],
                       [21,:HEALBLOCK],[25,:ICEFANG],[30,:FAIRYWIND],
                       [33,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:SING],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
     when 5; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:FLASH],[7,:BLIZZARD],[10,:SLASH],
                       [14,:HIDDENPOWER],[17,:NATUREPOWER],[20,:THIEF],
                       [21,:HEALBLOCK],[25,:ICEFANG],[30,:FAIRYWIND],
                       [33,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:SING],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
     when 6; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]
     when 7; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:FLASH],[7,:GLARE],[10,:SLASH],
                       [14,:HIDDENPOWER],[17,:NATUREPOWER],[20,:THIEF],
                       [21,:HEALBLOCK],[25,:ICEFANG],[30,:FAIRYWIND],
                       [33,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:SING],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]     
     when 8; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]
     when 9; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]                                              
     when 10; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:TACKLE],[8,:GROWL],[13,:HIDDENPOWER],
                       [15,:NATUREPOWER],[20,:HEALBLOCK],[20,:WATERGUN],[23,:STEELWING],
                       [30,:SOAK],[30,:FAIRYWIND],[37,:NIGHTSHADE],[40,:SNARL],
                       [45,:PINMISSILE],[47,:QUIVERDANCE], [56, :HEX],
                       [62,:MINDRECOVERCY]]
     when 11; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:SLASH],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:POISONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:SPIDERWEB],[64,:MINDRECOVERCY]]                                              
     when 12; movelist=[[0,:MEGADRAIN],[1,:MEGADRAIN],[1,:THIEF],[7,:GROWL],[10,:NEUTRALIZINGGAS],
                       [14,:HIDDENPOWER],[14,:NATUREPOWER],[20,:INGRAIN],
                       [21,:HEALBLOCK],[23,:SANDATTACK],[30,:FAIRYWIND],
                       [37,:SOAK],[37,:DRAGONTAIL],[45,:PINMISSILE],[50,:TACKLE],
                       [58,:RELICSONG],[64,:MINDRECOVERCY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:PLAYSTORE,{
"getFormOnCreation"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   d%=3
   next d
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 3; next getID(PBAbilities,:SOUNDPROOF)
     else;   next                                 
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 3; next [109,45,70,255,19,70]
     else;   next
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form!=3
   next 2 if pokemon.form==3
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:VODAFONE,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:FIRE) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:LICK) if pokemon.form==1 # Eternal
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [60,70,110,20,80,90] # Eternal
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:INFILTRATOR),0],
         [getID(PBAbilities,:ANTISHARPNESS),1],
         [getID(PBAbilities,:FLOERYGIST),2],
         [getID(PBAbilities,:SUPERCLEARBODY),3],
         [getID(PBAbilities,:TOUGHCLAWS),4]] if pokemon.form==1 # Eternal
},

"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE)] if pokemon.form==1 # Eternal
   next
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:FISSURE],[1,:LICK],[5,:MAGMATRIIVERSE],[5,:DRAININGKISS],
             [10,:REVELATIONDANCE],[10,:LICKLOCK],[20,:ATTRACT],[20,:FAIRYWIND],
             [40,:LICKLOCK],[40,:FIREBLAST],[80,:CASANOVA],[80,:LICKLINGLICK],
             [160,:SUNNYBLAST],[160,:MOONBLOVER],[320,:MAGMATRIIVERSE],[320,:REVELATIONDANCE]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Who know the fact about the ancient Vodafone? It was recently found on the MYSTERY ZONE building out an alternative world that wasn't found out yet.") if pokemon.form==1 # Eternal
},


"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Distortion") if pokemon.form==1  # Eternal
},


"getFormOnCreation"=>proc{|pokemon|
   maps=[112]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:WIKIMEDIAB,{
# Affects this Pokémon and its evolution (Wikimedia)
"getFormOnCreation"=>proc{|pokemon|
   formrations=[12,11,10,10,9,9,8,8,8,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0]
   next formrations[rand(48)]
}
})

MultipleForms.register(:BOMBOMEDIA,{
# Affects this Pokémon and its evolution (Uncyclomedia)
"getFormOnCreation"=>proc{|pokemon|
   formrations=[3,2,2,1,1,0,0,0,0]
   next formrations[rand(9)]
}
})


MultipleForms.register(:WIKIMANIA,{
"type2"=>proc{|pokemon|
   types=[:GUST,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:LIGHTER),0],
         [getID(PBAbilities,:SHINYGATHER),1],
         [getID(PBAbilities,:JUSTIFIED),2],
         [getID(PBAbilities,:INTIMILOW),3],
         [getID(PBAbilities,:STENCH),4]] if pokemon.form==1 # Dark Mode
   next                                                    # Light Mode
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 5 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   if pbGetMetadata($game_map.map_id,MetadataDarkMap) || 
     (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
     isConst?(pokemon.item,PBItems,:DUSKSTONE)
     next 1 # Dark Colors with White Text
   else
     next 0 # Classical Colors with Black Text
   end
}
})



MultipleForms.register(:UNCYCLOMEDIA,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:NORMAL,:WATER,:DOOM]
   next getID(PBTypes,types[pokemon.form])
},  
 "type2"=>proc{|pokemon|
   types=[:NORMAL,:ELECTRIC,:WATER,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])  
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0                                       # Unmeta (Normal)
   next [[getID(PBAbilities,:TRACE),0],
         [getID(PBAbilities,:VOLTABSORB),1],
         [getID(PBAbilities,:GALVANIZE),2]] if pokemon.form==1   # Foundation (Normal/Electric)
   next [[getID(PBAbilities,:CLOUDNINE),0],
         [getID(PBAbilities,:WATERABSORB),1],
         [getID(PBAbilities,:WATERBUBBLE),2]] if pokemon.form==2   # Commons (Water)
   next [[getID(PBAbilities,:BRIDINI),0],
         [getID(PBAbilities,:HIRALINA),1],
         [getID(PBAbilities,:MASKEDHERB),2]] if pokemon.form==3 # World Dimension/WD (Doom/Glimse)
},
=begin
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:TRACE) # Foundation (Normal/Electric)
     when 2; next getID(PBAbilities,:CLOUDNINE) # Commons (Water)
     when 3; next getID(PBAbilities,:BRIDINI) # World Dimension/WD (Doom/Glimse)
       else;   next 
   end
},
=end
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form == 1  || pokemon.form == 3
   next 1 if pokemon.form == 2
},
#"getFormOnCreation"=>proc{|pokemon|
#   d=pokemon.personalID&3
#   d|=((pokemon.personalID>>8)&3)<<2
#   d|=((pokemon.personalID>>16)&3)<<4
#   d|=((pokemon.personalID>>24)&3)<<6
#   d%=3
#   next d
#},
#"getFormOnCreation"=>proc{|pokemon|
#   next rand(3)
#},
#"getFormOnCreation"=>proc{|pokemon|
#   d=pokemon.personalID&3
#   d|=((pokemon.personalID>>8)&3)<<2
#   d|=((pokemon.personalID>>16)&3)<<4
#   d|=((pokemon.personalID>>24)&3)<<6
#   d%=3
#   r=rand(100)
#   if r==100;  next 0
#   elsif r<75; next d
#   elsif r<50;  next [rand(3),d].min
#   elsif r<25;  next rand(3)
#   end
#   next [rand(3),d].max
#},
"getFormOnCreation"=>proc{|pokemon|
   formrations=[3,2,2,1,1,0,0,0,0]
   next formrations[rand(9)]
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next [95,100,58,15,38,15]
     when 2; next [95, 65,93,66,38,45]
     when 3; next [95,55,100,0,45,77]
     else;   next
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
    when 1; movelist=[[0,:TACKLE],[1,:TACKLE],[1,:THIEF],[5,:GROWL],[14,:SWIFT],[18,:ICEFANG],
     [21,:INGRAIN],[24,:EDGE],[30,:SECRETPOWER],[33,:SLASH],[35,:HEALBLOCK],
     [40,:GLASSPUNCH],[42,:MAGICCROWN],[45,:DRAGONTAIL],[50,:FAKEOUT],
     [58,:SECRETSWORD],[64,:MINDRECOVERCY]]
    when 2; movelist=[[0,:TACKLE],[1,:TACKLE],[1,:MEGADRAIN],[5,:GROWL],[14,:WATERGUN],
     [18,:COPYCAT],[21,:INGRAIN],[24,:SEASHELL],[24,:EDGE],[28,:SECRETPOWER],
     [30,:CHARM],[33,:SLASH],[35,:PINMISSILE],[40,:GLASSPUNCH],[42,:SOAK],
     [45,:AQUATAIL],[50,:FAKEOUT],[58,:SECRETSWORD],[64,:MINDRECOVERCY]]
    when 3; movelist=[[0,:TACKLE],[1,:TACKLE],[1,:DREAMYRECOVERCY],[5,:GROWL],
     [14,:MINDYGLOPS],[18,:COPYCAT],[22,:DOOMSURPLETE],[24,:EDGE],
     [30,:SLASH],[33,:GLIMSETREAT],[35,:METRONOME],[40,:SWIFT],
     [42,:GLIMMYGALAXY],[45,:GENIEDREAM],[50,:DOOMARIETTA],[58,:MIMIC],
     [64,:MINDRECOVERCY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:KRISKRIS,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:LICK) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:FAIRY) if pokemon.form==1 # Eternal
   next getID(PBTypes,:HERB)  if pokemon.form==2 # Ζυμώνει ότι αξίζει - Alternate
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [100,20,20,90,120,120] # Eternal
     when 2; next  [95,10,10,100,115,125] # Ζυμώνει ότι αξίζει - Alternate
     else;   next
   end
},
"color"=>proc{|pokemon|
   next if pokemon.form!=1
   next 3
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:INFILTRATOR),0],
         [getID(PBAbilities,:ANTISHARPNESS),1],
         [getID(PBAbilities,:FLOERYGIST),2],
         [getID(PBAbilities,:SUPERCLEARBODY),3],
         [getID(PBAbilities,:TOUGHCLAWS),4]] if pokemon.form==1 # Eternal
},

"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE)] if pokemon.form==1 # Eternal
   next [0,
         getID(PBItems,:HERBGEM),
         getID(PBItems,:BOTANICPLATE)]   if pokemon.form==2 # Ζυμώνει ότι αξίζει - Alternate
   next
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:CHROMELICKS],[1,:MOONBLAST],[5,:REVELATIONDANCE],[5,:DRAININGKISS],
             [10,:HERBALPUNCH],[10,:HERBOTOPIA],[20,:ATTRACT],[20,:FAIRYWIND],
             [40,:SALAZIRE],[40,:DISARMINGVOICE],[80,:CASANOVA],[80,:HARASHLICKMENTO],
             [160,:SUNNYBLAST],[160,:MOONBLOVER],[320,:REVELATIONDANCE],[320,:HERBALPUNCH]] if pokemon.form==1 # Eternal
   movelist=[[1,:IRONDEFENSE],[1,:SWIFT],[15,:METRONOME],[15,:HOWL],
             [30,:HERBSLAM],[30,:EAGLEWIND],[45,:SLASH],[45,:DAZZLINGLICK],
             [60,:FURYCUTTER],[60,:ASSIST],[70,:SUNNYDRAGON],[70,:GRASSKNOT],
             [80,:HEX],[90,:SWEETSODA],[90,:DOOMPRETZEL],[100,:EXPLOSION],
             [105,:HERBLEAF],[110,:SIAXIS]] if pokemon.form==2 # Ζυμώνει ότι αξίζει - Alternate
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Who know the fact about the ancient Kris Kris? It was recently found on the MYSTERY ZONE building out an alternative world that wasn't found out yet.") if pokemon.form==1 # Eternal
   next _INTL("Kris Kris was found at the Medical Caves along with LG and Vodafone. It serves botanic help at all times, archeologists said") if pokemon.form==2                          # Ζυμώνει ότι αξίζει - Alternate
},


"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Distortion") if pokemon.form==1  # Eternal
   next _INTL("Botanical")  if pokemon.form==2  # Ζυμώνει ότι αξίζει - Alternate
},


"getFormOnCreation"=>proc{|pokemon|
   maps=[112]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next [0,2][rand(2)] # Using just rand(2) won't work because form 1 is Eternal Forme
   end
}
})

MultipleForms.register(:LG,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:GUST) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:DRAGON) if pokemon.form==1 # Eternal
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [100,25,30,100,130,110] # Eternal
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:INFILTRATOR),0],
         [getID(PBAbilities,:ANTISHARPNESS),1],
         [getID(PBAbilities,:FLOERYGIST),2],
         [getID(PBAbilities,:SUPERCLEARBODY),3],
         [getID(PBAbilities,:TOUGHCLAWS),4]] if pokemon.form==1 # Eternal
},
"color"=>proc{|pokemon|
   next if pokemon.form!=1
   next 3
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE),
         getID(PBItems,:ABILITYCAPSULE)] if pokemon.form==1 # Eternal
   next
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:HORNDRILL],[1,:MOONBLAST],[5,:GUSTATTACK],[5,:DRAININGKISS],
             [10,:GUSTINGPOND],[10,:DOOMTACKLE],[20,:ATTRACT],[20,:FAIRYWIND],
             [40,:GUSTUP],[40,:OUTRGAE],[80,:CASANOVA],[80,:DAMADON],
             [160,:SUNNYBLAST],[160,:MOONBLOVER],[320,:GUSTATTACK],[320,:GUSTINGPOND]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Who know the fact about the ancient LG? It was recently found on the MYSTERY ZONE building out an alternative world that wasn't found out yet.") if pokemon.form==1 # Eternal
},


"kind"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Distortion") if pokemon.form==1  # Eternal
},


"getFormOnCreation"=>proc{|pokemon|
   maps=[112]   # Map IDs for Eternal Forme
   if $game_map && maps.include?($game_map.map_id)
     next 1 # Eternal
   else
     next 0 
   end
}
})


MultipleForms.register(:FADOM,{
"type1"=>proc{|pokemon|
   types=[:HERB,:SHARPENER]
   next getID(PBTypes,types[pokemon.form])
},

"type2"=>proc{|pokemon|
   types=[:FAIRY,:HEART]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:SUPERCLEARBODY)
     else;   next 
   end
},

"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:METRONOME)    # Super Fandom
   next 0
},
   
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next [160,190,100,90,250,188]
     else;   next
     end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0
   next _INTL("Fandom's Heart becomes gradientless when it helds a Metronome. Its satura clear body can make it invulnerable to any non-attack damage. Weird?")
},
=begin
  "getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
    when 1; movelist=[[1,:MAGICHAND],[1,:EDGE],[2,:STUNSPORE],[5,:TACKLE],
                      [8,:FAIRYWIND],[10,:THUNDERFANG],[11,:SLAM],
                      [19,:METRONOME],[24,:HORNDRILL],[28,:CASANOVA],
                      [30,:MOONBLAST],[34,:EDGE],[40,:SLASH],[45,:MAGICCROWN],
                      [50,:FINALGAMBIT],[58,:POISONFANG],[58,:DRAGONDANCE],
                      [58,:JEWELLERY],[58,:SPEEDYKICK],[66,:DESTINYSCROLL],
                      [70,:MAGICBOMB],[70,:MAGMABOMB],[99,:TOSTI],
                      [120,:GLASSPUNCH]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
=end
})


# Alphatv does not have actual mutliple forms but it is set because Female ones
# should be Fire, not water
MultipleForms.register(:ALPHATV,{
  
 "type2"=>proc{|pokemon|
   types=[:WATER,:FIRE]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 0 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

# Κουλουνδομόρφοση toggles battler's form
MultipleForms.register(:KOULUNDIN,{
 "type1"=>proc{|pokemon|
   types=[:SUN,:FLYING]
   next getID(PBTypes,types[pokemon.form])  
},  
 "type2"=>proc{|pokemon|
   types=[:MOON,:WIND]
   next getID(PBTypes,types[pokemon.form])  
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next [255,55,200,255,55,200]
     else;   next
     end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   next 70
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   next 100
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("LEGO Minifigure") if pokemon.form==1
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("A Κουλούνδιν has been seen transforming again and again in the Anime. Who knows the exact cause of this?") if pokemon.form==1
},
"onSetForm"=>proc{|pokemon,form|
   pbSEPlay("GUI party switch") # Not played from the transform script
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:FIREFOX,{
"getForm"=>proc{|pokemon|
   env=pbGetEnvironment()
   if env==PBEnvironment::Galaxy
     next 2 # Dev
   elsif pbGetMetadata($game_map.map_id,MetadataDarkMap) || 
     (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
     isConst?(pokemon.item,PBItems,:DUSKSTONE)
     next 1 # Nightly
   else
     next 0 # Normal
   end
}
})

MultipleForms.register(:FENIX,{
"type1"=>proc{|pokemon|
   types=[:SUN,:LICK,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:CURSEDBODY),0],
         [getID(PBAbilities,:SONIKO),1],
         [getID(PBAbilities,:CONTRARY),2],
         [getID(PBAbilities,:SIAXIS),3]] if pokemon.form==1 # Eternal
   next [[getID(PBAbilities,:MARIAMARA),0],
         [getID(PBAbilities,:SONIKO),1],
         [getID(PBAbilities,:CONTRARY),2],
         [getID(PBAbilities,:SIAXIS),3]] if pokemon.form==2 # Eternal
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:SPOOKYPLATE),
         getID(PBItems,:GHOSTGEM),
         0] if pokemon.form==1
   next [getID(PBItems,:DREADPLATE),
         getID(PBItems,:DARKGREM),
         0] if pokemon.form==2
   next
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
   next 1 if pokemon.form==2
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[[0,:LOCK],[1,:EDGE],[1,:FAIRYWIND],[4,:DESTINYSCROLL],
             [6,:SWORDSDANCE],[10,:STEELWING],[12,:LICKINGLICK],
             [12,:GROWL],[14,:METRONOME],[18,:DRAGONDANCE],
             [20,:FLASHCANNON],[24,:SHADOWSNEAK],[24,:FALSESWIPE],[28,:ATTRACT],
             [32,:AMNESIA],[35,:REST],[35,:DRAGONBREATH],
             [40,:KHLERI],[45,:DRAGONRAGE],[50,:VCREATE],
             [55,:DRAGONITI],[60,:SHADOWPUNCH],[66,:SUNNYDRAGON]] if pokemon.form==1 # Eternal
   movelist=[[0,:MOONGEIST],[1,:EDGE],[1,:FAIRYWIND],[4,:PURSUIT],
             [6,:SWORDSDANCE],[10,:STEELWING],[12,:GLIMSETREAT],
             [12,:GROWL],[14,:METRONOME],[18,:DRAGONDANCE],
             [20,:FLASHCANNON],[24,:ASSURANCE],[24,:FALSESWIPE],[28,:ATTRACT],
             [32,:AMNESIA],[35,:REST],[35,:DRAGONBREATH],
             [40,:KHLERI],[45,:DRAGONRAGE],[50,:VCREATE],
             [55,:DRAGONITI],[60,:DARKPUNCH],[66,:SUNNYDRAGON]] if pokemon.form==2 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"getForm"=>proc{|pokemon|
   env=pbGetEnvironment()
   if env==PBEnvironment::Galaxy
     next 2 # Dev
   elsif pbGetMetadata($game_map.map_id,MetadataDarkMap) || 
     (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
     isConst?(pokemon.item,PBItems,:DUSKSTONE)
     next 1 # Nightly
   else
     next 0 # Normal
   end
}
})

MultipleForms.register(:ONE,{
"type1"=>proc{|pokemon|
   types=[:FIGHTING,:GRASS,:WATER,:ROCK,:GROUND,:BUG,:ICE,:FIRE,:GHOST,:FLYING,
          :DRAGON,:MOON,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"color"=>proc{|pokemon|
   next [0,3,1,2,2,3,1,2,6,1,6,4,5][pokemon.form]
},
"getBaseStats"=>proc{|pokemon|
   next                     if pokemon.form%2==0
   next [100,75,35,150,35,75]
},
"getFormOnCreation"=>proc{|pokemon|
    type = 0;
    case pbGetEnvironment()
    when PBEnvironment::None;        type=0  # Fighting
    when PBEnvironment::Grass;       type=1  # Grass
    when PBEnvironment::TallGrass;   type=1  # Grass
    when PBEnvironment::MovingWater; type=2  # Water
    when PBEnvironment::StillWater;  type=2  # Water
    when PBEnvironment::Underwater;  type=2  # Water
    when PBEnvironment::Cave;        type=3  # Rock
    when PBEnvironment::Rock;        type=4  # Ground
    when PBEnvironment::Sand;        type=4  # Ground
    when PBEnvironment::Forest;      type=5  # Bug
    when PBEnvironment::Snow;        type=6  # Ice
    when PBEnvironment::Volcano;     type=7  # Fire
    when PBEnvironment::Graveyard;   type=8  # Ghost
    when PBEnvironment::Sky;         type=9  # Flying
    when PBEnvironment::Space;       type=10 # Dragon
    when PBEnvironment::Galaxy;      type=11 # Moon
    when PBEnvironment::Boardwalk;   type=12 # Dark
    end
    next type
}
})


MultipleForms.register(:DOLPHIN,{
"getBaseStats"=>proc{|pokemon|
   next                     if pokemon.form==0      # Field
   next [60,20,60,50,30,90] if pokemon.form==1      # Octum
   next [60,60,20,30,90,30] if pokemon.form==2      # Stealth
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  145
     when 2; next  140
     else;   next
   end
},
"type1"=>proc{|pokemon|
   types=[:NORMAL,:WATER,:WATER]
   next getID(PBTypes,types[pokemon.form])
},  
 "type2"=>proc{|pokemon|
   types=[:NORMAL,:WATER,:ROCK]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 1 if pokemon.form==1
   next 5 if pokemon.form==2
},
})

MultipleForms.register(:FLAMENGO,{
"type2"=>proc{|pokemon|
   types=[:LAVA,:FIRE] # It didn't originally stayed
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [200,45,30,10,40,60]
     else;   next
   end
},
"baseExp"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  125
     else;   next
   end
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0 
   next _INTL("As Flamengos tend to increase in size, they also start to be more defensive and more slower as opposed to while they weren't.") if pokemon.form==1
},
"height"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  45
     else;   next
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  180
     else;   next
   end
}
})

MultipleForms.register(:SQUIGGLES,{
"getForm"=>proc{|pokemon|
    type = 0
    case pbGetEnvironment()
    when PBEnvironment::None;        type=0  # Fighting
    when PBEnvironment::Grass;       type=1  # Grass
    when PBEnvironment::TallGrass;   type=1  # Grass
    when PBEnvironment::MovingWater; type=2  # Water
    when PBEnvironment::StillWater;  type=2  # Water
    when PBEnvironment::Underwater;  type=2  # Water
    when PBEnvironment::Cave;        type=3  # Rock
    when PBEnvironment::Rock;        type=4  # Ground
    when PBEnvironment::Sand;        type=4  # Ground
    when PBEnvironment::Forest;      type=5  # Bug
    when PBEnvironment::Snow;        type=6  # Ice
    when PBEnvironment::Volcano;     type=7  # Fire
    when PBEnvironment::Graveyard;   type=8  # Ghost
    when PBEnvironment::Sky;         type=9  # Flying
    when PBEnvironment::Space;       type=10 # Dragon
    when PBEnvironment::Galaxy;      type=11 # Moon
    when PBEnvironment::Boardwalk;   type=12 # Dark
    end
    next type
}
})



MultipleForms.register(:SALEM,{
"type1"=>proc{|pokemon|
   types=[:GHOST,:POISON,:GRASS,:DOOM,:SUN,:FIRE]
   next getID(PBTypes,types[pokemon.form])
},  
 "type2"=>proc{|pokemon|
   types=[:ELECTRIC,:ELECTRIC,:LICK,:LICK,:FIGHTING,:FIGHTING]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1  if (isConst?(pokemon.item,PBItems,:POISONBOX) ||
               isConst?(pokemon.item,PBItems,:TOXICPLATE))   # Poison
   next 2  if (isConst?(pokemon.item,PBItems,:GRASSBOX) ||
               isConst?(pokemon.item,PBItems,:MEADOWPLATE))  # Grass
   next 3  if (isConst?(pokemon.item,PBItems,:DOOMBOX) ||
              isConst?(pokemon.item,PBItems,:BOMBPLATE))      # Doom
   next 4  if (isConst?(pokemon.item,PBItems,:SUNBOX) ||
              isConst?(pokemon.item,PBItems,:SUNSHINEPLATE))   # Sun
   next 5  if (isConst?(pokemon.item,PBItems,:FIRESTONE) ||
              isConst?(pokemon.item,PBItems,:FLAMEPLATE))   # Fire
   next 0
},
"color"=>proc{|pokemon|
   next if pokemon.form<2
   next 3 if pokemon.form==2
   next 4 if pokemon.form==3
   next 0 if pokemon.form>3
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves1=[
      :SHADOWCLAW,
      :SODASWAMP,
      :VINEWHIP,
      :DOOMCLAW,
      :SUNNYBLAST,
      :FIREBLAST
   ]
   moves2=[
      :THUNDER,
      :LIGHTBALL,
      :LICKINGLICK,
      :LICKPUNCH,
      :LOWSWEEP,
      :LEGSWIDTH
   ]
   # 1st Special Move
if !$inbattle # Avoid Glitches with trainer battles
   hasoldmove1=-1
   for i in 0...4
     for j in 0...moves1.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves1[j])
         hasoldmove1=i; break
       end
     end
     break if hasoldmove1>=0
   end
   if true # Intentionally wanted to keep this
     newmove1=moves1[form]
     if newmove1!=nil && hasConst?(PBMoves,newmove1) && !pokemon.knowsMove?(newmove1)
       if hasoldmove1>=0
         # Automatically replace the old form's 1st special move with the new one's
         oldmovename1=PBMoves.getName(pokemon.moves[hasoldmove1].id)
         newmovename1=PBMoves.getName(getID(PBMoves,newmove1))
         pokemon.moves[hasoldmove1]=PBMove.new(getID(PBMoves,newmove1))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename1))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename1))
       elsif !pokemon.knowsMove?(newmove1)
         # Try to learn the new form's 1st special move
         pbLearnMove(pokemon,getID(PBMoves,newmove1),true)
       end
     end
   else
     if hasoldmove1>=0
       # Forget the old form's 1st special move
       oldmovename1=PBMoves.getName(pokemon.moves[hasoldmove1].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove1)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename1))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:SHADOWCLAW))
       end
     end
   end
   # 2nd Special Move
   hasoldmove2=-1
   for i in 0...4
     for j in 0...moves2.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves2[j])
         hasoldmove2=i; break
       end
     end
     break if hasoldmove2>=0
   end
   if true # Intentionally wanted to keep this
     newmove2=moves2[form]
     if newmove2!=nil && hasConst?(PBMoves,newmove2) && !pokemon.knowsMove?(newmove2)
       if hasoldmove2>=0
         # Automatically replace the old form's 2nd special move with the new one's
         oldmovename2=PBMoves.getName(pokemon.moves[hasoldmove2].id)
         newmovename2=PBMoves.getName(getID(PBMoves,newmove2))
         pokemon.moves[hasoldmove2]=PBMove.new(getID(PBMoves,newmove2))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename2))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[MoveLearnt]",pokemon.name,newmovename2))
       elsif !pokemon.knowsMove?(newmove2)
         # Try to learn the new form's 1st special move
         pbLearnMove(pokemon,getID(PBMoves,newmove2),true)
       end
     end
   else
     if hasoldmove2>=0
       # Forget the old form's 2nd special move
       oldmovename2=PBMoves.getName(pokemon.moves[hasoldmove2].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove2)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename2))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:THUNDER))
       end
     end
   end
end
}

})


MultipleForms.register(:ETV,{
"getFormOnCreation"=>proc{|pokemon|
   formrations= ($Trainer.isFemale?) ? [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1] : [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1]
   next formrations[rand(15)]
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form<2
   next [[getID(PBAbilities,:PARENTALBOND),0]]
}
})


# MS Office only has graphical differences in a form
# Form must be set as 4E in order to allow it evolve with other species (Such as evolving a 4E into an Microsoft Office 2010)
MultipleForms.register(:FOURE,{
"getFormOnCreation"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   d%=4
   formrations=[[0,0,0,0,1,1,1,2,2,3],[3,3,3,3,2,2,2,1,1,0],[0,0,0,0,2,2,2,3,3,1],[1,1,1,1,3,3,3,0,0,2]] # This variable is set into an array list of four sub-arrays with ten values in each one
   formrations=formrations[d] # Which array will pick will depend on personalID
   next formrations[rand(10)] # Then one of the ten random numbers of the chosen sub-array will set 4E's and Microsoft Office's form. Bred Office will give a 4E egg into the form it was
}
})

MultipleForms.copy(:FOURE,:OFFICE)


MultipleForms.register(:SALLONN,{
 "type2"=>proc{|pokemon|
   types=[:GHOST,:WIND]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 3 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   if pbGetMetadata($game_map.map_id,MetadataDarkMap) || 
     (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
     isConst?(pokemon.item,PBItems,:DUSKSTONE)
     next 0 # Ghost Form - Nightly
   else
     next 1 # Wind Form - Ringify
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:SALLONN,:SOURLLONN,:SOURLLAXX)


MultipleForms.register(:ROOMBA,{
 "type1"=>proc{|pokemon|
   types=[:FAIRY,:ELECTRIC,:CHLOROPHYLL,:MIND,:ELECTRIC,:CHLOROPHYLL]
   next getID(PBTypes,types[pokemon.form])  
},
 "type2"=>proc{|pokemon|
   types=[:MIND,:MIND,:MIND,:DOOM,:DOOM,:DOOM]
   next getID(PBTypes,types[pokemon.form])  
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form<3        # Classiko
   next [60,140,160,0,160,140]   # Ultra Blue formes
},
"getFormOnCreation"=>proc{|pokemon|
   next [rand(3),rand(3)].min
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 2 if pokemon.form==1
   next 3 if pokemon.form==2
   next 4 if pokemon.form>2
},
"getFormOnCroteline"=>proc{|pokemon|
   next [rand(3),rand(3)].min
},
"getFormOnPES"=>proc{|pokemon|
   next [rand(3),rand(3)].min
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==3               # Fairist
   next [0,3,0,0,0,0] if pokemon.form==1 || pokemon.form==4 # Electrist
   next [0,0,0,3,0,0] if pokemon.form==2 || pokemon.form==5 # Chlorophyllist
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:PERSIMBERRY),
         getID(PBItems,:RINGTARGET),
         getID(PBItems,:MINDPLATE)] if pokemon.form==1
   next [getID(PBItems,:RAWSTBERRY),
         getID(PBItems,:RINGTARGET),
         getID(PBItems,:MINDPLATE)] if pokemon.form==2
   next
},
"kind"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form==3
   next _INTL("Electric Glyph") if pokemon.form==1 || pokemon.form==4
   next _INTL("Chlorophyll Glyph") if pokemon.form==2 || pokemon.form==5
},
"dexEntry"=>proc{|pokemon|
   next if pokemon.form<3
   next _INTL("Roomba has undergo a special graduation, namely Ultra Blue. Who wants to know about the ancient black glyphs before being turned onto a colorful ones?")
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   if form>2
     Kernel.pbMessage(_INTL("Roomba is undergo a graduation"))
     Kernel.pbMessage(_INTL("It gives back its true form with impressive power but lower speed"))
     Kernel.pbMessage(_INTL("If one tries to hit Roomba, it has a chance of reverting the graduation"))
   end
}
})

MultipleForms.register(:ALTERCHANNEL,{
 "type1"=>proc{|pokemon|
   types=[:HERB,:LICK]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 4 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:LICKLOCK)    # Inverted
   next 0                                     # Ordinal
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ALTERPLUS,{
 "type1"=>proc{|pokemon|
   types=[:HERB,:LICK]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:LICKLOCK)    # Inverted
   next 0                                     # Ordinal
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:ALTERPLUS,:MEGAPLUS)

MultipleForms.register(:JOICON,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,:DOOM,:JELLY,
          :SHARPENER,:LAVA,:WIND,:LICK,:BOLT,:HERB,:CHLOROPHYLL,
          :GUST,:SUN,:MOON,:MIND,:HEART,:BLIZZARD,:GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:MAGIC,:DOOM,:JELLY,
          :SHARPENER,:LAVA,:WIND,:LICK,:BOLT,:HERB,:CHLOROPHYLL,
          :GUST,:SUN,:MOON,:MIND,:HEART,:BLIZZARD,:GAS,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"color"=>proc{|pokemon|
   next [8,0,6,6,2,2,3,6,7,0,1,3,2,9,1,6,5,9,2,4,9,8,0,3,5,6,2,3,1,2,4,9,9,1,3,4][pokemon.form]
},
"getForm"=>proc{|pokemon|
   d=pokemon.iv[0]+pokemon.iv[1]+pokemon.iv[2]+pokemon.iv[3]+pokemon.iv[4]+pokemon.iv[5]
   d%=36 # 36 Different Flavors, which one will be depeneds on Individual Values
   next d
}
})

MultipleForms.register(:PLUNUM,{
"getFormOnCreation"=>proc{|pokemon|
   formrations= ($Trainer.isFemale?) ? [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1] : [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1]
   next formrations[rand(15)]
}
})

MultipleForms.register(:FENPLUS,{
"type1"=>proc{|pokemon|
   types=[:SUN,:LICK,:GLIMSE]
   next getID(PBTypes,types[pokemon.form])
},
"wildHoldItems"=>proc{|pokemon|
   next [getID(PBItems,:SPOOKYPLATE),
         getID(PBItems,:GHOSTGEM),
         0] if pokemon.form==1
   next [getID(PBItems,:DREADPLATE),
         getID(PBItems,:DARKGREM),
         0] if pokemon.form==2
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0 || pokemon.form>2
   movelist=[[0,:DOOMCROKET],[1,:LOCK],[1,:EDGE],[1,:FAIRYWIND],
             [4,:DESTINYSCROLL],[6,:SWORDSDANCE],[10,:STEELWING],
             [12,:LICKINGLICK],[12,:GROWL],[14,:METRONOME],[18,:DRAGONDANCE],
             [20,:FLASHCANNON],[24,:SHADOWSNEAK],[24,:FALSESWIPE],[28,:ATTRACT],
             [32,:AMNESIA],[35,:REST],[35,:DRAGONBREATH],
             [40,:KHLERI],[45,:DRAGONRAGE],[50,:VCREATE],
             [55,:DRAGONITI],[60,:SHADOWPUNCH],[66,:SUNNYDRAGON]] if pokemon.form==1 # Eternal
   movelist=[[0,:DOOMCROKET],[1,:MOONGEIST],[1,:EDGE],[1,:FAIRYWIND],[4,:PURSUIT],
             [6,:SWORDSDANCE],[10,:STEELWING],[12,:GLIMSETREAT],
             [12,:GROWL],[14,:METRONOME],[18,:DRAGONDANCE],
             [20,:FLASHCANNON],[24,:ASSURANCE],[24,:FALSESWIPE],[28,:ATTRACT],
             [32,:AMNESIA],[35,:REST],[35,:DRAGONBREATH],
             [40,:KHLERI],[45,:DRAGONRAGE],[50,:VCREATE],
             [55,:DRAGONITI],[60,:DARKPUNCH],[66,:SUNNYDRAGON]] if pokemon.form==2 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getForm"=>proc{|pokemon|
   env=pbGetEnvironment()
   if env==PBEnvironment::Galaxy
     next 2 # Dev
   elsif pbGetMetadata($game_map.map_id,MetadataDarkMap) || 
     (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
     isConst?(pokemon.item,PBItems,:DUSKSTONE)
     next 1 # Nightly
   else
     next 0 # Normal
   end
}
})



# Candy Crush Soda does not have sprite differences, only ability ones
# If Soda Saga loses SIAXIS ability due to different form, it won't lose it
MultipleForms.register(:CANDYCRUSHSODA,{
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:SINISTRO),0]]   if pokemon.form==1
   next [[getID(PBAbilities,:SOUNDPROOF),0]] if pokemon.form==2
   next [[getID(PBAbilities,:LONGREACH),0]]  if pokemon.form==3
   next [[getID(PBAbilities,:SIAXIS),0]]     if pokemon.form==4
},
"getMoveCompatibility"=>proc{|pokemon|
   next if pokemon.form!=4
   movelist=[:HONECLAWS,:ROAR,:HIDDENPOWER,:PROTECT,:SAFEGUARD,
             :DOUBLETEAM,:FACADE,:REST,:ROUND,:ALLYSWITCH,
             :CUT,:STRENGTH,:WRAPPEDTACKLE,:SALAZIRE,:SNATCH,
             :SWIFT,:SODASWAMP,:SIAXIS,:COACHING]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
     next rand(5)
},
"getFormOnPES"=>proc{|pokemon|
     next rand(5)
}
})

MultipleForms.copy(:CANDYCRUSHSODA,:SODAPLUS)

# Form set for Pac-Man is handled elsewhere
MultipleForms.register(:PACMAN,{
"type1"=>proc{|pokemon|
   next if pokemon.form!=3                 # Everything else
   next getID(PBTypes,:BOLT)               # Cinema
},
"type2"=>proc{|pokemon|
   next if pokemon.form!=3                 # Everything else
   next getID(PBTypes,:BOLT)               # Cinema
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                 # Everything else
   case pokemon.form
     when 2; next [30,50,255,100,50,255]   # Emergency
     when 3; next [30,100,120,50,100,120]  # Cinema
     else;   next
     end
},
"kind"=>proc{|pokemon|
   next if pokemon.form!=3                 # Everything else
   next _INTL("Cinemascope-Men")           # Cinema
},
"color"=>proc{|pokemon|
   next if pokemon.form==0                 # Inactive
   next 2 if pokemon.form==1               # Active
   next 1 if pokemon.form==2               # Emergenncy
   next 0 if pokemon.form==3               # Cinema
},
"getFormOnCroteline"=>proc{|pokemon|       # Form set on FLINT Minigame Protain Mag
   next 1
},
"getFormOnPES"=>proc{|pokemon|             # Form set on FLINT Pro Evolution Soccer Mag
   if $flint_pes_life_tisekato <= 25        # $flint_pes_life_tisekato is the amount of life current member has in percentages
     next 2 # Emergency
   elsif $flint_pes_condition_tounite      # $flint_pes_condition_tounite is true if the player is playing well
     next 3 # Cinema
   elsif $flint_pes_soccering              # $flint_pes_soccering is true if a match happens
     next 1 # Active
   end
   next 0   # Inactive
},
"dexEntry"=>proc{|pokemon|
   next                                                                                                                                                                                                        if pokemon.form==0                       # Inactive
   next _INTL("This is the form Pac-Man takes when it enters a battle. Males are more likely to battle with others and play with its abilities.")                                                              if pokemon.isMale? && pokemon.form==1    # Active (Male)
   next _INTL("This is the form Pac-Man takes when it enters a battle. Females on the other hand seem to care about the babies more than battling with others.")                                               if pokemon.isFemale? && pokemon.form==1  # Active (Female)
   next _INTL("This is the form Pac-Man takes when it sees danger. Males usually call for help when they see other Pokémon in front of it.")                                                                   if pokemon.isMale? && pokemon.form==2    # Emergency (Male)
   next _INTL("This is the form Pac-Man takes when it sees danger. Females on the other hand, are more curious about their status problem so they call anything for help, even a person in order to survive.") if pokemon.isFemale? && pokemon.form==2  # Emergency (Female)
   next _INTL("This is the form Pac-Man takes when Cinament is emergenced. Both males and females are capable of taking their bolty power and hurling it onto the opposing Pokémon.")                          if pokemon.form==3                       # Cinema
}

})

MultipleForms.register(:MEGACHANNEL,{
 "type1"=>proc{|pokemon|
   types=[:HERB,:LICK]
   next getID(PBTypes,types[pokemon.form])  
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 8 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:LICKLOCK)    # Inverted
   next 0                                     # Ordinal
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


# ΔΤ does not have alternative forms but since we have some spots, we need to set
# them through here
MultipleForms.register(:DIMOSIA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbDimosiaSpots(pokemon,bitmap)
}
})


MultipleForms.register(:NERIT,{
"type2"=>proc{|pokemon|
   types=[:WATER,:FIRE,:GRASS,:ELECTRIC,:BOLT]
   next getID(PBTypes,types[pokemon.form])
},
"color"=>proc{|pokemon|
   next if pokemon.form==0 
   next 0 if pokemon.form==1
   next 3 if pokemon.form==2
   next 2 if pokemon.form==3
   next 6 if pokemon.form==4
}
})

MultipleForms.register(:ANAMARIOBIRD,{
 "type1"=>proc{|pokemon|
   types=[:MOON,:BOLT]
   next getID(PBTypes,types[pokemon.form])  
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:REVELATIONDANCE],[1,:NIGHTMOON],[5,:WINDBOLT],
             [9,:MAGICSCRATCH],[14,:GEOMANCY],[18,:MIRRORMOVE],
             [25,:THUNDERBOLT],[30,:CHLOROPHYLL],[34,:MEMENTO],
             [40,:BRAVEBONE],[40,:BOLTOPIA],[48,:GUST],
             [57,:SUPERMEMENTO],[57,:NATUREPOWER],[80,:BOLTYDREAM],
             [80,:HEALINGWISH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"color"=>proc{|pokemon|
   next if pokemon.form==0 
   next 2 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
}
})

MultipleForms.register(:ANALUIGIBIRD,{
 "type1"=>proc{|pokemon|
   types=[:HEART,:LAVA]
   next getID(PBTypes,types[pokemon.form])  
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:REVELATIONDANCE],[1,:NIGHTMOON],[5,:LAVACORN],
             [9,:MAGICSCRATCH],[14,:GEOMANCY],[18,:MIRRORMOVE],
             [25,:LAVAPLUME],[30,:GUST],[34,:MEMENTO],
             [40,:BRAVEBONE],[40,:LAVACRAYON],[48,:CHLOROPHYLL],
             [57,:SUPERMEMENTO],[57,:NATUREPOWER],[80,:LAVAOVER],
             [80,:HEALINGWISH]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"color"=>proc{|pokemon|
   next if pokemon.form==0 
   next 0 if pokemon.form==1
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
}
})

# The form Star Channel it is set after ending a battle is handled elsewhere
# Star Channel can alternate between types without even having a graphical change
# If star channel is Heart or Glimse type, it can do moves regardless of its abilities
MultipleForms.register(:STARCHANNEL,{
 "type1"=>proc{|pokemon|
   types=[:NORMAL,:HERB,:POISON,:DOOM,:LAVA]
   next getID(PBTypes,types[pokemon.form])  
},
 "type2"=>proc{|pokemon|
   types=[:GLIMSE,:LICK,:HEART,:DRAGON,:FLYING]
   next getID(PBTypes,types[pokemon.form])  
},
"getFormOnCreation"=>proc{|pokemon|
     next rand(5)
},
"getFormOnPES"=>proc{|pokemon|
     next rand(5)
}
})


MultipleForms.register(:DIGIWORM,{
"getFormOnCreation"=>proc{|pokemon|
  next[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2][rand(30)]
},
 "type1"=>proc{|pokemon|
   types=[:NORMAL,:GROUND,:SHARPENER]
   next getID(PBTypes,types[pokemon.form])  
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:GROUND,:SHARPENER]
   next getID(PBTypes,types[pokemon.form])  
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:EERIEQUAKE],[1,:ROCKYFLECTOR],[1,:SILVERYBLISS]] if pokemon.form==1
   movelist=[[1,:ROCKYHELMET],[1,:SILVERYBLISS]] if pokemon.form==2
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.copy(:DIGIWORM,:DALIAWORM)


MultipleForms.register(:SYLVIA,{
"getFormOnCreation"=>proc{|pokemon|
   d=pokemon.personalID&3
   d|=((pokemon.personalID>>8)&3)<<2
   d|=((pokemon.personalID>>16)&3)<<4
   d|=((pokemon.personalID>>24)&3)<<6
   d%=2
   next d
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:MINDBLOW],[1,:SMORESMIRI]] if pokemon.form==1
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

# Igglybird does not have actual mutliple forms but it is set because Female ones
# should be Psychic, not fighting
MultipleForms.register(:IGGLYBIRD,{
  
 "type2"=>proc{|pokemon|
   types=[:FIGHTING,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:WIKITECH,{
# Affects this Pokémon and its evolution (Wikimedia)
"type1"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:WATER) if pokemon.form==1 # Eternal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0 
   next getID(PBTypes,:WIND) if pokemon.form==1 # Eternal
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   case pokemon.form
     when 1; next  [190,90,150,30,100,140] # Eternal
     else;   next
   end
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:ENIGMATACTICS),0],
         [getID(PBAbilities,:WATERSPLASH),1],
         [getID(PBAbilities,:CONTRARY),2],
         [getID(PBAbilities,:ELDERPROJECTOR),3]] if pokemon.form==1 # Eternal
},

"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[1,:FALSWSWIPE],[1,:HARDEN],[1,:WATERGUN],[1,:GROWL],[10,:DAMADON],
             [10,:BUBBLEBEAM],[10,:SPINJITZUAEROBICS],[20,:MINDRECOVERCY],
             [20,:WINDGLOW],[20,:CAPTIVATE],[30,:SUPERDAMADON],[30,:WATERLOGO],
             [30,:LAVASHIFT],[40,:CASTLEMANIA],[40,:CONFUSION],[40,:WATERSPOUT],
             [50,:DOOMARIETTA],[50,:WINDSLASH],[50,:WINDYAEROBICS]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})


MultipleForms.register(:SURPLETE,{
 "type2"=>proc{|pokemon|
   types=[:GLIMSE,:PSYCHIC,:GAS,:BLIZZARD,:DOOM]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:ROLEPLAY) 
   next 2 if pokemon.knowsMove?(:GASTROACID) 
   next 3 if pokemon.knowsMove?(:BLIZZARDOUSOCEAN) 
   next 4 if pokemon.knowsMove?(:DOOMSURPLETE) 
   next 0
}
})

MultipleForms.register(:GEOMETRYDASH,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(4)
}
})

MultipleForms.register(:META,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)
},
"color"=>proc{|pokemon|
   next                         if pokemon.form==0
   next 1                       if pokemon.form==1
   next 6                       if pokemon.form==2
   next pokemon.isMale? ? 0 : 9 if pokemon.form==3
   next 3                       if pokemon.form==4
}
})


MultipleForms.register(:MICROSOFT,{
"type2"=>proc{|pokemon|
   types=[:NORMAL,:CHLOROPHYLL,:GUST,:WATER,:BOLT]
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next  [90,75,100,50,75,100]
},
"getAbilityList"=>proc{|pokemon|
   next if pokemon.form==0
   next [[getID(PBAbilities,:EFFECTSPORE),0]] if pokemon.form==1
   next [[getID(PBAbilities,:SIAXIS),0]] if pokemon.form==2
   next [[getID(PBAbilities,:WATERBUBBLE),0]] if pokemon.form==3
   next [[getID(PBAbilities,:VERGINI),0]] if pokemon.form==4
},
"onSetForm"=>proc{|pokemon,form|
   moves=[
      :KLEOPOTRIA,
      :GUSTOPIA,    
      :WATERBUBBLE,
      :BOLTYDREAM
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if (form==1 || form==2 || form==3 || form==4) && !$inbattle
     newmove = moves[form-1]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename = PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename = PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove] = PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   elsif form==0
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pokemon.pbDeleteMoveAtIndex(hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:MAGICHAND))
       end
     end
   end
}
})


MultipleForms.register(:NAMCO,{
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:NAMCO,:BANDAI)

MultipleForms.register(:BANDAINAMCO,{
  
 "type1"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
 "type2"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 6 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[0,:FORBIDDENSPELL],[1,:GRAVITY],[1,:CONSTRICT],[1,:HARDEN],[5,:GROWL],
             [10,:AGILITY],[15,:UPROAR],[20,:PSYBEAM],[25,:TOXIC],[30,:MINDBLOW],
             [35,:HYPNOSIS],[40,:FLY],[45,:DREAMTOPIA],[50,:PSYCHIC],
             [60,:PSYCHICTERRAIN],[60,:TERRAINPULSE]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELIABANDAINAMCO,{
  
 "type1"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
 "type2"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},
"color"=>proc{|pokemon|
   next if pokemon.form==0
   next 9 if pokemon.form==1
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[0,:FORBIDDENSPELL],[1,:GRAVITY],[1,:CONSTRICT],[1,:HARDEN],
             [6,:GROWL],[12,:AGILITY],[18,:UPROAR],[24,:PSYBEAM],[30,:TOXIC],
             [36,:MINDBLOW],[42,:HYPNOSIS],[48,:FLY],[54,:DREAMTOPIA],
             [60,:PSYCHIC],[72,:PSYCHICTERRAIN],[72,:TERRAINPULSE]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELIABANDAIPLUS,{
  
 "type1"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])  
},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isFemale?    # Fire

   next 0
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[[0,:DOOMSURPLETE],[1,:FORBIDDENSPELL],[1,:GRAVITY],[1,:CONSTRICT],
             [1,:HARDEN],[6,:GROWL],[12,:AGILITY],[18,:UPROAR],[24,:PSYBEAM],
             [30,:TOXIC],[36,:MINDBLOW],[42,:HYPNOSIS],[48,:FLY],[54,:DREAMTOPIA],
             [60,:PSYCHIC],[72,:PSYCHICTERRAIN],[72,:TERRAINPULSE]] if pokemon.form==1 # Eternal
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
