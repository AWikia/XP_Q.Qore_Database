#===============================================================================
# * Ultra Beasts, Legendary and Mythical PokImons
#===============================================================================

def isUltraBeast?(species)
  if isConst?(species.species,PBSpecies,:NIHILEGO) ||
     isConst?(species.species,PBSpecies,:BUZZWOLE) ||
     isConst?(species.species,PBSpecies,:PHEROMOSA) ||
     isConst?(species.species,PBSpecies,:XURKITREE) ||
     isConst?(species.species,PBSpecies,:CELESTEELA) ||
     isConst?(species.species,PBSpecies,:KARTANA) ||
     isConst?(species.species,PBSpecies,:GUZZLORD) ||
     isConst?(species.species,PBSpecies,:POIPOLE) ||
     isConst?(species.species,PBSpecies,:NAGANADEL) ||
     isConst?(species.species,PBSpecies,:STAKATAKA) ||
     isConst?(species.species,PBSpecies,:BLACEPHALON)
    return true
  end
  return false
end

def isLegendaryMythicalOrUltra?(species)
  if isUltraBeast?(species) ||
     isConst?(species.species,PBSpecies,:ZAPDOS) ||
     isConst?(species.species,PBSpecies,:ARTICUNO) ||
     isConst?(species.species,PBSpecies,:MOLTRES) ||
     isConst?(species.species,PBSpecies,:MEWTWO) ||
     isConst?(species.species,PBSpecies,:MEW) ||
     isConst?(species.species,PBSpecies,:RAIKOU) ||
     isConst?(species.species,PBSpecies,:ENTEI) ||
     isConst?(species.species,PBSpecies,:SUICUNE) ||
     isConst?(species.species,PBSpecies,:LUGIA) ||
     isConst?(species.species,PBSpecies,:HOOH) ||
     isConst?(species.species,PBSpecies,:CELEBI) ||
     isConst?(species.species,PBSpecies,:REGIROCK) ||
     isConst?(species.species,PBSpecies,:REGICE) ||
     isConst?(species.species,PBSpecies,:REGISTEEL) ||
     isConst?(species.species,PBSpecies,:LATIAS) ||
     isConst?(species.species,PBSpecies,:LATIOS) ||
     isConst?(species.species,PBSpecies,:KYOGRE) ||
     isConst?(species.species,PBSpecies,:GROUDON) ||
     isConst?(species.species,PBSpecies,:RAYQUAZA) ||
     isConst?(species.species,PBSpecies,:JIRACHI) ||
     isConst?(species.species,PBSpecies,:DEOXYS) ||
     isConst?(species.species,PBSpecies,:UXIE) ||
     isConst?(species.species,PBSpecies,:MESPRIT) ||
     isConst?(species.species,PBSpecies,:AZELF) ||
     isConst?(species.species,PBSpecies,:DIALGA) ||
     isConst?(species.species,PBSpecies,:PALKIA) ||
     isConst?(species.species,PBSpecies,:HEATRAN) ||
     isConst?(species.species,PBSpecies,:REGIGIGAS) ||
     isConst?(species.species,PBSpecies,:GIRATINA) ||
     isConst?(species.species,PBSpecies,:CRESSELIA) ||
     isConst?(species.species,PBSpecies,:PHIONE) ||
     isConst?(species.species,PBSpecies,:MANAPHY) ||
     isConst?(species.species,PBSpecies,:DARKRAI) ||
     isConst?(species.species,PBSpecies,:SHAYMIN) ||
     isConst?(species.species,PBSpecies,:ARCEUS) ||
     isConst?(species.species,PBSpecies,:VICTINI) ||
     isConst?(species.species,PBSpecies,:COBALION) ||
     isConst?(species.species,PBSpecies,:TERRAKION) ||
     isConst?(species.species,PBSpecies,:VIRIZION) ||
     isConst?(species.species,PBSpecies,:TORNADUS) ||
     isConst?(species.species,PBSpecies,:THUNDURUS) ||
     isConst?(species.species,PBSpecies,:RESHIRAM) ||
     isConst?(species.species,PBSpecies,:ZEKROM) ||
     isConst?(species.species,PBSpecies,:LANDORUS) ||
     isConst?(species.species,PBSpecies,:KYUREM) ||
     isConst?(species.species,PBSpecies,:KELDEO) ||
     isConst?(species.species,PBSpecies,:MELOETTA) ||
     isConst?(species.species,PBSpecies,:GENESECT) ||
     isConst?(species.species,PBSpecies,:XERNEAS) ||
     isConst?(species.species,PBSpecies,:YVELTAL) ||
     isConst?(species.species,PBSpecies,:ZYGARDE) ||
     isConst?(species.species,PBSpecies,:DIANCIE) ||
     isConst?(species.species,PBSpecies,:HOOPA) ||
     isConst?(species.species,PBSpecies,:VOLCANION) ||
     isConst?(species.species,PBSpecies,:TYPENULL) ||
     isConst?(species.species,PBSpecies,:SILVALLY) ||
     isConst?(species.species,PBSpecies,:TAPUKOKO) ||
     isConst?(species.species,PBSpecies,:TAPULELE) ||
     isConst?(species.species,PBSpecies,:TAPUBULU) ||
     isConst?(species.species,PBSpecies,:TAPUFINI) ||
     isConst?(species.species,PBSpecies,:COSMOG) ||
     isConst?(species.species,PBSpecies,:COSMOEM) ||
     isConst?(species.species,PBSpecies,:SOLGALEO) ||
     isConst?(species.species,PBSpecies,:LUNALA) ||
     isConst?(species.species,PBSpecies,:NECROZMA) ||
     isConst?(species.species,PBSpecies,:MAGEARNA) ||
     isConst?(species.species,PBSpecies,:MARSHADOW) ||
     isConst?(species.species,PBSpecies,:ZERAORA) ||
     isConst?(species.species,PBSpecies,:MELTAN) ||
     isConst?(species.species,PBSpecies,:MELMETAL) ||
     isConst?(species.species,PBSpecies,:ZACIAN) ||
     isConst?(species.species,PBSpecies,:ZAMAZENTA) ||
     isConst?(species.species,PBSpecies,:KYODON) ||
     isConst?(species.species,PBSpecies,:SURPLETE)
    return true
  end
  return false
