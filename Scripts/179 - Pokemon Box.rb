class PokemonBoxScene
  attr_accessor :stages
  attr_accessor :items

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(expired=false)
    @stages=4 # Classic, Bronze, Silver, Gold
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
    @durations=[12,6,4,4,2,2]
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-140,44,@viewport)
    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_0",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132+14,240,@viewport)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132,338,@viewport)
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
    @sprites["overlay2"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlay2"].z = 2
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
    pbSetSystemFont(@sprites["overlay2"].bitmap)
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
    return id%100 == 0 || (id%10 == 0 && id<51)
  end
  
  def isMillenial2?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < @stages # First Gold and below can never be milestone
    return id%1000 == 0
  end
  
  def addIncr(num)
    return ((($game_variables[PBOX_VARIABLES[2]] / 2).floor / 4) * num).floor
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
    multi=1+[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min
    multi+=1 if isMillenial2?
    multi2=1 + [($Trainer.numbadges / 2).floor,5].min
    taskVals=[(500*multi)+rand((1500*multi*multi2)+addIncr(500)), # Gain Experience
              (2*multi)+rand((2*multi)+addIncr(2)),               # Level Up Pokemon
              (2*multi)+rand((2*multi)+addIncr(2)),               # Defeat Pokemon
              (1*multi)+rand((2*multi)+addIncr(1)),               # Catch Pokemon
              (10*multi)+rand((20*multi)+addIncr(10)),            # Trigger Abilites
              (10*multi)+rand((20*multi)+addIncr(10)),            # Trigger Items
              (2*multi)+rand((2*multi)+addIncr(2)),               # Use Physical Moves
              (2*multi)+rand((2*multi)+addIncr(2)),               # Use Special Moves
              (2*multi)+rand((2*multi)+addIncr(2)),               # Use Status Moves
              (1*multi)+rand((1*multi)+addIncr(1)),               # Use Battle Items
              (3*multi)+rand((3*multi)+addIncr(3)),               # Defear Trainers
              (7*multi)+rand((7*multi)+addIncr(7)),               # Lapse Turns
              (2*multi)+rand((2*multi)+addIncr(2)),               # Use Medicine Items
              (3*multi)+rand((6*multi)+addIncr(3)),               # UNUSED!
              (250*multi)+rand((1250*multi*multi2)+addIncr(250)), # Deal Damage
              (2*multi)+rand((2*multi)+addIncr(2)),               # Land Critical Hits
              (2*multi)+rand((2*multi)+addIncr(2)),               # Use STAB Moves
              (1*multi)+rand((1*multi)+addIncr(1)),               # Defeat Pokemon Instantly
              (1*multi)+rand((2*multi)+addIncr(1)),               # Use Berries
              (1*multi)+rand((1*multi)+addIncr(1))                # UNUSED!
              ]
    taskN12=false
    taskN10=false # For Milleinal/Elite Boxes
    taskN13=false # Not applicable on Q.Qore
    taskN18=false
    taskN19=false # Not applicable on Q.Qore
    task0 = [0,1,2,14][rand(4)]
    if rand(6)==0 && !taskN12
      taskN12=true
      task0=12
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task0=10
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task0=18
    end
    task1 = [3,4,5,15][rand(4)]
    if rand(6)==0 && !taskN12
      taskN12=true
      task1=12
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task1=10
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task1=18
    end
    task2 = [6,7,8,16][rand(4)]
    if rand(6)==0 && !taskN12
      taskN12=true
      task2=12
    elsif rand(6)==0 && !taskN10 && isMillenial?
      taskN10=true
      task2=10
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task2=18
    end
    task3 = [9,10,11,17][rand(4)]
    task3 = [9,11,17][rand(3)] if taskN10 # Don't assign the 11th task in order again
    if rand(6)==0 && !taskN12
      taskN12=true
      task3=12
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task3=18
    end
    $game_variables[PBOX_VARIABLES[0]]=0
    $game_variables[PBOX_VARIABLES[1]] = [
      [task0,$PokemonGlobal.pokebox[task0],taskVals[task0]],
      [task1,$PokemonGlobal.pokebox[task1],taskVals[task1]],
      [task2,$PokemonGlobal.pokebox[task2],taskVals[task2]],
      [task3,$PokemonGlobal.pokebox[task3],taskVals[task3]]
                                          ]
    id = [$game_variables[PBOX_VARIABLES[2]],(@durations.length)-3].min
    id = @durations.length-2 if isMillenial?
    id = @durations.length-1 if isMillenial2?
    pbTimeEventDays(PBOX_VARIABLES[3],@durations[id])
    pbPokemonBoxUpdate
    if isMillenial2?
      Kernel.pbMessage(_INTL("Legendary Challenge Ahead!"))
    elsif isMillenial?
      Kernel.pbMessage(_INTL("Elite Challenge Ahead!."))
    end
    Kernel.pbMessage(_INTL("Finish this box within a 2-day interval to receive special rewards.")) if isMillenial?
  end

  # Updates the box itself (The progress bar, the text, the task and the icons)
  def pbPokemonBoxUpdate
    taskname=$PokemonGlobal.pokeboxNames[$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][0]]
    taskstatus=$PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][0]] - $game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][1]
    taskstatus2=$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][2]
    @sprites["overlay2"].bitmap.clear
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    progress=[]
    value=$game_variables[PBOX_VARIABLES[3]]
    shadowfract=taskstatus*100/taskstatus2
    shadowfract2=(value[1]-(pbGetTimeNow.to_f - value[0]))*100/value[1]
    if ($PokemonSystem.threecolorbar==1 rescue false)
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    else
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    end
      progress.push(["Graphics/UI/Pokemon Box/icons",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][0],34,34])
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
       [_INTL("Time left: {1}",pbTimeEventRemainingTime(PBOX_VARIABLES[3])),14,298,0,baseColor,shadowColor]
    ]
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    @sprites["overlay2"].z = 2
    pbDrawTextPositions(@sprites["overlay2"].bitmap,textpos)
    pbDrawImagePositions(@sprites["overlay2"].bitmap,progress)
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    @sprites["header"].text=_INTL("Pokémon Box - Win Streak: {1}",$game_variables[PBOX_VARIABLES[2]])
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_elite",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial?
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}_legendary",[$game_variables[PBOX_VARIABLES[2]],(@stages-1)].min)) if isMillenial2?
    update_icons
  end
  
  # Used to check if the box should advance itself
  def pbPokemonBoxAdvance
    taskstatus=$PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][0]] - $game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][1]
    taskstatus2=$game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][2]
    if taskstatus >= taskstatus2
      $game_variables[PBOX_VARIABLES[0]]+=1
      update_icons
      pbSEPlay("DTM_start")
      Kernel.pbMessage(_INTL("Task Completed"))
      if $game_variables[PBOX_VARIABLES[0]] > 3
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
      else
        # Refresh Task
        $game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][1] = $PokemonGlobal.pokebox[ $game_variables[PBOX_VARIABLES[1]][$game_variables[PBOX_VARIABLES[0]]][0] ]
        pbPokemonBoxUpdate
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
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonBox
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(expired=false)
    @scene.pbStartScene(expired)
    @scene.pbPokemonBoxScreen
    @scene.pbEndScene
  end
end