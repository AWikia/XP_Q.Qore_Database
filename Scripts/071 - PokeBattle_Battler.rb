class PokeBattle_Battler
  attr_reader :battle
  attr_reader :pokemon
  attr_reader :name
  attr_reader :index
  attr_accessor :pokemonIndex
  attr_reader :totalhp
  attr_reader :fainted
  attr_accessor :lastAttacker
  attr_accessor :turncount
  attr_accessor :effects
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :gender
  attr_accessor :attack
  attr_writer :defense
  attr_accessor :spatk
  attr_writer :spdef
  attr_accessor :speed
  attr_accessor :stages
  attr_accessor :color
  attr_accessor :ev
  attr_accessor :iv
  attr_accessor :moves
  attr_accessor :participants
  attr_accessor :tookDamage
  attr_accessor :lastHPLost
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedType
  attr_accessor :lastMoveUsedSketch
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRoundMoved
  attr_accessor :movesUsed
  attr_accessor :currentMove
  attr_accessor :damagestate
  attr_accessor :captured
  attr_accessor :temperature
  attr_accessor :addTemp
  attr_accessor :recoildamage
  attr_accessor :favcolor
  attr_accessor :criticalhits
  attr_accessor :favtype
  attr_accessor :ragefist

  def inHyperMode?; return false; end
  def isShadow?; return false; end

################################################################################
# Ρατουρ
################################################################################
  def temperature
    return (@pokemon) ? @pokemon.temperature : 35
  end

  def temperatureD
    return (@pokemon) ? (@temperature + @addTemp) : 35
  end

  def addTemp=(value)
    @addTemp=value
    @pokemon.addTemp=value if @pokemon
  end

  def temperature2=(value)
    @temperature=self.basetemp if !@temperature
    @temperature+=value
    @pokemon.temperature+=(value - @pokemon.addTemp) if @pokemon
  end

  
  def resetTemperature
    @temperature=self.basetemp if !@temperature
    self.addTemp=0
    @pokemon.temperature=self.basetemp if @pokemon
  end

  
  def basetemp
    if self.pbHasType?(:FIRE)
      return 40 if self.pbHasType?(:ICE) || self.pbHasType?(:BLIZZARD)
      return 50
    elsif self.pbHasType?(:ICE) || self.pbHasType?(:BLIZZARD)
      return 20
    elsif self.pbHasType?(:SUN)
      return 60
    elsif self.pbHasType?(:MOON) || self.pbHasType?(:SHARPENER)
      return 30
    else
      return 35
    end
  end
  
  def addTemp
    return (@pokemon) ? @pokemon.addTemp : 0
  end
  
  def highTemp?
    return self.temperatureD > 90 if self.pbHasType?(:FIRE) || self.pbHasType?(:SUN)
    return self.temperatureD > 70
  end

  def tooHighTemp?
    return self.temperatureD > 95 if self.pbHasType?(:FIRE) || self.pbHasType?(:SUN)
    return self.temperatureD > 90
  end

  def tempHH?
    return false if self.pbHasType?(:FIRE) || self.pbHasType?(:SUN) # Not for Fire and Sunny Species
    return self.temperatureD > 100
  end

  def tempLL?
    return false if self.pbHasType?(:ICE) || self.pbHasType?(:BLIZZARD) # Not for Ice and Blizzardi Species
    return self.temperatureD < -5 if self.pbHasType?(:WATER) # Aquatic Species can last longer
    return self.temperatureD < 0
  end

################################################################################
# Recoil Damage
################################################################################
def recoildamage
    return (@pokemon) ? @pokemon.recoildamage : 0 # modification done by ATechno in order to avoid crashes
  end
    
  def recoildamage=(value)
    @recoildamage=value
    @pokemon.recoildamage = value if @pokemon 
  end

  def resetRecoilDamage
    @recoildamage=0
    @pokemon.recoildamage = 0 if @pokemon 
  end

  def changeRecoilDamage(value)
    resetRecoilDamage if !@recoildamage
    @recoildamage+=value
    @pokemon.recoildamage+= value if @pokemon 
  end


################################################################################
# Critical Hits
################################################################################
def criticalhits
    return (@pokemon) ? @pokemon.criticalhits : 0 # modification done by ATechno in order to avoid crashes
  end
    
  def criticalhits=(value)
    @criticalhits=value
    @pokemon.criticalhits = value if @pokemon 
  end

  def resetCriticalHits
    @criticalhits=0
    @pokemon.criticalhits = 0 if @pokemon 
  end

  def changeCriticalHits(value)
    resetCriticalHits if !@criticalhits
    @criticalhits+=value
    @pokemon.criticalhits+= value if @pokemon 
  end

  
################################################################################
# Rage Fist
################################################################################
def ragefist
    return (@pokemon) ? @pokemon.ragefist : 0 # modification done by ATechno in order to avoid crashes
  end
    
  def ragefist=(value)
    @ragefist=value
    @pokemon.ragefist = value if @pokemon 
  end

  def resetRageFist
    @ragefist=0
    @pokemon.ragefist = 0 if @pokemon 
  end

  def increaseRageFist
    resetRageFist if !@ragefist
    @ragefist+=1
    @pokemon.ragefist+= 1 if @pokemon 
  end

  
################################################################################
# Complex accessors
################################################################################
  def defense
    return (@battle.field.effects[PBEffects::WonderRoom]>0 && 
           !hasWorkingAbility(:MORFAT)) ? @spdef : @defense
  end

  def spdef
    return (@battle.field.effects[PBEffects::WonderRoom]>0 && 
           !hasWorkingAbility(:MORFAT)) ? @defense : @spdef
  end

  def profstat 
      if @attack >= @defense &&
          @attack >= @spatk &&
          @attack >= @spdef &&
          @attack >= @speed
        return PBStats::ATTACK
      elsif @defense >= @spatk &&
          @defense >= @spdef &&
          @defense >= @speed
        return PBStats::DEFENSE
      elsif @spatk >= @spdef &&
          @spatk >= @speed
        return PBStats::SPATK
      elsif @spdef >= @speed
        return PBStats::SPDEF
      else
        return PBStats::SPEED
      end
  end

  def nature
    return (@pokemon) ? @pokemon.nature : 0
  end

  def happiness
    return (@pokemon) ? @pokemon.happiness : 0
  end

  def pokerusStage
    return (@pokemon) ? @pokemon.pokerusStage : 0
  end

  attr_reader :form

  def form=(value)
    @form=value
    @pokemon.form=value if @pokemon
  end

  def hasMega?
    return false if @effects[PBEffects::Transform]
    if @pokemon
      return (@pokemon.hasMegaForm? rescue false)
    end
    return false
  end

  def isMega?
    if @pokemon
      return (@pokemon.isMega? rescue false)
    end
    return false
  end

  def hasPrimal?
    return false if @effects[PBEffects::Transform]
    if @pokemon
      return (@pokemon.hasPrimalForm? rescue false)
    end
    return false
  end

  def isPrimal?
    if @pokemon
      return (@pokemon.isPrimal? rescue false)
    end
    return false
  end

  attr_reader :level

  def level=(value)
    @level=value
    @pokemon.level=(value) if @pokemon
  end

  attr_reader :status

  def status=(value)
    if @status==PBStatuses::SLEEP && value==0
      @effects[PBEffects::Truant]=false
    end
    @status=value
    @pokemon.status=value if @pokemon
    if value!=PBStatuses::POISON
      @effects[PBEffects::Toxic]=0
    end
    if value!=PBStatuses::POISON && value!=PBStatuses::SLEEP
      @statusCount=0
      @pokemon.statusCount=0 if @pokemon
    end
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount=value
    @pokemon.statusCount=value if @pokemon
  end

  attr_reader :hp

  def hp=(value)
    @hp=value.to_i
    @pokemon.hp=value.to_i if @pokemon
  end
  
  attr_reader :item

  def item=(value)
    @item=value
    @pokemon.setItem(value) if @pokemon
  end

  def weight(attacker=nil)
    w=(@pokemon) ? @pokemon.weight : 500
    if !attacker || !attacker.hasMoldBreaker
      w*=2 if self.hasWorkingAbility(:HEAVYMETAL)
      w/=2 if self.hasWorkingAbility(:LIGHTMETAL)
    end
    w/=2 if self.hasWorkingItem(:FLOATSTONE)
    w+=@effects[PBEffects::WeightChange]
    w=w.floor
    w=1 if w<1
    return w
  end

  def name
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].name
    end
    return @name
  end

  def displayGender
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].gender
    end
    return self.gender
  end

  def isShiny?
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].isShiny?
    end
    return @pokemon.isShiny? if @pokemon
    return false
  end

  def owned
    return (@pokemon) ? $Trainer.owned[@pokemon.species] && !@battle.opponent : false
  end

################################################################################
# Creating a battler
################################################################################
  def initialize(btl,index)
    @battle       = btl
    @index        = index
    @hp           = 0
    @totalhp      = 0
    @fainted      = true
    @captured     = false
    @stages       = []
    @effects      = []
    @damagestate  = PokeBattle_DamageState.new
    pbInitBlank
    pbInitEffects(false)
    pbInitPermanentEffects
  end

  def pbInitPokemon(pkmn,pkmnIndex)
    if pkmn.isRB?
      raise _INTL("An Remote Box can't be an active Pokémon")
    end
    if pkmn.isEgg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @item         = pkmn.item
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @temperature  = pkmn.temperature - pkmn.addTemp
    @addTemp      = pkmn.addTemp
    @ragefist     = pkmn.ragefist
    @criticalhits = pkmn.criticalhits
    @recoildamage = pkmn.recoildamage
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @participants = [] # Participants will earn Exp. Points if this battler is defeated
    @moves        = [
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[0]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[1]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[2]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[3])
    ]
    @color        = pkmn.color
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    @ev           = []
    @ev[0]        = pkmn.ev[0]
    @ev[1]        = pkmn.ev[1]
    @ev[2]        = pkmn.ev[2]
    @ev[3]        = pkmn.ev[3]
    @ev[4]        = pkmn.ev[4]
    @ev[5]        = pkmn.ev[5]
  end

  def pbInitDummyPokemon(pkmn,pkmnIndex)
    if pkmn.isRB?
      raise _INTL("An Remote Box can't be an active Pokémon")
    end
    if pkmn.isEgg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @temperature  = pkmn.temperature - pkmn.addTemp
    @addTemp      = pkmn.addTemp
    @ragefist     = pkmn.ragefist
    @criticalhits = pkmn.criticalhits
    @recoildamage = pkmn.recoildamage
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @participants = []
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    @ev           = []
    @ev[0]        = pkmn.ev[0]
    @ev[1]        = pkmn.ev[1]
    @ev[2]        = pkmn.ev[2]
    @ev[3]        = pkmn.ev[3]
    @ev[4]        = pkmn.ev[4]
    @ev[5]        = pkmn.ev[5]
  end

  def pbInitBlank
    @name         = ""
    @species      = 0
    @level        = 0
    @hp           = 0
    @totalhp      = 0
    @gender       = 0
    @ability      = 0
    @type1        = 0
    @type2        = 0
    @form         = 0
    @attack       = 0
    @defense      = 0
    @speed        = 0
    @spatk        = 0
    @spdef        = 0
    @status       = 0
    @statusCount  = 0
    @temperature  = 30
    @addTemp      = 0
    @ragefist     = 0
    @criticalhits = 0
    @recoildamage = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = [nil,nil,nil,nil]
    @iv           = [0,0,0,0,0,0]
    @ev           = [0,0,0,0,0,0]
    @item         = 0
    @weight       = nil
  end

  def pbInitPermanentEffects
    # These effects are always retained even if a Pokémon is replaced
    @effects[PBEffects::FutureSight]        = 0
    @effects[PBEffects::FutureSightMove]    = 0
    @effects[PBEffects::FutureSightUser]    = -1
    @effects[PBEffects::FutureSightUserPos] = -1
    @effects[PBEffects::HealingWish]        = false
    @effects[PBEffects::Sixtopia]           = false
    @effects[PBEffects::LunarDance]         = false
    @effects[PBEffects::Wish]               = 0
    @effects[PBEffects::WishAmount]         = 0
    @effects[PBEffects::WishMaker]          = -1
    @effects[PBEffects::ShedTail]           = 0
  end

  def pbInitEffects(batonpass)
    if !batonpass
      # These effects are retained if Baton Pass is used
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
      @lastMoveUsedSketch        = -1
      @effects[PBEffects::AquaRing]    = false
      @effects[PBEffects::TransformProtection]    = false
      @effects[PBEffects::TransformBlock]    = false
      @effects[PBEffects::Confusion]   = 0
      @effects[PBEffects::Curse]       = false
      @effects[PBEffects::Embargo]     = 0
      @effects[PBEffects::SixtopiaP]     = false
      @effects[PBEffects::FocusEnergy] = 0
      @effects[PBEffects::GastroAcid]  = false
      @effects[PBEffects::HealBlock]   = 0
      @effects[PBEffects::Ingrain]     = false
      @effects[PBEffects::LeechSeed]   = -1
      @effects[PBEffects::LockOn]      = 0
      @effects[PBEffects::LockOnPos]   = -1
      for i in 0...4
        next if !@battle.battlers[i]
        if @battle.battlers[i].effects[PBEffects::LockOnPos]==@index &&
           @battle.battlers[i].effects[PBEffects::LockOn]>0
          @battle.battlers[i].effects[PBEffects::LockOn]=0
          @battle.battlers[i].effects[PBEffects::LockOnPos]=-1
        end
      end
      @effects[PBEffects::MagnetRise]     = 0
      @effects[PBEffects::PerishSong]     = 0
      @effects[PBEffects::PerishSongUser] = -1
      @effects[PBEffects::PowerTrick]     = false
      @effects[PBEffects::Substitute]     = 0
      @effects[PBEffects::Telekinesis]    = 0
      @effects[PBEffects::LaserFocus]     = 0 # changed
    else
      if @effects[PBEffects::LockOn]>0
        @effects[PBEffects::LockOn]=2
      else
        @effects[PBEffects::LockOn]=0
      end
      if @effects[PBEffects::PowerTrick]
        @attack,@defense=@defense,@attack
      end
      if @effects[PBEffects::LaserFocus]>0
        @effects[PBEffects::LaserFocus]=2
      else
        @effects[PBEffects::LaserFocus]=0
      end
    end
    @damagestate.reset
    @fainted          = false
    @lastAttacker     = []
    @lastHPLost       = 0
    @tookDamage       = false
    @lastMoveUsed     = -1
    @lastMoveUsedType = -1
    @lastRoundMoved   = -1
    @movesUsed        = []
    @turncount        = 0
    @effects[PBEffects::Attract]          = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::Attract]==@index
        @battle.battlers[i].effects[PBEffects::Attract]=-1
      end
    end
    @effects[PBEffects::Type1]            = self.type1
    @effects[PBEffects::Type2]            = self.type2
    @effects[PBEffects::BatonPass]        = false
    @effects[PBEffects::Bide]             = 0
    @effects[PBEffects::Splicern]         = 0
    @effects[PBEffects::BideDamage]       = 0
    @effects[PBEffects::BideTarget]       = -1
    @effects[PBEffects::Charge]           = 0
    @effects[PBEffects::ChoiceBand]       = -1
    @effects[PBEffects::Counter]          = -1
    @effects[PBEffects::CounterTarget]    = -1
    @effects[PBEffects::DefenseCurl]      = false
    @effects[PBEffects::DestinyBond]      = false
    @effects[PBEffects::Disable]          = 0
    @effects[PBEffects::DisableMove]      = 0
    @effects[PBEffects::Electrify]        = false
    @effects[PBEffects::Encore]           = 0
    @effects[PBEffects::EncoreIndex]      = 0
    @effects[PBEffects::EncoreMove]       = 0
    @effects[PBEffects::Endure]           = false
    @effects[PBEffects::FirstPledge]      = 0
    @effects[PBEffects::FlashFire]        = false
    @effects[PBEffects::DoomElist]        = false
    @effects[PBEffects::LongGrass]        = false
    @effects[PBEffects::Flinch]           = false
    @effects[PBEffects::FollowMe]         = 0
    @effects[PBEffects::Foresight]        = false
    @effects[PBEffects::FuryCutter]       = 0
    @effects[PBEffects::Grudge]           = false
    @effects[PBEffects::HelpingHand]      = false
    @effects[PBEffects::HyperBeam]        = 0
    @effects[PBEffects::UltraBurst]       = 0
    @effects[PBEffects::UBForm]           = 0
    @effects[PBEffects::Eternamax]        = 0
    @effects[PBEffects::BurningJelousy]   = false
    @effects[PBEffects::LashOut]          = false
    @effects[PBEffects::DarkTunnel]          = false
    @effects[PBEffects::Illusion]         = nil
    if self.hasWorkingAbility(:ILLUSION)
      lastpoke=@battle.pbGetLastPokeInTeam(@index)
      if lastpoke!=@pokemonIndex
        @effects[PBEffects::Illusion]     = @battle.pbParty(@index)[lastpoke]
      end
    end
    @effects[PBEffects::Imprison]         = false
    @effects[PBEffects::KingsShield]      = false
    @effects[PBEffects::SilkTrap]         = false
    @effects[PBEffects::LifeOrb]          = false
    @effects[PBEffects::MagicCoat]        = false
    @effects[PBEffects::MeanLook]         = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MeanLook]==@index
        @battle.battlers[i].effects[PBEffects::MeanLook]=-1
      end
    end
    @effects[PBEffects::MeFirst]          = false
    @effects[PBEffects::Metronome]        = 0
    @effects[PBEffects::MicleBerry]       = false
    @effects[PBEffects::Minimize]         = false
    @effects[PBEffects::MiracleEye]       = false
    @effects[PBEffects::MirrorCoat]       = -1
    @effects[PBEffects::MirrorCoatTarget] = -1
    @effects[PBEffects::MoveNext]         = false
    @effects[PBEffects::MudSport]         = false
    @effects[PBEffects::MultiTurn]        = 0
    @effects[PBEffects::MultiTurnAttack]  = 0
    @effects[PBEffects::MultiTurnUser]    = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
        @battle.battlers[i].effects[PBEffects::MultiTurn]=0
        @battle.battlers[i].effects[PBEffects::MultiTurnUser]=-1
      end
    end
    @effects[PBEffects::Nightmare]        = false
    @effects[PBEffects::Outrage]          = 0
    @effects[PBEffects::ParentalBond]     = 0
    @effects[PBEffects::PickupItem]       = 0
    @effects[PBEffects::PickupUse]        = 0
    @effects[PBEffects::Pinch]            = false
    @effects[PBEffects::Powder]           = false
    @effects[PBEffects::Protect]          = false
    @effects[PBEffects::ProtectNegation]  = false
    @effects[PBEffects::ProtectRate]      = 1
    @effects[PBEffects::Pursuit]          = false
    @effects[PBEffects::Quash]            = false
    @effects[PBEffects::Rage]             = false
    @effects[PBEffects::Revenge]          = 0
    @effects[PBEffects::Roar]             = false
    @effects[PBEffects::Rollout]          = 0
    @effects[PBEffects::Roost]            = false
    @effects[PBEffects::SkipTurn]         = false
    @effects[PBEffects::SkyDrop]          = false
    @effects[PBEffects::SmackDown]        = false
    @effects[PBEffects::Snatch]           = false
    @effects[PBEffects::SpikyShield]      = false
    @effects[PBEffects::Stockpile]        = 0
    @effects[PBEffects::StockpileDef]     = 0
    @effects[PBEffects::StockpileSpDef]   = 0
    @effects[PBEffects::Taunt]            = 0
    @effects[PBEffects::Khleri]            = 0
    @effects[PBEffects::Torment]          = false
    @effects[PBEffects::Toxic]            = 0
    @effects[PBEffects::Transform]        = false
    @effects[PBEffects::Truant]           = false
    @effects[PBEffects::TwoTurnAttack]    = 0
    @effects[PBEffects::Type3]            = -1
    @effects[PBEffects::Unburden]         = false
    @effects[PBEffects::Uproar]           = 0
    @effects[PBEffects::Uturn]            = false
    @effects[PBEffects::WaterSport]       = false
    @effects[PBEffects::WeightChange]     = 0
    @effects[PBEffects::Yawn]             = 0
    # changed
    @effects[PBEffects::BanefulBunker]    = false
    @effects[PBEffects::Obstruct]    = false
    @effects[PBEffects::ShellTrap]        = false
    @effects[PBEffects::TarShot]        = false
    @effects[PBEffects::TemporaryMoldBreaker] = false
    @effects[PBEffects::Disguise] = false
    @effects[PBEffects::IceFace] = false
    @effects[PBEffects::Octolock] = false
    @effects[PBEffects::GulpMissile] = false
    @effects[PBEffects::NoRetreat]        = false
    @effects[PBEffects::MagicDelta]        = false
    @effects[PBEffects::SilveryBliss]        = false
    @effects[PBEffects::JawLock]        = false
    @effects[PBEffects::Mimicry]        = false
    @effects[PBEffects::NeutralTrap]        = 0
    @effects[PBEffects::Brainymedia]        = false
    @effects[PBEffects::CudChew]        = false
    @effects[PBEffects::GlaiveRush]      = 0
    @effects[PBEffects::GlaiveRushPos]   = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::GlaiveRushPos]==@index &&
         @battle.battlers[i].effects[PBEffects::GlaiveRush]>0
        @battle.battlers[i].effects[PBEffects::GlaiveRush]=0
        @battle.battlers[i].effects[PBEffects::GlaiveRushPos]=-1
      end
    end
    # Disguise causes the ability-suppressing effect to fade
    # if it was passed on through Baton Pass
    if self.hasWorkingAbility(:DISGUISE) && isConst?(self.species,PBSpecies,:MIMIKYU)
      @effects[PBEffects::GastroAcid] = false
    end
    @effects[PBEffects::LastMoveFailed]   = false
    @effects[PBEffects::ThroatChop]       = 0
    # changed end
  end

  def pbUpdate(fullchange=false)
    if @pokemon
      @pokemon.calcStats
      @level     = @pokemon.level
      @hp        = @pokemon.hp
      @totalhp   = @pokemon.totalhp
      if !@effects[PBEffects::Transform]
        @attack    = @pokemon.attack
        @defense   = @pokemon.defense
        @speed     = @pokemon.speed
        @spatk     = @pokemon.spatk
        @spdef     = @pokemon.spdef
        if fullchange
          @ability = @pokemon.ability
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
  end

  def pbInitialize(pkmn,index,batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if self.hasWorkingAbility(:NATURALCURE)
      self.status=0
    end
    if self.hasWorkingAbility(:REGENERATOR)
      self.pbRecoverHP((totalhp/3).floor)
    end
    if self.hasWorkingAbility(:ZEROTOHERO) && 
        isConst?(self.species,PBSpecies,:PALAFIN) 
      self.form=1
    end
    self.resetTemperature
    pbInitPokemon(pkmn,index)
    pbInitEffects(batonpass)
  end

# Used only to erase the battler of a Shadow Pokémon that has been snagged.
  def pbReset
    @pokemon                = nil
    @pokemonIndex           = -1
    self.hp                 = 0
    pbInitEffects(false)
    # reset status
    self.status             = 0
    self.statusCount        = 0
    @fainted                = true
    # reset choice
    @battle.choices[@index] = [0,0,nil,-1]
    return true
  end

# Update Pokémon who will gain EXP if this battler is defeated
  def pbUpdateParticipants
    return if self.isFainted? # can't update if already fainted
    if @battle.pbIsOpposing?(@index)
      found1=false
      found2=false
      for i in @participants
        found1=true if i==pbOpposing1.pokemonIndex
        found2=true if i==pbOpposing2.pokemonIndex
      end
      if !found1 && !pbOpposing1.isFainted?
        @participants[@participants.length]=pbOpposing1.pokemonIndex
      end
      if !found2 && !pbOpposing2.isFainted?
        @participants[@participants.length]=pbOpposing2.pokemonIndex
      end
    end
  end

################################################################################
# About this battler
################################################################################
  def pbThis(lowercase=false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent
        return lowercase ? _INTL("the opposing {1}",self.name) : _INTL("The opposing {1}",self.name)
      else
        return lowercase ? _INTL("the wild {1}",self.name) : _INTL("The wild {1}",self.name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",self.name)
    else
      return lowercase ? _INTL("the ally {1}",self.name) : _INTL("The ally {1}",self.name)
    end
  end

  def pbHasType?(type)
    ret=false
    if type.is_a?(Symbol) || type.is_a?(String)
      ret=isConst?(self.type1,PBTypes,type.to_sym) ||
          isConst?(self.type2,PBTypes,type.to_sym)
      if @effects[PBEffects::Type3]>=0
        ret|=isConst?(@effects[PBEffects::Type3],PBTypes,type.to_sym)
      end
    else
      ret=(self.type1==type || self.type2==type)
      if @effects[PBEffects::Type3]>=0
        ret|=(@effects[PBEffects::Type3]==type)
      end
    end
    return ret
  end
  
  def pbHasMove?(id)
    if id.is_a?(String) || id.is_a?(Symbol)
      id=getID(PBMoves,id)
    end
    return false if !id || id==0
    for i in @moves
      return true if i.id==id
    end
    return false
  end

  def pbHasMoveType?(type)
    if type.is_a?(String) || type.is_a?(Symbol)
      type=getID(PBTypes,type)
    end
    return false if !type || type<0
    for i in @moves
      return true if i.type==type
    end
    return false
  end

  def pbHasMoveFunction?(code)
    return false if !code
    for i in @moves
      return true if i.function==code
    end
    return false
  end

  def hasMovedThisRound?
    return false if !@lastRoundMoved
    return @lastRoundMoved==@battle.turncount
  end

  def isFainted?
    return @hp<=0
  end

  def hasMoldBreaker
    return false if @battle.field.effects[PBEffects::Cinament]>0 && !hasWorkingItem(:RODOFSPARROW)
    return true if hasWorkingAbility(:MOLDBREAKER) ||
                   hasWorkingAbility(:TERAVOLT) ||
                   hasWorkingAbility(:TURBOBLAZE) |
                   pbPartner.hasWorkingAbility(:PHANTOMSPIRIT) ||
                   pbHasType?(:HEART) ||
                   pbHasType?(:GLIMSE) ||
                   @effects[PBEffects::TemporaryMoldBreaker] ||
                   hasWorkingItem(:LECTROBALL)
    return false
  end

  def hasAbilityPowers(target)
    if target
      return false if target.hasWorkingAbility(:ABILITOPIA) || target.hasWorkingAbility(:MORFAT)
      return false if target.pbHasType?(:GHOST) || target.pbHasType?(:GLIMSE)
    end
    return true if hasWorkingAbility(:ABILITOPIA)
    return false
  end
  

  def hasWorkingAbility(ability,ignorefainted=false)
    return false if self.isFainted? && !ignorefainted
    if @battle.field.effects[PBEffects::NeutralizingGas] && !self.pbHasType?(:GAS)
      return false if @effects[PBEffects::NeutralTrap]>0
      return false if @effects[PBEffects::GastroAcid]
      return false if !isConst?(@ability,PBAbilities,:COMMANDER) ||
                      !isConst?(@ability,PBAbilities,:STANCECHANGE) ||
                      !isConst?(@ability,PBAbilities,:SCHOOLING) ||
                      !isConst?(@ability,PBAbilities,:DOLPHININO) ||
                      !isConst?(@ability,PBAbilities,:ABILITOPIA) ||
                      !isConst?(@ability,PBAbilities,:NEUTRALIZINGGAS)
    end
    return false if @effects[PBEffects::NeutralTrap]>0
    return false if @effects[PBEffects::GastroAcid] && !self.pbHasType?(:GAS)
    return isConst?(@ability,PBAbilities,ability)
  end

  def hasWorkingItem(item,ignorefainted=false)
    return false if self.isFainted? && !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0 && 
                    !hasWorkingAbility(:MORFAT)
    return false if @pokemon.corrosiveGas
    return false if self.hasWorkingAbility(:KLUTZ,ignorefainted)
    return isConst?(@item,PBItems,item)
  end

  def hasWorkingBerry(ignorefainted=false)
    return false if self.isFainted? && !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0 && 
                    !hasWorkingAbility(:MORFAT)
    return false if @pokemon.corrosiveGas
    return false if self.hasWorkingAbility(:KLUTZ,ignorefainted)
    return pbIsBerry?(@item)
  end

  def hasWorkingBox(ignorefainted=false)
    return false if self.isFainted? && !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0 && 
                    !hasWorkingAbility(:MORFAT)
    return false if @pokemon.corrosiveGas
    return false if self.hasWorkingAbility(:KLUTZ,ignorefainted)
    return pbIsBox?(@item)
  end
  
  def isAirborne?(ignoreability=false)
    return false if self.hasWorkingItem(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Cinament]>0
    return false if @battle.field.effects[PBEffects::Gravity]>0
    return true if self.pbHasType?(:WIND) && $USENEWBATTLEMECHANICS
    return true if self.pbHasType?(:FLYING) && !@effects[PBEffects::Roost]
    return true if self.hasWorkingAbility(:LEVITATE) && !ignoreability
    return true if self.hasWorkingItem(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise]>0
    return true if @effects[PBEffects::Telekinesis]>0
    return true if @effects[PBEffects::MagicDelta]
    return false
  end

  def checkMimicry
    if hasWorkingAbility(:MIMICRY)
      type= @battle.field.effects[PBEffects::GrassyTerrain]>0 ? getConst(PBTypes,:GRASS) :  @battle.field.effects[PBEffects::MistyTerrain]>0 ? getConst(PBTypes,:FAIRY) :  @battle.field.effects[PBEffects::PsychicTerrain]>0 ? getConst(PBTypes,:PSYCHIC) : @battle.field.effects[PBEffects::VolcanicTerrain]>0 ? getConst(PBTypes,:LAVA) : @battle.field.effects[PBEffects::LovelyTerrain]>0 ? getConst(PBTypes,:FAIRY) : @battle.field.effects[PBEffects::Cinament]>0 ? getConst(PBTypes,:BOLT) : @battle.field.effects[PBEffects::ElectricTerrain]>0 ? getConst(PBTypes,:ELECTRIC) : 0
      if (type1==getConst(PBTypes,type) &&
         type2==getConst(PBTypes,type)) || self.isFainted?
      elsif type != 0
        @effects[PBEffects::Mimicry] = true
        self.type1=type
        self.type2=type
        typename=PBTypes.getName(type)
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",self.pbThis,typename))
      end
    end
  end

  def removeMimicry
    if hasWorkingAbility(:MIMICRY) && @effects[PBEffects::Mimicry]
      @effects[PBEffects::Mimicry] = false
      self.type1=@effects[PBEffects::Type1]
      self.type2=@effects[PBEffects::Type2]
      @battle.pbDisplay(_INTL("{1} transformed into the original types!",self.pbThis))
    end
  end

  
  def checkMimicryAll
    for i in [self,self.pbPartner,self.pbOpposing1,self.pbOpposing2]
      next if !i
      i.checkMimicry
    end
  end
  

  def pbSpeed()
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    speed=@speed
    stage=@stages[PBStats::SPEED]+6
    speed=(speed*stagemul[stage]/stagediv[stage]).floor
    speedmult=0x1000
    case @battle.pbWeather
    when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
      speedmult=speedmult*2 if self.hasWorkingAbility(:SWIFTSWIM) && 
                              !self.hasWorkingItem(:UTILITYUMBRELLA)
    when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
      speedmult=speedmult*2 if self.hasWorkingAbility(:CHLOROPHYLL) && 
                              !self.hasWorkingItem(:UTILITYUMBRELLA)
    when PBWeather::SANDSTORM
      speedmult=speedmult*2 if self.hasWorkingAbility(:SANDRUSH)
    when PBWeather::HAIL
      speedmult=speedmult*2 if self.hasWorkingAbility(:SLUSHRUSH) # changed
    end
    if self.hasWorkingAbility(:QUICKFEET) && self.status>0
      speedmult=(speedmult*1.5).round
    end
    if self.hasWorkingAbility(:SURGESURFER) && @battle.field.effects[PBEffects::ElectricTerrain]>0
      speedmult=speedmult*2
    end
    if self.hasWorkingAbility(:UNBURDEN) && @effects[PBEffects::Unburden] &&
       self.item==0
      speedmult=speedmult*2
    end
    if self.hasWorkingAbility(:SLOWSTART) && self.turncount<=5
      speedmult=(speedmult/2).round
    end
    # Protosynthesis/Quark Drive
    if ((@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN) && 
       self.hasWorkingAbility(:PROTOSYNTHESIS)) ||
      (@battle.field.effects[PBEffects::ElectricTerrain]>0 && 
       self.hasWorkingAbility(:QUARKDRIVE)) && self.profstat == PBStats::SPEED
       speedmult=(speedmult*1.5).round
    end
    if self.hasWorkingItem(:MACHOBRACE) ||
       self.hasWorkingItem(:POWERWEIGHT) ||
       self.hasWorkingItem(:POWERBRACER) ||
       self.hasWorkingItem(:POWERBELT) ||
       self.hasWorkingItem(:POWERANKLET) ||
       self.hasWorkingItem(:POWERLENS) ||
       self.hasWorkingItem(:POWERBAND)
      speedmult=(speedmult/2).round
    end
    if self.hasWorkingItem(:CHOICESCARF)
      speedmult=(speedmult*1.5).round
    end
    if isConst?(self.item,PBItems,:IRONBALL)
      speedmult=(speedmult/2).round
    end
    if self.hasWorkingItem(:QUICKPOWDER) && isConst?(self.species,PBSpecies,:DITTO) &&
       !@effects[PBEffects::Transform]
      speedmult=speedmult*2
    end
    if self.pbOwnSide.effects[PBEffects::Tailwind]>0
      speedmult=speedmult*2
    end
    if self.pbOwnSide.effects[PBEffects::Swamp]>0
      speedmult=(speedmult/2).round
    end
    if self.status==PBStatuses::PARALYSIS && !self.hasWorkingAbility(:QUICKFEET)
      speedmult=(speedmult/2).round
    end
    if @battle.internalbattle && @battle.pbOwnedByPlayer?(@index) &&
       @battle.pbPlayer.numbadges>=BADGESBOOSTSPEED
      speedmult=(speedmult*1.1).round
    end
    speed=(speed*speedmult*1.0/0x1000).round
    return [speed,1].max
  end

################################################################################
# Change HP
################################################################################
  def pbReduceHP(amt,anim=false,registerDamage=true)
    if amt>=self.hp
      amt=self.hp
    elsif amt<1 && !self.isFainted?
      amt=1
    end
    oldhp=self.hp
    self.hp-=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    @tookDamage=true if amt>0 && registerDamage
    @battle.pbCheckDanger
    return amt
  end

  def pbRecoverHP(amt,anim=false)
    if self.hp+amt>@totalhp
      amt=@totalhp-self.hp
    elsif amt<1 && self.hp!=@totalhp
      amt=1
    end
    oldhp=self.hp
    self.hp+=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    @battle.pbCheckDanger
    return amt
  end

  def pbFaint(showMessage=true)
    if !self.isFainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return true
    end
    if @fainted
#      PBDebug.log("!!!***Can't faint if already fainted")
      return true
    end
    # Changed added
    # Power of Alchemy / Receiver
    if !self.pbPartner.isFainted? &&
        (self.pbPartner.hasWorkingAbility(:POWEROFALCHEMY) ||
        self.pbPartner.hasWorkingAbility(:RECEIVER))
      if !(isConst?(self.ability,PBAbilities,:BATTLEBOND) ||
          isConst?(self.ability,PBAbilities,:COMMANDER) ||
          isConst?(self.ability,PBAbilities,:COMATOSE) ||
          isConst?(self.ability,PBAbilities,:DISGUISE) ||
          isConst?(self.ability,PBAbilities,:FLOWERGIFT) ||
          isConst?(self.ability,PBAbilities,:FORECAST) ||
          isConst?(self.ability,PBAbilities,:GULPMISSILE) ||
          isConst?(self.ability,PBAbilities,:ICEFACE) ||
          isConst?(self.ability,PBAbilities,:ILLUSION) ||
          isConst?(self.ability,PBAbilities,:IMPOSTER) ||
          isConst?(self.ability,PBAbilities,:MULTITYPE) ||
          isConst?(self.ability,PBAbilities,:NEUTRALIZINGGAS) ||
          isConst?(self.ability,PBAbilities,:POWERCONSTRUCT) ||
          isConst?(self.ability,PBAbilities,:POWEROFALCHEMY) ||
          isConst?(self.ability,PBAbilities,:PROTOSYNTHESIS) ||
          isConst?(self.ability,PBAbilities,:QUARKDRIVE) ||
          isConst?(self.ability,PBAbilities,:RECEIVER) ||
          isConst?(self.ability,PBAbilities,:RKSSYSTEM) ||
          isConst?(self.ability,PBAbilities,:SCHOOLING) ||
          isConst?(self.ability,PBAbilities,:SHIELDSDOWN) ||
          isConst?(self.ability,PBAbilities,:STANCECHANGE) ||
          isConst?(self.ability,PBAbilities,:TRACE) ||
          isConst?(self.ability,PBAbilities,:WONDERGUARD) ||
          isConst?(self.ability,PBAbilities,:ZENMODE) ||
          isConst?(self.ability,PBAbilities,:ZEROTOHERO) ||
          isConst?(self.ability,PBAbilities,:PHONYPREDATOR) ||
          isConst?(self.ability,PBAbilities,:KOULUNDIN) ||
          isConst?(self.ability,PBAbilities,:CHIKOLINI) ||
          isConst?(self.ability,PBAbilities,:ALONELY) ||
          isConst?(self.ability,PBAbilities,:DOLPHININO) ||
          isConst?(self.ability,PBAbilities,:ABILITOPIA) ||
          isConst?(self.ability,PBAbilities,:MORFAT))
     #   @triggermoxieeffects=false
        battlername=self.pbThis(true)
        battlerability=self.ability
        self.pbPartner.ability=battlerability
        abilityname=PBAbilities.getName(battlerability)
        @battle.pbDisplay(_INTL("{1}'s {2} was taken over!",battlername,abilityname))
        PBDebug.log("[Ability triggered] #{self.pbPartner.pbThis(true)}'s Receiver/Power of Alchemy turned into #{abilityname} from #{battlername}")
      end
    end
    # Changed end
    # Chikolini
    if self.pbPartner.hasWorkingAbility(:CHIKOLINI) && !self.pbPartner.isFainted?
      choice=self
      blacklist=[
          0xC9,    # Fly
          0xCA,    # Dig
          0xCB,    # Dive
          0xCC,    # Bounce
          0xCD,    # Shadow Force
          0xCE,    # Sky Drop
          0x14D,   # Phantom Force
          0x336    # Steel Fly
      ]
      if choice.effects[PBEffects::Transform] ||
          self.pbPartner.effects[PBEffects::Transform] ||
          self.pbPartner.effects[PBEffects::TransformBlock] ||
          choice.effects[PBEffects::TransformProtection] ||
          choice.effects[PBEffects::Illusion] ||
          choice.effects[PBEffects::Substitute]>0 ||
          choice.effects[PBEffects::SkyDrop] ||
          blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function) ||
          isConst?(choice.ability,PBAbilities,:KOULUNDIN) ||
          isConst?(choice.ability,PBAbilities,:ALONELY) ||
          isUltraBlue?(choice) ||
          @battle.field.effects[PBEffects::Cinament]>0 && !self.pbPartner.hasWorkingItem(:RODOFSPARROW) ||
          self.isAirborne? && !self.pbPartner.isAirborne?
        PBDebug.log("[Ability triggered] #{self.pbPartner.pbThis}'s Chikolini couldn't transform")
      elsif choice.hasWorkingItem(:PASTELCARD,true) 
        if self.pbPartner.pbReduceStatWithCause(PBStats::DEFENSE,1,choice,PBItems.getName(choice.item))
          choice.effects[PBEffects::TransformProtection]=true
          choice.pbConsumeItem
        end
      elsif choice.hasWorkingItem(:PLACTENCARD,true) 
        if self.pbPartner.pbReduceStatWithCause(PBStats::SPDEF,1,choice,PBItems.getName(choice.item))
          self.pbPartner.effects[PBEffects::TransformBlock]=true
          choice.effects[PBEffects::TransformProtection]=true
          choice.pbConsumeItem
        end
      else
        PBDebug.log("[Ability triggered] #{self.pbPartner.pbThis}'s Chikolini")
        @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),self.pbPartner,choice)
        self.pbPartner.effects[PBEffects::Transform]=true
        self.pbPartner.effects[PBEffects::Mimicry] = choice.effects[PBEffects::Mimicry]
        self.pbPartner.effects[PBEffects::Type1] = choice.effects[PBEffects::Type1]
        self.pbPartner.effects[PBEffects::Type2] = choice.effects[PBEffects::Type2]
        self.pbPartner.type1=choice.type1
        self.pbPartner.type2=choice.type2
        self.pbPartner.effects[PBEffects::Type3]=-1
        self.pbPartner.ability=choice.ability
        self.pbPartner.attack=choice.attack
        self.pbPartner.defense=choice.defense
        self.pbPartner.speed=choice.speed
        self.pbPartner.spatk=choice.spatk
        self.pbPartner.spdef=choice.spdef
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          self.pbPartner.stages[i]=choice.stages[i]
        end
        for i in 0...4
          self.pbPartner.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
          self.pbPartner.moves[i].pp=5
          self.pbPartner.moves[i].totalpp=5
        end
        self.pbPartner.effects[PBEffects::Disable]=0
        self.pbPartner.effects[PBEffects::DisableMove]=0
        @battle.pbDisplay(_INTL("{1} transformed into {2}!",self.pbPartner.pbThis,choice.pbThis(true)))
        PBDebug.log("[Pokémon transformed] #{self.pbPartner.pbThis} transformed into #{choice.pbThis(true)}")
      end
    end
    # Commander (When Dondozo faints, user of Commander gets back to Normal)
    if self.pbPartner.effects[PBEffects::Commander] &&
      self.effects[PBEffects::CommanderAlly]
        PBDebug.log("[Ability triggered] #{pbPartner.pbThis}'s Commander")
      self.effects[PBEffects::CommanderAlly]=false
      self.pbPartner.effects[PBEffects::Commander]=false
    end
    neutralizinggas=false
    @battle.scene.pbFainted(self)
    pbInitEffects(false)
    # Reset status
    self.status=0
    self.statusCount=0
    self.resetRecoilDamage # Reset Recoil Damage back to 0
    self.resetCriticalHits # Reset Critical Hits back to 0
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness("faint")
    end
    if self.isMega?
      @pokemon.makeUnmega
    end
    if self.isPrimal?
      @pokemon.makeUnprimal
    end
    @fainted=true
    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    pbOwnSide.effects[PBEffects::LastRoundFainted]=@battle.turncount
    @battle.pbDisplayPaused(_INTL("{1} fainted!",pbThis)) if showMessage
    PBDebug.log("[Pokémon fainted] #{pbThis}")
    if @fainted
      if @ability==PBAbilities::NEUTRALIZINGGAS
        neutralizinggas=true if ((self.pbPartner.ability==PBAbilities::NEUTRALIZINGGAS && !self.pbPartner.isFainted?) ||
                                 (self.pbOpposing1.ability==PBAbilities::NEUTRALIZINGGAS && !self.pbOpposing1.isFainted?) ||
                                 (self.pbOpposing2.ability==PBAbilities::NEUTRALIZINGGAS && !self.pbOpposing2.isFainted?))
        if !neutralizinggas
          @battle.field.effects[PBEffects::NeutralizingGas]=false
          @battle.pbDisplayPaused(_INTL("The effects of the neutralizing gas wore off!"))
          for j in @battle.pbPriority
            j.pbAbilitiesOnSwitchIn(true) if !j.pbHasType?(:GAS)
          end
        end
      end
    end
    return true
  end
