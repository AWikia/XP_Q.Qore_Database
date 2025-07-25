#===============================================================================
# UseFromBag handlers
# Return values: 0 = not used
#                1 = used, item not consumed
#                2 = close the Bag to use, item not consumed
#                3 = used, item consumed
#                4 = close the Bag to use, item consumed
#===============================================================================

def pbRepel(item,steps)
  if $PokemonGlobal.repel>0
    Kernel.pbMessage(_INTL("But the effects of a Repel lingered from earlier."))
    return 0
  else
    Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
    $PokemonGlobal.repel=steps
    return 3
  end
end

ItemHandlers::UseFromBag.add(:REPEL,proc{|item| pbRepel(item,100) })

ItemHandlers::UseFromBag.add(:SUPERREPEL,proc{|item| pbRepel(item,200) })

ItemHandlers::UseFromBag.add(:MAXREPEL,proc{|item| pbRepel(item,250) })

Events.onStepTaken+=proc {
   if !PBTerrain.isIce?($game_player.terrain_tag)   # Shouldn't count down if on ice
     if $PokemonGlobal.repel>0
       $PokemonGlobal.repel-=1
       if $PokemonGlobal.repel<=0
         Kernel.pbMessage(_INTL("Repel's effect wore off..."))
         ret=pbChooseItemFromList(_INTL("Do you want to use another Repel?"),1,
            :REPEL,:SUPERREPEL,:MAXREPEL)
         pbUseItem($PokemonBag,ret) if ret>0
       end
     end
   end
}

ItemHandlers::UseFromBag.add(:BLACKFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be repelled."))
   $PokemonMap.blackFluteUsed=true
   $PokemonMap.whiteFluteUsed=false
   next 1
})

ItemHandlers::UseFromBag.add(:WHITEFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be lured."))
   $PokemonMap.blackFluteUsed=false
   $PokemonMap.whiteFluteUsed=true
   next 1
})

ItemHandlers::UseFromBag.add(:HONEY,proc{|item| next 4 })

ItemHandlers::UseFromBag.add(:ESCAPEROPE,proc{|item|
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     next 0
   end
   if ($PokemonGlobal.inPast || $PokemonGlobal.inFuture) && $PokemonGlobal
     Kernel.pbMessage(_INTL("It can only be used while you're in the present."))
     next 0
   end
   if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
     next 4 # End screen and consume item
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})

ItemHandlers::UseFromBag.add(:SACREDASH,proc{|item|
   revived=0
   if $Trainer.pokemonCount==0
     Kernel.pbMessage(_INTL("There is no Pokémon."))
     next 0
   end
   pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Using item..."),false)
      for i in $Trainer.party
       if i.hp<=0 && !i.isEgg?
         revived+=1
         i.heal
         screen.pbDisplay(_INTL("{1}'s HP was restored.",i.name))
       end
     end
     if revived==0
       screen.pbDisplay(_INTL("It won't have any effect."))
     end
     screen.pbEndScene
   }
   next (revived==0) ? 0 : 3
})

ItemHandlers::UseFromBag.add(:VICIOUSCANDY,proc{|item|
   revived=0
   if $Trainer.pokemonCount==0
     Kernel.pbMessage(_INTL("There is no Pokémon."))
     next 0
   end
   pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Using item..."),false)
      for i in $Trainer.party
       if i.level>=PBExperience::MAXLEVEL || (i.isShadow? rescue false)
       else
         revived+=1
         pbChangeLevel(i,i.level+1,scene)
         scene.pbHardRefresh
       end
     end
     if revived==0
       screen.pbDisplay(_INTL("It won't have any effect."))
     end
     screen.pbEndScene
   }
   next (revived==0) ? 0 : 3
})

ItemHandlers::UseFromBag.copy(:VICIOUSCANDY,:GRAPEBOX)


ItemHandlers::UseFromBag.add(:PCSTORAGEBOX,proc{|item|
  if $game_switches[172]
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
  else
     pbPokeCenterPC
     next 1
  end
})

ItemHandlers::UseFromBag.add(:DAILYTREATMACHINE,proc{|item|
  if $game_variables[DTM_VARIABLE] == [pbGetTimeNow.mon, pbGetTimeNow.day]
     Kernel.pbMessage(_INTL("Can't use that now."))
     next 0
  else
     scene=DailyTreatMachineScene.new
     screen=DailyTreatMachine.new(scene)
     pbFadeOutIn(99999) { 
        screen.pbStartScreen
     }
     next 1
  end
})

ItemHandlers::UseFromBag.add(:BICYCLE,proc{|item|
   next pbBikeCheck ? 2 : 0
})

ItemHandlers::UseFromBag.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseFromBag.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if (PBTerrain.isWater?(terrain) && !$PokemonGlobal.surfing && notCliff) ||
      (PBTerrain.isWater?(terrain) && $PokemonGlobal.surfing)
     next 2
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})

