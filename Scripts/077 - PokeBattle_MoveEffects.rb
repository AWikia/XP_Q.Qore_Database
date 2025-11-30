################################################################################
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Non-damaging moves always fail.
################################################################################
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    else
			pbPlayMissSE()
      @battle.pbDisplay("But it failed!")
      return -1
    end
  end
end



################################################################################
# Superclass for a failed move. Always fails.
# This class is unused.
################################################################################
class PokeBattle_FailedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		pbPlayMissSE()
    @battle.pbDisplay("But it failed!")
    return -1
  end
end



################################################################################
# Pseudomove for confusion damage.
################################################################################
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @basedamage = 40
    @type       = -1
    @accuracy   = 100
    @pp         = -1
    @addlEffect = 0
    @target     = 0
    @priority   = 0
    @flags      = 0
    @thismove   = move
    @name       = ""
    @id         = 0
  end

  def pbIsPhysical?(type); return true; end
  def pbIsSpecial?(type); return false; end
  def pbIsElderSpecial?; return false; end

  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,
       PokeBattle_Move::NOCRITICAL|PokeBattle_Move::SELFCONFUSE|PokeBattle_Move::NOTYPE|PokeBattle_Move::NOWEIGHTING)
  end

  def pbEffectMessages(attacker,opponent,ignoretype=false)
    return super(attacker,opponent,true)
  end
end



################################################################################
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
################################################################################
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move)
    @id         = -1    # doesn't work if 0
    @battle     = battle
    @name       = _INTL("Struggle")
    @basedamage = 50
    @type       = -1
    @accuracy   = 0
    @addlEffect = 0
    @target     = 0
    @priority   = 0
    @flags      = 0
    @thismove   = nil   # not associated with a move
    @pp         = -1
    @totalpp    = 0
    if move
      @id = move.id
      @name = PBMoves.getName(id)
    end
  end

  def pbIsPhysical?(type); return true; end
  def pbIsSpecial?(type); return false; end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      attacker.pbReduceHP((attacker.totalhp/4.0).round)
      attacker.changeRecoilDamage((attacker.totalhp/4.0).round)
      @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
    end
  end

  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,PokeBattle_Move::IGNOREPKMNTYPES)
  end
end



################################################################################
# No additional effect.
################################################################################
class PokeBattle_Move_000 < PokeBattle_Move
end



################################################################################
# Does absolutely nothing. (Splash)
################################################################################
class PokeBattle_Move_001 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("But nothing happened!"))
    return 0
  end
end



################################################################################
# Struggle. Overrides the default Struggle effect above.
################################################################################
class PokeBattle_Move_002 < PokeBattle_Struggle
end



################################################################################
# Puts the target to sleep.
################################################################################
class PokeBattle_Move_003 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.pbCanSleep?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbSleep
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanSleep?(attacker,false,self)
      opponent.pbSleep
    end
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if isConst?(@id,PBMoves,:RELICSONG)
      if isConst?(attacker.species,PBSpecies,:MELOETTA) &&
         !attacker.effects[PBEffects::Transform] &&
         !(attacker.hasWorkingAbility(:SHEERFORCE) && self.addlEffect>0) &&
         !attacker.isFainted?
        attacker.form=(attacker.form+1)%2
        attacker.pbUpdate(true)
        @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
        @battle.pbDisplay(_INTL("{1} transformed!",attacker.pbThis))
        PBDebug.log("[Form changed] #{attacker.pbThis} changed to form #{attacker.form}")
      end
    end
  end
end



################################################################################
# Makes the target drowsy; it will fall asleep at the end of the next turn. (Yawn)
################################################################################
class PokeBattle_Move_004 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanSleep?(attacker,true,self)
    if opponent.effects[PBEffects::Yawn]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Yawn]=2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Poisons the target.
# Barb Barrage: Power is doubled if the target has a status condition
################################################################################
class PokeBattle_Move_005 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if (isConst?(@id,PBMoves,:BARBBARRAGE) && 
        opponent.status!=0)
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanPoison?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanPoison?(attacker,false,self)
      opponent.pbPoison(attacker)
    end
  end
end



################################################################################
# Badly poisons the target. (Poison Fang, Toxic)
# (Handled in Battler's pbSuccessCheck): Hits semi-invulnerable targets if user
# is Poison-type and move is status move.
################################################################################
class PokeBattle_Move_006 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanPoison?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker,nil,true)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanPoison?(attacker,false,self)
      opponent.pbPoison(attacker,nil,true)
    end
  end
end



################################################################################
# Paralyzes the target.
# Thunder Wave: Doesn't affect target if move's type has no effect on it.
# Bolt Strike: Powers up the next Fusion Flare used this round.
# Body Slam: Does double damage and has perfect accuracy if the target is 
# Minimized. from Gen6+
# Transistor: Power is doubled if a Pokemon has the corresponding ability
################################################################################
class PokeBattle_Move_007 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:TRANSISTOR) && 
       @battle.pbCheckGlobalAbility(:TRANSISTOR)
      return (damagemult*2.0).round
    end
    return damagemult
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && isConst?(@id,PBMoves,:BOLTSTRIKE)
        @battle.field.effects[PBEffects::FusionFlare]=true
      end
      return ret
    else
      if isConst?(@id,PBMoves,:THUNDERWAVE)
        if pbTypeModifier(type,attacker,opponent)==0
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
          return -1
        end
      end
      return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
      return -1 if !opponent.pbCanParalyze?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbParalyze(attacker)
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end

  def tramplesMinimize?(param=1)
    return false if !isConst?(@id,PBMoves,:BODYSLAM)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Paralyzes the target. Accuracy perfect in rain, 50% in sunshine. (Thunder)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_008 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      case @battle.pbWeather
      when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
        return 0
      when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
        return 50
      end
      return baseaccuracy
    else
      return baseaccuracy
    end
  end
end



################################################################################
# Paralyzes the target. May cause the target to flinch. (Thunder Fang)
################################################################################
class PokeBattle_Move_009 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Burns the target.
# Blue Flare: Powers up the next Fusion Bolt used this round.
# Dragon's Maw: Power is doubled if a Pokemon has the corresponding ability
# Infernal Parade: Power is doubled if the target has a status condition
################################################################################
class PokeBattle_Move_00A < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if (isConst?(@id,PBMoves,:DRAGONSMAW) && 
       @battle.pbCheckGlobalAbility(:DRAGONSMAW)) ||
       (isConst?(@id,PBMoves,:INFERNALPARADE) && 
        opponent.status!=0)
      return (damagemult*2.0).round
    end
    return damagemult
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && isConst?(@id,PBMoves,:BLUEFLARE)
        @battle.field.effects[PBEffects::FusionBolt]=true
      end
      return ret
    else
      return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
      return -1 if !opponent.pbCanBurn?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbBurn(attacker)
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanBurn?(attacker,false,self)
      opponent.pbBurn(attacker)
    end
  end
end



################################################################################
# Burns the target. May cause the target to flinch. (Fire Fang)
################################################################################
class PokeBattle_Move_00B < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Freezes the target.
# Bitter Malice: Power is doubled if the target has a status condition
################################################################################
class PokeBattle_Move_00C < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if (isConst?(@id,PBMoves,:BITTERMALICE) && 
        opponent.status!=0)
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanFreeze?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
    end
  end
end



################################################################################
# Freezes the target. Accuracy perfect in hail. (Blizzard)
################################################################################
class PokeBattle_Move_00D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanFreeze?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
    end
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if @battle.pbWeather==PBWeather::HAIL
      return 0
    end
    return baseaccuracy
  end
end



################################################################################
# Freezes the target. May cause the target to flinch. (Ice Fang)
################################################################################
class PokeBattle_Move_00E < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Causes the target to flinch.
################################################################################
class PokeBattle_Move_00F < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Causes the target to flinch. Does double damage and has perfect accuracy if
# the target is Minimized.
################################################################################
class PokeBattle_Move_010 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end

  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Causes the target to flinch. Fails if the user is not asleep. (Snore)
################################################################################
class PokeBattle_Move_011 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.status!=PBStatuses::SLEEP)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Causes the target to flinch. Fails if this isn't the user's first turn. (Fake Out)
################################################################################
class PokeBattle_Move_012 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount>1)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Confuses the target.
################################################################################
class PokeBattle_Move_013 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if opponent.pbCanConfuse?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
    end
  end
end



################################################################################
# Confuses the target. Chance of causing confusion depends on the cry's volume.
# Confusion chance is 0% if user doesn't have a recorded cry. (Chatter)
# TODO: Play the actual chatter cry as part of the move animation
#       @battle.scene.pbChatter(attacker,opponent) # Just plays cry
################################################################################
class PokeBattle_Move_014 < PokeBattle_Move
  def addlEffect
    return 100
  #  if attacker.pokemon && attacker.pokemon.chatter
  #    return attacker.pokemon.chatter.intensity*10/127
  #  end
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
    end
  end
end



################################################################################
# Confuses the target. Accuracy perfect in rain, 50% in sunshine. (Hurricane)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_015 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if opponent.pbCanConfuse?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
    end
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      case @battle.pbWeather
      when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
        return 0
      when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
        return 50
      end
      return baseaccuracy
    else
      return baseaccuracy
    end
  end
end



################################################################################
# Attracts the target. (Attract)
################################################################################
class PokeBattle_Move_016 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanAttract?(attacker)
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      elsif (opponent.pbHasType?(:SHARPENER) && !attacker.hasWorkingAbility(:ANTISHARPNESS)) || 
        opponent.pbHasType?(:HERB) || opponent.pbHasType?(:MIND) || 
        opponent.pbHasType?(:GLIMSE)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbAttract(attacker)
    return 0
  end
end



################################################################################
# Burns, freezes or paralyzes the target. (Tri Attack)
################################################################################
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    case @battle.pbRandom(3)
    when 0
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
      end
    when 1
      if opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
      end
    when 2
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
      end
    end
  end
end



################################################################################
# Cures user of burn, poison and paralysis. (Refresh)
################################################################################
class PokeBattle_Move_018 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::BURN &&
       attacker.status!=PBStatuses::POISON &&
       attacker.status!=PBStatuses::PARALYSIS
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      t=attacker.status
      attacker.pbCureStatus(false)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if t==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} healed its burn!",attacker.pbThis))  
      elsif t==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} cured its poisoning!",attacker.pbThis))  
      elsif t==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} cured its paralysis!",attacker.pbThis))  
      end
      return 0
    end
  end
end



################################################################################
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
################################################################################
class PokeBattle_Move_019 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if isConst?(@id,PBMoves,:AROMATHERAPY)
      @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
    else
      @battle.pbDisplay(_INTL("A bell chimed!"))
    end
    activepkmn=[]
    for i in @battle.battlers
      next if attacker.pbIsOpposing?(i.index) || i.isFainted?
      activepkmn.push(i.pokemonIndex)
      next if i.index!=attacker.index && 
         pbTypeImmunityByAbility(pbType(@type,attacker,i),attacker,i)
      case i.status
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.",i.pbThis))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1}'s sleep was woken.",i.pbThis))
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",i.pbThis))
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.",i.pbThis))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.",i.pbThis))
      end
      i.pbCureStatus(false)
    end
    party=@battle.pbParty(attacker.index) # NOTE: Considers both parties in multi battles
    for i in 0...party.length
      next if activepkmn.include?(i)
      next if !party[i] || party[i].isEgg? || party[i].hp<=0
      case party[i].status
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.",party[i].name))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from its sleep.",party[i].name))
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",party[i].name))
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.",party[i].name))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.",party[i].name))
      end
      party[i].status=0
      party[i].statusCount=0
    end
    return 0
  end
end



################################################################################
# Safeguards the user's side from being inflicted with status problems. (Safeguard)
################################################################################
class PokeBattle_Move_01A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Safeguard]=5
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became cloaked in a mystical veil!"))
    else
      @battle.pbDisplay(_INTL("The opposing team became cloaked in a mystical veil!"))
    end
    return 0
  end
end



################################################################################
# User passes its status problem to the target. (Psycho Shift, Herb Lobby)
################################################################################
class PokeBattle_Move_01B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status==0 ||
      (attacker.status==PBStatuses::PARALYSIS && !opponent.pbCanParalyze?(attacker,false,self)) ||
      (attacker.status==PBStatuses::SLEEP && !opponent.pbCanSleep?(attacker,false,self)) ||
      (attacker.status==PBStatuses::POISON && !opponent.pbCanPoison?(attacker,false,self)) ||
      (attacker.status==PBStatuses::BURN && !opponent.pbCanBurn?(attacker,false,self)) ||
      (attacker.status==PBStatuses::FROZEN && !opponent.pbCanFreeze?(attacker,false,self))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    case attacker.status
    when PBStatuses::PARALYSIS
      opponent.pbParalyze(attacker)
      opponent.pbAbilityCureCheck
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",attacker.pbThis))
    when PBStatuses::SLEEP
      opponent.pbSleep
      opponent.pbAbilityCureCheck
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} woke up.",attacker.pbThis))
    when PBStatuses::POISON
      opponent.pbPoison(attacker,nil,attacker.statusCount!=0)
      opponent.pbAbilityCureCheck
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
    when PBStatuses::BURN
      opponent.pbBurn(attacker)
      opponent.pbAbilityCureCheck
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",attacker.pbThis))
    when PBStatuses::FROZEN
      opponent.pbFreeze
      opponent.pbAbilityCureCheck
      attacker.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was thawed out.",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack by 1 stage.
################################################################################
class PokeBattle_Move_01C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Defense by 1 stage.
# Diffindo: Power is doubled if user's friendship is high and is halved during
#           Psychic Terrain (Gen 7+)
################################################################################
class PokeBattle_Move_01D < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:DIFFINDO) &&
        @battle.pbTerrain==PBBattleTerrains::PSYCHIC && 
        attacker.happiness<220
      return (damagemult*0.5).round
    end
    if isConst?(@id,PBMoves,:DIFFINDO) &&
        attacker.happiness>219 && @battle.pbTerrain!=PBBattleTerrains::PSYCHIC
      return (damagemult*2.0).round
    end
    return damagemult
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Defense by 1 stage. User curls up. (Defense Curl)
################################################################################
class PokeBattle_Move_01E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::DefenseCurl]=true
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self)
    return ret ? 0 : -1
  end
end



################################################################################
# Increases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_01F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_020 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Special Defense by 1 stage.
# Charges up user's next attack if it is Electric-type. (Charge)
################################################################################
class PokeBattle_Move_021 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::Charge]=2
    @battle.pbDisplay(_INTL("{1} began charging power!",attacker.pbThis))
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self)
    end
    return 0
  end
end



################################################################################
# Increases the user's evasion by 1 stage.
################################################################################
class PokeBattle_Move_022 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::EVASION,1,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's critical hit rate. (Focus Energy)
################################################################################
class PokeBattle_Move_023 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if attacker.effects[PBEffects::FocusEnergy]>=2
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::FocusEnergy]=2
    @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.effects[PBEffects::FocusEnergy]<2
      attacker.effects[PBEffects::FocusEnergy]=2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    end
  end
end



################################################################################
# Increases the user's Attack and Defense by 1 stage each. (Bulk Up)
################################################################################
class PokeBattle_Move_024 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense and accuracy by 1 stage each. (Coil)
################################################################################
class PokeBattle_Move_025 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ACCURACY,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Speed by 1 stage each. (Dragon Dance)
################################################################################
class PokeBattle_Move_026 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Special Attack by 1 stage each. (Work Up)
################################################################################
class PokeBattle_Move_027 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
  end

end



################################################################################
# Increases the user's Attack and Sp. Attack by 1 stage each.
# In sunny weather, increase is 2 stages each instead. (Growth)
################################################################################
class PokeBattle_Move_028 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    increment=1
    if @battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      increment=2
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,increment,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,increment,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and accuracy by 1 stage each. (Hone Claws)
################################################################################
class PokeBattle_Move_029 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ACCURACY,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Defense and Special Defense by 1 stage each. (Cosmic Power)
################################################################################
class PokeBattle_Move_02A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
  end

end



################################################################################
# Increases the user's Sp. Attack, Sp. Defense and Speed by 1 stage each. (Quiver Dance)
################################################################################
class PokeBattle_Move_02B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Sp. Attack and Sp. Defense by 1 stage each. (Calm Mind)
################################################################################
class PokeBattle_Move_02C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (AncientPower, Ominous Wind, Silver Wind)
################################################################################
class PokeBattle_Move_02D < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
    end
    return true
  end
end




################################################################################
# Increases the user's Attack by 2 stages.
################################################################################
class PokeBattle_Move_02E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Defense by 2 stages.
################################################################################
class PokeBattle_Move_02F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Speed by 2 stages.
################################################################################
class PokeBattle_Move_030 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Speed by 2 stages. Lowers user's weight by 100kg. (Autotomize)
################################################################################
class PokeBattle_Move_031 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self)
    if ret
      attacker.effects[PBEffects::WeightChange]-=1000
      @battle.pbDisplay(_INTL("{1} became nimble!",attacker.pbThis))
    end
    return ret ? 0 : -1
  end
end



################################################################################
# Increases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_032 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_033 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's evasion by 2 stages. Minimizes the user. (Minimize)
################################################################################
class PokeBattle_Move_034 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    attacker.effects[PBEffects::Minimize]=true
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    attacker.effects[PBEffects::Minimize]=true
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::EVASION,2,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each. (Shell Smash)
# Increases the user's Attack, Speed and Special Attack by 2 stages each.
################################################################################
class PokeBattle_Move_035 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbReduceStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Speed by 2 stages, and its Attack by 1 stage. (Shift Gear)
################################################################################
class PokeBattle_Move_036 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases one random stat of the user by 2 stages (except HP). (Acupressure)
################################################################################
class PokeBattle_Move_037 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index 
      if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
         @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanIncreaseStatStage?(i,attacker,false,self)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbIncreaseStat(stat,2,attacker,false,self)
    return 0
  end
end



################################################################################
# Increases the user's Defense by 3 stages.
################################################################################
class PokeBattle_Move_038 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,3,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,attacker,false,self)
    end
  end
end



################################################################################
# Increases the user's Special Attack by 3 stages.
################################################################################
class PokeBattle_Move_039 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,3,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,3,attacker,false,self)
    end
  end
end



################################################################################
# Reduces the user's HP by half of max, and sets its Attack to maximum. (Belly Drum)
################################################################################
class PokeBattle_Move_03A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp<=(attacker.totalhp/2).floor ||
       !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbReduceHP((attacker.totalhp/2).floor)
    if attacker.hasWorkingAbility(:CONTRARY)
      attacker.stages[PBStats::ATTACK]=-6
      @battle.pbCommonAnimation("StatDown",attacker,nil)
      @battle.pbDisplay(_INTL("{1} cut its own HP and minimized its Attack!",attacker.pbThis))
    else
      attacker.stages[PBStats::ATTACK]=6
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Decreases the user's Attack and Defense by 1 stage each. (Superpower)
################################################################################
class PokeBattle_Move_03B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      showanim='mix' # Was true
      if attacker.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
        attacker.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each. (Close Combat)
################################################################################
class PokeBattle_Move_03C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      showanim='mix' # Was true
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPDEF,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense, Special Defense and Speed by 1 stage each.
# User's ally loses 1/16 of its total HP. (V-create)
################################################################################
class PokeBattle_Move_03D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbPartner && !attacker.pbPartner.isFainted?
        attacker.pbPartner.pbReduceHP((attacker.pbPartner.totalhp/16).floor,true)
      end
      showanim='mix' # Was true
      if attacker.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPEED,1,attacker,false,self,showanim)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPDEF,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_03E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_03F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPATK,2,attacker,false,self)
      end
    end
    return ret
  end
end



################################################################################
# Increases the target's Special Attack by 1 stage. Confuses the target. (Flatter)
################################################################################
class PokeBattle_Move_040 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
      ret=0
    end
    if opponent.pbCanConfuse?(attacker,true,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Increases the target's Attack by 2 stages. Confuses the target. (Swagger)
################################################################################
class PokeBattle_Move_041 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self)
      ret=0
    end
    if opponent.pbCanConfuse?(attacker,true,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack by 1 stage.
################################################################################
class PokeBattle_Move_042 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Defense by 1 stage.
################################################################################
class PokeBattle_Move_043 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Speed by 1 stage.
# Bulldoze and Fortune Terrain: Power is halved during Grassy Terrain
# Doom Croket: Power is doubled if user's friendship is high (Gen 7+)
################################################################################
class PokeBattle_Move_044 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCFanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    end
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:DOOMCROKET) &&
        attacker.happiness>=220
      return (damagemult*2.0).round
    end
    if (isConst?(@id,PBMoves,:BULLDOZE) || isConst?(@id,PBMoves,:FORTUNETERRAIN)) &&
       @battle.pbTerrain==PBBattleTerrains::GRASSY
      return (damagemult/2.0).round
    end
    return damagemult
  end
end



################################################################################
# Decreases the target's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_045 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Special Defense by 1 stage.
################################################################################
class PokeBattle_Move_046 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPDEF,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's accuracy by 1 stage.
################################################################################
class PokeBattle_Move_047 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's evasion by 2 stages. (Sweet Scent)
################################################################################
class PokeBattle_Move_048 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    increment= 2
    ret=opponent.pbReduceStat(PBStats::EVASION,increment,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
      increment=2
      opponent.pbReduceStat(PBStats::EVASION,increment,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's evasion by 1 stage. Ends all barriers, entry
# hazards on both sides and Terrains. (Defog)
################################################################################
class PokeBattle_Move_049 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbReduceStat(PBStats::EVASION,1,attacker,false,self)
    # Target's Side
    opponent.pbOwnSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOwnSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOwnSide.effects[PBEffects::AuroraVeil]  = 0 # changed
    opponent.pbOwnSide.effects[PBEffects::Mist]        = 0
    opponent.pbOwnSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOwnSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOwnSide.effects[PBEffects::StealthRock] = false
    opponent.pbOwnSide.effects[PBEffects::StickyWeb]   = false
    opponent.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
    # Own Side
    opponent.pbOpposingSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOpposingSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOpposingSide.effects[PBEffects::AuroraVeil]  = 0 # changed
    opponent.pbOpposingSide.effects[PBEffects::Mist]        = 0
    opponent.pbOpposingSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOpposingSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOpposingSide.effects[PBEffects::StealthRock] = false
    opponent.pbOpposingSide.effects[PBEffects::StickyWeb]   = false
    opponent.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
    # Terrains
    @battle.terrain=0
    @battle.terrainduration=0
    @battle.field.effects[PBEffects::GlimmyGalaxy]=0
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.damagestate.substitute
      if opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
        opponent.pbReduceStat(PBStats::EVASION,1,attacker,false,self)
      end
    end
    # Target's Side
    opponent.pbOwnSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOwnSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOwnSide.effects[PBEffects::Mist]        = 0
    opponent.pbOwnSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOwnSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOwnSide.effects[PBEffects::StealthRock] = false
    opponent.pbOwnSide.effects[PBEffects::StickyWeb]   = false
    opponent.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
    # Own Side
    opponent.pbOpposingSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOpposingSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOpposingSide.effects[PBEffects::Mist]        = 0
    opponent.pbOpposingSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOpposingSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOpposingSide.effects[PBEffects::StealthRock] = false
    opponent.pbOpposingSide.effects[PBEffects::StickyWeb]   = false
    opponent.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
    # Terrains
    @battle.terrain=0
    @battle.terrainduration=0
    @battle.field.effects[PBEffects::GlimmyGalaxy]=0
  end
end



################################################################################
# Decreases the target's Attack and Defense by 1 stage each. (Tickle)
################################################################################
class PokeBattle_Move_04A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Decreases the target's Attack by 2 stages.
################################################################################
class PokeBattle_Move_04B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,2,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Defense by 2 stages. (Screech)
################################################################################
class PokeBattle_Move_04C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,2,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Speed by 2 stages. (Cotton Spore, Scary Face, String Shot)
################################################################################
class PokeBattle_Move_04D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    increment=2
    ret=opponent.pbReduceStat(PBStats::SPEED,increment,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      increment=2
      opponent.pbReduceStat(PBStats::SPEED,increment,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Special Attack by 2 stages. Only works on the opposite
# gender. (Captivate)
################################################################################
class PokeBattle_Move_04E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    if attacker.gender==2 || opponent.gender==2 || attacker.gender==opponent.gender ||
    (opponent.pbHasType?(:SHARPENER) && !attacker.hasWorkingAbility(:ANTISHARPNESS))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if attacker.gender!=2 && opponent.gender!=2 && attacker.gender!=opponent.gender
      if attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:OBLIVIOUS) ||
      !opponent.pbHasType?(:SHARPENER) || attacker.hasWorkingAbility(:ANTISHARPNESS)
        if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
          opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self)
        end
      end
    end
  end
end



################################################################################
# Decreases the target's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_04F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPDEF,2,attacker,false,self)
    end
  end
end



################################################################################
# Resets all target's stat stages to 0. (Clear Smog)
################################################################################
class PokeBattle_Move_050 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      opponent.stages[PBStats::ATTACK]   = 0
      opponent.stages[PBStats::DEFENSE]  = 0
      opponent.stages[PBStats::SPEED]    = 0
      opponent.stages[PBStats::SPATK]    = 0
      opponent.stages[PBStats::SPDEF]    = 0
      opponent.stages[PBStats::ACCURACY] = 0
      opponent.stages[PBStats::EVASION]  = 0
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",opponent.pbThis))
    end
    return ret
  end
end



################################################################################
# Resets all stat stages for all battlers to 0. (Haze)
# Mariamara: Does not affect Doom-type Pokemon
# Herbal Start Fails if this isn't the user's first turn.
################################################################################
class PokeBattle_Move_051 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount>1) && isConst?(@id,PBMoves,:HERBALSTART)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in 0...4
      next if isConst?(@id,PBMoves,:MARIAMARA) && i.pbHasType?(:DOOM)
      @battle.battlers[i].stages[PBStats::ATTACK]   = 0
      @battle.battlers[i].stages[PBStats::DEFENSE]  = 0
      @battle.battlers[i].stages[PBStats::SPEED]    = 0
      @battle.battlers[i].stages[PBStats::SPATK]    = 0
      @battle.battlers[i].stages[PBStats::SPDEF]    = 0
      @battle.battlers[i].stages[PBStats::ACCURACY] = 0
      @battle.battlers[i].stages[PBStats::EVASION]  = 0
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    return 0
  end
end



################################################################################
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
################################################################################
class PokeBattle_Move_052 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::ATTACK],ostage[PBStats::ATTACK]=ostage[PBStats::ATTACK],astage[PBStats::ATTACK]
    astage[PBStats::SPATK],ostage[PBStats::SPATK]=ostage[PBStats::SPATK],astage[PBStats::SPATK]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
################################################################################
class PokeBattle_Move_053 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::DEFENSE],ostage[PBStats::DEFENSE]=ostage[PBStats::DEFENSE],astage[PBStats::DEFENSE]
    astage[PBStats::SPDEF],ostage[PBStats::SPDEF]=ostage[PBStats::SPDEF],astage[PBStats::SPDEF]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User and target swap all their stat stages. (Heart Swap)
################################################################################
class PokeBattle_Move_054 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i],opponent.stages[i]=opponent.stages[i],attacker.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User copies the target's stat stages. (Psych Up)
################################################################################
class PokeBattle_Move_055 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i]=opponent.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes. (Mist)
################################################################################
class PokeBattle_Move_056 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Mist]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Mist]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      @battle.pbDisplay(_INTL("The opposing team became shrouded in mist!"))
    end
    return 0
  end
end



################################################################################
# Swaps the user's Attack and Defense stats. (Power Trick)
################################################################################
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.attack,attacker.defense=attacker.defense,attacker.attack
    attacker.effects[PBEffects::PowerTrick]=!attacker.effects[PBEffects::PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Attack.
# Averages the user's and target's Special Attack. (Power Split)
################################################################################
class PokeBattle_Move_058 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avatk=((attacker.attack+opponent.attack)/2).floor
    avspatk=((attacker.spatk+opponent.spatk)/2).floor
    attacker.attack=opponent.attack=avatk
    attacker.spatk=opponent.spatk=avspatk
    @battle.pbDisplay(_INTL("{1} shared its power with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Defense.
# Averages the user's and target's Special Defense. (Guard Split)
################################################################################
class PokeBattle_Move_059 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avdef=((attacker.defense+opponent.defense)/2).floor
    avspdef=((attacker.spdef+opponent.spdef)/2).floor
    attacker.defense=opponent.defense=avdef
    attacker.spdef=opponent.spdef=avspdef
    @battle.pbDisplay(_INTL("{1} shared its guard with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's current HP. (Pain Split)
################################################################################
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    olda=attacker.hp
    oldo=opponent.hp
    avhp=((attacker.hp+opponent.hp)/2).floor
    attacker.hp=[avhp,attacker.totalhp].min
    opponent.hp=[avhp,opponent.totalhp].min
    @battle.scene.pbHPChanged(attacker,olda)
    @battle.scene.pbHPChanged(opponent,oldo)
    @battle.pbCheckDanger
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    return 0
  end
end



################################################################################
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
################################################################################
class PokeBattle_Move_05B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Tailwind]=4
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The tailwind blew from behind your team!"))
    else
      @battle.pbDisplay(_INTL("The tailwind blew from behind the opposing team!"))
    end
    return 0
  end
end



################################################################################
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
################################################################################
class PokeBattle_Move_05C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x14,   # Chatter
       0x5C,   # Mimic
       0x5D,   # Sketch
       0xB6,   # Metronome
       0x172,  # Κουλούνδιν
       0x187,  # Douze Crayon
       0x325   # Elder Special Moves
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsed<=0 ||
       isConst?(PBMoveData.new(opponent.lastMoveUsed).type,PBTypes,:SHADOW) ||
       isConst?(PBMoveData.new(opponent.lastMoveUsed).type,PBTypes,:ROBOT) ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsed
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsed)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove)
        movename=PBMoves.getName(opponent.lastMoveUsed)
        $PokemonGlobal.pokebox[42]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.pbDisplay(_INTL("{1} learned {2}!",attacker.pbThis,movename))
        return 0
      end
    end
			pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# This move permanently turns into the last move used by the target. (Sketch)
################################################################################
class PokeBattle_Move_05D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x14,   # Chatter
       0x5D,   # Sketch
       0x13B,  # Hyperscare Fury
       0x172,  # Κουλούνδιν
       0x325,  # Elder Special Moves
       0x362,  # Revival Blessing
       0x379   # Tera Starstorm
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsedSketch<=0 ||
       isConst?(PBMoveData.new(opponent.lastMoveUsedSketch).type,PBTypes,:SHADOW) ||
       isConst?(PBMoveData.new(opponent.lastMoveUsedSketch).type,PBTypes,:ROBOT) ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsedSketch).function)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsedSketch
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsedSketch)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove)
        party=@battle.pbParty(attacker.index)
        party[attacker.pokemonIndex].moves[i]=newmove
        movename=PBMoves.getName(opponent.lastMoveUsedSketch)
        $PokemonGlobal.pokebox[42]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.pbDisplay(_INTL("{1} learned {2}!",attacker.pbThis,movename))
        return 0
      end
    end
			pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Changes user's type to that of a random user's move, except this one, OR the
# user's first move's type. (Conversion)
################################################################################
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    for i in attacker.moves
      next if i.id==@id
      next if PBTypes.isPseudoType?(i.type)
      next if attacker.pbHasType?(i.type)
      if !types.include?(i.type)
        types.push(i.type)
        break
      end
    end
    if types.length==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.effects[PBEffects::Mimicry] = false
    attacker.type1=newtype
    attacker.type2=newtype
    attacker.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
  end
end



################################################################################
# Changes user's type to a random one that resists/is immune to the last move
# used by the target. (Conversion 2)
################################################################################
class PokeBattle_Move_05F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       PBTypes.isPseudoType?(PBMoveData.new(opponent.lastMoveUsed).type)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    atype=opponent.lastMoveUsedType
    if atype<0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in 0..PBTypes.maxValue
      next if PBTypes.isPseudoType?(i)
      next if attacker.pbHasType?(i)
      types.push(i) if PBTypes.getEffectiveness(atype,i)<2 
    end
    if types.length==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.effects[PBEffects::Mimicry] = false
    attacker.type1=newtype
    attacker.type2=newtype
    attacker.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    return 0
  end
end



################################################################################
# Changes user's type depending on the environment. (Camouflage)
################################################################################
class PokeBattle_Move_060 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    type=getConst(PBTypes,:NORMAL) || 0
    case @battle.environment
    when PBEnvironment::None;        type=getConst(PBTypes,:NORMAL) || 0
    when PBEnvironment::Grass;       type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::TallGrass;   type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::MovingWater; type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::StillWater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Underwater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Cave;        type=getConst(PBTypes,:ROCK) || 0
    when PBEnvironment::Rock;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Sand;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Forest;      type=getConst(PBTypes,:BUG) || 0
    when PBEnvironment::Snow;        type=getConst(PBTypes,:ICE) || 0
    when PBEnvironment::Volcano;     type=getConst(PBTypes,:FIRE) || 0
    when PBEnvironment::Graveyard;   type=getConst(PBTypes,:GHOST) || 0
    when PBEnvironment::Sky;         type=getConst(PBTypes,:FLYING) || 0
    when PBEnvironment::Space;       type=getConst(PBTypes,:DRAGON) || 0
    when PBEnvironment::Galaxy;      type=getConst(PBTypes,:MOON) || 0
    when PBEnvironment::Boardwalk;   type=getConst(PBTypes,:DARK) || 0
    when PBEnvironment::Ring;        type=getConst(PBTypes,:FIGHTING) || 0
    end
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      type=getConst(PBTypes,:ELECTRIC) if hasConst?(PBTypes,:ELECTRIC)
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      type=getConst(PBTypes,:GRASS) if hasConst?(PBTypes,:GRASS)
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      type=getConst(PBTypes,:FAIRY) if hasConst?(PBTypes,:FAIRY)
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      type=getConst(PBTypes,:PSYCHIC) if hasConst?(PBTypes,:PSYCHIC)
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      type=getConst(PBTypes,:BOLT) if hasConst?(PBTypes,:BOLT)
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      type=getConst(PBTypes,:LAVA) if hasConst?(PBTypes,:LAVA)
    elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      type=getConst(PBTypes,:HEART) if hasConst?(PBTypes,:HEART)
    end
    if attacker.pbHasType?(type)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Mimicry] = false
    attacker.type1=type
    attacker.type2=type
    attacker.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(type)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))  
    return 0
  end
end



################################################################################
# Target becomes Water type. (Soak)
################################################################################
class PokeBattle_Move_061 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:WATER) &&
       opponent.type2==getConst(PBTypes,:WATER) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:WATER))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:WATER)
    opponent.type2=getConst(PBTypes,:WATER)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:WATER))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# User copes target's types. (Reflect Type)
################################################################################
class PokeBattle_Move_062 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(opponent.type1) &&
       attacker.pbHasType?(opponent.type2) &&
       attacker.pbHasType?(opponent.effects[PBEffects::Type3]) &&
       opponent.pbHasType?(attacker.type1) &&
       opponent.pbHasType?(attacker.type2) &&
       opponent.pbHasType?(attacker.effects[PBEffects::Type3])
 			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    attacker.effects[PBEffects::Type3]=-1
    @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Target's ability becomes Simple. (Simple Beam)
################################################################################
class PokeBattle_Move_063 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasUnstoppableAbility(attacker,[:TRUANT],[:SIMPLE])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.ability=getConst(PBAbilities,:SIMPLE) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:SIMPLE))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# Target's ability becomes Insomnia. (Worry Seed)
################################################################################
class PokeBattle_Move_064 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.hasUnstoppableAbility(attacker,[:TRUANT],[:INSOMNIA])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.ability=getConst(PBAbilities,:INSOMNIA) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:INSOMNIA))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# User copies target's ability. (Role Play)
################################################################################
class PokeBattle_Move_065 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.ability==0 ||
       attacker.ability==opponent.ability ||
       attacker.hasUnstoppableAbility(nil) ||
       opponent.hasUngainableAbility(attacker,[:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=attacker.ability
    attacker.ability=opponent.ability
    abilityname=PBAbilities.getName(opponent.ability)
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),abilityname))
    if attacker.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      attacker.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",attacker.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(attacker.species,PBSpecies,:ETV) && attacker.form>1
      attacker.form-=2
      attacker.pbUpdate(true)
      @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",attacker.pbThis))
    end
    if attacker.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{attacker.pbThis}'s Illusion ended")    
      attacker.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",attacker.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# Target copies user's ability. (Entrainment)
################################################################################
class PokeBattle_Move_066 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.ability==0 ||
       attacker.ability==opponent.ability ||
       opponent.hasUnstoppableAbility(attacker,[:TRUANT]) ||
       attacker.hasUngainableAbility(nil,[:POWEROFALCHEMY, :RECEIVER, :TRACE])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.ability=attacker.ability
    abilityname=PBAbilities.getName(attacker.ability)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# User and target swap abilities. (Skill Swap)
################################################################################
class PokeBattle_Move_067 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.ability==0 && opponent.ability==0) ||
#       attacker.hasUngainableAbility(nil) ||
       attacker.hasUnstoppableAbility(nil,[:NEUTRALIZINGGAS, :ILLUSION, :WONDERGUARD, :ABILITOPIA, :IMPRISIN]) ||
#       opponent.hasUngainableAbility(attacker) ||
       opponent.hasUnstoppableAbility(attacker,[:NEUTRALIZINGGAS, :ILLUSION, :WONDERGUARD, :ABILITOPIA, :IMPRISIN])
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    tmp=attacker.ability
    attacker.ability=opponent.ability
    opponent.ability=tmp
    @battle.pbDisplay(_INTL("{1} swapped its {2} Ability with its target's {3} Ability!",
       attacker.pbThis,PBAbilities.getName(opponent.ability),
       PBAbilities.getName(attacker.ability)))
    attacker.pbAbilitiesOnSwitchIn(true)
    opponent.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end