################################################################################
# Find other battlers/sides in relation to this battler
################################################################################
# Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[@index&1] # Player: 0 and 2; Foe: 1 and 3
  end

# Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(@index&1)^1] # Player: 1 and 3; Foe: 0 and 2
  end

# Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index&1)!=(i&1)
  end

# Returns the battler's partner
  def pbPartner
    return @battle.battlers[(@index&1)|((@index&2)^2)]
  end

# Returns the battler's first opposing Pokémon
  def pbOpposing1
    return @battle.battlers[((@index&1)^1)]
  end

# Returns the battler's second opposing Pokémon
  def pbOpposing2
    return @battle.battlers[((@index&1)^1)+2]
  end

  def pbOppositeOpposing
    return @battle.battlers[(@index^1)]
  end

  def pbOppositeOpposing2
    return @battle.battlers[(@index^1)|((@index&2)^2)]
  end

  def pbNonActivePokemonCount()
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if (self.isFainted? || i!=self.pokemonIndex) &&
         (pbPartner.isFainted? || i!=self.pbPartner.pokemonIndex) &&
         party[i] && !party[i].isEgg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end

################################################################################
# Forms
################################################################################
  def pbCheckForm
    return if @effects[PBEffects::Transform]
    return if self.isFainted?
    transformed=false
    # Forecast
    if isConst?(self.species,PBSpecies,:CASTFORM) && !self.hasWorkingItem(:UTILITYUMBRELLA)
      if self.hasWorkingAbility(:FORECAST)
        case @battle.pbWeather
        when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
          if self.form!=1
            self.form=1; transformed=true
          end
        when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
          if self.form!=2
            self.form=2; transformed=true
          end
        when PBWeather::HAIL
          if self.form!=3
            self.form=3; transformed=true
          end
        else
          if self.form!=0
            self.form=0; transformed=true
          end
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Cherrim
    if isConst?(self.species,PBSpecies,:CHERRIM) && !self.hasWorkingItem(:UTILITYUMBRELLA)
      if self.hasWorkingAbility(:FLOWERGIFT) &&
         (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN)
        if self.form!=1
          self.form=1; transformed=true
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Shaymin
    if isConst?(self.species,PBSpecies,:SHAYMIN)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Giratina
    if isConst?(self.species,PBSpecies,:GIRATINA)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Arceus
    if isConst?(self.ability,PBAbilities,:MULTITYPE) &&
       isConst?(self.species,PBSpecies,:ARCEUS)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Zen Mode (Unovan)
    if isConst?(self.species,PBSpecies,:DARMANITAN) && self.form<2
      if self.hasWorkingAbility(:ZENMODE) && @hp<=((@totalhp/2).floor)
        if self.form!=1
          self.form=1; transformed=true
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Zen Mode (Galartian)
    if isConst?(self.species,PBSpecies,:DARMANITAN) && self.form>1
      if self.hasWorkingAbility(:ZENMODE) && @hp<=((@totalhp/2).floor)
        if self.form!=3
          self.form=3; transformed=true
        end
      else
        if self.form!=2
          self.form=2; transformed=true
        end
      end
    end
    # Keldeo
    if isConst?(self.species,PBSpecies,:KELDEO)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Genesect
    if isConst?(self.species,PBSpecies,:GENESECT)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Wishiwashi # Changed added
    if isConst?(self.species,PBSpecies,:WISHIWASHI) && !self.isFainted?
      if isConst?(self.ability,PBAbilities,:SCHOOLING) && @hp<=((@totalhp/4).floor)
        if self.form!=0
          self.form=0; transformed=true
        end
      else
        if self.form!=1 && @level>=20
          self.form=1; transformed=true
        end
      end
    end
    # Minior
    if isConst?(self.species,PBSpecies,:MINIOR) && !self.isFainted?
      if self.hasWorkingAbility(:SHIELDSDOWN) && !@effects[PBEffects::Transform]
        if self.hp<=(self.totalhp/2).floor
          if self.form<7
            self.form+=7
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("Shields Down activated!"))
          end
        else
          if self.form>=7
            self.form-=7
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("Shields Down deactivated!"))
          end
        end
      end
    end
    # Phony Predator (Polteageist)
    if isConst?(self.species,PBSpecies,:POLTEAGEIST)
      if self.hasWorkingAbility(:PHONYPREDATOR) && @hp<=((@totalhp/2).floor)
        if self.form!=1
          self.form=1; transformed=true
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Zacian
    if isConst?(self.species,PBSpecies,:ZACIAN)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
      end
    end
    # Zamazenta
    if isConst?(self.species,PBSpecies,:ZAMAZENTA)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
      end
    end
    # Koraidon
    if isConst?(self.species,PBSpecies,:KORAIDON)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
      end
    end
    # Miraidon
    if isConst?(self.species,PBSpecies,:MIRAIDON)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
      end
    end
    # Sunny Channel
    if isConst?(self.species,PBSpecies,:SUNNYCHANNEL)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Dolphin Emulator
    if isConst?(self.species,PBSpecies,:DOLPHIN) && !self.isFainted?
      if self.hasWorkingAbility(:DOLPHININO)
        if self.form==0
          self.form=1; transformed=true
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Flamengo
    if isConst?(self.species,PBSpecies,:FLAMENGO) && !self.isFainted?
      if @hp<=((@totalhp/3).floor)
        if self.form!=0
          self.form=0; transformed=true
        end
      else
        if self.form!=1 && @level>=30
          self.form=1; transformed=true
        end
      end
    end
    # Pac-Man
    if isConst?(self.species,PBSpecies,:PACMAN) && !self.isFainted?
      if self.hp<=((self.totalhp/3).floor) || self.status!=0 ||
         @battle.field.effects[PBEffects::GlimmyGalaxy]>0
        if self.form!=2
          self.form=2; transformed=true
        end
      elsif @battle.field.effects[PBEffects::Cinament]>0
        if self.form!=3
          self.form=3; transformed=true
        end
      else
        if self.form!=1
          self.form=1; transformed=true
        end
      end
    end
    # Νεα Ελληνική Ραδιοφονία, Ιντερνετ Τηλεόραση (ΝΕΡΙΤ, or just N)
    if isConst?(self.species,PBSpecies,:NERIT)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Alter Channel
    if isConst?(self.species,PBSpecies,:ALTERCHANNEL)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Alter Plus
    if isConst?(self.species,PBSpecies,:ALTERPLUS)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Mega Channel
    if isConst?(self.species,PBSpecies,:MEGACHANNEL)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Mega Plus
    if isConst?(self.species,PBSpecies,:MEGAPLUS)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Surplété
    if isConst?(self.species,PBSpecies,:SURPLETE)
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    if transformed
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      pbSEPlay("GUI party switch")
      @battle.pbDisplay(_INTL("{1} transformed!",pbThis))
      PBDebug.log("[Form changed] #{pbThis} changed to form #{self.form}")
    end
  end

  def pbResetForm
    if !@effects[PBEffects::Transform]
      if isConst?(self.species,PBSpecies,:CASTFORM) ||
         isConst?(self.species,PBSpecies,:CHERRIM) ||
         isConst?(self.species,PBSpecies,:MELOETTA) ||
         isConst?(self.species,PBSpecies,:AEGISLASH) ||
         isConst?(self.species,PBSpecies,:XERNEAS) ||
         isConst?(self.species,PBSpecies,:WISHIWASHI) ||
         isConst?(self.species,PBSpecies,:MIMIKYU) ||
         isConst?(self.species,PBSpecies,:SOLGALEO) ||
         isConst?(self.species,PBSpecies,:LUNALA) ||
         isConst?(self.species,PBSpecies,:CRAMORANT) ||
         isConst?(self.species,PBSpecies,:POLTEAGEIST) ||
         isConst?(self.species,PBSpecies,:MORPEKO) ||
         isConst?(self.species,PBSpecies,:EISCUE) ||
         isConst?(self.species,PBSpecies,:ZACIAN) ||
         isConst?(self.species,PBSpecies,:ZAMAZENTA) ||
         isConst?(self.species,PBSpecies,:ETERNATUS) ||
         isConst?(self.species,PBSpecies,:KOULUNDIN) ||
         isConst?(self.species,PBSpecies,:FLAMENGO) ||
         isConst?(self.species,PBSpecies,:PACMAN) ||
         isConst?(self.species,PBSpecies,:NERIT) ||
         isConst?(self.species,PBSpecies,:DOLPHIN)
        self.form=0 if self.form!=0
      elsif isConst?(self.species,PBSpecies,:DARMANITAN)
        self.form-=1 if self.form==1 || self.form==3
      elsif isConst?(self.species,PBSpecies,:MINIOR)
        self.form+=7 if self.form < 7
      elsif isConst?(self.species,PBSpecies,:ROOMBA)
        self.form=[rand(3),rand(3)].min
      elsif isConst?(self.species,PBSpecies,:CANDYCRUSHSODA) ||
            isConst?(self.species,PBSpecies,:SODAPLUS)  || 
            isConst?(self.species,PBSpecies,:STARCHANNEL)
        self.form=rand(5)
      elsif isConst?(self.species,PBSpecies,:ETV)
        self.form-=2 if self.form>1
      elsif isConst?(self.species,PBSpecies,:NECROZMA)
        self.form=@effects[PBEffects::UBForm] if self.form==3
      end
    end
    pbUpdate(true)
  end

################################################################################
# Ability effects
################################################################################
  def pbAbilitiesOnSwitchIn(onactive)
    return if self.isFainted?
    if onactive
      @battle.pbPrimalReversion(self.index)
    end
    # Neutralizing Gas
    if isConst?(self.ability,PBAbilities,:NEUTRALIZINGGAS) && onactive &&
       !@battle.field.effects[PBEffects::NeutralizingGas] && !self.isFainted?
      @battle.field.effects[PBEffects::NeutralizingGas]=true
      @battle.pbDisplay(_INTL("Neutralizing gas filled the area!"))
    end
    # Weather
    if onactive
      if self.hasWorkingAbility(:PRIMORDIALSEA) && @battle.weather!=PBWeather::HEAVYRAIN
        for i in 0...4
          @battle.battlers[i].addTemp = 0
        end
        @battle.weather=PBWeather::HEAVYRAIN
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("HeavyRain",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} made a heavy rain begin to fall!",pbThis,PBAbilities.getName(self.ability)))
        PBDebug.log("[Ability triggered] #{pbThis}'s Primordial Sea made it rain heavily")
      end
      if self.hasWorkingAbility(:DESOLATELAND) && @battle.weather!=PBWeather::HARSHSUN
        for i in 0...4
          @battle.battlers[i].addTemp = 25
        end
        @battle.weather=PBWeather::HARSHSUN
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("HarshSun",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} turned the sunlight extremely harsh!",pbThis,PBAbilities.getName(self.ability)))
        PBDebug.log("[Ability triggered] #{pbThis}'s Desolate Land made the sun shine harshly")
      end
      if self.hasWorkingAbility(:DELTASTREAM) && @battle.weather!=PBWeather::STRONGWINDS
        for i in 0...4
          @battle.battlers[i].addTemp = 0
        end
        @battle.weather=PBWeather::STRONGWINDS
        @battle.weatherduration=-1

        @battle.pbCommonAnimation("StrongWinds",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} caused a mysterious air current that protects Flying-type Pokémon!",pbThis,PBAbilities.getName(self.ability)))
        PBDebug.log("[Ability triggered] #{pbThis}'s Delta Stream made an air current blow")
      end
      # Neutralizing Gas
      if self.hasWorkingAbility(:NEUTRALIZINGGAS) && !@battle.field.effects[PBEffects::NeutralizingGas]  # Not hasWorkingAbility (We need to be workable even if other abilities supressed)
        @battle.field.effects[PBEffects::NeutralizingGas]=true