ItemHandlers::UseFromBag.copy(:OLDROD,:GOODROD,:SUPERROD)

ItemHandlers::UseFromBag.add(:ITEMFINDER,proc{|item| next 2 })

ItemHandlers::UseFromBag.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)

ItemHandlers::UseFromBag.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins))
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALL,proc{|item|
   $PokemonBag.pbChangeItem(:EXPALL,:EXPALLOFF)
   Kernel.pbMessage(_INTL("The Exp Share was turned off."))
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF,proc{|item|
   $PokemonBag.pbChangeItem(:EXPALLOFF,:EXPALL)
   Kernel.pbMessage(_INTL("The Exp Share was turned on."))
   next 1 # Continue
})

#===============================================================================
# UseInField handlers
#===============================================================================

ItemHandlers::UseInField.add(:HONEY,proc{|item|  
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   pbSweetScent
})

ItemHandlers::UseInField.add(:ESCAPEROPE,proc{|item|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[]
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     next
   end
   if ($PokemonGlobal.inPast || $PokemonGlobal.inFuture) && $PokemonGlobal
     Kernel.pbMessage(_INTL("It can only be used while you're in the present."))
     next
   end
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=escape[0]
      $game_temp.player_new_x=escape[1]
      $game_temp.player_new_y=escape[2]
      $game_temp.player_new_direction=escape[3]
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
   }
   pbEraseEscapePoint
})


ItemHandlers::UseInField.add(:PCSTORAGEBOX,proc{|item|
  if $game_switches[172]
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
  else
     pbPokeCenterPC
     next 1
  end
})


ItemHandlers::UseInField.add(:BICYCLE,proc{|item|
   if pbBikeCheck
     if $PokemonGlobal.bicycle
       Kernel.pbDismountBike
     else
       Kernel.pbMountBike 
     end
   end
})

ItemHandlers::UseInField.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseInField.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !PBTerrain.isWater?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::OldRod)
   if pbFishing(encounter,1)
     pbEncounter(EncounterTypes::OldRod)
   end
})

ItemHandlers::UseInField.add(:GOODROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !PBTerrain.isWater?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::GoodRod)
   if pbFishing(encounter,2)
     pbEncounter(EncounterTypes::GoodRod)
   end
})

ItemHandlers::UseInField.add(:SUPERROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !PBTerrain.isWater?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::SuperRod)
   if pbFishing(encounter,3)
     pbEncounter(EncounterTypes::SuperRod)
   end
})

ItemHandlers::UseInField.add(:ITEMFINDER,proc{|item|
   event=pbClosestHiddenItem
   if !event
     Kernel.pbMessage(_INTL("... ... ... ...Nope!\r\nThere's no response."))
   else
     offsetX=event.x-$game_player.x
     offsetY=event.y-$game_player.y
     if offsetX==0 && offsetY==0
       for i in 0...32
         Graphics.update
         Input.update
         $game_player.turn_right_90 if (i&7)==0
         pbUpdateSceneMap
       end
       Kernel.pbMessage(_INTL("The {1}'s indicating something right underfoot!\1",PBItems.getName(item)))
     else
       direction=$game_player.direction
       if offsetX.abs>offsetY.abs
         direction=(offsetX<0) ? 4 : 6         
       else
         direction=(offsetY<0) ? 8 : 2
       end
       for i in 0...8
         Graphics.update
         Input.update
         if i==0
           $game_player.turn_down if direction==2
           $game_player.turn_left if direction==4
           $game_player.turn_right if direction==6
           $game_player.turn_up if direction==8
         end
         pbUpdateSceneMap
       end
       Kernel.pbMessage(_INTL("Huh?\nThe {1}'s responding!\1",PBItems.getName(item)))
       Kernel.pbMessage(_INTL("There's an item buried around here!"))
     end
   end
})

ItemHandlers::UseInField.copy(:ITEMFINDER,:DOWSINGMCHN,:DOWSINGMACHINE)

ItemHandlers::UseInField.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
})

ItemHandlers::UseInField.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins.to_s_formatted))
   next 1 # Continue
})

#===============================================================================
# UseOnPokemon handlers
#===============================================================================