################################################################################
# Target's ability is negated. (Gastro Acid)
################################################################################
class PokeBattle_Move_068 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) ||
      opponent.pbHasType?(:GUST) || opponent.pbHasType?(:MOON) || 
      opponent.pbHasType?(:MIND) || opponent.effects[PBEffects::GastroAcid] ||
      opponent.pbHasType?(:GAS) || isEternal?(opponent)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasUnstoppableAbility(attacker)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.effects[PBEffects::GastroAcid]=true
    opponent.effects[PBEffects::Truant]=false
    @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis)) 
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# User transforms into the target. (Transform)
################################################################################
class PokeBattle_Move_069 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0xC9,   # Fly
       0xCA,   # Dig
       0xCB,   # Dive
       0xCC,   # Bounce
       0xCD,   # Shadow Force
       0xCE,   # Sky Drop
       0x14D,  # Phantom Force
       0x336   # Steel FLy
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Illusion] ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       opponent.effects[PBEffects::SkyDrop] ||
       blacklist.include?(PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function) ||
       isConst?(opponent.ability,PBAbilities,:KOULUNDIN)
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.hasWorkingAbility(:ALONELY) && !attacker.hasMoldBreaker(opponent))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s {2} prevents transforming!",opponent.pbThis,PBAbilities.getName(opponent.ability))) if showMessages
      return -1
    end
    if isUltraBlue?(opponent)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} anchored itself with its Ultra Blue!",opponent.pbThis)) if showMessages
      return -1
    end    
    if @battle.pbTerrain==PBBattleTerrains::CINAMENT && !attacker.hasWorkingItem(:RODOFSPARROW)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The Cinament prevented {1} from transforming into {2}!",attacker.pbThis,opponent.pbThis(true)))
      return -1
    end
    if opponent.effects[PBEffects::TransformProtection] ||
       attacker.effects[PBEffects::TransformBlock]
			pbPlayMissSE()
    @battle.pbDisplay(_INTL("{1} cannot transform into {2}!",attacker.pbThis,opponent.pbThis(true)))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    # Pastel Card - Lower user's defense by 1 stage and prevent transforms of the holder
    if opponent.hasWorkingItem(:PASTELCARD) 
      if attacker.pbReduceStatWithCause(PBStats::DEFENSE,1,opponent,PBItems.getName(opponent.item))
        opponent.effects[PBEffects::TransformProtection]=true
        opponent.pbConsumeItem
      end
      return -1
    end
    # Placten Card - Lower user's sp. defense by 1 stage and prevent transforms of the holder
    if opponent.hasWorkingItem(:PLACTENCARD) 
      if attacker.pbReduceStatWithCause(PBStats::SPDEF,1,opponent,PBItems.getName(opponent.item))
        opponent.effects[PBEffects::TransformProtection]=true
        attacker.effects[PBEffects::TransformBlock]=true
        opponent.pbConsumeItem
      end
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Transform]=true
    attacker.effects[PBEffects::Mimicry] = opponent.effects[PBEffects::Mimicry]
    attacker.effects[PBEffects::Type1] = opponent.effects[PBEffects::Type1]
    attacker.effects[PBEffects::Type2] = opponent.effects[PBEffects::Type2]
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    attacker.effects[PBEffects::Type3]=-1
    attacker.ability=opponent.ability
    attacker.attack=opponent.attack
    attacker.defense=opponent.defense
    attacker.speed=opponent.speed
    attacker.spatk=opponent.spatk
    attacker.spdef=opponent.spdef
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i]=opponent.stages[i]
    end
    for i in 0...4
      attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
         @battle,PBMove.new(opponent.moves[i].id))
      attacker.moves[i].pp=5
      attacker.moves[i].totalpp=5
    end
    attacker.effects[PBEffects::Disable]=0
    attacker.effects[PBEffects::DisableMove]=0
    $PokemonGlobal.pokebox[49]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Inflicts a fixed 20HP damage. (SonicBoom)
################################################################################
class PokeBattle_Move_06A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(20,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts a fixed 40HP damage. (Dragon Rage)
################################################################################
class PokeBattle_Move_06B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(40,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Halves the target's current HP. (Super Fang)
################################################################################
class PokeBattle_Move_06C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage([(opponent.hp/2).floor,1].max,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage equal to the user's level. (Night Shade, Seismic Toss)
################################################################################
class PokeBattle_Move_06D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(attacker.level,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
################################################################################
class PokeBattle_Move_06E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp>=opponent.hp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return pbEffectFixedDamage(opponent.hp-attacker.hp,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
################################################################################
class PokeBattle_Move_06F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    dmg=[(attacker.level*(@battle.pbRandom(101)+50)/100).floor,1].max
    return pbEffectFixedDamage(dmg,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# OHKO. Accuracy increases by difference between levels of user and target.
################################################################################
class PokeBattle_Move_070 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STURDY)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return false
    end
    if opponent.pbHasType?(:MIND)
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return false
    end
    if opponent.level>attacker.level
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      return false
    end
    acc=@accuracy+attacker.level-opponent.level
    return @battle.pbRandom(100)<acc
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted?
			pbSEPlay("Battle effect message") ## Qora's Change. Play Sassy SE when fainted
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end


################################################################################
# Counters a physical move used against the user this round, with 2x the power. (Counter)
################################################################################
class PokeBattle_Move_071 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::CounterTarget]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::CounterTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::CounterTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Counter]<0 || !opponent
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage([attacker.effects[PBEffects::Counter]*2,1].max,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# Counters a specical move used against the user this round, with 2x the power. (Mirror Coat)
################################################################################
class PokeBattle_Move_072 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::MirrorCoatTarget]>=0 && 
       attacker.pbIsOpposing?(attacker.effects[PBEffects::MirrorCoatTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::MirrorCoatTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::MirrorCoat]<0 || !opponent
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage([attacker.effects[PBEffects::MirrorCoat]*2,1].max,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst)
################################################################################
class PokeBattle_Move_073 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.lastAttacker.length>0
      lastattacker=attacker.lastAttacker[attacker.lastAttacker.length-1]
      if lastattacker>=0 && attacker.pbIsOpposing?(lastattacker)
        if !attacker.pbAddTarget(targets,@battle.battlers[lastattacker])
          attacker.pbRandomTarget(targets)
        end
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.lastHPLost==0 || !opponent
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage([(attacker.lastHPLost*1.5).floor,1].max,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# The target's ally loses 1/16 of its max HP. (Flame Burst)
################################################################################
class PokeBattle_Move_074 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if opponent.pbPartner && !opponent.pbPartner.isFainted? &&
         !(opponent.pbPartner.hasWorkingAbility(:MAGICGUARD) || opponent.pbPartner.hasWorkingAbility(:SUPERCLEARBODY))
        opponent.pbPartner.pbReduceHP((opponent.pbPartner.totalhp/16).floor)
        @battle.pbDisplay(_INTL("The bursting flame hit {1}!",opponent.pbPartner.pbThis(true)))
      end
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target is using Dive. (Surf)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_075 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the target is using Dig. Power is halved if Grassy Terrain
# is in effect. (Earthquake)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_076 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    ret=damagemult
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      ret=(damagemult*2.0).round
    end
    if @battle.pbTerrain==PBBattleTerrains::GRASSY
      ret=(damagemult/2.0).round
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop. (Gust)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_077 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9  || # Fly
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC  || # Bounce
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE  || # Sky Drop
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x336 || # Steel Fly
       opponent.effects[PBEffects::SkyDrop]
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop. (Twister)
# May make the target flinch.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_078 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9  || # Fly
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC  || # Bounce
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE  || # Sky Drop
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x336 || # Steel Fly
       opponent.effects[PBEffects::SkyDrop]
      return basedmg*2
    end
    return basedmg
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Power is doubled if Fusion Flare has already been used this round. (Fusion Bolt)
################################################################################
class PokeBattle_Move_079 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.field.effects[PBEffects::FusionBolt]
      @battle.field.effects[PBEffects::FusionBolt]=false
      @doubled=true
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @doubled=false
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      @battle.field.effects[PBEffects::FusionFlare]=true
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.damagestate.critical || @doubled
      return super(id,attacker,opponent,1,alltargets,showanimation) # Charged anim
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Power is doubled if Fusion Bolt has already been used this round. (Fusion Flare)
################################################################################
class PokeBattle_Move_07A < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.field.effects[PBEffects::FusionFlare]
      @battle.field.effects[PBEffects::FusionFlare]=false
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      @battle.field.effects[PBEffects::FusionBolt]=true
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.damagestate.critical || @doubled
      return super(id,attacker,opponent,1,alltargets,showanimation) # Charged anim
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Power is doubled if the target is poisoned. (Venoshock)
################################################################################
class PokeBattle_Move_07B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::POISON &&
       (opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker))
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is paralyzed. Cures the target of paralysis.
# (SmellingSalt)
################################################################################
class PokeBattle_Move_07C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::PARALYSIS &&
       (opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker))
      return basedmg*2
    end
    return basedmg
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.status==PBStatuses::PARALYSIS
      opponent.pbCureStatus
    end
  end
end



################################################################################
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
################################################################################
class PokeBattle_Move_07D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::SLEEP &&
       (opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker))
      return basedmg*2
    end
    return basedmg
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.status==PBStatuses::SLEEP
      opponent.pbCureStatus
    end
  end
end



################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
################################################################################
class PokeBattle_Move_07E < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target has a status problem. (Hex)
################################################################################
class PokeBattle_Move_07F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status>0 &&
       (opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker))
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
################################################################################
class PokeBattle_Move_080 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.hp<=opponent.totalhp/2
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the user has lost HP due to the target's move this round.
# (Revenge, Avalanche)
################################################################################
class PokeBattle_Move_081 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.lastHPLost>0 && attacker.lastAttacker.include?(opponent.index)
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target has already lost HP this round. (Assurance)
################################################################################
class PokeBattle_Move_082 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.tookDamage
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if a user's ally has already used this move this round. (Round)
# If an ally is about to use the same move, make it go next, ignoring priority.
################################################################################
class PokeBattle_Move_083 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    ret=basedmg
    attacker.pbOwnSide.effects[PBEffects::Round].times do
      ret*=2
    end
    return ret
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.pbOwnSide.effects[PBEffects::Round]+=1
      if attacker.pbPartner && !attacker.pbPartner.hasMovedThisRound?
        if @battle.choices[attacker.pbPartner.index][0]==1 # Will use a move
          partnermove=@battle.choices[attacker.pbPartner.index][2]
          if partnermove.function==@function
            attacker.pbPartner.effects[PBEffects::MoveNext]=true
            attacker.pbPartner.effects[PBEffects::Quash]=false
          end
        end
      end
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target has already moved this round. (Payback)
################################################################################
class PokeBattle_Move_084 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? # Used a move already
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if a user's teammate fainted last round. (Retaliate)
################################################################################
class PokeBattle_Move_085 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::LastRoundFainted]>=0 &&
       attacker.pbOwnSide.effects[PBEffects::LastRoundFainted]==@battle.turncount-1
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the user has no held item. (Acrobatics)
################################################################################
class PokeBattle_Move_086 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if attacker.item==0
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled in weather. Type changes depending on the weather. 
# Power is doubled in Cinament as well and goes for Bolt type (Weather Ball)
################################################################################
class PokeBattle_Move_087 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.pbWeather!=0 || 
      (@battle.pbTerrain==PBBattleTerrains::CINAMENT && @battle.field.effects[PBEffects::GlimmyGalaxy]==0)
      return basedmg*2 if !attacker.hasWorkingItem(:UTILITYUMBRELLA)
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || 0
    case @battle.pbWeather
    when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
      type=(getConst(PBTypes,:FIRE) || type)
    when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
      type=(getConst(PBTypes,:WATER) || type)
    when PBWeather::SANDSTORM
      type=(getConst(PBTypes,:ROCK) || type)
    when PBWeather::HAIL
      type=(getConst(PBTypes,:ICE) || type)
    end
    type=(getConst(PBTypes,:BOLT) || type) if @battle.pbTerrain==PBBattleTerrains::CINAMENT && 
                                              @battle.field.effects[PBEffects::GlimmyGalaxy]==0
    return getConst(PBTypes,:NORMAL) if attacker.hasWorkingItem(:UTILITYUMBRELLA)
    return type
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    anim=0
    case @battle.pbWeather
    when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
      anim=1
    when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
      anim=2
    when PBWeather::SANDSTORM
      anim=4
    when PBWeather::HAIL
      anim=3
    end
    anim=5 if @battle.pbTerrain==PBBattleTerrains::CINAMENT &&
              @battle.field.effects[PBEffects::GlimmyGalaxy]==0
    anim=0 if attacker.hasWorkingItem(:UTILITYUMBRELLA)
    return super(id,attacker,opponent,anim,alltargets,showanimation) # Weather-specific anim
  end

end



################################################################################
# Power is doubled if a foe tries to switch out or use U-turn/Volt Switch/
# Parting Shot. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.switching
      return basedmg*2
    end
    return basedmg
  end

  def pbAccuracyCheck(attacker,opponent)
    return true if @battle.switching
    return super(attacker,opponent)
  end
end



################################################################################
# Power increases with the user's happiness. (Return)
################################################################################
class PokeBattle_Move_089 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(attacker.happiness*2/5).floor,1].max
  end
end



################################################################################
# Power decreases with the user's happiness. (Frustration)
################################################################################
class PokeBattle_Move_08A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [((255-attacker.happiness)*2/5).floor,1].max
  end
end



################################################################################
# Power increases with the user's HP. (Eruption, Water Spout)
################################################################################
class PokeBattle_Move_08B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(150*attacker.hp/attacker.totalhp).floor,1].max
  end
end



################################################################################
# Power increases with the target's HP. (Crush Grip, Wring Out)
################################################################################
class PokeBattle_Move_08C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(120*opponent.hp/opponent.totalhp).floor,1].max
  end
end



################################################################################
# Power increases the quicker the target is than the user. (Gyro Ball)
################################################################################
class PokeBattle_Move_08D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [[(25*opponent.pbSpeed/attacker.pbSpeed).floor,150].min,1].max
  end
end



################################################################################
# Power increases with the user's positive stat changes (ignores negative ones).
# (Stored Power)
################################################################################
class PokeBattle_Move_08E < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=1
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      mult+=attacker.stages[i] if attacker.stages[i]>0
    end
    return 20*mult
  end
end



################################################################################
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
################################################################################
class PokeBattle_Move_08F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=3
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      mult+=opponent.stages[i] if opponent.stages[i]>0
    end
    return [20*mult,200].min
  end
end



################################################################################
# Power and type depends on the user's IVs. (Hidden Power)
################################################################################
class PokeBattle_Move_090 < PokeBattle_Move
  def pbModifyType(type,attacker,opponent)
    hp=pbHiddenPower(attacker.iv)
    type=hp[0]
    return type
  end

  def pbBaseDamage(basedmg,attacker,opponent)
 #   return 60
    hp=pbHiddenPower(attacker.iv)
    return hp[1]
  end
end

def pbHiddenPower(iv)
  powermin=30
  powermax=70
  type=0; base=0
  types=[]
  for i in 0..PBTypes.maxValue
    types.push(i) if !PBTypes.isPseudoType?(i) &&
                     !isConst?(i,PBTypes,:NORMAL) && !isConst?(i,PBTypes,:SHADOW) &&
                     !isConst?(i,PBTypes,:FAIRY) && !isConst?(i,PBTypes,:MOON) &&
                     !isConst?(i,PBTypes,:HEART) && !isConst?(i,PBTypes,:ROBOT)
  end
  type|=(iv[PBStats::HP]&1)
  type|=(iv[PBStats::ATTACK]&1)<<1
  type|=(iv[PBStats::DEFENSE]&1)<<2
  type|=(iv[PBStats::SPEED]&1)<<3
  type|=(iv[PBStats::SPATK]&1)<<4
  type|=(iv[PBStats::SPDEF]&1)<<5
  type=(type*(types.length-1)/63).floor
  hptype=types[type]
  base|=(iv[PBStats::HP]&2)>>1
  base|=(iv[PBStats::ATTACK]&2)
  base|=(iv[PBStats::DEFENSE]&2)<<1
  base|=(iv[PBStats::SPEED]&2)<<2
  base|=(iv[PBStats::SPATK]&2)<<3
  base|=(iv[PBStats::SPDEF]&2)<<4
  base=(base*(powermax-powermin)/63).floor+powermin
  return [hptype,base]
end

################################################################################
# Power doubles for each consecutive use. (Fury Cutter)
################################################################################
class PokeBattle_Move_091 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg=basedmg<<(attacker.effects[PBEffects::FuryCutter]-1) # can be 1 to 4
    return basedmg
  end
end



################################################################################
# Power is multiplied by the number of consecutive rounds in which this move was
# used by any Pokémon on the user's side. (Echoed Voice)
################################################################################
class PokeBattle_Move_092 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg*=attacker.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] # can be 1 to 5
    return basedmg
  end
end



################################################################################
# User rages until the start of a round in which they don't use this move. (Rage)
# (Handled in Battler's pbProcessMoveAgainstTarget): Ups rager's Attack by 1
# stage each time it loses HP due to a move.
################################################################################
class PokeBattle_Move_093 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Rage]=true if ret>0
    return ret
  end
end



################################################################################
# Randomly damages or heals the target. (Present)
################################################################################
class PokeBattle_Move_094 < PokeBattle_Move
  def pbOnStartUse(attacker)
    # Just to ensure that Parental Bond's second hit damages if the first hit does
    @forcedamage=false
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    @forcedamage=true
    return @calcbasedmg 
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @calcbasedmg=1
    r=@battle.pbRandom((@forcedamage) ? 8 : 10)
    if r<4
      @calcbasedmg=40
    elsif r<7
      @calcbasedmg=80
    elsif r<8
      @calcbasedmg=120
    else
      if pbTypeModifier(pbType(@type,attacker,opponent),attacker,opponent)==0
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      end
      if opponent.hp==opponent.totalhp
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      damage=pbCalcDamage(attacker,opponent) # Consumes Gems even if it will heal
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Healing animation
      opponent.pbRecoverHP((opponent.totalhp/4).floor,true)
      @battle.pbDisplay(_INTL("{1} had its HP restored.",opponent.pbThis))   
      return 0
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Power is chosen at random. Power is doubled if the target is using Dig. (Magnitude)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_095 < PokeBattle_Move
  def pbOnStartUse(attacker)
    basedmg=[10,30,50,70,90,110,150]
    magnitudes=[
       4,
       5,5,
       6,6,6,6,
       7,7,7,7,7,7,
       8,8,8,8,
       9,9,
       10
    ]
    magni=magnitudes[@battle.pbRandom(magnitudes.length)]
    @calcbasedmg=basedmg[magni-4]
    @battle.pbDisplay(_INTL("Magnitude {1}!",magni)) if isConst?(@id,PBMoves,:MAGNITUDE)
    @battle.pbDisplay(_INTL("Eerie {1}!",magni)) if isConst?(@id,PBMoves,:EERIEQUAKE)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      ret*=2
    end
    if @battle.pbTerrain==PBBattleTerrains::GRASSY
      ret=(ret/2.0).round
    end
    return ret
  end
end



################################################################################
# Power and type depend on the user's held berry. Destroys the berry. (Natural Gift)
################################################################################
class PokeBattle_Move_096 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if !pbIsBerry?(attacker.item) ||
       attacker.effects[PBEffects::Embargo]>0 ||
       @battle.field.effects[PBEffects::MagicRoom]>0 ||
       attacker.hasWorkingAbility(:KLUTZ) ||
       attacker.pbOpposing1.hasWorkingAbility(:UNNERVE) ||
       attacker.pbOpposing2.hasWorkingAbility(:UNNERVE) ||
       attacker.pbOpposing1.hasWorkingAbility(:ASONE1) ||
       attacker.pbOpposing2.hasWorkingAbility(:ASONE1) ||
       attacker.pbOpposing1.hasWorkingAbility(:ASONE2) ||
       attacker.pbOpposing2.hasWorkingAbility(:ASONE2)
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    @berry=attacker.item
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    damagearray={
       80 => [:CHERIBERRY,:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:ASPEARBERRY,
              :LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,
              :FIGYBERRY,:WIKIBERRY,:MAGOBERRY,:AGUAVBERRY,:IAPAPABERRY,
              :RAZZBERRY,:OCCABERRY,:PASSHOBERRY,:WACANBERRY,:RINDOBERRY,
              :YACHEBERRY,:CHOPLEBERRY,:KEBIABERRY,:SHUCABERRY,:COBABERRY,
              :PAYAPABERRY,:TANGABERRY,:CHARTIBERRY,:KASIBBERRY,:HABANBERRY,
              :COLBURBERRY,:BABIRIBERRY,:CHILANBERRY,:ROSELIBERRY],
       90 => [:BLUKBERRY,:NANABBERRY,:WEPEARBERRY,:PINAPBERRY,:POMEGBERRY,
              :KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY,
              :CORNNBERRY,:MAGOSTBERRY,:RABUTABERRY,:NOMELBERRY,:SPELONBERRY,
              :PAMTREBERRY],
       100 => [:WATMELBERRY,:DURINBERRY,:BELUEBERRY,:LIECHIBERRY,:GANLONBERRY,
              :SALACBERRY,:PETAYABERRY,:APICOTBERRY,:LANSATBERRY,:STARFBERRY,
              :ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,:JABOCABERRY,:ROWAPBERRY,
              :KEEBERRY,:MARANGABERRY]
    }
    for i in damagearray.keys
      data=damagearray[i]
      if data
        for j in data
          if isConst?(@berry,PBItems,j)
            ret=i
            ret+=20
            return ret
          end
        end
      end
    end
    return 1
  end

  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || 0
    typearray={
       :NORMAL   => [:CHILANBERRY],
       :FIRE     => [:CHERIBERRY,:BLUKBERRY,:WATMELBERRY,:OCCABERRY],
       :WATER    => [:CHESTOBERRY,:NANABBERRY,:DURINBERRY,:PASSHOBERRY],
       :ELECTRIC => [:PECHABERRY,:WEPEARBERRY,:BELUEBERRY,:WACANBERRY],
       :GRASS    => [:RAWSTBERRY,:PINAPBERRY,:RINDOBERRY,:LIECHIBERRY],
       :ICE      => [:ASPEARBERRY,:POMEGBERRY,:YACHEBERRY,:GANLONBERRY],
       :FIGHTING => [:LEPPABERRY,:KELPSYBERRY,:CHOPLEBERRY,:SALACBERRY],
       :POISON   => [:ORANBERRY,:QUALOTBERRY,:KEBIABERRY,:PETAYABERRY],
       :GROUND   => [:PERSIMBERRY,:HONDEWBERRY,:SHUCABERRY,:APICOTBERRY],
       :FLYING   => [:LUMBERRY,:GREPABERRY,:COBABERRY,:LANSATBERRY],
       :PSYCHIC  => [:SITRUSBERRY,:TAMATOBERRY,:PAYAPABERRY,:STARFBERRY],
       :BUG      => [:FIGYBERRY,:CORNNBERRY,:TANGABERRY,:ENIGMABERRY],
       :ROCK     => [:WIKIBERRY,:MAGOSTBERRY,:CHARTIBERRY,:MICLEBERRY],
       :GHOST    => [:MAGOBERRY,:RABUTABERRY,:KASIBBERRY,:CUSTAPBERRY],
       :DRAGON   => [:AGUAVBERRY,:NOMELBERRY,:HABANBERRY,:JABOCABERRY],
       :DARK     => [:IAPAPABERRY,:SPELONBERRY,:COLBURBERRY,:ROWAPBERRY,:MARANGABERRY],
       :STEEL    => [:RAZZBERRY,:PAMTREBERRY,:BABIRIBERRY],
       :FAIRY    => [:ROSELIBERRY,:KEEBERRY]
    }
    for i in typearray.keys
      data=typearray[i]
      if data
        for j in data
          if isConst?(@berry,PBItems,j)
            type=getConst(PBTypes,i) || type
          end
        end
      end
    end
    return type
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if turneffects[PBEffects::TotalDamage]>0
      attacker.pbConsumeItem
    end
  end
end



################################################################################
# Power increases the less PP this move has. (Trump Card)
################################################################################
class PokeBattle_Move_097 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    dmgs=[200,80,60,50,40]
    ppleft=[@pp,4].min   # PP is reduced before the move is used
    basedmg=dmgs[ppleft]
    return basedmg
  end
end



################################################################################
# Power increases the less HP the user has. (Flail, Reversal)
################################################################################
class PokeBattle_Move_098 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(48*attacker.hp/attacker.totalhp).floor
    ret=20
    ret=40 if n<33
    ret=80 if n<17
    ret=100 if n<10
    ret=150 if n<5
    ret=200 if n<2
    return ret
  end
end



################################################################################
# Power increases the quicker the user is than the target. (Electro Ball)
################################################################################
class PokeBattle_Move_099 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=([attacker.pbSpeed,1].max/[opponent.pbSpeed,1].max).floor
    ret=60
    ret=80 if n>=2
    ret=120 if n>=3
    ret=150 if n>=4
    return ret
  end
end



################################################################################
# Power increases the heavier the target is. (Grass Knot, Low Kick)
################################################################################
class PokeBattle_Move_09A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    weight=opponent.weight(attacker)
    ret=20
    ret=40 if weight>=100
    ret=60 if weight>=250
    ret=80 if weight>=500
    ret=100 if weight>=1000
    ret=120 if weight>=2000
    return ret
  end
end



################################################################################
# Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
# Does double damage and has perfect accuracy if the target is Minimized.
################################################################################
class PokeBattle_Move_09B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(attacker.weight/opponent.weight(attacker)).floor
    ret=40
    ret=60 if n>=2
    ret=80 if n>=3
    ret=100 if n>=4
    ret=120 if n>=5
    return ret
  end
  
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Powers up the ally's attack this round by 1.5. (Helping Hand)
################################################################################
class PokeBattle_Move_09C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || opponent.isFainted? ||
       @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? ||
       opponent.effects[PBEffects::HelpingHand]
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::HelpingHand]=true
    @battle.pbDisplay(_INTL("{1} is ready to help {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Weakens Electric attacks. (Mud Sport)
################################################################################
class PokeBattle_Move_09D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::MudSportField]>0
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::MudSportField]=5
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    return 0
    return -1
  end
end



################################################################################
# Weakens Fire attacks. (Water Sport)
################################################################################
class PokeBattle_Move_09E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::WaterSportField]>0
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::WaterSportField]=5
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
    return 0
  end
end



################################################################################
# Type depends on the user's held item. (Judgment, Techno Blast)
################################################################################
class PokeBattle_Move_09F < PokeBattle_Move
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || 0
    if isConst?(@id,PBMoves,:JUDGMENT)
      type=(getConst(PBTypes,:FIGHTING) || 0)     if attacker.hasWorkingItem(:FISTPLATE)
      type=(getConst(PBTypes,:FLYING) || 0)       if attacker.hasWorkingItem(:SKYPLATE)
      type=(getConst(PBTypes,:POISON) || 0)       if attacker.hasWorkingItem(:TOXICPLATE)
      type=(getConst(PBTypes,:GROUND) || 0)       if attacker.hasWorkingItem(:EARTHPLATE)
      type=(getConst(PBTypes,:ROCK) || 0)         if attacker.hasWorkingItem(:STONEPLATE)
      type=(getConst(PBTypes,:BUG) || 0)          if attacker.hasWorkingItem(:INSECTPLATE)
      type=(getConst(PBTypes,:GHOST) || 0)        if attacker.hasWorkingItem(:SPOOKYPLATE)
      type=(getConst(PBTypes,:STEEL) || 0)        if attacker.hasWorkingItem(:IRONPLATE)
      type=(getConst(PBTypes,:FIRE) || 0)         if attacker.hasWorkingItem(:FLAMEPLATE)
      type=(getConst(PBTypes,:WATER) || 0)        if attacker.hasWorkingItem(:SPLASHPLATE)
      type=(getConst(PBTypes,:GRASS) || 0)        if attacker.hasWorkingItem(:MEADOWPLATE)
      type=(getConst(PBTypes,:ELECTRIC) || 0)     if attacker.hasWorkingItem(:ZAPPLATE)
      type=(getConst(PBTypes,:PSYCHIC) || 0)      if attacker.hasWorkingItem(:MINDPLATE)
      type=(getConst(PBTypes,:ICE) || 0)          if attacker.hasWorkingItem(:ICICLEPLATE)
      type=(getConst(PBTypes,:DRAGON) || 0)       if attacker.hasWorkingItem(:DRACOPLATE)
      type=(getConst(PBTypes,:DARK) || 0)         if attacker.hasWorkingItem(:DREADPLATE)
      type=(getConst(PBTypes,:FAIRY) || 0)        if attacker.hasWorkingItem(:PIXIEPLATE)
      # Flint Types
      type=(getConst(PBTypes,:MAGIC) || 0)        if attacker.hasWorkingItem(:WIZARDPLATE)
      type=(getConst(PBTypes,:DOOM) || 0)         if attacker.hasWorkingItem(:BOMBPLATE)
      type=(getConst(PBTypes,:JELLY) || 0)        if attacker.hasWorkingItem(:JELLYLICIOUSPLATE)
      type=(getConst(PBTypes,:SHARPENER) || 0)    if attacker.hasWorkingItem(:GYROPLATE)
      type=(getConst(PBTypes,:LAVA) || 0)         if attacker.hasWorkingItem(:VOLCANOPLATE)
      type=(getConst(PBTypes,:WIND) || 0)         if attacker.hasWorkingItem(:WHIRLWINDPLATE)
      type=(getConst(PBTypes,:LICK) || 0)         if attacker.hasWorkingItem(:CANDLEPLATE)
      type=(getConst(PBTypes,:BOLT) || 0)         if attacker.hasWorkingItem(:CHARGINGPLATE)
      type=(getConst(PBTypes,:HERB) || 0)         if attacker.hasWorkingItem(:BOTANICPLATE)
      type=(getConst(PBTypes,:CHLOROPHYLL) || 0)  if attacker.hasWorkingItem(:MENTALPLATE)
      type=(getConst(PBTypes,:GUST) || 0)         if attacker.hasWorkingItem(:FISSIONPLATE)
      type=(getConst(PBTypes,:SUN) || 0)          if attacker.hasWorkingItem(:SUNSHINEPLATE)
      type=(getConst(PBTypes,:MOON) || 0)         if attacker.hasWorkingItem(:LUNARPLATE)
      type=(getConst(PBTypes,:MIND) || 0)         if attacker.hasWorkingItem(:BRAINPLATE)
      type=(getConst(PBTypes,:HEART) || 0)        if attacker.hasWorkingItem(:LOVEPLATE)
      type=(getConst(PBTypes,:BLIZZARD) || 0)     if attacker.hasWorkingItem(:COLDPLATE)
      type=(getConst(PBTypes,:GAS) || 0)          if attacker.hasWorkingItem(:CARBONPLATE)
      type=(getConst(PBTypes,:GLIMSE) || 0)       if attacker.hasWorkingItem(:GALAXYPLATE)
    elsif isConst?(@id,PBMoves,:TECHNOBLAST)
      return getConst(PBTypes,:ELECTRIC) if attacker.hasWorkingItem(:SHOCKDRIVE)
      return getConst(PBTypes,:FIRE)     if attacker.hasWorkingItem(:BURNDRIVE)
      return getConst(PBTypes,:ICE)      if attacker.hasWorkingItem(:CHILLDRIVE)
      return getConst(PBTypes,:WATER)    if attacker.hasWorkingItem(:DOUSEDRIVE)
    elsif isConst?(@id,PBMoves,:MULTIATTACK)
      type=(getConst(PBTypes,:FIGHTING) || 0)     if attacker.hasWorkingItem(:FIGHTINGMEMORY)
      type=(getConst(PBTypes,:FLYING) || 0)       if attacker.hasWorkingItem(:FLYINGMEMORY)
      type=(getConst(PBTypes,:POISON) || 0)       if attacker.hasWorkingItem(:POISONMEMORY)      
      type=(getConst(PBTypes,:GROUND) || 0)       if attacker.hasWorkingItem(:GROUNDMEMORY)
      type=(getConst(PBTypes,:ROCK) || 0)         if attacker.hasWorkingItem(:ROCKMEMORY)
      type=(getConst(PBTypes,:BUG) || 0)          if attacker.hasWorkingItem(:BUGMEMORY)
      type=(getConst(PBTypes,:GHOST) || 0)        if attacker.hasWorkingItem(:GHOSTMEMORY)
      type=(getConst(PBTypes,:STEEL) || 0)        if attacker.hasWorkingItem(:STEELMEMORY)
      type=(getConst(PBTypes,:FIRE) || 0)         if attacker.hasWorkingItem(:FIREMEMORY)
      type=(getConst(PBTypes,:WATER) || 0)        if attacker.hasWorkingItem(:WATERMEMORY)
      type=(getConst(PBTypes,:GRASS) || 0)        if attacker.hasWorkingItem(:GRASSMEMORY)
      type=(getConst(PBTypes,:ELECTRIC) || 0)     if attacker.hasWorkingItem(:ELECTRICMEMORY)
      type=(getConst(PBTypes,:PSYCHIC) || 0)      if attacker.hasWorkingItem(:PSYCHICMEMORY)
      type=(getConst(PBTypes,:ICE) || 0)          if attacker.hasWorkingItem(:ICEMEMORY)
      type=(getConst(PBTypes,:DRAGON) || 0)       if attacker.hasWorkingItem(:DRAGONMEMORY)
      type=(getConst(PBTypes,:DARK) || 0)         if attacker.hasWorkingItem(:DARKMEMORY)
      type=(getConst(PBTypes,:FAIRY) || 0)        if attacker.hasWorkingItem(:FAIRYMEMORY)
      # Flint Types
      type=(getConst(PBTypes,:MAGIC) || 0)        if attacker.hasWorkingItem(:MAGICMEMORY)
      type=(getConst(PBTypes,:DOOM) || 0)         if attacker.hasWorkingItem(:DOOMMEMORY)
      type=(getConst(PBTypes,:JELLY) || 0)        if attacker.hasWorkingItem(:JELLYMEMORY)
      type=(getConst(PBTypes,:SHARPENER) || 0)    if attacker.hasWorkingItem(:SHARPENERMEORY)
      type=(getConst(PBTypes,:LAVA) || 0)         if attacker.hasWorkingItem(:LAVAMEMORY)
      type=(getConst(PBTypes,:WIND) || 0)         if attacker.hasWorkingItem(:WINDMEMORY)
      type=(getConst(PBTypes,:LICK) || 0)         if attacker.hasWorkingItem(:LICKMEMORY)
      type=(getConst(PBTypes,:BOLT) || 0)         if attacker.hasWorkingItem(:BOLTMEMORY)
      type=(getConst(PBTypes,:HERB) || 0)         if attacker.hasWorkingItem(:HERBMEMORY)
      type=(getConst(PBTypes,:CHLOROPHYLL) || 0)  if attacker.hasWorkingItem(:CHLOROPHYLLMEMORY)
      type=(getConst(PBTypes,:GUST) || 0)         if attacker.hasWorkingItem(:GUSTMEMORY)
      type=(getConst(PBTypes,:SUN) || 0)          if attacker.hasWorkingItem(:SUNMEMORY)
      type=(getConst(PBTypes,:MOON) || 0)         if attacker.hasWorkingItem(:MOONMEMORY)
      type=(getConst(PBTypes,:MIND) || 0)         if attacker.hasWorkingItem(:MINDMEMORY)
      type=(getConst(PBTypes,:HEART) || 0)        if attacker.hasWorkingItem(:HEARTMEMORY)
      type=(getConst(PBTypes,:BLIZZARD) || 0)     if attacker.hasWorkingItem(:BLIZZARD)
      type=(getConst(PBTypes,:GAS) || 0)          if attacker.hasWorkingItem(:GASMEMORY)
      type=(getConst(PBTypes,:GLIMSE) || 0)       if attacker.hasWorkingItem(:GLIMSEMEMORY)

    end
    return type
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(@id,PBMoves,:TECHNOBLAST)
      anim=0
      anim=1 if isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
      anim=2 if isConst?(pbType(@type,attacker,opponent),PBTypes,:FIRE)
      anim=3 if isConst?(pbType(@type,attacker,opponent),PBTypes,:ICE)
      anim=4 if isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
      return super(id,attacker,opponent,anim,alltargets,showanimation) # Type-specific anim
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# This attack is always a critical hit. (Frost Breath, Storm Throw)
################################################################################
class PokeBattle_Move_0A0 < PokeBattle_Move
  def pbCritialOverride(attacker,opponent)
    return true
  end
end



################################################################################
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
################################################################################
class PokeBattle_Move_0A1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LuckyChant]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LuckyChant]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The Lucky Chant shielded your team from critical hits!"))
    else
      @battle.pbDisplay(_INTL("The Lucky Chant shielded the opposing team from critical hits!"))
    end  
    return 0
  end
end



################################################################################
# For 5 rounds, lowers power of physical attacks against the user's side. (Reflect)
################################################################################
class PokeBattle_Move_0A2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Reflect]=5
    attacker.pbOwnSide.effects[PBEffects::Reflect]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Reflect raised your team's Defense!"))
    else
      @battle.pbDisplay(_INTL("Reflect raised the opposing team's Defense!"))
    end  
    return 0
  end
end



################################################################################
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
################################################################################
class PokeBattle_Move_0A3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=5
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Light Screen raised your team's Special Defense!"))
    else
      @battle.pbDisplay(_INTL("Light Screen raised the opposing team's Special Defense!"))
    end
    return 0
  end
end



