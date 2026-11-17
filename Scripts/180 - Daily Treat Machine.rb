class DailyTreatMachineScene
  attr_accessor :items
  attr_accessor :id

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-138,76,@viewport)
    level = pbGetCardLevel
    @machinestarted=false
    # Streak Lost
    losestreak=false
    oldstreak=$game_variables[DTM_VARIABLES[0]]
    if pbTimeEventValid(DTM_VARIABLES[1])
      $game_variables[DTM_VARIABLES[0]]=0
      losestreak=true
    end
    # Last Used Level
    upgraded=false
    if $game_variables[DTM_VARIABLES[2]]>0 && 
       $game_variables[DTM_VARIABLES[2]] <= level
      upgraded=true
    end
    $game_variables[DTM_VARIABLES[2]] = 1 + level
    # Increase Streak
    $game_variables[DTM_VARIABLES[0]]+=1
    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Treat Machine/bg_"+level.to_s,@viewport)
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Treat Machine/overlay_machine_"+level.to_s))
    @sprites["bg"].z = 1
    @sprites["machine"].z = 2
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Daily Treat Machine - Load Streak: {1}",$game_variables[DTM_VARIABLES[0]]),
       2,-18,400,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayStar"]=BitmapSprite.new(Graphics.width/2,Graphics.height - 40,@viewport)
    @sprites["overlayStar"].z = 2
    x=(Graphics.width/4)-75
    imagepos = []
    @overlaystar=@sprites["overlayStar"].bitmap
    @overlaystar.clear
    for i in 0..4
      iconvariant=(level>i) ? 1 : 0
      imagepos.push(["Graphics/UI/"+getDarkModeFolder+"/Daily Treat Machine/icon_stars",x,40,28*iconvariant,0,28,28])
      x+=30
    end
    pbDrawImagePositions(@overlaystar,imagepos)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @items     = [0,0,0,0,0,0,0,1]  # Daily Chest
    @rfrag     = [0,1]              # Random Pokemon Fragment
    @rfragMS   = [0]                # Random Mega Stone Fragment
    @rfragRB   = [0]                # Random Remote Box Fragment
    if level>=1
      @items   = [0,0,0,0,0,1,1,2]  # Daily Chest
      @rfrag   = [0,1,1,2]          # Random Pokemon Fragment
      @rfragMS = [0]                # Random Mega Stone Fragment
      @rfragRB = [0]                # Random Remote Box Fragment
    end
    if level>=2
      @items   = [0,0,1,1,1,2,2,3]  # Daily Chest
      @rfrag   = [0,0,1,1,1,2,2,3]  # Random Pokemon Fragment
      @rfragMS = [0,1]              # Random Mega Stone Fragment
      @rfragRB = [0]                # Random Remote Box Fragment
    end
    if level>=3
      @items   = [1,1,1,2,2,3,3,4]  # Daily Chest
      @rfrag   = [1,1,1,2,2,3,3,4]  # Random Pokemon Fragment
      @rfragMS = [0,1,2,2]          # Random Mega Stone Fragment
      @rfragRB = [0,1]              # Random Remote Box Fragment
    end
    if level>=4
      @items   = [1,2,2,3,3,4,4,5]  # Daily Chest
      @rfrag   = [1,1,2,2,2,3,3,4]  # Random Pokemon Fragment
      @rfragMS = [0,0,1,1,1,2,3,3]  # Random Mega Stone Fragment
      @rfragRB = [0,1,1,2]          # Random Remote Box Fragment
    end
    if level>=5
      @items   = [1,2,2,3,3,4,4,5]  # Daily Chest
      @rfrag   = [1,2,2,2,3,3,3,4]  # Random Pokemon Fragment
      @rfragMS = [1,1,1,2,2,3,3,4]  # Random Mega Stone Fragment
      @rfragRB = [0,0,1,1,1,2,2,3]  # Random Remote Box Fragment
    end
    @rfragMS = [0] if !hasSupercharger? # Don't throw Random Mega Stone Fragments when player has no Mega Ring
    pbTreatMachine
    pbFadeInAndShow(@sprites) { update }
    if upgraded
      if level>4
        Kernel.pbMessage(_INTL("\\me[EvolutionSuccess_1]Machine fully upgraded! Maximum reward chances unlocked."))
      else
        Kernel.pbMessage(_INTL("\\me[EvolutionSuccess_1]Machine upgraded! Improved reward chances unlocked."))
      end
    end
    if losestreak
        Kernel.pbMessage(_INTL("\\me[EvolutionCancelled]Oh no! You've broke your {1} load streak while you were taking your break.",oldstreak))
    end
    4.times do
      Graphics.update
      Input.update
    end
    @machinestarted=true
  end

  def pbTreatMachine
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    textPositions=[
       [_INTL("How to use:"),(Graphics.width/4)-14,0,2,baseColor,shadowColor],
    ]
    text = _INTL("Get rewards from the machine each day.")
    text2 = _INTL("Extra reward is awarded every 7 consecutive game loads")
    text3 = _INTL("Machine upgrades as you progress the game")
    text4 = _INTL("Use a Heart Scale or Ad Quests for additional rewards")
    drawTextEx(overlay,0,32,(Graphics.width/2)-28,2,text,baseColor,shadowColor)
    drawTextEx(overlay,0,112,(Graphics.width/2)-28,2,text2,baseColor,shadowColor)
    drawTextEx(overlay,0,192,(Graphics.width/2)-28,2,text3,baseColor,shadowColor)
    drawTextEx(overlay,0,272,(Graphics.width/2)-28,2,text4,baseColor,shadowColor)
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbDailuMachineStart
    pbSEPlay("DTM_start")
    frame=0
    until frame==20 # 60 frames per seconds
      Graphics.update
      Input.update
      @sprites["machine"].flash(Color.new(222,222,222,frame*12),20)
      frame+=1
    end
    until frame==0 # 60 frames per seconds
      Graphics.update
      Input.update
      @sprites["machine"].flash(Color.new(222,222,222,frame*12),20)
      frame-=1
    end
    @sprites["machine"].flash(Color.new(0,0,0,0),40)
    # Main Daily Chest Items:
    # 0 = Common 
    # 1 = Uncommon
    # 2 = Rare
    # 3 = Elite
    # 4 = Epic
    # 5 = Legendary
    # 6 = x2 Legendary
    item=@items[rand(@items.length)]
    item=[:COMMONDAILYCHEST,:UNCOMMONDAILYCHEST,:RAREDAILYCHEST,:ELITEDAILYCHEST,
          :EPICDAILYCHEST,:LEGENDARYDAILYCHEST,[:LEGENDARYDAILYCHEST,2] ][item]
    Kernel.pbReceiveItem(item)
    # Random Pokemon Fragment
    item=@rfrag[rand(@rfrag.length)]
    if item>0
      Kernel.pbReceiveItem(:RANDOMPOKEMONFRAGMENT,item)
    end
    # Random Mega Stone Fragment
    item=@rfragMS[rand(@rfragMS.length)]
    if item>0
      Kernel.pbReceiveItem(:RANDOMMEGASTONEFRAGMENT,item)
    end
    # Random Remote Box Fragment
    item=@rfragRB[rand(@rfragRB.length)]
    if item>0
      Kernel.pbReceiveItem(:RANDOMREMOTEBOXFRAGMENT,item)
    end
  end
  
  def pbDailyTreatMachineScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if @machinestarted
        heartscale=false
        pbSetLotteryNumber(1)
        @id=$game_variables[1].to_i
        pbDailuMachineStart          
        if $PokemonBag.pbQuantity(:HEARTSCALE)>0 && !heartscale
          if Kernel.pbConfirmMessage(_INTL("Would you like to use a Heart Scale to get a second reward?"))
            heartscale=true
            $PokemonBag.pbDeleteItem(:HEARTSCALE)
            Kernel.pbReceiveItem(:HEARTSCALEDAILYCHEST)
          end
        end
        if canAcceptAds?
          reward = heartscale ? _INTL("third") : _INTL("second")
          if Kernel.pbConfirmMessage(_INTL("Would you like to complete an Ad Quest to get a {1} reward?",reward))
            @id=$game_variables[1].to_i
            @id+=$Trainer.secretID($Trainer.id)
            Kernel.pbReceiveItem(:ADQUESTDAILYCHEST) if startAd
          end
        end
        if $game_variables[DTM_VARIABLES[0]]%7 == 0
          coins = [($game_variables[DTM_VARIABLES[0]] / 0.7).floor,50].min
          Kernel.pbMessage(_INTL("As you've made a 7-day load streak, you'll be getting {1} additional coins.",coins))
          $PokemonGlobal.coins+=coins
        end
        Kernel.pbMessage(_INTL("Load the game tomorrow for your next reward."))
        pbTimeEventDays(DTM_VARIABLES[1],2) # 2 days, event reactivates when 1 day or less is left
        @machinestarted=false
        break
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class DailyTreatMachine
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbDailyTreatMachineScreen
    @scene.pbEndScene
  end
end