class PokeBattle_Battler
#===============================================================================
# Minior
#===============================================================================
  def pbShieldsUp?
    return isConst?(species,PBSpecies,:MINIOR) &&
      isConst?(ability,PBAbilities,:SHIELDSDOWN) &&
      !@effects[PBEffects::Transform] && self.form<7 && !self.isFainted?
  end
#===============================================================================
# Sleep
#===============================================================================
  def pbCanSleep?(attacker,showMessages,move=nil,ignorestatus=false)
    return false if isFainted?
    selfsleep=(attacker && attacker.index==self.index)
    if (!ignorestatus && status==PBStatuses::SLEEP) || isConst?(ability,PBAbilities,:COMATOSE)
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep
      if self.status!=0 ||
         (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
         pbSEPlay("protection") if showMessages
         @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
    end
    if !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      if @battle.field.effects[PBEffects::ElectricTerrain]>0
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("The Electric Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
        return false
      elsif @battle.field.effects[PBEffects::MistyTerrain]>0
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
        return false
      end
    end
    if (attacker && attacker.hasMoldBreaker) || !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
          return false
        end
      end 
    end
    if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
      if hasWorkingAbility(:VITALSPIRIT) ||
         hasWorkingAbility(:INSOMNIA) ||
         hasWorkingAbility(:SWEETVEIL) ||
         hasWorkingAbility(:PURIFYINGSALT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN) &&
                                            !hasWorkingItem(:UTILITYUMBRELLA))
        abilityname=PBAbilities.getName(self.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:SWEETVEIL) ||
         (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
        abilityname=PBAbilities.getName(pbPartner.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if !selfsleep
      if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
         (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
        pbSEPlay("protection") if showMessages
         @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
        return false
      end
    end
    return true
  end

  def pbCanSleepYawn?
    return false if status!=0 || isConst?(ability,PBAbilities,:COMATOSE)
    if !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end
    end
    if !self.isAirborne?
      return false if @battle.field.effects[PBEffects::ElectricTerrain]>0
      return false if @battle.field.effects[PBEffects::MistyTerrain]>0
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       hasWorkingAbility(:SWEETVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN) &&
                                          !hasWorkingItem(:UTILITYUMBRELLA))
      return false
    end
    return false if pbPartner.hasWorkingAbility(:SWEETVEIL)
    return true
  end

  def pbSleep(msg=nil)
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    self.statusCount=(self.statusCount/2).floor if self.hasWorkingAbility(:EARLYBIRD)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} fell asleep!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} fell asleep (#{self.statusCount} turns)")
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration
    else
      self.statusCount=2+@battle.pbRandom(3)
    end
    self.statusCount=(self.statusCount/2).floor if self.hasWorkingAbility(:EARLYBIRD)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[Status change] #{pbThis} made itself fall asleep (#{self.statusCount} turns)")
  end

#===============================================================================
# Poison
#===============================================================================
  def pbCanPoison?(attacker,showMessages,move=nil)
    return false if isFainted?
    if status==PBStatuses::POISON
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) ||
       isConst?(ability,PBAbilities,:COMATOSE) ||
       pbShieldsUp?
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL) || pbHasType?(:GAS)) && !(hasWorkingItem(:RINGTARGET) || (attacker && attacker.hasWorkingAbility(:CORROSION)))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being poisoned!",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:IMMUNITY) || hasWorkingAbility(:PASTELVEIL) ||
         hasWorkingAbility(:PURIFYINGSALT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN) &&
                                            !hasWorkingItem(:UTILITYUMBRELLA))
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
          pbPartner.hasWorkingAbility(:PASTELVEIL)
        abilityname=PBAbilities.getName(pbPartner.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents poisoning!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSynchronize?(opponent)
    return false if isFainted?
    if (pbHasType?(:POISON) || pbHasType?(:STEEL) || pbHasType?(:GAS)) && !(hasWorkingItem(:RINGTARGET))
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
         opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end   
    return false if self.status!=0 || isConst?(ability,PBAbilities,:COMATOSE) || pbShieldsUp?
    if hasWorkingAbility(:IMMUNITY) || hasWorkingAbility(:PASTELVEIL) ||
       hasWorkingAbility(:PURIFYINGSALT) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN) &&
                                          !hasWorkingItem(:UTILITYUMBRELLA))
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
        pbPartner.hasWorkingAbility(:PASTELVEIL)
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?(moldbreaker=false)
    return false if isFainted?
    return false if self.status!=0 || isConst?(ability,PBAbilities,:COMATOSE)
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL) || pbHasType?(:GAS)
    if !moldbreaker
      return false if hasWorkingAbility(:IMMUNITY) || hasWorkingAbility(:PASTELVEIL) || pbPartner.hasWorkingAbility(:PASTELVEIL) ||
                      hasWorkingAbility(:PURIFYINGSALT) ||
                      (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
                      (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
      return false if hasWorkingAbility(:LEAFGUARD) &&
                      (@battle.pbWeather==PBWeather::SUNNYDAY ||
                      @battle.pbWeather==PBWeather::HARSHSUN) &&
                      !hasWorkingItem(:UTILITYUMBRELLA)
    end
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbPoison(attacker,msg=nil,toxic=false)
    self.status=PBStatuses::POISON
    self.statusCount=(toxic) ? 1 : 0
    self.effects[PBEffects::Toxic]=0
    if toxic
    @battle.pbCommonAnimation("BadPoison",self,nil)
    else
    @battle.pbCommonAnimation("Poison",self,nil)
    end
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      if toxic
        @battle.pbDisplay(_INTL("{1} was badly poisoned!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1} was poisoned!",pbThis))
      end
    end
    if toxic
      PBDebug.log("[Status change] #{pbThis} was badly poisoned]")
    else
      PBDebug.log("[Status change] #{pbThis} was poisoned")
    end
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanPoisonSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbPoison(nil,_INTL("{1}'s {2} poisoned {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)),toxic)
      end
    end
  end

#===============================================================================
# Burn
#===============================================================================
  def pbCanBurn?(attacker,showMessages,move=nil)
    return false if isFainted?
    if self.status==PBStatuses::BURN
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) ||
       isConst?(ability,PBAbilities,:COMATOSE) ||
       pbShieldsUp?
        pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
        pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being burned!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !(hasWorkingItem(:RINGTARGET) || (attacker && attacker.hasWorkingAbility(:BURNOLA)))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:WATERVEIL) || hasWorkingAbility(:WATERBUBBLE) ||
          hasWorkingAbility(:THERMALEXCHANGE) ||
          hasWorkingAbility(:PURIFYINGSALT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN) &&
                                            !hasWorkingItem(:UTILITYUMBRELLA))
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents burns!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
        pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnSynchronize?(opponent)
    return false if isFainted?
    return false if self.status!=0 || isConst?(ability,PBAbilities,:COMATOSE) || pbShieldsUp?
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       pbSEPlay("protection")
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:WATERVEIL) || hasWorkingAbility(:WATERBUBBLE) ||
       hasWorkingAbility(:THERMALEXCHANGE) ||
       hasWorkingAbility(:PURIFYINGSALT) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN) &&
                                          !hasWorkingItem(:UTILITYUMBRELLA))
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBurn(attacker,msg=nil)
    self.status=PBStatuses::BURN
    self.statusCount=0
    @battle.pbCommonAnimation("Burn",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} was burned!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} was burned")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanBurnSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbBurn(nil,_INTL("{1}'s {2} burned {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(attacker,showMessages,move=nil)
    return false if isFainted?
    if status==PBStatuses::PARALYSIS
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) ||
       isConst?(ability,PBAbilities,:COMATOSE) ||
       pbShieldsUp?
      pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being paralyzed!",pbThis(true))) if showMessages
      return false
    end
    if (pbHasType?(:ELECTRIC) || pbHasType?(:BOLT)) && !(hasWorkingItem(:RINGTARGET) || (attacker && attacker.hasWorkingAbility(:PARAJINDA))) && $USENEWBATTLEMECHANICS
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:LIMBER) ||
         hasWorkingAbility(:PURIFYINGSALT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN) &&
                                            !hasWorkingItem(:UTILITYUMBRELLA))
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents paralysis!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent)
    return false if self.status!=0 || isConst?(ability,PBAbilities,:COMATOSE) || pbShieldsUp?
    return false if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isAirborne?
    return false if (pbHasType?(:ELECTRIC) || pbHasType?(:BOLT)) && !(hasWorkingItem(:RINGTARGET)) && $USENEWBATTLEMECHANICS
    if hasWorkingAbility(:LIMBER) ||
       hasWorkingAbility(:PURIFYINGSALT) ||
      (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN) &&
                                          !hasWorkingItem(:UTILITYUMBRELLA))
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbParalyze(attacker,msg=nil)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    @battle.pbCommonAnimation("Paralysis",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} was paralyzed")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanParalyzeSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbParalyze(nil,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           self.pbThis,PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(attacker,showMessages,move=nil)
    return false if isFainted?
    if status==PBStatuses::FROZEN
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already frozen solid!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) ||
       isConst?(ability,PBAbilities,:COMATOSE) ||
       pbShieldsUp? ||
       @battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN
        pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:ICE) || pbHasType?(:BLIZZARD)) && !(hasWorkingItem(:RINGTARGET) ||(attacker && attacker.hasWorkingAbility(:SHEERCOLD)))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
        pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being frozen!",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:MAGMAARMOR) ||
         hasWorkingAbility(:PURIFYINGSALT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN) &&
                                            !hasWorkingItem(:UTILITYUMBRELLA))
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents freezing!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents freezing!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
			pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbFreeze(msg=nil)
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} was frozen solid!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} was frozen")
  end