################################################################################
# Effect depends on the environment. (Secret Power)
################################################################################
class PokeBattle_Move_0A4 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        return
      end
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      if opponent.pbCanSleep?(attacker,false,self)
        opponent.pbSleep
        return
      end
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
        return
      end
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
      end
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
        return
      end
    elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      if opponent.pbCanAttract?(attacker)
        opponent.pbAttract(attacker)
        return
      end
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self)
        if opponent.pbCanParalyze?(attacker,false,self)
          opponent.pbParalyze(attacker)
          return
        end
        return
      end
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        return
      end
    end
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass, PBEnvironment::Forest
      if opponent.pbCanSleep?(attacker,false,self)
        opponent.pbSleep
      end
    when PBEnvironment::MovingWater, PBEnvironment::Underwater
      if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
        opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
      end
    when PBEnvironment::StillWater, PBEnvironment::Sky, PBEnvironment::Ring
      if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
      end
    when PBEnvironment::Sand, PBEnvironment::Galaxy
      if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
        opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
      end
    when PBEnvironment::Rock
      if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
        opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
      end
    when PBEnvironment::Cave, PBEnvironment::Graveyard, PBEnvironment::Space, PBEnvironment::Boardwalk
      if opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker)
        opponent.pbFlinch(attacker)
      end
    when PBEnvironment::Snow
      if opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
      end
    when PBEnvironment::Volcano
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
      end
    else
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
      end
    end
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    id=getConst(PBMoves,:SPITUP)
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass
      id=(getConst(PBMoves,:VINEWHIP)) || id
    when PBEnvironment::MovingWater; id=getConst(PBMoves,:WATERPULSE) || id
    when PBEnvironment::StillWater;  id=getConst(PBMoves,:MUDSHOT) || id
    when PBEnvironment::Underwater;  id=getConst(PBMoves,:WATERPULSE) || id
    when PBEnvironment::Cave;        id=getConst(PBMoves,:ROCKTHROW) || id
    when PBEnvironment::Rock;        id=getConst(PBMoves,:SANDATTACK) || id
    when PBEnvironment::Sand;        id=getConst(PBMoves,:SANDATTACK) || id
    when PBEnvironment::Forest;      id=getConst(PBMoves,:RAZORLEAF) || id
    # Ice tiles in Gen 6 should be Ice Shard
    when PBEnvironment::Snow;        id=getConst(PBMoves,:AVALANCHE) || id
    when PBEnvironment::Volcano;     id=getConst(PBMoves,:INCINERATE) || id
    when PBEnvironment::Graveyard;   id=getConst(PBMoves,:SHADOWSNEAK) || id
    when PBEnvironment::Sky;         id=getConst(PBMoves,:GUST) || id
    when PBEnvironment::Space;       id=getConst(PBMoves,:SWIFT) || id
    when PBEnvironment::Galaxy;      id=getConst(PBMoves,:MOONCROKET) || id
    when PBEnvironment::Boardwalk;   id=getConst(PBMoves,:PURSUIT) || id
    when PBEnvironment::Ring;        id=getConst(PBMoves,:BRICKBREAK) || id
    end
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      id=getConst(PBMoves,:THUNDERSHOCK) || id
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      id=getConst(PBMoves,:VINEWHIP) || id
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      id=getConst(PBMoves,:FAIRYWIND) || id
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      id=getConst(PBMoves,:CONFUSION) || id
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      id=getConst(PBMoves,:WINDBOLT) || id
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      id=getConst(PBMoves,:LAVACORN) || id
    elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      id=getConst(PBMoves,:HEARTGLOW) || id
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation) # Environment-specific anim
  end
end



################################################################################
# Always hits.
################################################################################
class PokeBattle_Move_0A5 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
end



################################################################################
# User's attack next round against the target will definitely hit. (Lock-On, Mind Reader)
################################################################################
class PokeBattle_Move_0A6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LockOn]=2
    opponent.effects[PBEffects::LockOnPos]=attacker.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on. (Foresight, Odor Sleuth)
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
################################################################################
class PokeBattle_Move_0A7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Foresight]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on. (Miracle Eye)
# Psychic moves have normal effectiveness against the Dark-type target.
################################################################################
class PokeBattle_Move_0A8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MiracleEye]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (Chip Away, Sacred Sword)
################################################################################
class PokeBattle_Move_0A9 < PokeBattle_Move
# Handled in superclass def pbAccuracyCheck and def pbCalcDamage, do not edit!
end



################################################################################
# User is protected against moves with the "B" flag this round. (Detect, Protect)
################################################################################
class PokeBattle_Move_0AA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved ||
       @battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Protect]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User's side is protected against moves with priority greater than 0 this round.
# (Quick Guard)
################################################################################
class PokeBattle_Move_0AB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::QuickGuard]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::QuickGuard]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Quick Guard protected your team!"))
    else
      @battle.pbDisplay(_INTL("Quick Guard protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# User's side is protected against moves that target multiple battlers this round.
# (Wide Guard)
################################################################################
class PokeBattle_Move_0AC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::WideGuard]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::WideGuard]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Wide Guard protected your team!"))
    else
      @battle.pbDisplay(_INTL("Wide Guard protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# Ignores target's protections. If successful, all other moves this round
# ignore them too. (Feint)
################################################################################
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if ret>0
      opponent.effects[PBEffects::ProtectNegation]=true
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
    end
    return ret
  end
end



################################################################################
# Uses the last move that the target used. (Mirror Move)
################################################################################
class PokeBattle_Move_0AE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.lastMoveUsed<=0 ||
       (PBMoveData.new(opponent.lastMoveUsed).flags&0x10)==0 # flag e: Copyable by Mirror Move
      @battle.pbDisplay(_INTL("The mirror move failed!"))
      return -1
    end
    $PokemonGlobal.pokebox[28]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
    attacker.pbUseMoveSimple(opponent.lastMoveUsed,-1,opponent.index)
    return 0
  end
end



################################################################################
# Uses the last move that was used. (Copycat)
################################################################################
class PokeBattle_Move_0AF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x69,    # Transform
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x73,    # Metal Burst
       0x9C,    # Helping Hand
       0xAA,    # Detect, Protect
       0xAD,    # Feint
       0xB2,    # Snatch
       0xAF,    # Copycat
       0xE7,    # Destiny Bond
       0xE8,    # Endure
       0xEC,    # Circle Throw, Dragon Tail
       0xF1,    # Covet, Thief
       0xF2,    # Switcheroo, Trick
       0xF3,    # Bestow
       0xAE,    # Mirror Move
       0x115,   # Focus Punch
       0x117,   # Follow Me, Rage Powder
       0x158,   # Belch
       0x172,   # Κουλούνδιν
       0x186,   # Intimidate
       0x187,   # Douze Crayon
       0x245,   # Doom Catapult
       0x246,   # Fiery Catapult
       0x221,   # Baneful Bunker
       0x295,   # Grassy Catapult
       0x325,   # Elder Special Moves
       0x344    # Brainymedia
    ]
    blacklist+=[
       0xEB,    # Roar, Whirlwind
       # Two-turn attacks
       0xC3,    # Razor Wind
       0xC4,    # SolarBeam
       0xC5,    # Freeze Shock
       0xC6,    # Ice Burn
       0xC7,    # Sky Attack
       0xC8,    # Skull Bash
       0xC9,    # Fly
       0xCA,    # Dig
       0xCB,    # Dive
       0xCC,    # Bounce
       0xCD,    # Shadow Force
       0xCE,    # Sky Drop
       0x14D,   # Phantom Force
       0x14E,   # Geomancy
       0x336,   # Steel Fly
       0x378    # Electro Shot
    ]
    if battle.lastMoveUsed<=0 ||
       blacklist.include?(PBMoveData.new(@battle.lastMoveUsed).function) || 
       @battle.lastMoveUser == attacker
			pbPlayMissSE()       
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    $PokemonGlobal.pokebox[28]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
    attacker.pbUseMoveSimple(@battle.lastMoveUsed,-1,@battle.lastMoveUser)
    return 0
  end
end




################################################################################
# Uses the move the target was about to use this round, with 1.5x power. (Me First)
################################################################################
class PokeBattle_Move_0B0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x73,    # Metal Burst
       0xB0,    # Me First
       0xF1,    # Covet, Thief
       0x115,   # Focus Punch
       0x158,   # Belch
       0x172,   # Κουλούνδιν
       0x817,   # Douze Crayon
       0x245,   # Doom Catapult
       0x246,   # Fiery Catapult
       0x295,   # Grassy Catapult
       0x325    # Elder Special Moves
    ]
    oppmove=@battle.choices[opponent.index][2]
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? ||
       !oppmove || oppmove.id<=0 ||
       oppmove.pbIsStatus? ||
       blacklist.include?(oppmove.function)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.effects[PBEffects::MeFirst]=true
    $PokemonGlobal.pokebox[28]+=1 if @battle.pbOwnedByPlayer?(attacker.index)
    attacker.pbUseMoveSimple(oppmove.id,-1,-1)
    attacker.effects[PBEffects::MeFirst]=false
    return 0
  end
end



################################################################################
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin. (Magic Coat)
################################################################################
class PokeBattle_Move_0B1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagicCoat]=true
    @battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",attacker.pbThis))
    return 0
  end
end



################################################################################
# This round, snatches all used moves with the "D" flag. (Snatch)
################################################################################
class PokeBattle_Move_0B2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Snatch]=true
    @battle.pbDisplay(_INTL("{1} waits for a target to make a move!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Uses a different move depending on the environment. (Nature Power)
################################################################################
class PokeBattle_Move_0B3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    move=getConst(PBMoves,:TRIATTACK) || 0
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass, PBEnvironment::Forest
      move=(getConst(PBMoves,:ENERGYBALL)) || move
    when PBEnvironment::MovingWater; move=getConst(PBMoves,:HYDROPUMP) || move
    when PBEnvironment::StillWater;  move=getConst(PBMoves,:MUDBOMB) || move
    when PBEnvironment::Underwater;  move=getConst(PBMoves,:HYDROPUMP) || move
    when PBEnvironment::Cave
      move=(getConst(PBMoves,:POWERGEM)) || move
    when PBEnvironment::Rock
      move=(getConst(PBMoves,:EARTHPOWER)) || move
    when PBEnvironment::Sand
      move=(getConst(PBMoves,:EARTHPOWER)) || move
    # Ice tiles in Gen 6 should be Ice Beam
    when PBEnvironment::Snow
      move=(getConst(PBMoves,:FROSTBREATH)) || move
    when PBEnvironment::Volcano;     move=getConst(PBMoves,:LAVAPLUME) || move
    when PBEnvironment::Graveyard;   move=getConst(PBMoves,:SHADOWBALL) || move
    when PBEnvironment::Sky;         move=getConst(PBMoves,:AIRSLASH) || move
    when PBEnvironment::Space;       move=getConst(PBMoves,:DRACOMETEOR) || move
    when PBEnvironment::Galaxy;      move=getConst(PBMoves,:MOONBLOVER) || move
    when PBEnvironment::Boardwalk;   move=getConst(PBMoves,:NIGHTSLASH) || move
    when PBEnvironment::Ring;        move=getConst(PBMoves,:AURASPHERE) || move
    end
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      move=getConst(PBMoves,:THUNDERBOLT) || move
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      move=getConst(PBMoves,:ENERGYBALL) || move
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      move=getConst(PBMoves,:MOONBLAST) || move
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      move=getConst(PBMoves,:PSYCHIC) || move
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      move=getConst(PBMoves,:BOLTOPIA) || move
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      move=getConst(PBMoves,:LAVAOVER) || move
     elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      move=getConst(PBMoves,:HEARTSTAMP) || move
   end
    if move==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    thismovename=PBMoves.getName(@id)
    movename=PBMoves.getName(move)
    @battle.pbDisplay(_INTL("{1} turned into {2}!",thismovename,movename))
    target=(opponent) ? opponent.index : -1
    attacker.pbUseMoveSimple(move,-1,target)
    return 0
  end
end



################################################################################
# Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
################################################################################
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::SLEEP
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end 
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x5C,    # Mimic
       0x5D,    # Sketch
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xD1,    # Uproar
       0xD4,    # Bide
       0x115,   # Focus Punch
       0xAF,    # Copycat
       0x220,   # Beak Blast
# Two-turn attacks
       0xC3,    # Razor Wind
       0xC4,    # SolarBeam
       0xC5,    # Freeze Shock
       0xC6,    # Ice Burn
       0xC7,    # Sky Attack
       0xC8,    # Skull Bash
       0xC9,    # Fly
       0xCA,    # Dig
       0xCB,    # Dive
       0xCC,    # Bounce
       0xCD,    # Shadow Force
       0xCE,    # Sky Drop
       0x14D,   # Phantom Force
       0x14E,   # Geomancy
       0x336,   # Steel Fly
       0x378,   # Electro Shot
# Dedicated Moves
       0x172,   # Κουλούνδιν
       0x325    # Elder Special Moves
    ]
    choices=[]
    for i in 0...4
      found=false
      next if attacker.moves[i].id==0
      found=true if blacklist.include?(attacker.moves[i].function)
      next if found
      choices.push(i) if @battle.pbCanChooseMove?(attacker.index,i,false,true)
    end
    if choices.length==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    choice=choices[@battle.pbRandom(choices.length)]
    attacker.pbUseMoveSimple(attacker.moves[choice].id,choice,attacker.pbOppositeOpposing.index)
    return 0
  end
end



################################################################################
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
################################################################################
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x5C,    # Mimic
       0x5D,    # Sketch
       0x69,    # Transform
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x73,    # Metal Burst
       0x9C,    # Helping Hand
       0xAA,    # Detect, Protect
       0xAD,    # Feint
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB2,    # Snatch
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xAF,    # Copycat
       0xCD,    # Shadow Force
       0xE7,    # Destiny Bond
       0xE8,    # Endure
       0xEB,    # Roar, Whirlwind
       0xEC,    # Circle Throw, Dragon Tail
       0xF1,    # Covet, Thief
       0xF2,    # Switcheroo, Trick
       0xF3,    # Bestow
       0x115,   # Focus Punch
       0x117,   # Follow Me, Rage Powder
       0x149,   # Mat Block
       0x14B,   # King's Shield
       0x14C,   # Spiky Shield
       0x14D,   # Phantom Force
       0x158,   # Belch
       0x172,   # Κουλούνδιν
       0x187,   # Douze Crayon
       0x245,   # Doom Catapult
       0x246,   # Fiery Catapult
       0x221,   # Baneful Bunker
       0x220,   # Beak Blast
       0x211,   # Shell Trap
       0x229,   # Spotlight
       0x295,   # Grassy Catapult
       0x325,   # Elder Special Moves
       0x344    # Brainymedia
    ]
    blacklist+=[
       # Two-turn attacks
       0xC3,    # Razor Wind
       0xC4,    # SolarBeam
       0xC5,    # Freeze Shock
       0xC6,    # Ice Burn
       0xC7,    # Sky Attack
       0xC8,    # Skull Bash
       0xC9,    # Fly
       0xCA,    # Dig
       0xCB,    # Dive
       0xCC,    # Bounce
       0xCD,    # Shadow Force
       0xCE,    # Sky Drop
       0x14D,   # Phantom Force
       0x14E,   # Geomancy
       0x336,   # Steel Fly
       0x378    # Electro Shot
    ]
    moves=[]
    party=@battle.pbParty(attacker.index) # NOTE: pbParty is common to both allies in multi battles
    for i in 0...party.length
      if i!=attacker.pokemonIndex && party[i] && !party[i].isEgg?
        for j in party[i].moves
          next if isConst?(j.type,PBTypes,:SHADOW) || 
                  isConst?(j.type,PBTypes,:ROBOT)
          next if j.id==0
          found=false
          moves.push(j.id) if !blacklist.include?(PBMoveData.new(j.id).function)
        end
      end
    end
    if moves.length==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    move=moves[@battle.pbRandom(moves.length)]
    attacker.pbUseMoveSimple(move)
    return 0
  end
end



################################################################################
# Uses a random move that exists. (Metronome)
################################################################################
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x11,    # Snore
       0x14,    # Chatter
       0x5C,    # Mimic
       0x5D,    # Sketch
       0x69,    # Transform
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x73,    # Metal Burst
       0x9C,    # Helping Hand
       0xAA,    # Detect, Protect
       0xAB,    # Quick Guard
       0xAC,    # Wide Guard
       0xAD,    # Feint
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB2,    # Snatch
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xE7,    # Destiny Bond
       0xE8,    # Endure
       0xF1,    # Covet, Thief
       0xF2,    # Switcheroo, Trick
       0xF3,    # Bestow
       0x115,   # Focus Punch
       0x117,   # Follow Me, Rage Powder
       0x11D,   # After You
       0x11E,   # Quash
       0xAF,    # Copycat
       0x172,   # Κουλούνδιν
       0x187,   # Douze Crayon
       0x245,   # Doom Catapult
       0x246,   # Fiery Catapult
       0x221,   # Baneful Bunker
       0x220,   # Beak Blast
       0x212,   # Instruct
       0x229,   # Spotlight
       0x295,   # Grassy Catapult
       0x325,   # Elder Special Moves
       0x344    # Brainymedia
    ]
    blacklistmoves=[
       :DIAMONDSTORM,
       :DRAGONASCENT,
       :FLEURCANNON,
       :FREEZESHOCK,
       :GEOMANCY,
       :HYPERSPACEFURY,
       :HYPERSPACEHOLE,
       :ICEBURN,
       :LIGHTOFRUIN,
       :MINDBLOWN,
       :ORIGINPULSE,
       :PHOTONGEYSER,
       :PLASMAFISTS,
       :PRECIPICEBLADES,
       :RELICSONG,
       :SECRETSWORD,
       :SNARL,
       :SPECTRALTHIEF,
       :STEAMERUPTION,
       :TECHNOBLAST,
       :THOUSANDARROWS,
       :THOUSANDWAVES,
       :VCREATE,
       :KLEOPOTRIA,
       :CHROMELICKS,
       :LOBBY,
       :SUPERMIND,
       :LICKSTART
    ]
    if !attacker.hasWorkingAbility(:SIAXIS)
      blacklistmoves+=[
         :SIAXIS
      ]
    end
    i=0; loop do break unless i<1000
      move=@battle.pbRandom(PBMoves.maxValue)+1
      next if isConst?(PBMoveData.new(move).type,PBTypes,:SHADOW) ||
              isConst?(PBMoveData.new(move).type,PBTypes,:ROBOT)
      found=false
      if blacklist.include?(PBMoveData.new(move).function)
        found=true
      else
        for j in blacklistmoves
          if isConst?(move,PBMoves,j)
            found=true
            break
          end
        end
      end
      if !found
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
        attacker.pbUseMoveSimple(move)
        return 0
      end
      i+=1
    end
		pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# The target can no longer use the same move twice in a row. (Torment)
################################################################################
class PokeBattle_Move_0B7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Torment] || opponent.pbHasType?(:HERB) ||
      opponent.pbHasType?(:MIND) || opponent.pbHasType?(:GLIMSE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Torment]=true
    @battle.pbDisplay(_INTL("{1} was subjected to torment!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Disables all target's moves that the user also knows. (Imprison)
################################################################################
class PokeBattle_Move_0B8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Imprison]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Imprison]=true
    @battle.pbDisplay(_INTL("{1} sealed the opponent's move(s)!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the last move the target used. (Disable)
################################################################################
class PokeBattle_Move_0B9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Disable]>0 || opponent.pbHasType?(:HERB) ||
      opponent.pbHasType?(:MIND) || opponent.pbHasType?(:GLIMSE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    for i in opponent.moves
      if i.id>0 && i.id==opponent.lastMoveUsed && (i.pp>0 || i.totalpp==0)
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.effects[PBEffects::Disable]=5
        opponent.effects[PBEffects::DisableMove]=opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",opponent.pbThis,i.name))
        return 0
      end
    end
		pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
################################################################################
class PokeBattle_Move_0BA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Taunt]>0 ||
       (!attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:OBLIVIOUS)) ||
        opponent.pbHasType?(:HERB) || opponent.pbHasType?(:MIND) || 
        opponent.pbHasType?(:GLIMSE)
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Taunt]=4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the target's healing moves. (Heal Block)
################################################################################
class PokeBattle_Move_0BB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if opponent.effects[PBEffects::HealBlock]>0 || opponent.pbHasType?(:HERB) ||
      opponent.pbHasType?(:MIND) || opponent.pbHasType?(:GLIMSE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::HealBlock]=5
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.effects[PBEffects::HealBlock]==0 &&
       !(opponent.pbHasType?(:HERB) || opponent.pbHasType?(:MIND) || 
         opponent.pbHasType?(:GLIMSE))
      healblock=true
      if !attacker.hasMoldBreaker(opponent)
        healblock=false if opponent.hasWorkingAbility(:AROMAVEIL) ||
                           opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
      end
      if healblock
        opponent.effects[PBEffects::HealBlock]=5
        @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
      end
    end
  end
end



################################################################################
# For 4 rounds, the target must use the same move each round. (Encore)
################################################################################
class PokeBattle_Move_0BC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0xB5,    # Assist 
       0xAF,    # Copycat
       0xBC,    # Encore
       0xB0,    # Me First
       0xB6,    # Metronome
       0x5C,    # Mimic
       0xAE,    # Mirror Move
       0xB3,    # Nature Power
       0x5D,    # Sketch
       0xB4,    # Sleep Talk
       0x02,    # Struggle
       0x69,    # Transform
       0x171,   # Lick Lock
       0x172,   # Κουλούνδιν
       0x173,   # Herbotopia 
       0x174,   # SIAXIS, Park Damage and Glimsey Treat
       0x186,   # Intimidate
       0x187,   # Douze Crayon
       0x189,   # Intimidoom
       0x243,   # Intimilow
       0x245,   # Doom Catapult
       0x246,   # Fiery Catapult
       0x295,   # Grassy Catapult
       0x325    # Elder Special Moves
    ]
    if opponent.effects[PBEffects::Encore]>0 || opponent.pbHasType?(:HERB) ||
      opponent.pbHasType?(:MIND) || opponent.hasWorkingAbility(:KOULUNDIN) ||
      opponent.pbHasType?(:GLIMSE)
 			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    for i in 0...4
      if opponent.lastMoveUsed==opponent.moves[i].id &&
         (opponent.moves[i].pp>0 || opponent.moves[i].totalpp==0)
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.effects[PBEffects::Encore]=4
        opponent.effects[PBEffects::EncoreIndex]=i
        opponent.effects[PBEffects::EncoreMove]=opponent.moves[i].id
        @battle.pbDisplay(_INTL("{1} received an encore!",opponent.pbThis))
        return 0
      end
    end
			pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Hits twice.
################################################################################
class PokeBattle_Move_0BD < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
end



################################################################################
# Hits twice. May poison the target on each hit. (Twineedle)
################################################################################
class PokeBattle_Move_0BE < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanPoison?(attacker,false,self)
      opponent.pbPoison(attacker)
    end
  end
end



################################################################################
# Hits 3 times. Power is multiplied by the hit number. (Triple Kick)
# An accuracy check is performed for each hit.
################################################################################
class PokeBattle_Move_0BF < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end

  def successCheckPerHit?
    return @checks
  end

  def pbOnStartUse(attacker)
    @calcbasedmg=@basedamage
    @checks=!(attacker.hasWorkingAbility(:SKILLLINK) || 
              attacker.hasWorkingItem(:LOADEDDICE))
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    @calcbasedmg+=basedmg
    return ret
  end
end



################################################################################
# Hits 2-5 times.
################################################################################
class PokeBattle_Move_0C0 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    hitchances=[2,2,3,3,4,5]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=5 if attacker.hasWorkingAbility(:SKILLLINK)
    ret=4 if attacker.hasWorkingItem(:LOADEDDICE) && ret < 4
    return ret
  end
end



################################################################################
# Hits X times, where X is 1 (the user) plus the number of non-user unfainted
# status-free Pokémon in the user's party (the participants). Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
################################################################################
class PokeBattle_Move_0C1 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return @participants.length
  end

  def pbOnStartUse(attacker)
    party=@battle.pbParty(attacker.index)
    @participants=[]
    for i in 0...party.length
      if attacker.pokemonIndex==i
        @participants.push(i)
      elsif party[i] && !party[i].isEgg? && party[i].hp>0 && party[i].status==0
        @participants.push(i)
      end
    end
    if @participants.length==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    party=@battle.pbParty(attacker.index)
    atk=party[@participants[0]].baseStats[1]
    @participants[0]=nil; @participants.compact!
    return 5+(atk/10)
  end
end



################################################################################
# Two turn attack. Attacks first turn, skips second turn (if successful).
################################################################################
class PokeBattle_Move_0C2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Razor Wind)
################################################################################
class PokeBattle_Move_0C3 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (SolarBeam)
# Power halved in all weather except sunshine. In sunshine, takes 1 turn instead.
################################################################################
class PokeBattle_Move_0C4 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false; @sunny=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      if (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        @immediate=true; @sunny=true
      end
    end
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.pbWeather!=0 &&
       @battle.pbWeather!=PBWeather::SUNNYDAY &&
       @battle.pbWeather!=PBWeather::HARSHSUN
      return (damagemult*0.5).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} took in sunlight!",attacker.pbThis))
    end
    if @immediate && !@sunny
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end




################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Freeze Shock)
# May paralyze the target.
################################################################################
class PokeBattle_Move_0C5 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
  
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Ice Burn)
# May burn the target.
################################################################################
class PokeBattle_Move_0C6 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
  
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanBurn?(attacker,false,self)
      opponent.pbBurn(attacker)
    end
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Sky Attack)
# May make the target flinch.
################################################################################
class PokeBattle_Move_0C7 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} became cloaked in a harsh light!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Two turn attack. Ups user's Defense by 1 stage first turn, attacks second turn.
# (Skull Bash)
################################################################################
class PokeBattle_Move_0C8 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} tucked in its head!",attacker.pbThis))
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self)
      end
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Fly)
# (Handled in Battler's pbSuccessCheck): Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0C9 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Dig)
# (Handled in Battler's pbSuccessCheck): Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CA < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Dive)
# Water Splash: Decreases the target's Speed by 1 stage.
# (Handled in Battler's pbSuccessCheck): Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CB < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} hid underwater!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self) && 
       attacker.effects[PBEffects::TwoTurnAttack]==0 && 
       isConst?(@id,PBMoves,:WATERSPLASH)
      opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    end
  end


end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Bounce)
# May paralyze the target.
# (Handled in Battler's pbSuccessCheck): Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CC < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} sprang up!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Shadow Force)
# Is semi-invulnerable during use.
# Ignores target's Detect, King's Shield, Mat Block, Protect and Spiky Shield
# this round. If successful, negates them this round.
################################################################################
class PokeBattle_Move_0CD < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if ret>0
      opponent.effects[PBEffects::ProtectNegation]=true
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
    end
    return ret
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Sky Drop)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_0CE < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbMoveFailed(attacker,opponent)
    ret=false
    ret=true if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
    ret=true if opponent.effects[PBEffects::TwoTurnAttack]>0
    ret=true if opponent.effects[PBEffects::SkyDrop] && attacker.effects[PBEffects::TwoTurnAttack]>0
    ret=true if !opponent.pbIsOpposing?(attacker.index)
    ret=true if opponent.weight(attacker)>=2000
    return ret
  end

  def pbTwoTurnAttack(attacker)
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} took {2} into the sky!",attacker.pbThis,opponent.pbThis(true)))
      opponent.effects[PBEffects::SkyDrop]=true
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    ret=super
    @battle.pbDisplay(_INTL("{1} was freed from the Sky Drop!",opponent.pbThis))
    opponent.effects[PBEffects::SkyDrop]=false
    return ret
  end

  def pbTypeModifier(type,attacker,opponent)
    return 0 if opponent.pbHasType?(:FLYING)
    return 0 if !attacker.hasMoldBreaker(opponent) &&
       opponent.hasWorkingAbility(:LEVITATE) && !opponent.effects[PBEffects::SmackDown]
    return super
  end
end



################################################################################
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
################################################################################
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.isFainted? &&
       !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=5+@battle.pbRandom(2)
        if attacker.hasWorkingItem(:GRIPCLAW)
          opponent.effects[PBEffects::MultiTurn]=8
        end
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        if isConst?(@id,PBMoves,:BIND)
          @battle.pbDisplay(_INTL("{1} was squeezed by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:CLAMP)
          @battle.pbDisplay(_INTL("{1} clamped {2}!",attacker.pbThis,opponent.pbThis(true)))
        elsif isConst?(@id,PBMoves,:FIRESPIN)
          @battle.pbDisplay(_INTL("{1} was trapped in the fiery vortex!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:MAGMASTORM)
          @battle.pbDisplay(_INTL("{1} became trapped by Magma Storm!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:SANDTOMB)
          @battle.pbDisplay(_INTL("{1} became trapped by Sand Tomb!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:WRAP)
          @battle.pbDisplay(_INTL("{1} was wrapped by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:INFESTATION)
          @battle.pbDisplay(_INTL("{1} has been afflicted with an infestation by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:SNAPTRAP)
          opponent.effects[PBEffects::MultiTurn]-=1 # Traps for 4 or 5 rounds (or 7 if holding Grip Claw)
          @battle.pbDisplay(_INTL("{1} got trapped by a snap trap!",opponent.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        end
      end
    end
    return ret
  end
end



################################################################################
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round. (Whirlpool)
# Power is doubled if target is using Dive.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_0D0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.isFainted? &&
       !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=5+@battle.pbRandom(2)
        if attacker.hasWorkingItem(:GRIPCLAW)
          opponent.effects[PBEffects::MultiTurn]=8
        end
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        @battle.pbDisplay(_INTL("{1} became trapped in the vortex!",opponent.pbThis))
      end
    end
    return ret
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
################################################################################
class PokeBattle_Move_0D1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::Uproar]==0
        attacker.effects[PBEffects::Uproar]=3
        @battle.pbDisplay(_INTL("{1} caused an uproar!",attacker.pbThis))
        attacker.currentMove=@id
      end
    end
    return ret
  end
end



################################################################################
# User must use this move for 1 or 2 more rounds. At end, user becomes confused.
# (Outrage, Petal Dange, Thrash)
################################################################################
class PokeBattle_Move_0D2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 &&
       attacker.effects[PBEffects::Outrage]==0 && 
       attacker.status!=PBStatuses::SLEEP
      attacker.effects[PBEffects::Outrage]=2+@battle.pbRandom(2)
      attacker.currentMove=@id
    elsif pbTypeModifier(@type,attacker,opponent)==0
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Outrage]=0
    end
    if attacker.effects[PBEffects::Outrage]>0
      attacker.effects[PBEffects::Outrage]-=1
      if attacker.effects[PBEffects::Outrage]==0 && attacker.pbCanConfuseSelf?(false)
        attacker.pbConfuse
        @battle.pbDisplay(_INTL("{1} became confused due to fatigue!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User must use this move for 4 more rounds. Power doubles each round.
# Power is also doubled if user has curled up. (Ice Ball, Rollout)
################################################################################
class PokeBattle_Move_0D3 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    shift=(4-attacker.effects[PBEffects::Rollout]) # from 0 through 4, 0 is most powerful
    shift+=1 if attacker.effects[PBEffects::DefenseCurl]
    basedmg=basedmg<<shift
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::Rollout]=5 if attacker.effects[PBEffects::Rollout]==0
    attacker.effects[PBEffects::Rollout]-=1
    attacker.currentMove=thismove.id
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage==0 ||
       pbTypeModifier(@type,attacker,opponent)==0 || 
       attacker.status==PBStatuses::SLEEP
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Rollout]=0
    end
    return ret
  end
end



################################################################################
# User bides its time this round and next round. The round after, deals 2x the
# total damage it took while biding to the last battler that damaged it. (Bide)
################################################################################
class PokeBattle_Move_0D4 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.effects[PBEffects::Bide]==0
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
      attacker.effects[PBEffects::Bide]=2
      attacker.effects[PBEffects::BideDamage]=0
      attacker.effects[PBEffects::BideTarget]=-1
      attacker.currentMove=@id
      pbShowAnimation(@id,attacker,nil)
      return 1
    else
      attacker.effects[PBEffects::Bide]-=1
      if attacker.effects[PBEffects::Bide]==0
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",attacker.pbThis))
        return 0
      else
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!",attacker.pbThis))
        pbShowAnimation(@id,attacker,nil)
        return 2
      end
    end
  end

  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::BideTarget]>=0
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::BideTarget]])
        attacker.pbRandomTarget(targets)
      end
    else
      attacker.pbRandomTarget(targets)
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::BideDamage]==0 || !opponent
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    typemod=pbTypeModifier(pbType(@type,attacker,opponent),attacker,opponent)
    if typemod==0
    pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    showanimation=false
    pbShowAnimation(@id,attacker,opponent,1,alltargets,true)
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::BideDamage]*2,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# Heals user by 1/2 of its max HP.
################################################################################
class PokeBattle_Move_0D5 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
################################################################################
class PokeBattle_Move_0D6 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    attacker.effects[PBEffects::Roost]=true
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
################################################################################
class PokeBattle_Move_0D7 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Wish]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Wish]=2
    attacker.effects[PBEffects::WishAmount]=((attacker.totalhp+1)/2).floor
    attacker.effects[PBEffects::WishMaker]=attacker.pokemonIndex
    return 0
  end
end



################################################################################
# Heals user by an amount depending on the weather. (Moonlight, Morning Sun,
# Synthesis, Night Moon)
################################################################################
class PokeBattle_Move_0D8 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if (@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      hpgain=(attacker.totalhp*2/3).floor
    elsif @battle.pbWeather!=0
      hpgain=(attacker.totalhp/4).floor
    else
      hpgain=(attacker.totalhp/2).floor
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
################################################################################
class PokeBattle_Move_0D9 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanSleep?(attacker,true,self,true)
      return -1
    end
    if attacker.status==PBStatuses::SLEEP
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbSleepSelf(3)
    @battle.pbDisplay(_INTL("{1} slept and became healthy!",attacker.pbThis))
    hp=attacker.pbRecoverHP(attacker.totalhp-attacker.hp,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis)) if hp>0
    return 0
  end
end



################################################################################
# Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
# (Aqua Ring)
################################################################################
class PokeBattle_Move_0DA < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::AquaRing]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::AquaRing]=true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
################################################################################
class PokeBattle_Move_0DB < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Ingrain]=true
    @battle.pbDisplay(_INTL("{1} planted its roots!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Seeds the target. Seeded Pokémon lose 1/8 of max HP at the end of each round,
# and the Pokémon in the user's position gains the same amount. (Leech Seed)
################################################################################
class PokeBattle_Move_0DC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.isFainted?
        if !(opponent.effects[PBEffects::LeechSeed]>=0 ||
           opponent.pbHasType?(:GRASS) || opponent.pbHasType?(:CHLOROPHYLL))
            opponent.effects[PBEffects::LeechSeed]=attacker.index
            @battle.pbDisplay(_INTL("{1} was seeded!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.effects[PBEffects::LeechSeed]>=0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
      return -1
    end
    if opponent.pbHasType?(:GRASS) || opponent.pbHasType?(:CHLOROPHYLL)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LeechSeed]=attacker.index
    @battle.pbDisplay(_INTL("{1} was seeded!",opponent.pbThis))
    return 0
  end
end



################################################################################
# User gains half the HP it inflicts as damage.
################################################################################
class PokeBattle_Move_0DD < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost/2).round
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User gains half the HP it inflicts as damage. (Dream Eater)
# (Handled in Battler's pbSuccessCheck): Fails if target is not asleep.
################################################################################
class PokeBattle_Move_0DE < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost/2).round
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Heals target by 1/2 of its max HP. (Heal Pulse)
################################################################################
class PokeBattle_Move_0DF < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hp==opponent.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    hpgain=((opponent.totalhp+1)/2).floor
    hpgain=(opponent.totalhp*3/4).round if attacker.hasWorkingAbility(:MEGALAUNCHER)
    opponent.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))  
    return 0
  end
end



################################################################################
# User faints. (Explosion, Selfdestruct)
# Herb Leaf: Power is doubled if the user has status problem.
#            Accuracy perfect for Herb, Chlorophyll and SIAXIS-ability Pokemon
#            Power is halved during Electric and Volcanic Terrains (Gen7+)
# Lick Start: Move is usable while asleep and skips accuracy checks with that way
#             Move is usable even if a Pokemon has Damp and doubles its power
#             if so (Gen5+)
# Gustopia and Chloropia: Power is doubled if the user shares the move's type
# Misty Explosion: Power is increased in Misty Terrain
################################################################################
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if !attacker.hasMoldBreaker(nil)
      bearer=@battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil && !attacker.pbHasType?(:HEART) &&
        !isConst?(@id,PBMoves,:LICKSTART)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
           bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
        return false
      end
    end
    return true
  end

  def pbCanUseWhileAsleep?
    return isConst?(@id,PBMoves,:LICKSTART)
  end  

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:HERBLEAF) &&
        (@battle.pbTerrain==PBBattleTerrains::ELECTRIC || 
         @battle.pbTerrain==PBBattleTerrains::VOLCANIC) &&
        !attacker.status>0
      return (damagemult*0.5).round
    end
    if (isConst?(@id,PBMoves,:HERBLEAF) &&
        attacker.status>0 && 
        @battle.pbTerrain!=PBBattleTerrains::ELECTRIC && 
        @battle.pbTerrain!=PBBattleTerrains::VOLCANIC) ||
        (isConst?(@id,PBMoves,:LICKSTART) && @battle.pbCheckGlobalAbility(:DAMP)) ||
        (isConst?(@id,PBMoves,:GUSTOPIA) && attacker.pbHasType?(:GUST)) ||
        (isConst?(@id,PBMoves,:CHLOROPIA) && attacker.pbHasType?(:CHLOROPHYLL)) ||
        (isConst?(@id,PBMoves,:MISTYEXPLOSION) && 
         @battle.pbTerrain==PBBattleTerrains::MISTY)
      return (damagemult*2.0).round
    end
    return damagemult
  end

  
  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
      if (isConst?(@id,PBMoves,:HERBLEAF) &&
          (attacker.hasWorkingAbility(:SIAXIS) || 
           attacker.pbHasType?(:HERB) ||
           attacker.pbHasType?(:CHLOROPHYLL) ||
           attacker.pbHasType?(:GLIMSE))) ||
         (isConst?(@id,PBMoves,:LICKSTART) && attacker.status==PBStatuses::SLEEP)
        return 0
      end
      return baseaccuracy
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    super(id,attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && 
       !(attacker.hasWorkingAbility(:SIAXIS) || attacker.pbHasType?(:CHLOROPHYLL) ||
        attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
      attacker.pbFaint if attacker.isFainted?
    end
  end
end



################################################################################
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
################################################################################
class PokeBattle_Move_0E1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    typemod=pbTypeModifier(pbType(@type,attacker,opponent),attacker,opponent)
    if typemod==0
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.hp,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    super(id,attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? &&
       !(attacker.hasWorkingAbility(:SIAXIS) || attacker.pbHasType?(:CHLOROPHYLL) ||
         attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
      attacker.pbFaint if attacker.isFainted?
    end
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 2 stages each. (Memento)
# User faints (even if effect does nothing).
################################################################################
class PokeBattle_Move_0E2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
    if opponent.pbReduceStat(PBStats::ATTACK,2,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if !(attacker.hasWorkingAbility(:SIAXIS) || 
         attacker.hasWorkingAbility(:ANTIMENTO) || attacker.pbHasType?(:CHLOROPHYLL) ||
         attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
    end
    return ret
  end
end



################################################################################
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status). Fails if user won't be replaced. (Healing Wish)
################################################################################
class PokeBattle_Move_0E3 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index) || attacker.hasWorkingAbility(:SIAXIS)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::HealingWish]=true
    return 0
  end
end



################################################################################
# User faints. The Pokémon that replaces the user is fully healed (HP, PP and
# status). Fails if user won't be replaced. (Lunar Dance)
################################################################################
class PokeBattle_Move_0E4 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index) || attacker.hasWorkingAbility(:SIAXIS)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::LunarDance]=true
    return 0
  end
end



################################################################################
# All current battlers will perish after 3 more rounds. (Perish Song)
################################################################################
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=true
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0 &&
         (attacker.hasMoldBreaker(opponent) ||
         !@battle.battlers[i].hasWorkingAbility(:SOUNDPROOF))
        failed=false; break
      end   
    end
    if failed
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All Pokémon that hear the song will faint in three turns!"))
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0
        if !attacker.hasMoldBreaker(opponent) && @battle.battlers[i].hasWorkingAbility(:SOUNDPROOF)
        pbPlayMissSE()
          @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",@battle.battlers[i].pbThis,
             PBAbilities.getName(@battle.battlers[i].ability),@name))
        else
          @battle.battlers[i].effects[PBEffects::PerishSong]=4
          @battle.battlers[i].effects[PBEffects::PerishSongUser]=attacker.index
        end
      end
    end
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the attack that caused it loses all PP.
# (Grudge)
################################################################################
class PokeBattle_Move_0E6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Grudge]=true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the battler that caused it also faints.
# (Destiny Bond)
################################################################################
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret = super(attacker,opponent,hitnum,alltargets,showanimation)
      if !attacker.effects[PBEffects::DestinyBond]
        attacker.effects[PBEffects::DestinyBond]=true
        @battle.pbDisplay(_INTL("{1} is trying to take its foe down with it!",attacker.pbThis))
      end
      return ret
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::DestinyBond]=true
    @battle.pbDisplay(_INTL("{1} is trying to take its foe down with it!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
################################################################################
class PokeBattle_Move_0E8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved ||
       @battle.pbRandom(65536)>(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Endure]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} braced itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If target would be KO'd by this attack, it survives with 1HP instead. (False Swipe)
################################################################################
class PokeBattle_Move_0E9 < PokeBattle_Move
# Handled in superclass def pbReduceHPDamage, do not edit!
end



################################################################################
# User flees from battle. User switches out in trainer battles. (Teleport)
################################################################################
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanRun?(attacker.index)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.opponent
      attacker.effects[PBEffects::Uturn]=true
    else
      @battle.pbDisplay(_INTL("{1} fled from battle!",attacker.pbThis))
      @battle.decision=3
    end
    return 0
  end
end



################################################################################
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
################################################################################
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.hasMoldBreaker(opponent) && ( opponent.hasWorkingAbility(:SUCTIONCUPS) ||
                                     opponent.hasWorkingAbility(:ENIGMATACTICS) ||
                                     opponent.hasWorkingAbility(:GUARDDOG))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return -1
    end
    if opponent.hasWorkingItem(:ASPEARVEST)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",opponent.pbThis,PBItems.getName(opponent.item)))  
      return -1
    end
    if opponent.effects[PBEffects::Ingrain]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",opponent.pbThis))  
      return -1
    end
    if !@battle.opponent
      if opponent.level>attacker.level || 
         opponent.effects[PBEffects::CommanderAlly]
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.decision=3 # Set decision to escaped
      return 0
    else
      choices=false
      party=@battle.pbParty(opponent.index)
      for i in 0...party.length
        if @battle.pbCanSwitch?(opponent.index,i,false,true)
          choices=true
          break
        end
      end
      if !choices
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.effects[PBEffects::Roar]=true
      return 0
    end
  end
end



################################################################################
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For damaging moves. (Circle Throw, Dragon Tail)
################################################################################
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && !opponent.isFainted? &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       (attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:SUCTIONCUPS) || 
        !opponent.hasWorkingAbility(:ENIGMATACTICS) ||
        !opponent.hasWorkingAbility(:GUARDDOG)) &&
       !opponent.effects[PBEffects::Ingrain] &&
       !opponent.effects[PBEffects::CommanderAlly] &&
       !opponent.hasWorkingItem(:ASPEARVEST)
      if !@battle.opponent
        if opponent.level<=attacker.level
          @battle.decision=3 # Set decision to escaped
        end
      else
        party=@battle.pbParty(opponent.index)
        for i in 0..party.length-1
          if @battle.pbCanSwitch?(opponent.index,i,false)
            opponent.effects[PBEffects::Roar]=true
            break
          end
        end
      end
    end
  end