end

#===============================================================================
# * Eternal PokImons, Ultra Blue and Regional Forms
#===============================================================================

def isRegionalForme?(species)
    return true if isEternal?(species)
    return true if isPhonetic?(species)
    return true if isAlolan?(species)
    return true if isGalarian?(species)
    return true if isMysterical?(species)
    return true if isYorkbook?(species)
    return false
end

def isEternal?(species)
    return true if isConst?(species.species,PBSpecies,:OK) && species.form==1
    return true if isConst?(species.species,PBSpecies,:VODAFONE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:KRISKRIS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:LG) && species.form==1
    return false
end

def isUltraBlue?(species)
    return true if isConst?(species.species,PBSpecies,:ROOMBA) && species.form>2
    return false
end

def isPhonetic?(species)
    return true if isConst?(species.species,PBSpecies,:SPRITZEE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:AROMATISSE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SWIRLIX) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SLURPUFF) && species.form==1
    return true if isConst?(species.species,PBSpecies,:FOMANTIS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:LURANTIS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:MORELULL) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SHIINOTIC) && species.form==1
    return true if isConst?(species.species,PBSpecies,:GOSSIFLEUR) && species.form==1
    return true if isConst?(species.species,PBSpecies,:ELDEGOSS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:CLOBBOPUS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:GRAPPLOCT) && species.form==1
    return true if isConst?(species.species,PBSpecies,:CUFANT) && species.form==1
    return true if isConst?(species.species,PBSpecies,:COPPERAJAH) && species.form==1
    return false
end

def isMysterical?(species)
    return true if isConst?(species.species,PBSpecies,:EKANS) && species.form==1
    return true if isConst?(species.species,PBSpecies,:ARBOK) && species.form==1
    return true if isConst?(species.species,PBSpecies,:PONYTA) && species.form==1
    return true if isConst?(species.species,PBSpecies,:RAPIDASH) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SWIRLIX) && species.form==2
    return true if isConst?(species.species,PBSpecies,:SLURPUFF) && species.form==2
    return true if isConst?(species.species,PBSpecies,:PHANTUMP) && species.form==1
    return true if isConst?(species.species,PBSpecies,:TREVENANT) && species.form==1
    return true if isConst?(species.species,PBSpecies,:PINCURCHIN) && species.form==1
    return false