ItemHandlers::UseOnPokemon.addIf(proc{|item| pbIsEvolutionStone?(item)},
   proc{|item,pokemon,scene|
   if (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   newspecies=pbCheckEvolution(pokemon,item)
   if newspecies<=0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbFadeOutInWithMusic(99999){
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonBag_Scene)
          scene.pbRefreshAnnotations(proc{|p| pbCheckEvolution(p,item)>0 })
          scene.pbRefresh
        end
     }
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PRISMSTONE,proc{|item,pokemon,scene|
   if (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   newspecies=pbCheckEvolution(pokemon,item)
   if newspecies<=0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbFadeOutInWithMusic(99999){
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution(false,true)
        evo.pbEndScreen
        if scene.is_a?(PokemonBag_Scene)
          scene.pbRefreshAnnotations(proc{|p| pbCheckEvolution(p,item)>0 })
          scene.pbRefresh
        end
     }
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:LINKINGCORD,proc{|item,pokemon,scene|
   if (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   newspecies=pbTradeCheckEvolution(pokemon,pokemon)
   if newspecies<=0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbFadeOutInWithMusic(99999){
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonBag_Scene)
          scene.pbRefreshAnnotations(proc{|p| pbCheckEvolution(p,item)>0 })
          scene.pbRefresh
        end
     }
     next true
   end
})


          
ItemHandlers::UseOnPokemon.add(:POTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.copy(:POTION,:SOURCANDY)


ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,50,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,120,scene)
})

ItemHandlers::UseOnPokemon.add(:MEGAPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,200,scene)
})

ItemHandlers::UseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,scene|
   hp = pokemon.isRB? ? pokemon.maxsteps - pokemon.eggsteps : pokemon.totalhp-pokemon.hp
   next pbHPItem(pokemon,hp,scene)
})

ItemHandlers::UseOnPokemon.copy(:MAXPOTION,:MELONBOX)

ItemHandlers::UseOnPokemon.add(:ORANGEBOX,proc{|item,pokemon,scene|
   hp = pokemon.isRB? ? pokemon.maxsteps : pokemon.totalhp
   next pbHPItem(pokemon,(hp/2).floor,scene)
})

ItemHandlers::UseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:CHERRYBOX,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,40,scene)
})

ItemHandlers::UseOnPokemon.copy(:CHERRYBOX,:SPICYCANDY)

ItemHandlers::UseOnPokemon.add(:CHOCOLATEBOX,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,120,scene)
})

ItemHandlers::UseOnPokemon.add(:BELLBOX,proc{|item,pokemon,scene|
  if pokemon.isRB? && pokemon.eggsteps!=pokemon.maxsteps
    hpgain=pbItemRestoreSteps(pokemon,pokemon.maxsteps/4)
    scene.pbRefresh
    scene.pbDisplay(_INTL("Remote Box's battery was restored by {2} steps.",pokemon.name,hpgain))
    return true
  else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
  end
})


ItemHandlers::UseOnPokemon.add(:KEYBOX,proc{|item,pokemon,scene|
  if (pokemon.isEgg? && !pokemon.isRB?) && pokemon.eggsteps>1
    reduce = (pokemon.maxsteps/2).ceil * -1
    hpgain=pbItemRestoreSteps(pokemon,reduce)
    scene.pbRefresh
    scene.pbDisplay(_INTL("Egg's hatch steps have been reduced by {2}.",pokemon.name,hpgain*-1))
    return true
  else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
  end
})


=begin
ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})
=end

ItemHandlers::UseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,50,scene)
})

ItemHandlers::UseOnPokemon.add(:SODAPOP,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,60,scene)
})

ItemHandlers::UseOnPokemon.add(:LEMONADE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,80,scene)
})

ItemHandlers::UseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,100,scene)
})

ItemHandlers::UseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,10,scene)
})

ItemHandlers::UseOnPokemon.copy(:ORANBERRY,:SWEETCANDY)

ItemHandlers::UseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,(pokemon.totalhp/4).floor,scene)
})

ItemHandlers::UseOnPokemon.add(:AWAKENING,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::UseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::UseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::UseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:PARLYZHEAL,:PARALYZEHEAL,:CHERIBERRY)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::UseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,:LUMBERRY,
   :BIGMALASADA,:STRAWBERRYBOX,:PEWTERCRUNCHIES,:RAGECANDYBAR)

ItemHandlers::UseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,scene|
  if pokemon.isRB? # Done separately
    if pokemon.eggsteps==pokemon.maxsteps
      scene.pbDisplay(_INTL("It won't have any effect."))
      return false
    else
      hpgain=pbItemRestoreSteps(pokemon,pokemon.maxsteps-pokemon.eggsteps)
      scene.pbRefresh
      scene.pbDisplay(_INTL("Remote Box's battery was restored by {2} steps.",pokemon.name,hpgain))
      return true
    end
  elsif pokemon.hp<=0 || (pokemon.hp==pokemon.totalhp && pokemon.status==0)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     hpgain=pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
     pokemon.healStatus
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     end
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVE,proc{|item,pokemon,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.hp=(pokemon.totalhp/2).floor
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healHP
     pokemon.healStatus
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:MAXREVIVE,:GALAXIANBOX)


ItemHandlers::UseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,60,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,120,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healHP
     pokemon.healStatus
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,10)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
      scene.pbDisplay(_INTL("PP was restored."))
      next true
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::UseOnPokemon.add(:MAXETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::UseOnPokemon.copy(:MAXETHER,:APPLEBOX)

ItemHandlers::UseOnPokemon.add(:ELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})