end



################################################################################
# User switches out. Various effects affecting the user are passed to the
# replacement. (Baton Pass)
################################################################################
class PokeBattle_Move_0ED < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::BatonPass]=true
    return 0
  end
end



################################################################################
# After inflicting damage, user switches out. Ignores trapping moves.
# (U-turn, Volt Switch)
# TODO: Pursuit should interrupt this move.
################################################################################
class PokeBattle_Move_0EE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      attacker.effects[PBEffects::Uturn]=true
    end
    return ret
  end
end



################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# (Block, Mean Look, Spider Web, Thousand Waves)
################################################################################
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.isFainted?
        if opponent.effects[PBEffects::MeanLook]<0 &&
           !(opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) ||
             opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
          opponent.effects[PBEffects::MeanLook]=attacker.index
          @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::MeanLook]>=0 ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
        opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
################################################################################
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && !opponent.isFainted? && opponent.item!=0 &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item)
        itemname=PBItems.getName(opponent.item)
        opponent.item=0
        opponent.pokemon.corrosiveGas=false
        opponent.effects[PBEffects::ChoiceBand]=-1
        opponent.effects[PBEffects::Unburden]=true
        @battle.pbDisplay(_INTL("{1} dropped its {2}!",opponent.pbThis,itemname))
      end
    end
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if !@battle.pbIsUnlosableItem(opponent,opponent.item)
       # Still boosts damage even if opponent has Sticky Hold
      return (damagemult*1.5).round
    end
    return damagemult
  end
end



################################################################################
# User steals the target's item, if the user has none itself. (Covet, Thief)
# Items stolen from wild Pokémon are kept after the battle.
################################################################################
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && !opponent.isFainted? && opponent.item!=0 &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item) &&
            !@battle.pbIsUnlosableItem(attacker,opponent.item) &&
            attacker.item==0 &&
            (@battle.opponent || !@battle.pbIsOpposing?(attacker.index))
        itemname=PBItems.getName(opponent.item)
        attacker.item=opponent.item
        opponent.item=0
        if opponent.pokemon.corrosiveGas
          opponent.pokemon.corrosiveGas=false
          attacker.pokemon.corrosiveGas=true
        end
        opponent.effects[PBEffects::ChoiceBand]=-1
        opponent.effects[PBEffects::Unburden]=true
        if !@battle.opponent && # In a wild battle
           attacker.pokemon.itemInitial==0 &&
           opponent.pokemon.itemInitial==attacker.item
          attacker.pokemon.itemInitial=attacker.item
          opponent.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
  end
end



################################################################################
# User and target swap items. They remain swapped after wild battles.
# (Switcheroo, Trick)
################################################################################
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       (attacker.item==0 && opponent.item==0) ||
       (!@battle.opponent && @battle.pbIsOpposing?(attacker.index))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(opponent,opponent.item) ||
       @battle.pbIsUnlosableItem(attacker,opponent.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item) ||
       @battle.pbIsUnlosableItem(attacker,attacker.item)
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STICKYHOLD)
      abilityname=PBAbilities.getName(opponent.ability)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,name))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldattitem=attacker.item
    oldoppitem=opponent.item
    oldattitemname=PBItems.getName(oldattitem)
    oldoppitemname=PBItems.getName(oldoppitem)
    tempEffect=attacker.pokemon.corrosiveGas
    attacker.pokemon.corrosiveGas=opponent.pokemon.corrosiveGas
    opponent.pokemon.corrosiveGas=tempEffect
    tmpitem=attacker.item
    attacker.item=opponent.item
    opponent.item=tmpitem
    if !@battle.opponent && # In a wild battle
       attacker.pokemon.itemInitial==oldattitem &&
       opponent.pokemon.itemInitial==oldoppitem
      attacker.pokemon.itemInitial=oldoppitem
      opponent.pokemon.itemInitial=oldattitem
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",attacker.pbThis))
    if oldoppitem>0 && oldattitem>0
      @battle.pbDisplayPaused(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname))
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname))
    else
      @battle.pbDisplay(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname)) if oldoppitem>0
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname)) if oldattitem>0
    end
    attacker.effects[PBEffects::ChoiceBand]=-1
    opponent.effects[PBEffects::ChoiceBand]=-1
    return 0
  end
end



################################################################################
# User gives its item to the target. The item remains given after wild battles.
# (Bestow)
################################################################################
class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       attacker.item==0 || opponent.item!=0
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(attacker,attacker.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item)
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    itemname=PBItems.getName(attacker.item)
    opponent.item=attacker.item
    attacker.item=0
    if attacker.pokemon.corrosiveGas
      attacker.pokemon.corrosiveGas=false
      opponent.pokemon.corrosiveGas=true
    end
    attacker.effects[PBEffects::ChoiceBand]=-1
    attacker.effects[PBEffects::Unburden]=true
    if !@battle.opponent && # In a wild battle
       opponent.pokemon.itemInitial==0 &&
       attacker.pokemon.itemInitial==opponent.item
      opponent.pokemon.itemInitial=opponent.item
      attacker.pokemon.itemInitial=0
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!",opponent.pbThis,itemname,attacker.pbThis(true)))
    return 0
  end
end



################################################################################
# User consumes target's berry and gains its effect. (Bug Bite, Pluck)
################################################################################
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && !opponent.isFainted? && pbIsBerry?(opponent.item) &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:STICKYHOLD) &&
       !opponent.pokemon.corrosiveGas
        item=opponent.item
        itemname=PBItems.getName(item)
        opponent.pbConsumeItem(false,false)
        @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",attacker.pbThis,itemname))
        if !attacker.hasWorkingAbility(:KLUTZ) &&
           attacker.effects[PBEffects::Embargo]==0 &&
          attacker.pbActivateBerryEffect(item,false)
        end
        # Symbiosis
        if attacker.item==0 &&
           attacker.pbPartner && attacker.pbPartner.hasWorkingAbility(:SYMBIOSIS)
          partner=attacker.pbPartner
          if partner.item>0 &&
             !@battle.pbIsUnlosableItem(partner,partner.item) &&
             !@battle.pbIsUnlosableItem(attacker,partner.item)
            @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
               partner.pbThis,PBAbilities.getName(partner.ability),
               PBItems.getName(partner.item),attacker.pbThis(true)))
            attacker.item=partner.item
            partner.item=0
            partner.effects[PBEffects::Unburden]=true
            attacker.pbBerryCureCheck
          end
        end
      end
    end
  end
end



################################################################################
# Target's berry is destroyed. (Incinerate)
################################################################################
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute &&
       (pbIsBerry?(opponent.item) || pbIsGem?(opponent.item))
      itemname=PBItems.getName(opponent.item)
      opponent.pbConsumeItem(false,false)
      @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",opponent.pbThis,itemname))
    end
    return ret
  end
end



################################################################################
# User recovers the last item it held and consumed. (Recycle)
################################################################################
class PokeBattle_Move_0F6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pokemon || attacker.pokemon.itemRecycle==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    item=attacker.pokemon.itemRecycle
    itemname=PBItems.getName(item)
    attacker.item=item
    if !@battle.opponent # In a wild battle
      attacker.pokemon.itemInitial=item if attacker.pokemon.itemInitial==0
    end
    attacker.pokemon.itemRecycle=0
    attacker.effects[PBEffects::PickupItem]=0
    attacker.effects[PBEffects::PickupUse]=0
    @battle.pbDisplay(_INTL("{1} found one {2}!",attacker.pbThis,itemname))
    return 0
  end
end



################################################################################
# User flings its item at the target. Power and effect depend on the item. (Fling)
################################################################################
class PokeBattle_Move_0F7 < PokeBattle_Move
  def flingarray
    return {
       130 => [:IRONBALL],
       100 => [:ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HARDSTONE,
               :HELIXFOSSIL,:JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:RAREBONE,
               :ROOTFOSSIL,:SAILFOSSIL,:SKULLFOSSIL],
        90 => [:DEEPSEATOOTH,:DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,
               :FLAMEPLATE,:GRIPCLAW,:ICICLEPLATE,:INSECTPLATE,:IRONPLATE,
               :MEADOWPLATE,:MINDPLATE,:PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,
               :SPOOKYPLATE,:STONEPLATE,:THICKCLUB,:TOXICPLATE,:ZAPPLATE],
        80 => [:ABOMASITE,:ABSOLITE,:AERODACTYLITE,:AGGRONITE,:ALAKAZITE,
               :ALTARIANITE,:AMPHAROSITE,:ASSAULTVEST,:AUDINITE,:BANETTITE,
               :BEEDRILLITE,:BLASTOISINITE,:BLAZIKENITE,:CAMERUPTITE,
               :CHARIZARDITEX,:CHARIZARDITEY,:DAWNSTONE,:DIANCITE,:DUSKSTONE,
               :ELECTIRIZER,:GALLADITE,:GARCHOMPITE,:GARDEVOIRITE,:GENGARITE,
               :GLALITITE,:GYARADOSITE,:HERACRONITE,:HOUNDOOMINITE,
               :KANGASKHANITE,:LATIASITE,:LATIOSITE,:LOPUNNITE,:LUCARIONITE,
               :MAGMARIZER,:MANECTITE,:MAWILITE,:MEDICHAMITE,:METAGROSSITE,
               :MEWTWONITEX,:MEWTWONITEY,:ODDKEYSTONE,:OVALSTONE,:PIDGEOTITE,
               :PINSIRITE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SABLENITE,:SACHET,
               :SAFETYGOGGLES,:SALAMENCITE,:SCEPTILITE,:SCIZORITE,:SHARPEDONITE,
               :SHINYSTONE,:SLOWBRONITE,:STEELIXITE,:STICKYBARB,:SWAMPERTITE,
               :TYRANITARITE,:VENUSAURITE,:WEAKNESSPOLICY,:WHIPPEDDREAM],
        70 => [:BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:DRAGONFANG,:POISONBARB,
               :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
               :POWERWEIGHT,:SHOCKDRIVE],
        60 => [:ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LUSTROUSORB,
               :MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER],
        50 => [:BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:DUBIOUSDISC,
               :ELECTRICMEMORY,:FAIRYMEMORY,:FIGHTINGMEMORY,:FIREMEMORY,
               :FLYINGMEMORY,:GHOSTMEMORY,:GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,
               :POISONMEMORY,:PSYCHICMEMORY,:ROCKMEMORY,:SHARPBEAK,:STEELMEMORY,
               :WATERMEMORY],               
        40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH],
        30 => [:ABSORBBULB,:ADRENALINEORB,:AMAZEMULCH,:AMULETCOIN,:ANTIDOTE,
               :AWAKENING,:BALMMUSHROOM,:BERRYJUICE,:BIGMALASADA,:BIGMUSHROOM,
               :BIGNUGGET,:BIGPEARL,:BINDINGBAND,:BLACKBELT,:BLACKGLASSES,
               :BLACKSLUDGE,:BLUEFLUTE,:BLUESHARD,:BOOSTMULCH,:BOTTLECAP,
               :BURNHEAL,:CALCIUM,:CARBOS,:CASTELIACONE,:CELLBATTERY,:CHARCOAL,
               :CLEANSETAG,:COMETSHARD,:DAMPMULCH,:DEEPSEASCALE,:DIREHIT,
               :DRAGONSCALE,:EJECTBUTTON,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,
               :ESCAPEROPE,:ETHER,:EVERSTONE,:EXPSHARE,:FIRESTONE,:FLAMEORB,
               :FLOATSTONE,:FLUFFYTAIL,:FRESHWATER,:FULLHEAL,:FULLRESTORE,
               :GOLDBOTTLECAP,:GOOEYMULCH,:GREENSHARD,:GROWTHMULCH,:GUARDSPEC,
               :HEALPOWDER,:HEARTSCALE,:HONEY,:HPUP,:HYPERPOTION,:ICEHEAL,
               :ICESTONE,:IRON,:KINGSROCK,:LAVACOOKIE,:LEAFSTONE,:LEMONADE,
               :LIFEORB,:LIGHTBALL,:LIGHTCLAY,:LUCKYEGG,:LUMINOUSMOSS,
               :LUMIOSEGALETTE,:MAGNET,:MAXELIXIR,:MAXETHER,:MAXPOTION,
               :MAXREPEL,:MAXREVIVE,:METALCOAT,:METRONOME,:MIRACLESEED,
               :MOOMOOMILK,:MOONSTONE,:MYSTICWATER,:NEVERMELTICE,:NUGGET,
               :OLDGATEAU,:PARALYZEHEAL,:PASSORB,:PEARL,:PEARLSTRING,:POKEDOLL,
               :POKETOY,:POTION,:PPMAX,:PPUP,:PRISMSCALE,:PROTECTIVEPADS,
               :PROTEIN,:RAGECANDYBAR,:RARECANDY,:RAZORFANG,:REDFLUTE,:REDSHARD,
               :RELICBAND,:RELICCOPPER,:RELICCROWN,:RELICGOLD,:RELICSILVER,
               :RELICSTATUE,:RELICVASE,:REPEL,:REVIVALHERB,:REVIVE,:RICHMULCH,
               :SACREDASH,:SCOPELENS,:SHALOURSABLE,:SHELLBELL,:SHOALSALT,
               :SHOALSHELL,:SMOKEBALL,:SNOWBALL,:SODAPOP,:SOULDEW,:SPELLTAG,
               :STARDUST,:STARPIECE,:STRANGESOUVENIR,:SUNSTONE,:SUPERPOTION,
               :SUPERREPEL,:SURPRISEMULCH,:SWEETHEART,:THUNDERSTONE,
               :TINYMUSHROOM,:TOXICORB,:TWISTEDSPOON,:UPGRADE,:WATERSTONE,
               :XACCURACY,:XATTACK,:XDEFENSE,:XSPATK,:XSPDEF,:XSPEED,
               :YELLOWFLUTE,:YELLOWSHARD,:ZINC],
        20 => [:CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
               :RESISTWING,:SWIFTWING],
        10 => [:AGUAVBERRY,:AIRBALLOON,:APICOTBERRY,:ASPEARBERRY,:BABIRIBERRY,
               :BELUEBERRY,:BIGROOT,:BLUESCARF,:BLUKBERRY,:BRIGHTPOWDER,
               :CHARTIBERRY,:CHERIBERRY,:CHESTOBERRY,:CHILANBERRY,:CHOICEBAND,
               :CHOICESCARF,:CHOICESPECS,:CHOPLEBERRY,:COBABERRY,:COLBURBERRY,
               :CORNNBERRY,:CUSTAPBERRY,:DESTINYKNOT,:DISCOUNTCOUPON,
               :DURINBERRY,:ELECTRICSEED,:ENIGMABERRY,:EXPERTBELT,:FIGYBERRY,
               :FOCUSBAND,:FOCUSSASH,:FULLINCENSE,:GANLONBERRY,:GRASSYSEED,
               :GREENSCARF,:GREPABERRY,:HABANBERRY,:HONDEWBERRY,:IAPAPABERRY,
               :JABOCABERRY,:KASIBBERRY,:KEBIABERRY,:KEEBERRY,:KELPSYBERRY,
               :LAGGINGTAIL,:LANSATBERRY,:LAXINCENSE,:LEFTOVERS,:LEPPABERRY,
               :LIECHIBERRY,:LUCKINCENSE,:LUMBERRY,:MAGOBERRY,:MAGOSTBERRY,
               :MARANGABERRY,:MENTALHERB,:METALPOWDER,:MICLEBERRY,:MISTYSEED,
               :MUSCLEBAND,:NANABBERRY,:NOMELBERRY,:OCCABERRY,:ODDINCENSE,
               :ORANBERRY,:PAMTREBERRY,:PASSHOBERRY,:PAYAPABERRY,:PECHABERRY,
               :PERSIMBERRY,:PETAYABERRY,:PINAPBERRY,:PINKNECTAR,:PINKSCARF,
               :POMEGBERRY,:POWERHERB,:PSYCHICSEED,:PUREINCENSE,:PURPLENECTAR,
               :QUALOTBERRY,:QUICKPOWDER,:RABUTABERRY,:RAWSTBERRY,:RAZZBERRY,
               :REAPERCLOTH,:REDCARD,:REDNECTAR,:REDSCARF,:RINDOBERRY,
               :RINGTARGET,:ROCKINCENSE,:ROSEINCENSE,:ROSELIBERRY,:ROWAPBERRY,
               :SALACBERRY,:SEAINCENSE,:SHEDSHELL,:SHUCABERRY,:SILKSCARF,
               :SILVERPOWDER,:SITRUSBERRY,:SMOOTHROCK,:SOFTSAND,:SOOTHEBELL,
               :SPELONBERRY,:STARFBERRY,:TAMATOBERRY,:TANGABERRY,:WACANBERRY,
               :WATMELBERRY,:WAVEINCENSE,:WEPEARBERRY,:WHITEHERB,:WIDELENS,
               :WIKIBERRY,:WISEGLASSES,:YACHEBERRY,:YELLOWNECTAR,:YELLOWSCARF,
               :ZOOMLENS]
    }
  end

  def pbMoveFailed(attacker,opponent)
    return true if attacker.item==0 ||
                   @battle.pbIsUnlosableItem(attacker,attacker.item) ||
                   pbIsPokeBall?(attacker.item) ||
                   @battle.field.effects[PBEffects::MagicRoom]>0 ||
                   attacker.hasWorkingAbility(:KLUTZ) ||
                   attacker.effects[PBEffects::Embargo]>0
    for i in flingarray.keys
      if flingarray[i]
        for j in flingarray[i]
          return false if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return false if pbIsBox?(attacker.item)
    return false if pbIsBerry?(attacker.item) &&
                    !attacker.pbOpposing1.hasWorkingAbility(:UNNERVE) &&
                    !attacker.pbOpposing2.hasWorkingAbility(:UNNERVE) &&
                    !attacker.pbOpposing1.hasWorkingAbility(:ASONE1) &&
                    !attacker.pbOpposing2.hasWorkingAbility(:ASONE1) &&
                    !attacker.pbOpposing1.hasWorkingAbility(:ASONE2) &&
                    !attacker.pbOpposing2.hasWorkingAbility(:ASONE2)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return 10 if pbIsBerry?(attacker.item)
    return 80 if pbIsMegaStone?(attacker.item)
    return 120 if pbIsBox?(attacker.item)
    for i in flingarray.keys
      if flingarray[i]
        for j in flingarray[i]
          return i if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return 1
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    attacker.effects[PBEffects::Unburden]=true
    @battle.pbDisplay(_INTL("{1} flung its {2}!",attacker.pbThis,PBItems.getName(attacker.item)))
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       (attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:SHIELDDUST))
      if attacker.hasWorkingBerry
        opponent.pbActivateBerryEffect(attacker.item,false)
      elsif attacker.hasWorkingItem(:FLAMEORB)
        if opponent.pbCanBurn?(attacker,false,self)
          opponent.pbBurn(attacker)
        end
      elsif attacker.hasWorkingItem(:KINGSROCK) ||
            attacker.hasWorkingItem(:RAZORFANG)
        opponent.pbFlinch(attacker)
      elsif attacker.hasWorkingItem(:LIGHTBALL)
        if opponent.pbCanParalyze?(attacker,false,self)
          opponent.pbParalyze(attacker)
        end
      elsif attacker.hasWorkingItem(:MENTALHERB)
        if opponent.effects[PBEffects::Attract]>=0
          opponent.pbCureAttract
          @battle.pbDisplay(_INTL("{1} got over its infatuation.",opponent.pbThis))
        end
        if opponent.effects[PBEffects::Taunt]>0
          opponent.effects[PBEffects::Taunt]=0
          @battle.pbDisplay(_INTL("{1}'s taunt wore off!",opponent.pbThis))
        end
        if opponent.effects[PBEffects::Khleri]>0
          opponent.effects[PBEffects::Khleri]=0
          @battle.pbDisplay(_INTL("{1}'s khleri wore off!",opponent.pbThis))
        end
        if opponent.effects[PBEffects::Encore]>0
          opponent.effects[PBEffects::Encore]=0
          opponent.effects[PBEffects::EncoreMove]=0
          opponent.effects[PBEffects::EncoreIndex]=0
          @battle.pbDisplay(_INTL("{1}'s encore ended!",opponent.pbThis))
        end
        if opponent.effects[PBEffects::Torment]
          opponent.effects[PBEffects::Torment]=false
          @battle.pbDisplay(_INTL("{1}'s torment wore off!",opponent.pbThis))
        end
        if opponent.effects[PBEffects::Disable]>0
          opponent.effects[PBEffects::Disable]=0
          @battle.pbDisplay(_INTL("{1} is no longer disabled!",opponent.pbThis))
        end
        if opponent.effects[PBEffects::HealBlock]>0
          opponent.effects[PBEffects::HealBlock]=0
          @battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:POISONBARB)
        if opponent.pbCanPoison?(attacker,false,self)
          opponent.pbPoison(attacker)
        end
      elsif attacker.hasWorkingItem(:TOXICORB)
        if opponent.pbCanPoison?(attacker,false,self)
          opponent.pbPoison(attacker,nil,true)
        end
      elsif attacker.hasWorkingItem(:WHITEHERB)
        while true
          reducedstats=false
          for i in [PBStats::ATTACK,PBStats::DEFENSE,
                    PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                    PBStats::EVASION,PBStats::ACCURACY]
            if opponent.stages[i]<0
              opponent.stages[i]=0; reducedstats=true
            end
          end
          break if !reducedstats
          @battle.pbDisplay(_INTL("{1}'s status is returned to normal!",
             opponent.pbThis(true)))
        end
      end
    end
    attacker.pbConsumeItem
    return ret
  end
end



################################################################################
# For 5 rounds, the target cannnot use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
################################################################################
class PokeBattle_Move_0F8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Embargo]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Embargo]=5
    @battle.pbDisplay(_INTL("{1} can't use items anymore!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
################################################################################
class PokeBattle_Move_0F9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::MagicRoom]>0
      @battle.field.effects[PBEffects::MagicRoom]=0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.field.effects[PBEffects::MagicRoom]=5
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
    return 0
  end
end



################################################################################
# User takes recoil damage equal to 1/4 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FA < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) &&
         !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.hasWorkingAbility(:SUPERCLEARBODY)
        attacker.pbReduceHP((turneffects[PBEffects::TotalDamage]/4.0).round)
        attacker.changeRecoilDamage((turneffects[PBEffects::TotalDamage]/4.0).round)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
      end
    end
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FB < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) &&
         !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.hasWorkingAbility(:SUPERCLEARBODY)
        attacker.pbReduceHP((turneffects[PBEffects::TotalDamage]/3.0).round)
        attacker.changeRecoilDamage((turneffects[PBEffects::TotalDamage]/3.0).round)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
      end
    end
  end
end



################################################################################
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash)
################################################################################
class PokeBattle_Move_0FC < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) &&
         !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.hasWorkingAbility(:SUPERCLEARBODY)
        attacker.pbReduceHP((turneffects[PBEffects::TotalDamage]/2.0).round)
        attacker.changeRecoilDamage((turneffects[PBEffects::TotalDamage]/2.0).round)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
      end
    end
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
################################################################################
class PokeBattle_Move_0FD < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) &&
         !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.hasWorkingAbility(:SUPERCLEARBODY)
        attacker.pbReduceHP((turneffects[PBEffects::TotalDamage]/3.0).round)
        attacker.changeRecoilDamage((turneffects[PBEffects::TotalDamage]/3.0).round)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
      end
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
################################################################################
class PokeBattle_Move_0FE < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) &&
         !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.hasWorkingAbility(:SUPERCLEARBODY)
        attacker.pbReduceHP((turneffects[PBEffects::TotalDamage]/3.0).round)
        attacker.changeRecoilDamage((turneffects[PBEffects::TotalDamage]/3.0).round)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",attacker.pbThis))
      end
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanBurn?(attacker,false,self)
      opponent.pbBurn(attacker)
    end
  end
end



################################################################################
# Starts sunny weather. (Sunny Day)
################################################################################
class PokeBattle_Move_0FF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    case @battle.weather
    when PBWeather::HEAVYRAIN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::SUNNYDAY
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::SUNNYDAY
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:HEATROCK)
    @battle.pbCommonAnimation("Sunny",nil,nil)
    @battle.pbDisplay(_INTL("The sunlight turned harsh!"))
    return 0
  end
end



################################################################################
# Starts rainy weather. (Rain Dance)
################################################################################
class PokeBattle_Move_100 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    case @battle.weather
    when PBWeather::HEAVYRAIN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::RAINDANCE
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::RAINDANCE
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:DAMPROCK)
    @battle.pbCommonAnimation("Rain",nil,nil)
    @battle.pbDisplay(_INTL("It started to rain!"))
    return 0
  end
end



################################################################################
# Starts sandstorm weather. (Sandstorm)
################################################################################
class PokeBattle_Move_101 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    case @battle.weather
    when PBWeather::HEAVYRAIN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::SANDSTORM
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::SANDSTORM
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:SMOOTHROCK)
    @battle.pbCommonAnimation("Sandstorm",nil,nil)
    @battle.pbDisplay(_INTL("A sandstorm brewed!"))
    return 0
  end
end



################################################################################
# Starts hail weather. (Hail)
################################################################################
class PokeBattle_Move_102 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    case @battle.weather
    when PBWeather::HEAVYRAIN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::HAIL
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::HAIL
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:ICYROCK)
    @battle.pbCommonAnimation("Hail",nil,nil)
    @battle.pbDisplay(_INTL("It started to hail!"))
    return 0
  end
end



################################################################################
# Entry hazard. Lays spikes on the opposing side (max. 3 layers). (Spikes)
################################################################################
class PokeBattle_Move_103 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::Spikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Spikes were scattered all around the opposing team's feet!"))
    else
      @battle.pbDisplay(_INTL("Spikes were scattered all around your team's feet!"))
    end
    return 0
  end
end



################################################################################
# Entry hazard. Lays poison spikes on the opposing side (max. 2 layers).
# (Toxic Spikes)
################################################################################
class PokeBattle_Move_104 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around the opposing team's feet!"))
    else
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around your team's feet!"))
    end
    return 0
  end
end



################################################################################
# Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
################################################################################
class PokeBattle_Move_105 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::StealthRock]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::StealthRock]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Pointed stones float in the air around the opposing team!"))
    else
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
    end
    return 0
  end
end



################################################################################
# Forces ally's Pledge move to be used next, if it hasn't already. (Grass Pledge)
# Combo's with ally's Pledge move if it was just used. Power is doubled, and
# causes either a sea of fire or a swamp on the opposing side.
################################################################################
class PokeBattle_Move_106 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x107 ||   # Fire Pledge
       attacker.effects[PBEffects::FirstPledge]==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*2
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:FIRE) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.isFainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::SeaOfFire]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A sea of fire enveloped the opposing team!"))
          @battle.pbCommonAnimation("SeaOfFireOpp",nil,nil)
        else
          @battle.pbDisplay(_INTL("A sea of fire enveloped your team!"))
          @battle.pbCommonAnimation("SeaOfFire",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::Swamp]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A swamp enveloped the opposing team!"))
          @battle.pbCommonAnimation("SwampOpp",nil,nil)
        else
          @battle.pbDisplay(_INTL("A swamp enveloped your team!"))
          @battle.pbCommonAnimation("Swamp",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x107 ||   # Fire Pledge
       partnermove==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]==@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @overridetype
      return super(getConst(PBMoves,:FIREPLEDGE),attacker,opponent,hitnum,alltargets,showanimation)
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Forces ally's Pledge move to be used next, if it hasn't already. (Fire Pledge)
# Combo's with ally's Pledge move if it was just used. Power is doubled, and
# causes either a sea of fire on the opposing side or a rainbow on the user's side.
################################################################################
class PokeBattle_Move_107 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x106 ||   # Grass Pledge
       attacker.effects[PBEffects::FirstPledge]==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*2
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:WATER) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.isFainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::SeaOfFire]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A sea of fire enveloped the opposing team!"))
          @battle.pbCommonAnimation("SeaOfFireOpp",nil,nil)
        else
          @battle.pbDisplay(_INTL("A sea of fire enveloped your team!"))
          @battle.pbCommonAnimation("SeaOfFire",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOwnSide.effects[PBEffects::Rainbow]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on your team's side!"))
          @battle.pbCommonAnimation("Rainbow",nil,nil)
        else
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on the opposing team's side!"))
          @battle.pbCommonAnimation("RainbowOpp",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x106 ||   # Grass Pledge
       partnermove==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]==@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @overridetype
      return super(getConst(PBMoves,:WATERPLEDGE),attacker,opponent,hitnum,alltargets,showanimation)
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Forces ally's Pledge move to be used next, if it hasn't already. (Water Pledge)
# Combo's with ally's Pledge move if it was just used. Power is doubled, and
# causes either a swamp on the opposing side or a rainbow on the user's side.
################################################################################
class PokeBattle_Move_108 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x106 ||   # Grass Pledge
       attacker.effects[PBEffects::FirstPledge]==0x107      # Fire Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*2
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:GRASS) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.isFainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::Swamp]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A swamp enveloped the opposing team!"))
          @battle.pbCommonAnimation("SwampOpp",nil,nil)
        else
          @battle.pbDisplay(_INTL("A swamp enveloped your team!"))
          @battle.pbCommonAnimation("Swamp",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0
        attacker.pbOwnSide.effects[PBEffects::Rainbow]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on your team's side!"))
          @battle.pbCommonAnimation("Rainbow",nil,nil)
        else
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on the opposing team's side!"))
          @battle.pbCommonAnimation("RainbowOpp",nil,nil)
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x106 ||   # Grass Pledge
       partnermove==0x107      # Fire Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]==@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @overridetype
      return super(getConst(PBMoves,:GRASSPLEDGE),attacker,opponent,hitnum,alltargets,showanimation)
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Scatters coins that the player picks up after winning the battle. (Pay Day)
################################################################################
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.extramoney+=5*attacker.level
        @battle.extramoney=MAXMONEY if @battle.extramoney>MAXMONEY
      end
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
    return ret
  end
end



################################################################################
# Ends the opposing side's Light Screen and Reflect. (Brick Break)
################################################################################
class PokeBattle_Move_10A < PokeBattle_Move
  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,PokeBattle_Move::NOREFLECT)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
      attacker.pbOpposingSide.effects[PBEffects::Reflect]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!"))
      else
        @battle.pbDisplayPaused(_INTL("Your team's Reflect wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      attacker.pbOpposingSide.effects[PBEffects::LightScreen]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Light Screen wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0 # changed added
      attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Aurora Veil wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Aurora Veil wore off!"))
      end
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0 ||
       attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0 ||
       attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      return super(id,attacker,opponent,1,alltargets,showanimation) # Wall-breaking anim
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP.
# (Hi Jump Kick, Jump Kick)
################################################################################
class PokeBattle_Move_10B < PokeBattle_Move
  def isRecoilMove?
    return true
  end

  def unusableInGravity?
    return true
  end
end



################################################################################
# User turns 1/4 of max HP into a substitute. (Substitute)
################################################################################
class PokeBattle_Move_10C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Substitute]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} already has a substitute!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4).floor,1].max
    if attacker.hp<=sublife
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It was too weak to make a substitute!"))
      return -1  
    end
    attacker.pbReduceHP(sublife,false,false)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MultiTurn]=0
    attacker.effects[PBEffects::MultiTurnAttack]=0
    attacker.effects[PBEffects::Substitute]=sublife
    @battle.pbDisplay(_INTL("{1} put in a substitute!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User is not Ghost/Lick: Decreases the user's Speed, increases the user's Attack &
# Defense by 1 stage each.
# User is Ghost/Lick: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# (Curse)
################################################################################
class PokeBattle_Move_10D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=false
    if (attacker.pbHasType?(:GHOST) || attacker.pbHasType?(:LICK)) && 
      !@battle.pbCheckGlobalAbility(:BOTANOTHERAPY)
      if opponent.effects[PBEffects::Curse] ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
        failed=true
      else
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",attacker.pbThis,opponent.pbThis(true)))
        opponent.effects[PBEffects::Curse]=true
        attacker.pbReduceHP((attacker.totalhp/2).floor)
      end
    else
      lowerspeed=attacker.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      raiseatk=attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      raisedef=attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      if !lowerspeed && !raiseatk && !raisedef
        failed=true
      else
        pbShowAnimation(@id,attacker,nil,1,alltargets,showanimation) # Non-Ghost move animation
        if lowerspeed
          attacker.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
        end
        showanim='mix' # Was true
        if raiseatk
          attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
          showanim=false
        end
        if raisedef
          attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
          showanim=false
        end
      end
    end
    if failed
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return failed ? -1 : 0
  end
end



################################################################################
# Target's last move used loses 4 PP. (Spite)
################################################################################
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        reduction=[4,i.pp].min
        i.pp-=reduction
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),i.name,reduction))
        return 0
      end
    end
		pbPlayMissSE()
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
################################################################################
class PokeBattle_Move_10F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.status!=PBStatuses::SLEEP || opponent.effects[PBEffects::Nightmare] ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Nightmare]=true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
# Gen8+: Also increases user's speed by 1 stage. (Rapid Spin)
# Mortal Spin: Poisons the target instead of increasing user's speed by 1 stage
################################################################################
class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      if isConst?(@id,PBMoves,:MORTALSPIN)
        if opponent.pbCanPoison?(attacker,false,self)
          opponent.pbPoison(attacker)
        end
      else
        if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
          attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
        end
      end
      if attacker.effects[PBEffects::MultiTurn]>0
        mtattack=PBMoves.getName(attacker.effects[PBEffects::MultiTurnAttack])
        mtuser=@battle.battlers[attacker.effects[PBEffects::MultiTurnUser]]
        @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",attacker.pbThis,mtuser.pbThis(true),mtattack))
        attacker.effects[PBEffects::MultiTurn]=0
        attacker.effects[PBEffects::MultiTurnAttack]=0
        attacker.effects[PBEffects::MultiTurnUser]=-1
      end
      if attacker.effects[PBEffects::LeechSeed]>=0
        attacker.effects[PBEffects::LeechSeed]=-1
        @battle.pbDisplay(_INTL("{1} shed Leech Seed!",attacker.pbThis))   
      end
      if attacker.pbOwnSide.effects[PBEffects::StealthRock]
        attacker.pbOwnSide.effects[PBEffects::StealthRock]=false
        @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        attacker.pbOwnSide.effects[PBEffects::Spikes]=0
        @battle.pbDisplay(_INTL("{1} blew away Spikes!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
        @battle.pbDisplay(_INTL("{1} blew away poison spikes!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
        attacker.pbOwnSide.effects[PBEffects::StickyWeb]=false
        @battle.pbDisplay(_INTL("{1} blew away sticky webs!",attacker.pbThis))     
      end
    end
  end
end



################################################################################
# Attacks 2 rounds in the future. (Doom Desire, Future Sight)
################################################################################
class PokeBattle_Move_111 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    return 0 if @battle.futuresight
    return super(attacker)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::FutureSight]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.futuresight
      # Attack hits
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    end
    # Attack is launched
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::FutureSight]=3 
    opponent.effects[PBEffects::FutureSightMove]=@id
    opponent.effects[PBEffects::FutureSightUser]=attacker.pokemonIndex
    opponent.effects[PBEffects::FutureSightUserPos]=attacker.index
    if isConst?(@id,PBMoves,:FUTURESIGHT)
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",attacker.pbThis))
    end
    return 0
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.futuresight
      return super(id,attacker,opponent,1,alltargets,showanimation) # Hit opponent anim
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Increases the user's Defense and Special Defense by 1 stage each. Ups the
# user's stockpile by 1 (max. 3). (Stockpile)
################################################################################
class PokeBattle_Move_112 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Stockpile]>=3
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Stockpile]+=1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",attacker.pbThis,
        attacker.effects[PBEffects::Stockpile]))
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      attacker.effects[PBEffects::StockpileDef]+=1
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      attacker.effects[PBEffects::StockpileSpDef]+=1
      showanim=false
    end
    return 0
  end