#===============================================================================
# Generalised status displays
#===============================================================================
  def pbContinueStatus(showAnim=true)
    case self.status
    when PBStatuses::SLEEP
      @battle.pbCommonAnimation("Sleep",self,nil)
      @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
    when PBStatuses::POISON
#      @battle.pbCommonAnimation("Poison",self,nil)
      @battle.pbDisplay(_INTL("{1} was hurt by poison!",pbThis))
    when PBStatuses::BURN
      self.temperature2= [[5,10][rand(2)],5,2,2,-2,-5][rand(6)] if rand(100) < 75
      @battle.pbCommonAnimation("Burn",self,nil)
      @battle.pbDisplay(_INTL("{1} was hurt by its burn!",pbThis))
    when PBStatuses::PARALYSIS
      @battle.pbCommonAnimation("Paralysis",self,nil)
      @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!",pbThis)) 
    when PBStatuses::FROZEN
      self.temperature2= [[-5,-10][rand(2)],-5,-2,-2,2,5][rand(6)] if rand(100) < 75
      @battle.pbCommonAnimation("Frozen",self,nil)
      @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis))
    end
  end

  def pbCureStatus(showMessages=true)
    oldstatus=self.status
    self.status=0
    self.statusCount=0
    if showMessages
      case oldstatus
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
      when PBStatuses::POISON
      when PBStatuses::BURN
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.",pbThis))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s status was cured")
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(attacker=nil,showMessages=true,move=nil)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:OWNTEMPO)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
			pbSEPlay("protection") if showMessages
       @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO)
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbConfuse
    @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
    @battle.pbCommonAnimation("Confusion",self,nil)
    PBDebug.log("[Lingering effect triggered] #{pbThis} became confused (#{@effects[PBEffects::Confusion]} turns)")
  end

  def pbConfuseSelf
    if pbCanConfuseSelf?(false)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
      PBDebug.log("[Lingering effect triggered] #{pbThis} became confused (#{@effects[PBEffects::Confusion]} turns)")
    end
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
  end

  def pbCureConfusion(showMessages=true)
    @effects[PBEffects::Confusion]=0
    @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis)) if showMessages
    PBDebug.log("[End of effect] #{pbThis} was cured of confusion")
  end

