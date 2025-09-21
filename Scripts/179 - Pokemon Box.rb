class PokemonBoxScene
  attr_accessor :stages
  attr_accessor :items

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def initialize
    @stages=4 # Classic, Bronze, Silver, Gold
  end
  
  def stages
    return @stages rescue 4
  end

  def pbStartScene(expired=false)
    heal=[:AWAKENING,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL]
    heal=heal[$Trainer.publicID($Trainer.id)%heal.length]
    @items = [
            [:POTION,:POKEBALL],
            [:SUPERPOTION,:GREATBALL,heal],
            [:HYPERPOTION,:ULTRABALL,:FULLHEAL,:NORMALGEM],
            [:MEGAPOTION,:PARKBALL,:FULLHEAL,:NORMALGEM,:RARECANDY],
            # Elite Challenge
            [:FULLRESTORE,:PARKBALL,:SUPERBOOSTER,:NORMALBOX,:VICIOUSCANDY],
            # Legendary Challenge
            [:SACREDASH,:MASTERBALL,:SUPERBOOSTER,:BOTANICSMOKE,:NORMALBOX,:VICIOUSCANDY]
            ]
    @durations=[13,7,5,5,3,2] # Was [14,6,4,4,2,2]
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-140,44,@viewport)
    @sprites["bg"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
#    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_0",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132+14,240,@viewport)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132+14,338,@viewport)
    @sprites["progresstime"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["bg"].z = 1
    @sprites["machine"].z = 2
    @sprites["progress"].z = 2
    @sprites["progresstime"].z = 2
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokémon Box - Win Streak: {1}",$game_variables[PBOX_VARIABLES[2]]),
       2,-18,400,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayTask"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayTask"].z = 2
    @sprites["overlayTime"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayTime"].z = 2
    @sprites["overlayItems"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayItems"].z = 2

    @sprites["task0"]=IconSprite.new(@sprites["machine"].x+12,@sprites["machine"].y+70,@viewport)
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_magnemite"))
    @sprites["task0"].z = 3
    @sprites["task1"]=IconSprite.new(@sprites["machine"].x+76,@sprites["machine"].y+70,@viewport)
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_shellder"))
    @sprites["task1"].z = 3
    @sprites["task2"]=IconSprite.new(@sprites["machine"].x+140,@sprites["machine"].y+70,@viewport)
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_pikachu"))
    @sprites["task2"].z = 3
    @sprites["task3"]=IconSprite.new(@sprites["machine"].x+204,@sprites["machine"].y+70,@viewport)
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_psyduck"))
    @sprites["task3"].z = 3
    expiredbox = pbTimeEventValid(PBOX_VARIABLES[3]) || expired
    if $game_variables[PBOX_VARIABLES[1]] == 0 || expiredbox
      $game_variables[PBOX_VARIABLES[2]]=0
      initializeBox
    end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbPokemonBoxStart
    pbFadeInAndShow(@sprites) { update }
    if expiredbox
        Kernel.pbMessage(_INTL("You ran out of time on the previous box. Better luck next time."))
    end
    pbPokemonBoxAdvance
  end
  
  # Mlienial Streak Counts:
  # * 10, 20, 30, 40, 50 and anything divisible by 100 starting from 100
  def isMillenial?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < @stages # First Gold and below can never be milestone
    return id%10 == 0
  end
  
  def isMillenial2?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < @stages # First Gold and below can never be milestone
    return id%100 == 0
  end
  
  def addIncr(num)
    return ((($game_variables[PBOX_VARIABLES[2]] / 10).floor / 4) * num).floor
  end
  
  def currentStep
    return $game_variables[PBOX_VARIABLES[0]] + (4*$game_variables[PBOX_VARIABLES[4]])
  end
  
  def randIncr(num)
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    if isMillenial? # Milenial Box, prefer Larger amounts
      return [rand(num),rand(num)].max
    elsif id < 2    # Classic and Bronze Boxes, prefer smaller amounts
      return [rand(num),rand(num)].min
    else
      return rand(num)
    end
  end
  
  def taskVals(num=0)
    multi=1+[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min
    multi+=1 if isMillenial2?
    multi2=1 + [($Trainer.numbadges / 2).floor,5].min
    return [(500*multi)+randIncr((1500*multi*multi2)+addIncr(500)), # Gain Experience
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Level Up Pokemon
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Defeat Pokemon
            (1*multi)+randIncr((2*multi)+addIncr(1)),               # Catch Pokemon
            (10*multi)+randIncr((20*multi)+addIncr(10)),            # Trigger Abilites
            (10*multi)+randIncr((20*multi)+addIncr(10)),            # Trigger Items
            (3*multi)+randIncr((3*multi)+addIncr(3)),               # Use Physical Moves
            (3*multi)+randIncr((3*multi)+addIncr(3)),               # Use Special Moves
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Status Moves
            (0.5*multi)+randIncr((1*multi)+addIncr(0.5)),           # Use Battle Items
            (3*multi)+randIncr((3*multi)+addIncr(3)),               # Defear Trainers
            (7*multi)+randIncr((7*multi)+addIncr(7)),               # Lapse Turns
            (1*multi)+randIncr((2*multi)+addIncr(1)),               # Use Medicine Items
            (3*multi)+randIncr((3*multi)+addIncr(3)),               # UNUSED!
            (250*multi)+randIncr((1250*multi*multi2)+addIncr(250)), # Deal Damage
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Land Critical Hits
            (2*multi)+randIncr((3*multi)+addIncr(2)),               # Use STAB Moves
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Defeat Pokemon Instantly
            (1*multi)+randIncr((2*multi)+addIncr(1)),               # Use Berries
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # UNUSED!
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Increase Stats
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Revive Pokemon
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Healing Moves
            (0.25*multi)+randIncr((0.5*multi)+addIncr(0.25)),       # Use One-hit KO Moves 
            (2*multi)+randIncr((3*multi)+addIncr(3)),               # Use Hi Priority Moves
            ][num].ceil

  end
  
  def pbPokemonBoxStart
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
    text = _INTL("Win battles, including wild to complete tasks.")
    text2 = _INTL("Each Pokémon requires a different task.")
    text3 = _INTL("Finish all four tasks to get a new box and rewards.")
    text4 = _INTL("If the time expires, your win streak rests.")
    drawTextEx(overlay,0,32,(Graphics.width/2)-28,2,text,baseColor,shadowColor)
    drawTextEx(overlay,0,112,(Graphics.width/2)-28,2,text2,baseColor,shadowColor)
    drawTextEx(overlay,0,192,(Graphics.width/2)-28,2,text3,baseColor,shadowColor)
    drawTextEx(overlay,0,272,(Graphics.width/2)-28,2,text4,baseColor,shadowColor)
    pbDrawTextPositions(overlay,textPositions)
    pbPokemonBoxUpdate
  end
  
  # Creates a new box instance
  def initializeBox
    taskN12=false
    taskN10=false # For Milleinal/Elite Boxes
    taskN13=false # Not applicable on Q.Qore
    taskN18=false
    taskN19=false # Not applicable on Q.Qore
    taskN24=false
    task0 = [0,1,2,14,20]
    if rand(6)==0 && !taskN12
      taskN12=true
      task0.push(12)
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task0.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task0.push(18)
    elsif rand(6)==0 && !taskN24 && isMillenial?
      taskN24=true
      task0.push(24)
    end
    task0.shuffle!
    task1 = [3,4,5,15,21]
    if rand(6)==0 && !taskN12
      taskN12=true
      task1.push(12)
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task1.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task1.push(18)
    elsif rand(6)==0 && !taskN24 && isMillenial?
      taskN24=true
      task1.push(24)
    end
    task1.shuffle!
    task2 = [6,7,8,16,22]
    if rand(6)==0 && !taskN12
      taskN12=true
      task2.push(12)
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task2.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task2.push(18)
    elsif rand(6)==0 && !taskN24
      taskN24=true
      task2.push(24)
    end
    task2.shuffle!
    task3 = [9,10,11,17,23]
    task3 = [9,11,17,23] if taskN10 # Don't assign the 11th task in order again
    if rand(6)==0 && !taskN12
      taskN12=true
      task3.push(12)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task3.push(18)
    elsif rand(6)==0 && !taskN24
      taskN24=true
      task3.push(24)
    end
    task3.shuffle!
    $game_variables[PBOX_VARIABLES[0]]=0
    $game_variables[PBOX_VARIABLES[1]] = [
      # Task #0
      [task0[0],$PokemonGlobal.pokebox[task0[0]],taskVals(task0[0])],
      [task1[0],$PokemonGlobal.pokebox[task1[0]],taskVals(task1[0])],
      [task2[0],$PokemonGlobal.pokebox[task2[0]],taskVals(task2[0])],
      [task3[0],$PokemonGlobal.pokebox[task3[0]],taskVals(task3[0])],
      # Task #1
      [task0[1],$PokemonGlobal.pokebox[task0[1]],taskVals(task0[1])],
      [task1[1],$PokemonGlobal.pokebox[task1[1]],taskVals(task1[1])],
      [task2[1],$PokemonGlobal.pokebox[task2[1]],taskVals(task2[1])],
      [task3[1],$PokemonGlobal.pokebox[task3[1]],taskVals(task3[1])],      
      # Task #2
      [task0[2],$PokemonGlobal.pokebox[task0[2]],taskVals(task0[2])],
      [task1[2],$PokemonGlobal.pokebox[task1[2]],taskVals(task1[2])],
      [task2[2],$PokemonGlobal.pokebox[task2[2]],taskVals(task2[2])],
      [task3[2],$PokemonGlobal.pokebox[task3[2]],taskVals(task3[2])],      
      # Task #3
      [task0[3],$PokemonGlobal.pokebox[task0[3]],taskVals(task0[3])],
      [task1[3],$PokemonGlobal.pokebox[task1[3]],taskVals(task1[3])],
      [task2[3],$PokemonGlobal.pokebox[task2[3]],taskVals(task2[3])],
      [task3[3],$PokemonGlobal.pokebox[task3[3]],taskVals(task3[3])]      
                                          ]
    id = [$game_variables[PBOX_VARIABLES[2]],(@durations.length)-3].min
    id = @durations.length-2 if isMillenial?
    id = @durations.length-1 if isMillenial2?
    pbTimeEventDays(PBOX_VARIABLES[3],@durations[id])
    pbPokemonBoxUpdate(true)
  end

  # Updates the box itself (The progress bar, the text, the task and the icons)
  def pbPokemonBoxUpdate(showMillenialMessage=false)
    taskname=$PokemonGlobal.pokeboxNames[$game_variables[PBOX_VARIABLES[1]][currentStep][0]]
    taskstatus=$PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][currentStep][0]] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
    taskstatus2=$game_variables[PBOX_VARIABLES[1]][currentStep][2]
    @sprites["overlayTask"].bitmap.clear
    @sprites["overlayTime"].bitmap.clear
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    progress=[]
    progressTime=[]
    value=$game_variables[PBOX_VARIABLES[3]]
    shadowfract=taskstatus*100/taskstatus2
    id2 = [$game_variables[PBOX_VARIABLES[2]],(@durations.length)-3].min
    id2 = @durations.length-2 if isMillenial?
    id2 = @durations.length-1 if isMillenial2?
    remtime = @durations[id2]*86400
    shadowfract2=(value[1]-(pbGetTimeNow.to_f - value[0]))*100/remtime
    if ($PokemonSystem.threecolorbar==1 rescue false)
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    else
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    end
      progress.push(["Graphics/UI/Pokemon Box/icons",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*$game_variables[PBOX_VARIABLES[1]][currentStep][0],34,34])
      progressTime.push(["Graphics/UI/Pokemon Box/icon_clock",@sprites["progresstime"].x-28,@sprites["progresstime"].y-6,0,0,-1,-1])
    id = [$game_variables[PBOX_VARIABLES[2]],(@items.length)-3].min
    id = @items.length-2 if isMillenial?
    id = @items.length-1 if isMillenial2?
    x = 116 - ([(@items[id].length - 1),4].min * 24)
    for i in @items[id]
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,i)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,i)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+14+offsetY,0,0,-1,-1])
      x+=(96.0/[(@items[id].length - 1),4].max)*2
    end
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    textpos=[
       [_INTL("{1}: {2}/{3}",taskname,[taskstatus,taskstatus2].min,taskstatus2),14,200,0,baseColor,shadowColor],
    ]
    textposTime=[
       [_INTL("Time left: {1}",pbTimeEventRemainingTime(PBOX_VARIABLES[3])),14,298,0,baseColor,shadowColor]
    ]
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    @sprites["overlayTask"].z = 2
    pbDrawTextPositions(@sprites["overlayTask"].bitmap,textpos)
    pbDrawImagePositions(@sprites["overlayTask"].bitmap,progress)
    pbDrawTextPositions(@sprites["overlayTime"].bitmap,textposTime)
    pbDrawImagePositions(@sprites["overlayTime"].bitmap,progressTime)
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    @sprites["header"].text=_INTL("Pokémon Box - Win Streak: {1}",$game_variables[PBOX_VARIABLES[2]])
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    update_icons
    if showMillenialMessage
      if isMillenial2?
        Kernel.pbMessage(_INTL("Legendary Challenge Ahead!"))
      elsif isMillenial?
        Kernel.pbMessage(_INTL("Elite Challenge Ahead!."))
      end
      Kernel.pbMessage(_INTL("Finish this box within a 2-day interval to receive special rewards.")) if isMillenial?
    end
  end
  
  def animateTaskPane(from=255,into=0)
    zoom=from.to_f
    dec=(from.to_f - into.to_f) / 10.0
    10.times do
      Graphics.update
      Input.update
      zoom-=dec
      @sprites["progress"].opacity=zoom
      @sprites["overlayTask"].opacity=zoom
    end
  end
  
  def refreshTask
    pbPlayEquipSE()
    animateTaskPane(255,0)
    $game_variables[PBOX_VARIABLES[1]][currentStep][1] = $PokemonGlobal.pokebox[ $game_variables[PBOX_VARIABLES[1]][currentStep][0] ]
    pbPokemonBoxUpdate(false)
    animateTaskPane(0,255)
  end
  
  # Used to check if the box should advance itself
  def pbPokemonBoxAdvance
    taskstatus=$PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][currentStep][0]] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
    taskstatus2=$game_variables[PBOX_VARIABLES[1]][currentStep][2]
    if taskstatus >= taskstatus2
      $game_variables[PBOX_VARIABLES[0]]+=1
      $game_variables[PBOX_VARIABLES[4]]=0 # Reset Substep
      update_icons
      pbSEPlay("DTM_start")
      Kernel.pbMessage(_INTL("Task Completed"))
      if $game_variables[PBOX_VARIABLES[0]] > 3
        animateTaskPane(255,0)
        close_box
        pbSEPlay("Item3",100,80)
        if isMillenial2?
          Kernel.pbMessage(_INTL("Legendary Box Completed. Here's your rewards"))
        elsif isMillenial?
          Kernel.pbMessage(_INTL("Elite Box Completed. Here's your rewards"))
        else
          Kernel.pbMessage(_INTL("Box Completed. Here's your rewards"))
        end
        id = [$game_variables[PBOX_VARIABLES[2]],(@items.length)-3].min
        id = @items.length-2 if isMillenial?
        id = @items.length-1 if isMillenial2?
        for i in @items[id]
          Kernel.pbReceiveItem(i,1)
        end
        $game_variables[PBOX_VARIABLES[2]]+=1
        stage=[_INTL("Classic"), 
               _INTL("Bronze"),
               _INTL("Silver"),
               _INTL("Gold")][[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min] rescue ""
        if $game_variables[PBOX_VARIABLES[2]] >= stage.length
          Kernel.pbMessage(_INTL("Spectacular! Keep completing out {1} Pokémon Boxes.",stage))
        else
          Kernel.pbMessage(_INTL("You've unlocked the {1} Pokémon Box. Spectacular!",stage))
        end
        initializeBox
        animateTaskPane(0,255)
      else
        # Refresh Task
        refreshTask
      end
    end
  end
  
  # Closes out the Pokemon Box container itself
  def close_box
    @sprites["task0"].visible= false
    @sprites["task1"].visible= false
    @sprites["task2"].visible= false
    @sprites["task3"].visible= false
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    id = [$game_variables[PBOX_VARIABLES[2]],(@items.length)-3].min
    id = @items.length-2 if isMillenial?
    id = @items.length-1 if isMillenial2?
    x = 116 - ([(@items[id].length - 1),4].min * 24)
    idx=0
    for i in @items[id]
      idx+=1
      if idx == 1 || idx == @items[id].length
        y = 70
      else
        y = 54
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,i)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,i)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+y+offsetY,0,0,-1,-1])
      x+=(96.0/[(@items[id].length - 1),4].max)*2
    end
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_closed",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_elite_closed",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_legendary_closed",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
  end
  
  # Updates the icons in the Pokemon Box container itself
  def update_icons
    @sprites["task0"].visible= $game_variables[PBOX_VARIABLES[0]]>0
    @sprites["task1"].visible= $game_variables[PBOX_VARIABLES[0]]>1
    @sprites["task2"].visible= $game_variables[PBOX_VARIABLES[0]]>2
    @sprites["task3"].visible= $game_variables[PBOX_VARIABLES[0]]>3
  end
  
  def pbPokemonBoxScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::A)
        maxtimes = ($game_variables[PBOX_VARIABLES[1]].length/4).floor - 1
        availabletimes = maxtimes - $game_variables[PBOX_VARIABLES[4]]
        if $game_variables[PBOX_VARIABLES[4]]>=maxtimes
          Kernel.pbMessage(_INTL("You can't change this task any longer."))
        elsif Kernel.pbConfirmMessage(_INTL("Are you sure you want to change this task? You can change it {1} times. Any progress done on this one will be lost.",availabletimes))
          $game_variables[PBOX_VARIABLES[4]]+=1
          refreshTask
        end
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonBoxEvent # Not PokemonBox as it conflicts with another class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(expired=false)
    @scene.pbStartScene(expired)
    @scene.pbPokemonBoxScreen
    @scene.pbEndScene
  end
end