end



################################################################################
# Power is 100 multiplied by the user's stockpile (X). Resets the stockpile to
# 0. Decreases the user's Defense and Special Defense by X stages each. (Spit Up)
################################################################################
class PokeBattle_Move_113 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.effects[PBEffects::Stockpile]==0)
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return 100*attacker.effects[PBEffects::Stockpile]
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && turneffects[PBEffects::TotalDamage]>0
      showanim='mix' # Was true
      if attacker.effects[PBEffects::StockpileDef]>0
        if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
          attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef],
             attacker,false,self,showanim)
          showanim=false
        end
      end
      if attacker.effects[PBEffects::StockpileSpDef]>0
        if attacker.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
          attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef],
             attacker,false,self,showanim)
          showanim=false
        end
      end
      attacker.effects[PBEffects::Stockpile]=0
      attacker.effects[PBEffects::StockpileDef]=0
      attacker.effects[PBEffects::StockpileSpDef]=0
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    end
  end
end



################################################################################
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X stages each. (Swallow)
################################################################################
class PokeBattle_Move_114 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    hpgain=0
    case attacker.effects[PBEffects::Stockpile]
    when 0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
      return -1
    when 1
      hpgain=(attacker.totalhp/4).floor
    when 2
      hpgain=(attacker.totalhp/2).floor
    when 3
      hpgain=attacker.totalhp
    end
    if attacker.hp==attacker.totalhp &&
       attacker.effects[PBEffects::StockpileDef]==0 &&
       attacker.effects[PBEffects::StockpileSpDef]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if attacker.pbRecoverHP(hpgain,true)>0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    showanim='mix' # Was true
    if attacker.effects[PBEffects::StockpileDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef],
           attacker,false,self,showanim)
        showanim=false
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef],
           attacker,false,self,showanim)
        showanim=false
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Fails if user was hit by a damaging move this round. (Focus Punch)
################################################################################
class PokeBattle_Move_115 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.lastHPLost>0
			pbPlayMissSE()
      @battle.pbDisplayBrief(_INTL("{1} lost its focus and couldn't move!",attacker.pbThis))
      return -1
    end
    return super(attacker)
  end
end



################################################################################
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch)
################################################################################
class PokeBattle_Move_116 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0 || oppmove.pbIsStatus?
    return true if opponent.hasMovedThisRound? && oppmove.function!=0xB0 # Me First
    return false
  end
end



################################################################################
# This round, user becomes the target of attacks that have single targets.
# (Follow Me, Rage Powder)
################################################################################
class PokeBattle_Move_117 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::FollowMe]=1
    if !attacker.pbPartner.isFainted? && attacker.pbPartner.effects[PBEffects::FollowMe]>0
      attacker.effects[PBEffects::FollowMe]=attacker.pbPartner.effects[PBEffects::FollowMe]+1
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, increases gravity on the field. Pokémon cannot become airborne.
# (Gravity)
################################################################################
class PokeBattle_Move_118 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::Gravity]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::Gravity]=5
    for i in 0...4
      poke=@battle.battlers[i]
      next if !poke
      if PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCE || # Sky Drop
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0x336   # Steel Fly
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
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    return 0
  end
end



################################################################################
# For 5 rounds, user becomes airborne. (Magnet Rise)
################################################################################
class PokeBattle_Move_119 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain] ||
       attacker.effects[PBEffects::MagicDelta] ||
       attacker.effects[PBEffects::SmackDown] ||
       attacker.effects[PBEffects::MagnetRise]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagnetRise]=5
    @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 3 rounds, target becomes airborne and can always be hit. (Telekinesis)
################################################################################
class PokeBattle_Move_11A < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Ingrain] ||
       opponent.effects[PBEffects::MagicDelta] ||
       opponent.effects[PBEffects::SmackDown] ||
       opponent.effects[PBEffects::Telekinesis]>0
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Telekinesis]=3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!",opponent.pbThis))
    return 0
  end
end




################################################################################
# Hits airborne semi-invulnerable targets. (Sky Uppercut)
################################################################################
class PokeBattle_Move_11B < PokeBattle_Move
# Handled in Battler's pbSuccessCheck, do not edit!
end



################################################################################
# Grounds the target while it remains active. (Smack Down, Thousand Arrows)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9  || # Fly
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC  || # Bounce
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE  || # Sky Drop
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x336 || # Steel Fly
       opponent.effects[PBEffects::SkyDrop]
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.effects[PBEffects::Roost]
      opponent.effects[PBEffects::SmackDown]=true
      showmsg=(opponent.pbHasType?(:FLYING) ||
               opponent.hasWorkingAbility(:LEVITATE))
      if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
         PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
         PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x336   # Steel Fly
         opponent.effects[PBEffects::TwoTurnAttack]=0; showmsg=true
      end
      if opponent.effects[PBEffects::MagnetRise]>0
        opponent.effects[PBEffects::MagnetRise]=0; showmsg=true
      end
      if opponent.effects[PBEffects::Telekinesis]>0
        opponent.effects[PBEffects::Telekinesis]=0; showmsg=true
      end
      if opponent.effects[PBEffects::MagicDelta]
        opponent.effects[PBEffects::MagicDelta]=false; showmsg=true
      end
      @battle.pbDisplay(_INTL("{1} fell straight down!",opponent.pbThis)) if showmsg
    end
    return ret
  end
end



################################################################################
# Target moves immediately after the user, ignoring priority/speed. (After You)
################################################################################
class PokeBattle_Move_11D < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if opponent.effects[PBEffects::MoveNext]
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0
    return true if opponent.hasMovedThisRound?
    return false
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MoveNext]=true
    opponent.effects[PBEffects::Quash]=false
    @battle.pbDisplay(_INTL("{1} took the kind offer!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target moves last this round, ignoring priority/speed. (Quash)
################################################################################
class PokeBattle_Move_11E < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if opponent.effects[PBEffects::Quash]
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0
    return true if opponent.hasMovedThisRound?
    return false
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Quash]=true
    opponent.effects[PBEffects::MoveNext]=false
    @battle.pbDisplay(_INTL("{1}'s move was postponed!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
# (Trick Room)
################################################################################
class PokeBattle_Move_11F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::TrickRoom]>0
      @battle.field.effects[PBEffects::TrickRoom]=0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!",attacker.pbThis))
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.field.effects[PBEffects::TrickRoom]=5
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# User switches places with its ally. (Ally Switch)
################################################################################
class PokeBattle_Move_120 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle ||
       !attacker.pbPartner || attacker.pbPartner.isFainted?
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    a=@battle.battlers[attacker.index]
    b=@battle.battlers[attacker.pbPartner.index]
#    temp=a; a=b; b=temp
    a,b=b,a
    # Swap effects that point at the position rather than the Pokémon
    # NOT PerishSongUser (no need to swap), Attract, MultiTurnUser
    effectstoswap=[PBEffects::BideTarget,
                   PBEffects::CounterTarget,
                   PBEffects::LeechSeed,
                   PBEffects::LockOnPos,
                   PBEffects::MeanLook,
                   PBEffects::MirrorCoatTarget]
    for i in effectstoswap
      a.effects[i],b.effects[i]=b.effects[i],a.effects[i]
    end
    attacker.pbUpdate(true)
    attacker.pbPartner.pbUpdate(true)
    @battle.pbDisplay(_INTL("{1} and {2} switched places!",attacker.pbPartner.pbThis,attacker.pbThis(true)))
  end
end



################################################################################
# Target's Attack is used instead of user's Attack for this move's calculations.
# (Foul Play)
################################################################################
class PokeBattle_Move_121 < PokeBattle_Move
# Handled in superclass def pbCalcDamage, do not edit!
end



################################################################################
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Psyshock, Psystrike, Secret Sword)
################################################################################
class PokeBattle_Move_122 < PokeBattle_Move
# Handled in superclass def pbCalcDamage, do not edit!
end



################################################################################
# Only damages Pokémon that share a type with the user. (Synchronoise)
# Gen9 FLINT+: Power is doubled on Pokémon that share the user's favorite type. 
################################################################################
class PokeBattle_Move_123 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbHasType?(attacker.type1) &&
       !opponent.pbHasType?(attacker.type2) &&
       !opponent.pbHasType?(attacker.effects[PBEffects::Type3])
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.pbHasType?(attacker.favtype)
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
# (Wonder Room)
################################################################################
class PokeBattle_Move_124 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::WonderRoom]>0
      @battle.field.effects[PBEffects::WonderRoom]=0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      @battle.field.effects[PBEffects::WonderRoom]=5
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
    return 0
  end
end



################################################################################
# Fails unless user has already used all other moves it knows. (Last Resort)
################################################################################
class PokeBattle_Move_125 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    counter=0; nummoves=0
    for move in attacker.moves
      next if move.id<=0
      counter+=1 if move.id!=@id && !attacker.movesUsed.include?(move.id)
      nummoves+=1
    end
    return counter!=0 || nummoves==1
  end
end



#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.
#===============================================================================



################################################################################
# Does absolutely nothing. (Hold Hands)
################################################################################
class PokeBattle_Move_133 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle ||
       !attacker.pbPartner || attacker.pbPartner.isFainted?
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    return 0
  end
end



################################################################################
# Does absolutely nothing. Shows a special message. (Celebrate)
################################################################################
class PokeBattle_Move_134 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("Congratulations, {1}!",@battle.pbGetOwner(attacker.index).name))
    return 0
  end
end



################################################################################
# Freezes the target. (Freeze-Dry)
# (Superclass's pbTypeModifier): Effectiveness against Water-type is 2x.
################################################################################
class PokeBattle_Move_135 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
    end
  end
end



################################################################################
# Increases the user's Defense by 1 stage for each target hit. (Diamond Storm)
################################################################################
class PokeBattle_Move_136 < PokeBattle_Move_02F
# No difference to function code 01D. It may need to be separate in future.
end



################################################################################
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
################################################################################
class PokeBattle_Move_137 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner]
      next if !i || i.isFainted?
      next if !i.hasWorkingAbility(:PLUS) && !i.hasWorkingAbility(:MINUS)
      next if !i.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
              !i.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      showanim='mix' # Was true
      if i.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
        i.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
        showanim=false
      end
      if i.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
        i.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# Increases ally's Special Defense by 1 stage. (Aromatic Mist)
################################################################################
class PokeBattle_Move_138 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !opponent ||
       !opponent.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self)
    return ret ? 0 : -1
  end
end



################################################################################
# Decreases the target's Attack by 1 stage. Always hits. (Play Nice)
################################################################################
class PokeBattle_Move_139 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
    return ret ? 0 : -1
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar)
################################################################################
class PokeBattle_Move_13A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Decreases the user's Defense by 1 stage. Always hits. (Hyperspace Fury)
################################################################################
class PokeBattle_Move_13B < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:HOOPA)
    return true if attacker.form!=1
    return false
  end

  def pbAccuracyCheck(attacker,opponent)
    return true
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self)
    end
  end
end



################################################################################
# Decreases the target's Special Attack by 1 stage. Always hits. (Confide)
################################################################################
class PokeBattle_Move_13C < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
    return ret ? 0 : -1
  end
end



################################################################################
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
################################################################################
class PokeBattle_Move_13D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self)
    end
  end
end



################################################################################
# Increases the Attack and Special Attack of all Grass-type Pokémon on the field
# by 1 stage each. Doesn't affect airborne Pokémon. (Rototiller)
################################################################################
class PokeBattle_Move_13E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.pbHasType?(:GRASS)
      next if i.isAirborne?(attacker.hasMoldBreaker(opponent))
      next if !i.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
              !i.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      showanim='mix' # Was true
      if i.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
        i.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false
      end
      if i.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
        i.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# Increases the Defense of all Grass-type Pokémon on the field by 1 stage each.
# (Flower Shield)
################################################################################
class PokeBattle_Move_13F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.pbHasType?(:GRASS)
      next if !i.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      if i.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
        i.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,true)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# Decreases the Attack, Special Attack and Speed of all poisoned opponents by 1
# stage each. (Venom Drench)
################################################################################
class PokeBattle_Move_140 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.status==PBStatuses::POISON
      next if !i.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self) &&
              !i.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self) &&
              !i.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      showanim='mix' # Was true
      if i.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
        i.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false
      end
      if i.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        i.pbReduceStat(PBStats::SPATK,1,attacker,false,self,showanim)
        showanim=false
      end
      if i.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        i.pbReduceStat(PBStats::SPEED,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# Reverses all stat changes of the target. (Topsy-Turvy)
################################################################################
class PokeBattle_Move_141 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    nonzero=false
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      if opponent.stages[i]!=0
        nonzero=true; break
      end
    end
    if !nonzero
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) if nonzero
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      opponent.stages[i]*=-1
    end
    @battle.pbDisplay(_INTL("{1}'s stats were reversed!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Gives target the Ghost type. (Trick-or-Treat)
################################################################################
class PokeBattle_Move_142 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       !hasConst?(PBTypes,:GHOST) || opponent.pbHasType?(:GHOST) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Type3]=getConst(PBTypes,:GHOST)
    typename=PBTypes.getName(getConst(PBTypes,:GHOST))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# Gives target the Grass type. (Forest's Curse)
################################################################################
class PokeBattle_Move_143 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.effects[PBEffects::LeechSeed]>=0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
      return -1
    end
    if !hasConst?(PBTypes,:GRASS) || opponent.pbHasType?(:GRASS) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Type3]=getConst(PBTypes,:GRASS)
    typename=PBTypes.getName(getConst(PBTypes,:GRASS))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# Damage is multiplied by Flying's effectiveness against the target. Does double
# damage and has perfect accuracy if the target is Minimized. (Flying Press)
################################################################################
class PokeBattle_Move_144 < PokeBattle_Move
  def unusableInGravity?
    return true
  end
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:FLYING) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Target's moves become Electric-type for the rest of the round. (Electrify)
################################################################################
class PokeBattle_Move_145 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.effects[PBEffects::Electrify]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       !@battle.choices[opponent.index][2] ||
       @battle.choices[opponent.index][2].id<=0 ||
       opponent.hasMovedThisRound?
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Electrify]=true
    @battle.pbDisplay(_INTL("{1} was electrified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
################################################################################
class PokeBattle_Move_146 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if ret>0 && !@battle.field.effects[PBEffects::IonDeluge]
        @battle.field.effects[PBEffects::IonDeluge]=true
        @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
      end
      return ret
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || @battle.field.effects[PBEffects::IonDeluge]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::IonDeluge]=true
    @battle.pbDisplay(_INTL("The Ion Deluge started!"))
    return 0
  end
end



################################################################################
# Always hits. (Hyperspace Hole)
# TODO: Hits through various shields.
################################################################################
class PokeBattle_Move_147 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
end


################################################################################
# Powders the foe. This round, if it uses a Fire move, it loses 1/4 of its max
# HP instead. (Powder)
################################################################################
class PokeBattle_Move_148 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Powder]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Powder]=true
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("{1} is covered in powder!",attacker.pbThis))
    return 0
  end  
end



################################################################################
# This round, the user's side is unaffected by damaging moves. (Mat Block)
################################################################################
class PokeBattle_Move_149 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount>1)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.pbOwnSide.effects[PBEffects::MatBlock]=true
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User's side is protected against status moves this round. (Crafty Shield)
################################################################################
class PokeBattle_Move_14A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::CraftyShield]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Crafty Shield protected your team!"))
    else
      @battle.pbDisplay(_INTL("Crafty Shield protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
################################################################################
class PokeBattle_Move_14B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::KingsShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::KingsShield]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
################################################################################
class PokeBattle_Move_14C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::SpikyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved ||
       @battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::SpikyShield]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Phantom Force)
# Is semi-invulnerable during use.
# Ignores target's Detect, King's Shield, Mat Block, Protect and Spiky Shield
# this round. If successful, negates them this round.
# Gen6 only: Does double damage and has perfect accuracy if the target is Minimized.
################################################################################
class PokeBattle_Move_14D < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if ret>0
      opponent.effects[PBEffects::ProtectNegation]=true
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
    end
    return ret
  end

# Disabled
=begin
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
=end
end



################################################################################
# Two turn attack. Skips first turn, increases the user's Special Attack,
# Special Defense and Speed by 2 stages each second turn. (Geomancy)
################################################################################
class PokeBattle_Move_14E < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} is absorbing power!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
################################################################################
class PokeBattle_Move_14F < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost*3/4).round
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# If this move KO's the target, increases the user's Attack by 3 stages.
# (Fell Stinger)
################################################################################
class PokeBattle_Move_150 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && opponent.isFainted?
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::ATTACK,3,attacker,false,self) # Was by 2 stages (Gen VI)
      end
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. Then, user
# switches out. Ignores trapping moves. (Parting Shot)
# TODO: Pursuit should interrupt this move.
################################################################################
class PokeBattle_Move_151 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if !self.isSoundBased? ||
       attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:SOUNDPROOF)
      showanim='mix' # Was true
      if opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false; ret=0
      end
      if opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self,showanim)
        showanim=false; ret=0
      end
    end
    if !attacker.isFainted? &&
       @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      attacker.effects[PBEffects::Uturn]=true; ret=0
    end
    return ret
  end
end



################################################################################
# No Pokémon can switch out or flee until the end of the next round, as long as
# the user remains active. (Fairy Lock)
################################################################################
class PokeBattle_Move_152 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::FairyLock]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::FairyLock]=2
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    return 0
  end
end



################################################################################
# Entry hazard. Lays stealth rocks on the opposing side. (Sticky Web)
################################################################################
class PokeBattle_Move_153 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::StickyWeb]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A sticky web has been laid out beneath the opposing team's feet!"))
    else
      @battle.pbDisplay(_INTL("A sticky web has been laid out beneath your team's feet!"))
    end
    return 0
  end
end



################################################################################
# For 5 rounds, creates an electric terrain which boosts Electric-type moves and
# prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
# (Electric Terrain)
################################################################################
class PokeBattle_Move_154 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::ELECTRIC
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("An electric current runs across the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end



################################################################################
# For 5 rounds, creates a grassy terrain which boosts Grass-type moves and heals
# Pokémon at the end of each round. Affects non-airborne Pokémon only.
# (Grassy Terrain)
################################################################################
class PokeBattle_Move_155 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::GRASSY
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::GRASSY
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end



################################################################################
# For 5 rounds, creates a misty terrain which weakens Dragon-type moves and
# protects Pokémon from status problems. Affects non-airborne Pokémon only.
# (Misty Terrain)
################################################################################
class PokeBattle_Move_156 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::MISTY
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::MISTY
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("Mist swirled about the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end



################################################################################
# Doubles the prize money the player gets after winning the battle. (Happy Hour)
################################################################################
class PokeBattle_Move_157 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbIsOpposing?(attacker.index) || @battle.doublemoney
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.doublemoney=true
    @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
    return 0
  end
end



################################################################################
# Fails unless user has consumed a berry at some point. (Belch)
################################################################################
class PokeBattle_Move_158 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.pokemon.belch
  end
end

################################################################################
# Lowers the foe's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (Tosti, Glass Punch, Eagle Wind, DoomGrill, Minditopia)
# Eagle and Lava Winds: Power is tripled if the targe's last move failed - Gen8
# DoomGrill: Power is doubled if user's friendship is higher than the target's
# friendship - Gen8
# Minditopia: Does double damage and has perfect accuracy against Minimized
# targets
################################################################################
class PokeBattle_Move_159 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if (isConst?(@id,PBMoves,:EAGLEWIND) ||
        isConst?(@id,PBMoves,:LAVAWIND)) &&
        opponent.effects[PBEffects::LastMoveFailed]
      return (damagemult*3.0).round
    end
    if isConst?(@id,PBMoves,:DOOMGRILL) && attacker.happiness > opponent.happiness
      return (damagemult*2.0).round
    end
    return damagemult
  end
  def pbAdditionalEffect(attacker,opponent)
    showanim='mix' # Was true
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false)
      opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false)
      opponent.pbReduceStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false)
      opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
    end
    return true
  end

  def tramplesMinimize?(param=1)
    return false if !isConst?(@id,PBMoves,:MINDITOPIA)  # Only works for Minditopia
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end

################################################################################
# Target becomes Normal type. (Normalise)
################################################################################
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:NORMAL) &&
       opponent.type2==getConst(PBTypes,:NORMAL) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:NORMAL))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:NORMAL)
    opponent.type2=getConst(PBTypes,:NORMAL)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:NORMAL))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Target becomes Jelly type. (Jelly Funch - Normalise)
################################################################################
class PokeBattle_Move_161 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:JELLY) &&
       opponent.type2==getConst(PBTypes,:JELLY) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:JELLY))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:JELLY)
    opponent.type2=getConst(PBTypes,:JELLY)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:JELLY))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 3 stages each. (Super 
# Memento)
# User faints (even if effect does nothing).
################################################################################
class PokeBattle_Move_163 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
    if opponent.pbReduceStat(PBStats::ATTACK,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPATK,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if !(attacker.hasWorkingAbility(:SIAXIS) || 
         attacker.hasWorkingAbility(:ANTIMENTO) || attacker.pbHasType?(:CHLOROPHYLL) ||
         attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
    end
    return ret
  end
end

################################################################################
# All Normal-type moves become Magic-type for the rest of the round.
# (Magic Storm)
################################################################################
class PokeBattle_Move_164 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || @battle.field.effects[PBEffects::MagicStorm]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::MagicStorm]=true
    @battle.pbDisplay(_INTL("The Magic Storm started!"))
    return 0
  end
end

################################################################################
# If this move KO's the target, increases the user's Evasion by 3 stages and
# user's Defemse by 1 stage.
# (Pelegosto, Lord of Moon)
################################################################################
class PokeBattle_Move_165 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    showanim='mix' # Was true
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && opponent.isFainted?
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::EVASION,3,attacker,false,self,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
      end
    end
    return ret
  end
end

################################################################################
# Gives target the Sharpener type. (Sharp ShaSharp)
################################################################################
class PokeBattle_Move_166 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       !hasConst?(PBTypes,:SHARPENER) || opponent.pbHasType?(:SHARPENER) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Type3]=getConst(PBTypes,:SHARPENER)
    typename=PBTypes.getName(getConst(PBTypes,:SHARPENER))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end


################################################################################
# Gives target the Magic type. (Magic Fitini)
################################################################################
class PokeBattle_Move_167 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       !hasConst?(PBTypes,:MAGIC) || opponent.pbHasType?(:MAGIC) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Type3]=getConst(PBTypes,:MAGIC)
    typename=PBTypes.getName(getConst(PBTypes,:MAGIC))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Gives target the Lava type. (Lalalava)
################################################################################
class PokeBattle_Move_168 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
       !hasConst?(PBTypes,:LAVA) || opponent.pbHasType?(:LAVA) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Type3]=getConst(PBTypes,:LAVA)
    typename=PBTypes.getName(getConst(PBTypes,:LAVA))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Increases the user's Speed by 3 stages.
################################################################################
class PokeBattle_Move_169 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,3,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,3,attacker,false,self)
    end
  end
end

################################################################################
# Decreases the target's Defense by 1 or 3 stages. User also faits 
# Move is banned if any Pokemon has Nervous Crack
# Power is severely halved if Psychic Terrain is in effect (Except Psycho Track)
# During the next turn, a crate buster is applied to the other side as well
# Psycho Track: Accuracy perfect if the user starts with that move as its first
# move (Gen7+)
# Lololove: Move works regardless of its abilities. Does double damage if it is
# used first
################################################################################
class PokeBattle_Move_170 < PokeBattle_Move
  def pbOnStartUse(attacker)
    attacker.effects[PBEffects::TemporaryMoldBreaker]=isConst?(@id,PBMoves,:LOLOLOVE)
    if !attacker.hasMoldBreaker(nil)
      bearer=@battle.pbCheckGlobalAbility(:NERVOUSCRACK)
      if bearer!=nil && !attacker.pbHasType?(:HEART)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
           bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
        return false
      end
    end
    return true
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,true,self)
    lowering=3
    lowering=(attacker.hasWorkingAbility(:CRATECRUSTER)) ? 2 : 1  if !isConst?(@id,PBMoves,:PSYCHOTRACK) && @battle.pbTerrain==PBBattleTerrains::PSYCHIC
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,lowering,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
      damage=damagemult
    if isConst?(@id,PBMoves,:LOLOLOVE) &&
         attacker.turncount<2
        damage=(damage*2.0).round
      end
    if !isConst?(@id,PBMoves,:PSYCHOTRACK) && 
       @battle.pbTerrain==PBBattleTerrains::PSYCHIC
       mult = (attacker.hasWorkingAbility(:CRATECRUSTER)) ? 0.5 : 0.25 
      damage=(damage*mult).round
    end
    return damage
  end

  
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    lowering=3
    lowering=(attacker.hasWorkingAbility(:CRATECRUSTER)) ? 2 : 1  if !isConst?(@id,PBMoves,:PSYCHOTRACK) && @battle.pbTerrain==PBBattleTerrains::PSYCHIC
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,lowering,attacker,false,self)
    end
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    # Crate buster applies in the following turn for Gen6- and in the following
    # two turns in Gen7
    opponent.pbOwnSide.effects[PBEffects::CrateBuster]=3
    attacker.effects[PBEffects::TemporaryMoldBreaker]=false
  end
  
  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
      if isConst?(@id,PBMoves,:PSYCHOTRACK) &&
         attacker.turncount<2
        return 0 # As per Gen7 FLINT
      end
      return baseaccuracy
  end

  
  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    super(id,attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? &&
       !(attacker.hasWorkingAbility(:SIAXIS) || attacker.pbHasType?(:CHLOROPHYLL) ||
        attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
      attacker.pbFaint if attacker.isFainted?
    end
  end
end

################################################################################
# Increases the user's evasion by 3 stages.
# Decreases the user's defense by 3 stages
# Minimizes the user. (Lick Lock)
################################################################################
class PokeBattle_Move_171 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self) &&
       !attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("{1}'s stats won't go any higher or lower!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::EVASION,3,attacker,false,self,true)
    end
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbReduceStat(PBStats::DEFENSE,3,attacker,false,self,true)
    end
    return 0
  end
end

################################################################################
# Increases the user's Evasion by 6 Stages and displays a message (Κουλούνδιν)
# NOTE: This move is a dedicated move. It can not be used in other Pokémon
# You must define another function if you want the same effect
################################################################################
class PokeBattle_Move_172 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:KOULUNDIN)
    return false
  end
  
  def pbOnStartUse(attacker)
    if isConst?(attacker.species,PBSpecies,:KOULUNDIN)
      return true
    else
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("When this Pokémon started to use this move, it failed!"))
      return false
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      if attacker.form==0 # MPRING
        attacker.stages[PBStats::EVASION]=6
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1} is now Κουλούνδed",attacker.pbThis))
      else # LEGO
        attacker.pbRecoverHP(((attacker.totalhp+1)/4).floor,true)
        @battle.pbDisplay(_INTL("{1} took the fly",attacker.pbThis))
      end
  end
end

################################################################################
# Increases the user's defense by 3 stages.
# Decreases the user's evasion by 3 stages
# Minimizes the user. (Herbotopia)
################################################################################
class PokeBattle_Move_173 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
       !attacker.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("{1}'s stats won't go any higher or lower!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,attacker,false,self,true)
    end
    if attacker.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbReduceStat(PBStats::EVASION,3,attacker,false,self,true)
    end
    return 0
  end
end

################################################################################
# If this move KO's the target, increases the user's attack by 1 stage and gains
# HP (SIAXIS and Park Damage)
# SIAXIS: Power is halved if the user does not contain SIAXIS ability
# Park Damage and Glimse Treat: Power is doubled during Cinament 
# (Ignoring power halve for Chlorophyll and Glimse moves)
################################################################################
class PokeBattle_Move_174 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:SIAXIS) && !attacker.hasWorkingAbility(:SIAXIS) 
      return (damagemult*0.5).round
    end
    if (isConst?(@id,PBMoves,:PARKDAMAGE) || isConst?(@id,PBMoves,:GLIMSETREAT)) &&
       @battle.pbTerrain==PBBattleTerrains::CINAMENT
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && opponent.isFainted?
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,true)
      end
        attacker.pbRecoverHP(((attacker.totalhp+3)/6).floor,true)
    end
    return ret
  end
end

################################################################################
# For 4 rounds, disables the target's damaging moves. (Khleri)
################################################################################
class PokeBattle_Move_175 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Khleri]>0 ||
       (!attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:OBLIVIOUS)) || 
        opponent.pbHasType?(:HERB) || opponent.pbHasType?(:MIND) || 
        opponent.pbHasType?(:GLIMSE)
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Khleri]=4
    @battle.pbDisplay(_INTL("{1} fell for the khleri!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Target becomes Chlorophyll type. (Chlornopia)
################################################################################
class PokeBattle_Move_176 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:CHLOROPHYLL) &&
       opponent.type2==getConst(PBTypes,:CHLOROPHYLL) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:CHLOROPHYLL))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:CHLOROPHYLL)
    opponent.type2=getConst(PBTypes,:CHLOROPHYLL)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:CHLOROPHYLL))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Increases one random stat of the user by 3 stages (except HP). 
# (Super Acupressure)
################################################################################
class PokeBattle_Move_177 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index 
      if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
         @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanIncreaseStatStage?(i,attacker,false,self)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbIncreaseStat(stat,3,attacker,false,self)
    return 0
  end
end

################################################################################
# User gains 4/6 the HP it inflicts as damage. (Sunny Drain, Moon Absorb)
################################################################################
class PokeBattle_Move_178 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost*4/6).round
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end

################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed.
# Also raises evasion by 1 stage (Sunny Blast/Gen7 SUN Move)
################################################################################
class PokeBattle_Move_179 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::EVASION,1,attacker,false,self)
    end
  end
end

################################################################################
# Power is halved if the user is burned, poisoned or paralyzed.
# Also lowers user's Evasion by 1 stage (Moon Blover/Gen7 MOON Move)
################################################################################
class PokeBattle_Move_180 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS
      return basedmg*0.5
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanReduceStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbReduceStat(PBStats::EVASION,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
      attacker.pbReduceStat(PBStats::EVASION,1,attacker,false,self)
    end
  end
end


################################################################################
# Decreases the target's stats by 3 stages each. (Harsh Lickmento)
# User faints (even if effect does nothing).
################################################################################

class PokeBattle_Move_181 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
    if opponent.pbReduceStat(PBStats::ATTACK,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::DEFENSE,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPATK,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPDEF,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPEED,3,attacker,false,self,showanim)
      ret=0; showanim=false
    end
    if !(attacker.hasWorkingAbility(:SIAXIS) || 
         attacker.hasWorkingAbility(:ANTIMENTO) || attacker.pbHasType?(:CHLOROPHYLL) ||
         attacker.pbHasType?(:GLIMSE) || attacker.hasWorkingItem(:GENIEBALL))
      attacker.pbReduceHP(attacker.hp)
    end
    return ret
  end
end

################################################################################
# Decreases one random stat of the user by 2 stages (except HP). 
# (Nexopressure)
################################################################################
class PokeBattle_Move_182< PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index 
      if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
         @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanReduceStatStage?(i,attacker,false,self)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(stat,2,attacker,false,self)
    return 0
  end
end

################################################################################
# Decreases one random stat of the user by 3 stages (except HP). 
# (Super Naxopressure)
################################################################################
class PokeBattle_Move_183 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index 
      if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
         @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanReduceStatStage?(i,attacker,false,self)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(stat,3,attacker,false,self)
    return 0
  end
end

################################################################################
# Target's ability becomes Ferfatina (Heralina Formerly). 
# Fails if another Pokémon has this ability as well (Mind Control)
################################################################################
class PokeBattle_Move_184 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if  @battle.pbCheckGlobalAbility(:FERFATINA)
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.hasUnstoppableAbility(attacker,[:TRUANT],[:FERFATINA])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.ability=getConst(PBAbilities,:FERFATINA) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:FERFATINA))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end

################################################################################
# Target drops its item. It regains the item at the end of the battle. (Technic Bros)
# If target has a losable item, damage is multiplied by 3.
# If the user has poison/burn/paralysis problem as well, damage is
# multiplied by 6 instead.
# Gen8: Move is usuable while asleep if Cinament is under effect
################################################################################
class PokeBattle_Move_185 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted? && !opponent.isFainted? && opponent.item!=0 &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item)
        itemname=PBItems.getName(opponent.item)
        opponent.item=0
        opponent.pokemon.corrosiveGas=false
        opponent.effects[PBEffects::ChoiceBand]=-1
        opponent.effects[PBEffects::Unburden]=true
        @battle.pbDisplay(_INTL("{1} dropped its {2}!",opponent.pbThis,itemname))
      end
    end
  end

  def pbCanUseWhileAsleep?
    return @battle.pbTerrain==PBBattleTerrains::CINAMENT
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if !@battle.pbIsUnlosableItem(opponent,opponent.item)
       # Still boosts damage even if opponent has Sticky Hold
        if attacker.status==PBStatuses::POISON ||
           attacker.status==PBStatuses::BURN ||
           attacker.status==PBStatuses::PARALYSIS
           return (damagemult*6).round
        end
       return (damagemult*3).round
    end
    return damagemult
  end
end

################################################################################
# Steals one stage from target's attack and applies it to the user 
# (Intimidate, Mascu Glass)
################################################################################
class PokeBattle_Move_186 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
    ret2=attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self)
    return ret ? ret2 ? 0 : -1 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self)
    end
  end
end

################################################################################
# Damage taken increases by difference between levels of user and target. 
# Always starts with at least base damage of 5 (10 in Gen8)
# Power is doubled if used on Ring maps
# Gen 8: Has double damage and perfect accuracy against minimized
# targets
# Power also gets doubled and also being used while asleep if the opponent 
# tries to switch out. This stakcs with the aforementioned power double, having
# x4 power boost if used on opponents that try to switch out on Ring Maps
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
# Intended for HellasNet Pokemon and Info+ (Douze Crayon)
################################################################################
class PokeBattle_Move_187 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg=(attacker.level-opponent.level)
    basedmg+=10
    if @battle.environment==PBEnvironment::Ring
      basedmg=basedmg*2
    end
    if @battle.switching
      basedmg=basedmg*2
    end
    if basedmg > 0
      return basedmg
    else
      return 10
    end
  end

  def pbCanUseWhileAsleep?
    return @battle.switching
  end
  
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end


################################################################################
# Damage taken increases by the amount of Effort Values the Pokemon has. 
# Always starts with at least base damage of 5 (10 in Gen8)
# Power is doubled if used on Boardwalk maps. Power is halved on Volcano Maps in
# Generation 7- and on Ring Maps
# Gen 6+: Has double damage and perfect accuracy against minimized
# targets (Topsy-Damage)
################################################################################
class PokeBattle_Move_188 < PokeBattle_Move
    def pbBaseDamage(basedmg,attacker,opponent)
      evtotal=(attacker.ev[0]+attacker.ev[1]+attacker.ev[2]+attacker.ev[3]+attacker.ev[4]+attacker.ev[5])/6
      evtotal+=10
      if @battle.environment==PBEnvironment::Boardwalk
        evtotal=evtotal*2
      end
      if @battle.environment==PBEnvironment::Ring
        evtotal=evtotal*0.5
      end
      if evtotal > 0
        return evtotal
      else
        return 10
      end
    end
    
    def tramplesMinimize?(param=1)
      return true if param==1 # Perfect accuracy
      return true if param==2 # Double damage
      return false
    end
end

################################################################################
# Steals one stage from target's special attack and applies it to the user
# (Intimidoom, Mescu Gless)
################################################################################
class PokeBattle_Move_189 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
    ret2=attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
    return ret ? ret2 ? 0 : -1 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
    end
  end
end

################################################################################
# User gains 4/6 the HP it inflicts as damage.
# Damage taken increases by the amount of Effort Values the Pokemon has. 
# Always starts with at least base damage of 10
# Has double damage and perfect accuracy against minimized targets 
# May be used even during asleep (Mind Recovercy)
################################################################################
class PokeBattle_Move_190 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbCanUseWhileAsleep?
    return true
  end

    def pbBaseDamage(basedmg,attacker,opponent)
      evtotal=(attacker.ev[0]+attacker.ev[1]+attacker.ev[2]+attacker.ev[3]+attacker.ev[4]+attacker.ev[5])/12
      evtotal+=10
      if evtotal > 0
        return evtotal
      else
        return 10
      end
    end
      
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost*4/6).round
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end

    def tramplesMinimize?(param=1)
      return true if param==1 # Perfect accuracy
      return true if param==2 # Double damage
      return false
    end

end

################################################################################
# Increases the user's Defense by 3 stages and usable while asleep (Akata Makata)
# Gen8: Increase is by 6 stages. No longer usable while asleep
################################################################################
class PokeBattle_Move_191 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    upper=6
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,upper,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      upper=6
      attacker.pbIncreaseStat(PBStats::DEFENSE,upper,attacker,false,self)
    end
  end
end


################################################################################
# Increases the ally's Special Attack by 1 stage (Lava Assist)
################################################################################
class PokeBattle_Move_192 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !opponent ||
       !opponent.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self)
    return ret ? 0 : -1
  end
end

