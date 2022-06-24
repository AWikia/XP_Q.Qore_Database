#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @nicknamed=false
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    isbox = @pokemon.remoteBox==1
    if isHisuian?(@pokemon)
      background="hatchbg_hisui"
    elsif isGalarian?(@pokemon) || isMysterical?(@pokemon)
      background="hatchbg_galar"
    elsif isAlolan?(@pokemon) || isPhonetic?(@pokemon)
      background="hatchbg_alola"
    else
      background="hatchbg"
    end
    addBackgroundOrColoredPlane(@sprites,"background",background,
       Color.new(248,248,248),@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setSpeciesBitmap(@pokemon.species,@pokemon.isFemale?,
                                         (@pokemon.form rescue 0),@pokemon.isShiny?,
                                         false,false,true,isbox) # Egg sprite
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=48+(Graphics.height-@sprites["pokemon"].bitmap.height)/2
    @sprites["hatch"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    crackfilename=sprintf("Graphics/Battlers/%seggCracks",getConstantName(PBSpecies,@pokemon.species)) rescue nil
    if !pbResolveBitmap(crackfilename)
      crackfilename=sprintf("Graphics/Battlers/%03deggCracks",@pokemon.species)
      if !pbResolveBitmap(crackfilename)
        crackfilename=sprintf("Graphics/Battlers/eggCracks")
      end
    end
    crackfilename=pbResolveBitmap(crackfilename)
    hatchSheet=AnimatedBitmap.new(crackfilename)
    if isGalarian?(@pokemon)
      pbBGMPlay("evolv_galar")
    elsif isMysterical?(@pokemon)
      pbBGMPlay("evolv_mystery")
    elsif isAlolan?(@pokemon)
      pbBGMPlay("evolv_alola")
    elsif isPhonetic?(@pokemon)
      pbBGMPlay("evolv_phonetic")
    else
      pbBGMPlay("evolv")
    end
    # Egg animation
    updateScene(60)
    pbPositionHatchMask(hatchSheet,0)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,1)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,2)
    pbSEPlay("ballshake")
    swingEgg(4,2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,3)
    pbSEPlay("ballshake")
    swingEgg(8,4)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,4)
    pbSEPlay("recall")
    # Fade and change the sprite
    fadeSpeed=15
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(i*fadeSpeed,i*fadeSpeed,i*fadeSpeed)
      @sprites["overlay"].opacity=i*fadeSpeed
      updateScene
    end
    updateScene(30)
    @sprites["pokemon"].setPokemonBitmap(@pokemon) # Pokémon sprite
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=-8+(Graphics.height-@sprites["pokemon"].bitmap.height)/2
    metrics=load_data("Data/metrics.dat")
    @sprites["pokemon"].y+=(metrics[1][@pokemon.species] || 0)*2 - (metrics[2][@pokemon.species] || 0)*2
    @sprites["hatch"].visible=false
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(255-i*fadeSpeed,255-i*fadeSpeed,255-i*fadeSpeed)
      @sprites["overlay"].opacity=255-i*fadeSpeed
      updateScene
    end
    @sprites["pokemon"].tone=Tone.new(0,0,0)
    @sprites["overlay"].opacity=0
    # Finish scene
    frames=pbCryFrameLength(@pokemon.species)
    pbBGMStop()
    pbPlayCry(@pokemon)
    updateScene(frames)
    pbMEPlay("EvolutionSuccess")
    if @pokemon.remoteBox==1
      Kernel.pbMessage(_INTL("\\se[]{1} released from its Remote Box!\\wt[80]",@pokemon.name)) { update }
      @pokemon.removeRB
    else
      Kernel.pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]",@pokemon.name)) { update }
    end
    if Kernel.pbConfirmMessage(
        _INTL("Would you like to nickname the newly hatched {1}?",@pokemon.name)) { update }
      nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",@pokemon.name),0,12,"",@pokemon,true)
      @pokemon.name=nickname if nickname!=""
      @nicknamed=true
    end
    Kernel.pbReceiveTrophy(:THATCHER)
  end

  def pbPositionHatchMask(hatchSheet,index)
    @sprites["hatch"].bitmap.clear
    frames = 5
    frameWidth = (hatchSheet.width/frames).floor
    rect = Rect.new(frameWidth*index,0,frameWidth,hatchSheet.height)
    @sprites["hatch"].bitmap.blt(@sprites["pokemon"].x,@sprites["pokemon"].y,
                                 hatchSheet.bitmap,rect)
  end

  def swingEgg(speed,swingTimes=1) # Only accepts 2, 4 or 8 for speed.
    limit = 8
    targets = [@sprites["pokemon"].x-limit,@sprites["pokemon"].x+limit,
               @sprites["pokemon"].x]
    swingTimes.times do
      usedSpeed=speed
      for target in targets
        usedSpeed*=-1
        while target!=@sprites["pokemon"].x
          @sprites["pokemon"].x+=usedSpeed
          @sprites["hatch"].x+=usedSpeed
          updateScene
        end
      end
    end
  end

  def updateScene(frames=1) # Can be used for "wait" effect
    frames.times do
      Graphics.update
      Input.update
      self.update
    end
  end  

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update } if !@nicknamed
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonEggHatchScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbMain
    @scene.pbEndScene
  end