#        @battle.pbDisplay(_INTL("{1}'s {2} turned the sunlight extremely harsh!",pbThis,PBAbilities.getName(self.ability)))
        PBDebug.log("[Ability triggered] #{pbThis}'s Neutralizing Gas started")
      end
      # End of Primal weather cancelling regular weather
      # Surges
      # https://www.pokecommunity.com/showthread.php?t=383035&page=2
      if self.hasWorkingAbility(:ELECTRICSURGE) && @battle.field.effects[PBEffects::ElectricTerrain]<=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::ElectricTerrain]=5
        @battle.field.effects[PBEffects::ElectricTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("An electric current runs across the battlefield!"))
        PBDebug.log("[#{pbThis}: Electric Surge made Electric Terrain]") # Kept Japanese name in Debug log
        self.checkMimicryAll
        # The Electric Seed raised Hawlucha's Defense!
      end
      if self.hasWorkingAbility(:HADRONENGINE) && @battle.field.effects[PBEffects::ElectricTerrain]<=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::ElectricTerrain]=5
        @battle.field.effects[PBEffects::ElectricTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("An electric current runs across the battlefield!"))
        PBDebug.log("[#{pbThis}: Hadron Engine made Electric Terrain]") # Kept Japanese name in Debug log
        self.checkMimicryAll
        # The Electric Seed raised Hawlucha's Defense!
      end
      if self.hasWorkingAbility(:PSYCHICSURGE) && @battle.field.effects[PBEffects::PsychicTerrain]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=5
        @battle.field.effects[PBEffects::PsychicTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("The battlefield got weird!"))
        PBDebug.log("[#{pbThis}: Psychic Surge made Psychic Terrain]")
        self.checkMimicryAll
      end
      if self.hasWorkingAbility(:GRASSYSURGE) && @battle.field.effects[PBEffects::GrassyTerrain]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=5
        @battle.field.effects[PBEffects::GrassyTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("Grass grew to cover the battlefield!"))
        PBDebug.log("[#{pbThis}: Grassy Surge made Grassy Terrain]")
        self.checkMimicryAll
      end
      if self.hasWorkingAbility(:MISTYSURGE) && @battle.field.effects[PBEffects::MistyTerrain]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=5
        @battle.field.effects[PBEffects::MistyTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("Mist swirls around the battlefield!"))
        PBDebug.log("[#{pbThis}: Misty Surge made Misty Terrain]")
        self.checkMimicryAll
      end
      if self.hasWorkingAbility(:VOLCANICSURGE) && @battle.field.effects[PBEffects::VolcanicTerrain]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=5
        @battle.field.effects[PBEffects::VolcanicTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.pbDisplay(_INTL("A heatness has been set up on the battlefield!"))
        PBDebug.log("[#{pbThis}: Volcanic Surge made Volcanic Terrain]")
        self.checkMimicryAll
      end
      if self.hasWorkingAbility(:LOVELYSURGE) && @battle.field.effects[PBEffects::LovelyTerrain]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::LovelyTerrain]=5
        @battle.field.effects[PBEffects::LovelyTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::Cinament]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.pbDisplay(_INTL("A loveness has been set up on the battlefield!"))
        PBDebug.log("[#{pbThis}: Lovely Surge made Lovely Terrain]")
        self.checkMimicryAll
      end
      if self.hasWorkingAbility(:CINEMAMAKER) && @battle.field.effects[PBEffects::Cinament]<=0
        @battle.field.effects[PBEffects::ElectricTerrain]=0
        @battle.field.effects[PBEffects::GrassyTerrain]=0
        @battle.field.effects[PBEffects::PsychicTerrain]=0
        @battle.field.effects[PBEffects::Cinament]=5
        @battle.field.effects[PBEffects::Cinament]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
        @battle.field.effects[PBEffects::LovelyTerrain]=0
        @battle.field.effects[PBEffects::MistyTerrain]=0
        @battle.field.effects[PBEffects::VolcanicTerrain]=0
        @battle.pbCommonAnimation("Cinament",nil,nil)
        @battle.pbDisplay(_INTL("A bolty cauldron has sweeped the battlefield!"))
        PBDebug.log("[#{pbThis}: Cinema Maker made Cinament]")
        self.checkMimicryAll
      end

      if self.hasWorkingAbility(:DARKTUNNEL) && @battle.field.effects[PBEffects::GlimmyGalaxy]<=0
        @battle.field.effects[PBEffects::GlimmyGalaxy]=3
        self.effects[PBEffects::DarkTunnel] = true
        pbCommonAnimation("GlimmyGalaxy",nil,nil)
        @battle.pbDisplay(_INTL("A Galaxian Tunnel has been emergenced on the battlefield!"))
        PBDebug.log("[#{pbThis}: Dark Tunnel made Glimmy Galaxy]")
      end
      # End surges
      if self.hasWorkingAbility(:ASTROPLANET) && @battle.field.effects[PBEffects::Gravity]<=0
        @battle.field.effects[PBEffects::Gravity]=5
        for i in 0...4
          poke=@battle.battlers[i]
          next if !poke
          if PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xC9  || # Fly
             PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCC  || # Bounce
             PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCE  || # Sky Drop
             PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0x366 || # Steel Fly
            poke.effects[PBEffects::TwoTurnAttack]=0
          end
          if poke.effects[PBEffects::SkyDrop]
            poke.effects[PBEffects::SkyDrop]=false
          end
          if poke.effects[PBEffects::MagnetRise]>0
            poke.effects[PBEffects::MagnetRise]=0
          end
          if poke.effects[PBEffects::Telekinesis]>0
            poke.effects[PBEffects::Telekinesis]=0
          end
          if poke.effects[PBEffects::MagicDelta]
            poke.effects[PBEffects::MagicDelta]=false
          end
        end
        @battle.pbDisplay(_INTL("Gravity intensified!"));
        PBDebug.log("[#{pbThis}: Astro Planet made Gravity intensified]")
      end
      if @battle.weather!=PBWeather::HEAVYRAIN &&
         @battle.weather!=PBWeather::HARSHSUN &&
         @battle.weather!=PBWeather::STRONGWINDS
        if self.hasWorkingAbility(:DRIZZLE) && (@battle.weather!=PBWeather::RAINDANCE || @battle.weatherduration!=-1)
          for i in 0...4
            @battle.battlers[i].addTemp = 0
          end
          @battle.weather=PBWeather::RAINDANCE
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:DAMPROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Rain",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} made it rain!",pbThis,PBAbilities.getName(self.ability)))
          PBDebug.log("[Ability triggered] #{pbThis}'s Drizzle made it rain")
        end
        if self.hasWorkingAbility(:DROUGHT) && (@battle.weather!=PBWeather::SUNNYDAY || @battle.weatherduration!=-1)
          for i in 0...4
            @battle.battlers[i].addTemp = 25
          end
          @battle.weather=PBWeather::SUNNYDAY
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:HEATROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Sunny",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} intensified the sun's rays!",pbThis,PBAbilities.getName(self.ability)))
          PBDebug.log("[Ability triggered] #{pbThis}'s Drought made it sunny")
        end
        if self.hasWorkingAbility(:ORICHALCUMPULSE) && (@battle.weather!=PBWeather::SUNNYDAY || @battle.weatherduration!=-1)
          for i in 0...4
            @battle.battlers[i].addTemp = 25
          end
          @battle.weather=PBWeather::SUNNYDAY
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:HEATROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Sunny",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} intensified the sun's rays!",pbThis,PBAbilities.getName(self.ability)))
          PBDebug.log("[Ability triggered] #{pbThis}'s Orichalcum Pulse made it sunny")
        end
        if self.hasWorkingAbility(:SANDSTREAM) && (@battle.weather!=PBWeather::SANDSTORM || @battle.weatherduration!=-1)
          for i in 0...4
            @battle.battlers[i].addTemp = 0
          end
          @battle.weather=PBWeather::SANDSTORM
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:SMOOTHROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Sandstorm",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} whipped up a sandstorm!",pbThis,PBAbilities.getName(self.ability)))
          PBDebug.log("[Ability triggered] #{pbThis}'s Sand Stream made it sandstorm")
        end
        if self.hasWorkingAbility(:SNOWWARNING) && (@battle.weather!=PBWeather::HAIL || @battle.weatherduration!=-1)
          for i in 0...4
            @battle.battlers[i].addTemp = -20
          end
          @battle.weather=PBWeather::HAIL
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:ICYROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Hail",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} made it hail!",pbThis,PBAbilities.getName(self.ability)))
          PBDebug.log("[Ability triggered] #{pbThis}'s Snow Warning made it hail")
        end
      end
      if self.hasWorkingAbility(:AIRLOCK) ||
         self.hasWorkingAbility(:CLOUDNINE)
        @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,PBAbilities.getName(self.ability)))
        @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
      end
    end
    @battle.pbPrimordialWeather
    # changed
    if self.hasWorkingAbility(:DISGUISE) && isConst?(species,PBSpecies,:MIMIKYU) &&
       self.form==0 && onactive
      @effects[PBEffects::Disguise]=true
    end
    if self.hasWorkingAbility(:ICEFACE) && isConst?(species,PBSpecies,:EISCUE) &&
       self.form==0 && onactive
      @effects[PBEffects::IceFace]=true
    end
    # changed end
    # Screen Cleaner
    if self.hasWorkingAbility(:SCREENCLEANER)
      PBDebug.log("[Ability triggered] #{pbThis}'s Screen Cleaner")
      pbOwnSide.effects[PBEffects::Reflect]     = 0
      pbOwnSide.effects[PBEffects::LightScreen] = 0
      pbOwnSide.effects[PBEffects::AuroraVeil]  = 0 # changed
      pbOpposingSide.effects[PBEffects::Reflect]     = 0
      pbOpposingSide.effects[PBEffects::LightScreen] = 0
      pbOpposingSide.effects[PBEffects::AuroraVeil]  = 0 # changed
      @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,PBAbilities.getName(self.ability)))
      @battle.pbDisplay(_INTL("The effects of protective barriers disappeared."))
    end
    # Trace
    if self.hasWorkingAbility(:TRACE)
      choices=[]
      for i in 0...4
        foe=@battle.battlers[i]
        if pbIsOpposing?(i) && !foe.isFainted?
          abil=foe.ability
          if abil>0 &&
             !isConst?(abil,PBAbilities,:BATTLEBOND) &&
             !isConst?(abil,PBAbilities,:COMMANDER) &&
             !isConst?(abil,PBAbilities,:COMATOSE) &&
             !isConst?(abil,PBAbilities,:DISGUISE) &&
             !isConst?(abil,PBAbilities,:FLOWERGIFT) &&
             !isConst?(abil,PBAbilities,:FORECAST) &&
             !isConst?(abil,PBAbilities,:GULPMISSILE) &&
             !isConst?(abil,PBAbilities,:ICEFACE) &&
             !isConst?(abil,PBAbilities,:ILLUSION) &&
             !isConst?(abil,PBAbilities,:IMPOSTER) &&
             !isConst?(abil,PBAbilities,:MULTITYPE) &&
             !isConst?(abil,PBAbilities,:NEUTRALIZINGGAS) &&
             !isConst?(abil,PBAbilities,:POWERCONSTRUCT) &&
             !isConst?(abil,PBAbilities,:PROTOSYNTHESIS) &&
             !isConst?(abil,PBAbilities,:QUARKDRIVE) &&
             !isConst?(abil,PBAbilities,:RECEIVER) &&
             !isConst?(abil,PBAbilities,:RKSSYSTEM) &&
             !isConst?(abil,PBAbilities,:SCHOOLING) &&
             !isConst?(abil,PBAbilities,:SHIELDSDOWN) &&
             !isConst?(abil,PBAbilities,:STANCECHANGE) &&
             !isConst?(abil,PBAbilities,:TRACE) &&
             !isConst?(abil,PBAbilities,:ZEROTOHERO) &&
             !isConst?(abil,PBAbilities,:KOULUNDIN) &&
             !isConst?(abil,PBAbilities,:CHIKOLINI) &&
             !isConst?(abil,PBAbilities,:DOLPHININO) &&
             !isConst?(abil,PBAbilities,:HERALINA) &&
             !isConst?(abil,PBAbilities,:ABILITOPIA) &&
             !isConst?(abil,PBAbilities,:MORFAT)
             choices.push(i)
          end
        end
      end
      if choices.length>0
        choice=choices[@battle.pbRandom(choices.length)]
        battlername=@battle.battlers[choice].pbThis(true)
        battlerability=@battle.battlers[choice].ability
        @ability=battlerability
        abilityname=PBAbilities.getName(battlerability)
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,battlername,abilityname))
        PBDebug.log("[Ability triggered] #{pbThis}'s Trace turned into #{abilityname} from #{battlername}")
      end
    end
    # Intimidate
    if self.hasWorkingAbility(:INTIMIDATE) && onactive
      PBDebug.log("[Ability triggered] #{pbThis}'s Intimidate")
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceAttackStatIntimidate(self)
        end
      end
    end
    # Intimidoom
    if self.hasWorkingAbility(:INTIMIDOOM) && onactive
      PBDebug.log("[Ability triggered] #{pbThis}'s Intimidoom")
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceSpAttackStatIntimidoom(self)
        end
      end
    end
    # Intimilow
    if self.hasWorkingAbility(:INTIMILOW) && onactive
      PBDebug.log("[Ability triggered] #{pbThis}'s Intimilow")
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceSpeedStatIntimilow(self)
        end
      end
    end
    # Lens Intimidate
    if self.hasWorkingAbility(:LENSINTIMIDATE) && onactive
      PBDebug.log("[Ability triggered] #{pbThis}'s Lens Intimidate")
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceProficientStatLensIntimidate(self)
        end
      end
    end
    # Corrosive Gas (Curing)
      if self.pbHasType?(:GAS) && self.pokemon.corrosiveGas
        self.pokemon.corrosiveGas=false
        @battle.pbDisplay(_INTL("{1}'s {2} is no longer corroded!",self.pbThis,PBItems.getName(self.item)))
      end
    # Download
    if self.hasWorkingAbility(:DOWNLOAD) && onactive
      odef=ospdef=0
      if pbOpposing1 && !pbOpposing1.isFainted?
        odef+=pbOpposing1.defense
        ospdef+=pbOpposing1.spdef
      end
      if pbOpposing2 && !pbOpposing2.isFainted?
        odef+=pbOpposing2.defense
        ospdef+=pbOpposing2.spdef
      end
      if ospdef>odef
        if pbIncreaseStatWithCause(PBStats::ATTACK,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Download (raising Attack)")
        end
      else
        if pbIncreaseStatWithCause(PBStats::SPATK,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Download (raising Special Attack)")
        end
      end
    end
    # NetPlay
    if self.hasWorkingAbility(:NETPLAY) && onactive
      oatk=ospatk=0
      if pbOpposing1 && !pbOpposing1.isFainted?
        oatk+=pbOpposing1.attack
        ospatk+=pbOpposing1.spatk
      end
      if pbOpposing2 && !pbOpposing2.isFainted?
        oatk+=pbOpposing2.attack
        ospatk+=pbOpposing2.spatk
      end
      if ospatk>oatk
        if pbIncreaseStatWithCause(PBStats::DEFENSE,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s NetPlay (raising Defense)")
        end
      else
        if pbIncreaseStatWithCause(PBStats::SPDEF,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s NetPlay (raising Special Defense)")
        end
      end
    end
    # Upload
    if self.hasWorkingAbility(:UPLOAD) && onactive
      oatk=ospatk=0
      if pbOpposing1 && !pbOpposing1.isFainted?
        oatk+=pbOpposing1.attack
        ospatk+=pbOpposing1.spatk
      end
      if pbOpposing2 && !pbOpposing2.isFainted?
        oatk+=pbOpposing2.attack
        ospatk+=pbOpposing2.spatk
      end
      if ospatk>oatk
        if pbIncreaseStatWithCause(PBStats::DEFENSE,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Upload (raising Defense)")
        end
      else
        if pbIncreaseStatWithCause(PBStats::SPDEF,1,self,PBAbilities.getName(ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Upload (raising Special Defense)")
        end
      end
    end
    # Battle Booster
    if self.hasWorkingAbility(:BATTLEBOOSTER) && onactive
      oatk=odef=ospeed=ospatk=ospdef=0
      if pbOpposing1 && !pbOpposing1.isFainted?
        oatk+=pbOpposing1.attack
        odef+=pbOpposing1.defense
        ospeed+=pbOpposing1.speed
        ospatk+=pbOpposing1.spatk
        ospdef+=pbOpposing1.spdef
      end
      if pbOpposing2 && !pbOpposing2.isFainted?
        oatk+=pbOpposing2.attack
        odef+=pbOpposing2.defense
        ospeed+=pbOpposing2.speed
        ospatk+=pbOpposing2.spatk
        ospdef+=pbOpposing2.spdef
      end
      showanim='mix'
      if oatk >= odef &&
          oatk >= ospatk &&
          oatk >= ospdef &&
          oatk >= ospeed
        if pbIncreaseStatWithCause(PBStats::DEFENSE,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Defense)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::EVASION,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Evasion)")
        end
      elsif odef >= ospatk &&
          odef >= ospdef &&
          odef >= ospeed
        if pbIncreaseStatWithCause(PBStats::ATTACK,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Attack)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::ACCURACY,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Accuracy)")
        end
      elsif ospatk >= ospdef &&
          ospatk >= ospeed
        if pbIncreaseStatWithCause(PBStats::SPDEF,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Special Defense)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::EVASION,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Evasion)")
        end
      elsif ospdef >= ospeed
        if pbIncreaseStatWithCause(PBStats::SPATK,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Special Attack)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::ACCURACY,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Accuracy)")
        end
      else
        if pbIncreaseStatWithCause(PBStats::SPEED,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Speed)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::ACCURACY,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Accuracy)")
          showanim=false
        end
        if pbIncreaseStatWithCause(PBStats::EVASION,3,self,PBAbilities.getName(ability),showanim)
          PBDebug.log("[Ability triggered] #{pbThis}'s Battle Booster (raising Evasion)")
        end
      end
    end

    # Emergence Policy
    if self.hasWorkingItem(:EMERGENCEPOLICY) && onactive
      oatk=ospatk=0
      if pbOpposing1 && !pbOpposing1.isFainted?
        oatk+=pbOpposing1.attack
        ospatk+=pbOpposing1.spatk
      end
      if pbOpposing2 && !pbOpposing2.isFainted?
        oatk+=pbOpposing2.attack
        ospatk+=pbOpposing2.spatk
      end
      if ospatk>oatk
        if pbIncreaseStatWithCause(PBStats::DEFENSE,2,self,PBItems.getName(item))
          pbConsumeItem(false,false)
          PBDebug.log("[Item triggered] #{pbThis}'s Emergence Policy (raising Defense)")
        end
      else
        if pbIncreaseStatWithCause(PBStats::SPDEF,2,self,PBItems.getName(item))
          pbConsumeItem(false,false)
          PBDebug.log("[Item triggered] #{pbThis}'s Emergence Policy (raising Special Defense)")
        end
      end
    end
    # Intrepid Sword
    if self.hasWorkingAbility(:INTREPIDSWORD) && onactive
      if pbIncreaseStatWithCause(PBStats::ATTACK,1,self,PBAbilities.getName(ability))
        PBDebug.log("[Ability triggered] #{pbThis}'s Intrepid Sword")
      end
    end
    # Dauntless Shield
    if self.hasWorkingAbility(:DAUNTLESSSHIELD) && onactive
      if pbIncreaseStatWithCause(PBStats::DEFENSE,1,self,PBAbilities.getName(ability))
        PBDebug.log("[Ability triggered] #{pbThis}'s Dauntless Shield")
      end
    end
    # Frisk
    if self.hasWorkingAbility(:FRISK) && @battle.pbOwnedByPlayer?(@index) && onactive
      foes=[]
      foes.push(pbOpposing1) if pbOpposing1.item>0 && !pbOpposing1.isFainted?
      foes.push(pbOpposing2) if pbOpposing2.item>0 && !pbOpposing2.isFainted?
      if $USENEWBATTLEMECHANICS
        PBDebug.log("[Ability triggered] #{pbThis}'s Frisk") if foes.length>0
        for i in foes
          itemname=PBItems.getName(i.item)
          @battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",pbThis,i.pbThis(true),itemname))
        end
      elsif foes.length>0
        PBDebug.log("[Ability triggered] #{pbThis}'s Frisk")
        foe=foes[@battle.pbRandom(foes.length)]
        itemname=PBItems.getName(foe.item)
        @battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",pbThis,itemname))
      end
    end
    # Anticipation
    if self.hasWorkingAbility(:ANTICIPATION) && @battle.pbOwnedByPlayer?(@index) && onactive
      PBDebug.log("[Ability triggered] #{pbThis} has Anticipation")
      found=false
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          eff=PBTypes.getCombinedEffectiveness(movedata.type,type1,type2,@effects[PBEffects::Type3])
          if (movedata.basedamage>0 && eff>8) ||
             ( movedata.isOHKO?  && eff>0) # OHKO
            found=true
            break
          end
        end
        break if found
      end
      @battle.pbDisplay(_INTL("{1} shuddered with anticipation!",pbThis)) if found
    end
    # Forewarn
    if self.hasWorkingAbility(:FOREWARN) && @battle.pbOwnedByPlayer?(@index) && onactive
      PBDebug.log("[Ability triggered] #{pbThis} has Forewarn")
      highpower=0
      fwmoves=[]
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          power=movedata.basedamage
          power=160 if movedata.isOHKO?            # OHKO
          power=150 if movedata.function==0x8B     # Eruption
          power=120 if movedata.function==0x71 ||  # Counter
                       movedata.function==0x72 ||  # Mirror Coat
                       movedata.function==0x73 ||  # Metal Burst
          power=80 if movedata.function==0x6A ||   # SonicBoom
                      movedata.function==0x6B ||   # Dragon Rage
                      movedata.function==0x6D ||   # Night Shade
                      movedata.function==0x6E ||   # Endeavor
                      movedata.function==0x6F ||   # Psywave
                      movedata.function==0x89 ||   # Return
                      movedata.function==0x8A ||   # Frustration
                      movedata.function==0x8C ||   # Crush Grip
                      movedata.function==0x8D ||   # Gyro Ball
                      movedata.function==0x90 ||   # Hidden Power
                      movedata.function==0x96 ||   # Natural Gift
                      movedata.function==0x97 ||   # Trump Card
                      movedata.function==0x98 ||   # Flail
                      movedata.function==0x9A ||   # Grass Knot
                      movedata.function==0x188     # Topsy-Damage
          if power>highpower
            fwmoves=[j.id]; highpower=power
          elsif power==highpower
            fwmoves.push(j.id)
          end
        end
      end
      if fwmoves.length>0
        fwmove=fwmoves[@battle.pbRandom(fwmoves.length)]
        movename=PBMoves.getName(fwmove)
        @battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",pbThis,movename))
      end
    end
    # Pressure message
    if self.hasWorkingAbility(:PRESSURE) && onactive
      @battle.pbDisplay(_INTL("{1} is exerting its pressure!",pbThis))
    end
    # Herbalility/Botanic Smoke message
    if (self.hasWorkingAbility(:HERBALILITY) ||
        self.hasWorkingItem(:BOTANICSMOKE))   && onactive
      @battle.pbDisplay(_INTL("{1} is trying to take a foe down with it!",pbThis))
    end
    # Pastel Veil (Curing Poisoning)
    if self.hasWorkingAbility(:PASTELVEIL) && self.pbPartner.status==PBStatuses::POISON && onactive
      self.pbPartner.pbCureStatus(false)
      pbDisplay(_INTL("{1}'s {2} cured its partner's poison problem!",self.pbThis,PBAbilities.getName(self.ability)))
    end
    # Commander
    if self.hasWorkingAbility(:COMMANDER) && 
       isConst?(self.pbPartner.species,PBSpecies,:DONDOZO) && 
        !self.pbPartner.isFainted? && self.pbPartner &&
       !self.pbPartner.effects[PBEffects::CommanderAlly]
        PBDebug.log("[Ability triggered] #{pbThis}'s Commander")
      self.effects[PBEffects::Commander]=true
      self.pbPartner.effects[PBEffects::CommanderAlly]=true
      showanim='mix'
      if self.pbPartner.pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBAbilities.getName(self.ability),showanim)
        showanim=false
      end
      if self.pbPartner.pbIncreaseStatWithCause(PBStats::DEFENSE,2,self,PBAbilities.getName(self.ability),showanim)
        showanim=false
      end
      if self.pbPartner.pbIncreaseStatWithCause(PBStats::SPATK,2,self,PBAbilities.getName(self.ability),showanim)
        showanim=false
      end
      if self.pbPartner.pbIncreaseStatWithCause(PBStats::SPDEF,2,self,PBAbilities.getName(self.ability),showanim)
        showanim=false
      end
      if self.pbPartner.pbIncreaseStatWithCause(PBStats::SPEED,2,self,PBAbilities.getName(self.ability),showanim)
        showanim=false
      end
    end
    # Costar
    if self.hasWorkingAbility(:COSTAR) && self.pbPartner && onactive
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        self.stages[i]=self.pbPartner.stages[i]
      end
      @battle.pbDisplay(_INTL("{1}'s {2} copied {3}'s stat changes!",pbThis,PBAbilities.getName(self.ability),pbPartner.pbThis(true)))
    end
    # Curious Medicine
    if self.hasWorkingAbility(:CURIOUSMEDICINE) && onactive
          self.stages[PBStats::ATTACK]=0
          self.stages[PBStats::DEFENSE]=0
          self.stages[PBStats::SPATK]=0
          self.stages[PBStats::SPDEF]=0
          self.stages[PBStats::SPEED]=0
          self.stages[PBStats::ACCURACY]=0
          self.stages[PBStats::EVASION]=0
          if pbPartner
            pbPartner.stages[PBStats::ATTACK]=0
            pbPartner.stages[PBStats::DEFENSE]=0
            pbPartner.stages[PBStats::SPATK]=0
            pbPartner.stages[PBStats::SPDEF]=0
            pbPartner.stages[PBStats::SPEED]=0
            pbPartner.stages[PBStats::ACCURACY]=0
            pbPartner.stages[PBStats::EVASION]=0
          end
    end
    # Imprisin
    if self.hasWorkingAbility(:IMPRISIN) && onactive
      @battle.pbDisplay(_INTL("{1}'s Imprisin sealed the opponent's move(s)!",pbThis))
      self.effects[PBEffects::Imprison]=true
    end
    # Mold Breaker message
    if self.hasWorkingAbility(:MOLDBREAKER) && onactive
      @battle.pbDisplay(_INTL("{1} breaks the mold!",pbThis))
    end
    # Comatose message
    if isConst?(ability,PBAbilities,:COMATOSE) && onactive
      @battle.pbDisplay(_INTL("{1} is drowsing!",pbThis))
    end
    # Turboblaze message
    if self.hasWorkingAbility(:TURBOBLAZE) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",pbThis))
    end
    # Teravolt message
    if self.hasWorkingAbility(:TERAVOLT) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",pbThis))
    end
    # Dark Aura message
    if self.hasWorkingAbility(:DARKAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a dark aura!",pbThis))
    end
    # Fairy Aura message
    if self.hasWorkingAbility(:FAIRYAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",pbThis))
    end
    # Aura Break message
    if self.hasWorkingAbility(:AURABREAK) && onactive
      @battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",pbThis))
    end
    # Slow Start message
    if self.hasWorkingAbility(:SLOWSTART) && onactive
      @battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         pbThis,PBAbilities.getName(self.ability)))
    end
    # Mimicry 
    if self.hasWorkingAbility(:MIMICRY) && onactive
      self.checkMimicry
    end
    # Parent Child
    if isConst?(species,PBSpecies,:ETV) && form<2 && hasWorkingItem(:PARENTCHILD)
      self.form+=2
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,self.pokemon)
      @battle.pbDisplay(_INTL("{1} summoned a Parent Child!",pbThis))
      pbConsumeItem
    end
    # Imposter
    if self.hasWorkingAbility(:IMPOSTER) && !@effects[PBEffects::Transform] && onactive
      choice=pbOppositeOpposing
      blacklist=[
         0xC9,    # Fly
         0xCA,    # Dig
         0xCB,    # Dive
         0xCC,    # Bounce
         0xCD,    # Shadow Force
         0xCE,    # Sky Drop
         0x14D,   # Phantom Force
         0x336    # Steel Fly
      ]
      if choice.effects[PBEffects::Transform] ||
         @effects[PBEffects::TransformBlock] ||
         choice.effects[PBEffects::TransformProtection] ||
         choice.effects[PBEffects::Illusion] ||
         choice.effects[PBEffects::Substitute]>0 ||
         choice.effects[PBEffects::SkyDrop] ||
         blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function) ||
         isConst?(choice.ability,PBAbilities,:KOULUNDIN) ||
         isConst?(choice.ability,PBAbilities,:ALONELY) ||
         isUltraBlue?(choice) ||
         @battle.field.effects[PBEffects::Cinament]>0 && !hasWorkingItem(:RODOFSPARROW)
        PBDebug.log("[Ability triggered] #{pbThis}'s Imposter couldn't transform")
      elsif choice.hasWorkingItem(:PASTELCARD) 
        if pbReduceStatWithCause(PBStats::DEFENSE,1,choice,PBItems.getName(choice.item))
          choice.effects[PBEffects::TransformProtection]=true
          choice.pbConsumeItem
        end
      elsif choice.hasWorkingItem(:PLACTENCARD) 
        if pbReduceStatWithCause(PBStats::SPDEF,1,choice,PBItems.getName(choice.item))
          choice.effects[PBEffects::TransformProtection]=true
          @effects[PBEffects::TransformBlock]=true
          choice.pbConsumeItem
        end
      else
        PBDebug.log("[Ability triggered] #{pbThis}'s Imposter")
        @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),self,choice)
        @effects[PBEffects::Transform]=true
        @effects[PBEffects::Mimicry] = choice.effects[PBEffects::Mimicry]
        @effects[PBEffects::Type1] = choice.effects[PBEffects::Type1]
        @effects[PBEffects::Type2] = choice.effects[PBEffects::Type2]
        @type1=choice.type1
        @type2=choice.type2
        @effects[PBEffects::Type3]=-1
        @ability=choice.ability
        @attack=choice.attack
        @defense=choice.defense
        @speed=choice.speed
        @spatk=choice.spatk
        @spdef=choice.spdef
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          @stages[i]=choice.stages[i]
        end
        for i in 0...4
          @moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
          @moves[i].pp=5
          @moves[i].totalpp=5
        end
        @effects[PBEffects::Disable]=0
        @effects[PBEffects::DisableMove]=0
        @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,choice.pbThis(true)))
        PBDebug.log("[Pokémon transformed] #{pbThis} transformed into #{choice.pbThis(true)}")
      end
    end
    # Soufliz
    if self.hasWorkingAbility(:SOUFLIZ) && self.status!=0 && onactive
        dodge=false
        damager=(rand(100)<50) ? pbOpposing1 : pbOpposing2
        damager= pbOpposing1 if !@battle.doublebattle
        if (self.status==PBStatuses::PARALYSIS && !pbOpposing1.pbCanParalyze?(self,false,self)) ||
           (self.status==PBStatuses::SLEEP && !pbOpposing1.pbCanSleep?(self,false,self)) ||
           (self.status==PBStatuses::POISON && !pbOpposing1.pbCanPoison?(self,false,self)) ||
           (self.status==PBStatuses::BURN && !pbOpposing1.pbCanBurn?(self,false,self)) ||
           (self.status==PBStatuses::FROZEN && !pbOpposing1.pbCanFreeze?(self,false,self))
            damager=pbOpposing2  # If 1st opposing can't be affected, use the 2nd
            dodge=true if !@battle.doublebattle
        elsif ((self.status==PBStatuses::PARALYSIS && !pbOpposing2.pbCanParalyze?(self,false,self)) ||
           (self.status==PBStatuses::SLEEP && !pbOpposing2.pbCanSleep?(self,false,self)) ||
           (self.status==PBStatuses::POISON && !pbOpposing2.pbCanPoison?(self,false,self)) ||
           (self.status==PBStatuses::BURN && !pbOpposing2.pbCanBurn?(self,false,self)) ||
           (self.status==PBStatuses::FROZEN && !pbOpposing2.pbCanFreeze?(self,false,self))) && @battle.doublebattle
            damager=pbOpposing1  # If 2nd opposing can't be affected, use the 1st
            dodge=true if !@battle.doublebattle
        end
        if (self.status==PBStatuses::PARALYSIS && !pbOpposing1.pbCanParalyze?(self,false,self) && !pbOpposing2.pbCanParalyze?(self,false,self) ) ||
           (self.status==PBStatuses::SLEEP && !pbOpposing1.pbCanSleep?(self,false,self) && !pbOpposing2.pbCanSleep?(self,false,self)) ||
           (self.status==PBStatuses::POISON && !pbOpposing1.pbCanPoison?(self,false,self) && !pbOpposing2.pbCanPoison?(self,false,self)) ||
           (self.status==PBStatuses::BURN && !pbOpposing1.pbCanBurn?(self,false,self) && !pbOpposing2.pbCanBurn?(self,false,self)) ||
           (self.status==PBStatuses::FROZEN && !pbOpposing1.pbCanFreeze?(self,false,self) && !pbOpposing2.pbCanFreeze?(self,false,self)) &&
           @battle.doublebattle
            dodge=true # If neither opposing can't be affected, dodge the ability completely
        end
        if !dodge
          case self.status
          when PBStatuses::PARALYSIS
            damager.pbParalyze(self,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",self.pbThis,PBAbilities.getName(self.ability),damager.pbThis(true)))
            damager.pbAbilityCureCheck
          when PBStatuses::SLEEP
            damager.pbSleep(_INTL("{1}'s {2} made {3} fall asleep!",self.pbThis,PBAbilities.getName(self.ability),damager.pbThis(true)))
            damager.pbAbilityCureCheck
          when PBStatuses::POISON
            damager.pbPoison(self,_INTL("{1}'s {2} poisoned {3}!",self.pbThis,PBAbilities.getName(self.ability),damager.pbThis(true)),self.statusCount!=0)
            damager.pbAbilityCureCheck
          when PBStatuses::BURN
            damager.pbBurn(self,_INTL("{1}'s {2} burned {3}!",self.pbThis,PBAbilities.getName(self.ability),damager.pbThis(true)))
            damager.pbAbilityCureCheck
          when PBStatuses::FROZEN
            damager.pbFreeze(_INTL("{1}'s {2} made {3} frozen solid!",self.pbThis,PBAbilities.getName(self.ability),damager.pbThis(true)))
            damager.pbAbilityCureCheck
          end
        end
    end
    # Air Balloon message
    if self.hasWorkingItem(:AIRBALLOON) && onactive
      @battle.pbDisplay(_INTL("{1} floats in the air with its {2}!",pbThis,PBItems.getName(self.item)))
    end
  end

  def pbEffectsOnDealingDamage(move,user,target,damage)
    movetype=move.pbType(move.type,user,target)
    if damage>0 && move.isContactMove? && !user.hasWorkingAbility(:LONGREACH) && 
       !(user.hasWorkingItem(:PROTECTIVEPADS) || target.hasWorkingItem(:PROTECTIVEPADS)) # changed
      if !target.damagestate.substitute
        if target.hasWorkingItem(:STICKYBARB,true) && user.item==0 && !user.isFainted?
          user.item=target.item
          target.item=0
          target.effects[PBEffects::Unburden]=true
          if !@battle.opponent && !@battle.pbIsOpposing?(user.index)
            if user.pokemon.itemInitial==0 && target.pokemon.itemInitial==user.item
              user.pokemon.itemInitial=user.item
              target.pokemon.itemInitial=0
            end
          end
          @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
             target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
          PBDebug.log("[Item triggered] #{target.pbThis}'s Sticky Barb moved to #{user.pbThis(true)}")
        end
        if target.hasWorkingItem(:ROCKYHELMET,true) && !user.isFainted?
          if !((user.hasWorkingAbility(:MAGICGUARD)) || (user.hasWorkingAbility(:SUPERCLEARBODY)))
            PBDebug.log("[Item triggered] #{target.pbThis}'s Rocky Helmet")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/6).floor)
            @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,
               PBItems.getName(target.item)))
          end
        end
        # changed added
        # in the section for damage > 0, contact damage, and NOT hitting a sub
        targetchoice=@battle.choices[target.index][2] # 2 refers to the move
        if targetchoice && !targetchoice.is_a?(Numeric) && targetchoice.function==0x220 && user.pbCanBurn?(nil,false) # Beak Blast
          # targetchoice==0 means the target hasn't picked a move this round (switched, used a poke ball etc.)
          user.pbBurn(target)
        end
        # changed end
        if target.hasWorkingAbility(:AFTERMATH,true) && target.isFainted? &&
           !user.isFainted?
          if !@battle.pbCheckGlobalAbility(:DAMP) &&
             !user.hasMoldBreaker && !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY)) 
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Aftermath")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/4).floor)
            @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
          end
        end
        if target.hasWorkingAbility(:CUTECHARM) && @battle.pbRandom(10)<3 && !user.pbHasType?(:SHARPENER)
          if !user.isFainted? && user.pbCanAttract?(target,false)
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Cute Charm")
            user.pbAttract(target,_INTL("{1}'s {2} made {3} fall in love!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:EFFECTSPORE,true) && @battle.pbRandom(10)<3
          if $USENEWBATTLEMECHANICS &&
             (user.pbHasType?(:GRASS) || user.pbHasType?(:CHLOROPHYLL) ||
             user.pbHasType?(:GAS) || user.hasWorkingAbility(:OVERCOAT) ||
             user.hasWorkingItem(:SAFETYGOGGLES))
          else
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Effect Spore")
            case @battle.pbRandom(3)
            when 0
              if user.pbCanPoison?(nil,false)
                user.pbPoison(target,_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
                   PBAbilities.getName(target.ability),user.pbThis(true)))
              end
            when 1
              if user.pbCanSleep?(nil,false)
                user.pbSleep(_INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
                   PBAbilities.getName(target.ability),user.pbThis(true)))
              end
            when 2
              if user.pbCanParalyze?(nil,false)
                user.pbParalyze(target,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
                   target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
              end
            end
          end
        end
        # NERIT
        if isConst?(target.species,PBSpecies,:NERIT)
          oldform = target.form
          @battle.pbDisplay(_INTL("{1} shuffled out the deck!",target.pbThis))
          target.effects[PBEffects::Splicern]=rand(65536) # Shuffle out forms
          target.form = target.effects[PBEffects::Splicern]%5
          if oldform != target.form
            target.pbUpdate(true)
            @battle.scene.pbChangePokemon(target,target.pokemon)
            pbSEPlay("GUI party switch")
            @battle.pbDisplay(_INTL("{1} transformed!",target.pbThis))
            PBDebug.log("[Form changed] #{pbThis} changed to form #{self.form}")
          end
        end
        # Wandering Spirit
        if user.hasWorkingAbility(:WANDERINGSPIRIT)
          if (taregt.ability==0) ||
             (user.ability==target.ability && !$USENEWBATTLEMECHANICS) ||
             isConst?(target.ability,PBAbilities,:BATTLEBOND) ||
             isConst?(target.ability,PBAbilities,:COMMANDER) ||
             isConst?(target.ability,PBAbilities,:COMATOSE) ||
             isConst?(target.ability,PBAbilities,:DISGUISE) ||
             isConst?(target.ability,PBAbilities,:GULPMISSILE) ||
             isConst?(target.ability,PBAbilities,:ICEFACE) ||
             isConst?(target.ability,PBAbilities,:ILLUSION) ||
             isConst?(target.ability,PBAbilities,:MULTITYPE) ||
             isConst?(target.ability,PBAbilities,:NEUTRALIZINGGAS) ||
             isConst?(target.ability,PBAbilities,:POWERCONSTRUCT) ||
             isConst?(target.ability,PBAbilities,:PROTOSYNTHESIS) ||
             isConst?(target.ability,PBAbilities,:QUARKDRIVE) ||
             isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
             isConst?(target.ability,PBAbilities,:SCHOOLING) ||
             isConst?(target.ability,PBAbilities,:SHIELDSDOWN) ||
             isConst?(target.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(target.ability,PBAbilities,:WONDERGUARD) ||
             isConst?(target.ability,PBAbilities,:ZEROTOHERO) ||
             isConst?(target.ability,PBAbilities,:KOULUNDIN) ||
             isConst?(target.ability,PBAbilities,:CHIKOLINI) ||
             isConst?(target.ability,PBAbilities,:MAXTHIN) ||
             isConst?(target.ability,PBAbilities,:IMPRISIN) ||
             isConst?(target.ability,PBAbilities,:ABILITOPIA) ||
             isConst?(target.ability,PBAbilities,:MORFAT)
          else
          tmp=user.ability
          user.ability=target.ability
          target.ability=tmp
          @battle.pbDisplay(_INTL("{1} swapped its {2} Ability with its target's {3} Ability!",
             user.pbThis,PBAbilities.getName(target.ability),
             PBAbilities.getName(user.ability)))
          user.pbAbilitiesOnSwitchIn(true)
          target.pbAbilitiesOnSwitchIn(true)
          end
        end
        # Heralina
        if target.hasWorkingAbility(:HERALINA) && @battle.pbRandom(10)<3 &&
        !target.isFainted?
        choice=user
        blacklist=[
           0xC9,    # Fly
           0xCA,    # Dig
           0xCB,    # Dive
           0xCC,    # Bounce
           0xCD,    # Shadow Force
           0xCE,    # Sky Drop
           0x14D,   # Phantom Force
           0x336    # Steel Fly
        ]
        if choice.effects[PBEffects::Transform] ||
           target.effects[PBEffects::Transform] ||
           target.effects[PBEffects::TransformBlock] ||
           choice.effects[PBEffects::TransformProtection] ||
           choice.effects[PBEffects::Illusion] ||
           choice.effects[PBEffects::Substitute]>0 ||
           choice.effects[PBEffects::SkyDrop] ||
           blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function) ||
           isConst?(choice.ability,PBAbilities,:KOULUNDIN) ||
           isConst?(choice.ability,PBAbilities,:ALONELY) ||
           isUltraBlue?(choice) ||
           @battle.field.effects[PBEffects::Cinament]>0 && !target.hasWorkingItem(:RODOFSPARROW)
          PBDebug.log("[Ability triggered] #{pbThis}'s Heralina couldn't transform")
        elsif choice.hasWorkingItem(:PASTELCARD) 
          if target.pbReduceStatWithCause(PBStats::DEFENSE,1,choice,PBItems.getName(choice.item))
            choice.effects[PBEffects::TransformProtection]=true
            choice.pbConsumeItem
          end
        elsif choice.hasWorkingItem(:PLACTENCARD) 
          if target.pbReduceStatWithCause(PBStats::SPDEF,1,choice,PBItems.getName(choice.item))
            choice.effects[PBEffects::TransformProtection]=true
            target.effects[PBEffects::TransformBlock]=true
            choice.pbConsumeItem
          end
        else
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Heralina")
          @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),target,choice)
          target.effects[PBEffects::Transform]=true
          target.effects[PBEffects::Mimicry] = choice.effects[PBEffects::Mimicry]
          target.effects[PBEffects::Type1] = choice.effects[PBEffects::Type1]
          target.effects[PBEffects::Type2] = choice.effects[PBEffects::Type2]
          target.type1=choice.type1
          target.type2=choice.type2
          target.effects[PBEffects::Type3]=-1
          target.ability=choice.ability
          target.attack=choice.attack
          target.defense=choice.defense
          target.speed=choice.speed
          target.spatk=choice.spatk
          target.spdef=choice.spdef
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                    PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            target.stages[i]=choice.stages[i]
          end
          for i in 0...4
            target.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
            target.moves[i].pp=5
            target.moves[i].totalpp=5
          end
          target.effects[PBEffects::Disable]=0
          target.effects[PBEffects::DisableMove]=0
          @battle.pbDisplay(_INTL("{1} transformed into {2}!",target.pbThis,choice.pbThis(true)))
          PBDebug.log("[Pokémon transformed] #{pbThis} transformed into #{choice.pbThis(true)}")
        end
      end
      # Ferfatina
      if user.hasWorkingAbility(:FERFATINA) && @battle.pbRandom(10)<3 &&
        !user.isFainted?
        choice=target
        blacklist=[
           0xC9,    # Fly
           0xCA,    # Dig
           0xCB,    # Dive
           0xCC,    # Bounce
           0xCD,    # Shadow Force
           0xCE,    # Sky Drop
           0x14D,   # Phantom Force
           0x336    # Steel Fly
        ]
        if choice.effects[PBEffects::Transform] ||
           user.effects[PBEffects::Transform] ||
           user.effects[PBEffects::TransformBlock] ||
           choice.effects[PBEffects::TransformProtection] ||
           choice.effects[PBEffects::Illusion] ||
           choice.effects[PBEffects::Substitute]>0 ||
           choice.effects[PBEffects::SkyDrop] ||
           blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function) ||
           isConst?(choice.ability,PBAbilities,:KOULUNDIN) ||
           isConst?(choice.ability,PBAbilities,:ALONELY) ||
           isUltraBlue?(choice) ||
           @battle.field.effects[PBEffects::Cinament]>0 && !user.hasWorkingItem(:RODOFSPARROW)
          PBDebug.log("[Ability triggered] #{pbThis}'s Ferfatina couldn't transform")
        elsif choice.hasWorkingItem(:PASTELCARD) 
          if user.pbReduceStatWithCause(PBStats::DEFENSE,1,choice,PBItems.getName(choice.item))
            choice.effects[PBEffects::TransformProtection]=true
            choice.pbConsumeItem
          end
        elsif choice.hasWorkingItem(:PLACTENCARD) 
          if user.pbReduceStatWithCause(PBStats::SPDEF,1,choice,PBItems.getName(choice.item))
            user.effects[PBEffects::TransformBlock]=true
            choice.effects[PBEffects::TransformProtection]=true
            choice.pbConsumeItem
          end
        else
          PBDebug.log("[Ability triggered] #{user.pbThis}'s Ferfatina")
          @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),user,choice)
          user.effects[PBEffects::Transform]=true
          user.effects[PBEffects::Mimicry] = choice.effects[PBEffects::Mimicry]
          user.effects[PBEffects::Type1] = choice.effects[PBEffects::Type1]
          user.effects[PBEffects::Type2] = choice.effects[PBEffects::Type2]
          user.type1=choice.type1
          user.type2=choice.type2
          user.effects[PBEffects::Type3]=-1
          user.ability=choice.ability
          user.attack=choice.attack
          user.defense=choice.defense
          user.speed=choice.speed
          user.spatk=choice.spatk
          user.spdef=choice.spdef
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                    PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            user.stages[i]=choice.stages[i]
          end
          for i in 0...4
            user.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
            user.moves[i].pp=5
            user.moves[i].totalpp=5
          end
          user.effects[PBEffects::Disable]=0
          user.effects[PBEffects::DisableMove]=0
          @battle.pbDisplay(_INTL("{1} transformed into {2}!",user.pbThis,choice.pbThis(true)))
          PBDebug.log("[Pokémon transformed] #{user.pbThis} transformed into #{choice.pbThis(true)}")
        end
      end
        if target.hasWorkingAbility(:FLAMEBODY,true) && @battle.pbRandom(10)<3 &&
           user.pbCanBurn?(nil,false)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Flame Body")
          user.pbBurn(target,_INTL("{1}'s {2} burned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:FROZENBODY,true) && @battle.pbRandom(10)<3 &&
           user.pbCanFreeze?(nil,false)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Flame Body")
          user.pbFreeze(_INTL("{1}'s {2} made {3} frozen solid!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:MUMMY,true) && !user.isFainted?
          if !isConst?(user.ability,PBAbilities,:BATTLEBOND) &&
             !isConst?(user.ability,PBAbilities,:COMMANDER) &&
             !isConst?(user.ability,PBAbilities,:COMATOSE) &&
             !isConst?(user.ability,PBAbilities,:DISGUISE) &&
             !isConst?(user.ability,PBAbilities,:GULPMISSILE) &&
             !isConst?(user.ability,PBAbilities,:HUNGERSWITCH) &&
             !isConst?(user.ability,PBAbilities,:ICEFACE) &&
             !isConst?(user.ability,PBAbilities,:MULTITYPE) &&
             !isConst?(user.ability,PBAbilities,:MUMMY) &&
             !isConst?(user.ability,PBAbilities,:NEUTRALIZINGGAS) &&
             !isConst?(user.ability,PBAbilities,:POWERCONSTRUCT) &&
             !isConst?(user.ability,PBAbilities,:PROTOSYNTHESIS) &&
             !isConst?(user.ability,PBAbilities,:QUARKDRIVE) &&
             !isConst?(user.ability,PBAbilities,:RKSSYSTEM) &&
             !isConst?(user.ability,PBAbilities,:SCHOOLING) &&
             !isConst?(user.ability,PBAbilities,:STANCECHANGE) &&
             !isConst?(user.ability,PBAbilities,:ZEROTOHERO) &&
             !isConst?(user.ability,PBAbilities,:MAXTHIN) &&
             !isConst?(user.ability,PBAbilities,:KOULUNDIN) &&
             !isConst?(user.ability,PBAbilities,:CHIKOLINI) &&
             !isConst?(user.ability,PBAbilities,:ABILITOPIA) ||
             !isConst?(user.ability,PBAbilities,:MORFAT)
             PBDebug.log("[Ability triggered] #{target.pbThis}'s Mummy copied onto #{user.pbThis(true)}")
            user.ability=getConst(PBAbilities,:MUMMY) || 0
            @battle.pbDisplay(_INTL("{1} was mummified by {2}!",
               user.pbThis,target.pbThis(true)))
          end
        end
        # Lingering Aroma
        if target.hasWorkingAbility(:LINGERINGAROMA,true) && !user.isFainted?
          if !isConst?(user.ability,PBAbilities,:BATTLEBOND) &&
             !isConst?(user.ability,PBAbilities,:COMMANDER) &&
             !isConst?(user.ability,PBAbilities,:COMATOSE) &&
             !isConst?(user.ability,PBAbilities,:DISGUISE) &&
             !isConst?(user.ability,PBAbilities,:GULPMISSILE) &&
             !isConst?(user.ability,PBAbilities,:HUNGERSWITCH) &&
             !isConst?(user.ability,PBAbilities,:ICEFACE) &&
             !isConst?(user.ability,PBAbilities,:MULTITYPE) &&
             !isConst?(user.ability,PBAbilities,:LINGERINGAROMA) &&
             !isConst?(user.ability,PBAbilities,:NEUTRALIZINGGAS) &&
             !isConst?(user.ability,PBAbilities,:POWERCONSTRUCT) &&
             !isConst?(user.ability,PBAbilities,:PROTOSYNTHESIS) &&
             !isConst?(user.ability,PBAbilities,:QUARKDRIVE) &&
             !isConst?(user.ability,PBAbilities,:RKSSYSTEM) &&
             !isConst?(user.ability,PBAbilities,:SCHOOLING) &&
             !isConst?(user.ability,PBAbilities,:STANCECHANGE) &&
             !isConst?(user.ability,PBAbilities,:ZEROTOHERO) &&
             !isConst?(user.ability,PBAbilities,:MAXTHIN) &&
             !isConst?(user.ability,PBAbilities,:KOULUNDIN) &&
             !isConst?(user.ability,PBAbilities,:CHIKOLINI) &&
             !isConst?(user.ability,PBAbilities,:ABILITOPIA) ||
             !isConst?(user.ability,PBAbilities,:MORFAT)
             PBDebug.log("[Ability triggered] #{target.pbThis}'s Mummy copied onto #{user.pbThis(true)}")
            user.ability=getConst(PBAbilities,:LINGERINGAROMA) || 0
            @battle.pbDisplay(_INTL("{1} was lingered by {2}!",
               user.pbThis,target.pbThis(true)))
          end
        end

        
        if target.hasWorkingAbility(:POISONPOINT,true) && @battle.pbRandom(10)<3 &&
           user.pbCanPoison?(nil,false)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Poison Point")
          user.pbPoison(target,_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if (target.hasWorkingAbility(:ROUGHSKIN,true) ||
           target.hasWorkingAbility(:IRONBARBS,true)) && !user.isFainted?
          if !user.hasWorkingAbility(:MAGICGUARD) || !user.hasWorkingAbility(:SUPERCLEARBODY)
            PBDebug.log("[Ability triggered] #{target.pbThis}'s #{PBAbilities.getName(target.ability)}")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/8).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:STATIC,true) && @battle.pbRandom(10)<3 &&
           user.pbCanParalyze?(nil,false)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Static")
          user.pbParalyze(target,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:SOUFLAZ,true) && @battle.pbRandom(10)<3 &&
            target.status !=0 && user.status ==0 &&
            ((target.status==PBStatuses::PARALYSIS && user.pbCanParalyze?(target,false,self)) ||
             (target.status==PBStatuses::SLEEP && user.pbCanSleep?(target,false,self)) ||
             (target.status==PBStatuses::POISON && user.pbCanPoison?(target,false,self)) ||
             (target.status==PBStatuses::BURN && user.pbCanBurn?(target,false,self)) ||
             (target.status==PBStatuses::FROZEN && user.pbCanFreeze?(target,false,self)))
          case target.status
          when PBStatuses::PARALYSIS
            user.pbParalyze(target,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            user.pbAbilityCureCheck
        target.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.",target.pbThis))
          when PBStatuses::SLEEP
            user.pbSleep(_INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            user.pbAbilityCureCheck
        target.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} woke up.",target.pbThis))
          when PBStatuses::POISON
            user.pbPoison(target,_INTL("{1}'s {2} poisoned {3}!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)),target.statusCount!=0)
            user.pbAbilityCureCheck
        target.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",target.pbThis))
          when PBStatuses::BURN
            user.pbBurn(target,_INTL("{1}'s {2} burned {3}!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            user.pbAbilityCureCheck
        target.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s burn was healed.",target.pbThis))
          when PBStatuses::FROZEN
            user.pbFreeze(_INTL("{1}'s {2} made {3} frozen solid!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            user.pbAbilityCureCheck
        target.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} was thawed out.",target.pbThis))
          end
        end
        if user.pbOwnSide.effects[PBEffects::Electromania]>0 &&
           target.pbCanParalyze?(nil,false)
           target.pbParalyze(user)
        end
        if target.pbOwnSide.effects[PBEffects::Electromania]>0 &&
           user.pbCanParalyze?(nil,false)
           user.pbParalyze(target)
        end
        if user.pbOwnSide.effects[PBEffects::Fierymania]>0 &&
           target.pbCanBurn?(nil,false)
           target.pbBurn(user)
        end
        if target.pbOwnSide.effects[PBEffects::Fierymania]>0 &&
           user.pbCanBurn?(nil,false)
           user.pbBurn(target)
        end
        if user.pbOwnSide.effects[PBEffects::ToxicSwamp]>0 &&
           target.pbCanPoison?(nil,false)
           target.pbPoison(user)
        end
        if target.pbOwnSide.effects[PBEffects::ToxicSwamp]>0 &&
           user.pbCanPoison?(nil,false)
           user.pbPoison(target)
        end
        if target.hasWorkingAbility(:GOOEY,true) || target.hasWorkingAbility(:TANGLINGHAIR,true)
          if user.pbReduceStatWithCause(PBStats::SPEED,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Gooey")
          end
        end
        if target.hasWorkingAbility(:KOULUNDIN,true) || target.hasWorkingAbility(:MINIMALIST,true)
          if user.pbReduceStatWithCause(PBStats::ACCURACY,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Minimalist/Κουλούνδιν")
          end
        end
        if user.hasWorkingAbility(:POISONTOUCH,true) &&
           target.pbCanPoison?(nil,false) && @battle.pbRandom(10)<3
          PBDebug.log("[Ability triggered] #{user.pbThis}'s Poison Touch")
          target.pbPoison(user,_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
             PBAbilities.getName(user.ability),target.pbThis(true)))
        end
        if user.hasWorkingAbility(:ILLUSIVEBILITY) && @battle.pbRandom(10)<3 && !target.pbHasType?(:SHARPENER)
          if !target.isFainted? && target.pbCanAttract?(target,false)
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Illusive Bility")
            target.pbAttract(user,_INTL("{1}'s {2} made {3} fall in love!",user.pbThis,
               PBAbilities.getName(user.ability),target.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:PERISHBODY)
          user.effects[PBEffects::PerishSong]=4
          user.effects[PBEffects::PerishSongUser]=target.index
          target.effects[PBEffects::PerishSong]=4
          target.effects[PBEffects::PerishSongUser]=target.index
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Perish Body")
        end
      end
    end
    if damage>0
      if !target.damagestate.substitute
        target.increaseRageFist
        if target.hasWorkingAbility(:INNARDSOUT,true) && target.isFainted? && # changed added
           !user.isFainted?
          if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Innards Out")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(target.lastHPLost)
            @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
          end
        end
        if target.effects[PBEffects::GulpMissile] && # changed added
           !user.isFainted?
          target.effects[PBEffects::GulpMissile]=false
          if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Gulp Missile")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/4).floor)
            @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
          end
          if target.form==2 && user.pbCanParalyze?(nil,false)
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Gulp Missile (Paralyzing)")
            user.pbParalyze(target,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif target.form==1 && user.pbReduceStatWithCause(PBStats::DEFENSE,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Gulp Missile (Lowering defense)")
          end
          target.form=0
          target.pbUpdate(true)
          @battle.scene.pbChangePokemon(target,target.pokemon)
          @battle.pbDisplay(_INTL("{1} changed forme",target.pbThis))
          PBDebug.log("[Form changed] #{target.pbThis} changed forme")
        end
        if target.hasWorkingAbility(:CURSEDBODY,true) && @battle.pbRandom(10)<3
          if user.effects[PBEffects::Disable]<=0 && move.pp>0 && !user.isFainted?
            user.effects[PBEffects::Disable]=3
            user.effects[PBEffects::DisableMove]=move.id
            @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Cursed Body disabled #{user.pbThis(true)}")
          end
        end
        if target.hasWorkingAbility(:MAXTHIN,true) && @battle.pbRandom(10)<3
          if user.effects[PBEffects::Taunt]<=0 && user.effects[PBEffects::Khleri]<=0 && move.pp>0 && !user.isFainted?
            case @battle.pbRandom(2)
              when 0
              user.effects[PBEffects::Khleri]=3
              @battle.pbDisplay(_INTL("{1}'s {2} khlered {3}!",target.pbThis,
                 PBAbilities.getName(target.ability),user.pbThis(true)))
              PBDebug.log("[Ability triggered] #{target.pbThis}'s Maxthin khlered #{user.pbThis(true)}")
              when 1
              user.effects[PBEffects::Taunt]=3
              @battle.pbDisplay(_INTL("{1}'s {2} taunted {3}!",target.pbThis,
                 PBAbilities.getName(target.ability),user.pbThis(true)))
              PBDebug.log("[Ability triggered] #{target.pbThis}'s Maxthin taunted #{user.pbThis(true)}")
            end
          end
        end
        if target.hasWorkingAbility(:ANTIHEALER,true) && @battle.pbRandom(10)<3
          if user.effects[PBEffects::HealBlock]<=0 && move.pp>0 && !user.isFainted?
            user.effects[PBEffects::HealBlock]=5
            @battle.pbDisplay(_INTL("{1}'s {2} prevented {3} from healing!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Anti-Healer prevented #{user.pbThis(true)} from healing")
          end
        end
        if target.hasWorkingAbility(:HERBALILITY,true) && target.isFainted? &&
           !user.isFainted?
          @battle.pbAnimation(getConst(PBMoves,:HERBALSMOKE),target,user) # Plays animation even if it would be immune
           if (user.hasWorkingAbility(:MAGICGUARD) || 
              user.hasWorkingAbility(:SUPERCLEARBODY) ||
              user.hasWorkingAbility(:HERBALILITY) ||
              user.hasWorkingAbility(:MASKEDHERB) ||
              user.hasWorkingItem(:BOTANICSMOKE) ||
              user.pbHasType?(:HERB) || user.pbHasType?(:GLIMSE))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Herbalility couldn't work")
          else
           PBDebug.log("[Ability triggered] #{target.pbThis}'s Herbalility")
           pbSEPlay("protection")
           @battle.pbDisplay(_INTL("{1}'s {2} took {3} down with it!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            user.pbReduceHP(user.hp)
            user.pbFaint # no return
            @battle.pbJudgeCheckpoint(user)
          end
        end
        if target.hasWorkingItem(:BOTANICSMOKE,true) && target.isFainted? &&
           !user.isFainted?
          @battle.pbAnimation(getConst(PBMoves,:HERBALSMOKE),target,user) # Plays animation even if it would be immune
           if (user.hasWorkingAbility(:MAGICGUARD) || 
              user.hasWorkingAbility(:SUPERCLEARBODY) ||
              user.hasWorkingAbility(:HERBALILITY) ||
              user.hasWorkingAbility(:MASKEDHERB) ||
              user.hasWorkingItem(:BOTANICSMOKE) ||
              user.pbHasType?(:HERB) || user.pbHasType?(:GLIMSE))
            PBDebug.log("[Item triggered] #{target.pbThis}'s Botanic Smoke couldn't work")
          else
           PBDebug.log("[Item triggered] #{target.pbThis}'s Botanic Smoke")
           pbSEPlay("protection")
           @battle.pbDisplay(_INTL("{1}'s {2} took {3} down with it!",target.pbThis,
               PBItems.getName(target.item),user.pbThis(true)))
            target.pbConsumeItem(false,false)
            user.pbReduceHP(user.hp)
            user.pbFaint # no return
            @battle.pbJudgeCheckpoint(user)
          end
        end
        if target.hasWorkingAbility(:BAIKARI) && isConst?(movetype,PBTypes,:SUN)
          if target.pbIncreaseStatWithCause(PBStats::DEFENSE,2,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Baikari")
          end
        end
        # Thermal Exchange
        if target.hasWorkingAbility(:THERMALEXCHANGE) && isConst?(movetype,PBTypes,:FIRE)
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Termal Exchange")
          end
        end
        if target.hasWorkingAbility(:JUSTIFIED) && isConst?(movetype,PBTypes,:DARK)
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Justified")
          end
        end
        if target.hasWorkingAbility(:STEAMENGINE) && (isConst?(movetype,PBTypes,:FIRE) || isConst?(movetype,PBTypes,:WATER))
          if target.pbIncreaseStatWithCause(PBStats::SPEED,3,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Steam Engine")
          end
        end
        if target.hasWorkingAbility(:STAMINA) # changed added
          if target.pbIncreaseStatWithCause(PBStats::DEFENSE,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Stamina")
          end
        end
        # Sand Spit
        if target.hasWorkingAbility(:SANDSPIT) && (@battle.weather!=PBWeather::SANDSTORM || @battle.weatherduration!=-1)
          @battle.weather=PBWeather::SANDSTORM
          if $USENEWBATTLEMECHANICS
            @battle.weatherduration=5
            @battle.weatherduration=8 if hasWorkingItem(:SMOOTHROCK)
          else
            @battle.weatherduration=-1
          end
          @battle.pbCommonAnimation("Sandstorm",nil,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} whipped up a sandstorm!",target.pbThis,PBAbilities.getName(target.ability)))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Sand Spit made it sandstorm")
        end
        # Toxic Derbis
        if target.hasWorkingAbility(:TOXICDERBIS) && 
           move.pbIsPhysical?(movetype) &&
           target.pbOpposingSide.effects[PBEffects::ToxicSpikes]<2
          target.pbOpposingSide.effects[PBEffects::ToxicSpikes]+=1
          if !@battle.pbIsOpposing?(target.index)
            @battle.pbDisplay(_INTL("{1}'s {2} scattered poison spikes all around the opposing team's feet!",target.pbThis,PBAbilities.getName(target.ability)))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Toxic Derbis scattered poison spikes all around the opposing team's feet!")
          else
            @battle.pbDisplay(_INTL("{1}'s {2} scattered poison spikes all around your team's feet!",target.pbThis,PBAbilities.getName(target.ability)))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Toxic Derbis scattered poison spikes all around your team's feet!")
          end
        end
        # Wind Power & Electromorphosis
        if (target.hasWorkingAbility(:WINDPOWER) && move.isWindMove?) ||
           (target.hasWorkingAbility(:ELECTROMORPHOSIS) && isConst?(movetype,PBTypes,:ELECTRIC))
          target.effects[PBEffects::Charge]=2
          @battle.pbDisplay(_INTL("{1} began charging power!",target.pbThis))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s #{PBAbilities.getName(target.ability)}")
        end
        # Seed Sower
        if target.hasWorkingAbility(:SEEDSOWER) && @battle.field.effects[PBEffects::GrassyTerrain]<=0
          @battle.field.effects[PBEffects::ElectricTerrain]=0
          @battle.field.effects[PBEffects::MistyTerrain]=0
          @battle.field.effects[PBEffects::PsychicTerrain]=0
          @battle.field.effects[PBEffects::GrassyTerrain]=5
          @battle.field.effects[PBEffects::GrassyTerrain]=8 if self.hasWorkingItem(:TERRAINEXTENDER)
          @battle.field.effects[PBEffects::Cinament]=0
          @battle.field.effects[PBEffects::VolcanicTerrain]=0
          @battle.field.effects[PBEffects::LovelyTerrain]=0
          @battle.pbDisplay(_INTL("Grass grew to cover the battlefield!"))
          PBDebug.log("[#{pbThis}: Sand Sower made Grassy Terrain]")
          self.checkMimicryAll
        end
        if target.hasWorkingAbility(:COTTONDOWN)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Cotton Down")
          for i in [target.pbPartner,target.pbOpposing1,target.pbOpposing2]
            next if !i || i.isFainted?
            next if !i.pbCanReduceStatStage?(PBStats::SPEED,target,false,self)
            if i.pbReduceStatWithCause(PBStats::SPEED,1,target,PBAbilities.getName(target.ability))
            end
          end
        end
        if target.hasWorkingAbility(:RATTLED) &&
           (isConst?(movetype,PBTypes,:BUG) ||
            isConst?(movetype,PBTypes,:DARK) ||
            isConst?(movetype,PBTypes,:GHOST))
          if target.pbIncreaseStatWithCause(PBStats::SPEED,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Rattled")
          end
        end
        if target.hasWorkingAbility(:WEAKARMOR) && move.pbIsPhysical?(movetype)
          if target.pbReduceStatWithCause(PBStats::DEFENSE,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Weak Armor (lower Defense)")
          end
          if target.pbIncreaseStatWithCause(PBStats::SPEED,1,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Weak Armor (raise Speed)")
          end
        end
        if target.hasWorkingAbility(:WATERCOMPACTION) && isConst?(movetype,PBTypes,:WATER) # changed
          if target.pbIncreaseStatWithCause(PBStats::DEFENSE,2,target,PBAbilities.getName(target.ability))
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Water Compaction")
          end
        end
        if target.hasWorkingItem(:AIRBALLOON,true)
          PBDebug.log("[Item triggered] #{target.pbThis}'s Air Balloon popped")
          @battle.pbDisplay(_INTL("{1}'s Air Balloon popped!",target.pbThis))
          target.pbConsumeItem(true,false)
        elsif target.hasWorkingItem(:GENIEBALL) && rand(30)<6 &&
          (user.hasMoldBreaker || !target.hasWorkingAbility(:STICKYHOLD))
          PBDebug.log("[Item triggered] #{target.pbThis}'s Genie layed out from its Genie Ball")
          @battle.pbDisplay(_INTL("{1}'s Genie from its {2} layed out!",target.pbThis,PBItems.getName(target.item)))
          target.pbConsumeItem(false,false)
        elsif target.hasWorkingItem(:ABSORBBULB) && isConst?(movetype,PBTypes,:WATER)
          if target.pbIncreaseStatWithCause(PBStats::SPATK,1,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:THOUSANDSBULB) && isConst?(movetype,PBTypes,:GROUND)
          if target.pbIncreaseStatWithCause(PBStats::SPATK,1,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:LUMINOUSMOSS) && isConst?(movetype,PBTypes,:WATER)
          if target.pbIncreaseStatWithCause(PBStats::SPDEF,1,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:CELLBATTERY) && isConst?(movetype,PBTypes,:ELECTRIC)
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,1,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:SNOWBALL) && isConst?(movetype,PBTypes,:ICE)
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,1,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:WEAKNESSPOLICY) && target.damagestate.typemod>8
          showanim='mix'
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,2,target,PBItems.getName(target.item),showanim)
            PBDebug.log("[Item triggered] #{target.pbThis}'s Weakness Policy (Attack)")
            showanim=false
          end
          if target.pbIncreaseStatWithCause(PBStats::SPATK,2,target,PBItems.getName(target.item),showanim)
            PBDebug.log("[Item triggered] #{target.pbThis}'s Weakness Policy (Special Attack)")
            showanim=false
          end
          target.pbConsumeItem if !showanim
        elsif target.hasWorkingItem(:PHOENIXPOLICY) && isConst?(movetype,PBTypes,:CHLOROPHYLL)
          if target.pbIncreaseStatWithCause(PBStats::EVASION,2,target,PBItems.getName(target.item))
            PBDebug.log("[Item triggered] #{target.pbThis}'s Phoenix Policy")
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:ULTRASONICPOLICY) && 
             (isConst?(movetype,PBTypes,:ELECTRIC) || isConst?(movetype,PBTypes,:BOLT))
          showanim='mix'
          if target.pbIncreaseStatWithCause(PBStats::DEFENSE,2,target,PBItems.getName(target.item),showanim)
            PBDebug.log("[Item triggered] #{target.pbThis}'s Ultrasonic Policy (Defense)")
            showanim=false
          end
          if target.pbIncreaseStatWithCause(PBStats::ACCURACY,2,target,PBItems.getName(target.item),showanim)
            PBDebug.log("[Item triggered] #{target.pbThis}'s Ultrasonic Policy (Accuracy)")
            showanim=false
          end
          target.pbConsumeItem if !showanim
        elsif user.hasWorkingItem(:THROATSPRAY) && move.isSoundBased?
          showanim=true
          if user.pbIncreaseStatWithCause(PBStats::ATTACK,2,target,PBItems.getName(target.item),showanim)
            PBDebug.log("[Item triggered] #{user.pbThis}'s Throat Spray")
            showanim=false
          end
          user.pbConsumeItem if !showanim
        elsif target.hasWorkingItem(:ENIGMABERRY) && (target.damagestate.typemod>8 || target.effects[PBEffects::CudChew])
          target.pbActivateBerryEffect
        elsif (target.hasWorkingItem(:JABOCABERRY) && move.pbIsPhysical?(movetype)) ||
              (target.hasWorkingItem(:ROWAPBERRY) && move.pbIsSpecial?(movetype))
          if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY)) && !user.isFainted?
            PBDebug.log("[Item triggered] #{target.pbThis}'s #{PBItems.getName(target.item)}")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/8).floor)
            @battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
               PBItems.getName(target.item),user.pbThis(true)))
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:KEEBERRY) && (move.pbIsPhysical?(movetype) || target.effects[PBEffects::CudChew])
          target.pbActivateBerryEffect
        elsif target.hasWorkingItem(:MARANGABERRY) && (move.pbIsSpecial?(movetype) || target.effects[PBEffects::CudChew])
          target.pbActivateBerryEffect
        end
        # changed added
        # in the section for damage > 0, NOT contact, and NOT hitting a sub
        targetchoice=@battle.choices[target.index][2] # 2 refers to the move
        if targetchoice && !targetchoice.is_a?(Numeric) && targetchoice.function==0x193 && # Shell Trap
           move.pbIsPhysical?(movetype)
          # targetchoice==0 means the target hasn't picked a move this round (switched, used a poke ball etc.)
          target.effects[PBEffects::ShellTrap]=true
          # adds shell trap effect to opponent if the opponent's move choice is shell trap
        end
        # changed end
      end
      if target.hasWorkingAbility(:ANGERPOINT)
        if target.damagestate.critical && !target.damagestate.substitute &&
           target.pbCanIncreaseStatStage?(PBStats::ATTACK,target)
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Point")
          target.stages[PBStats::ATTACK]=6
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
             target.pbThis,PBAbilities.getName(target.ability),PBStats.getName(PBStats::ATTACK)))
        end
      end
      if target.hasWorkingAbility(:DOOMYSLUSH)
        if (target.damagestate.critical || isConst?(movetype,PBTypes,:DOOM)) && 
          !target.damagestate.substitute &&
          (target.pbCanIncreaseStatStage?(PBStats::ATTACK,target) ||
           target.pbCanIncreaseStatStage?(PBStats::DEFENSE,target) ||
           target.pbCanIncreaseStatStage?(PBStats::SPATK,target) ||
           target.pbCanIncreaseStatStage?(PBStats::SPDEF,target) ||
           target.pbCanIncreaseStatStage?(PBStats::SPEED,target) ||
           target.pbCanIncreaseStatStage?(PBStats::ACCURACY,target) ||
           target.pbCanIncreaseStatStage?(PBStats::EVASION,target))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Doomy Slush")
          target.stages[PBStats::ATTACK]=6
          target.stages[PBStats::DEFENSE]=6
          target.stages[PBStats::SPATK]=6
          target.stages[PBStats::SPDEF]=6
          target.stages[PBStats::SPEED]=6
          target.stages[PBStats::ACCURACY]=6
          target.stages[PBStats::EVASION]=6
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} maxed its stats!",
             target.pbThis,PBAbilities.getName(target.ability)))
        end
      end
    end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
  end

  def pbEffectsAfterHit(user,target,thismove,turneffects,danced=false)
    return if turneffects[PBEffects::TotalDamage]==0
    if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
      # Target's held items:
      # Red Card
      if target.hasWorkingItem(:REDCARD) && @battle.pbCanSwitch?(user.index,-1,false)
        user.effects[PBEffects::Roar]=true
        @battle.pbDisplay(_INTL("{1} held up its {2} against the {3}!",
           target.pbThis,PBItems.getName(target.item),user.pbThis(true)))
        target.pbConsumeItem
      # Eject Button
      elsif target.hasWorkingItem(:EJECTBUTTON) && @battle.pbCanChooseNonActive?(target.index)
        target.effects[PBEffects::Uturn]=true
        @battle.pbDisplay(_INTL("{1} is switched out with the {2}!",
           target.pbThis,PBItems.getName(target.item)))
        target.pbConsumeItem
      end
      # User's held items:
      # Shell Bell
      if user.hasWorkingItem(:SHELLBELL) && user.effects[PBEffects::HealBlock]==0
        PBDebug.log("[Item triggered] #{user.pbThis}'s Shell Bell (total damage=#{turneffects[PBEffects::TotalDamage]})")
        hpgain=user.pbRecoverHP((turneffects[PBEffects::TotalDamage]/8).floor,true)
        if hpgain>0
          @battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
             user.pbThis,PBItems.getName(user.item)))
        end
      end
      # Life Orb
      if user.effects[PBEffects::LifeOrb] && !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY) )
        PBDebug.log("[Item triggered] #{user.pbThis}'s Life Orb (recoil)")
        hploss=user.pbReduceHP((user.totalhp/10).floor,true)
        if hploss>0
          @battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
        end
      end
      user.pbFaint if user.isFainted? # no return
      if thismove
        pbDancerMoveCheck(thismove.id) if !danced      
      end
      # Color Change
      movetype=thismove.pbType(thismove.type,user,target)
      if target.hasWorkingAbility(:COLORCHANGE) &&
         !PBTypes.isPseudoType?(movetype) && !target.pbHasType?(movetype)
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Color Change made it #{PBTypes.getName(movetype)}-type")
        target.type1=movetype
        target.type2=movetype
        target.effects[PBEffects::Type3]=-1
        @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
           PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
      end
    end
    # Moxie
    if user.hasWorkingAbility(:MOXIE) && target.isFainted?
      if user.pbIncreaseStatWithCause(PBStats::ATTACK,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Moxie")
      end
    end
    # Chilling Neigh
    if (user.hasWorkingAbility(:CHILLINGNEIGH) || user.hasWorkingAbility(:ASONE1)) && target.isFainted?
      if user.pbIncreaseStatWithCause(PBStats::ATTACK,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Chilling Neigh")
      end
    end
    # Grim Neigh
    if (user.hasWorkingAbility(:GRIMNEIGH) || user.hasWorkingAbility(:ASONE2)) && target.isFainted?
      if user.pbIncreaseStatWithCause(PBStats::SPATK,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Grim Neigh")
      end
    end
    # Soul Heart
    if user.hasWorkingAbility(:SOULHEART) && target.isFainted?
      if user.pbIncreaseStatWithCause(PBStats::SPATK,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Soul Heart")
      end
    end
    # Allergy
    if user.hasWorkingAbility(:ALLERGY) && target.isFainted?
      if user.pbIncreaseStatWithCause(PBStats::SPDEF,3,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Allergy")
      end
    end
    # Beast Boost
    if user.hasWorkingAbility(:BEASTBOOST) && target.isFainted?
      if pbIncreaseStatWithCause(user.profstat,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{pbThis}'s Beast Boost (raising #{PBStats.getName(user.profstat)})")
      end
    end
    # Photon Force
    if user.hasWorkingAbility(:PHOTONFORCE) && target.isFainted? && user.pbPartner
      if user.pbPartner.pbIncreaseStatWithCause(user.pbPartner.profstat,1,user,PBAbilities.getName(user.ability))
        PBDebug.log("[Ability triggered] #{pbThis}'s Photon Force (raising #{PBStats.getName(user.pbPartner.profstat)})")
      end
    end
    # Berserk
    if target.hasWorkingAbility(:BERSERK) && target.hp+turneffects[PBEffects::TotalDamage]>target.totalhp/2 && # changed added
        target.hp<target.totalhp/2 && !target.isFainted?
      if target.pbIncreaseStatWithCause(PBStats::SPATK,1,target,PBAbilities.getName(target.ability))
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Berserk")
      end
    end

    # Anger Shell
    if target.hasWorkingAbility(:ANGERSHELL) && target.hp+turneffects[PBEffects::TotalDamage]>target.totalhp/2 && # changed added
        target.hp<target.totalhp/2 && !target.isFainted?
      showanim='mix' # Was true
      if target.pbCanReduceStatStage?(PBStats::DEFENSE,target,false,self)
        target.pbReduceStat(PBStats::DEFENSE,1,target,false,self,showanim)
        showanim=false
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Shell (Lowering Defense)")
      end
      if target.pbCanReduceStatStage?(PBStats::SPDEF,target,false,self)
        target.pbReduceStat(PBStats::SPDEF,1,target,false,self,showanim)
        showanim=false
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Shell (Lowering Special Defense)")
      end
      showanim='mix' # Was true
      if target.pbCanIncreaseStatStage?(PBStats::ATTACK,target,false,self)
        target.pbIncreaseStat(PBStats::ATTACK,2,target,false,self,showanim)
        showanim=false
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Shell (Raising Attack)")
      end
      if target.pbCanIncreaseStatStage?(PBStats::SPATK,target,false,self)
        target.pbIncreaseStat(PBStats::SPATK,2,target,false,self,showanim)
        showanim=false
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Shell (Raising Special Attack)")
      end
      if target.pbCanIncreaseStatStage?(PBStats::SPEED,target,false,self)
        target.pbIncreaseStat(PBStats::SPEED,2,target,false,self,showanim)
        showanim=false
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Anger Shell (Raising Speed)")
      end
    end
    # Magician
    if user.hasWorkingAbility(:MAGICIAN)
      if target.item>0 && user.item==0 &&
         user.effects[PBEffects::Substitute]==0 &&
         target.effects[PBEffects::Substitute]==0 &&
         !target.hasWorkingAbility(:STICKYHOLD) &&
         !@battle.pbIsUnlosableItem(target,target.item) &&
         !@battle.pbIsUnlosableItem(user,target.item) &&
         (@battle.opponent || !@battle.pbIsOpposing?(user.index))
        user.item=target.item
        target.item=0
        if target.pokemon.corrosiveGas
          target.pokemon.corrosiveGas=false
          user.pokemon.corrosiveGas=true
        end
        target.effects[PBEffects::Unburden]=true
        if !@battle.opponent &&   # In a wild battle
           user.pokemon.itemInitial==0 &&
           target.pokemon.itemInitial==user.item
          user.pokemon.itemInitial=user.item
          target.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           target.pbThis(true),PBItems.getName(user.item),PBAbilities.getName(user.ability)))
        PBDebug.log("[Ability triggered] #{user.pbThis}'s Magician stole #{target.pbThis(true)}'s #{PBItems.getName(user.item)}")
      end
    end
    # Pickpocket
    if target.hasWorkingAbility(:PICKPOCKET)
      if target.item==0 && user.item>0 && 
         user.effects[PBEffects::Substitute]==0 &&
         target.effects[PBEffects::Substitute]==0 &&
         !user.hasWorkingAbility(:STICKYHOLD) &&
         !@battle.pbIsUnlosableItem(user,user.item) &&
         !@battle.pbIsUnlosableItem(target,user.item) &&
         (@battle.opponent || !@battle.pbIsOpposing?(target.index))
        target.item=user.item
        user.item=0
        if user.pokemon.corrosiveGas
          user.pokemon.corrosiveGas=false
          target.pokemon.corrosiveGas=true
        end
        user.effects[PBEffects::Unburden]=true
        if !@battle.opponent &&   # In a wild battle
           target.pokemon.itemInitial==0 &&
           user.pokemon.itemInitial==target.item
          target.pokemon.itemInitial=target.item
          user.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
           user.pbThis(true),PBItems.getName(target.item)))
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Pickpocket stole #{user.pbThis(true)}'s #{PBItems.getName(target.item)}")
      end
    end
  end

  def pbAbilityCureCheck
    return if self.isFainted?
    case self.status
    when PBStatuses::SLEEP
      if self.hasWorkingAbility(:VITALSPIRIT) || self.hasWorkingAbility(:INSOMNIA) ||
         self.hasWorkingAbility(:PURIFYINGSALT)
        PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} woke it up!",pbThis,PBAbilities.getName(@ability)))
      end
    when PBStatuses::POISON
      if self.hasWorkingAbility(:IMMUNITY) || self.hasWorkingAbility(:PURIFYINGSALT)
        PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",pbThis,PBAbilities.getName(@ability)))
      end
    when PBStatuses::BURN
      if self.hasWorkingAbility(:WATERVEIL) || self.hasWorkingAbility(:WATERBUBBLE) ||
         self.hasWorkingAbility(:THERMALEXCHANGE) || self.hasWorkingAbility(:PURIFYINGSALT)
        PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",pbThis,PBAbilities.getName(@ability)))
      end
    when PBStatuses::PARALYSIS
      if self.hasWorkingAbility(:LIMBER) || self.hasWorkingAbility(:PURIFYINGSALT)
        PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",pbThis,PBAbilities.getName(@ability)))
      end
    when PBStatuses::FROZEN
      if self.hasWorkingAbility(:MAGMAARMOR) || self.hasWorkingAbility(:PURIFYINGSALT)
        PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",pbThis,PBAbilities.getName(@ability)))
      end
    end
    if @effects[PBEffects::Confusion]>0 && self.hasWorkingAbility(:OWNTEMPO)
      PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)} (attract)")
      pbCureConfusion(false)
      @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,PBAbilities.getName(@ability)))
    end
    if @effects[PBEffects::Attract]>=0 && self.hasWorkingAbility(:OBLIVIOUS)
      PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)}")
      pbCureAttract
      @battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",pbThis,PBAbilities.getName(@ability)))
    end
    if $USENEWBATTLEMECHANICS && @effects[PBEffects::Taunt]>0 && self.hasWorkingAbility(:OBLIVIOUS)
      PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)} (taunt)")
      @effects[PBEffects::Taunt]=0
      @battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",pbThis,PBAbilities.getName(@ability)))
    end
    if $USENEWBATTLEMECHANICS && @effects[PBEffects::Khleri]>0 && self.hasWorkingAbility(:OBLIVIOUS)
      PBDebug.log("[Ability triggered] #{pbThis}'s #{PBAbilities.getName(@ability)} (khleri)")
      @effects[PBEffects::Khleri]=0
      @battle.pbDisplay(_INTL("{1}'s {2} made its khleri wear off!",pbThis,PBAbilities.getName(@ability)))
    end
  end