################################################################################
# Decreases the target's Special Defense by 2 stages. Only works on the opposite
# gender. (Karbonite)
################################################################################
class PokeBattle_Move_193 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,true,self)
    if attacker.gender==2 || opponent.gender==2 || attacker.gender==opponent.gender ||
    (opponent.pbHasType?(:SHARPENER) && !attacker.hasWorkingAbility(:ANTISHARPNESS))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if attacker.gender!=2 && opponent.gender!=2 && attacker.gender!=opponent.gender
      if attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:OBLIVIOUS) ||
      !opponent.pbHasType?(:SHARPENER) || attacker.hasWorkingAbility(:ANTISHARPNESS)
        if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
          opponent.pbReduceStat(PBStats::SPDEF,2,attacker,false,self)
        end
      end
    end
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# Power also gets doubled, also being used wile asleep and has perfect accuracy
# if the opponent tries to switch out.
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
# Gen8: If the target tries to switch out and can no longer escape, cancel escape
# (Salazire, Lickalick)
################################################################################
class PokeBattle_Move_194 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.switching
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbCanUseWhileAsleep?
    return @battle.switching
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
      if @battle.switching
        return 0 # As per Gen7 FLINT
      end
      return baseaccuracy
    end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.isFainted?
        if opponent.effects[PBEffects::MeanLook]<0 &&
           !(opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
             opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
          opponent.effects[PBEffects::MeanLook]=attacker.index
          @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::MeanLook]>=0 ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
        opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Toggles the user between forms (Κουλουνδομόρφοση)
# NOTE: This move is a dedicated move. It can not be used in other Pokémon
# You must define another function if you want the same effect
################################################################################
class PokeBattle_Move_195 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:KOULUNDIN)
    return false
  end
  def pbOnStartUse(attacker)
    if isConst?(attacker.species,PBSpecies,:KOULUNDIN)
      return true
    else
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("When this Pokémon started to use this move, it failed!"))
      return false
    end
  end
  def pbCanUseWhileAsleep?
    return true
  end
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      if attacker.form==0 # MPRING
        attacker.form=1
        attacker.pbUpdate(true)
        @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
        @battle.pbDisplay(_INTL("{1} transformed into a Robin",attacker.pbThis))
        return 0
      else # LEGO
        attacker.form=0
        attacker.pbUpdate(true)
        @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
        @battle.pbDisplay(_INTL("{1} detransformed back to its original forme",attacker.pbThis))
        return 0
      end
  end
end


################################################################################
# Faints the whole team if form is 0 or lowers defense by one stage if form is 1
# fails otherewise (Κουλουνδόπια)
# NOTE: This move is a dedicated move. It can not be used in other Pokémon
# You must define another function if you want the same effect
################################################################################
class PokeBattle_Move_196 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true unless $dbattle
    return true if !isConst?(attacker.species,PBSpecies,:KOULUNDIN)
    return false
  end
  
  def pbOnStartUse(attacker)
    if isConst?(attacker.species,PBSpecies,:KOULUNDIN)
      return false unless $dbattle
      return true
    else
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("When this Pokémon started to use this move, it failed!"))
      return false
    end
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      if attacker.form==0 # MPRING
        opponent.pbReduceHP(opponent.hp)
        opponent.pbPartner.pbReduceHP(opponent.pbPartner.hp)
        attacker.pbPartner.pbReduceHP(attacker.pbPartner.hp)
        attacker.pbReduceHP(attacker.hp)
        @battle.pbDisplay(_INTL("{1} emptied the battlefield",attacker.pbThis))
        return 0
      else # LEGO
        if opponent.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self,true)
          ret=0;
        return 0
      end
    end
  end
end

################################################################################
# Deals Physical Typeless Damage. Damage Varies
# Accuracy is lowered on the faster forme (Κουλουνδοπίθεση)
# NOTE: This move is a dedicated move. It can not be used in other Pokémon
# You must define another function if you want the same effect
################################################################################
class PokeBattle_Move_197 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:KOULUNDIN)
    return false
  end
  
  def pbOnStartUse(attacker)
    if isConst?(attacker.species,PBSpecies,:KOULUNDIN)
      return true
    else
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("When this Pokémon started to use this move, it failed!"))
      return false
    end
  end
  
    def pbBaseDamage(basedmg,attacker,opponent)
      evtotal=[rand(250),rand(250)].max
      if evtotal > 4
        return evtotal
      else
        return 10
      end
    end
    def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
      case attacker.form
      when 0
        return 0
      when 1
        return 40+rand(30)
      end
      return baseaccuracy
    end
  end
  
################################################################################
# Heals user. The amount of HP depends on user's Happiness (S'More S'Miri)
################################################################################
class PokeBattle_Move_198 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    factor=[(attacker.happiness*2/50).floor,1].max
    attacker.pbRecoverHP(((attacker.totalhp+1)/(11.5-factor)).floor,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    factor=10
    factor-=[(attacker.happiness*2/50).floor,1].max
    if factor==0
      anim=0  # Full Friendship
    elsif factor>0 and factor<6
      anim=1  # High Friendship
    elsif factor>5 and factor<9
      anim=2  # Medium Friendship
    elsif factor>8
      anim=3  # Low Friendship
    end
    return super(id,attacker,opponent,anim,alltargets,showanimation) # Friendship-based animation
  end

end


################################################################################
# After attacking, the user removes this move's type from their own typing
# This move cannot be used for a Pokemon for which the move isn't STAB (Burn Up)
# A Gen6 FLINT Move (And Gen7+ Ordianl Move)
# Gen8: Can work on Lava Type Pokemon. Move will be Lava-type if used by Lava
# Pokemon. Lava-Fire Pokemon will have this move working as dual-type move
################################################################################
class PokeBattle_Move_199 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    if !(attacker.pbHasType?(:FIRE) || attacker.pbHasType?(:LAVA))
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !(type==getConst(PBTypes,:FIRE) || type==getConst(PBTypes,:LAVA))
        pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    # Fire Case
    type=getConst(PBTypes,:FIRE)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    # Lava Case
    type=getConst(PBTypes,:LAVA)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    attacker.effects[PBEffects::Mimicry] = false
    @battle.pbDisplay(_INTL("{1} burned itself out!",attacker.pbThis))
    return ret
  end
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:FIRE) || -1
    if type>=0 && attacker.pbHasType?(:FIRE) && attacker.pbHasType?(:LAVA)
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:LAVA) if attacker.pbHasType?(:LAVA)
    type=getConst(PBTypes,:FIRE)
    return type
  end
end


################################################################################
# Move type changes based on user's primary type 
# Flashes out Joicon first and then displays an animation based on user's primary
# type 
# Displays an error message if other species try to use this move (Joicon)
# Dedicated move function. If you need similar effect, rely on code 201, not on
# this one.
################################################################################
class PokeBattle_Move_200 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if isConst?(attacker.species,PBSpecies,:JOICON)
      @battle.pbCommonAnimation("Joicon",attacker,nil)
      return true
    else
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("When this Pokémon started to use this move, it failed!"))
      return false
    end
  end

  def pbModifyType(type,attacker,opponent)
    type=attacker.type1
    if !attacker.effects[PBEffects::Roost]
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=attacker.effects[PBEffects::Type3] if type==getConst(PBTypes,:QMARKS)
    else
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=getConst(PBTypes,:NORMAL) if type==getConst(PBTypes,:QMARKS)
    end
    return type
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=attacker.type1
    if !attacker.effects[PBEffects::Roost]
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=attacker.effects[PBEffects::Type3] if type==getConst(PBTypes,:QMARKS)
    else
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=getConst(PBTypes,:NORMAL) if type==getConst(PBTypes,:QMARKS)
    end
    id=getConst(PBMoves,:TACKLE)
    case type
    when getConst(PBTypes,:FIGHTING); id=getConst(PBMoves,:COMETPUNCH) || id
    when getConst(PBTypes,:FLYING); id=getConst(PBMoves,:GUST) || id
    when getConst(PBTypes,:POISON); id=getConst(PBMoves,:SLUDGE) || id
    when getConst(PBTypes,:GROUND); id=getConst(PBMoves,:SANDATTACK) || id
    when getConst(PBTypes,:ROCK); id=getConst(PBMoves,:ROCKTHROW) || id
    when getConst(PBTypes,:BUG); id=getConst(PBMoves,:TWINEEDLE) || id
    when getConst(PBTypes,:GHOST); id=getConst(PBMoves,:NIGHTSHADE) || id
    when getConst(PBTypes,:STEEL); id=getConst(PBMoves,:GYROBALL) || id
    when getConst(PBTypes,:FIRE); id=getConst(PBMoves,:EMBER) || id
    when getConst(PBTypes,:WATER); id=getConst(PBMoves,:WATERGUN) || id
    when getConst(PBTypes,:GRASS); id=getConst(PBMoves,:RAZORLEAF) || id
    when getConst(PBTypes,:ELECTRIC); id=getConst(PBMoves,:THUNDERSHOCK) || id
    when getConst(PBTypes,:PSYCHIC); id=getConst(PBMoves,:CONFUSION) || id
    when getConst(PBTypes,:ICE); id=getConst(PBMoves,:ICEBALL) || id
    when getConst(PBTypes,:DRAGON); id=getConst(PBMoves,:DRAGONRAGE) || id
    when getConst(PBTypes,:DARK); id=getConst(PBMoves,:PURSUIT) || id
    when getConst(PBTypes,:FAIRY); id=getConst(PBMoves,:FAIRYWIND) || id
    when getConst(PBTypes,:MAGIC); id=getConst(PBMoves,:MAGICHAND) || id
    when getConst(PBTypes,:DOOM); id=getConst(PBMoves,:DOOMTACKLE) || id
    when getConst(PBTypes,:JELLY); id=getConst(PBMoves,:JELLYKICK) || id
    when getConst(PBTypes,:SHARPENER); id=getConst(PBMoves,:WRAPPEDTACKLE) || id
    when getConst(PBTypes,:LAVA); id=getConst(PBMoves,:LAVACORN) || id
    when getConst(PBTypes,:WIND); id=getConst(PBMoves,:WINDATTACK) || id
    when getConst(PBTypes,:LICK); id=getConst(PBMoves,:LICK) || id
    when getConst(PBTypes,:BOLT); id=getConst(PBMoves,:WINDBOLT) || id
    when getConst(PBTypes,:HERB); id=getConst(PBMoves,:HERBSLAM) || id
    when getConst(PBTypes,:CHLOROPHYLL); id=getConst(PBMoves,:CHLOROPHYLL) || id
    when getConst(PBTypes,:GUST); id=getConst(PBMoves,:GUSTATTACK) || id
    when getConst(PBTypes,:SUN); id=getConst(PBMoves,:SUNNYTACKLE) || id
    when getConst(PBTypes,:MOON); id=getConst(PBMoves,:MOONCROCKET) || id
    when getConst(PBTypes,:MIND); id=getConst(PBMoves,:MINDBLOW) || id
    when getConst(PBTypes,:HEART); id=getConst(PBMoves,:HEARTGLOW) || id
    when getConst(PBTypes,:BLIZZARD); id=getConst(PBMoves,:ICEPUNCH) || id
    when getConst(PBTypes,:GAS); id=getConst(PBMoves,:ACID) || id
    when getConst(PBTypes,:GLIMSE); id=getConst(PBMoves,:GLIMSEATTACK) || id
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation) # Type-specific anim
  end

end

################################################################################
# Move type changes based on user's primary type (Revelation Dance)
################################################################################
class PokeBattle_Move_201 < PokeBattle_Move
  def pbModifyType(type,attacker,opponent)
    type=attacker.type1
    if !attacker.effects[PBEffects::Roost]
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=attacker.effects[PBEffects::Type3] if type==getConst(PBTypes,:QMARKS)
    else
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=getConst(PBTypes,:NORMAL) if type==getConst(PBTypes,:QMARKS)
    end
    return type
  end
end

################################################################################
# OHKO. Accuracy increases by difference between levels of user and target.
# Does not affect Ice Pokemon and has high accuracy on ice Pokemon (Sheer Cold)
################################################################################
class PokeBattle_Move_202 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STURDY)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return false
    end
    if opponent.pbHasType?(:MIND) || opponent.pbHasType?(:ICE)
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return false
    end
    if opponent.level>attacker.level
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      return false
    end
    acc=@accuracy+attacker.level-opponent.level
    return @battle.pbRandom(100)<acc
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if attacker.pbHasType?(:ICE)
      return baseaccuracy
    else
      return 20
    end
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted?
			pbSEPlay("Battle effect message") ## Qora's Change. Play Sassy SE when fainted
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end


################################################################################
# Deals Damage
# More damge on user's first turn and 100% chance of lowering all stats by 
# 2 stages. Slight more damage with a status problem 
# Only works for non-airbone Pokemon 
# Gen5: Also works for airbone Pokemon on user's first turn (Magma Triiverse)
################################################################################
class PokeBattle_Move_203 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.status>0 && attacker.turncount>1
      return basedmg*3
    end
    if attacker.turncount<2
      return basedmg*20
    end
    return basedmg
  end
  
  def pbMoveFailed(attacker,opponent)
    return true  if opponent.isAirborne?(attacker.hasMoldBreaker(opponent))
  end
  
  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if  attacker.turncount<2
      return 0
    else
      return baseaccuracy
    end
  end

  
  def pbAdditionalEffect(attacker,opponent)
    if attacker.turncount<2
      showanim='mix' # Was true
      if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false)
        opponent.pbReduceStat(PBStats::ATTACK,2,attacker,false,self,showanim)
        showanim=false
      end
      if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false)
        opponent.pbReduceStat(PBStats::DEFENSE,2,attacker,false,self,showanim)
        showanim=false
      end
      if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false)
        opponent.pbReduceStat(PBStats::SPATK,2,attacker,false,self,showanim)
        showanim=false
      end
      if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false)
        opponent.pbReduceStat(PBStats::SPDEF,2,attacker,false,self,showanim)
        showanim=false
      end
      if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false)
        opponent.pbReduceStat(PBStats::SPEED,2,attacker,false,self,showanim)
        showanim=false
      end
      return true
    end
  end
end

################################################################################
# After attacking, the user removes this move's type from their own typing
# This move cannot be used for a Pokemon for which the move isn't STAB (Gust Up)
# A Gen7 FLINT Move (Based on Burn Up)
# Gen8: Can work on Flying Type Pokemon. Move will be Flying-type if used by
# Flying Pokemon
################################################################################
class PokeBattle_Move_204 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    if !(attacker.pbHasType?(:GUST) || attacker.pbHasType?(:FLYING))
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !(type==getConst(PBTypes,:GUST) || type==getConst(PBTypes,:FLYING))
        pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    # Gust Case
    type=getConst(PBTypes,:GUST)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    # Flying Case
    type=getConst(PBTypes,:FLYING)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    attacker.effects[PBEffects::Mimicry] = false
    @battle.pbDisplay(_INTL("{1} gusted itself out!",attacker.pbThis))
    return ret
  end
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:GUST) || -1
    if type>=0 && attacker.pbHasType?(:GUST) && attacker.pbHasType?(:FLYING)
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:FLYING)  if attacker.pbHasType?(:FLYING)
    type=getConst(PBTypes,:GUST)
    return type
  end
end


################################################################################
# Freezes the target. Accuracy perfect in hail.
# Damage is multiplied by Steel's effectiveness against the target. 
# (Titanum Blizzard)
################################################################################
class PokeBattle_Move_205 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanFreeze?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    return 0
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:STEEL) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
    end
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if @battle.pbWeather==PBWeather::HAIL
      return 0
    end
    return baseaccuracy
  end
end


################################################################################
# User copies target's ability.
# Target's ability also gets suppresed 
# Fails if target is Blizzard-type (Blizzardous Ocean)
################################################################################
class PokeBattle_Move_206 < PokeBattle_Move
  # Initialize:
  # Fails if the other side is under the effects of CraftyShield
  # Fails if the user has Multitype, Stance Change, Maxthin or Κουλούνδιν
  # Fails if the target has Flower Gift, Forecast, Illusion, Imposter, Heralina
  # * Multitype, Stance Change, Wonder Guard, Zen Mode or Κουλούνδιν
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield] || 
       opponent.pbHasType?(:BLIZZARD)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.ability==0 ||
       attacker.ability==opponent.ability ||
       attacker.hasUnstoppableAbility(nil) ||
       opponent.hasUngainableAbility(attacker,[:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    # Part A: User Copies target's ability
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabilA=attacker.ability
    attacker.ability=opponent.ability
    abilityname=PBAbilities.getName(opponent.ability)
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),abilityname))
    if attacker.effects[PBEffects::Imprison] && isConst?(oldabilA,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      attacker.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",attacker.pbThis,PBAbilities.getName(oldabilA)))
    end
    if isConst?(attacker.species,PBSpecies,:ETV) && attacker.form>1
      attacker.form-=2
      attacker.pbUpdate(true)
      @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",attacker.pbThis))
    end
    if attacker.effects[PBEffects::Illusion] && isConst?(oldabilA,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{attacker.pbThis}'s Illusion ended")    
      attacker.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",attacker.pbThis,PBAbilities.getName(oldabilA)))
    end
    # PartB: Target's ability suprresion happens (Exceptions exist, however)
    # Exceptions for not going on this test: Maxthon and Maxplus
    # Also exceptions are all Gust, Moon and Mind Pokemons
    # Last but not least, this test won't trigger if the target has its ability
    # * already suppresed before with Gastro Acid

    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) ||
      opponent.pbHasType?(:GUST) || opponent.pbHasType?(:MOON) || 
      opponent.pbHasType?(:MIND) || opponent.effects[PBEffects::GastroAcid] ||
      opponent.pbHasType?(:GAS) || isEternal?(opponent) ||
      opponent.hasUnstoppableAbility(attacker)
    else
      oldabilB=opponent.ability
      opponent.effects[PBEffects::GastroAcid]=true
      opponent.effects[PBEffects::Truant]=false
      @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis)) 
      if opponent.effects[PBEffects::Imprison] && isConst?(oldabilB,PBAbilities,:IMPRISIN)
        PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
        opponent.effects[PBEffects::Imprison]=false
        @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabilB)))
      end
      if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
        opponent.form-=2
        opponent.pbUpdate(true)
        @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
        @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
      end
      if opponent.effects[PBEffects::Illusion] && isConst?(oldabilB,PBAbilities,:ILLUSION)
        PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
        opponent.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabilB)))
      end
    end
    return 0
  end
end

################################################################################
# Damage is multiplied by Dragon's effectiveness against the target. (Sunny Dragon)
################################################################################
class PokeBattle_Move_236 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:DRAGON) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
end


################################################################################
# Damage is multiplied by Ghost's effectiveness against the target. (Doom Pretzel)
# Gen8: Move is unusable in Gravity
################################################################################
class PokeBattle_Move_237 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:GHOST) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
end


################################################################################
# Decreases the targets's evasion by 2 stages. Maximizess the target. (Maximize)
################################################################################
class PokeBattle_Move_238 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    opponent.effects[PBEffects::Minimize]=false
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::EVASION,2,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    opponent.effects[PBEffects::Minimize]=false
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
      opponent.pbReduceStat(PBStats::EVASION,2,attacker,false,self)
    end
  end
end

################################################################################
# Power is doubled if the target hasn't moved this round.
# May poison the target if the target hasn't moved this round 
# (Soda Swamp, Marine Gastro)
################################################################################
class PokeBattle_Move_239 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if !(@battle.choices[opponent.index][0]!=1 || # Choosen a move already
       opponent.hasMovedThisRound?) # Didn't used a move
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanPoison?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    return -1 if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    opponent.pbPoison(attacker)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    return if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    if opponent.pbCanPoison?(attacker,false,self)
      opponent.pbPoison(attacker)
    end
  end
end

################################################################################
# Power is doubled if the target is using Phantom or Shadow Force.
# Power is halved during Cinament (Nightly)
# If the target vanishes, cancel the move
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_240 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    ret=damagemult
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x14D || # Phantom Force
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCD    # Shadow Force
      ret=(damagemult*2.0).round
    end
    if @battle.pbTerrain==PBBattleTerrains::CINAMENT
      ret=(ret*0.5).round
    end
    return ret
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    showmsg=false
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x14D || # Phantom Force
         PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCD    # Shadow Force
        opponent.effects[PBEffects::TwoTurnAttack]=0; showmsg=true
      end
      @battle.pbDisplay(_INTL("{1} vanish was cancwelled!",opponent.pbThis)) if showmsg
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x14D || # Phantom Force
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0x0CD    # Shadow Force
      return super(id,attacker,opponent,1,alltargets,showanimation)
    end
    return super(id,attacker,opponent,hitnum,alltargets,showanimation)
  end  

end

################################################################################
# For 5 rounds, creates a bolty cinema which boosts Bolt-type moves, protects
# Pokémon from lowering other stats (Except Self Reductions), negates 
# Mold Breaker, makes Pokémon unable to transform into other species and
# makes airborne Pokémon look like non-airborne (Cinament)
################################################################################
class PokeBattle_Move_241 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::CINAMENT
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::CINAMENT
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbCommonAnimation("Cinament",nil,nil)
    @battle.pbDisplay(_INTL("A bolty cauldron has sweeped the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end



################################################################################
# Power is doubled if the Pokémon shares a type with the user. 
# (Moon Croket, Glimse Attack)
################################################################################
class PokeBattle_Move_242 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    ret=damagemult
    if !opponent.pbHasType?(attacker.type1) &&
       !opponent.pbHasType?(attacker.type2) &&
       !opponent.pbHasType?(attacker.effects[PBEffects::Type3])
       return ret
     end
     ret=(damagemult*2.0).floor
    return ret
  end
end


################################################################################
# Steals one stage from target's speed and applies it to the user
# (Intimilow, Moscu Gloss)
################################################################################
class PokeBattle_Move_243 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    ret2=attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    return ret ? ret2 ? 0 : -1 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    end
  end
end

################################################################################
# Deals random damage of 20, 40, 80 or 160. Chosen randomly
# Ignores power halve during Cinament for Doom Star
# Power is doubled if:
#                     * Target is curled up
#                     * User is asleep
#                     * Target is in its first turn (Gen 4+)
# Can be used while asleep if Cinament is in effect
# Power is halved if any weather is present (Gen 4+)
# Gen6+ Move is unusable in Gravity for Doom Star (Doom Star, Neutralizing Gas)
################################################################################
class PokeBattle_Move_244 < PokeBattle_Move
  def unusableInGravity?
    return isConst?(@id,PBMoves,:DOOMSTAR)
  end
  
  def pbBaseDamage(damagemult,attacker,opponent)
    ret=[[20,20,20],
         [20,20,40],
         [20,40,80],
         [40,40,80],
         [20,40,160],
         [40,40,40],
         [80,40,80],
         [20,20,160],
         [80,160,20],
         [20,160,80],
         [20,20,20],
         [40,40,160],
         [20,20,20],
         [80,20,20],
         [40,40,40],
         [40,160,20],
         [40,40,40],
         [80,20,40],
         [20,20,20],
         [160,160,160]][rand(20)][rand(3)]
    if @battle.pbTerrain==PBBattleTerrains::CINAMENT &&
       isConst?(@id,PBMoves,:DOOMSTAR) # Double damage on Cinament to ignore halved doom damage
      ret=(ret*2.0).floor
    end
    if (opponent.effects[PBEffects::DefenseCurl]==true || # Curled up (Target)
        attacker.status==PBStatuses::SLEEP ||             # User is sleeping (Or has Comatose Ability)
        opponent.turncount<2)                             # Target has just came into battle
      ret=(ret*2.0).floor
    end
    if @battle.pbWeather!=0
      ret=(ret*0.5).floor
    end
    return ret
  end
  
  def pbCanUseWhileAsleep?
    return @battle.pbTerrain==PBBattleTerrains::CINAMENT
  end  
end

################################################################################
# Hits 7 times
# May lower accuracy on each hit (10% chance, 1 OR 2 stages)
# Ignores target's Doom Elist and doubles the power if the target is under that
# effect (Does not ignore it for other moves, though)
# Move is not usable while in Gravity (Doom Catapult)
# Gen8: After ending damage, opponent's Doom Elist effects activates
################################################################################
class PokeBattle_Move_245 < PokeBattle_Move
  def unusableInGravity?
    return true
  end
  
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 7
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    opponent.effects[PBEffects::DoomElist]=true if opponent.hasWorkingAbility(:DOOMELIST)
  end

  def pbBaseDamage(damagemult,attacker,opponent)
    ret=damagemult
    if opponent.effects[PBEffects::DoomElist]
      ret=(ret*2.0).floor
    end
    return ret
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::DoomElist]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::DoomElist]
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    end
  end
end


################################################################################
# Hits 7 times
# May lower accuracy on each hit (10% chance, 1 OR 2 stages)
# Ignores target's Flash Fire and doubles the power if the target is under that
# effect (Does not ignore it for other moves, though)
# Move is not usable while in Gravity (Fiery Catapult)
# Gen8: After ending damage, opponent's Flash Fire effects activates
################################################################################
class PokeBattle_Move_246 < PokeBattle_Move
  def unusableInGravity?
    return true
  end
  
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 7
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    opponent.effects[PBEffects::FlashFire]=true if opponent.hasWorkingAbility(:FLASHFIRE)
  end
  
  def pbBaseDamage(damagemult,attacker,opponent)
    ret=damagemult
    if opponent.effects[PBEffects::FlashFire]
      ret=(ret*2.0).floor
    end
    return ret
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::FlashFire]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::FlashFire]
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    end
  end
end

################################################################################
# Target becomes Doom type.
# Target loses his ability.
# Fails on Doom Pokémon
# This move will work neither through Multitype nor RKS System
# If ability can't be supressed, it will only become doom type ones 
# Works through Illusion (Doom Surplété)
################################################################################
class PokeBattle_Move_247 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) ||
      opponent.pbHasType?(:DOOM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    suppress= !opponent.hasUnstoppableAbility(attacker)
    if ((opponent.effects[PBEffects::Substitute]>0 && ignoresSubstitute?(attacker)) ||
         (opponent.pbHasType?(:GUST) || opponent.pbHasType?(:MOON) ||
         opponent.pbHasType?(:MIND) || opponent.effects[PBEffects::GastroAcid]) ||
         opponent.pbHasType?(:GAS))
      suppress=false
    end
    if suppress
      oldabilB=opponent.ability
      opponent.effects[PBEffects::GastroAcid]=true
      opponent.effects[PBEffects::Truant]=false
      @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis)) 
      if opponent.effects[PBEffects::Imprison] && isConst?(oldabilB,PBAbilities,:IMPRISIN)
        PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
        opponent.effects[PBEffects::Imprison]=false
        @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabilB)))
      end
      if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
        opponent.form-=2
        opponent.pbUpdate(true)
        @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
        @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
      end
      if opponent.effects[PBEffects::Illusion] && isConst?(oldabilB,PBAbilities,:ILLUSION)
        PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
        opponent.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabilB)))
      end
    end
    if opponent.type1==getConst(PBTypes,:DOOM) &&
       opponent.type2==getConst(PBTypes,:DOOM) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:DOOM))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:DOOM)
    opponent.type2=getConst(PBTypes,:DOOM)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:DOOM))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end


################################################################################
# Target copes user's types. (Underflect Type)
################################################################################
class PokeBattle_Move_248 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(opponent.type1) &&
       attacker.pbHasType?(opponent.type2) &&
       attacker.pbHasType?(opponent.effects[PBEffects::Type3]) &&
       opponent.pbHasType?(attacker.type1) &&
       opponent.pbHasType?(attacker.type2) &&
       opponent.pbHasType?(attacker.effects[PBEffects::Type3])
 			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=attacker.type1
    opponent.type2=attacker.type2
    opponent.effects[PBEffects::Type3]=-1
    @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",opponent.pbThis,attacker.pbThis(true)))
    return 0
  end
end


################################################################################
# Changes targets's type depending on the environment. (Casterflage)
################################################################################
class PokeBattle_Move_249 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    type=getConst(PBTypes,:NORMAL) || 0
    case @battle.environment
    when PBEnvironment::None;        type=getConst(PBTypes,:NORMAL) || 0
    when PBEnvironment::Grass;       type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::TallGrass;   type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::MovingWater; type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::StillWater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Underwater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Cave;        type=getConst(PBTypes,:ROCK) || 0
    when PBEnvironment::Rock;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Sand;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Forest;      type=getConst(PBTypes,:BUG) || 0
    when PBEnvironment::Snow;        type=getConst(PBTypes,:ICE) || 0
    when PBEnvironment::Volcano;     type=getConst(PBTypes,:FIRE) || 0
    when PBEnvironment::Graveyard;   type=getConst(PBTypes,:GHOST) || 0
    when PBEnvironment::Sky;         type=getConst(PBTypes,:FLYING) || 0
    when PBEnvironment::Space;       type=getConst(PBTypes,:DRAGON) || 0
    when PBEnvironment::Galaxy;      type=getConst(PBTypes,:MOON) || 0
    when PBEnvironment::Boardwalk;   type=getConst(PBTypes,:DARK) || 0
    when PBEnvironment::Ring;        type=getConst(PBTypes,:FIGHTING) || 0
    end
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      type=getConst(PBTypes,:ELECTRIC) if hasConst?(PBTypes,:ELECTRIC)
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      type=getConst(PBTypes,:GRASS) if hasConst?(PBTypes,:GRASS)
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      type=getConst(PBTypes,:FAIRY) if hasConst?(PBTypes,:FAIRY)
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      type=getConst(PBTypes,:PSYCHIC) if hasConst?(PBTypes,:PSYCHIC)
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      type=getConst(PBTypes,:BOLT) if hasConst?(PBTypes,:BOLT)
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      type=getConst(PBTypes,:LAVA) if hasConst?(PBTypes,:LAVA)
    elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      type=getConst(PBTypes,:HEART) if hasConst?(PBTypes,:HEART)
    end
    if opponent.pbHasType?(type)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=type
    opponent.type2=type
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(type)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))  
    return 0
  end
end

################################################################################
# For 5 rounds, creates a volcanic terrain which boosts Lava-type moves,
# halves power from Fire and Water-type moves and damages the targets a bit.
# Affects non-airborne Pokémon only. (Volcanic Terrain)
################################################################################
class PokeBattle_Move_250 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::VOLCANIC
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::VOLCANIC
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("A heatness has been set up on the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end


################################################################################
# Damage is multiplied by Herb's effectiveness against the target.
# May lower target's accuracy
# (Handled in pbProcessMoveAgainstTarget): Has 100% chance for Εν Χρυσώ of
# lowering accuracy
# (Magic Gold)
################################################################################
class PokeBattle_Move_251 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:HERB) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      opponent.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self)
    end
  end
end


################################################################################
# OHKO. Accuracy increases by difference between levels of user and target.
# Does not affect Magic Pokemon and has high accuracy on Magic Pokemon 
# (Magic Scratch)
################################################################################
class PokeBattle_Move_252 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    if !attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STURDY)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return false
    end
    if opponent.pbHasType?(:MIND) || opponent.pbHasType?(:MAGIC)
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return false
    end
    if opponent.level>attacker.level
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      return false
    end
    acc=@accuracy+attacker.level-opponent.level
    return @battle.pbRandom(100)<acc
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if attacker.pbHasType?(:MAGIC)
      return baseaccuracy
    else
      return 20
    end
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted?
			pbSEPlay("Battle effect message") ## Qora's Change. Play Sassy SE when fainted
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end


################################################################################
# Increases the Accuaracy of all Pokémon on the field by 1 OR 2 stages each. 
# Doesn't affect airborne Pokémon. (Mind Box)
################################################################################
class PokeBattle_Move_253 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if i.isAirborne?(attacker.hasMoldBreaker(opponent))
      next if !i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      upping = (i.pbHasType?(:MIND) || isUltraBlue?(i)) ? 2 : 1
      if i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
        i.pbIncreaseStat(PBStats::ACCURACY,upping,attacker,false,self,true)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# If the user's and target's previous move has failed, power doubles.
# (Lava Crayon)
################################################################################
class PokeBattle_Move_254 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*2 if attacker.effects[PBEffects::LastMoveFailed] && 
                        opponent.effects[PBEffects::LastMoveFailed]
    return basedmg
  end
end

################################################################################
# Power is doubled on every turn ending in 2/4/6/8/0 (Myrithi Crayon)
# (Superclass's pbTypeModifier): Effectiveness against Doom-type is 2x.
################################################################################
class PokeBattle_Move_255 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*2 if (attacker.turncount)%2==0
    return basedmg
  end
end

################################################################################
# Ends opposing Pokémon Illusion, consumes opposing Pokémon Genie Ball, ends
# opposing Pokémon Ultra Blue and makes the target Moon type (Genie Dream)
################################################################################
class PokeBattle_Move_274 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) ||
      opponent.pbHasType?(:MOON) ||        
      isConst?(opponent.ability,PBAbilities,:MULTITYPE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.effects[PBEffects::Illusion]
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    end
    if opponent.hasWorkingItem(:GENIEBALL) && 
      (attacker.hasMoldBreaker(opponent) || !opponent.hasWorkingAbility(:STICKYHOLD))
      PBDebug.log("[Item triggered] #{opponent.pbThis}'s Genie layed out from its Genie Ball")
      @battle.pbDisplay(_INTL("{1}'s Genie from its {2} layed out!",opponent.pbThis,PBItems.getName(opponent.item)))
      opponent.pbConsumeItem(false,false)
    end
    if isConst?(opponent.species,PBSpecies,:ROOMBA) && isUltraBlue?(opponent)
      opponent.form-=3
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s graduation wore off",opponent.pbThis))
      PBDebug.log("[Form changed] #{opponent.pbThis} graduation ended")
    end
    opponent.type1=getConst(PBTypes,:MOON)
    opponent.type2=getConst(PBTypes,:MOON)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:MOON))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Target becomes Electric type. (Electrodia)
################################################################################
class PokeBattle_Move_275 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:ELECTRIC) &&
       opponent.type2==getConst(PBTypes,:ELECTRIC) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:ELECTRIC))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:ELECTRIC)
    opponent.type2=getConst(PBTypes,:ELECTRIC)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:ELECTRIC))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# For 5 rounds, creates a lovely terrain which boosts Heart-type moves,
# halves power from Psychic, Fairy and Mind-type moves, doubles stat changes and
# can attract more species
# Affects non-airborne Pokémon only. (Lovely Terrain)
################################################################################
class PokeBattle_Move_276 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::LOVELY
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::LOVELY
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("A loveness has been set up on the battlefield!"))
    attacker.checkMimicryAll
    return 0
  end
end

################################################################################
# Two turn attack. Attacks first turn, skips second turn (if successful).
# If the target is burned, the burn is healed. (Water Bubble)
################################################################################
class PokeBattle_Move_277 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
      if !opponent.isFainted? && !opponent.damagestate.substitute && 
        opponent.status==PBStatuses::BURN
        opponent.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1}'s burn was healed.",opponent.pbThis))
      end
    end
  end
end


################################################################################
# OHKO. Accuracy increases by difference between levels of user and target.
# Never affects Herb and Glimse Pokemon. Also is blocked by Herbalility Pokemon
# Has High Accuracy if the user is Herb or Herbalility Pokemon
# (Herbal Smoke)
################################################################################
class PokeBattle_Move_278 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    if (!attacker.hasMoldBreaker(opponent) && opponent.hasWorkingAbility(:STURDY) ||
        opponent.hasWorkingAbility(:HERBALILITY) || 
        opponent.hasWorkingAbility(:MASKEDHERB))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return false
    end
    if opponent.hasWorkingItem(:BOTANICSMOKE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} was protected by its {2}!",opponent.pbThis,PBItems.getName(opponent.item)))  
      return false
    end
    if opponent.pbHasType?(:MIND) || opponent.pbHasType?(:HERB) || 
       opponent.pbHasType?(:GLIMSE)
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return false
    end
    if opponent.level>attacker.level
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      return false
    end
    acc=@accuracy+attacker.level-opponent.level
    return @battle.pbRandom(100)<acc
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if attacker.pbHasType?(:HERB) || attacker.hasWorkingAbility(:HERBALILITY) || 
      attacker.hasWorkingItem(:BOTANICSMOKE)
      return baseaccuracy
    else
      return 20
    end
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted?
			pbSEPlay("Battle effect message") ## Qora's Change. Play Sassy SE when fainted
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end

################################################################################
# Heals user. The amount of HP depends on target's Happiness (Dreamy Recovercy)
################################################################################
class PokeBattle_Move_279 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    factor=[(opponent.happiness*2/50).floor,1].max
    attacker.pbRecoverHP(((attacker.totalhp+1)/(11.5-factor)).floor,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end

end

################################################################################
# After attacking, the user removes this move's type from their own typing
# This move cannot be used for a Pokemon for which the move isn't STAB (Leaf Up)
# A Gen8 FLINT Move (Based on Burn Up and Gust Up)
# Can work on Chlorophyll Type Pokemon. Move will be Chlorophyll-type if used by
# Chlorophyll Pokemon
################################################################################
class PokeBattle_Move_281 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    if !(attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:CHLOROPHYLL))
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !(type==getConst(PBTypes,:GRASS) || type==getConst(PBTypes,:CHLOROPHYLL))
        pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    # Grass Case
    type=getConst(PBTypes,:GRASS)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    # Chlorophyll Case
    type=getConst(PBTypes,:CHLOROPHYLL)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    attacker.effects[PBEffects::Mimicry] = false
    @battle.pbDisplay(_INTL("{1} leafed itself out!",attacker.pbThis))
    return ret
  end
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:GRASS) || -1
    if type>=0 && attacker.pbHasType?(:GRASS) && attacker.pbHasType?(:CHLOROPHYLL)
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:CHLOROPHYLL)  if attacker.pbHasType?(:CHLOROPHYLL)
    type=getConst(PBTypes,:GRASS)
    return type
  end
end

################################################################################
# Two turn attack. Attacks first turn, skips second turn (if successful).
# Also lowers user's Accuracy by 2 stages. (Jelly Ploder)
################################################################################
class PokeBattle_Move_282 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
      if attacker.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
        attacker.pbReduceStat(PBStats::ACCURACY,2,attacker,false,self)
      end
    end
  end
end

################################################################################
# Exhausts the foe (Silvery Bliss)
################################################################################
class PokeBattle_Move_283 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::SilveryBliss] ||
       @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? # Used a move already
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::SilveryBliss]=true
    @battle.pbDisplay(_INTL("{1} made {2} exhausted!",attacker.pbThis,
    opponent.pbThis(true)))
    return 0
  end
end

################################################################################
# Power is doubled if the target hasn't moved this round.
# May paralyze the target if the target hasn't moved this round 
# (Lovely Bliss)
################################################################################
class PokeBattle_Move_284 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if !(@battle.choices[opponent.index][0]!=1 || # Choosen a move already
       opponent.hasMovedThisRound?) # Didn't used a move
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanParalyze?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    return -1 if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    opponent.pbParalyze(attacker)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    return if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end
end

################################################################################
# For five turns, all contact moves will paralyze targets and targets will be
# paralyzed if they use contact moves (Electromania)
################################################################################
class PokeBattle_Move_285 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Electromania]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Electromania]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A Magnetic Electric Field emergenced on your team!"))
    else
      @battle.pbDisplay(_INTL("A Magnetic Electric Field emergenced on the opposing team!"))
    end
    return 0
  end
