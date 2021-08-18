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