################################################################################
# Held item effects
################################################################################
  def pbConsumeItem(recycle=true,pickup=true)
    itemname=PBItems.getName(self.item)
    @pokemon.itemRecycle=self.item if recycle
    @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
    if pickup
      @effects[PBEffects::PickupItem]=self.item
      @effects[PBEffects::PickupUse]=@battle.nextPickupUse
    end
    self.item=0
    self.effects[PBEffects::Unburden]=true
    # Symbiosis
    if pbPartner && pbPartner.hasWorkingAbility(:SYMBIOSIS) && recycle
      if pbPartner.item>0 &&
         !@battle.pbIsUnlosableItem(pbPartner,pbPartner.item) &&
         !@battle.pbIsUnlosableItem(self,pbPartner.item) && 
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
           pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
           PBItems.getName(pbPartner.item),pbThis(true)))
        self.item=pbPartner.item
        pbPartner.item=0
        if pbPartner.pokemon.corrosiveGas
          pbPartner.pokemon.corrosiveGas=false
          @pokemon.corrosiveGas=true
        end
        pbPartner.effects[PBEffects::Unburden]=true
        pbBerryCureCheck
      end
    end
  end

  def pbConfusionBerry(flavor,message1,message2)
    if hasWorkingAbility(:RIPEN)
      amt=self.pbRecoverHP((self.totalhp/3).floor,true)
    else
      amt=self.pbRecoverHP((self.totalhp/6).floor,true)
    end
    if amt>0
      @battle.pbDisplay(message1)
      if (self.nature%5)==flavor && (self.nature/5).floor!=(self.nature%5)
        @battle.pbDisplay(message2)
        pbConfuseSelf
      end
      return true
    end
    return false
  end

  def pbStatIncreasingBerry(stat,berryname)
    if hasWorkingAbility(:RIPEN)
      return pbIncreaseStatWithCause(stat,2,self,berryname)
    else
      return pbIncreaseStatWithCause(stat,1,self,berryname)
    end
  end

  def pbActivateBerryEffect(berry=0,consume=true)
    berry=self.item if berry==0
    berryname=(berry==0) ? "" : PBItems.getName(berry)
    PBDebug.log("[Item triggered] #{pbThis}'s #{berryname}")
    consumed=false
    if @effects[PBEffects::CudChew]
      @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(ability)))
    end
    if isConst?(berry,PBItems,:ORANBERRY)
      if hasWorkingAbility(:RIPEN)
        amt=self.pbRecoverHP(20,true)
      else
        amt=self.pbRecoverHP(10,true)
      end
      if amt>0
        @battle.pbDisplay(_INTL("{1} restored its health using its {2}!",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:SITRUSBERRY) ||
          isConst?(berry,PBItems,:ENIGMABERRY)
      if hasWorkingAbility(:RIPEN)
        amt=self.pbRecoverHP((self.totalhp/2).floor,true)
      else
        amt=self.pbRecoverHP((self.totalhp/4).floor,true)
      end
      if amt>0
        @battle.pbDisplay(_INTL("{1} restored its health using its {2}!",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:CHESTOBERRY)
      if self.status==PBStatuses::SLEEP
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem.",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:PECHABERRY)
      if self.status==PBStatuses::POISON
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning.",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:RAWSTBERRY)
      if self.status==PBStatuses::BURN
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} healed its burn.",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:CHERIBERRY)
      if self.status==PBStatuses::PARALYSIS
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis.",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:ASPEARBERRY)
      if self.status==PBStatuses::FROZEN
        pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s {2} thawed it out.",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:LEPPABERRY)
      found=[]
      for i in 0...@pokemon.moves.length
        if @pokemon.moves[i].id!=0
          if (consume && @pokemon.moves[i].pp==0) ||
             (!consume && @pokemon.moves[i].pp<@pokemon.moves[i].totalpp)
            found.push(i)
          end
        end
      end
      if found.length>0
        choice=(consume) ? found[0] : found[@battle.pbRandom(found.length)]
        pokemove=@pokemon.moves[choice]
        if hasWorkingAbility(:RIPEN)
          pokemove.pp+=20
        else
          pokemove.pp+=10
        end
        pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp 
        self.moves[choice].pp=pokemove.pp
        movename=PBMoves.getName(pokemove.id)
        @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s PP!",pbThis,berryname,movename)) 
        consumed=true
      end
    elsif isConst?(berry,PBItems,:PERSIMBERRY)
      if @effects[PBEffects::Confusion]>0
        pbCureConfusion(false)
        @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:LUMBERRY)
      if self.status>0 || @effects[PBEffects::Confusion]>0
        st=self.status; conf=(@effects[PBEffects::Confusion]>0)
        pbCureStatus(false)
        pbCureConfusion(false)
        case st
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1}'s {2} woke it up!",pbThis,berryname))
        when PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",pbThis,berryname))
        when PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",pbThis,berryname))
        when PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",pbThis,berryname))
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",pbThis,berryname))
        end
        if conf
          @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,berryname))
        end
        consumed=true
      end
    elsif isConst?(berry,PBItems,:FIGYBERRY)
      consumed=pbConfusionBerry(0,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too spicy!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:WIKIBERRY)
      consumed=pbConfusionBerry(3,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too dry!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:MAGOBERRY)
      consumed=pbConfusionBerry(2,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too sweet!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:AGUAVBERRY)
      consumed=pbConfusionBerry(4,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too bitter!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:IAPAPABERRY)
      consumed=pbConfusionBerry(1,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too sour!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:LIECHIBERRY)
      consumed=pbStatIncreasingBerry(PBStats::ATTACK,berryname)
    elsif isConst?(berry,PBItems,:GANLONBERRY) ||
          isConst?(berry,PBItems,:KEEBERRY)
      consumed=pbStatIncreasingBerry(PBStats::DEFENSE,berryname)
    elsif isConst?(berry,PBItems,:SALACBERRY)
      consumed=pbStatIncreasingBerry(PBStats::SPEED,berryname)
    elsif isConst?(berry,PBItems,:PETAYABERRY)
      consumed=pbStatIncreasingBerry(PBStats::SPATK,berryname)
    elsif isConst?(berry,PBItems,:APICOTBERRY) ||
          isConst?(berry,PBItems,:MARANGABERRY)
      consumed=pbStatIncreasingBerry(PBStats::SPDEF,berryname)
    elsif isConst?(berry,PBItems,:LANSATBERRY)
      if @effects[PBEffects::FocusEnergy]<2
        @effects[PBEffects::FocusEnergy]=2
        @battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:MICLEBERRY)
      if !@effects[PBEffects::MicleBerry]
        @effects[PBEffects::MicleBerry]=true
        @battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
           pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:STARFBERRY)
      stats=[]
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
        stats.push(i) if pbCanIncreaseStatStage?(i,self)
      end
      if stats.length>0
        stat=stats[@battle.pbRandom(stats.length)]
        if hasWorkingAbility(:RIPEN)
          consumed=pbIncreaseStatWithCause(stat,4,self,berryname)
        else
          consumed=pbIncreaseStatWithCause(stat,2,self,berryname)
        end
      end
    end