end

def isYorkbook?(species)
    return true if isConst?(species.species,PBSpecies,:GROOKEY) && species.form==1
    return true if isConst?(species.species,PBSpecies,:THWACKEY) && species.form==1
    return true if isConst?(species.species,PBSpecies,:RILLABOOM) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SCORBUNNY) && species.form==1
    return true if isConst?(species.species,PBSpecies,:RABOOT) && species.form==1
    return true if isConst?(species.species,PBSpecies,:CINDERACE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:SOBBLE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:DRIZZILE) && species.form==1
    return true if isConst?(species.species,PBSpecies,:INTELEON) && species.form==1
    return false
end


def isAlolan?(pokemon)
  return (isConst?(pokemon.species,PBSpecies,:RATTATA) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:RATICATE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:PIKACHU) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:RAICHU) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SANDSHREW) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SANDSLASH) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:VULPIX) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:NINETALES) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:DIGLETT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:DUGTRIO) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:MEOWTH) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:PERSIAN) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GEODUDE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GRAVELER) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GOLEM) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GRIMER) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:MUK) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:EXEGGCUTE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:EXEGGUTOR) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:CUBONE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:MAROWAK) && pokemon.form==1) |
         (isConst?(pokemon.species,PBSpecies,:PICHU) && pokemon.form==1)
end

def isGalarian?(pokemon)
  # NOTE: Also includes their evolutions exclusive to Galarian forms
  return (isConst?(pokemon.species,PBSpecies,:ZIGZAGOON) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:LINOONE) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:OBSTAGOON) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:KOFFING) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:WEEZING) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:MEOWTH) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:PERRSERKER) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:FARFETCHD) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:SIRFETCHD) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:STANFISK) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:CORSOLA) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:CURSOLA) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:YAMASK) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:RUNERIGUS) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:PONYTA) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:RAPIDASH) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:MIMEJR) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:MRRIME) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:DARUMAKA) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:DARMANITAN) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:DARMANITAN) && pokemon.form==3) ||
         (isConst?(pokemon.species,PBSpecies,:SLOWPOKE) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:SLOWBRO) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:SLOWKING) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:ARTICUNO) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:MOLTRES) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:ZAPDOS) && pokemon.form==2)

end

def isHisuian?(pokemon)
  # NOTE: Also includes their evolutions exclusive to Hisuian forms
  # (Sneasler and Overqwil) and white-striped Basculin family but does not include
  # Ursulana, Kleavor and Wyrdeer
  return (isConst?(pokemon.species,PBSpecies,:GROWLITHE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:ARCANINE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:VOLTORB) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:ELECTRODE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:CYNDAQUIL) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:QUILAVA) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:TYPHLOSION) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:QWILFISH) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:OVERQWIL) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SNEASEL) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SNEASLER) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:OSHAWOTT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:DEWOTT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SAMUROTT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:BASCULIN) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:BASCULEGION) && pokemon.form==2) ||
         (isConst?(pokemon.species,PBSpecies,:PETILIT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:LILLIGANT) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:ZORUA) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:ZOROARK) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:RUFFLET) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:BRIVIARY) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GOOMY) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:SLIGGOO) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:GOODRA) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:BERGMITE) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:AVALUGG) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:ROWLET) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:DARTRIX) && pokemon.form==1) ||
         (isConst?(pokemon.species,PBSpecies,:DECIDUEYE) && pokemon.form==1)

end


# Type Colors
=begin
       How to add more entries:
        * You must define your new type
        * You must make a new array in the typeColors array that must be below
          * the last type it is defined. The first Color of the new sub-array
          * is the base color, the second ones is the shadow color (Darker than 
          * the base color), and the thrid ones is the highlight color (Lighter
          * than the first color)
          * In Summary Screens, in light mode, the 1st and 2nd colors are used as
          * base and shadow colors for move names respectively. In Dark Mode, the
          * base and shadow colors for move names are the 3rd and 1st colors of
          * the selected subarry respectively.
        * You may use a color set used by an existing type such as for the Glimse
          * type re-using the color set used by the shadow color
        * Have fun with the colors!!! --Qore Qore Telecommunities