ItemHandlers::UseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:BANANABOX,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,15)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PPUP,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup+=1
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:PPMAX,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup=3
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:HPUP,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::HP)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PROTEIN,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::ATTACK)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:IRON,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::DEFENSE)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CALCIUM,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPATK)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ZINC,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPDEF)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CARBOS,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPEED)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:HEALTHWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::HP,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::ATTACK,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:RESISTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::DEFENSE,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPATK,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPDEF,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,PBStats::SPEED,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc{|item,pokemon,scene|
   if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbChangeLevel(pokemon,pokemon.level+1,scene)
     scene.pbHardRefresh
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:RARECANDY,:VANILLABOX)

ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::HP,[
      _INTL("{1} adores you! Its base HP fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base HP can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base HP fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::ATTACK,[
      _INTL("{1} adores you! Its base Attack fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base Attack can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::DEFENSE,[
      _INTL("{1} adores you! Its base Defense fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base Defense can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::SPATK,[
      _INTL("{1} adores you! Its base Special Attack fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base Special Attack can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base Special Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::SPDEF,[
      _INTL("{1} adores you! Its base Special Defense fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base Special Defense can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base Special Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,PBStats::SPEED,[
      _INTL("{1} adores you! Its base Speed fell!",pokemon.name),
      _INTL("{1} became more friendly. Its base Speed can't go lower.",pokemon.name),
      _INTL("{1} became more friendly. However, its base Speed fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:SHAYMIN) && pokemon.form==0 &&
      pokemon.status!=PBStatuses::FROZEN && !PBDayNight.isNight?
     if pokemon.hp>0
       pokemon.form=1
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc{|item,pokemon,scene|
   if (isConst?(pokemon.species,PBSpecies,:TORNADUS) ||
      isConst?(pokemon.species,PBSpecies,:THUNDURUS) ||
      isConst?(pokemon.species,PBSpecies,:LANDORUS) ||
      isConst?(pokemon.species,PBSpecies,:ENAMORUS))
     if pokemon.hp>0
       pokemon.form=(pokemon.form==0) ? 1 : 0
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc{|item,pokemon,scene|
   # Kyurem
   if isConst?(pokemon.species,PBSpecies,:KYUREM)
     if pokemon.hp>0
       if pokemon.fused!=nil
         if $Trainer.party.length>=6
           scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
           next false
         else
           $Trainer.party[$Trainer.party.length]=pokemon.fused
           pokemon.fused=nil
           pokemon.form=0
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           next true
         end
       else
         chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
         if chosen>=0
           poke2=$Trainer.party[chosen]
           if (isConst?(poke2.species,PBSpecies,:RESHIRAM) ||
              isConst?(poke2.species,PBSpecies,:ZEKROM)) && poke2.hp>0 && !poke2.isEgg?
             pokemon.form=1 if isConst?(poke2.species,PBSpecies,:RESHIRAM)
             pokemon.form=2 if isConst?(poke2.species,PBSpecies,:ZEKROM)
             pokemon.fused=poke2
             pbRemovePokemonAt(chosen)
             scene.pbHardRefresh
             scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
             next true
           elsif poke2.isRB?
             scene.pbDisplay(_INTL("It cannot be fused with a Remote Box."))
           elsif poke2.isEgg?
             scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
           elsif poke2.hp<=0
             scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
           elsif pokemon==poke2
             scene.pbDisplay(_INTL("It cannot be fused with itself."))
           else
             scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
           end
         else
           next false
         end
       end
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   # Necrozma
   elsif isConst?(pokemon.species,PBSpecies,:NECROZMA)
     if pokemon.hp>0
       if pokemon.fused!=nil
         if $Trainer.party.length>=6
           scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
           next false
         else
           $Trainer.party[$Trainer.party.length]=pokemon.fused
           pokemon.fused=nil
           pokemon.form=0
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           next true
         end
       else
         chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
         if chosen>=0
           poke2=$Trainer.party[chosen]
           if (isConst?(poke2.species,PBSpecies,:SOLGALEO) ||
              isConst?(poke2.species,PBSpecies,:LUNALA)) && poke2.hp>0 && !poke2.isEgg?
             pokemon.form=1 if isConst?(poke2.species,PBSpecies,:SOLGALEO)
             pokemon.form=2 if isConst?(poke2.species,PBSpecies,:LUNALA)
             pokemon.fused=poke2
             pbRemovePokemonAt(chosen)
             scene.pbHardRefresh
             scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
             next true
           elsif poke2.isRB?
             scene.pbDisplay(_INTL("It cannot be fused with a Remote Box."))
           elsif poke2.isEgg?
             scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
           elsif poke2.hp<=0
             scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
           elsif pokemon==poke2
             scene.pbDisplay(_INTL("It cannot be fused with itself."))
           else
             scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
           end
         else
           next false
         end
       end
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   # Calyerex
   elsif isConst?(pokemon.species,PBSpecies,:CALYREX)
     if pokemon.hp>0
       if pokemon.fused!=nil
         if $Trainer.party.length>=6
           scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
           next false
         else
           $Trainer.party[$Trainer.party.length]=pokemon.fused
           pokemon.fused=nil
           pokemon.form=0
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           next true
         end
       else
         chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
         if chosen>=0
           poke2=$Trainer.party[chosen]
           if (isConst?(poke2.species,PBSpecies,:GLASTRIER) ||
              isConst?(poke2.species,PBSpecies,:SPECTRIER)) && poke2.hp>0 && !poke2.isEgg?
             pokemon.form=1 if isConst?(poke2.species,PBSpecies,:GLASTRIER)
             pokemon.form=2 if isConst?(poke2.species,PBSpecies,:SPECTRIER)
             pokemon.fused=poke2
             pbRemovePokemonAt(chosen)
             scene.pbHardRefresh
             scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
             next true
           elsif poke2.isRB?
             scene.pbDisplay(_INTL("It cannot be fused with a Remote Box."))
           elsif poke2.isEgg?
             scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
           elsif poke2.hp<=0
             scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
           elsif pokemon==poke2
             scene.pbDisplay(_INTL("It cannot be fused with itself."))
           else
             scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
           end
         else
           next false
         end
       end
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   # Microsoft
   elsif isConst?(pokemon.species,PBSpecies,:MICROSOFT)
     if pokemon.hp>0
       if pokemon.fused!=nil
         if $Trainer.party.length>=6
           scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
           next false
         else
           $Trainer.party[$Trainer.party.length]=pokemon.fused
           pokemon.fused=nil
           pokemon.form=0
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           next true
         end
       else
         chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
         if chosen>=0
           poke2=$Trainer.party[chosen]
           if (isConst?(poke2.species,PBSpecies,:XBOX) ||
              isConst?(poke2.species,PBSpecies,:BING) ||
              isConst?(poke2.species,PBSpecies,:AZURE) ||
              isConst?(poke2.species,PBSpecies,:VISUALSTUDIIO)) && poke2.hp>0 && !poke2.isEgg?
             pokemon.form=1 if isConst?(poke2.species,PBSpecies,:XBOX)
             pokemon.form=2 if isConst?(poke2.species,PBSpecies,:BING)
             pokemon.form=3 if isConst?(poke2.species,PBSpecies,:AZURE)
             pokemon.form=4 if isConst?(poke2.species,PBSpecies,:VISUALSTUDIO)
             pokemon.fused=poke2
             pbRemovePokemonAt(chosen)
             scene.pbHardRefresh
             scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
             next true
           elsif poke2.isRB?
             scene.pbDisplay(_INTL("It cannot be fused with a Remote Box."))
           elsif poke2.isEgg?
             scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
           elsif poke2.hp<=0
             scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
           elsif pokemon==poke2
             scene.pbDisplay(_INTL("It cannot be fused with itself."))
           else
             scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
           end
         else
           next false
         end
       end
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:HOOPA)
     if pokemon.hp>0
       pokemon.form=(pokemon.form==0) ? 1 : 0
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

# Oricorio Nectars (Begin)

ItemHandlers::UseOnPokemon.add(:PINKNECTAR,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:ORICORIO) && pokemon.form!=2
     if pokemon.hp>0
       pokemon.form=2
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:PURPLENECTAR,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:ORICORIO) && pokemon.form!=3
     if pokemon.hp>0
       pokemon.form=3
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:REDNECTAR,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:ORICORIO) && pokemon.form!=0
     if pokemon.hp>0
       pokemon.form=0
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:YELLOWNECTAR,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:ORICORIO) && pokemon.form!=1
     if pokemon.hp>0
       pokemon.form=1
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

# Oricorio Nectars (End)

# Mints (Begin)

ItemHandlers::UseOnPokemon.add(:LONELYMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::LONELY,1)
})

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::ADAMANT,3)
})