#      
    if consumed
      # Solbeyu
      if hasWorkingAbility(:SOLBEYU)
        damager=pbOppositeOpposing
        dodgesol=false
        if $USENEWBATTLEMECHANICS  # Gen 6 version goes here
          damager=(rand(100)<50) ? pbOpposing1 : pbOpposing2
          if pbOpposing1.hasWorkingAbility(:SOLBEYU)
            damager=pbOpposing2  # If 1st opposing has Solbeyu, use the 2nd
            dodgesol=true if !@battle.doublebattle
          elsif pbOpposing2.hasWorkingAbility(:SOLBEYU) && @battle.doublebattle
            damager=pbOpposing1 # If 2nd opposing has Solbeyu, use the 1st
            dodgesol=true if !@battle.doublebattle
          end
          if pbOpposing1.hasWorkingAbility(:SOLBEYU) && 
                pbOpposing2.hasWorkingAbility(:SOLBEYU) &&
                @battle.doublebattle
            dodgesol=true
          end
        end
        if !(dodgesol || damager.hasWorkingAbility(:MAGICGUARD) ||
            damager.hasWorkingAbility(:SUPERCLEARBODY))
        @battle.scene.pbDamageAnimation(damager,0)
        amt=damager.pbReduceHP((damager.totalhp/3).floor)
          if amt>0
            @battle.pbDisplay(_INTL("{1} was hurt by {2}'s Solbeyu.",
               damager.pbThis,pbThis))
          end
        end
      end
      # Star Punny
      if (pbOpposing1.hasWorkingAbility(:STARPUNNY) ||
          pbOpposing2.hasWorkingAbility(:STARPUNNY)) &&
          !(hasWorkingAbility(:STARPUNNY) || hasWorkingAbility(:MAGICGUARD) ||
            hasWorkingAbility(:SUPERCLEARBODY))
        @battle.scene.pbDamageAnimation(self,0)
        amt=self.pbReduceHP((@totalhp/3).floor)
        if amt>0
          @battle.pbDisplay(_INTL("{1} was hurt by the opposing Star Punny.",
             pbThis))
        end
      end
      # Cheek Pouch
      if hasWorkingAbility(:CHEEKPOUCH)
        amt=self.pbRecoverHP((@totalhp/3).floor,true)
        if amt>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its health!",
             pbThis,PBAbilities.getName(ability)))
        end
      end
      @effects[PBEffects::CudChew]=!@effects[PBEffects::CudChew] if hasWorkingAbility(:CUDCHEW)
      pbConsumeItem if consume && !@effects[PBEffects::CudChew]
      self.pokemon.belch=true if self.pokemon
    end
  end

  def pbBerryCureCheck(hpcure=false)
    return if self.isFainted?
    unnerver=(pbOpposing1.hasWorkingAbility(:UNNERVE) ||
              pbOpposing2.hasWorkingAbility(:UNNERVE) ||
              pbOpposing1.hasWorkingAbility(:ASONE1) ||
              pbOpposing2.hasWorkingAbility(:ASONE1) ||
              pbOpposing1.hasWorkingAbility(:ASONE2) ||
              pbOpposing2.hasWorkingAbility(:ASONE2))
    itemname=(self.item==0) ? "" : PBItems.getName(self.item)
    if hpcure
      if self.hasWorkingItem(:BERRYJUICE) && self.hp<=(self.totalhp/2).floor
        amt=self.pbRecoverHP(20,true)
        if amt>0
          @battle.pbCommonAnimation("UseItem",self,nil)
          @battle.pbDisplay(_INTL("{1} restored its health using its {2}!",pbThis,itemname))
          pbConsumeItem
          return
        end
      end
    end
    if !unnerver
      if hpcure 
        if self.hp<=(self.totalhp/2).floor || self.effects[PBEffects::CudChew]
          if self.hasWorkingItem(:ORANBERRY) ||
             self.hasWorkingItem(:SITRUSBERRY)
            pbActivateBerryEffect
            return
          end
          if self.hasWorkingItem(:FIGYBERRY) ||
             self.hasWorkingItem(:WIKIBERRY) ||
             self.hasWorkingItem(:MAGOBERRY) ||
             self.hasWorkingItem(:AGUAVBERRY) ||
             self.hasWorkingItem(:IAPAPABERRY)
            pbActivateBerryEffect
            return
          end
        end
      end
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
           self.hp<=(self.totalhp/4).floor || self.effects[PBEffects::CudChew]
          if self.hasWorkingItem(:LIECHIBERRY) ||
             self.hasWorkingItem(:GANLONBERRY) ||
             self.hasWorkingItem(:SALACBERRY) ||
             self.hasWorkingItem(:PETAYABERRY) ||
             self.hasWorkingItem(:APICOTBERRY)
            pbActivateBerryEffect
            return
          end
          if self.hasWorkingItem(:LANSATBERRY) ||
             self.hasWorkingItem(:STARFBERRY)
            pbActivateBerryEffect
            return
          end
          if self.hasWorkingItem(:MICLEBERRY)
            pbActivateBerryEffect
            return
          end
        end
        if self.hasWorkingItem(:LEPPABERRY)
          pbActivateBerryEffect
          return
        end
      if self.hasWorkingItem(:CHESTOBERRY) ||
         self.hasWorkingItem(:PECHABERRY) ||
         self.hasWorkingItem(:RAWSTBERRY) ||
         self.hasWorkingItem(:CHERIBERRY) ||
         self.hasWorkingItem(:ASPEARBERRY) ||
         self.hasWorkingItem(:PERSIMBERRY) ||
         self.hasWorkingItem(:LUMBERRY)
        pbActivateBerryEffect
        return
      end
    end
    if self.hasWorkingItem(:WHITEHERB)
      reducedstats=false
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::ACCURACY,PBStats::EVASION]
        if @stages[i]<0
          @stages[i]=0; reducedstats=true
        end
      end
      if reducedstats
        PBDebug.log("[Item triggered] #{pbThis}'s #{itemname}")
        @battle.pbCommonAnimation("UseItem",self,nil)
        @battle.pbDisplay(_INTL("{1} restored its status using its {2}!",pbThis,itemname))
        pbConsumeItem
        return
      end
    end
    if self.hasWorkingItem(:MENTALHERB) &&
       (@effects[PBEffects::Attract]>=0 ||
       @effects[PBEffects::Khleri]>0 ||
       @effects[PBEffects::Taunt]>0 ||
       @effects[PBEffects::Encore]>0 ||
       @effects[PBEffects::Torment] ||
       @effects[PBEffects::Disable]>0 ||
       @effects[PBEffects::HealBlock]>0)
      PBDebug.log("[Item triggered] #{pbThis}'s #{itemname}")
      @battle.pbCommonAnimation("UseItem",self,nil)
      @battle.pbDisplay(_INTL("{1} cured its infatuation status using its {2}.",pbThis,itemname)) if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1}'s khleri wore off!",pbThis)) if @effects[PBEffects::Khleri]>0
      @battle.pbDisplay(_INTL("{1}'s taunt wore off!",pbThis)) if @effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("{1}'s encore ended!",pbThis)) if @effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("{1}'s torment wore off!",pbThis)) if @effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("{1} is no longer disabled!",pbThis)) if @effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",pbThis)) if @effects[PBEffects::HealBlock]>0
      self.pbCureAttract
      @effects[PBEffects::Khleri]=0
      @effects[PBEffects::Taunt]=0
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreMove]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::Torment]=false
      @effects[PBEffects::Disable]=0
      @effects[PBEffects::HealBlock]=0
      pbConsumeItem
      return
    end
    if hpcure && self.hasWorkingItem(:LEFTOVERS) && self.hp!=self.totalhp &&
       @effects[PBEffects::HealBlock]==0
      PBDebug.log("[Item triggered] #{pbThis}'s Leftovers")
      @battle.pbCommonAnimation("UseItem",self,nil)
      pbRecoverHP((self.totalhp/16).floor,true)
      @battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",pbThis,itemname))
    end
    if hpcure && self.hasWorkingItem(:BLACKSLUDGE)
      if pbHasType?(:POISON) || pbHasType?(:GAS)
        if self.hp!=self.totalhp &&
           (!$USENEWBATTLEMECHANICS || @effects[PBEffects::HealBlock]==0)
          PBDebug.log("[Item triggered] #{pbThis}'s Black Sludge (heal)")
          @battle.pbCommonAnimation("UseItem",self,nil)
          pbRecoverHP((self.totalhp/16).floor,true)
          @battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",pbThis,itemname))
        end
      elsif !(self.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
        PBDebug.log("[Item triggered] #{pbThis}'s Black Sludge (damage)")
        @battle.pbCommonAnimation("UseItem",self,nil)
        pbReduceHP((self.totalhp/8).floor,true)
        @battle.pbDisplay(_INTL("{1} was hurt by its {2}!",pbThis,itemname))
      end
      pbFaint if self.isFainted?
    end
  end

################################################################################
# Move user and targets
################################################################################
  def pbFindUser(choice,targets)
    move=choice[2]
    target=choice[3]
    user=self   # Normally, the user is self
    # Targets in normal cases
    case pbTarget(move)
    when PBTargets::SingleNonUser
      if target>=0
        targetBattler=@battle.battlers[target]
        if !pbIsOpposing?(targetBattler.index)
          if !pbAddTarget(targets,targetBattler)
            pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
          end
        else
          pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::SingleOpposing
      if target>=0
        targetBattler=@battle.battlers[target]
        if !pbIsOpposing?(targetBattler.index)
          if !pbAddTarget(targets,targetBattler)
            pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
          end
        else
          pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::OppositeOpposing
      pbAddTarget(targets,pbOppositeOpposing) if !pbAddTarget(targets,pbOppositeOpposing2)
    when PBTargets::RandomOpposing
      pbRandomTarget(targets)
    when PBTargets::AllOpposing
      # Just pbOpposing1 because partner is determined late
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
    when PBTargets::AllNonUsers
      for i in 0...4 # not ordered by priority
        pbAddTarget(targets,@battle.battlers[i]) if i!=@index
      end
    when PBTargets::UserOrPartner
      if target>=0 # Pre-chosen target
        targetBattler=@battle.battlers[target]
        pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
      else
        pbAddTarget(targets,self)
      end
    when PBTargets::Partner
      pbAddTarget(targets,pbPartner)
    else
      move.pbAddTarget(targets,self)
    end
    return user
  end

  def pbChangeUser(thismove,user)
    priority=@battle.pbPriority
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          PBDebug.log("[Lingering effect triggered] #{i.pbThis}'s Snatch made it use #{user.pbThis(true)}'s #{thismove.name}")
          @battle.pbCommonAnimation("Snatch",self,nil)    
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && user.pbIsOpposing?(target.index) && userchoice>=0
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
          break if $USENEWBATTLEMECHANICS
        end
      end
    end
    return user
  end

  def pbTarget(move)
    target=move.target
    if move.function==0x10D && (pbHasType?(:GHOST) || pbHasType?(:LICK)) # Curse
      target=PBTargets::SingleOpposing
    end
    # Changed Pollen Puff
    if move.function==0x214 && self.effects[PBEffects::HealBlock]>0
      target=PBTargets::SingleOpposing
    end
    # Changed Expanding Force
    if move.function==0x305 && !self.isAirborne? &&
      @battle.field.effects[PBEffects::PsychicTerrain]>0
      target=PBTargets::AllOpposing
    end
    return target
  end

  def pbAddTarget(targets,target)
    if !target.isFainted?
      targets[targets.length]=target
      return true
    end
    return false
  end

  def pbRandomTarget(targets)
    choices=[]
    pbAddTarget(choices,pbOpposing1)
    pbAddTarget(choices,pbOpposing2)
    if choices.length>0
      pbAddTarget(targets,choices[@battle.pbRandom(choices.length)])
    end
  end

  def pbChangeTarget(thismove,userandtarget,targets)
    priority=@battle.pbPriority
    changeeffect=0
    user=userandtarget[0]
    target=userandtarget[1]
    if !(user.hasWorkingAbility(:STALWART) || user.hasWorkingAbility(:PROPELLERTAIL)  || @function==0x259)
      # Lightningrod
      if targets.length==1 && isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:ELECTRIC) && 
         !target.hasWorkingAbility(:LIGHTNINGROD)
        for i in priority # use Pokémon earliest in priority
          next if user.index==i.index || target.index==i.index
          if i.hasWorkingAbility(:LIGHTNINGROD)
            PBDebug.log("[Ability triggered] #{i.pbThis}'s Lightningrod (change target)")
            target=i # X's Lightningrod took the attack!
            changeeffect=1
            break
          end
        end
      end
      # Storm Drain
      if targets.length==1 && isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:WATER) && 
         !target.hasWorkingAbility(:STORMDRAIN)
        for i in priority # use Pokémon earliest in priority
          next if user.index==i.index || target.index==i.index
          if i.hasWorkingAbility(:STORMDRAIN)
            PBDebug.log("[Ability triggered] #{i.pbThis}'s Storm Drain (change target)")
            target=i # X's Storm Drain took the attack!
            changeeffect=1
            break
          end
        end
      end
      # Doomy Trevor
      if targets.length==1 && isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:DOOM) && 
         !target.hasWorkingAbility(:DOOMYTREVOR)
        for i in priority # use Pokémon earliest in priority
          next if user.index==i.index || target.index==i.index
          if i.hasWorkingAbility(:DOOMYTREVOR)
            PBDebug.log("[Ability triggered] #{i.pbThis}'s Doomy Trevor (change target)")
            target=i # X's Doomy Trevor took the attack!
            changeeffect=1
            break
          end
        end
      end
    end
    # Change target to user of Follow Me (overrides Magic Coat
    # because check for Magic Coat below uses this target)
    if PBTargets.targetsOneOpponent?(thismove)
      newtarget=nil; strength=100
      for i in priority # use Pokémon latest in priority
        next if !user.pbIsOpposing?(i.index) || user.hasWorkingAbility(:STALWART) || user.hasWorkingAbility(:PROPELLERTAIL) || @function==0x259
        if !i.isFainted? && !@battle.switching && !i.effects[PBEffects::SkyDrop] &&
           i.effects[PBEffects::FollowMe]>0 && i.effects[PBEffects::FollowMe]<strength
          PBDebug.log("[Lingering effect triggered] #{i.pbThis}'s Follow Me")
          newtarget=i; strength=i.effects[PBEffects::FollowMe]
          changeeffect=0
        end
      end
      target=newtarget if newtarget
    end
    # TODO: Pressure here is incorrect if Magic Coat redirects target
    if user.pbIsOpposing?(target.index) && target.hasWorkingAbility(:PRESSURE)
      PBDebug.log("[Ability triggered] #{target.pbThis}'s Pressure (in pbChangeTarget)")
      user.pbReducePP(thismove) # Reduce PP
    end  
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} Snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          PBDebug.log("[Lingering effect triggered] #{i.pbThis}'s Snatch made it use #{user.pbThis(true)}'s #{thismove.name}")
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && user.pbIsOpposing?(target.index) && userchoice>=0
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Pressure (part of Snatch)")
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      end
    end
    if !thismove.isContactMove? || user.hasWorkingAbility(:LONGREACH)
      if !(user.hasMoldBreaker || thismove.function==0x300 || thismove.pbIsStatus?) && 
            target.hasWorkingAbility(:MINDYGLOPS)
        # switch user and target
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Mindy Glops made it use #{user.pbThis(true)}'s #{thismove.name}")
        changeeffect=3
        tmp=user
        user=target
        target=tmp
      end
    end