#===============================================================================
# Attraction
#===============================================================================
  def pbCanAttract?(attacker,showMessages=true)
    return false if isFainted?
    return false if !attacker || attacker.isFainted?
    if @effects[PBEffects::Attract]>=0
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    agender=attacker.gender
    ogender=self.gender
    if agender==2 || ogender==2 || agender==ogender
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (!attacker || !attacker.hasMoldBreaker) && hasWorkingAbility(:OBLIVIOUS)
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,
         PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbHasType?(:SHARPENER) && !(hasWorkingItem(:RINGTARGET) || (attacker && attacker.hasWorkingAbility(:ANTISHARPNESS)))
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    return true
  end

  def pbAttract(attacker,msg=nil)
    @effects[PBEffects::Attract]=attacker.index
    @battle.pbCommonAnimation("Attract",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} fell in love!",pbThis))
    end
    PBDebug.log("[Lingering effect triggered] #{pbThis} became infatuated (with #{attacker.pbThis(true)})")
    if self.hasWorkingItem(:DESTINYKNOT) &&
       attacker.pbCanAttract?(self,false)
      PBDebug.log("[Item triggered] #{pbThis}'s Destiny Knot")
      attacker.pbAttract(self,_INTL("{1}'s {2} made {3} fall in love!",pbThis,
         PBItems.getName(self.item),attacker.pbThis(true)))
    end
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",
       pbThis,seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis)) 
  end

  def pbCureAttract
    @effects[PBEffects::Attract]=-1
    PBDebug.log("[End of effect] #{pbThis} was cured of infatuation")
  end