ItemHandlers::UseOnPokemon.add(:NAUGHTYMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::NAUGHTY,4)
})

ItemHandlers::UseOnPokemon.add(:BRAVEMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::BRAVE,2)
})

ItemHandlers::UseOnPokemon.add(:BOLDMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::BOLD,5)
})

ItemHandlers::UseOnPokemon.add(:IMPISHMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::IMPISH,8)
})

ItemHandlers::UseOnPokemon.add(:LAXMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::LAX,9)
})

ItemHandlers::UseOnPokemon.add(:RELAXEDMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::RELAXED,7)
})

ItemHandlers::UseOnPokemon.add(:MODESTMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::MODEST,15)
})

ItemHandlers::UseOnPokemon.add(:MILDMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::MILD,16)
})

ItemHandlers::UseOnPokemon.add(:RASHMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::RASH,19)
})

ItemHandlers::UseOnPokemon.add(:QUIETMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::QUIET,17)
})

ItemHandlers::UseOnPokemon.add(:CALMMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::CALM,20)
})

ItemHandlers::UseOnPokemon.add(:GENTLEMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::GENTLE,21)
})

ItemHandlers::UseOnPokemon.add(:CAREFULMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::CAREFUL,23)
})

ItemHandlers::UseOnPokemon.add(:SASSYMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::SASSY,22)
})