# Trampoline (Ability)
    if !thismove.isContactMove? || user.hasWorkingAbility(:LONGREACH)
      if !(user.hasMoldBreaker || thismove.pbIsStatus?) && 
            target.hasWorkingAbility(:TRAMPOLINE)
        # switch user and target
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Trampoline made it use #{user.pbThis(true)}'s #{thismove.name}")
        changeeffect=3
        tmp=user
        user=target
        target=tmp
      end
    end
# Trampoline (Move)
    if !thismove.isContactMove? || user.hasWorkingAbility(:LONGREACH)
      if thismove.pbIsDamaging? && target.pbOwnSide.effects[PBEffects::Trampoline]
        # switch user and target
        PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Trampoline made it use #{user.pbThis(true)}'s #{thismove.name}")
        changeeffect=3
        tmp=user
        user=target
        target=tmp
      end
    end
    if (target.pbOwnSide.effects[PBEffects::Brainologic] > 0 ||
        target.pbOwnSide.effects[PBEffects::RevelationPowder] > 0)&& 
        !(thismove.function==0x300 || user.hasWorkingAbility(:BALLOONIST)) && 
        user.pbIsOpposing?(target.index)
        target=target.pbPartner
    end
    if thismove.canMagicCoat?
      if target.effects[PBEffects::MagicCoat]
        # switch user and target
        PBDebug.log("[Lingering effect triggered] #{i.pbThis}'s Magic Coat made it use #{user.pbThis(true)}'s #{thismove.name}")
        changeeffect=3
        tmp=user
        user=target
        target=tmp
        # Magic Coat's PP is reduced if old user has Pressure
        userchoice=@battle.choices[user.index][1]
        if target.hasWorkingAbility(:PRESSURE) && user.pbIsOpposing?(target.index) && userchoice>=0
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Pressure (part of Magic Coat)")
          pressuremove=user.moves[userchoice]
          pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
        end
      elsif !user.hasMoldBreaker && target.hasWorkingAbility(:MAGICBOUNCE)
        # switch user and target
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Magic Bounce made it use #{user.pbThis(true)}'s #{thismove.name}")
        changeeffect=3
        tmp=user
        user=target
        target=tmp
      end
    end
    if changeeffect==1
      @battle.pbDisplay(_INTL("{1}'s {2} took the move!",target.pbThis,PBAbilities.getName(target.ability)))
    elsif changeeffect==3
      @battle.pbDisplay(_INTL("{1} bounced the {2} back!",user.pbThis,thismove.name))
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if !user.hasMoldBreaker && target.hasWorkingAbility(:SOUNDPROOF) &&
       thismove.isSoundBased? &&
       thismove.function!=0xE5 &&   # Perish Song handled elsewhere
       thismove.function!=0x151     # Parting Shot handled elsewhere
      PBDebug.log("[Ability triggered] #{target.pbThis}'s Soundproof blocked #{user.pbThis(true)}'s #{thismove.name}")
      @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,
         PBAbilities.getName(target.ability),thismove.name))
      return false
    end
    return true
  end

################################################################################
# Move PP
################################################################################
  def pbSetPP(move,pp)
    move.pp=pp
    # Not effects[PBEffects::Mimic], since Mimic can't copy Mimic
    if move.thismove && move.id==move.thismove.id && !@effects[PBEffects::Transform]
      move.thismove.pp=pp
    end
  end

  def pbReducePP(move)
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::Bide]>0 || 
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Uproar]>0
      # No need to reduce PP if two-turn attack
      return true
    end
    return true if move.pp<0   # No need to reduce PP for special calls of moves
    return true if move.totalpp==0   # Infinite PP, can always be used
    return false if move.pp==0
    if move.pp>0
      pbSetPP(move,move.pp-1)
    end
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