end

################################################################################
# For five turns, user's and ally's are partially swapped. Does not affect your
# moves in your side (Brainologic)
################################################################################
class PokeBattle_Move_286 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Brainologic]>0 ||
      !@battle.doublebattle
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Brainologic]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team was switched out!"))
    else
      @battle.pbDisplay(_INTL("The opposing team was switched out"))
    end
    return 0
  end
end

################################################################################
# For the rest of the round, user becomes airborne (Magic Delta)
################################################################################
class PokeBattle_Move_287 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain] ||
       attacker.effects[PBEffects::MagicDelta] ||
       attacker.effects[PBEffects::SmackDown] ||
       attacker.effects[PBEffects::MagnetRise]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagicDelta]=true
    @battle.pbDisplay(_INTL("{1} is covered by a delta!",attacker.pbThis))
    return 0
  end
end

################################################################################
# All Normal-type moves become Fire-type for the rest of the round.
# (Torchwood)
################################################################################
class PokeBattle_Move_288 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || @battle.field.effects[PBEffects::Torchwood]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::Torchwood]=true
    @battle.pbDisplay(_INTL("A torchwood emergenced!"))
    return 0
  end
end

################################################################################
# For five turns, all contact moves will burn targets and targets will be
# burn if they use contact moves (Fierymania)
################################################################################
class PokeBattle_Move_289 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Fierymania]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Fierymania]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A Fiery Vortex Field emergenced on your team!"))
    else
      @battle.pbDisplay(_INTL("A Fiery Vortex Field emergenced on the opposing team!"))
    end
    return 0
  end
end

################################################################################
# For five turns, all contact moves will poison targets and targets will be
# poison if they use contact moves (Toxic Swamp)
# Gen7 only: Targets doing contact moves won't be poisoned
################################################################################
class PokeBattle_Move_290 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::ToxicSwamp]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::ToxicSwamp]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A Swamp of Poison emergenced on your team!"))
    else
      @battle.pbDisplay(_INTL("A Swamp of Poison emergenced on the opposing team!"))
    end
    return 0
  end
end

################################################################################
# Target copies the user's stat stages. (Black Moon)
################################################################################
class PokeBattle_Move_291 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      opponent.stages[i]=attacker.stages[i]
    end
    @battle.pbDisplay(_INTL("{1}'s stat changes were passed on {2}!",opponent.pbThis,attacker.pbThis(true)))
    return 0
  end
end

################################################################################
# For 3 rounds, ends all terrains except Cinament and makes a tunnel that hurts
# some battlers as well If a Terrain move is emergenced, this effects fades out
# Cinament does not end this tunnel. (Glimmy Galaxy)
################################################################################
class PokeBattle_Move_292 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::GlimmyGalaxy]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::GlimmyGalaxy]=3
    @battle.pbDisplay(_INTL("A Galaxian Tunnel has been emergenced on the battlefield!"))
    return 0
  end
end

################################################################################
# Power is doubled if the target hasn't moved this round.
# May freeze the target if the target hasn't moved this round 
# (Frozen Yoghurt)
################################################################################
class PokeBattle_Move_293 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if !(@battle.choices[opponent.index][0]!=1 || # Choosen a move already
       opponent.hasMovedThisRound?) # Didn't used a move
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanParalyze?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    return -1 if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    opponent.pbFreeze(attacker)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    return if @battle.choices[opponent.index][0]!=1 || opponent.hasMovedThisRound?
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbbFreeze(attacker)
    end
  end
end


################################################################################
# Move only works if the target is trying to switch out (Blizzardi Chase)
################################################################################
class PokeBattle_Move_294 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return !@battle.switching
  end
  
  def pbBaseDamage(basedmg,attacker,opponent)
    if !@battle.switching # While it won't work in that case, it is required as in
                          # Pokken Tournament Minigame, it will happen
      return basedmg*0.5
    end
    return basedmg
  end
end

################################################################################
# Hits 7 times
# May lower accuracy on each hit (10% chance, 1 OR 2 stages)
# Ignores target's Long Grass and doubles the power if the target is under that
# effect (Does not ignore it for other moves, though)
# Move is not usable while in Gravity (Grassy Catapult)
# After ending damage, opponent's Long Grass effects activates
################################################################################
class PokeBattle_Move_295 < PokeBattle_Move
  def unusableInGravity?
    return true
  end
  
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 7
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    opponent.effects[PBEffects::LongGrass]=true if opponent.hasWorkingAbility(:LONGGRASS)
  end
  
  def pbBaseDamage(damagemult,attacker,opponent)
    ret=damagemult
    if opponent.effects[PBEffects::LongGrass]
      ret=(ret*2.0).floor
    end
    return ret
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::LongGrass]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    lowering = 1
    lowering = 2 if opponent.effects[PBEffects::LongGrass]
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      opponent.pbReduceStat(PBStats::ACCURACY,lowering,attacker,false,self)
    end
  end
end

################################################################################
# Increases the user's Defense and Sp. Def by 1 stage each.
# In sunny weather, increase is 2 stages each instead. (Flowerotopia)
################################################################################
class PokeBattle_Move_296 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    increment=1
    if @battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      increment=2
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,increment,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,increment,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end

################################################################################
# Increases OR Decreases evasion of each Pokémon by 1 stage each 
# Doesn't affect airborne Pokémon. (Jelly Skarlett)
################################################################################
class PokeBattle_Move_297 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self) && i.pbHasType?(:JELLY)
      next if !i.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self) && !i.pbHasType?(:JELLY)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      if i.pbCanIncreaseStatStage?(PBStats::EVASION,attacker,false,self) && i.pbHasType?(:JELLY)
        i.pbIncreaseStat(PBStats::EVASION,1,attacker,false,self,true)
      end
      if i.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self) && !i.pbHasType?(:JELLY)
        i.pbReduceStat(PBStats::EVASION,1,attacker,false,self,true)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# Hits twice. May paralyze the target on each hit. (Pixel Bolt, Bolt Blow)
################################################################################
class PokeBattle_Move_298 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanParalyze?(attacker,false,self)
      opponent.pbParalyze(attacker)
    end
  end
end

################################################################################
# Decreases the target's Speed by 2 stages. Fails if the user is not asleep. 
# (Snooze)
################################################################################
class PokeBattle_Move_299 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.status!=PBStatuses::SLEEP)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,2,attacker,false,self)
    end
  end
end

################################################################################
# (handled elsewhere) This move will ignore opposing Pokémon's Mindy Glops and
# other's side Brainologic (Mindy Glops)
################################################################################
class PokeBattle_Move_300 < PokeBattle_Move
end

################################################################################
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status) and has increased priopity. Fails if user won't be replaced. (Sixtopia)
################################################################################
class PokeBattle_Move_301 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index) || attacker.hasWorkingAbility(:SIAXIS)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::Sixtopia]=true
    return 0
  end
end


################################################################################
# Damages. Power is either 1 or 2. Power doubles if user has the Robot Vaucher or
# the target has Canavis Robot. Has low chance of more damage (Robtrata)
# Gen6: Canavis Robot and Robot Vaucher can stack themeselves
################################################################################
class PokeBattle_Move_302 < PokeBattle_Move
  
  def pbBaseDamage(damagemult,attacker,opponent)
    ret=[1,2][rand(2)]
    ret=(ret*100.0).floor if rand(1000)<10
    if opponent.hasWorkingAbility(:CANAVISROBOT)
      ret=(ret*2.0).floor
    end
    if attacker.hasWorkingItem(:ROBOTVAUCHER)
      ret=(ret*2.0).floor
    end
    return ret
  end

end

################################################################################
# Damage is multiplied by Poison's effectiveness against the target. Does double
# May also paralyze or poison the tagret (Electronic Toxic)
################################################################################
class PokeBattle_Move_303 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:POISON) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    case @battle.pbRandom(2)
    when 0
      if opponent.pbCanPoison?(attacker,false,self)
        opponent.pbPoison(attacker)
      elsif opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
      end
    when 1
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
      elsif opponent.pbCanPoison?(attacker,false,self)
        opponent.pbPoison(attacker)
      end
    end
  end


end


################################################################################
# Confuses the target. Fails if the user is not asleep. (Treble)
################################################################################
class PokeBattle_Move_304 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.status!=PBStatuses::SLEEP)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.pbConfuse
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
    end
  end
end

################################################################################
# Increases the user's Special Defense by 1 stage.
# Triffinto: Power is doubled if user's friendship is high and is halved during
# Psychic Terrain (Gen 7+)
################################################################################
class PokeBattle_Move_322 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if isConst?(@id,PBMoves,:TRIFFINTO) &&
        @battle.pbTerrain==PBBattleTerrains::PSYCHIC && 
        attacker.happiness<220
      return (damagemult*0.5).round
    end
    if isConst?(@id,PBMoves,:TRIFFINTO) &&
        attacker.happiness>219 && @battle.pbTerrain!=PBBattleTerrains::PSYCHIC
      return (damagemult*2.0).round
    end
    return damagemult
  end
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self)
    end
  end
end


################################################################################
# Increases OR Decreases accuracy of each Pokémon by 1 stage each 
# Doesn't affect airborne Pokémon. (Doom Arietta)
################################################################################
class PokeBattle_Move_323 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self) && i.pbHasType?(:DOOM)
      next if !i.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self) && !i.pbHasType?(:DOOM)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      if i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self) && i.pbHasType?(:DOOM)
        i.pbIncreaseStat(PBStats::ACCURACY,1,attacker,false,self,true)
      end
      if i.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self) && !i.pbHasType?(:DOOM)
        i.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self,true)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end


################################################################################
# Increases OR Decreases accuracy of each Pokémon by 1 stage each 
# Doesn't affect airborne Pokémon. (Volt Energy)
################################################################################
class PokeBattle_Move_324 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self) && i.pbHasType?(:ELECTRIC)
      next if !i.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self) && !i.pbHasType?(:ELECTRIC)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      if i.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self) && i.pbHasType?(:ELECTRIC)
        i.pbIncreaseStat(PBStats::ACCURACY,1,attacker,false,self,true)
      end
      if i.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self) && !i.pbHasType?(:ELECTRIC)
        i.pbReduceStat(PBStats::ACCURACY,1,attacker,false,self,true)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# Used on all Elder Special Moves
################################################################################
class PokeBattle_Move_325 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @battle.pbCommonAnimation("ElderSpecial",attacker,nil)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !attacker.hasWorkingAbility(:ELDERBANANZA)
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
  
end


################################################################################
# Only damages Pokémon that share the color of the user. 
# Power is doubled on Pokémon that share the user's favorite color. (Coloratura)
################################################################################
class PokeBattle_Move_326 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.color != attacker.color
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
    return super(attacker,opponent,attacker.color,alltargets,showanimation)
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.color == attacker.favcolor
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    anim=attacker.color
    return super(id,attacker,opponent,anim,alltargets,showanimation) # Weather-specific anim
  end
end
################################################################################
# Target's ability becomes Klutz. (Forbidden Spell).
################################################################################
class PokeBattle_Move_327 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if opponent.hasUnstoppableAbility(attacker,[:TRUANT],[:KLUTZ])
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.ability=getConst(PBAbilities,:KLUTZ) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:KLUTZ))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end

################################################################################
# Two turn attack. Attacks first turn, skips second turn (if successful).
# Also confuses the user. (Stylus)
################################################################################
class PokeBattle_Move_332 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
      if attacker.pbCanConfuseSelf?(false)
        attacker.pbConfuse
        @battle.pbDisplay(_INTL("{1} became confused",attacker.pbThis))
      end
    end
  end
end


################################################################################
# Two turn attack. Attacks first turn, skips second turn (if successful).
# Damage is multiplied by Electic's effectiveness against the target. (Aeroshock)
################################################################################
class PokeBattle_Move_333 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:ELECTRIC) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
end

################################################################################
# Increases the user's Accuracy by 3 stages. (Toxic Decoration)
################################################################################
class PokeBattle_Move_334 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::ACCURACY,3,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ACCURACY,3,attacker,false,self)
    end
  end
end

################################################################################
# For five turns, user's and ally's are partially swapped and makes a poweder. 
# Does not affect your moves in your side (Revelation Powder)
################################################################################
class PokeBattle_Move_335 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::RevelationPowder]>0 ||
      !@battle.doublebattle
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::RevelationPowder]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team was switched out!"))
    else
      @battle.pbDisplay(_INTL("The opposing team was switched out"))
    end
    return 0
  end
end


################################################################################
# Two turn attack. Skips first turn, attacks second turn.
# Damage is multiplied by Flying's effectiveness against the target. (Steel Fly)
# (Handled in Battler's pbSuccessCheck): Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_336 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:FLYING) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Burns the partner. (Wicked Fire)
################################################################################
class PokeBattle_Move_337 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
      return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
      return -1 if !opponent.pbPartner.pbCanBurn?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbPartner.pbBurn(attacker)
      return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbPartner.pbCanBurn?(attacker,false,self)
      opponent.pbPartner.pbBurn(attacker)
    end
  end
end

################################################################################
# Damage is multiplied by Bolt's effectiveness against the target. (Steel Fly)
# Also Paralyzes the partner. (Centro Volt)
################################################################################
class PokeBattle_Move_338 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:BOLT) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
      return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
      return -1 if !opponent.pbPartner.pbCanParalyze?(attacker,true,self)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbPartner.pbParalyze(attacker)
      return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbPartner.pbCanParalyze?(attacker,false,self)
      opponent.pbPartner.pbParalyze(attacker)
    end
  end
end


################################################################################
# Increases the best stat of the user and partner by 2 stages (Duel Duadine)
################################################################################
class PokeBattle_Move_339 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner]
      next if !i || i.isFainted?
      stat = i.profstat
      next if !i.pbCanIncreaseStatStage?(stat,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      if i.pbCanIncreaseStatStage?(stat,attacker,false,self)
        i.pbIncreaseStat(stat,2,attacker,false,self,showanimation)
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# Damage is multiplied by Normal's effectiveness against the target. (Chocolate)
################################################################################
class PokeBattle_Move_340 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled in Misty Terrain (Flange)
################################################################################
class PokeBattle_Move_341 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if  @battle.pbTerrain==PBBattleTerrains::MISTY
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled on every turn ending in 2/4/6/8/0 (Jelly Seasame)
################################################################################
class PokeBattle_Move_342 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*2 if (attacker.turncount)%2==0
    return basedmg
  end
end

################################################################################
# For 5 rounds, the target cannnot use its ability (Neutral Trap)
################################################################################
class PokeBattle_Move_343 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) || 
      isEternal?(opponent) || opponent.effects[PBEffects::NeutralTrap]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasUnstoppableAbility(attacker)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldabil=opponent.ability
    opponent.effects[PBEffects::NeutralTrap]=5
    opponent.effects[PBEffects::Truant]=false
    @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis)) 
    if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
      opponent.effects[PBEffects::Imprison]=false
      @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
      opponent.form-=2
      opponent.pbUpdate(true)
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
    end
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end

################################################################################
# If user is KO'd before it next moves, the battler that caused it will have its 
# all stat stages reduced to minimum (Brainymedia)
################################################################################
class PokeBattle_Move_344 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret = super(attacker,opponent,hitnum,alltargets,showanimation)
      if !attacker.effects[PBEffects::Brainymedia]
        attacker.effects[PBEffects::Brainymedia]=true
        @battle.pbDisplay(_INTL("{1} is trying to take the target's brain with it!",attacker.pbThis))
      end
      return ret
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Brainymedia]=true
    @battle.pbDisplay(_INTL("{1} is trying to take the target's brain with it!",attacker.pbThis))
    return 0
  end
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Electric Terrain (Electric Glide)
################################################################################
class PokeBattle_Move_345 < PokeBattle_Move
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Misty Terrain (Misty Glide)
################################################################################
class PokeBattle_Move_346 < PokeBattle_Move
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Psychic Terrain (Psychic Glide)
################################################################################
class PokeBattle_Move_347 < PokeBattle_Move
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Volcanic Terrain (Volcanic Glide)
################################################################################
class PokeBattle_Move_348 < PokeBattle_Move
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Lovely Terrain (Lovely Glide)
################################################################################
class PokeBattle_Move_349 < PokeBattle_Move
end

################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Cinament (Cinematic Glide)
################################################################################
class PokeBattle_Move_350 < PokeBattle_Move
end

################################################################################
# All damaging moves that do not make any contact are bounced for the rest of 
# the round. (Trampoline)
################################################################################
class PokeBattle_Move_351 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || attacker.pbOwnSide.effects[PBEffects::Trampoline]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Trampoline] = true
    @battle.pbDisplay(_INTL("A trampoline emergenced!"))
    return 0
  end
end

################################################################################
# Power gets increased the more rooms are active (Tactie Cream)
################################################################################
class PokeBattle_Move_352 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult = 1
    # Boosts damage even if the user has Morfat
    mult += 1 if @battle.field.effects[PBEffects::TrickRoom]>0
    mult += 1 if @battle.field.effects[PBEffects::WonderRoom]>0
    mult += 1 if @battle.field.effects[PBEffects::MagicRoom]>0
    return basedmg*mult
  end
end

################################################################################
# Target becomes the user's favorite type. (Favorite Present)
################################################################################
class PokeBattle_Move_372 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==attacker.favtype &&
       opponent.type2==attacker.favtype &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==attacker.favtype)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=attacker.favtype
    opponent.type2=attacker.favtype
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(attacker.favtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# User gains half the HP it inflicts as damage. 
# Deals more power to opponents of the opposite gender (Doom Swash)
################################################################################
class PokeBattle_Move_386 < PokeBattle_Move_0DD
  def isHealingMove?
    return true
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if attacker.gender!=2 && opponent.gender!=2 &&
       attacker.gender!=opponent.gender
      return (damagemult*1.25).round
    end
    return damagemult
  end  
end

################################################################################
# Damage is multiplied by Normal's effectiveness against the target. 
# Has perfect accuracy if the target is doing a priority move. Fails if the user
# is not Multidock (Horatio)
################################################################################
class PokeBattle_Move_387 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:MULTIDOCK)
    return false
  end
  
  def unusableInGravity?
    return true
  end
  
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || -1
    if type>=0
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end

  def pbModifyBaseAccuracy(baseaccuracy,attacker,opponent)
    if (@battle.choices[opponent.index][2].priority>0)
      return 0
    end
    return baseaccuracy
  end  
end


################################################################################
################################################################################
# Generation VII Move Effects
################################################################################
################################################################################

################################################################################
# Heals user by an amount depending on the weather. (Shore Up)
################################################################################
class PokeBattle_Move_207 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if @battle.pbWeather==PBWeather::SANDSTORM
      hpgain=(attacker.totalhp*2/3).floor
    else
      hpgain=(attacker.totalhp/2).floor
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end

################################################################################
# Inflicts damage to the target. If the target is burned, the burn is healed.
# (Sparkling Aria)
################################################################################
class PokeBattle_Move_208 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.status==PBStatuses::BURN
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",opponent.pbThis))
    end
  end
end

################################################################################
# For 5 rounds, creates a psychic terrain which boosts Psychic-type moves and
# protects Pokémon from priority moves. Affects non-airborne Pokémon only.
# (Psychic Terrain)
################################################################################
class PokeBattle_Move_209 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbTerrain==PBBattleTerrains::PSYCHIC
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.terrain=PBBattleTerrains::PSYCHIC
    @battle.terrainduration=5
    @battle.terrainduration=8 if attacker.hasWorkingItem(:TERRAINEXTENDER)
    @battle.pbDisplay(_INTL("The battlefield got weird!"))
    attacker.checkMimicryAll
    return 0
  end
end

################################################################################
# Move type changes based on user's primary type (Revelation Dance)
################################################################################
class PokeBattle_Move_210 < PokeBattle_Move
  def pbModifyType(type,attacker,opponent)
    type=attacker.type1
    if !attacker.effects[PBEffects::Roost]
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=attacker.effects[PBEffects::Type3] if type==getConst(PBTypes,:QMARKS)
    else
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=getConst(PBTypes,:NORMAL) if type==getConst(PBTypes,:QMARKS)
    end
    return type
  end
end

################################################################################
# Shell Trap
################################################################################
class PokeBattle_Move_211 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if !attacker.effects[PBEffects::ShellTrap]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!",attacker.pbThis))
      return -1
    end
    return super(attacker)
  end
  
  def pbMoveFailed(attacker,opponent)
    return !attacker.effects[PBEffects::ShellTrap]
  end
end

################################################################################
# Instructs the target to use the move it last used again. (Instruct)
################################################################################
class PokeBattle_Move_212 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
      # TODO Z-Moves      
      0xB5,    # Assist
      0x220,   # Beak Blast
      0xD4,    # Bide
      0xAF,    # Copycat
      0x115,   # Focus Punch
      0xD3,    # Ice Ball, Rollout
      0x212,   # Instruct
      0xB0,    # Me First
      0xB6,    # Metronome
      0x5C,    # Mimic
      0xAE,    # Mirror Move
      0xB3,    # Nature Power
      0xD2,    # Outrage, Petal Dance, Thrash
      0x211,   # Shell Trap
      0x5D,    # Sketch
      0xB4,    # Sleep Talk
      0x02,    # Struggle
      0x69,    # Transform
      # Recharge moves
      0xC2,    # Hyper Beam etc.
      # Two-turn attacks
      0xCC,    # Bounce
      0xCA,    # Dig
      0xCB,    # Dive
      0xC9,    # Fly
      0xC5,    # Freeze Shock
      0x14E,   # Geomancy
      0xC6,    # Ice Burn
      0x14D,   # Phantom Force
      0xC3,    # Razor Wind
      0xCD,    # Shadow Force
      0xC8,    # Skull Bash
      0xC7,    # Sky Attack
      0xCE,    # Sky Drop
      0xC4,    # Solar Beam, Solar Blade
      0x336,   # Steel Fly
      0x378,   # Electro Shot
      0x245,   # Doom Catapult
      0x246,   # Fiery Catapult
      0x295,   # Grassy Catapult
      0x325    # Elder Special Moves
    ]
    for i in opponent.moves # if no pp left for move
      if i.id>0 && i.id==opponent.lastMoveUsed && i.pp==0
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    if opponent.lastMoveUsed<=0 ||
       blacklist.include?(PBMoveData.new(@battle.lastMoveUsed).function)
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    # Fail for Focus Punch, Beak Blast, Shell Trap preparation
    if @battle.choices[opponent.index][0]==1 # Chose a move
      oppmove=@battle.choices[opponent.index][2]
      if oppmove.function==0x115 || oppmove.function==0x211 || oppmove.function==0x220
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!",
       opponent.pbThis,attacker.pbThis(true)))
       opponent.pbUseMoveSimple(opponent.lastMoveUsed,-1,opponent.index)
    return 0
  end
end

################################################################################
# Steals target's stat boosts, then attacks (Spectral Thief)
################################################################################
class PokeBattle_Move_213 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.stages[1]>0 || opponent.stages[2]>0 || opponent.stages[3]>0 ||
      opponent.stages[4]>0 || opponent.stages[5]>0 || opponent.stages[6]>0 ||
      opponent.stages[7]>0
      stolenstats=[0,0,0,0,0,0,0,0]
      for i in 1...8
        if opponent.stages[i]>0 && attacker.stages[i]<6
          stolenstats[i]=[6-attacker.stages[i],opponent.stages[i]].min
          opponent.stages[i]-=stolenstats[i] # Reduce by number of stolen stages
        end
      end
      @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!",attacker.pbThis))
      showanim='mix' # Was true
      for i in 1...8
        if attacker.pbCanIncreaseStatStage?(i,attacker,true) && stolenstats[i]>0
          attacker.pbIncreaseStat(i,stolenstats[i],attacker,false,self,showanim)
          showanim=false
        end
      end
    end
    # actually attack now
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end

################################################################################
# Heals target instead of damaging them if they are an ally (Pollen Puff)
################################################################################
class PokeBattle_Move_214 < PokeBattle_Move  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if attacker.pbPartner!=nil && attacker.pbPartner==opponent
      if attacker.effects[PBEffects::HealBlock]>0 || opponent.effects[PBEffects::HealBlock]>0
        thismovename=PBMoves.getName(@id)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("{1} can't use {2} because of Heal Block!",attacker.pbThis,thismovename))
        PBDebug.log("[Move failed] #{attacker.pbThis} can't use #{thismovename} because of Heal Block")
        return -1
      elsif opponent.hp==opponent.totalhp
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))  
        return -1
      else
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) # Healing animation
        opponent.pbRecoverHP((opponent.totalhp/2).floor,true)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))  
        return 0
      end
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Raises Atk and Sp. Atk of ally and user with Plus or Minus (Gear Up)
# See Magnetic Flux
################################################################################
class PokeBattle_Move_215 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner]
      next if !i || i.isFainted?
      next if !i.hasWorkingAbility(:PLUS) && !i.hasWorkingAbility(:MINUS)
      next if !i.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
              !i.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      showanim='mix' # Was true
      if i.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
        i.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false
      end
      if i.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
        i.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
        showanim=false
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# User and target swap their Speed stats (Speed Swap)
################################################################################
class PokeBattle_Move_216 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.speed,opponent.speed=opponent.speed,attacker.speed
    @battle.pbDisplay(_INTL("{1} switched Speed with its target!",attacker.pbThis))
    return 0
  end
end

################################################################################
# After attacking, the user removes this move's type from their own typing
# This move cannot be used for a Pokemon for which the move isn't STAB (Burn Up)
# DO NOT USE: Another function code exists with the same effect albeilt workable
# on Lava-type mons as well
################################################################################
class PokeBattle_Move_217 < PokeBattle_Move
=begin
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    if !attacker.pbHasType?(type)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if type!=getConst(PBTypes,:FIRE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    @battle.pbDisplay(_INTL("{1} burned itself out!",attacker.pbThis))
    return ret
  end
=end
end

################################################################################
# Lower's the target's Speed by 1 stage and inflicts Poison. (Toxic Thread)
################################################################################
class PokeBattle_Move_218 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self) &&
       !opponent.pbCanPoison?(attacker,false,self)
       pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self) if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
    opponent.pbPoison(attacker) if opponent.pbCanPoison?(attacker,false,self)
    return 0
  end
end

################################################################################
# User heals target's status condition
# If successful, user heals itself by 50% of its max HP. (Purify)
################################################################################
class PokeBattle_Move_219 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if opponent.status==0
    case opponent.status
    when PBStatuses::PARALYSIS
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",opponent.pbThis))
    when PBStatuses::SLEEP
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} woke up.",opponent.pbThis))
    when PBStatuses::POISON
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",opponent.pbThis))
    when PBStatuses::BURN
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",opponent.pbThis))
    when PBStatuses::FROZEN
      opponent.pbCureStatus(false)
      @battle.pbDisplay(_INTL("{1} was thawed out.",opponent.pbThis))
    end
    if attacker.effects[PBEffects::HealBlock]>0
      thismovename=PBMoves.getName(@id)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1} can't use {2} because of Heal Block!",attacker.pbThis,thismovename))
    elsif attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
    else
      attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    return 0
  end
end

################################################################################
# (handled elsewhere) If anyone makes contact with the Pokemon while they are
#    charging this move, they will be inflicted with a burn (Beak Blast)
################################################################################
class PokeBattle_Move_220 < PokeBattle_Move
end

################################################################################
# User is protected against damaging moves this round. Poisons the 
# user of a stopped contact move. (Baneful Bunker)
################################################################################
class PokeBattle_Move_221 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::BanefulBunker]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::BanefulBunker]=true
    attacker.effects[PBEffects::ProtectRate]*=2 # changed
    # attacker.effects[PBEffects::ProtectRate]=[attacker.effects[PBEffects::ProtectRate],729].min # changed added
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Decreases the user's Defense by 1 stage. (Clanging Scales)
################################################################################
class PokeBattle_Move_222 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
        attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self)
      end
    end
    return ret
  end
end

################################################################################
# If the target has already moved this round, suppresses target's ability (Core Enforcer)
################################################################################
class PokeBattle_Move_223 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
          !opponent.isFainted?
        if opponent.hasMovedThisRound? &&
            !(opponent.hasUnstoppableAbility(attacker) ||
            isEternal?(opponent))
          oldabil=opponent.ability
          opponent.effects[PBEffects::GastroAcid]=true
          opponent.effects[PBEffects::Truant]=false
          @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis)) 
          if opponent.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
            PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Imprisin ended")    
            opponent.effects[PBEffects::Imprison]=false
            @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",opponent.pbThis,PBAbilities.getName(oldabil)))
          end
          if isConst?(opponent.species,PBSpecies,:ETV) && opponent.form>1
            opponent.form-=2
            opponent.pbUpdate(true)
            @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
            @battle.pbDisplay(_INTL("{1}'s parent child faded!",opponent.pbThis))
          end
          if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
            PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Illusion ended")    
            opponent.effects[PBEffects::Illusion]=nil
            @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
            @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
          end
        end
      end
      return ret
    end
  end
end

################################################################################
# Fails if this isn't the user's first turn. (First Impression)
################################################################################
class PokeBattle_Move_224 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount>1)
  end
end

################################################################################
# User loses 50% max HP rounded up. (Mind Blown)
################################################################################
class PokeBattle_Move_225 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if !attacker.hasMoldBreaker(nil)
      bearer=@battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
           bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
        return false
      end
    end
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    if !attacker.isFainted?
      if !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP((attacker.totalhp/2.0).round)
        attacker.pbFaint if attacker.isFainted?
      end
    end
  end
end

################################################################################
# Ignores abilities (Moongeist Beam, Sunsteel Strike)
################################################################################
class PokeBattle_Move_226 < PokeBattle_Move
  def pbOnStartUse(attacker)
    attacker.effects[PBEffects::TemporaryMoldBreaker]=true
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    attacker.effects[PBEffects::TemporaryMoldBreaker]=false
    if attacker.form==1 && 
      (isConst?(attacker.species,PBSpecies,:SOLGALEO) ||
        isConst?(attacker.species,PBSpecies,:LUNALA))
      attacker.form=0
      attacker.pbUpdate(true)
      @battle.scene.pbChangePokemon(attacker,attacker.pokemon)
    end
  end
end

################################################################################
# Becomes physical if Atk > Sp. Atk. Ignores abilities (Photon Geyser)
# (handled elsewhere) For Fused Necrozma only. Adds its ultra burst state 
# and makes it Ultra Necrozma forme
################################################################################
class PokeBattle_Move_227 < PokeBattle_Move
  def pbOnStartUse(attacker)
    attacker.effects[PBEffects::TemporaryMoldBreaker]=true
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    calcattackstage=attacker.stages[PBStats::ATTACK]+6
    calcattack=(attacker.attack*1.0*stagemul[calcattackstage]/stagediv[calcattackstage]).floor
    calcspatkstage=attacker.stages[PBStats::SPATK]+6
    calcspatk=(attacker.spatk*1.0*stagemul[calcspatkstage]/stagediv[calcspatkstage]).floor
    @category=(calcattack>calcspatk) ? 0 : 1
    return true
  end

  def pbEffectAfterHit(attacker,opponent,turneffects)
    attacker.effects[PBEffects::TemporaryMoldBreaker]=false
  end
end

################################################################################
# Heals the user for an amount equal to the target's effective Attack stat
# Lowers the target's Attack by 1 stage. (Strength Sap)
################################################################################
class PokeBattle_Move_228 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbTooLow?(PBStats::ATTACK)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end    
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    calcattackstage=opponent.stages[PBStats::ATTACK]+6
    hpgain=(opponent.attack*1.0*stagemul[calcattackstage]/stagediv[calcattackstage]).floor
    ret=-1
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self)
      ret=0
    end
    if opponent.hasWorkingAbility(:LIQUIDOOZE)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      attacker.pbReduceHP(hpgain,true)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      ret=0
    elsif attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
    elsif attacker.effects[PBEffects::HealBlock]==0
      hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      attacker.pbRecoverHP(hpgain,true)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
      ret=0
    end
    return ret
  end
end

################################################################################
# Causes the move's target to become the center of attention. (Spotlight)
################################################################################
class PokeBattle_Move_229 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::FollowMe]=1
    if !opponent.pbPartner.isFainted? && opponent.pbPartner.effects[PBEffects::FollowMe]>0
      opponent.effects[PBEffects::FollowMe]=opponent.pbPartner.effects[PBEffects::FollowMe]+1
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",opponent.pbThis))
    return 0
  end
end

################################################################################
# If the user's previous move has failed, the power of this move doubles.
# (Stomping Tantrum)
################################################################################
class PokeBattle_Move_230 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*2 if attacker.effects[PBEffects::LastMoveFailed]
    return basedmg
  end
end

################################################################################
# Hits twice. May flinch the target on each hit. (Double Iron Bash)
# Does double damage and has perfect accuracy if the target is Minimized.
################################################################################
class PokeBattle_Move_231 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
  
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end

################################################################################
# Heals user by an amount depending on the terrain. (Floral Healing)
################################################################################
class PokeBattle_Move_232 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if @battle.pbTerrain==PBBattleTerrains::GRASSY
      hpgain=(attacker.totalhp*2/3).floor
    else
      hpgain=(attacker.totalhp/2).floor
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, lowers power of physical and special attacks against the user's
# Side. (Aurora Veil)
################################################################################
class PokeBattle_Move_233 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbWeather!=PBWeather::HAIL
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::AuroraVeil]=5
    attacker.pbOwnSide.effects[PBEffects::AuroraVeil]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Aurora Veil made your team stronger against physical and special moves!"))
    else
      @battle.pbDisplay(_INTL("Aurora Veil made the opposing team stronger against physical and special moves!"))
    end  
    return 0
  end
end

################################################################################
# Prevents the target from using sound-based moves for two turns. (Throat Chop)
################################################################################
class PokeBattle_Move_234 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.isFainted?
      opponent.effects[PBEffects::ThroatChop]=2
    end
    return ret
  end
end

################################################################################
# The user's next move will be a critical hit (Laser Focus)
################################################################################
class PokeBattle_Move_235 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::LaserFocus]>0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::LaserFocus]=2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!",attacker.pbThis))
    return 0
    end
  end
end

################################################################################
################################################################################
# Generation VIII Move Effects
################################################################################
################################################################################

################################################################################
# Move type changes based on Morpeko form 
# Also Raises speed by 1 stage
# If not Morpeko, move fails (Aura Wheel)
################################################################################
class PokeBattle_Move_256 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !isConst?(attacker.species,PBSpecies,:MORPEKO)
    return false
  end
  

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    end
  end

  def pbModifyType(type,attacker,opponent)
    if attacker.form==0
      type=getConst(PBTypes,:DARK)
    else
      type=getConst(PBTypes,:ELECTRIC)
    end
    return type
  end
end

################################################################################
# In singles, this move hits the target twice. In doubles, this move hits each 
# target once. If one of the two opponents protects or while semi-invulnerable 
# or is immune to this move, it hits the opponent that doesn't protect twice. 
# (Dragon Darts)
################################################################################
class PokeBattle_Move_257 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
  
  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.isShiny?
      return super(id,attacker,opponent,1,alltargets,showanimation) # Shiny Animation
    end
    return super(id,attacker,opponent,0,alltargets,showanimation)
  end  
end

################################################################################
# (handled elsewhere) This move will ignore moves and abilities that can draw
# in other moves (Snipe Shot)
################################################################################
class PokeBattle_Move_259 < PokeBattle_Move
end

################################################################################
# Increases the user's stat by 1 stage and prevents itself from fleeing
# or switching out (No retreat)
################################################################################
class PokeBattle_Move_260 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
    if attacker.effects[PBEffects::NoRetreat] && !attacker.effects[PBEffects::MeanLook]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    attacker.effects[PBEffects::NoRetreat]=true
    if ret==-1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return ret
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# In addition, each turn, Sp.Def of that user is also being reduced by 1 stage
# (Octolock)
################################################################################
class PokeBattle_Move_261 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.isFainted?
        if opponent.effects[PBEffects::Octolock]==false &&
           !(opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
             opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
          opponent.effects[PBEffects::Octolock]=true
          @battle.pbDisplay(_INTL("{1} was caught in the Octolock!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::Octolock] ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
      opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Octolock]=true
    @battle.pbDisplay(_INTL("{1} was caught in the Octolock!",opponent.pbThis))
    return 0
  end
end


################################################################################
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped contact move by 2 stages. (Obstruct)
################################################################################
class PokeBattle_Move_262 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Obstruct]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved ||
       @battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Obstruct]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Increases the target's Offensive stats by 2 stages (Decorate)
################################################################################
class PokeBattle_Move_263 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !opponent.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end

################################################################################
# Causes all other users to consume their held berries (Teatime)
################################################################################
class PokeBattle_Move_264 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    didsomething=false
    for i in [attacker,attacker.pbPartner,attacker.pbOpposing1,attacker.pbOpposing2]
      next if !i || i.isFainted?
      next if !i.hasWorkingBerry
      next if i.effects[PBEffects::TwoTurnAttack]>0
      next if i.pokemon.corrosiveGas
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      i.pbActivateBerryEffect(i.item,false)
    end
    if !didsomething
      @battle.pbDisplay(_INTL("But nothing happened..."))
      return -1
    else
      @battle.pbDisplay(_INTL("The battle is having a teatime"))
      return 0
    end
  end
end

################################################################################
# Target becomes Psychic type. (Magic Powder)
################################################################################
class PokeBattle_Move_265 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE)  ||
       isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.type1==getConst(PBTypes,:PSYCHIC) &&
       opponent.type2==getConst(PBTypes,:PSYCHIC) &&
       (opponent.effects[PBEffects::Type3]<0 ||
       opponent.effects[PBEffects::Type3]==getConst(PBTypes,:PSYCHIC))
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Mimicry] = false
    opponent.type1=getConst(PBTypes,:PSYCHIC)
    opponent.type2=getConst(PBTypes,:PSYCHIC)
    opponent.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(getConst(PBTypes,:PSYCHIC))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# (Jaw Lock)