#===============================================================================
# Flinching
#===============================================================================
  def pbFlinch(attacker)
    return false if (!attacker || !attacker.hasMoldBreaker) && hasWorkingAbility(:INNERFOCUS)
    @effects[PBEffects::Flinch]=true
    return true
  end

#===============================================================================
# Increase stat stages
#===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,attacker=nil,showMessages=false,move=nil,moldbreaker=false,ignoreContrary=false,ignoremirror=false,ignoreopportunist=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbCanReduceStatStage?(stat,attacker,showMessages,move,moldbreaker,true,ignoremirror)
        end
      end
    end
    return false if isFainted?
    if pbTooHigh?(stat)
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
         pbThis,PBStats.getName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment,attacker=nil,moldbreaker=false,ignoreContrary=false,ignoremirror=false,ignoreopportunist=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStatBasic(stat,increment,attacker,moldbreaker,true)
        end
        increment*=2 if hasWorkingAbility(:SIMPLE) || @battle.field.effects[PBEffects::LovelyTerrain]>0 
      end
    end
    increment=[increment,6-@stages[stat]].min
    PBDebug.log("[Stat change] #{pbThis}'s #{PBStats.getName(stat)} rose by #{increment} stage(s) (was #{@stages[stat]}, now #{@stages[stat]+increment})")
    @stages[stat]+=increment
    return increment
  end

  def pbIncreaseStat(stat,increment,attacker,showMessages,move=nil,upanim=true,moldbreaker=false,ignoreContrary=false,ignoremirror=false,ignoreopportunist=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStat(stat,increment,attacker,showMessages,move,upanim,moldbreaker,true,ignoremirror)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanIncreaseStatStage?(stat,attacker,showMessages,move,moldbreaker,ignoreContrary,ignoremirror)
      increment=pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary,ignoremirror)
      if increment>0
        if ignoremirror
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",attacker.pbThis,PBAbilities.getName(attacker.ability))) if upanim
        end
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if upanim
        end
        if upanim
          if upanim == 'mix'
            @battle.pbCommonAnimation("StatUp",self,nil)
          else
            @battle.pbCommonAnimation("StatUpAttack",self,nil)   if stat==PBStats::ATTACK
            @battle.pbCommonAnimation("StatUpDefense",self,nil)  if stat==PBStats::DEFENSE
            @battle.pbCommonAnimation("StatUpSpAtk",self,nil)    if stat==PBStats::SPATK
            @battle.pbCommonAnimation("StatUpSpDef",self,nil)    if stat==PBStats::SPDEF
            @battle.pbCommonAnimation("StatUpSpeed",self,nil)    if stat==PBStats::SPEED
            @battle.pbCommonAnimation("StatUpEvasion",self,nil)  if stat==PBStats::EVASION
            @battle.pbCommonAnimation("StatUpAccuracy",self,nil) if stat==PBStats::ACCURACY
          end
        end
        arrStatTexts=[_INTL("{1}'s {2} rose!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} rose sharply!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} rose drastically!",pbThis,PBStats.getName(stat))]
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
        # Opportunist
        if !ignoreopportunist
          for i in [self.pbPartner,self.pbOpposing1,self.pbOpposing2]
            next if !i || i.isFainted?
            next if !i.hasWorkingAbility(:OPPORTUNIST)