################################################################################
# Using a move
################################################################################
  def pbObedienceCheck?(choice)
    return true if choice[0]!=1
    if @battle.pbOwnedByPlayer?(@index) && @battle.internalbattle
      badgelevel=25
      badgelevel=50  if @battle.pbPlayer.numbadges>=1
      badgelevel=75  if @battle.pbPlayer.numbadges>=2
      badgelevel=100 if @battle.pbPlayer.numbadges>=3
      badgelevel=125 if @battle.pbPlayer.numbadges>=4
      badgelevel=150 if @battle.pbPlayer.numbadges>=5
      badgelevel=200 if @battle.pbPlayer.numbadges>=6
      badgelevel=250 if @battle.pbPlayer.numbadges>=7
      badgelevel=400 if @battle.pbPlayer.numbadges>=8
      badgelevel=1000 if @battle.pbPlayer.numbadges>=9
      badgelevel=1000 if @battle.pbPlayer.numbadges>=10
      badgelevel=1000 if @battle.pbPlayer.numbadges>=11
      move=choice[2]
      disobedient=false
      if @pokemon.isForeign?(@battle.pbPlayer) && @level>badgelevel
        a=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        disobedient|=a<badgelevel
      end
      if self.respond_to?("pbHyperModeObedience")
        disobedient|=!self.pbHyperModeObedience(move)
      end
      if disobedient
        PBDebug.log("[Disobedience] #{pbThis} disobeyed")
        @effects[PBEffects::Rage]=false
        if self.status==PBStatuses::SLEEP && 
           (move.function==0x11 || move.function==0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders while asleep!",pbThis)) 
          return false
        end
        b=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        if b<badgelevel
          return false if !@battle.pbCanShowFightMenu?(@index)
          othermoves=[]
          for i in 0...4
            next if i==choice[1]
            othermoves[othermoves.length]=i if @battle.pbCanChooseMove?(@index,i,false)
          end
          if othermoves.length>0
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) 
            newchoice=othermoves[@battle.pbRandom(othermoves.length)]
            choice[1]=newchoice
            choice[2]=@moves[newchoice]
            choice[3]=-1
          end
          return true
        elsif self.status!=PBStatuses::SLEEP
          c=@level-b
          r=@battle.pbRandom(256)
          if r<c && pbCanSleep?(self,false)
            pbSleepSelf()
            @battle.pbDisplay(_INTL("{1} took a nap!",pbThis))
            return false
          end
          r-=c
          if r<c
            @battle.pbDisplay(_INTL("It hurt itself in its confusion!"))
            pbConfusionDamage
          else
            message=@battle.pbRandom(4)
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) if message==0
            @battle.pbDisplay(_INTL("{1} turned away!",pbThis)) if message==1
            @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis)) if message==2
            @battle.pbDisplay(_INTL("{1} pretended not to notice!",pbThis)) if message==3
          end
          return false
        end
      end
      return true
    else
      return true
    end
  end

  def pbSuccessCheck(thismove,user,target,turneffects,accuracy=true)
    if user.effects[PBEffects::TwoTurnAttack]>0
      return true
    end
    # TODO: "Before Protect" applies to Counter/Mirror Coat
    if thismove.function==0xDE &&
       ((target.status!=PBStatuses::SLEEP && !target.hasWorkingAbility(:COMATOSE)) ||
       !(user.effects[PBEffects::HealBlock]==0))  # Dream Eater
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
      PBDebug.log("[Move failed] #{user.pbThis}'s Dream Eater's target isn't asleep")
      return false
    end
    if thismove.function==0x113 && user.effects[PBEffects::Stockpile]==0 # Spit Up
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      PBDebug.log("[Move failed] #{user.pbThis}'s Spit Up did nothing as Stockpile's count is 0")
      return false
    end
    unseenfistOff=true
    if user.hasWorkingAbility(:UNSEENFIST)
      unseenfistOff=false if thismove.isContactMove?
    end
    if target.effects[PBEffects::Protect] && thismove.canProtectAgainst? &&
			!target.effects[PBEffects::ProtectNegation] && unseenfistOff
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{target.pbThis}'s Protect stopped the attack")
      return false
    end
    p=thismove.priority
    if $USENEWBATTLEMECHANICS
      p+=1 if user.effects[PBEffects::SixtopiaP]
      p+=1 if user.hasWorkingAbility(:PRANKSTER) && thismove.pbIsStatus?
      p+=1 if user.hasWorkingAbility(:SONIKO) && !thismove.pbIsStatus?
      p+=1 if user.hasWorkingAbility(:TRIAGE) && thismove.isHealingMove?
      p+=1 if user.hasWorkingAbility(:SOUNDTRACK) && thismove.isSoundBased?
      p+=1 if user.hasWorkingAbility(:SINISTRO) && thismove.isContactMove?
      p+=1 if user.hasWorkingAbility(:GALEWINGS) && isConst?(thismove.type,PBTypes,:FLYING)
      p+=1 if @battle.field.effects[PBEffects::GrassyTerrain]>0 && thismove.function==0x310
      p+=1 if @battle.field.effects[PBEffects::ElectricTerrain]>0 && thismove.function==0x345
      p+=1 if @battle.field.effects[PBEffects::MistyTerrain]>0 && thismove.function==0x346
      p+=1 if @battle.field.effects[PBEffects::PsychicTerrain]>0 && thismove.function==0x347
      p+=1 if @battle.field.effects[PBEffects::VolcanicTerrain]>0 && thismove.function==0x348
      p+=1 if @battle.field.effects[PBEffects::LovelyTerrain]>0 && thismove.function==0x349
      p+=1 if @battle.field.effects[PBEffects::Cinament]>0 && thismove.function==0x350
    end
    if target.hasWorkingAbility(:PROVENDO) &&  thismove.canProtectAgainst? && 
      p>0 && !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} was protected by Provendo!",target.pbThis))
      PBDebug.log("[Move failed] Opposing's Provendo stopped the attack")
      return false
    end
    if target.pbOwnSide.effects[PBEffects::QuickGuard] && unseenfistOff && 
        thismove.canProtectAgainst? && p>0 && 
      !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} was protected by Quick Guard!",target.pbThis))
      PBDebug.log("[Move failed] The opposing side's Quick Guard stopped the attack")
      return false
    end
    # Changed added Psychic Terrain
    if @battle.field.effects[PBEffects::PsychicTerrain]>0 && p>0 && !target.isAirborne?
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} surrounds itself with psychic terrain!",target.pbThis))
      PBDebug.log("[Move failed] Psychic Terrain stopped the attack")
      return false
    end
    # Changed added immunity to prankster boosted moves for Dark-types
    if user.hasWorkingAbility(:PRANKSTER) && thismove.pbIsStatus? && p>0 &&
       target.pbHasType?(:DARK) && @battle.pbIsOpposing?(target.index)
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
      PBDebug.log("[Move failed] #{target.pbThis} is immune to prankster-boosted moves somehow")
      return false
    end
    # Added
    if (target.hasWorkingAbility(:DAZZLING) ||
       target.hasWorkingAbility(:QUEENLYMAJESTY) ||
       target.hasWorkingAbility(:ARMORTAIL) ||
       target.pbPartner.hasWorkingAbility(:DAZZLING) ||
       target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY) ||
       target.pbPartner.hasWorkingAbility(:ARMORTAIL)) &&
       !user.hasMoldBreaker && p>0 &&
       target!=user && target!=user.pbPartner
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,thismove.name))
      PBDebug.log("[Move failed] The opposing side's Dazzling/Queenly Majesty/Armor Tail stopped the attack")
      return false
    end
    # Changed end
    if target.pbOwnSide.effects[PBEffects::WideGuard] && unseenfistOff &&
       PBTargets.hasMultipleTargets?(thismove) && !thismove.pbIsStatus? &&
			!target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} was protected by Wide Guard!",target.pbThis))
      PBDebug.log("[Move failed] The opposing side's Wide Guard stopped the attack")
      return false
    end
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && thismove.pbIsStatus? &&
			thismove.function!=0xE5 # Perish Song
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",target.pbThis(true)))
      PBDebug.log("[Move failed] The opposing side's Crafty Shield stopped the attack")
      return false
    end
    if target.pbOwnSide.effects[PBEffects::MatBlock] && !thismove.pbIsStatus? &&
			thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation] &&
      unseenfistOff
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} was blocked by the kicked-up mat!",thismove.name))
      PBDebug.log("[Move failed] The opposing side's Mat Block stopped the attack")
      return false
    end
    # TODO: Mind Reader/Lock-On
    # --Sketch/FutureSight/PsychUp work even on Fly/Bounce/Dive/Dig
    if thismove.pbMoveFailed(user,target) # TODO: Applies to Snore/Fake Out
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("But it failed!"))
      PBDebug.log(sprintf("[Move failed] Failed pbMoveFailed (function code %02X)",thismove.function))
      return false
    end
    # King's Shield (purposely after pbMoveFailed)
    if target.effects[PBEffects::KingsShield] && unseenfistOff && 
      !thismove.pbIsStatus? && thismove.canProtectAgainst? && 
      !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{target.pbThis}'s King's Shield stopped the attack")
      if thismove.isContactMove? && !user.hasWorkingAbility(:LONGREACH) # changed
        user.pbReduceStat(PBStats::ATTACK,1,nil,false) # Was 2
      end
      return false
    end
    # Silk Trap (purposely after pbMoveFailed)
    if target.effects[PBEffects::SilkTrap] && unseenfistOff && 
      !thismove.pbIsStatus? && thismove.canProtectAgainst? && 
      !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{target.pbThis}'s Silk Trap stopped the attack")
      if thismove.isContactMove? && !user.hasWorkingAbility(:LONGREACH) # changed
        user.pbReduceStat(PBStats::SPEED,1,nil,false) # Was 2
      end
      return false
    end
    # Obstruct
    if target.effects[PBEffects::Obstruct] && unseenfistOff && 
      !thismove.pbIsStatus? && thismove.canProtectAgainst? && 
      !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{target.pbThis}'s Obstruct stopped the attack")
      if thismove.isContactMove? && !user.hasWorkingAbility(:LONGREACH) # changed
        user.pbReduceStat(PBStats::DEFENSE,2,nil,false)
      end
      return false
    end
    # Spiky Shield
    if target.effects[PBEffects::SpikyShield] && unseenfistOff && 
      thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{user.pbThis}'s Spiky Shield stopped the attack")
      if thismove.isContactMove? && !user.isFainted? && !user.hasWorkingAbility(:LONGREACH) # changed
        @battle.scene.pbDamageAnimation(user,0)
        amt=user.pbReduceHP((user.totalhp/8).floor)
        @battle.pbDisplay(_INTL("{1} was hurt!",user.pbThis)) if amt>0
      end
      return false
    end
     # Baneful Bunker
    if target.effects[PBEffects::BanefulBunker] && unseenfistOff &&
      thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[Move failed] #{user.pbThis}'s Baneful Bunker stopped the attack!")
      if thismove.isContactMove? && !user.isFainted? && user.pbCanPoison?(nil,false) && !user.hasWorkingAbility(:LONGREACH)
        PBDebug.log("#{target.pbThis} poisoned by Baneful Bunker")
        user.pbPoison(target,_INTL("{1} was poisoned!",target.pbThis))
      end
      return false
    end
    # Immunity to powder-based moves
    if $USENEWBATTLEMECHANICS && thismove.isPowderMove? &&
       (target.pbHasType?(:GRASS) || target.pbHasType?(:CHLOROPHYLL) ||
       (!user.hasMoldBreaker && target.hasWorkingAbility(:OVERCOAT)) ||
				target.hasWorkingItem(:SAFETYGOGGLES) || target.pbHasType?(:GAS))
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
      PBDebug.log("[Move failed] #{target.pbThis} is immune to powder-based moves somehow")
      return false
    end
    if thismove.pbIsStatus? # Mindy Glops
      if !user.hasMoldBreaker && target.hasWorkingAbility(:GOODASGOLD)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} makes Status moves miss with Good as Gold",target.pbThis))
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Good as Gold made the Status move miss")
        return false
      end
    end
    if thismove.basedamage>0 && thismove.function!=0x02 && # Struggle
       thismove.function!=0x111 # Future Sight
      type=thismove.pbType(thismove.type,user,target)
      typemod=thismove.pbTypeModifier(type,user,target)
      # Airborne-based immunity to Ground moves
      if isConst?(type,PBTypes,:GROUND) && target.isAirborne?(user.hasMoldBreaker) &&
         !target.hasWorkingItem(:RINGTARGET) && thismove.function!=0x11C # Smack Down
        if !user.hasMoldBreaker && target.hasWorkingAbility(:LEVITATE)
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Levitate!",target.pbThis))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Levitate made the Ground-type move miss")
          return false
        end
        if target.hasWorkingItem(:AIRBALLOON)
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1}'s Air Balloon makes Ground moves miss!",target.pbThis))
          PBDebug.log("[Item triggered] #{target.pbThis}'s Air Balloon made the Ground-type move miss")
          return false
        end
        if target.effects[PBEffects::MagicDelta]
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magic Delta!",target.pbThis))
          PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Magic Delta made the Ground-type move miss")
          return false
        end
        if target.effects[PBEffects::MagnetRise]>0
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
          PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Magnet Rise made the Ground-type move miss")
          return false
        end
        if target.effects[PBEffects::Telekinesis]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
          PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Telekinesis made the Ground-type move miss")
          return false
        end
      end
      if isConst?(type,PBTypes,:MAGIC) && !target.hasWorkingItem(:RINGTARGET) &&
         thismove.function!=0x97 # Magic Starfruit
        if !user.hasMoldBreaker && target.hasWorkingAbility(:MAGICBLOCK)
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Magic moves miss with Magic Block",target.pbThis))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Magic Block made the Mind-type move miss")
          return false
        end
      end
      if isConst?(type,PBTypes,:MIND) && !target.hasWorkingItem(:RINGTARGET) &&
         thismove.function!=0x300 # Mindy Glops
        if !user.hasMoldBreaker && target.hasWorkingAbility(:MINDYGLOPS)
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Mind moves miss with Mindy Glops",target.pbThis))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Mindy Glops made the Mind-type move miss")
          return false
        end
      end
      if thismove.pbIsElderSpecial? # Mindy Glops
        if target.hasWorkingAbility(:ELDERPROJECTOR)
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} makes Elder Special moves miss with Elder Projector",target.pbThis))
          PBDebug.log("[Ability triggered] #{target.pbThis}'s Elder Projector made the Elder Special move miss")
          return false
        end
      end
      if !user.hasMoldBreaker && target.hasWorkingAbility(:WONDERGUARD) &&
				type>=0 && typemod<=8
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Wonder Guard")
        return false 
      end
      if !user.hasMoldBreaker && target.hasWorkingAbility(:HERBLOBBY) &&
				type>=0 && typemod>8
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} avoided damage with Herb Lobby!",target.pbThis))
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Herb Lobby")
        return false 
      end
      if typemod==0
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
        PBDebug.log("[Move failed] Type immunity")
        return false 
      end
      if target.effects[PBEffects::Commander]
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        return false
      end
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Lock-On")
        return true
      end
      if target.effects[PBEffects::GlaiveRush]>0 && target.effects[PBEffects::GlaiveRushPos]==user.index
        PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Glaive Rush")
        return true
      end
      miss=false; override=false
      invulmove=PBMoveData.new(target.effects[PBEffects::TwoTurnAttack]).function
      case invulmove
      when 0xC9, 0xCC, 0x336 # Fly, Bounce
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C || # Smack Down
                         isConst?(thismove.id,PBMoves,:WHIRLWIND)
      when 0xCA # Dig
        miss=true unless thismove.function==0x76 || # Earthquake
                         thismove.function==0x95    # Magnitude, Eerie Quake
      when 0xCB # Dive, Brunal Water
        miss=true unless thismove.function==0x75    # Surf
                         thismove.function==0xD0    # Whirlpool
      when 0xCD # Shadow Force
        miss=true unless thismove.function==0x240   # Nightly
      when 0xCE # Sky Drop
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      when 0x14D # Phantom Force
        miss=true unless thismove.function==0x240    # Nightly
      end
      if target.effects[PBEffects::SkyDrop]
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0xCE ||  # Sky Drop
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      end
      miss=false if user.hasWorkingAbility(:NOGUARD) ||
                    target.hasWorkingAbility(:NOGUARD) ||
                    @battle.futuresight
      override=true if $USENEWBATTLEMECHANICS && thismove.function==0x06 && # Toxic
                    thismove.basedamage==0 && 
                    (user.pbHasType?(:POISON) || user.pbHasType?(:GAS))
      override=true if !miss && turneffects[PBEffects::SkipAccuracyCheck] # Called by another move
      if !override && (miss || !thismove.pbAccuracyCheck(user,target)) # Includes Counter/Mirror Coat
        PBDebug.log(sprintf("[Move failed] Failed pbAccuracyCheck (function code %02X) or target is semi-invulnerable",thismove.function))
        if thismove.target==PBTargets::AllOpposing && 
					(!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers && 
           (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          pbSEPlay("protection")
					@battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif target.effects[PBEffects::TwoTurnAttack]>0
          pbSEPlay("protection")
					@battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          pbSEPlay("protection")
					@battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        else
          pbSEPlay("protection")
					@battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
        end
        # Blunder Policy
        if user.hasWorkingItem(:BLUNDERPOLICY) && 
           target.effects[PBEffects::TwoTurnAttack]==0 && !thismove.isOHKO?
          showanim=true
          if user.pbIncreaseStatWithCause(PBStats::SPEED,2,user,PBItems.getName(user.item),showanim)
            PBDebug.log("[Item triggered] #{user.pbThis}'s Blunder Policy")
            showanim=false
          end
          user.pbConsumeItem if !showanim
        end
        # Pyro Claw
        if user.hasWorkingItem(:PYROCLAW) && 
           target.effects[PBEffects::TwoTurnAttack]==0 &&
           thismove.function!=0xDC &&
            !thismove.isOHKO? # Leech Seed
          choice=target
          blacklist=[
             0xC9,    # Fly
             0xCA,    # Dig
             0xCB,    # Dive
             0xCC,    # Bounce
             0xCD,    # Shadow Force
             0xCE,    # Sky Drop
             0x14D,   # Phantom Force
             0x336    # Steel Fly
          ]
          if choice.effects[PBEffects::Transform] ||
             user.effects[PBEffects::Transform] ||
             user.effects[PBEffects::TransformProtection] ||
             choice.effects[PBEffects::TransformProtection] ||
             choice.effects[PBEffects::Illusion] ||
             choice.effects[PBEffects::Substitute]>0 ||
             choice.effects[PBEffects::SkyDrop] ||
             blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function) ||
             isConst?(choice.ability,PBAbilities,:KOULUNDIN) ||
             isConst?(choice.ability,PBAbilities,:ALONELY) ||
             isUltraBlue?(choice) ||
             @battle.field.effects[PBEffects::Cinament]>0 && !user.hasWorkingItem(:RODOFSPARROW)
            PBDebug.log("[Item triggered] #{pbThis}'s Pyro Claw couldn't transform")
          elsif choice.hasWorkingItem(:PASTELCARD) 
            if user.pbReduceStatWithCause(PBStats::DEFENSE,1,choice,PBItems.getName(choice.item))
              choice.effects[PBEffects::TransformProtection]=true
              choice.pbConsumeItem
              user.pbConsumeItem  # Still conumes item even if transform changes into other effect
            end
          elsif choice.hasWorkingItem(:PLACTENCARD) 
            if user.pbReduceStatWithCause(PBStats::SPDEF,1,choice,PBItems.getName(choice.item))
              user.effects[PBEffects::TransformBlock]=true
              choice.effects[PBEffects::TransformProtection]=true
              choice.pbConsumeItem
              user.pbConsumeItem  # Still conumes item even if transform changes into other effect
            end
          else
            PBDebug.log("[Item triggered] #{user.pbThis}'s Pyro Claw")
            @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),user,choice)
            user.effects[PBEffects::Transform]=true
            user.effects[PBEffects::Mimicry] = choice.effects[PBEffects::Mimicry]
            user.effects[PBEffects::Type1] = choice.effects[PBEffects::Type1]
            user.effects[PBEffects::Type2] = choice.effects[PBEffects::Type2]
            user.type1=choice.type1
            user.type2=choice.type2
            user.effects[PBEffects::Type3]=-1
            user.ability=choice.ability
            user.attack=choice.attack
            user.defense=choice.defense
            user.speed=choice.speed
            user.spatk=choice.spatk
            user.spdef=choice.spdef
            for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                      PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
              user.stages[i]=choice.stages[i]
            end
            for i in 0...4
              user.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
              user.moves[i].pp=5
              user.moves[i].totalpp=5
            end
            user.effects[PBEffects::Disable]=0
            user.effects[PBEffects::DisableMove]=0
            user.pbConsumeItem
            @battle.pbDisplay(_INTL("{1} transformed into {2}!",user.pbThis,choice.pbThis(true)))
            PBDebug.log("[Pokémon transformed] #{user.pbThis} transformed into #{choice.pbThis(true)}")
          end
        end
        # End Pyro Claw
        return false
      end
    end
    # Temperature
    type=thismove.pbType(thismove.type,user,target)
      target.temperature2 = [1,-1][rand(2)] if rand(100) < 6
    if isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:SUN)
      target.temperature2 = [[5,10][rand(2)],5][rand(2)] if rand(100) < 45
    end
    if isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:BLIZZARD)
      target.temperature2 = [[-5,-10][rand(2)],-1,-5] [rand(3)] if rand(100) < 45
    end
    # End Temperature
    return true
  end

  def pbTryUseMove(choice,thismove,turneffects)
    return false if @effects[PBEffects::Commander]
    return true if turneffects[PBEffects::PassedTrying]
    # TODO: Return true if attack has been Mirror Coated once already
    if !turneffects[PBEffects::SkipAccuracyCheck]
      return false if !pbObedienceCheck?(choice)
    end
    if @effects[PBEffects::SkyDrop] # Intentionally no message here
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of being Sky Dropped")
      return false
    end
    if @battle.field.effects[PBEffects::Gravity]>0 && thismove.unusableInGravity?
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} can't use {2} because of gravity!",pbThis,thismove.name))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Gravity")
      return false
    end
    if @effects[PBEffects::Khleri]>0 && thismove.basedamage>0
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} can't use {2} after the khleri!",pbThis,thismove.name))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Khleri")
      return false
    end
    if @effects[PBEffects::Taunt]>0 && thismove.basedamage==0
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!",pbThis,thismove.name))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Taunt")
      return false
    end
    if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1} can't use {2} because of Heal Block!",pbThis,thismove.name))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Heal Block")
      return false
    end
    if @effects[PBEffects::SilveryBliss]
			pbSEPlay("protection")
			@battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      PBDebug.log("[Move failed] #{pbThis} must recharge")
      @effects[PBEffects::SilveryBliss]=false
      return false
    end
    if @effects[PBEffects::Torment] && 
      thismove.id==@lastMoveUsed && thismove.id!=@battle.struggle.id &&
      @effects[PBEffects::TwoTurnAttack]==0
			pbSEPlay("protection")
      @battle.pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",pbThis))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Torment")
      return false
    end
    # Trummet Spirit
    if !hasMoldBreaker
      if pbOpposing1.hasWorkingAbility(:TRUMMETSPIRIT) && !pbOpposing1.isFainted? &&
        thismove.id==@lastMoveUsed && thismove.id!=@battle.struggle.id &&
        @effects[PBEffects::TwoTurnAttack]==0
        pbSEPlay("protection")
        @battle.pbDisplayPaused(_INTL("{1} can't use the same move in a row due to {2}'s Trummet Spirit!",pbThis(true),pbOpposing1.pbThis(true)))
        PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Torment")
        return false
      elsif pbOpposing2.hasWorkingAbility(:TRUMMETSPIRIT) && !pbOpposing2.isFainted? &&
        thismove.id==@lastMoveUsed && thismove.id!=@battle.struggle.id &&
        @effects[PBEffects::TwoTurnAttack]==0
        pbSEPlay("protection")
        @battle.pbDisplayPaused(_INTL("{1} can't use the same move in a row due to {2}'s Trummet Spirit!",pbThis,pbOpposing2.pbThis(true)))
        PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name} because of Torment")
        return false
      end
    end
    # Gigaton Hammer
    if thismove.function==0x371 && 
      thismove.id==@lastMoveUsed && thismove.id!=@battle.struggle.id &&
      @effects[PBEffects::TwoTurnAttack]==0
			pbSEPlay("protection")
      @battle.pbDisplayPaused(_INTL("{1} can't use that move in a row!",pbThis))
      PBDebug.log("[Move failed] #{pbThis} can't use #{thismove.name}")
      return false
    end
    if pbOpposing1.effects[PBEffects::Imprison] && !pbOpposing1.isFainted?
      if thismove.id==pbOpposing1.moves[0].id ||
         thismove.id==pbOpposing1.moves[1].id ||
         thismove.id==pbOpposing1.moves[2].id ||
         thismove.id==pbOpposing1.moves[3].id
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",pbThis,thismove.name))
        PBDebug.log("[Move failed] #{thismove.name} can't use #{thismove.name} because of #{pbOpposing1.pbThis(true)}'s Imprison")
        return false
      end
    end
    if pbOpposing2.effects[PBEffects::Imprison] && !pbOpposing2.isFainted?
      if thismove.id==pbOpposing2.moves[0].id ||
         thismove.id==pbOpposing2.moves[1].id ||
         thismove.id==pbOpposing2.moves[2].id ||
				 thismove.id==pbOpposing2.moves[3].id
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",pbThis,thismove.name))
        PBDebug.log("[Move failed] #{thismove.name} can't use #{thismove.name} because of #{pbOpposing2.pbThis(true)}'s Imprison")
        return false
      end
    end
    if @effects[PBEffects::ThroatChop]>0 && thismove.isSoundBased? # changed added
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("The effects of Throat Chop prevent {1} from using certain moves!",pbThis))
      PBDebug.log("[Move failed] The effects of Throat Chop prevent #{pbThis} from using certain moves!")
      return false
    end
    if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove] &&
			 !@battle.switching # Pursuit ignores if it's disabled
			pbSEPlay("protection")
      @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
      PBDebug.log("[Move failed] #{pbThis}'s #{thismove.name} is disabled")
      return false
    end
    if choice[1]==-2 # Battle Palace
      pbSEPlay("protection")
			@battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      PBDebug.log("[Move failed] Battle Palace: #{pbThis} is incapable of using its power")
      return false
    end
    if @effects[PBEffects::HyperBeam]>0
			pbSEPlay("protection")
			@battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      PBDebug.log("[Move failed] #{pbThis} must recharge after using #{PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove)).name}")
      return false
    end
    if self.hasWorkingAbility(:TRUANT) && @effects[PBEffects::Truant]
      pbSEPlay("protection")
			@battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
      PBDebug.log("[Ability triggered] #{pbThis}'s Truant")
      return false
    end
    if (!self.hasWorkingAbility(:TRUANT) && ($PokemonSystem.battledif==4 rescue false) ) && @effects[PBEffects::Truant]
      pbSEPlay("protection")
			@battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
      return false
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if self.status==PBStatuses::SLEEP
        self.statusCount-=1
        if self.statusCount<=0
          self.pbCureStatus
        else
          self.pbContinueStatus
          PBDebug.log("[Status] #{pbThis} remained asleep (count: #{self.statusCount})")
          if !thismove.pbCanUseWhileAsleep? # Snore/Sleep Talk/Outrage
            PBDebug.log("[Move failed] #{pbThis} couldn't use #{thismove.name} while asleep")
            return false
          end
        end
      end
    end
    if self.status==PBStatuses::FROZEN
      if thismove.canThawUser?
        PBDebug.log("[Move effect triggered] #{pbThis} was defrosted by using #{thismove.name}")
        self.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} melted the ice!",pbThis))
        pbCheckForm
      elsif @battle.pbRandom(10)<2 && !turneffects[PBEffects::SkipAccuracyCheck]
        self.pbCureStatus
        pbCheckForm
      elsif !thismove.canThawUser?
        self.pbContinueStatus
        PBDebug.log("[Status] #{pbThis} remained frozen and couldn't move")
        return false
      end
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if @effects[PBEffects::Confusion]>0
        @effects[PBEffects::Confusion]-=1
        if @effects[PBEffects::Confusion]<=0
          pbCureConfusion
        else
          pbContinueConfusion
          PBDebug.log("[Status] #{pbThis} remained confused (count: #{@effects[PBEffects::Confusion]})")
          if @battle.pbRandom(($USENEWBATTLEMECHANICS) ? 3 : 2)==0
            pbConfusionDamage
            @battle.pbDisplay(_INTL("It hurt itself in its confusion!")) 
            PBDebug.log("[Status] #{pbThis} hurt itself in its confusion and couldn't move")
            return false
          end
        end
      end
    end
    if @effects[PBEffects::Flinch]
      @effects[PBEffects::Flinch]=false
    # Some abilities from FLINT that work like Steadfast but increases another stat
    if self.hasWorkingAbility(:FIERYGIST) # Evasion Increase
        if pbIncreaseStatWithCause(PBStats::EVASION,1,self,PBAbilities.getName(self.ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Steadfast")
        end
        return false
      end
    if self.hasWorkingAbility(:FLOERYGIST) # Accuracy Increase
        if pbIncreaseStatWithCause(PBStats::ACCURACY,1,self,PBAbilities.getName(self.ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Steadfast")
        end
        return false
    end
      @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
      PBDebug.log("[Lingering effect triggered] #{pbThis} flinched")
      if self.hasWorkingAbility(:STEADFAST) # Speed Increase
        if pbIncreaseStatWithCause(PBStats::SPEED,1,self,PBAbilities.getName(self.ability))
          PBDebug.log("[Ability triggered] #{pbThis}'s Steadfast")
        end
      end
      return false
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if @effects[PBEffects::Attract]>=0
        pbAnnounceAttract(@battle.battlers[@effects[PBEffects::Attract]])
        if @battle.pbRandom(2)==0
          pbContinueAttract
          PBDebug.log("[Lingering effect triggered] #{pbThis} was infatuated and couldn't move")
          return false
        end
      end
      if self.status==PBStatuses::PARALYSIS
        if @battle.pbRandom(4)==0
          pbContinueStatus
          PBDebug.log("[Status] #{pbThis} was fully paralysed and couldn't move")
          return false
        end
      end
    end
    turneffects[PBEffects::PassedTrying]=true
    return true
  end

  def pbConfusionDamage
    self.damagestate.reset
    confmove=PokeBattle_Confusion.new(@battle,nil)
    confmove.pbEffect(self,self)
    pbFaint if self.isFainted?
  end

  def pbUpdateTargetedMove(thismove,user)
    # TODO: Snatch, moves that use other moves
    # TODO: All targeting cases
    # Two-turn attacks, Magic Coat, Future Sight, Counter/MirrorCoat/Bide handled
  end

  def pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,nocheck=false,alltargets=nil,showanimation=true,danced=false)
    realnumhits=0
    totaldamage=0
    destinybond=false
    brainymedia=false
    neutralizinggas=false
    originalTarget=target
    for i in 0...numhits
      target.damagestate.reset
      if thismove.function==0x257 && @battle.doublebattle && target!=user.pbPartner && # Dragon Darts
         !target.pbPartner.isFainted?
        changetarget=false
        for i in @battle.pbPriority
          next if !user.pbIsOpposing?(i.index)
          changetarget=true if i.effects[PBEffects::FollowMe]>0 #|| i.effects[PBEffects::RagePowder]>0 || 
                             #  i.effects[PBEffects::Spotlight]
        end
        if (thismove.pbTypeModifier(thismove.pbType(thismove.type,user,originalTarget),user,originalTarget)==0 ||
           thismove.pbTypeImmunityByAbility(thismove.pbType(thismove.type,user,originalTarget),user,originalTarget) ||
           (originalTarget.effects[PBEffects::Protect] || 
           (originalTarget.pbOwnSide.effects[PBEffects::QuickGuard] && thismove.priority>0) ||
           originalTarget.effects[PBEffects::KingsShield] ||
           originalTarget.effects[PBEffects::SilkTrap] ||
           originalTarget.effects[PBEffects::SpikyShield] ||
           originalTarget.effects[PBEffects::BanefulBunker] ||
           originalTarget.effects[PBEffects::Obstruct] ||
           riginalTarget.effects[PBEffects::SilkTrap]) ||             
           originalTarget.effects[PBEffects::TwoTurnAttack]>0 ||
           !thismove.pbAccuracyCheck(user,originalTarget)) && !changetarget
          target=originalTarget.pbPartner
        end
      end
      # Check success (accuracy/evasion calculation)
      if !nocheck &&
         !pbSuccessCheck(thismove,user,target,turneffects,i==0 || thismove.successCheckPerHit?)
        if (thismove.function==0xBF || thismove.function==0x359) && realnumhits>0   # Triple Kick
          break   # Considered a success if Triple Kick hits at least once
        elsif thismove.function==0x10B ||
              thismove.function==0x355 # Hi Jump Kick, Jump Kick, Axe Kick
          if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
            PBDebug.log("[Move effect triggered] #{user.pbThis} took crash damage")
            #TODO: Not shown if message is "It doesn't affect XXX..."
						pbSEPlay("protection")
            @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
            damage=(user.totalhp/2).floor
            if damage>0
              @battle.scene.pbDamageAnimation(user,0)
              user.pbReduceHP(damage)
            end
            user.pbFaint if user.isFainted?
          end
        end
        user.effects[PBEffects::Outrage]=0 if thismove.function==0xD2 # Outrage
        user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
        user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
        user.effects[PBEffects::LastMoveFailed]=true
        return
      end
      # Add to counters for moves which increase them when used in succession
      if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<4
      else
        user.effects[PBEffects::FuryCutter]=0
      end
      if thismove.function==0x92 # Echoed Voice
        if !user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed] &&
           user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]<5
          user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]+=1
        end
        user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed]=true
      end
      # Count a hit for Parental Bond if it applies
      user.effects[PBEffects::ParentalBond]-=1 if user.effects[PBEffects::ParentalBond]>0
      # Count a hit for Dragon Darts if it hits first time
      if thismove.function==0x257 && @battle.doublebattle && realnumhits>0
        secondTarget=target.pbPartner
        changetarget=false
        for i in @battle.pbPriority
          next if !user.pbIsOpposing?(i.index)
          changetarget=true if i.effects[PBEffects::FollowMe]>0 #|| i.effects[PBEffects::RagePowder]>0 || 
                            #   i.effects[PBEffects::Spotlight]
        end
        if (thismove.pbTypeModifier(thismove.pbType(thismove.type,user,secondTarget),user,secondTarget)==0 ||
           thismove.pbTypeImmunityByAbility(thismove.pbType(thismove.type,user,secondTarget),user,secondTarget) ||
           (secondTarget.effects[PBEffects::Protect] || 
           (secondTarget.pbOwnSide.effects[PBEffects::QuickGuard] && thismove.priority>0) ||
           secondTarget.effects[PBEffects::SpikyShield] ||
           secondTarget.effects[PBEffects::BanefulBunker] ||
           secondTarget.effects[PBEffects::Obstruct] ||
           secondTarget.effects[PBEffects::SilkTrap]) ||             
           secondTarget.effects[PBEffects::TwoTurnAttack]>0 ||
           !thismove.pbAccuracyCheck(user,secondTarget)) && !changetarget
          target=secondTarget.pbPartner if secondTarget.pbPartner!=user.pbPartner
        else
          target=originalTarget.pbPartner if secondTarget.pbPartner!=user.pbPartner
          if target.hasWorkingAbility(:PRESSURE) && !originalTarget.hasWorkingAbility(:PRESSURE)
            PBDebug.log("[Ability triggered] #{target.pbThis}'s Pressure (in pbChangeTarget)")
            user.pbReducePP(thismove) # Reduce PP
          end
        end
      end
      # This hit will happen; count it      
      realnumhits+=1
      # Damage calculation and/or main effect
      damage=thismove.pbEffect(user,target,i,alltargets,showanimation) # Recoil/drain, etc. are applied here
      totaldamage+=damage if damage>0
      # Message and consume for type-weakening berries
      if target.damagestate.berryweakened
        @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",
           PBItems.getName(target.item),target.pbThis(true)))
        target.pbConsumeItem
      end
      # Illusion
      if target.effects[PBEffects::Illusion] && target.hasWorkingAbility(:ILLUSION) &&
         damage>0 && !target.damagestate.substitute
        PBDebug.log("[Ability triggered] #{target.pbThis}'s Illusion ended")    
        target.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(target,target.pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",target.pbThis,
            PBAbilities.getName(target.ability)))
      end
      # Roomba
      if isConst?(target.species,PBSpecies,:ROOMBA) && isUltraBlue?(target) &&
         damage>0 && !target.damagestate.substitute && rand(100) < 20
        target.form-=3
        target.pbUpdate(true)
        @battle.scene.pbChangePokemon(target,target.pokemon)
        @battle.pbDisplay(_INTL("{1}'s graduation wore off",target.pbThis))
        PBDebug.log("[Form changed] #{target.pbThis} graduation ended")
      end
      if user.isFainted?
        user.pbFaint # no return
      end
      if numhits>1 && target.damagestate.calcdamage<=0
        user.effects[PBEffects::LastMoveFailed]=true
        return
      end
      @battle.pbJudgeCheckpoint(user,thismove)
      # Additional effect
      if target.damagestate.calcdamage>0 &&
         !user.hasWorkingAbility(:SHEERFORCE) &&
         (user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST))
        addleffect=thismove.addlEffect
        addleffect=0  if user.pbOwnSide.effects[PBEffects::CrateBuster]>0
        addleffect*=2 if (user.hasWorkingAbility(:SERENEGRACE) ||
                         user.pbOwnSide.effects[PBEffects::Rainbow]>0) &&
                         ($USENEWBATTLEMECHANICS || 
                          thismove.function!=0xA4) # Secret Power
        addleffect*=1.5 if user.hasWorkingAbility(:FINITI) &&
                         (thismove.function==0x245 || thismove.function==0x246 ||
                          thismove.function==0x295) 
        addleffect=100 if ($DEBUG || $TEST) && Input.press?(Input::CTRL)
        addleffect=100 if isConst?(user.species,PBSpecies,:ENCHRISO) && # FLINT Species (Set here for convenience)
                          thismove.function==0x251  # Magic Gold
        if @battle.pbRandom(100)<addleffect
          PBDebug.log("[Move effect triggered] #{thismove.name}'s added effect")
          thismove.pbAdditionalEffect(user,target)
        end
      end
      # Ability effects
      pbEffectsOnDealingDamage(thismove,user,target,damage)
      # Emergency Exit / Wimp Out
      if (target.hasWorkingAbility(:WIMPOUT) ||
         target.hasWorkingAbility(:EMERGENCYEXIT)) &&
         target.hp<=(target.totalhp/2).floor &&
         target.hp+damage>(target.totalhp/2).floor &&
         ((@battle.pbCanChooseNonActive?(target.index) &&
         !@battle.pbAllFainted?(@battle.pbParty(target.index))) ||
         !@battle.opponent) # wild
        PBDebug.log("[#{target.pbThis}'s #{PBAbilities.getName(target.ability)} triggered]")
        @battle.pbDisplay(_INTL("{1} made an emergency exit!",target.pbThis)) if target.hasWorkingAbility(:EMERGENCYEXIT)
        @battle.pbDisplay(_INTL("{1} wimped out!",target.pbThis)) if target.hasWorkingAbility(:WIMPOUT)
        @battle.choices[target.index][0] = -1
        @battle.choices[target.index][1] = -1
        @battle.choices[target.index][2] = -1
        @battle.choices[target.index][3] = -1
        if !@battle.opponent # escape wild battles
          @battle.decision=3
        else
          @battle.pbDisplay(_INTL("{1} went back to {2}!",target.pbThis,@battle.pbGetOwner(target.index).name)) 
          newpoke=@battle.pbSwitchInBetween(target.index,true,false)
          @battle.pbMessagesOnReplace(target.index,newpoke)
          target.pbResetForm
          @battle.pbReplace(target.index,newpoke,false)
          @battle.pbOnActiveOne(target)
          target.pbAbilitiesOnSwitchIn(true)
        end          
      end
      # Grudge
      if !user.isFainted? && target.isFainted?
        if target.effects[PBEffects::Grudge] && target.pbIsOpposing?(user.index)
          thismove.pp=0
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!",
             user.pbThis,thismove.name))
          PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Grudge made #{thismove.name} lose all its PP")
        end
      end
      if target.isFainted?
        destinybond=destinybond || target.effects[PBEffects::DestinyBond]
        brainymedia=brainymedia || target.effects[PBEffects::Brainymedia]
      end
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted?
      break if target.isFainted?
      # Make the target flinch
      if target.damagestate.calcdamage>0 && !target.damagestate.substitute
        if user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST)
          canflinch=false
          if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) &&
             thismove.canKingsRock?
            canflinch=true
          end
          if user.hasWorkingAbility(:STENCH) &&
             thismove.function!=0x09 && # Thunder Fang
             thismove.function!=0x0B && # Fire Fang
             thismove.function!=0x0E && # Ice Fang
             thismove.function!=0x0F && # flinch-inducing moves
             thismove.function!=0x10 && # Stomp
             thismove.function!=0x11 && # Snore
             thismove.function!=0x12 && # Fake Out
             thismove.function!=0x78 && # Twister
             thismove.function!=0xC7    # Sky Attack
            canflinch=true
          end
          if canflinch && @battle.pbRandom(10)==0
            PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
            target.pbFlinch(user)
          end
        end
      end
      if target.damagestate.calcdamage>0 && !target.isFainted?
        # Defrost
        if target.status==PBStatuses::FROZEN &&
           (isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:FIRE) ||
           ($USENEWBATTLEMECHANICS && isConst?(thismove.id,PBMoves,:SCALD)) ||
            isConst?(thismove.id,PBMoves,:SCORCHINGSANDS))
          target.pbCureStatus
        end
        # Rage
        if target.effects[PBEffects::Rage] && target.pbIsOpposing?(user.index)
          # TODO: Apparently triggers if opposing Pokémon uses Future Sight after a Future Sight attack
          if target.pbIncreaseStatWithCause(PBStats::ATTACK,1,target,"",true,false)
            PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Rage")
            @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
          end
        end
      end
      target.pbFaint if target.isFainted? # no return
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted? || target.isFainted?
      # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
      for j in 0...4
        @battle.battlers[j].pbBerryCureCheck
      end
      break if user.isFainted? || target.isFainted?
      target.pbUpdateTargetedMove(thismove,user)
      break if target.damagestate.calcdamage<=0
    end
    turneffects[PBEffects::TotalDamage]+=totaldamage if totaldamage>0
    # Battle Arena only - attack is successful
    @battle.successStates[user.index].useState=2
    @battle.successStates[user.index].typemod=target.damagestate.typemod
    # Type effectiveness
    if numhits>1
      if target.damagestate.typemod>8
				pbSEPlay("stat3")
        if alltargets.length>1
          @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("It's super effective!"))
        end
      elsif target.damagestate.typemod>=1 && target.damagestate.typemod<8
        pbSEPlay("stat1")
				if alltargets.length>1
          @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("It's not very effective..."))
        end
      end
      if realnumhits==1
        @battle.pbDisplay(_INTL("Hit {1} time!",realnumhits))
      else
        @battle.pbDisplay(_INTL("Hit {1} times!",realnumhits)) if thismove.function!=0x257
      end
    end
    PBDebug.log("Move did #{numhits} hit(s), total damage=#{turneffects[PBEffects::TotalDamage]}")
    # Faint if 0 HP
    target.pbFaint if target.isFainted? # no return
    user.pbFaint if user.isFainted? # no return
    thismove.pbEffectAfterHit(user,target,turneffects)
    target.pbFaint if target.isFainted? # no return
    user.pbFaint if user.isFainted? # no return
    # Destiny Bond
    if !user.isFainted? && target.isFainted?
      if destinybond && target.pbIsOpposing?(user.index)
        PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Destiny Bond")
				pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} took its attacker down with it!",target.pbThis))
        user.pbReduceHP(user.hp)
        user.pbFaint # no return
        @battle.pbJudgeCheckpoint(user)
      end
      if brainymedia && target.pbIsOpposing?(user.index)
        if (user.pbCanReduceStatStage?(PBStats::ATTACK,target) ||
           user.pbCanReduceStatStage?(PBStats::DEFENSE,target) ||
           user.pbCanReduceStatStage?(PBStats::SPATK,target) ||
           user.pbCanReduceStatStage?(PBStats::SPDEF,target) ||
           user.pbCanReduceStatStage?(PBStats::SPEED,target) ||
           user.pbCanReduceStatStage?(PBStats::ACCURACY,target) ||
           user.pbCanReduceStatStage?(PBStats::EVASION,target))
          PBDebug.log("[Lingering effect triggered] #{target.pbThis}'s Brainymedia")
          user.stages[PBStats::ATTACK]=-6
          user.stages[PBStats::DEFENSE]=-6
          user.stages[PBStats::SPATK]=-6
          user.stages[PBStats::SPDEF]=-6
          user.stages[PBStats::SPEED]=-6
          user.stages[PBStats::ACCURACY]=-6
          user.stages[PBStats::EVASION]=-6
          @battle.pbCommonAnimation("StatDown",user,nil)
          @battle.pbDisplay(_INTL("{1} lowered its attacker stats!",target.pbThis))
        end
      end
    end
    pbEffectsAfterHit(user,target,thismove,turneffects)
    # Berry check
    for j in 0...4
      @battle.battlers[j].pbBerryCureCheck
    end
    target.pbUpdateTargetedMove(thismove,user)
    user.effects[PBEffects::LastMoveFailed]=false
  end

  def pbUseMoveSimple(moveid,index=-1,target=-1,danced=false)
    choice=[]
    choice[0]=1       # "Use move"
    choice[1]=index   # Index of move to be used in user's moveset
    choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveid)) # PokeBattle_Move object of the move
    choice[2].pp=-1
    choice[3]=target  # Target (-1 means no target yet)
    if index>=0
      @battle.choices[@index][1]=index
    end
    PBDebug.log("#{pbThis} used simple move #{choice[2].name}")
    pbUseMove(choice,true,danced)
    return
  end
  
  def pbDancerMoveCheck(id)
    dancemoves = [
      17, # Quiver Dance
      63, # Dragon Dance
      138, # Fiery Dance
      170, # Feather Dance
      192, # Petal Dance
      418, # Swords Dance
      420, # Teeter Dance
      483, # Lunar Dance
      748  # Revelation Dance
    ]
    for i in @battle.battlers
      next if i == self
      for j in dancemoves
        if id == j
          if i.hasWorkingAbility(:DANCER)
            @battle.pbDisplay(_INTL("{1} danced along!",i.pbThis))
            i.pbUseMoveSimple(id,-1,-1,true)
          end
        end
      end
    end
  end

  def pbUseMove(choice,specialusage=false,danced=false)
    # TODO: lastMoveUsed is not to be updated on nested calls
    # Note: user.lastMoveUsedType IS to be updated on nested calls; is used for Conversion 2
    turneffects=[]
    turneffects[PBEffects::SpecialUsage]=specialusage
    turneffects[PBEffects::SkipAccuracyCheck]=specialusage
    turneffects[PBEffects::PassedTrying]=false
    turneffects[PBEffects::TotalDamage]=0
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::Uproar]>0 ||
       @effects[PBEffects::Bide]>0
      choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove))
      turneffects[PBEffects::SpecialUsage]=true
      PBDebug.log("Continuing multi-turn move #{choice[2].name}")
    elsif @effects[PBEffects::Encore]>0
      if @battle.pbCanShowCommands?(@index) &&
         @battle.pbCanChooseMove?(@index,@effects[PBEffects::EncoreIndex],false)
        if choice[1]!=@effects[PBEffects::EncoreIndex] # Was Encored mid-round
          choice[1]=@effects[PBEffects::EncoreIndex]
          choice[2]=@moves[@effects[PBEffects::EncoreIndex]]
          choice[3]=-1 # No target chosen
        end
        PBDebug.log("Using Encored move #{choice[2].name}")
      end
    end
    thismove=choice[2]
    return if !thismove || thismove.id==0 # if move was not chosen
    if !turneffects[PBEffects::SpecialUsage]
      # TODO: Quick Claw message
    end
    # ---
    # Record that user has used a move this round (ot at least tried to)
    self.lastRoundMoved=@battle.turncount
    # Try to use the move
    if !pbTryUseMove(choice,thismove,turneffects)
      self.lastMoveUsed=-1
      self.lastMoveUsedType=-1
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=-1
      end
      pbCancelMoves
      @battle.pbGainEXP
      pbEndTurn(choice)
      @battle.pbJudge #      @battle.pbSwitch
      return
    end
    if !turneffects[PBEffects::SpecialUsage]
      if !pbReducePP(thismove)
        @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        self.lastMoveUsed=-1
        self.lastMoveUsedType=-1
        self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=-1
        pbEndTurn(choice)
        @battle.pbJudge #        @battle.pbSwitch
        PBDebug.log("[Move failed] #{thismove.name} has no PP left")
        return
      end
    end
    # Remember that user chose a two-turn move
    if thismove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[PBEffects::TwoTurnAttack]=thismove.id
      @currentMove=thismove.id
    else
      @effects[PBEffects::TwoTurnAttack]=0 # Cancel use of two-turn attack
    end
    # Charge up Metronome item
    if self.lastMoveUsed==thismove.id
      self.effects[PBEffects::Metronome]+=1
    else
      self.effects[PBEffects::Metronome]=0
    end
    
    # Start
    # Stance Change
    if hasWorkingAbility(:STANCECHANGE) && isConst?(species,PBSpecies,:AEGISLASH) &&
       !@effects[PBEffects::Transform]
      if thismove.pbIsDamaging? && self.form!=1
        self.form=1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} changed to Blade Forme!",pbThis))
        PBDebug.log("[Form changed] #{pbThis} changed to Blade Forme")
      elsif isConst?(thismove.id,PBMoves,:KINGSSHIELD) && self.form!=0
        self.form=0
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} changed to Shield Forme!",pbThis))
        PBDebug.log("[Form changed] #{pbThis} changed to Shield Forme")
      end      
    end
    # Dolphinino
    if hasWorkingAbility(:DOLPHININO) && isConst?(species,PBSpecies,:DOLPHIN) &&
       !@effects[PBEffects::Transform]
      if thismove.pbIsPhysical?(thismove.type) && self.form!=2
        self.form=2
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} changed to Stealth Forme!",pbThis))
        PBDebug.log("[Form changed] #{pbThis} changed to Stealth Forme")
      elsif isConst?(thismove.id,PBMoves,:OCTUMSHIELD) && self.form!=1
        self.form=1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} changed to Octum Forme!",pbThis))
        PBDebug.log("[Form changed] #{pbThis} changed to Octum Forme")
      end      
    end
    # Gulp Missile
    if hasWorkingAbility(:GULPMISSILE) && isConst?(species,PBSpecies,:CRAMORANT) &&
       !@effects[PBEffects::Transform]
      if (isConst?(thismove.id,PBMoves,:DIVE) || 
          isConst?(thismove.id,PBMoves,:SURF)) && self.form==0
        self.form=(self.hp<=((self.totalhp/2).floor)) ? 2 : 1
        @effects[PBEffects::GulpMissile]=true
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} changed forme",pbThis))
        PBDebug.log("[Form changed] #{pbThis} changed forme")
      end      
    end
    # Mycelium Might (Mold Breaker)
    if hasWorkingAbility(:MYCELIUMMIGHT) && thismove.pbIsStatus?
      @effects[PBEffects::TemporaryMoldBreaker]=true
    end
    # Roomba
    if isConst?(species,PBSpecies,:ROOMBA) &&  !@effects[PBEffects::Transform]
      if (isConst?(thismove.id,PBMoves,:MINDBOX)) && !isUltraBlue?(self)
        @battle.pbDisplay(_INTL("{1} is graduading back to its ultrastic form",pbThis))
        self.form+=3
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        PBDebug.log("[Form changed] #{pbThis} graduation started")
      end      
    end
    # Necrozma
    if !@effects[PBEffects::Transform] && (self.form==1 || self.form==2) &&
        isConst?(self.species,PBSpecies,:NECROZMA) && 
        isConst?(thismove.id,PBMoves,:PHOTONGEYSER)
        @effects[PBEffects::UBForm]=self.form
        @effects[PBEffects::UltraBurst]=2
        self.form=3
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} is ultra bursting",pbThis))
    end
    # Solgaleo
    if !@effects[PBEffects::Transform] && (self.form==0) &&
        isConst?(self.species,PBSpecies,:SOLGALEO) && 
        isConst?(thismove.id,PBMoves,:SUNSTEELSTRIKE)
        self.form=1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
    end
    # Lunala
    if !@effects[PBEffects::Transform] && (self.form==0) &&
        isConst?(self.species,PBSpecies,:LUNALA) && 
        isConst?(thismove.id,PBMoves,:MOONGEISTBEAM)
        self.form=1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
    end
    # Eternatus
    if !@effects[PBEffects::Transform] && (self.form==0) &&
        isConst?(self.species,PBSpecies,:ETERNATUS) && 
        isConst?(thismove.id,PBMoves,:ETERNABEAM)
      @effects[PBEffects::Eternamax]=3
      self.form=1
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL("{1} is eternamaxing",pbThis))
    end
    # Sensu Claw
    if hasWorkingItem(:SENSUCLAW) && thismove.pbIsDamaging?
      if pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBItems.getName(self.item))
        pbConsumeItem
      end
    end
    # End

    # "X used Y!" message
    case thismove.pbDisplayUseMessage(self)
    when 2   # Continuing Bide
      return
    when 1   # Starting Bide
      self.lastMoveUsed=thismove.id
      self.lastMoveUsedType=thismove.pbType(thismove.type,self,nil)
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=thismove.id
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2
      @battle.successStates[self.index].typemod=8
      return
    when -1   # Was hurt while readying Focus Punch, fails use
      self.lastMoveUsed=thismove.id
      self.lastMoveUsedType=thismove.pbType(thismove.type,self,nil)
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=thismove.id
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2 # somehow treated as a success
      @battle.successStates[self.index].typemod=8
      PBDebug.log("[Move failed] #{pbThis} was hurt while readying Focus Punch")
      return
    end
    # Find the user and target(s)
    targets=[]
    user=pbFindUser(choice,targets)
    # Change to two targets for expanding force with psychic terrain
    if thismove.function==0x305 && @battle.field.effects[PBEffects::PsychicTerrain]>0 && !user.isAirborne? && @battle.doublebattle 
      targets = [pbOpposing1, pbOpposing2] if (!pbOpposing1.isFainted? && !pbOpposing2.isFainted?)
    end
    # Battle Arena only - assume failure 
    @battle.successStates[user.index].useState=1
    @battle.successStates[user.index].typemod=8
    # Check whether Selfdestruct works
    if !thismove.pbOnStartUse(user) # Selfdestruct, Natural Gift, Beat Up can return false here
      PBDebug.log(sprintf("[Move failed] Failed pbOnStartUse (function code %02X)",thismove.function))
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
        user.lastRegularMoveUsed=thismove.id
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      return
    end
    if thismove.pbIsDamaging?
      # Environments
      env=pbGetEnvironment()
      if isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:SUN) && 
        env==PBEnvironment::Galaxy
        PBDebug.log("[Move failed] The Galaxy cancelled the Sun-type #{thismove.name}")
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("The Sun-type attack nullified out in the galaxy!"))
        user.lastMoveUsed=thismove.id
        user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
        if !turneffects[PBEffects::SpecialUsage]
          user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
          user.lastRegularMoveUsed=thismove.id
        end
        @battle.lastMoveUsed=thismove.id
        @battle.lastMoveUser=user.index
        return
      end
      # Primordial Sea, Desolate Land
      case @battle.pbWeather
      when PBWeather::HEAVYRAIN
        if isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:FIRE) && 
          !user.hasWorkingItem(:UTILITYUMBRELLA)
          PBDebug.log("[Move failed] Primordial Sea's rain cancelled the Fire-type #{thismove.name}")
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          user.lastMoveUsed=thismove.id
          user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
          if !turneffects[PBEffects::SpecialUsage]
            user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
            user.lastRegularMoveUsed=thismove.id
          end
          @battle.lastMoveUsed=thismove.id
          @battle.lastMoveUser=user.index
          return
        end
      when PBWeather::HARSHSUN
        if isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:WATER) &&
          !user.hasWorkingItem(:UTILITYUMBRELLA)
          PBDebug.log("[Move failed] Desolate Land's sun cancelled the Water-type #{thismove.name}")
					pbSEPlay("protection")
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          user.lastMoveUsed=thismove.id
          user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
          if !turneffects[PBEffects::SpecialUsage]
            user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
            user.lastRegularMoveUsed=thismove.id
          end
          @battle.lastMoveUsed=thismove.id
          @battle.lastMoveUser=user.index
          return
        end
      end
    end
    # Powder
    if user.effects[PBEffects::Powder] && isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:FIRE)
      PBDebug.log("[Lingering effect triggered] #{pbThis}'s Powder cancelled the Fire move")
      @battle.pbCommonAnimation("Powder",user,nil)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.pbReduceHP(1+(user.totalhp/4).floor) if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
        user.lastRegularMoveUsed=thismove.id
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      user.pbFaint if user.isFainted?
      pbEndTurn(choice)
      return
    end
    # Revelation Powder
    if user.pbOpposingSide.effects[PBEffects::RevelationPowder]>0 && isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:FIRE)
      PBDebug.log("[Lingering effect triggered] Revelation Powder cancelled the Fire move")
      @battle.pbCommonAnimation("Powder",user,nil)
      @battle.pbDisplay(_INTL("When the flame reached the revelation powder on the other side, it exploded!"))
      user.pbReduceHP(1+(user.totalhp/4).floor) if !(user.hasWorkingAbility(:MAGICGUARD) || user.hasWorkingAbility(:SUPERCLEARBODY))
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
        user.lastRegularMoveUsed=thismove.id
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      user.pbFaint if user.isFainted?
      pbEndTurn(choice)
      return
    end

    # Protean
    if user.hasWorkingAbility(:PROTEAN) &&
       thismove.function!=0xAE &&   # Mirror Move
       thismove.function!=0xAF &&   # Copycat
       thismove.function!=0xB0 &&   # Me First
       thismove.function!=0xB3 &&   # Nature Power
       thismove.function!=0xB4 &&   # Sleep Talk
       thismove.function!=0xB5 &&   # Assist
       thismove.function!=0xB6      # Metronome
      movetype=thismove.pbType(thismove.type,user,nil)
      if !user.pbHasType?(movetype)
        typename=PBTypes.getName(movetype)
        PBDebug.log("[Ability triggered] #{pbThis}'s Protean made it #{typename}-type")
        user.type1=movetype
        user.type2=movetype
        user.effects[PBEffects::Type3]=-1
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typename))  
      end
    end
    # Libero
    if user.hasWorkingAbility(:LIBERO) &&
       thismove.function!=0xAE &&   # Mirror Move
       thismove.function!=0xAF &&   # Copycat
       thismove.function!=0xB0 &&   # Me First
       thismove.function!=0xB3 &&   # Nature Power
       thismove.function!=0xB4 &&   # Sleep Talk
       thismove.function!=0xB5 &&   # Assist
       thismove.function!=0xB6      # Metronome
      movetype=thismove.pbType(thismove.type,user,nil)
      if !user.pbHasType?(movetype)
        typename=PBTypes.getName(movetype)
        PBDebug.log("[Ability triggered] #{pbThis}'s Libero made it #{typename}-type")
        user.type1=movetype
        user.type2=movetype
        user.effects[PBEffects::Type3]=-1
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typename))  
      end
    end
    # Try to use move against user if there aren't any targets
    if targets.length==0
      user=pbChangeUser(thismove,user)
      if thismove.target==PBTargets::SingleNonUser ||
         thismove.target==PBTargets::RandomOpposing ||
         thismove.target==PBTargets::AllOpposing ||
         thismove.target==PBTargets::AllNonUsers ||
         thismove.target==PBTargets::Partner ||
         thismove.target==PBTargets::UserOrPartner ||
         thismove.target==PBTargets::SingleOpposing ||
         thismove.target==PBTargets::OppositeOpposing
        @battle.pbDisplay(_INTL("But there was no target..."))
      else
        PBDebug.logonerr{
           ret=thismove.pbEffect(user,nil)
           user.effects[PBEffects::LastMoveFailed]=true if ret==-1 # changed for stomping tantrum
        }
      end
      if thismove
        pbDancerMoveCheck(thismove.id) if !danced      
      end
    else
      # We have targets
      showanimation=true
      alltargets=[]
      for i in 0...targets.length
        alltargets.push(targets[i].index) if !targets.include?(targets[i].index)
      end
      # For each target in turn
      i=0; loop do break if i>=targets.length
        # Get next target
        userandtarget=[user,targets[i]]
        success=pbChangeTarget(thismove,userandtarget,targets)
        user=userandtarget[0]
        target=userandtarget[1]
        if i==0 && thismove.target==PBTargets::AllOpposing 
          # Add target's partner to list of targets
          pbAddTarget(targets,target.pbPartner)
        end
        # If couldn't get the next target
        if !success
          i+=1
          next
        end
        # Get the number of hits
        numhits=thismove.pbNumHits(user)
        # Reset damage state, set Focus Band/Focus Sash to available
        target.damagestate.reset
        # Use move against the current target
        pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,false,alltargets,showanimation,danced)
        showanimation=false
        i+=1
      end
    end
    # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail, Red Card
    if !user.isFainted?
      switched=[]
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Roar]
          @battle.battlers[i].effects[PBEffects::Roar]=false
          @battle.battlers[i].effects[PBEffects::Uturn]=false
          next if @battle.battlers[i].isFainted?
          next if !@battle.pbCanSwitch?(i,-1,false)
          choices=[]
          party=@battle.pbParty(i)
          for j in 0...party.length
            choices.push(j) if @battle.pbCanSwitchLax?(i,j,false)
          end
          if choices.length>0
            newpoke=choices[@battle.pbRandom(choices.length)]
            newpokename=newpoke
            if isConst?(party[newpoke].ability,PBAbilities,:ILLUSION)
              newpokename=pbGetLastPokeInTeam(i)
            end
            switched.push(i)
            @battle.battlers[i].pbResetForm
            @battle.pbRecallAndReplace(i,newpoke,newpokename,false,user.hasMoldBreaker)
            @battle.pbDisplay(_INTL("{1} was dragged out!",@battle.battlers[i].pbThis))
            @battle.choices[i]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
          end
        end
      end
      for i in @battle.pbPriority
        next if !switched.include?(i.index)
        i.pbAbilitiesOnSwitchIn(true)
      end
    end
    # Pokémon switching caused by U-Turn, Volt Switch, Eject Button
    switched=[]
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::Uturn]
        @battle.battlers[i].effects[PBEffects::Uturn]=false
        @battle.battlers[i].effects[PBEffects::Roar]=false
        if !@battle.battlers[i].isFainted? && @battle.pbCanChooseNonActive?(i) &&
           !@battle.pbAllFainted?(@battle.pbOpposingParty(i))
          # TODO: Pursuit should go here, and negate this effect if it KO's attacker
          @battle.pbDisplay(_INTL("{1} went back to {2}!",@battle.battlers[i].pbThis,@battle.pbGetOwner(i).name))
          newpoke=0
          newpoke=@battle.pbSwitchInBetween(i,true,false)
          newpokename=newpoke
          if isConst?(@battle.pbParty(i)[newpoke].ability,PBAbilities,:ILLUSION)
            newpokename=pbGetLastPokeInTeam(i)
          end
          switched.push(i)
          @battle.battlers[i].pbResetForm
          @battle.pbRecallAndReplace(i,newpoke,newpokename,@battle.battlers[i].effects[PBEffects::BatonPass])
          @battle.choices[i]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
        end
      end
    end
    for i in @battle.pbPriority
      next if !switched.include?(i.index)
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Baton Pass
    if user.effects[PBEffects::BatonPass]
      user.effects[PBEffects::BatonPass]=false
      if !user.isFainted? && @battle.pbCanChooseNonActive?(user.index) &&
         !@battle.pbAllFainted?(@battle.pbParty(user.index))
        newpoke=0
        newpoke=@battle.pbSwitchInBetween(user.index,true,false)
        newpokename=newpoke
        if isConst?(@battle.pbParty(user.index)[newpoke].ability,PBAbilities,:ILLUSION)
          newpokename=pbGetLastPokeInTeam(user.index)
        end
        user.pbResetForm
        @battle.pbRecallAndReplace(user.index,newpoke,newpokename,true)
        @battle.choices[user.index]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
        user.pbAbilitiesOnSwitchIn(true)
      end
    end
    # Record move as having been used
    user.lastMoveUsed=thismove.id
    user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
    if !turneffects[PBEffects::SpecialUsage]
      user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
      user.lastRegularMoveUsed=thismove.id
      user.movesUsed.push(thismove.id) if !user.movesUsed.include?(thismove.id) # For Last Resort
    end
    @battle.lastMoveUsed=thismove.id
    @battle.lastMoveUser=user.index
    # Gain Exp
    @battle.pbGainEXP
    # Battle Arena only - update skills
    for i in 0...4
      @battle.successStates[i].updateSkill
    end
    # End of move usage
    pbEndTurn(choice)
    @battle.pbJudge #    @battle.pbSwitch
    return
  end

  def pbCancelMoves
    # If failed pbTryUseMove or have already used Pursuit to chase a switching foe
    # Cancel multi-turn attacks (note: Hyper Beam effect is not canceled here)
    @effects[PBEffects::TwoTurnAttack]=0 if @effects[PBEffects::TwoTurnAttack]>0
    @effects[PBEffects::Outrage]=0
    @effects[PBEffects::Rollout]=0
    @effects[PBEffects::Uproar]=0
    @effects[PBEffects::Bide]=0
    @currentMove=0
    # Reset counters for moves which increase them when used in succession
    @effects[PBEffects::FuryCutter]=0
    PBDebug.log("Cancelled using the move")
  end