ItemHandlers::UseOnPokemon.add(:TIMIDMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::TIMID,10)
})

ItemHandlers::UseOnPokemon.add(:HASTYMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::HASTY,11)
})

ItemHandlers::UseOnPokemon.add(:JOLLYMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::JOLLY,13)
})

ItemHandlers::UseOnPokemon.add(:NAIVEMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::NAIVE,14)
})

ItemHandlers::UseOnPokemon.add(:SERIOUSMINT,proc{|item,pokemon,scene|
   next pbConvertStats(pokemon,scene,item,PBNatures::SERIOUS,12)
})

# Mints (End)

# Candies (Begin)

ItemHandlers::UseOnPokemon.add(:EXPCANDYL,proc{|item,pokemon,scene|
   maxexp=PBExperience.pbGetMaxExperience(pokemon.growthrate)
   if pokemon.exp<maxexp
     if pokemon.hp>0
       pokemon.exp+=10000
       pokemon.exp=maxexp if pokemon.exp>maxexp
       pokemon.calcStats
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1}'s Exp was boosted!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM,proc{|item,pokemon,scene|
   maxexp=PBExperience.pbGetMaxExperience(pokemon.growthrate)
   if pokemon.exp<maxexp
     if pokemon.hp>0
       pokemon.exp+=3000
       pokemon.exp=maxexp if pokemon.exp>maxexp
       pokemon.calcStats
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1}'s Exp was boosted!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS,proc{|item,pokemon,scene|
   maxexp=PBExperience.pbGetMaxExperience(pokemon.growthrate)
   if pokemon.exp<maxexp
     if pokemon.hp>0
       pokemon.exp+=800
       pokemon.exp=maxexp if pokemon.exp>maxexp
       pokemon.calcStats
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1}'s Exp was boosted!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL,proc{|item,pokemon,scene|
   maxexp=PBExperience.pbGetMaxExperience(pokemon.growthrate)
   if pokemon.exp<maxexp
     if pokemon.hp>0
       pokemon.exp+=30000
       pokemon.exp=maxexp if pokemon.exp>maxexp
       pokemon.calcStats
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1}'s Exp was boosted!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc{|item,pokemon,scene|
   maxexp=PBExperience.pbGetMaxExperience(pokemon.growthrate)
   if pokemon.exp<maxexp
     if pokemon.hp>0
       pokemon.exp+=100
       pokemon.exp=maxexp if pokemon.exp>maxexp
       pokemon.calcStats
       scene.pbRefresh
       scene.pbDisplay(_INTL("{1}'s Exp was boosted!",pokemon.name))
       next true
     else
       scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

# Candies (End)

ItemHandlers::UseOnPokemon.add(:COSTUMECATALOG,proc{|item,pokemon,scene|
  if (isConst?(pokemon.species,PBSpecies,:PIKACHU) && pokemon.form>1)
    if pokemon.hp>0
      scene.pbDisplay(_INTL("The Catalogue contains a list of costumes for {1} to wear.",pokemon.name))
      cmd =0
      msg = _INTL("Which costume would you like to wear?")
      commands = [_INTL("Rock Star"),
                  _INTL("Belle"),
                  _INTL("Pop Star"),
                  _INTL("Ph. D"),
                  _INTL("Libre"),
                  _INTL("Remove Costume"),
                  _INTL("Cancel")]
      cmd = scene.pbShowCommands(msg,commands,cmd)
      forme=cmd+3
      if cmd>=0 && cmd<=4 && pokemon.form!=forme
        scene.pbDisplay(_INTL("{1} changed costume!",pokemon.name)) 
        pokemon.form=forme
        scene.pbRefresh
        next true
      elsif cmd==5 && pokemon.form>2
        scene.pbDisplay(_INTL("{1} removed costume!",pokemon.name)) 
        pokemon.form=2
        scene.pbRefresh
        next true
      elsif cmd!=6
        scene.pbDisplay(_INTL("It had no effect.")) if cmd!=-1
        next false
      else
        scene.pbRefresh
        next true
      end
    else
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ROTOMCATALOG,proc{|item,pokemon,scene|
  if (isConst?(pokemon.species,PBSpecies,:ROTOM))
    if pokemon.hp>0
      scene.pbDisplay(_INTL("The Catalogue contains a list of appliance for {1} to posses.",pokemon.name))
      cmd =0
      msg = _INTL("Which device would you like to posses?")
      commands = [_INTL("Microwave"),
                  _INTL("Washing Machine"),
                  _INTL("Refrigerator"),
                  _INTL("Electric Fan"),
                  _INTL("Lawnmower"),
                  _INTL("Remove Appliance"),
                  _INTL("Cancel")]
      cmd = scene.pbShowCommands(msg,commands,cmd)
      forme=cmd+1
      if cmd>=0 && cmd<=4 && pokemon.form!=forme
        scene.pbDisplay(_INTL("{1} changed appliance!",pokemon.name)) 
        pokemon.form=forme
        scene.pbRefresh
        next true
      elsif cmd==5 && pokemon.form>0
        scene.pbDisplay(_INTL("{1} removed appliance!",pokemon.name)) 
        pokemon.form=0
        scene.pbRefresh
        next true
      elsif cmd!=6
        scene.pbDisplay(_INTL("It had no effect.")) if cmd!=-1
        next false
      else
        scene.pbRefresh
        next true
      end
    else
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    end
  else
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})


ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc{|item,pokemon,scene|
   abils=pokemon.getAbilityList
   abil1=0; abil2=0
   for i in abils
     abil1=i[0] if i[1]==0
     abil2=i[0] if i[1]==1
   end
   if abil1<=0 || abil2<=0 || pokemon.hasHiddenAbility?
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   newabil=(pokemon.abilityIndex+1)%2
   newabilname=PBAbilities.getName((newabil==0) ? abil1 : abil2)
   if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",
      pokemon.name,newabilname))
     pokemon.setAbility(newabil)
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pokemon.name,
        PBAbilities.getName(pokemon.ability)))
     next true
   end
   next false
})