=end
def typeColors
     return [
          # Ordinal Types
            [Color.new(168,168,120),Color.new(113,113,73),Color.new(208,208,182)],    # Normal
            [Color.new(192,48,40),Color.new(108,27,22),Color.new(224,115,109)],       # Fighting
            [Color.new(168,144,240),Color.new(98,54,227),Color.new(238,234,252)],     # Flying
            [Color.new(160,64,160),Color.new(87,35,87),Color.new(202,124,202)],       # Poison
            [Color.new(224,192,104),Color.new(185,146,37),Color.new(251,230,147)],    # Ground
            [Color.new(184,160,56),Color.new(86,69,3),Color.new(248,207,46)],         # Rock
            [Color.new(168,184,32),Color.new(89,97,17),Color.new(212,227,91)],        # Bug
            [Color.new(112,88,152),Color.new(63,51,86),Color.new(165,149,193)],       # Ghost
            [Color.new(184,184,208),Color.new(122,122,165),Color.new(244,244,248)],   # Steel
            [Color.new(104,160,144),Color.new(63,98,88),Color.new(167,199,190)],      # ΡΩΤΙΜΑΤΙΚΑ
            [Color.new(240,128,48),Color.new(172,80,13),Color.new(247,186,143)],      # Fire
            [Color.new(104,144,240),Color.new(22,79,218),Color.new(197,212,249)],     # Water
            [Color.new(120,200,80),Color.new(73,134,43),Color.new(180,224,158)],      # Grass
            [Color.new(248,208,48),Color.new(186,149,6),Color.new(251,230,147)],      # Electric
            [Color.new(248,88,136),Color.new(222,9,73),Color.new(249,184,204)],       # Psychic
            [Color.new(152,216,216),Color.new(76,184,184),Color.new(225,243,243)],    # Ice
            [Color.new(112,56,248),Color.new(61,16,172),Color.new(183,155,251)],      # Dragon
            [Color.new(112,88,72),Color.new(50,39,32),Color.new(167,138,119)],        # Dark
            [Color.new(255,101,213),Color.new(251,0,183),Color.new(253,201,239)],     # Fairy
          # Shadow and FLINT Types
            [Color.new(255,170,0),Color.new(152,102,0),Color.new(255,204,102)],       # Magic
            [Color.new(73,73,73),Color.new(22,22,22),Color.new(124,124,124)],         # Doom
            [Color.new(242,26,147),Color.new(156,9,92),Color.new(247,124,193)],       # Jelly
            [Color.new(112,16,208),Color.new(61,9,112),Color.new(162,83,240)],        # Shadow
            [Color.new(202,202,220),Color.new(141,141,179),Color.new(255,255,255)],   # Sharpener
            [Color.new(230,0,0),Color.new(128,0,0),Color.new(255,77,77)],             # Lava
            [Color.new(117,184,32),Color.new(61,95,17),Color.new(167,227,91)],        # Wind
            [Color.new(108,72,112),Color.new(48,32,50),Color.new(161,118,166)],       # Lick
            [Color.new(128,60,160),Color.new(70,35,87),Color.new(175,123,200)],       # Bolt
            [Color.new(243,134,25),Color.new(156,82,8),Color.new(247,184,122)],       # Herb
            [Color.new(105,221,201),Color.new(41,183,158),Color.new(187,239,230)],    # Chlorophyll
            [Color.new(71,179,255),Color.new(0,129,220),Color.new(172,220,254)],      # Gust
            [Color.new(240,160,48),Color.new(172,105,13),Color.new(247,204,143)],     # Sun
            [Color.new(101,92,115),Color.new(50,46,57),Color.new(151,142,165)],       # Moon
            [Color.new(236,100,175),Color.new(208,26,126),Color.new(246,190,221)],    # Mind
            [Color.new(255,134,202),Color.new(251,31,155),Color.new(255,236,247)],    # Heart
            [Color.new(87,173,235),Color.new(23,124,196),Color.new(178,217,246)],     # Blizzard
            [Color.new(101,202,51),Color.new(59,119,30),Color.new(162,224,131)],      # Gas
            [Color.new(55,55,72),Color.new(11,11,14),Color.new(99,99,129)],           # Glimse
            [Color.new(184,56,59),Color.new(105,32,34),Color.new(215,126,127)],       # Robot
            ]
end