################################################################################
# Turn processing
################################################################################
  def pbBeginTurn(choice)
    # Cancel some lingering effects which only apply until the user next moves
    @effects[PBEffects::DestinyBond]=false
    @effects[PBEffects::Brainymedia]=false
    @effects[PBEffects::Grudge]=false
    # Reset Parental Bond's count
    @effects[PBEffects::ParentalBond]=0
    # Encore's effect ends if the encored move is no longer available
    if @effects[PBEffects::Encore]>0 &&
       @moves[@effects[PBEffects::EncoreIndex]].id!=@effects[PBEffects::EncoreMove]
      PBDebug.log("Resetting Encore effect")
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::EncoreMove]=0
    end
    # Wake up in an uproar
    if self.status==PBStatuses::SLEEP && !self.hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          pbCureStatus(false)
          @battle.pbDisplay(_INTL("{1} woke up in the uproar!",pbThis))
        end
      end
    end
  end

  def pbEndTurn(choice)
    # True end(?)
    if @effects[PBEffects::ChoiceBand]<0 && @lastMoveUsed>=0 && !self.isFainted? && 
       (self.hasWorkingItem(:CHOICEBAND) ||
       self.hasWorkingItem(:CHOICESPECS) ||
       self.hasWorkingItem(:CHOICESCARF))
      @effects[PBEffects::ChoiceBand]=@lastMoveUsed
    end
    @battle.pbPrimordialWeather
    for i in 0...4
      @battle.battlers[i].pbBerryCureCheck
    end
    for i in 0...4
      @battle.battlers[i].pbAbilityCureCheck
    end
    for i in 0...4
      @battle.battlers[i].pbAbilitiesOnSwitchIn(false)
    end
    for i in 0...4
      @battle.battlers[i].pbCheckForm
    end
  end

  def pbProcessTurn(choice)
    # Can't use a move if fainted
    return false if self.isFainted?
    # Wild roaming Pokémon always flee if possible
    if !@battle.opponent && @battle.pbIsOpposing?(self.index) &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index)
      pbBeginTurn(choice)
      @battle.pbDisplay(_INTL("{1} fled!",self.pbThis))
      @battle.decision=3
      pbEndTurn(choice)
      PBDebug.log("[Escape] #{pbThis} fled")
      return true
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0]!=1
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    # Turn is skipped if Pursuit, Douze Crayon or Salazire was used during switch
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit]=false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge #      @battle.pbSwitch
      return false
    end
    # Use the move
#   @battle.pbDisplayPaused("Before: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
    PBDebug.log("#{pbThis} used #{choice[2].name}")
    PBDebug.logonerr{
       pbUseMove(choice,choice[2]==@battle.struggle)
    }
#   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
    return true
  end
end