#            next if !i.pbCanIncreaseStatStage?(stat,i,false)
            i.pbIncreaseStatWithCause(stat,increment,i,PBAbilities.getName(i.ability),upanim,true,moldbreaker,ignoreContrary,ignoremirror,true)
          end
        end
        @effects[PBEffects::BurningJelousy] = true
        return true
      end
    end
    return false
  end

  def pbIncreaseStatWithCause(stat,increment,attacker,cause,showanim=true,showmessage=true,moldbreaker=false,ignoreContrary=false,ignoremirror=false,ignoreopportunist=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStatWithCause(stat,increment,attacker,cause,showanim,showmessage,moldbreaker,true,ignoremirror)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanIncreaseStatStage?(stat,attacker,false,nil,moldbreaker,ignoreContrary,ignoremirror)
      increment=pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary,ignoremirror)
      if increment>0
        if ignoremirror
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",attacker.pbThis,PBAbilities.getName(attacker.ability))) if showanim
        end
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if showanim
        end
        if showanim
          if showanim == 'mix'
            @battle.pbCommonAnimation("StatUp",self,nil)
          else
            @battle.pbCommonAnimation("StatUpAttack",self,nil)   if stat==PBStats::ATTACK
            @battle.pbCommonAnimation("StatUpDefense",self,nil)  if stat==PBStats::DEFENSE
            @battle.pbCommonAnimation("StatUpSpAtk",self,nil)    if stat==PBStats::SPATK
            @battle.pbCommonAnimation("StatUpSpDef",self,nil)    if stat==PBStats::SPDEF
            @battle.pbCommonAnimation("StatUpSpeed",self,nil)    if stat==PBStats::SPEED
            @battle.pbCommonAnimation("StatUpEvasion",self,nil)  if stat==PBStats::EVASION
            @battle.pbCommonAnimation("StatUpAccuracy",self,nil) if stat==PBStats::ACCURACY
          end
        end
        if attacker.index==self.index
          arrStatTexts=[_INTL("{1}'s {2} raised its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} sharply raised its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} drastically raised its {3}!",pbThis,cause,PBStats.getName(stat))]
           # _INTL("{1}'s {2} went way up!",pbThis,PBStats.getName(stat))]
        else
          arrStatTexts=[_INTL("{1}'s {2} raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} sharply raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} drastically raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat))]
        end
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min]) if showmessage
        # Opportunist
        if !ignoreopportunist
          for i in [self.pbPartner,self.pbOpposing1,self.pbOpposing2]
            next if !i || i.isFainted? || !i.hasWorkingAbility(:OPPORTUNIST)
            next if !i.hasWorkingAbility(:OPPORTUNIST)
#            next if !i.pbCanIncreaseStatStage?(stat,self,false)
            i.pbIncreaseStatWithCause(stat,increment,i,PBAbilities.getName(i.ability),showanim,true,moldbreaker,ignoreContrary,ignoremirror,true)
          end
        end
        @effects[PBEffects::BurningJelousy] = true
        return true
      end
    end
    return false
  end