end



def pbHatchAnimation(pokemon)
  Kernel.pbMessage(_INTL("Huh?\1"))
  pbFadeOutInWithMusic(99999) {
     scene=PokemonEggHatchScene.new
     screen=PokemonEggHatchScreen.new(scene)
     screen.pbStartScreen(pokemon)
  }
  return true
end

def pbHatch(pokemon)
  speciesname=PBSpecies.getName(pokemon.species)
  pokemon.name=speciesname
  pokemon.trainerID=$Trainer.id
  pokemon.ot=$Trainer.name
  pokemon.happiness=120
  pokemon.timeEggHatched=pbGetTimeNow
  pokemon.obtainMode=1 # hatched from egg
  pokemon.hatchedMap=$game_map.map_id
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon)
  pokemon.pbRecordFirstMoves
  if !pbHatchAnimation(pokemon)
    Kernel.pbMessage(_INTL("Huh?\1"))
    Kernel.pbMessage(_INTL("...\1"))
    Kernel.pbMessage(_INTL("... .... .....\1"))
    if pokemon.remoteBox==1
      Kernel.pbMessage(_INTL("{1} released from its Remote Box!",speciesname))
      pokemon.removeRB
    else
      Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
    end
    if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
      species=PBSpecies.getName(pokemon.species)
      nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,12,"",pokemon)
      pokemon.name=nickname if nickname!=""
    end
  end
  Kernel.pbReceiveTrophy(:THATCHER)
end

Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   for egg in $Trainer.party
     marmor = false
     crack = false
     if egg.eggsteps>0
       egg.eggsteps-=1 if !egg.isRB? # This is handled elsewhere for remote boxes
       for i in $Trainer.pokemonParty
         if egg.isRB? # Remote Box
           if !i.isEgg? # Don't check for eggs or other remote boxes
             egg.eggsteps-=1 # Reduces egg steps even if the Pokémon can't gain experience
             maxexp=PBExperience.pbGetMaxExperience(i.growthrate)
             if i.exp<maxexp
               oldlevel=i.level
               expp =  1
               expp *= 2 if isConst?(i.item,PBItems,:LUCKYEGG)
               expp *= 2 if isConst?(i.ability,PBAbilities,:PROTEINCROTELINE)
               i.exp+=expp
               if i.level!=oldlevel
                 i.calcStats
                 movelist=i.getMoveList
                 for j in movelist
                   i.pbLearnMove(j[1]) if j[0]==i.level       # Learned a new move
                 end
               end
             end
           end
         else # Egg
           if isConst?(i.ability,PBAbilities,:FINITI)
             egg.eggsteps-=[rand(4),rand(4)].min 
           end
           if isConst?(i.ability,PBAbilities,:NERVOUSCRACK)
             egg.eggsteps-=[rand(100),rand(100)].min if !crack
             crack = true
           end
           if isConst?(i.ability,PBAbilities,:SIAXIS)
             egg.eggsteps-=1
           end
           if isConst?(i.ability,PBAbilities,:FLAMEBODY) ||
              isConst?(i.ability,PBAbilities,:MAGMAARMOR) ||
              isConst?(i.ability,PBAbilities,:STEAMENGINE)
             egg.eggsteps-=1 if !marmor
             marmor = true
           end
         end
       end
       if egg.eggsteps<=0
         egg.eggsteps=0
         pbHatch(egg)
       end
     end
   end
}