################################################################################
class PokeBattle_Move_266 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsDamaging?
      ret=super(attacker,opponent,hitnum,alltargets,showanimation)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.isFainted?
        if opponent.effects[PBEffects::JawLock]==false &&
           !(opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
             opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
           attacker.effects[PBEffects::JawLock]=true
           opponent.effects[PBEffects::JawLock]=true
          @battle.pbDisplay(_INTL("{1} and you can no longer escape!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::JawLock] ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
        pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.pbHasType?(:GHOST) || opponent.pbHasType?(:DOOM) || 
        opponent.pbHasType?(:SUN) || opponent.pbHasType?(:MOON))
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::JawLock]=opponent.index
    opponent.effects[PBEffects::JawLock]=attacker.index
    @battle.pbDisplay(_INTL("{1} and you can no longer escape!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Eats the berry and sharply raises defense (Stuff Cheeks)
# (handled elsehere) Fails if no berry is being held
################################################################################
class PokeBattle_Move_267 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pokemon.corrosiveGas
      @battle.pbDisplay("But it failed!")
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbActivateBerryEffect(attacker.item,false) if attacker.hasWorkingBerry
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,attacker,false,self,showanim)
      showanim=false
    end
  end
end

################################################################################
# Power is doubled if the target hasn't moved this round.
# (Bolt Break, Fishious Rend)
################################################################################
class PokeBattle_Move_268 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if !(@battle.choices[opponent.index][0]!=1 || # Choosen a move already
       opponent.hasMovedThisRound?) # Didn't used a move
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# (handled elsewhere) User's Defense is used for damage calculation (Body Press)
################################################################################
class PokeBattle_Move_269 < PokeBattle_Move
end

################################################################################
# Heals user and partner by 1/3 of its max HP. (Life Dew)
################################################################################
class PokeBattle_Move_270 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp && 
       attacker.pbPartner.hp==attacker.pbPartner.totalhp
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    hpgain=0
    hpgain=((attacker.totalhp+1)/3).floor if !(attacker.hp==attacker.totalhp)
    attacker.pbRecoverHP(hpgain,true) if hpgain!=0
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis)) if hpgain!=0
    if !attacker.pbPartner.isFainted?
      hpgain=0
      hpgain=((attacker.pbPartner.totalhp+1)/3).floor if !(attacker.pbPartner.hp==attacker.totalhp)
      attacker.pbPartner.pbRecoverHP(hpgain,true) if !(attacker.pbPartner.hp==attacker.pbPartner.totalhp)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbPartner.pbThis)) if hpgain!=0
    end
    return 0
  end
end

################################################################################
# Increases the user's stat by 1 stage and loses some HP
# or switching out (Clangorous Soul)
################################################################################
class PokeBattle_Move_271 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
      sublife=[(attacker.totalhp/6).floor,1].max
    if attacker.hp<=sublife
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It was too weak to raise its stats!"))
      return -1  
    end
    attacker.pbReduceHP(sublife)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if ret==-1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return ret
  end
end

################################################################################
# Switches entry hazards between teams (Court Change)
################################################################################
class PokeBattle_Move_272 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    changeside=false
    for i in 0...2
      next if @battle.sides[i].effects[PBEffects::Reflect]==0 && 
              @battle.sides[i].effects[PBEffects::LightScreen]==0 && 
              @battle.sides[i].effects[PBEffects::AuroraVeil]==0 &&
              @battle.sides[i].effects[PBEffects::SeaOfFire]==0 && # Fire Pledge
              @battle.sides[i].effects[PBEffects::Swamp]==0 &&     # Grass Pledge
              @battle.sides[i].effects[PBEffects::Rainbow]==0 &&   # Water Pledge
              @battle.sides[i].effects[PBEffects::Mist]==0 && 
              @battle.sides[i].effects[PBEffects::Safeguard]==0 && 
             !@battle.sides[i].effects[PBEffects::StealthRock] && 
              @battle.sides[i].effects[PBEffects::Spikes]==0 && 
             !@battle.sides[i].effects[PBEffects::StickyWeb] && 
              @battle.sides[i].effects[PBEffects::ToxicSpikes]==0 && 
              @battle.sides[i].effects[PBEffects::Tailwind]==0 &&
              @battle.sides[i].effects[PBEffects::Electromania]==0 && 
              @battle.sides[i].effects[PBEffects::Fierymania]==0 && 
              @battle.sides[i].effects[PBEffects::ToxicSwamp]==0 && 
              @battle.sides[i].effects[PBEffects::Brainologic]==0
      changeside=true
    end
    if !changeside
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      ownside=@battle.sides[0]; oppside=@battle.sides[1]
      reflect=ownside.effects[PBEffects::Reflect]
      ownside.effects[PBEffects::Reflect]=oppside.effects[PBEffects::Reflect]
      oppside.effects[PBEffects::Reflect]=reflect
      lightscreen=ownside.effects[PBEffects::LightScreen]
      ownside.effects[PBEffects::LightScreen]=oppside.effects[PBEffects::LightScreen]
      oppside.effects[PBEffects::LightScreen]=lightscreen
      auroraveil=ownside.effects[PBEffects::AuroraVeil]
      ownside.effects[PBEffects::AuroraVeil]=oppside.effects[PBEffects::AuroraVeil]
      oppside.effects[PBEffects::AuroraVeil]=auroraveil
      firepledge=ownside.effects[PBEffects::SeaOfFire]
      ownside.effects[PBEffects::SeaOfFire]=oppside.effects[PBEffects::SeaOfFire]
      oppside.effects[PBEffects::SeaOfFire]=firepledge
      grasspledge=ownside.effects[PBEffects::Swamp]
      ownside.effects[PBEffects::Swamp]=oppside.effects[PBEffects::Swamp]
      oppside.effects[PBEffects::Swamp]=grasspledge
      waterpledge=ownside.effects[PBEffects::Rainbow]
      ownside.effects[PBEffects::Rainbow]=oppside.effects[PBEffects::Rainbow]
      oppside.effects[PBEffects::Rainbow]=waterpledge
      mist=ownside.effects[PBEffects::Mist]
      ownside.effects[PBEffects::Mist]=oppside.effects[PBEffects::Mist]
      oppside.effects[PBEffects::Mist]=mist
      spikes=ownside.effects[PBEffects::Spikes]
      ownside.effects[PBEffects::Spikes]=oppside.effects[PBEffects::Spikes]
      oppside.effects[PBEffects::Spikes]=spikes
      toxicspikes=ownside.effects[PBEffects::ToxicSpikes]
      ownside.effects[PBEffects::ToxicSpikes]=oppside.effects[PBEffects::ToxicSpikes]
      oppside.effects[PBEffects::ToxicSpikes]=toxicspikes
      stealthrock=ownside.effects[PBEffects::StealthRock]
      ownside.effects[PBEffects::StealthRock]=oppside.effects[PBEffects::StealthRock]
      oppside.effects[PBEffects::StealthRock]=stealthrock
      stickyweb=ownside.effects[PBEffects::StickyWeb]
      ownside.effects[PBEffects::StickyWeb]=oppside.effects[PBEffects::StickyWeb]
      oppside.effects[PBEffects::StickyWeb]=stickyweb
      tailwind=ownside.effects[PBEffects::Tailwind]
      ownside.effects[PBEffects::Tailwind]=oppside.effects[PBEffects::Tailwind]
      oppside.effects[PBEffects::Tailwind]=tailwind
      electromania=ownside.effects[PBEffects::Electromania]
      ownside.effects[PBEffects::Electromania]=oppside.effects[PBEffects::Electromania]
      oppside.effects[PBEffects::Electromania]=electromania
      fierymania=ownside.effects[PBEffects::Fierymania]
      ownside.effects[PBEffects::Fierymania]=oppside.effects[PBEffects::Fierymania]
      oppside.effects[PBEffects::Fierymania]=fierymania
      toxicswamp=ownside.effects[PBEffects::ToxicSwamp]
      ownside.effects[PBEffects::ToxicSwamp]=oppside.effects[PBEffects::ToxicSwamp]
      oppside.effects[PBEffects::ToxicSwamp]=toxicswamp
      brainologic=ownside.effects[PBEffects::Brainologic]
      ownside.effects[PBEffects::Brainologic]=oppside.effects[PBEffects::Brainologic]
      oppside.effects[PBEffects::Brainologic]=brainologic
      @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!",attacker.pbThis))
      return 0
    end
  end
end

################################################################################
# Decreases the target's Speed by 1 stage and becomes weaker to fire moves
# (Tar Shot)
################################################################################
class PokeBattle_Move_273 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    return ret ? 0 : -1
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if isConst?(@id,PBMoves,:TARSHOT) && !opponent.effects[PBEffects::TarShot]
      opponent.effects[PBEffects::TarShot]=true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!",opponent.pbThis))
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      opponent.pbReduceStat(PBStats::SPEED,1,attacker,false,self)
    end
  end
end

################################################################################
# Increases the user's OR the side's Attack by 1 stage. (Howl)
################################################################################
class PokeBattle_Move_280 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1;
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,true)
      ret=0
    end
    if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbPartner.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,true)
      ret=0
    end
    return ret
  end
end


################################################################################
################################################################################
# Generation VIII IoA and TCT Move Effects
################################################################################
################################################################################

################################################################################
# Damages all Pokemon and increases power in Psychic Terrain (Expanding Force)
################################################################################
class PokeBattle_Move_305 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if  @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      return (damagemult*1.5).round
    end
    return damagemult
  end
end


################################################################################
# Damages an enemy, ends all terrains and fails if no terrain or Glimmy Galaxy
# is being active (Steel Roller)
################################################################################
class PokeBattle_Move_306 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.pbTerrain==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.terrain=0
    @battle.terrainduration=0
    return 0
  end
end


################################################################################
# Hits 2-5 times. Lowers User's Defense but Increases User's Speed by 1 stage
# each for each hit (Scale Shot)
################################################################################
class PokeBattle_Move_307 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    hitchances=[2,2,3,3,4,5]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=5 if attacker.hasWorkingAbility(:SKILLLINK)
    ret=4 if attacker.hasWorkingItem(:LOADEDDICE) && ret < 4
    return ret
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    return if opponent.damagestate.substitute
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self)
    end
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      attacker.pbReduceStat(PBStats::DEFENSE,1,attacker,false,self)
    end
  end
end


################################################################################
# Two turn attack. Ups user's Sp.Atk by 1 stage first turn, attacks second turn.
# (Meteor Beam)
################################################################################
class PokeBattle_Move_308 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
     # @battle.pbDisplay(_INTL("{1} tucked in its head!",attacker.pbThis))
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
        attacker.pbIncreaseStat(PBStats::SPATK,1,attacker,false,self)
      end
    end
    if @immediate
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end


################################################################################
# Becomes physical if Atk > Sp. Atk. May Poison the target (Shell Side Arm)
################################################################################
class PokeBattle_Move_309 < PokeBattle_Move
  def pbOnStartUse(attacker)
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    calcattackstage=attacker.stages[PBStats::ATTACK]+6
    calcattack=(attacker.attack*1.0*stagemul[calcattackstage]/stagediv[calcattackstage]).floor
    calcspatkstage=attacker.stages[PBStats::SPATK]+6
    calcspatk=(attacker.spatk*1.0*stagemul[calcspatkstage]/stagediv[calcspatkstage]).floor
    calcdefensestage=opponent.stages[PBStats::DEFENSE]+6
    calcdefense=(opponent.defense*1.0*stagemul[calcdefensestage]/stagediv[calcdefensestage]).floor
    calcspdefstage=opponent.stages[PBStats::SPDEF]+6
    calcspdef=(opponent.spdef*1.0*stagemul[calcspdefstage]/stagediv[calcspdefstage]).floor    
    @category=(calcattack-calcdefense>calcspatk-calcspdef) ? 0 : 1
    @flags= (calcattack-calcdefense>calcspatk-calcspdef) ? @flags : @flags && (0x02 || 0x10 || 0x20) #Turns off contact if special move    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if !opponent.pbCanPoison?(attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker)
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanPoison?(attacker,false,self)
      opponent.pbPoison(attacker)
    end
  end

end


################################################################################
# (handled elsewhere) This move will have increased priority when used in
# Grassy Terrain (Grassy Glide)
################################################################################
class PokeBattle_Move_310 < PokeBattle_Move
end


################################################################################
# Power is doubled in Electric Terrain (Rising Voltage)
################################################################################
class PokeBattle_Move_311 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if  @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      return (damagemult*2.0).round
    end
    return damagemult
  end
end


################################################################################
# Type varies between terrains. Power is doubled when executed within an active
# terrain (Terrain Pulse)
################################################################################
class PokeBattle_Move_312 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if @battle.pbTerrain==0
      return damagemult
    end
    return (damagemult*2.0).round
  end

  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:NORMAL) || 0
    if @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      type=getConst(PBTypes,:ELECTRIC) if hasConst?(PBTypes,:ELECTRIC)
    elsif @battle.pbTerrain==PBBattleTerrains::GRASSY
      type=getConst(PBTypes,:GRASS) if hasConst?(PBTypes,:GRASS)
    elsif @battle.pbTerrain==PBBattleTerrains::MISTY
      type=getConst(PBTypes,:FAIRY) if hasConst?(PBTypes,:FAIRY)
    elsif @battle.pbTerrain==PBBattleTerrains::PSYCHIC
      type=getConst(PBTypes,:PSYCHIC) if hasConst?(PBTypes,:PSYCHIC)
    elsif @battle.pbTerrain==PBBattleTerrains::CINAMENT
      type=getConst(PBTypes,:BOLT) if hasConst?(PBTypes,:BOLT)
    elsif @battle.pbTerrain==PBBattleTerrains::VOLCANIC
      type=getConst(PBTypes,:LAVA) if hasConst?(PBTypes,:LAVA)
    elsif @battle.pbTerrain==PBBattleTerrains::LOVELY
      type=getConst(PBTypes,:HEART) if hasConst?(PBTypes,:HEART)
    end
    return type
  end
end

################################################################################
# Burns opposing Pokemon that have increased their stats in that turn before the
# execution of this move (Burning Jealousy)
################################################################################
class PokeBattle_Move_313 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanBurn?(attacker,false,self) && 
       opponent.effects[PBEffects::BurningJelousy]
      opponent.pbBurn(attacker)
    end
  end
end


################################################################################
# Power is doubled if user's stats were reduced in the turn the move would be
# executed (Lash Out)
################################################################################
class PokeBattle_Move_314 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if attacker.effects[PBEffects::LashOut]
      return (damagemult*2.0).round
    end
    return damagemult
  end
end


################################################################################
# Fails unless the target has a usable item (Poltergeist)
################################################################################
class PokeBattle_Move_315 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if opponent.item==0 ||
                   (@battle.field.effects[PBEffects::MagicRoom]>0 && 
                    !opponent.hasWorkingAbility(:MORFAT)) ||
                   opponent.hasWorkingAbility(:KLUTZ) ||
                   opponent.effects[PBEffects::Embargo]>0
    @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!",opponent.pbThis,PBItems.getName(opponent.item)))
    return false
  end

end

################################################################################
# Melts opposing Pokemon's Held items (Corrosive Gas)
################################################################################
class PokeBattle_Move_316 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if opponent.item==0 ||
      (@battle.field.effects[PBEffects::MagicRoom]>0 && 
      !opponent.hasWorkingAbility(:MORFAT)) ||
       opponent.hasWorkingAbility(:KLUTZ) ||
       opponent.hasWorkingAbility(:STICKYHOLD) ||
       opponent.pbHasType?(:GAS) ||
       opponent.pokemon.corrosiveGas ||
       opponent.effects[PBEffects::Embargo]>0
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      opponent.pokemon.corrosiveGas=true
      @battle.pbDisplay(_INTL("{1} corroded {2}'s {3}!",attacker.pbThis,opponent.pbThis,
                                                       PBItems.getName(opponent.item)))
      return 0
    end
  end
end

################################################################################
# Increases the ally's Attack and Defense by 1 stage each (Coaching)
################################################################################
class PokeBattle_Move_317 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle || !opponent
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !opponent.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if opponent.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::DEFENSE,1,attacker,false,self,showanim)
      showanim=false
    end
    return 0
  end
end

################################################################################
# Heals user and partner by 1/3 of its max HP. (Jungle Healing)
################################################################################
class PokeBattle_Move_318 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp && 
       attacker.pbPartner.hp==attacker.pbPartner.totalhp &&
       attacker.status==0 && attacker.pbPartner.status==0
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!",attacker.pbThis))
      return -1
    end
    case attacker.status
    when PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",attacker.pbThis))
    when PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s sleep was woken.",attacker.pbThis))
    when PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
    when PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",attacker.pbThis))
    when PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1} was thawed out.",attacker.pbThis))
    end
    attacker.pbCureStatus(false)
    case attacker.pbPartner.status
    when PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",attacker.pbPartner.pbThis))
    when PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s sleep was woken.",attacker.pbPartner.pbThis))
    when PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbPartner.pbThis))
    when PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",attacker.pbPartner.pbThis))
    when PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1} was thawed out.",attacker.pbPartner.pbThis))
    end
    attacker.pbPartner.pbCureStatus(false)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    hpgain=0
    hpgain=((attacker.totalhp)/1).floor if !(attacker.hp==attacker.totalhp)
    attacker.pbRecoverHP(hpgain,true) if hpgain!=0
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis)) if hpgain!=0
    if !attacker.pbPartner.isFainted?
      hpgain=0
      hpgain=((attacker.pbPartner.totalhp)/1).floor if !(attacker.pbPartner.hp==attacker.totalhp)
      attacker.pbPartner.pbRecoverHP(hpgain,true) if !(attacker.pbPartner.hp==attacker.pbPartner.totalhp)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbPartner.pbThis)) if hpgain!=0
    end
    return 0
  end
end

################################################################################
# Hits 3 times. This attack is always a critical hit. (Surging Strikes)
################################################################################
class PokeBattle_Move_319 < PokeBattle_Move
  def pbCritialOverride(attacker,opponent)
    return true
  end

  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end


################################################################################
# Target's last move used loses 3 PP. (Eerie Spell)
################################################################################
class PokeBattle_Move_321 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    for i in opponent.moves
      if ret>0 && i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        reduction=[3,i.pp].min
        i.pp-=reduction
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),i.name,reduction))
      end
    end
    return ret
  end
end

################################################################################
################################################################################
# Generation VIII Legends: Arceus Move Effects
################################################################################
################################################################################

################################################################################
# May also paralyze, poison or leave asleep the tagret (Dire Claw)
################################################################################
class PokeBattle_Move_328 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    case @battle.pbRandom(3)
    when 0
      if opponent.pbCanPoison?(attacker,false,self)
        opponent.pbPoison(attacker)
      end
    when 1
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze
      end
    when 2
      if opponent.pbCanSleep?(attacker,false,self)
        opponent.pbSleep(attacker)
      end
    end
  end

end

################################################################################
# Power is doubled if the target has a status condition
################################################################################
class PokeBattle_Move_329 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status!=0
      return basedmg*2
    end
    return basedmg
  end
end


################################################################################
# Heals user by 1/2 of its max HP and cures status conditions (Lunar Blessing)
################################################################################
class PokeBattle_Move_330 < PokeBattle_Move
  def isHealingMove?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp &&
       attacker.status!=PBStatuses::BURN &&
       attacker.status!=PBStatuses::POISON &&
       attacker.status!=PBStatuses::PARALYSIS
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if attacker.hp!=attacker.totalhp
      attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    # Recovercy
    if (attacker.status=PBStatuses::BURN ||
       attacker.status=PBStatuses::POISON ||
       attacker.status=PBStatuses::PARALYSIS)
       t=attacker.status
       attacker.pbCureStatus(false)
       pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
       if t==PBStatuses::BURN
         @battle.pbDisplay(_INTL("{1} healed its burn!",attacker.pbThis))  
       elsif t==PBStatuses::POISON
         @battle.pbDisplay(_INTL("{1} cured its poisoning!",attacker.pbThis))  
       elsif t==PBStatuses::PARALYSIS
         @battle.pbDisplay(_INTL("{1} cured its paralysis!",attacker.pbThis))  
       end
    end
    return 0
  end
end

################################################################################
# Swaps the user's Offensive and Defense stats. (Power Shift)
################################################################################
class PokeBattle_Move_331 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.attack,attacker.defense=attacker.defense,attacker.attack
    attacker.spatk,attacker.spdef=attacker.spdef,attacker.spatk
    @battle.pbDisplay(_INTL("{1} switched its Offsense and Defense!",attacker.pbThis))
    return 0
  end
end

################################################################################
################################################################################
# Generation IX Move Effects
################################################################################
################################################################################

################################################################################
# Move type changes based on user's primary type
# Becomes physical if Atk > Sp. Atk. Ignores abilities (Tera Blast)
################################################################################
class PokeBattle_Move_353 < PokeBattle_Move
  def pbOnStartUse(attacker)
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    calcattackstage=attacker.stages[PBStats::ATTACK]+6
    calcattack=(attacker.attack*1.0*stagemul[calcattackstage]/stagediv[calcattackstage]).floor
    calcspatkstage=attacker.stages[PBStats::SPATK]+6
    calcspatk=(attacker.spatk*1.0*stagemul[calcspatkstage]/stagediv[calcspatkstage]).floor
    @category=(calcattack>calcspatk) ? 0 : 1
    return true
  end

  def pbModifyType(type,attacker,opponent)
    type=attacker.type1
    if !attacker.effects[PBEffects::Roost]
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=attacker.effects[PBEffects::Type3] if type==getConst(PBTypes,:QMARKS)
    else
      type=attacker.type2 if type==getConst(PBTypes,:QMARKS)
      type=getConst(PBTypes,:NORMAL) if type==getConst(PBTypes,:QMARKS)
    end
    return type
  end

end

################################################################################
# User is protected against damaging moves this round. Decreases the Speed of
# the user of a stopped contact move by 1 stage. (Silk Trap)
################################################################################
class PokeBattle_Move_354 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::KingsShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::SilkTrap]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Confuses the target. If attack misses, user takes crash damage of 1/2 of max 
# HP. (Axe Kick)
################################################################################
class PokeBattle_Move_355 < PokeBattle_Move_013
 
  def isRecoilMove?
    return true
  end

  def unusableInGravity?
    return true
  end
  
end

################################################################################
# Power increases the more fainted allies are in the party. (Last Respects)
################################################################################
class PokeBattle_Move_356 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    mult = @battle.pbAmountOfFaintedAllies(attacker.index)+1
    return damagemult*mult
  end
end

################################################################################
# Increases the user's Speed, Attack OR Defense by 1 stage (Order Up)
################################################################################
class PokeBattle_Move_357 < PokeBattle_Move
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if !isConst?(attacker.pbPartner.species,PBSpecies,:TATSUGIRI)
			pbPlayMissSE() if !pbIsDamaging?
      @battle.pbDisplay(_INTL("But it failed!")) if !pbIsDamaging?
      return -1
    else
      stat = [PBStats::SPEED,PBStats::ATTACK,PBStats::DEFENSE][attacker.pbPartner.form]
    end
    return -1 if !attacker.pbCanIncreaseStatStage?(stat,attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(stat,1,attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if isConst?(attacker.pbPartner.species,PBSpecies,:TATSUGIRI)
      stat = [PBStats::SPEED,PBStats::ATTACK,PBStats::DEFENSE][attacker.pbPartner.form]
      if attacker.pbCanIncreaseStatStage?(stat,attacker,false,self)
        attacker.pbIncreaseStat(stat,1,attacker,false,self)
      end
    end
  end
end

################################################################################
# Decreases the target's Defense by 2 stage each. (Spicy Extract)
# Increases the target's Attack by 2 stages each.
################################################################################
class PokeBattle_Move_358 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self) &&
       !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
			pbPlayMissSE()
       @battle.pbDisplay(_INTL("{1}'s stats won't go any higher or lower!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self,true)
    end
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      opponent.pbReduceStat(PBStats::DEFENSE,2,attacker,false,self,true)
    end
    return 0
  end
end

################################################################################
# Hits 10 times. Power is multiplied by the hit number. (Population Bomb)
# An accuracy check is performed for each hit.
################################################################################
class PokeBattle_Move_359 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return [4,5,6,7,8,9,10][rand(7)] if attacker.hasWorkingItem(:LOADEDDICE)
    return 10
  end

  def successCheckPerHit?
    return @checks
  end

  def pbOnStartUse(attacker)
    @calcbasedmg=@basedamage
    @checks=!(attacker.hasWorkingAbility(:SKILLLINK) || 
              attacker.hasWorkingItem(:LOADEDDICE))
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    return ret
  end
end

################################################################################
# Ends all Terrains. (Ice Spinner)
################################################################################
class PokeBattle_Move_360 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.terrain=0
    @battle.terrainduration=0
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    @battle.terrain=0
    @battle.terrainduration=0
  end
end

################################################################################
# Target's attack next round against the user will definitely hit and have double
# damage (Glaive Rush)
################################################################################
class PokeBattle_Move_361 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.isFainted?
        attacker.effects[PBEffects::GlaiveRush]=2
        attacker.effects[PBEffects::GlaiveRushPos]=attacker.index
    end
    return ret
  end
end

################################################################################
# Revives a random Pokemon by half of its total HP (Revival Blessing)
################################################################################
class PokeBattle_Move_362 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.pbAmountOfFaintedAllies(attacker.index)<1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newpoke=0
    newpoke=@battle.pbSelectFaintedPlayer(attacker.index)
    pkmn = @battle.pbParty(attacker.index)[newpoke]
    newpokename=pkmn.name
		pkmn.hp=(pkmn.totalhp/2).floor
		pkmn.healStatus
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",newpokename))
    return 0
  end
end

################################################################################
# User and its ally copies target's ability. (Doodle)
################################################################################
class PokeBattle_Move_363 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    didsomething=false
    for i in [attacker,attacker.pbPartner]
      next if !i || i.isFainted?
      next if opponent.ability==0 ||
              i.ability==opponent.ability ||
               i.hasUnstoppableAbility(nil) ||
               opponent.hasUngainableAbility(attacker,[:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD])
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) if !didsomething
      didsomething=true
      oldabil=i.ability
      i.ability=opponent.ability
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",i.pbThis,opponent.pbThis(true),abilityname))
      if i.effects[PBEffects::Imprison] && isConst?(oldabil,PBAbilities,:IMPRISIN)
        PBDebug.log("[Ability triggered] #{i.pbThis}'s Imprisin ended")    
        attacker.effects[PBEffects::Imprison]=false
        @battle.pbDisplay(_INTL("{1}'s {2} finally bought back the sealed move(s) to the opposing Pokémon!",attacker.pbThis,PBAbilities.getName(oldabil)))
      end
      if isConst?(i.species,PBSpecies,:ETV) && i.form>1
        i.form-=2
        i.pbUpdate(true)
        @battle.scene.pbChangePokemon(i,i.pokemon)
        @battle.pbDisplay(_INTL("{1}'s parent child faded!",i.pbThis))
      end
      if i.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
        PBDebug.log("[Ability triggered] #{i.pbThis}'s Illusion ended")    
        i.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(i,i.pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",i.pbThis,PBAbilities.getName(oldabil)))
      end
    end
    if !didsomething
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack, Special Attack and Speed stats by 2 stage and
# loses some HP (Fillet Away)
################################################################################
class PokeBattle_Move_364 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim='mix' # Was true
      sublife=[(attacker.totalhp/2).floor,1].max
    if attacker.hp<=sublife
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("It was too weak to raise its stats!"))
      return -1  
    end
    attacker.pbReduceHP(sublife)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPATK,2,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,2,attacker,false,self,showanim)
      showanim=false
      ret=0
    end
    if ret==-1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return ret
  end
end

################################################################################
# Decreases the user's Special Attack by 1 stage. 
# Scatters coins that the player picks up after winning the battle. (Make it Rain)
################################################################################
class PokeBattle_Move_365 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.extramoney+=5*attacker.level
        @battle.extramoney=MAXMONEY if @battle.extramoney>MAXMONEY
      end
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
      if attacker.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        attacker.pbReduceStat(PBStats::SPATK,1,attacker,false,self)
      end
    end
    return ret
  end
end

################################################################################
# Halves the user's HP and turns 1/4 of max HP into a substitute Switches out 
# the user and passes the substitute to the switched Pokemon. (Shed Tail)
################################################################################
class PokeBattle_Move_366 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    sublife=[(attacker.totalhp/2).floor,1].max
    sublife2=[(attacker.totalhp/4).floor,1].max
    if !attacker.isFainted? &&
        attacker.effects[PBEffects::Substitute]==0 &&
        attacker.hp>sublife &&
       @battle.pbCanChooseNonActive?(attacker.index)
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
         attacker.pbReduceHP(sublife,false,false)
         attacker.effects[PBEffects::Uturn]=true
         attacker.effects[PBEffects::ShedTail]=sublife2
        return 0
    else
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Switches out the user. (Chilly Reception)
# Also makes hail if it can be created
################################################################################
class PokeBattle_Move_367 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.isFainted? &&
       @battle.pbCanChooseNonActive?(attacker.index)
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
          if @battle.weather != PBWeather::HEAVYRAIN || 
             @battle.weather != PBWeather::HARSHSUN ||
             @battle.weather != PBWeather::STRONGWINDS ||
             @battle.weather != PBWeather::HAIL
            @battle.weather=PBWeather::HAIL
            @battle.weatherduration=5
            @battle.weatherduration=8 if attacker.hasWorkingItem(:ICYROCK)
            @battle.pbCommonAnimation("Hail",nil,nil)
            @battle.pbDisplay(_INTL("It started to hail!"))
          end
         attacker.effects[PBEffects::Uturn]=true
        return 0
     else
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Increases the user's Attack and Spped by 1 stage each.
# Ends Spikes, Stealth Rock, Sticky Web and Toxic Spikes as well (Tidy Up)
################################################################################
class PokeBattle_Move_368 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,attacker,false,self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim='mix' # Was true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,attacker,false,self,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,attacker,false,self)
      attacker.pbIncreaseStat(PBStats::SPEED,1,attacker,false,self,showanim)
      showanim=false
    end
    for i in [attacker,opponent]
      if i.pbOwnSide.effects[PBEffects::StealthRock]
        i.pbOwnSide.effects[PBEffects::StealthRock]=false
        @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",attacker.pbThis))     
      end
      if i.pbOwnSide.effects[PBEffects::Spikes]>0
        i.pbOwnSide.effects[PBEffects::Spikes]=0
        @battle.pbDisplay(_INTL("{1} blew away Spikes!",attacker.pbThis))     
      end
      if i.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        i.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
        @battle.pbDisplay(_INTL("{1} blew away poison spikes!",attacker.pbThis))     
      end
      if i.pbOwnSide.effects[PBEffects::StickyWeb]
        i.pbOwnSide.effects[PBEffects::StickyWeb]=false
        @battle.pbDisplay(_INTL("{1} blew away sticky webs!",attacker.pbThis))     
      end
    end
    return 0
  end
end

################################################################################
# Power increases the more hits it took on the battle while active (Rage Fist)
# Counter is kept even if fainted
################################################################################
class PokeBattle_Move_369 < PokeBattle_Move

  def pbModifyDamage(damagemult,attacker,opponent)
    mult = met=1+1*[attacker.ragefist,6].min
    return damagemult*mult
  end


end

################################################################################
# After attacking, the user removes this move's type from their own typing
# This move cannot be used for a Pokemon for which the move isn't STAB (Double Shock)
# Can work on Bolt Type Pokemon. Move will be Bolt-type if used by Bolt
# Bolt-Electric Pokemon will have this move working as dual-type move
################################################################################
class PokeBattle_Move_370 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    if !(attacker.pbHasType?(:ELECTRIC) || attacker.pbHasType?(:BOLT))
      pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !(type==getConst(PBTypes,:ELECTRIC) || type==getConst(PBTypes,:BOLT))
        pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    # Electric Case
    type=getConst(PBTypes,:ELECTRIC)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    # Bolt Case
    type=getConst(PBTypes,:BOLT)
    if attacker.effects[PBEffects::Type3]==type
      attacker.effects[PBEffects::Type3]=-1
    end
    if attacker.type1==type && attacker.type2==type
      attacker.type1=getConst(PBTypes,:QMARKS)
      attacker.type2=getConst(PBTypes,:QMARKS)
    elsif attacker.type1==type  
      attacker.type1=attacker.type2
    elsif attacker.type2==type
      attacker.type2=attacker.type1
    end
    attacker.effects[PBEffects::Mimicry] = false
    @battle.pbDisplay(_INTL("{1} burned itself out!",attacker.pbThis))
    return ret
  end
  def pbModifyDamage(damagemult,attacker,opponent)
    type=getConst(PBTypes,:ELECTRIC) || -1
    if type>=0 && attacker.pbHasType?(:ELECTRIC) && attacker.pbHasType?(:BOLT)
      mult=PBTypes.getCombinedEffectiveness(type,
         opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
      return ((damagemult*mult)/8).round
    end
    return damagemult
  end
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:BOLT) if attacker.pbHasType?(:BOLT)
    type=getConst(PBTypes,:ELECTRIC)
    return type
  end
end

################################################################################
# (handled elsewhere) This move cannot be used twice in a row 
# (Gigaton Hammer)
################################################################################
class PokeBattle_Move_371 < PokeBattle_Move
end

################################################################################
# Power is increased by 1.5x in Harsh Sunlight (Hydro Steam)
################################################################################
class PokeBattle_Move_373 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if !attacker.hasWorkingItem(:UTILITYUMBRELLA)
      case @battle.pbWeather
      when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
        return (damagemult*3).round # 50% actually but power is reduced as well
      end
      return damagemult
    else
      return damagemult
    end
  end
end

################################################################################
# Power is increased by 1.5x in Electric Terrain (Psyblade)
################################################################################
class PokeBattle_Move_374 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if  @battle.pbTerrain==PBBattleTerrains::ELECTRIC
      return (damagemult*1.5).round
    end
    return damagemult
  end
end

################################################################################
# For the next three turns, opponent's Speed is reduced by 1 stage (Syrup Bomb)
################################################################################
class PokeBattle_Move_375 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=0
    ret=super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) if !pbIsDamaging?
    opponent.effects[PBEffects::SyrupBomb]=3
    @battle.pbDisplay(_INTL("{1} got covered in a sticky candy syrup!",opponent.pbThis))
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    opponent.effects[PBEffects::SyrupBomb]=3
    @battle.pbDisplay(_INTL("{1} got covered in a sticky candy syrup!",opponent.pbThis))
  end
end

################################################################################
# Type changes depending on Ogerpon's form. (Ivy Crudgel)
################################################################################
class PokeBattle_Move_376 < PokeBattle_Move
  def pbModifyType(type,attacker,opponent)
    type=getConst(PBTypes,:GRASS) || 0
    if isConst?(attacker.species,PBSpecies,:OGERPON)
      case attacker.form
      when 0
        type=(getConst(PBTypes,:GRASS) || type)
      when 1
        type=(getConst(PBTypes,:WATER) || type)
      when 2
        type=(getConst(PBTypes,:FIRE) || type)
      when 3
        type=(getConst(PBTypes,:ROCK) || type)
      end
    end
    return type
  end
end

################################################################################
# User gains half the HP it inflicts as damage. 
# May burn the target (Matcha Gotcha)
################################################################################
class PokeBattle_Move_377 < PokeBattle_Move_0DD
  def isHealingMove?
    return true
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanBurn?(attacker,false,self)
      opponent.pbBurn(attacker)
    end
  end
end

################################################################################
# Two turn attack. Skips first turn, attacks second turn. (Electro Shot)
# Power halved in all weather except rain. In rain, takes 1 turn instead.
################################################################################
class PokeBattle_Move_378 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false; @rain=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      if (@battle.pbWeather==PBWeather::RAINDANCE ||
         @battle.pbWeather==PBWeather::HEAVYRAIN) && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        @immediate=true; @rain=true
      end
    end
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.pbWeather!=0 &&
       @battle.pbWeather!=PBWeather::RAINDANCE &&
       @battle.pbWeather!=PBWeather::HEAVYRAIN
      return (damagemult*0.5).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} took in rain!",attacker.pbThis))
    end
    if @immediate && !@rain
      @battle.pbCommonAnimation("UseItem",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# (handled elsewhere) Damages all Pokemon when used by a Stellar Terapagos
# (Tera Starstorm)
################################################################################
class PokeBattle_Move_379 < PokeBattle_Move
end

################################################################################
# Power is doubled in some cases (Fickle Beam)
################################################################################
class PokeBattle_Move_380 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if rand(10)<3
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# User is protected against damaging moves this round. Burns the 
# user of a stopped contact move. (Burning Bulwark)
################################################################################
class PokeBattle_Move_381 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::BurningBulwark]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C,  # Spiky Shield
       0x221,  # Baneful Bunker
       0x262,  # Obstruct
       0x354,  # Silk Trap
       0x381   # Burning Bulwark
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      attacker.effects[PBEffects::ProtectRate]=1
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::BurningBulwark]=true
    attacker.effects[PBEffects::ProtectRate]*=2 # changed
    # attacker.effects[PBEffects::ProtectRate]=[attacker.effects[PBEffects::ProtectRate],729].min # changed added
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Increases the ally's critical hit rate. (Dragon Cheer)
################################################################################
class PokeBattle_Move_382 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if opponent.effects[PBEffects::DragonCheer]
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::DragonCheer]=true
    @battle.pbDisplay(_INTL("{1} is getting pumped!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.effects[PBEffects::DragonCheer]
      opponent.effects[PBEffects::DragonCheer]=true
      @battle.pbDisplay(_INTL("{1} is getting pumped!",opponent.pbThis))
    end
  end
end

################################################################################
# Confuses the target if it has increased its stats in that turn before the
# execution of this move (Alluring Voice)
################################################################################
class PokeBattle_Move_383 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanConfuse?(attacker,false,self) && 
       opponent.effects[PBEffects::BurningJelousy]
      opponent.confuse(attacker)
    end
  end
end

################################################################################
# For 2 rounds, disables the target's healing moves. (Psychic Noise)
################################################################################
class PokeBattle_Move_384 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    if opponent.effects[PBEffects::HealBlock]>0 || opponent.pbHasType?(:HERB) ||
      opponent.pbHasType?(:MIND) || opponent.pbHasType?(:GLIMSE)
			pbPlayMissSE()
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker(opponent)
      if opponent.hasWorkingAbility(:AROMAVEIL)
			pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        pbPlayMissSE()
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::HealBlock]=2
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return 0

  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.effects[PBEffects::HealBlock]==0 &&
       !(opponent.pbHasType?(:HERB) || opponent.pbHasType?(:MIND) || 
         opponent.pbHasType?(:GLIMSE))
      healblock=true
      if !attacker.hasMoldBreaker(opponent)
        healblock=false if opponent.hasWorkingAbility(:AROMAVEIL) ||
                           opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
      end
      if healblock
        opponent.effects[PBEffects::HealBlock]=5
        @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
      end
    end
  end
end

################################################################################
# Causes the target to flinch. Fails if target is not doing a priority move.
# (Upper Hand)
################################################################################
class PokeBattle_Move_385 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (@battle.choices[opponent.index][2].priority<1)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end

#===============================================================================
# NOTE: If you're inventing new move effects for your own game, use number 162
# or above
#===============================================================================