#===============================================================================
# Decrease stat stages
#===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  # Tickle (04A) and Noble Roar (13A) can't use this, but replicate it instead.
  # (Reason is they lowers more than 1 stat independently, and therefore could
  # show certain messages twice which is undesirable.)
  def pbCanReduceStatStage?(stat,attacker=nil,showMessages=false,move=nil,moldbreaker=false,ignoreContrary=false,ignoremirror=false)
    selfreduce=(attacker && attacker.index==self.index) # Moved to the top for Mirror Armor
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbCanIncreaseStatStage?(stat,attacker,showMessages,move,moldbreaker,true,ignoremirror)
        end
        if hasWorkingAbility(:MIRRORARMOR) && !(ignoremirror || selfreduce)
          return attacker.pbCanReduceStatStage?(stat,self,showMessages,move,moldbreaker,ignoreContrary,true)
        end
      end
    end
    return false if isFainted?
    if !selfreduce
      if @effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))
       pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
        (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
       pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
        return false
      end
      # Cinament
      if @battle.field.effects[PBEffects::Cinament]>0 &&
        (!attacker || !attacker.hasWorkingItem(:RODOFSPARROW) ||
          attacker.hasWorkingAbility(:MORFAT))
        abilityname=PBAbilities.getName(self.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("The Cinament prevents stat loss!")) if showMessages
        return false
      end
      # Changed added
      if hasWorkingAbility(:FULLMETALBODY)
        abilityname=PBAbilities.getName(self.ability)
        pbSEPlay("protection") if showMessages
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if !moldbreaker && (!attacker || !attacker.hasMoldBreaker)
        if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:SUPERCLEARBODY) ||
           hasWorkingAbility(:WHITESMOKE)
          abilityname=PBAbilities.getName(self.ability)
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if pbHasType?(:GRASS)
          if hasWorkingAbility(:FLOWERVEIL)
            abilityname=PBAbilities.getName(self.ability)
            pbSEPlay("protection") if showMessages
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
            return false
          elsif pbPartner.hasWorkingAbility(:FLOWERVEIL)
            abilityname=PBAbilities.getName(pbPartner.ability)
            pbSEPlay("protection") if showMessages
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",pbPartner.pbThis,abilityname,pbThis(true))) if showMessages
            return false
          end
        end
        if stat==PBStats::ATTACK && hasWorkingAbility(:HYPERCUTTER)
          abilityname=PBAbilities.getName(self.ability)
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if stat==PBStats::DEFENSE && hasWorkingAbility(:BIGPECKS)
          abilityname=PBAbilities.getName(self.ability)
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if stat==PBStats::ACCURACY && (hasWorkingAbility(:KEENEYE) || 
                                       hasWorkingAbility(:ILLUMINATE))
          abilityname=PBAbilities.getName(self.ability)
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} prevents accuracy loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if stat==profstat && hasWorkingAbility(:SUPERLENS)
          abilityname=PBAbilities.getName(self.ability)
          pbSEPlay("protection") if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityname,PBStats.getName(user.profstat))) if showMessages
          return false
        end
      end
    end
    if pbTooLow?(stat)
			pbSEPlay("protection") if showMessages
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis,PBStats.getName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment,attacker=nil,moldbreaker=false,ignoreContrary=false,ignoremirror=false)
    if !moldbreaker # moldbreaker is true only when Roar forces out a Pokémon into Sticky Web
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,true)
        end
        if hasWorkingAbility(:MIRRORARMOR) && !ignoremirror
          return attacker.pbReduceStatBasic(stat,increment,self,moldbreaker,ignoreContrary,true)
        end
        increment*=2 if hasWorkingAbility(:SIMPLE) || @battle.field.effects[PBEffects::LovelyTerrain]>0 
      end
    end
    increment=[increment,6+@stages[stat]].min
    PBDebug.log("[Stat change] #{pbThis}'s #{PBStats.getName(stat)} fell by #{increment} stage(s) (was #{@stages[stat]}, now #{@stages[stat]-increment})")
    @stages[stat]-=increment
    return increment
  end

  def pbReduceStat(stat,increment,attacker,showMessages,move=nil,downanim=true,moldbreaker=false,ignoreContrary=false,ignoremirror=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStat(stat,increment,attacker,showMessages,move,downanim,moldbreaker,true,ignoremirror)
        end
        if hasWorkingAbility(:MIRRORARMOR) && !ignoremirror
          return attacker.pbReduceStat(stat,increment,self,showMessages,move,downanim,moldbreaker,ignoreContrary,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanReduceStatStage?(stat,attacker,showMessages,move,moldbreaker,ignoreContrary,ignoremirror)
      increment=pbReduceStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary,ignoremirror)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if downanim
        end
        if ignoremirror
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",attacker.pbThis,PBAbilities.getName(attacker.ability))) if downanim
        end
        if downanim
          if downanim == 'mix'
            @battle.pbCommonAnimation("StatDown",self,nil)
          else
            @battle.pbCommonAnimation("StatDownAttack",self,nil)   if stat==PBStats::ATTACK
            @battle.pbCommonAnimation("StatDownDefense",self,nil)  if stat==PBStats::DEFENSE
            @battle.pbCommonAnimation("StatDownSpAtk",self,nil)    if stat==PBStats::SPATK
            @battle.pbCommonAnimation("StatDownSpDef",self,nil)    if stat==PBStats::SPDEF
            @battle.pbCommonAnimation("StatDownSpeed",self,nil)    if stat==PBStats::SPEED
            @battle.pbCommonAnimation("StatDownEvasion",self,nil)  if stat==PBStats::EVASION
            @battle.pbCommonAnimation("StatDownAccuracy",self,nil) if stat==PBStats::ACCURACY
          end
        end        
        arrStatTexts=[_INTL("{1}'s {2} fell!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} harshly fell!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} severely fell!",pbThis,PBStats.getName(stat))]
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
        # Defiant
        if hasWorkingAbility(:DEFIANT) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBAbilities.getName(self.ability))
        end
        # Competitive
        if hasWorkingAbility(:COMPETITIVE) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::SPATK,2,self,PBAbilities.getName(self.ability))
        end
        # Eject Pack
        if hasWorkingItem(:EJECTPACK) && (!attacker || attacker.pbIsOpposing?(self.index))
          if @battle.pbCanSwitch?(self.index,-1,false) && !@battle.pbAllFainted?(@battle.pbParty(self.index))
            @battle.pbCommonAnimation("UseItem",self,nil)
            pbConsumeItem(false,true)
            newpoke=0
            newpoke=@battle.pbSwitchInBetween(self.index,true,false)
            newpokename=newpoke
            if isConst?(@battle.pbParty(self.index)[newpoke].ability,PBAbilities,:ILLUSION)
              newpokename=pbGetLastPokeInTeam(self.index)
            end
            pbResetForm
            @battle.pbRecallAndReplace(self.index,newpoke,newpokename)
            @battle.choices[self.index]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
            pbAbilitiesOnSwitchIn(true)
          end
        end
        @effects[PBEffects::LashOut] = true
        return true
      end
    end
    return false
  end

  def pbReduceStatWithCause(stat,increment,attacker,cause,showanim=true,showmessage=true,moldbreaker=false,ignoreContrary=false,ignoremirror=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStatWithCause(stat,increment,attacker,cause,showanim,showmessage,moldbreaker,true,ignoremirror)
        end
        if hasWorkingAbility(:MIRRORARMOR) && !ignoreContrary
          return attacker.pbReduceStatWithCause(stat,increment,self,cause,showanim,showmessage,moldbreaker,ignoreContrary,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanReduceStatStage?(stat,attacker,false,nil,moldbreaker,ignoreContrary,ignoremirror)
      increment=pbReduceStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary,ignoremirror)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if showanim
        end
        if ignoremirror
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",attacker.pbThis,PBAbilities.getName(attacker.ability))) if showanim
        end
        if showanim
          if showanim == 'mix'
            @battle.pbCommonAnimation("StatDown",self,nil)
          else
            @battle.pbCommonAnimation("StatDownAttack",self,nil)   if stat==PBStats::ATTACK
            @battle.pbCommonAnimation("StatDownDefense",self,nil)  if stat==PBStats::DEFENSE
            @battle.pbCommonAnimation("StatDownSpAtk",self,nil)    if stat==PBStats::SPATK
            @battle.pbCommonAnimation("StatDownSpDef",self,nil)    if stat==PBStats::SPDEF
            @battle.pbCommonAnimation("StatDownSpeed",self,nil)    if stat==PBStats::SPEED
            @battle.pbCommonAnimation("StatDownEvasion",self,nil)  if stat==PBStats::EVASION
            @battle.pbCommonAnimation("StatDownAccuracy",self,nil) if stat==PBStats::ACCURACY
          end
        end        
        if attacker.index==self.index
          arrStatTexts=[_INTL("{1}'s {2} lowered its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,PBStats.getName(stat))]
        else
          if ignoremirror
            arrStatTexts=[_INTL("{1} lowered {2}'s {3}!",attacker.pbThis,pbThis(true),PBStats.getName(stat)),
               _INTL("{1} harshly lowered {2}'s {3}!",attacker.pbThis,pbThis(true),PBStats.getName(stat)),
               _INTL("{1} severely lowered {2}'s {3}!",attacker.pbThis,pbThis(true),PBStats.getName(stat))]
          else
            arrStatTexts=[_INTL("{1}'s {2} lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
               _INTL("{1}'s {2} harshly lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
               _INTL("{1}'s {2} severely lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat))]
          end
        end
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min]) if showmessage
        # Defiant
        if hasWorkingAbility(:DEFIANT) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBAbilities.getName(self.ability))
        end
        # Competitive
        if hasWorkingAbility(:COMPETITIVE) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::SPATK,2,self,PBAbilities.getName(self.ability))
        end
        # Eject Pack
        if hasWorkingItem(:EJECTPACK) && (!attacker || attacker.pbIsOpposing?(self.index))
          if @battle.pbCanSwitch?(self.index,-1,false) && !@battle.pbAllFainted?(@battle.pbParty(self.index))
            @battle.pbCommonAnimation("UseItem",self,nil)
            pbConsumeItem(false,true)
            newpoke=0
            newpoke=@battle.pbSwitchInBetween(self.index,true,false)
            newpokename=newpoke
            if isConst?(@battle.pbParty(self.index)[newpoke].ability,PBAbilities,:ILLUSION)
              newpokename=pbGetLastPokeInTeam(self.index)
            end
            pbResetForm
            @battle.pbRecallAndReplace(self.index,newpoke,newpokename)
            @battle.choices[self.index]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
            pbAbilitiesOnSwitchIn(true)
          end
        end
        @effects[PBEffects::LashOut] = true
        return true
      end
    end
    return false
  end

  def pbReduceAttackStatIntimidate(opponent)
    return false if isFainted?
    if effects[PBEffects::Substitute]>0
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
         pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if hasWorkingAbility(:GUARDDOG)
      @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(ability)))
      return pbIncreaseStatWithCause(PBStats::ATTACK,1,opponent,PBAbilities.getName(opponent.ability))
    end
    if !hasWorkingAbility(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
      end
      # Cinament
      if @battle.field.effects[PBEffects::Cinament]>0 &&
        (!opponent || !opponent.hasWorkingItem(:RODOFSPARROW))
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("The Cinament prevented {1}'s {2} from working!",opponent.pbThis(true),oppabilityname))
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
        hasWorkingAbility(:HYPERCUTTER) || hasWorkingAbility(:FULLMETALBODY) || hasWorkingAbility(:SUPERCLEARBODY) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:INNERFOCUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:SCRAPPY) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OBLIVIOUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OWNTEMPO) && $USENEWBATTLEMECHANICS) ||
          hasWorkingAbility(:PROTEINCROTELINE) ||
         (hasWorkingAbility(:SUPERLENS) && profstat==PBStats::ATTACK)
         abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
    end
    return pbReduceStatWithCause(PBStats::ATTACK,1,opponent,PBAbilities.getName(opponent.ability))
  end


  def pbReduceSpAttackStatIntimidoom(opponent)
    return false if isFainted?
    if effects[PBEffects::Substitute]>0
			pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
         pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if hasWorkingAbility(:GUARDDOG)
      @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(ability)))
      return pbIncreaseStatWithCause(PBStats::SPATK,1,opponent,PBAbilities.getName(opponent.ability))
    end
    if !hasWorkingAbility(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
      end
      # Cinament
      if @battle.field.effects[PBEffects::Cinament]>0 &&
        (!opponent || !opponent.hasWorkingItem(:RODOFSPARROW))
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("The Cinament prevented {1}'s {2} from working!",opponent.pbThis(true),oppabilityname))
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
         hasWorkingAbility(:FULLMETALBODY) || hasWorkingAbility(:SUPERCLEARBODY) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:SCRAPPY) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OBLIVIOUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:INNERFOCUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OWNTEMPO) && $USENEWBATTLEMECHANICS) ||
          hasWorkingAbility(:PROTEINCROTELINE) ||
         (hasWorkingAbility(:SUPERLENS) && profstat==PBStats::SPATK)
         abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
    end
    return pbReduceStatWithCause(PBStats::SPATK,1,opponent,PBAbilities.getName(opponent.ability))
  end

  def pbReduceSpeedStatIntimilow(opponent)
    return false if isFainted?
    if effects[PBEffects::Substitute]>0
      pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
         pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if hasWorkingAbility(:GUARDDOG)
      @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(ability)))
      return pbIncreaseStatWithCause(PBStats::SPEED,1,opponent,PBAbilities.getName(opponent.ability))
    end
    if !hasWorkingAbility(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
      end
      # Cinament
      if @battle.field.effects[PBEffects::Cinament]>0 &&
        (!opponent || !opponent.hasWorkingItem(:RODOFSPARROW))
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("The Cinament prevented {1}'s {2} from working!",opponent.pbThis(true),oppabilityname))
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
         hasWorkingAbility(:FULLMETALBODY) || hasWorkingAbility(:SUPERCLEARBODY) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:INNERFOCUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:SCRAPPY) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OBLIVIOUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OWNTEMPO) && $USENEWBATTLEMECHANICS) ||
          hasWorkingAbility(:PROTEINCROTELINE) ||
         (hasWorkingAbility(:SUPERLENS) && profstat==PBStats::SPEED)
         abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
    end
    return pbReduceStatWithCause(PBStats::SPEED,1,opponent,PBAbilities.getName(opponent.ability))
  end

  
  def pbReduceProficientStatLensIntimidate(opponent)
    return false if isFainted?
    proficient=profstat
    if effects[PBEffects::Substitute]>0
      pbSEPlay("protection")
      @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
         pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if hasWorkingAbility(:GUARDDOG)
      @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(ability)))
      return pbIncreaseStatWithCause(proficient,1,opponent,PBAbilities.getName(opponent.ability))
    end
    if !hasWorkingAbility(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
      end
      # Cinament
      if @battle.field.effects[PBEffects::Cinament]>0 &&
        (!opponent || !opponent.hasWorkingItem(:RODOFSPARROW))
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("The Cinament prevented {1}'s {2} from working!",opponent.pbThis(true),oppabilityname))
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
         hasWorkingAbility(:FULLMETALBODY) || hasWorkingAbility(:SUPERCLEARBODY) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:INNERFOCUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:SCRAPPY) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OBLIVIOUS) && $USENEWBATTLEMECHANICS) ||
         (hasWorkingAbility(:OWNTEMPO) && $USENEWBATTLEMECHANICS) ||
          hasWorkingAbility(:PROTEINCROTELINE) ||
          hasWorkingAbility(:SUPERLENS) ||
         (hasWorkingAbility(:HYPERCUTTER) && proficient==PBStats::ATTACK) ||
         (hasWorkingAbility(:BIGPECKS) && proficient==PBStats::DEFENSE)
         abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        pbSEPlay("protection")
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
    end
    return pbReduceStatWithCause(proficient,1,opponent,PBAbilities.getName(opponent.ability))
  end

  
end