#===============================================================================
# BattleUseOnPokemon handlers
#===============================================================================

ItemHandlers::BattleUseOnPokemon.add(:POTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:POTION,:SOURCANDY)


ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,120,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MEGAPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,200,scene)
})


ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXPOTION,:MELONBOX)

ItemHandlers::BattleUseOnPokemon.add(:ORANGEBOX,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,(pokemon.totalhp/2).floor,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:CHERRYBOX,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,40,scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:CHERRYBOX,:SPICYCANDY)

ItemHandlers::BattleUseOnPokemon.add(:CHOCOLATEBOX,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,120,scene)
})

=begin
ItemHandlers::BattleUseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})
=end

ItemHandlers::BattleUseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,60,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,80,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,100,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,10,scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:ORANBERRY,:SWEETCANDY)


ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,(pokemon.totalhp/4).floor,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:PARLYZHEAL,:PARALYZEHEAL,:CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,:LUMBERRY,
   :BIGMALASADA,:STRAWBERRYBOX,:PEWTERCRUNCHIES,:RAGECANDYBAR)

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.hp==pokemon.totalhp && pokemon.status==0 &&
      (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
      if battler
        hpgain = battler.pbRecoverHP(pokemon.totalhp-pokemon.hp)
      else
        hpgain = pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
      end
     pokemon.healStatus
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     end
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.hp=(pokemon.totalhp/2).floor
     pokemon.healStatus
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healHP
     pokemon.healStatus
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXREVIVE,:GALAXIANBOX)


ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,60,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,120,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.healStatus
     pokemon.hp=pokemon.totalhp
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER,proc{|item,pokemon,battler,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbBattleRestorePP(pokemon,battler,move,10)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER,proc{|item,pokemon,battler,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbBattleRestorePP(pokemon,battler,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXETHER,:APPLEBOX)

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:BANANABOX,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,15)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REDFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Attract]>=0
     battler.effects[PBEffects::Attract]=-1
     scene.pbDisplay(_INTL("{1} got over its infatuation.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.add(:YELLOWFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Confusion]>0
     battler.effects[PBEffects::Confusion]=0
     scene.pbDisplay(_INTL("{1} snapped out of confusion.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:YELLOWFLUTE,:PERSIMBERRY)

#===============================================================================
# BattleUseOnBattler handlers
#===============================================================================

ItemHandlers::BattleUseOnBattler.add(:XATTACK,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ATTACK,battler,false)
     battler.pbIncreaseStat(PBStats::ATTACK,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ATTACK,battler,false)
     battler.pbIncreaseStat(PBStats::ATTACK,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ATTACK,battler,false)
     battler.pbIncreaseStat(PBStats::ATTACK,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::ATTACK,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE,battler,false)
     battler.pbIncreaseStat(PBStats::DEFENSE,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFEND,:XDEFENSE)

ItemHandlers::BattleUseOnBattler.add(:XDEFEND2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE,battler,false)
     battler.pbIncreaseStat(PBStats::DEFENSE,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFEND2,:XDEFENSE2)

ItemHandlers::BattleUseOnBattler.add(:XDEFEND3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE,battler,false)
     battler.pbIncreaseStat(PBStats::DEFENSE,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFEND3,:XDEFENSE3)

ItemHandlers::BattleUseOnBattler.add(:XDEFEND6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::DEFENSE,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFEND6,:XDEFENSE6)

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPATK,battler,false)
     battler.pbIncreaseStat(PBStats::SPATK,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XSPECIAL,:XSPATK)

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPATK,battler,false)
     battler.pbIncreaseStat(PBStats::SPATK,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XSPECIAL2,:XSPATK2)

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPATK,battler,false)
     battler.pbIncreaseStat(PBStats::SPATK,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XSPECIAL3,:XSPATK3)

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::SPATK,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.copy(:XSPECIAL6,:XSPATK6)

ItemHandlers::BattleUseOnBattler.add(:XSPDEF,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPDEF,battler,false)
     battler.pbIncreaseStat(PBStats::SPDEF,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPDEF,battler,false)
     battler.pbIncreaseStat(PBStats::SPDEF,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPDEF,battler,false)
     battler.pbIncreaseStat(PBStats::SPDEF,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::SPDEF,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPEED,battler,false)
     battler.pbIncreaseStat(PBStats::SPEED,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPEED,battler,false)
     battler.pbIncreaseStat(PBStats::SPEED,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::SPEED,battler,false)
     battler.pbIncreaseStat(PBStats::SPEED,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::SPEED,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY,battler,false)
     battler.pbIncreaseStat(PBStats::ACCURACY,1,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY,battler,false)
     battler.pbIncreaseStat(PBStats::ACCURACY,2,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY,battler,false)
     battler.pbIncreaseStat(PBStats::ACCURACY,3,battler,true)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbIncreaseStatWithCause(PBStats::ACCURACY,6,battler,PBItems.getName(item))
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.effects[PBEffects::FocusEnergy]>=1
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=1
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT2,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.effects[PBEffects::FocusEnergy]>=2
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=2
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT3,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.effects[PBEffects::FocusEnergy]>=3
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=3
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:GUARDSPEC,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   if battler.pbOwnSide.effects[PBEffects::Mist]>0
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.pbOwnSide.effects[PBEffects::Mist]=5
     if !scene.pbIsOpposing?(battler.index)
       scene.pbDisplay(_INTL("Your team became shrouded in mist!"))
     else
       scene.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
     end
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:POKEDOLL,proc{|item,battler,scene|
   battle=battler.battle
   if battle.opponent
     scene.pbDisplay(_INTL("Can't use that here."))
     return false
   else
     playername=battle.pbPlayer.name
     scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::BattleUseOnBattler.add(:BOTANICSMOKE,proc{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   user=battler.pbOppositeOpposing
   user=battler.pbOppositeOpposing2 if rand(10) < 5 || battler.pbOppositeOpposing.isFainted? 
   user=battler.pbOppositeOpposing if !$dbattle
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,PBItems.getName(item)))
   scene.pbAnimation(getConst(PBMoves,:HERBALSMOKE),battler,user) # Plays animation even if it would be immune
    if (user.hasWorkingAbility(:MAGICGUARD) || 
        user.hasWorkingAbility(:SUPERCLEARBODY) ||
        user.hasWorkingAbility(:HERBALILITY) ||
        user.hasWorkingItem(:BOTANICSMOKE) ||
        user.pbHasType?(:HERB) || user.pbHasType?(:GLIMSE))
      scene.pbDisplay(_INTL("But it had no effect!"))
      return false
    else
      pbSEPlay("protection")
      scene.pbDisplay(_INTL("{1}'s {2} took {3} down with it!",playername,
          PBItems.getName(item),user.pbThis(true)))
      user.pbReduceHP(user.hp)
      user.pbFaint # no return
      return true
#      scene.pbJudgeCheckpoint(user)
    end
})


ItemHandlers::BattleUseOnBattler.addIf(proc{|item|
                pbIsPokeBall?(item)},proc{|item,battler,scene|  # Any Poké Ball
   battle=battler.battle
   if !battler.pbOpposing1.isFainted? && !battler.pbOpposing2.isFainted?
     if !pbIsSnagBall?(item)
       scene.pbDisplay(_INTL("It's no good! It's impossible to aim when there are two Pokémon!"))
       return false
     end
   end
   if battle.pbPlayer.party.length>=6 && $PokemonStorage.full?
     scene.pbDisplay(_INTL("There is no room left in the PC!"))
     return false
   end
   return true
})

#===============================================================================
# UseInBattle handlers
#===============================================================================

ItemHandlers::UseInBattle.add(:POKEDOLL,proc{|item,battler,battle|
   battle.decision=3
   pbPlayEscapeSE()
   battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::UseInBattle.addIf(proc{|item| pbIsPokeBall?(item)},
   proc{|item,battler,battle|  # Any Poké Ball 
      battle.pbThrowPokeBall(battler.index,item)
})