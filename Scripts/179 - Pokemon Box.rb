#===============================================================================
# Pokémon Box main screen
#===============================================================================
class PokemonBoxScene
  attr_accessor :stages
  attr_accessor :items

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def initialize
    heal=[:AWAKENING,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL]
    heal=heal[$Trainer.publicID($Trainer.id)%heal.length]
    # 0 = Name
    # 1 = Rewards
    # 2 = Dueation (In days)
    # 3 = Amount Multiplier
    # 4 = Difficulty (0 = Beginner, 1 = Intermediate, 2 = Advanced, 3 = Expert)
    @stages = [
    ["Tutorial",[:ORANBERRY,:SITRUSBERRY],13,0.5,0],
    ["Classic",[:POTION,:POKEBALL],10,1,1],
    ["Bronze",[:SUPERPOTION,:GREATBALL,heal],7,2,1],
    ["Silver",[:HYPERPOTION,:ULTRABALL,:FULLHEAL,:NORMALGEM],5,3.5,2],
    ["Gold",[:MEGAPOTION,:PARKBALL,[:FULLHEAL,2],:NORMALGEM,:RARECANDY],5,5,2],
    # Elite Challenge
    ["Elite",[:FULLRESTORE,[:PARKBALL,2],:SUPERBOOSTER,:NORMALBOX,:VICIOUSCANDY],3,6,3],
    # Legendary Challenge
    ["Legendary",[:SACREDASH,:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:NORMALBOX,:VICIOUSCANDY],3,7,3],
    # Legendary Challenge
    ["Mythical",[[:SACREDASH,2],:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:LOADEDDICE,:NORMALBOX,[:VICIOUSCANDY,2]],3,9,3]

    ]
    if $Trainer && $Trainer.isFemale?
      @icons=["voltorb","staryu","pikachu","slowpoke"]
    else
      @icons=["magnemite","shellder","pikachu","psyduck"]
    end
  end

  def pbStartScene(expired=false)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    # Viewport for the Task Pane
    @viewportTask=Viewport.new(14,196,(Graphics.width / 2)-28,78)
    @viewportTask.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-140,44,@viewport)
    @sprites["bg"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
#    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_0",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132,44,@viewportTask)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["progress"].visible=false
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132+14,338,@viewport)
    @sprites["progresstime"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["bg"].z = 1
    @sprites["machine"].z = 2
    @sprites["progress"].z = 2
    @sprites["progresstime"].z = 2
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("{1} Pokémon Box - Win Streak: {2}",boxName,$game_variables[PBOX_VARIABLES[2]]),
       2,-18,400,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayTask"]=BitmapSprite.new((Graphics.width / 2)-28,78,@viewportTask)
    @sprites["overlayTask"].z = 3
    @sprites["overlayTime"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlayTime"].z = 3
    @sprites["overlayItems"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayItems"].z = 3
    @sprites["task0"]=IconSprite.new(@sprites["machine"].x+12,@sprites["machine"].y+70,@viewport)
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[0]))
    @sprites["task0"].z = 3
    @sprites["task1"]=IconSprite.new(@sprites["machine"].x+76,@sprites["machine"].y+70,@viewport)
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[1]))
    @sprites["task1"].z = 3
    @sprites["task2"]=IconSprite.new(@sprites["machine"].x+140,@sprites["machine"].y+70,@viewport)
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[2]))
    @sprites["task2"].z = 3
    @sprites["task3"]=IconSprite.new(@sprites["machine"].x+204,@sprites["machine"].y+70,@viewport)
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[3]))
    @sprites["task3"].z = 3
    expiredbox = pbTimeEventValid(PBOX_VARIABLES[3]) || expired
    welcome=$game_variables[PBOX_VARIABLES[1]] == 0
    if welcome || expiredbox
      $game_variables[PBOX_VARIABLES[2]]=0
      initializeBox
    end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    pbPokemonBoxStart
    pbFadeInAndShow(@sprites) { update }
    if expiredbox
        Kernel.pbMessage(_INTL("You ran out of time on the previous box. Better luck next time."))
    end
    if welcome
        Kernel.pbMessage(_INTL("Welcome to Pokémon Box where you can complete out tasks by finishing battles."))
        Kernel.pbMessage(_INTL("Finish out four tasks and you'll be getting rewards for your journey and a new Box."))
        Kernel.pbMessage(_INTL("Good Luck!"))
    end
    pbPokemonBoxAdvance
  end
  
  def maxStages
    return @stages.length-3 rescue 4 # 3 Items are Elite Challenge
  end
  
  def currentStage(includeElite=true) # If includeElite is set to false, then currentStage does not increase on Milestone Boxes
    result = [$game_variables[PBOX_VARIABLES[2]],(maxStages-1)].min
    if includeElite
      result+=1 if isMillenial?
      result+=1 if isMillenial2?
      result+=1 if isMillenial3?
    end
    return result
  end
  
  def stageSuffix
    return "_mythical" if isMillenial3?
    return "_legendary" if isMillenial2?
    return "_elite" if isMillenial?
    return ""
  end
  
  def boxName(includeElite=false)
    return @stages[currentStage(includeElite)][0] rescue "Tutorial"
  end
  
  def boxItems
    return @stages[currentStage][1] rescue [:ORANBERRY,:SITRUSBERRY]
  end
  
  def boxDuration
    return @stages[currentStage][2] rescue 13
  end
  
  def boxMulti
    @stages[currentStage][3] rescue 0.5
  end
  
  # 0 = Junior and Basic
  # 1 = Classic and Bronze
  # 2 = Silver and Gold
  # 3 = Milestone Gold
  def boxLevel
    return @stages[currentStage][4] rescue 0
  end

  # Mlienial Streak Counts:
  # * 10, 20, 30, 40, 50 and anything divisible by 100 starting from 100
  def isMillenial?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id%10 == 0
  end
  
  def isMillenial2?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id%100 == 0
  end

  def isMillenial3?
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id%1000 == 0
  end
  
  def addIncr(num)
    return rand( ((($game_variables[PBOX_VARIABLES[2]] / 10).floor / 40) * num).floor )
  end
  
  def currentStep
    return $game_variables[PBOX_VARIABLES[0]] + (4*$game_variables[PBOX_VARIABLES[4]])
  end

  def taskID # Task ID
    return $game_variables[PBOX_VARIABLES[1]][currentStep][0]
  end
  
  def taskname
    return $PokemonGlobal.pokeboxNames[$game_variables[PBOX_VARIABLES[1]][currentStep][0]]
  end
  
  def taskstatus # Current Task Status
    return $PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][currentStep][0]] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
  end
  
  def taskstatus2 # Maximum Task Status
    return $game_variables[PBOX_VARIABLES[1]][currentStep][2]
  end
  
  def getTaskLabel(idx,nohardmarkers=false)
  if isHardTask(idx) && !nohardmarkers
    return "_hard"
  elsif $game_variables[PBOX_VARIABLES[0]]>idx
    return ""
  end
  return "_normal"
  end
  
  def randIncr(num)
    id = $game_variables[PBOX_VARIABLES[2]].to_i
    if boxLevel==3       # Milenial Box, prefer Larger amounts
      return [rand(num),rand(num)].max
    elsif boxLevel==2    # Silver and Gold Boxes, don't prefer anything
      return rand(num)
    else                 # Classic and Bronze Boxes, prefer smaller amounts
      return [rand(num),rand(num)].min
    end
  end
  
  def taskVals(num=0)
    multi=boxMulti
    multi2=1 + [($Trainer.numbadges / 2).floor,5].min
    return [(500*multi)+randIncr((2500*multi*multi2)+addIncr(500)), # Gain Experience
            (1.5*multi)+randIncr((1.5*multi)+addIncr(1.5)),         # Level Up Pokemon
            (3*multi)+randIncr((3*multi)+addIncr(3)),               # Defeat Pokemon
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Catch Pokemon
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Activate Abilites
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Activate Held Items
            (4*multi)+randIncr((4*multi)+addIncr(3)),               # Use Physical Moves
            (4*multi)+randIncr((4*multi)+addIncr(3)),               # Use Special Moves
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Status Moves
            (0.5*multi)+randIncr((0.5*multi)+addIncr(0.5)),         # Use Battle Items
            (3*multi)+randIncr((2*multi)+addIncr(3)),               # Defear Trainers
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Lapse Turns
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Use Medicine Items
            (3*multi)+randIncr((2*multi)+addIncr(3)),               # UNUSED!
            (500*multi)+randIncr((1500*multi*multi2)+addIncr(500)), # Deal Damage
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Land Critical Hits
            (3*multi)+randIncr((3*multi)+addIncr(2)),               # Use STAB Moves
            (1*multi)+randIncr((2*multi)+addIncr(1)),               # Defeat Pokemon Instantly
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Use Berries
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # UNUSED!
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Increase Stats
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Revive Pokemon
            (2*multi)+randIncr((3*multi)+addIncr(2)),               # Use Healing Moves
            (0.2*multi)+randIncr((0.6*multi)+addIncr(0.2)),         # Use One-hit KO Moves 
            (2*multi)+randIncr((3*multi)+addIncr(3)),               # Use Hi Priority Moves
            (6*multi)+randIncr((6*multi)+addIncr(6)),               # Decrease Stats
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Inflict Conditions            
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Moves with Effects
            (1*multi)+randIncr((1*multi)+addIncr(1)),               # Use Copycat Moves
            (250*multi)+randIncr((250*multi*multi2)+addIncr(250)),  # Take Recoil Damage
            (250*multi)+randIncr((500*multi*multi2)+addIncr(250)),  # Recover HP
            (2*multi)+randIncr((3*multi)+addIncr(2)),               # Land Super Effective
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Multi-hit Moves
            (2*multi)+randIncr((1*multi)+addIncr(2)),               # Defeat Best Trainers
            (0.5*multi)+randIncr((1*multi)+addIncr(1)),             # Use Sleeping Moves
            (500*multi)+randIncr((1500*multi*multi2)+addIncr(500)), # Gain Money
            (2*multi)+randIncr((3*multi)+addIncr(2)),               # Land Not Very Effective
            (2*multi)+randIncr((2*multi)+addIncr(2)),               # Use Mutli-Target Moves
            (4*multi)+randIncr((4*multi)+addIncr(5)),               # Activate Win Streak
            (1*multi)+randIncr((2*multi)+addIncr(1))                # Change Forms
            ][num].ceil

  end

  def isHardTask(idx=-1) # idx is used to identify if the current active task is hard
    return false if (currentStep%4 != idx && idx != -1) || boxLevel==0
    multi=boxMulti
    multi2=1 + [($Trainer.numbadges / 2).floor,5].min
    vals = [(500*multi)+(1250*multi*multi2), # Gain Experience
            (1.5*multi)+(0.75*multi),        # Level Up Pokemon
            (3*multi)+(1.5*multi),           # Defeat Pokemon
            (1*multi)+(0.5*multi),           # Catch Pokemon
            (6*multi)+(3*multi),             # Trigger Abilites
            (6*multi)+(3*multi),             # Trigger Items
            (4*multi)+(2*multi),             # Use Physical Moves
            (4*multi)+(2*multi),             # Use Special Moves
            (2*multi)+(1*multi),             # Use Status Moves
            (0.5*multi)+(0.25*multi),        # Use Battle Items
            (3*multi)+(1*multi),             # Defear Trainers
            (6*multi)+(3*multi),             # Lapse Turns
            (1*multi)+(0.5*multi),           # Use Medicine Items
            (3*multi)+(1*multi),             # UNUSED!
            (500*multi)+(750*multi*multi2),  # Deal Damage
            (2*multi)+(1*multi),             # Land Critical Hits
            (3*multi)+(1.5*multi),           # Use STAB Moves
            (1*multi)+(1*multi),             # Defeat Pokemon Instantly
            (1*multi)+(0.5*multi),           # Use Berries
            (1*multi)+(0.5*multi),           # UNUSED!
            (6*multi)+(3*multi),             # Increase Stats
            (1*multi)+(0.5*multi),           # Revive Pokemon
            (2*multi)+(1*multi),             # Use Healing Moves
            (0.2*multi)+(0.3*multi),         # Use One-hit KO Moves 
            (2*multi)+(1*multi),             # Use Hi Priority Moves
            (6*multi)+(3*multi),             # Decrease Stats
            (2*multi)+(1*multi),             # Inflict Conditions            
            (2*multi)+(1*multi),             # Use Moves with Effects
            (1*multi)+(0.5*multi),           # Use Copycat Moves
            (250*multi)+(125*multi*multi2),  # Take Recoil Damage
            (250*multi)+(250*multi*multi2),  # Recover HP
            (2*multi)+(1.5*multi),           # Land Super Effective
            (2*multi)+(1*multi),             # Use Multi-hit Moves
            (2*multi)+(0.5*multi),           # Defeat Best Trainers
            (0.5*multi)+(0.5*multi),         # Use Sleeping Moves
            (500*multi)+(750*multi*multi2),  # Gain Money
            (2*multi)+(1.5*multi),           # Land Not Very Effective
            (2*multi)+(1*multi),             # Use Mutli-Target Moves
            (4*multi)+(2*multi),             # Activate Win Streak
            (1*multi)+(1*multi)              # Change Forms
            ][taskID]
    return taskstatus2 > vals
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
    text2 = _INTL("Finish all four tasks to get rewards and a new box.")
    text3 = _INTL("If the time exipres, your win streak resets.")
    text4 = _INTL("Got stuck? Change task or try with different Pokémon.")
    drawTextEx(overlay,0,32,(Graphics.width/2)-28,2,text,baseColor,shadowColor)
    drawTextEx(overlay,0,112,(Graphics.width/2)-28,2,text2,baseColor,shadowColor)
    drawTextEx(overlay,0,192,(Graphics.width/2)-28,2,text3,baseColor,shadowColor)
    drawTextEx(overlay,0,272,(Graphics.width/2)-28,2,text4,baseColor,shadowColor)
    pbDrawTextPositions(overlay,textPositions)
    pbPokemonBoxUpdate
  end
  
  # Creates a new box instance
  def initializeBox(fromdebug=false)
    taskN12=false
    taskN10=false # For Milleinal/Elite/Level 3 Boxes
    taskN13=false # Not applicable on Q.Qore
    taskN18=false
    taskN19=false # Not applicable on Q.Qore
    taskN24=false
    taskN29=false
    taskN34=false
    taskN39=false
    task0 = [0,1,2,14,20,25,30,35]
    task0 = [0,1,2,14] if boxLevel==0
    if rand(6)==0 && !taskN12
      taskN12=true
      task0.push(12)
    elsif rand(6)==0 && !taskN10 && boxLevel==3
      taskN10=true
      task0.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task0.push(18)
    elsif rand(6)==0 && !taskN24 && boxLevel==3
      taskN24=true
      task0.push(24)
    elsif rand(6)==0 && !taskN29 && boxLevel!=0
      taskN29=true
      task0.push(29)
    elsif rand(6)==0 && !taskN34 && boxLevel!=0
      taskN34=true
      task0.push(34)
    elsif rand(6)==0 && !taskN39 && boxLevel!=0
      taskN29=true
      task0.push(39)
    end
    task0.shuffle!
    task1 = [3,4,5,15,21,26,31,36]
    task1 = [4,15,31,36] if boxLevel==0
    if rand(6)==0 && !taskN12
      taskN12=true
      task1.push(12)
    elsif rand(6)==0 && !taskN10 && boxLevel==3
      taskN10=true
      task1.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task1.push(18)
    elsif rand(6)==0 && !taskN24 && boxLevel==3
      taskN24=true
      task1.push(24)
    elsif rand(6)==0 && !taskN29 && boxLevel!=0
      taskN29=true
      task1.push(29)
    elsif rand(6)==0 && !taskN34 && boxLevel!=0
      taskN34=true
      task1.push(34)
    elsif rand(6)==0 && !taskN39 && boxLevel!=0
      taskN29=true
      task1.push(39)
    end
    task1.shuffle!
    task2 = [6,7,8,16,22,27,32,37]
    task2 = [6,7,8,16] if boxLevel==0
    if rand(6)==0 && !taskN12
      taskN12=true
      task2.push(12)
    elsif rand(6)==0 && !taskN10 && boxLevel==3
      taskN10=true
      task2.push(10)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task2.push(18)
    elsif rand(6)==0 && !taskN24  && boxLevel!=0
      taskN24=true
      task2.push(24)
    elsif rand(6)==0 && !taskN34  && boxLevel!=0
      taskN34=true
      task2.push(34)
    elsif rand(6)==0 && !taskN39  && boxLevel!=0
      taskN29=true
      task2.push(39)
    end
    task2.shuffle!
    task3 = [9,10,11,17,23,28,33,38]
    task3 = [9,11,17,23,28,33,38] if taskN10 # Don't assign the 11th task in order again
    task3 = [10,11,17,38] if boxLevel==0
    if rand(6)==0 && !taskN12
      taskN12=true
      task3.push(12)
    elsif rand(6)==0 && !taskN18
      taskN18=true
      task3.push(18)
    elsif rand(6)==0 && !taskN24 && boxLevel!=0
      taskN24=true
      task3.push(24)
    elsif rand(6)==0 && !taskN34 && boxLevel!=0
      taskN34=true
      task3.push(34)
    elsif rand(6)==0 && !taskN39 && boxLevel!=0
      taskN29=true
      task3.push(39)
    end
    task3.shuffle!
    $game_variables[PBOX_VARIABLES[0]]=0
    $game_variables[PBOX_VARIABLES[4]]=0
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
    pbTimeEventDays(PBOX_VARIABLES[3],boxDuration)
    pbSEPlay("recall") if !fromdebug
    pbPokemonBoxUpdate(true) if !fromdebug
  end

  # Updates the box itself (The progress bar, the text, the task and the icons)
  def pbPokemonBoxUpdate(showMillenialMessage=false)
    @sprites["overlayTask"].bitmap.clear
    @sprites["overlayTime"].bitmap.clear
    @sprites["overlayItems"].bitmap.clear
    imagepos=[]
    imageposAMT=[]
    progress=[]
    progressTime=[]
    value=$game_variables[PBOX_VARIABLES[3]]
    shadowfract=taskstatus*100/taskstatus2
    remtime = boxDuration*86400
    shadowfract2=(value[1]-(pbGetTimeNow.to_f - value[0]))*100/remtime
    progress.push(["Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress",@sprites["progress"].x,@sprites["progress"].y,0,0,-1,-1])
    if ($PokemonSystem.threecolorbar==1 rescue false)
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_threecolorbar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    else
      progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*2.48).floor,-1])
      progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    end
      progress.push(["Graphics/UI/Pokemon Box/icons",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*$game_variables[PBOX_VARIABLES[1]][currentStep][0],34,34])
      progressTime.push(["Graphics/UI/Pokemon Box/icon_clock",@sprites["progresstime"].x-28,@sprites["progresstime"].y-6,0,0,-1,-1])
    x = 116 - ([(boxItems.length - 1),4].min * 24)
    for i in boxItems
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]
      else
        item=i
        amt=1
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+14+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,@sprites["machine"].x+32+x.ceil,@sprites["machine"].y+34,2,Color.new(12,12,12),nil])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",@sprites["machine"].x+x.ceil,@sprites["machine"].y+14,0,0,-1,-1])
      end
      x+=(96.0/[(boxItems.length - 1),4].max)*2
    end
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
      hardBase=Color.new(248,56,32)
      hardShadow=Color.new(224,152,144)
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      hardBase=Color.new(224,152,144)
      hardShadow=Color.new(248,56,32)
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end

    numberbase=(isHardTask()) ? hardBase : baseColor
    numbershadow=(isHardTask()) ? hardShadow : shadowColor

    textpos=[
       [_INTL("{1}",taskname),(Graphics.width/4)-14,4,2,numberbase,numbershadow],
       [_INTL("{1}/{2}",[taskstatus,taskstatus2].min,taskstatus2),(Graphics.width/4)-14+15,40,2,base2,shadow2,true],
    ]
    textposTime=[
       [_INTL("Time Remaning"),(Graphics.width/4),298,2,baseColor,shadowColor],
       [_INTL("{1}",pbTimeEventRemainingTime(PBOX_VARIABLES[3])),(Graphics.width/4)+15,334,2,base2,shadow2,true],
    ]
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    @sprites["overlayTask"].z = 3
    # Task
    pbDrawImagePositions(@sprites["overlayTask"].bitmap,progress)
    pbDrawTextPositions(@sprites["overlayTask"].bitmap,textpos)
    # Time Left
    pbDrawImagePositions(@sprites["overlayTime"].bitmap,progressTime)
    pbDrawTextPositions(@sprites["overlayTime"].bitmap,textposTime)
    # Other
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    pbDrawTextPositions(@sprites["overlayItems"].bitmap,imageposAMT)
    @sprites["header"].text=_INTL("{1} Pokémon Box - Win Streak: {2}",boxName,$game_variables[PBOX_VARIABLES[2]])
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    update_icons
    if showMillenialMessage
      if isMillenial?
        Kernel.pbMessage(_INTL("{1} Challenge Ahead!.",boxName(true)))
      end
      Kernel.pbMessage(_INTL("Finish this box within a 3-day interval to receive special rewards.")) if isMillenial?
    end
  end
  
  def animateTaskPane(from=255,into=0)
    zoom=from.to_f
    dec=(from.to_f - into.to_f) / 10.0
    10.times do
      Graphics.update
      Input.update
      zoom-=dec
      @sprites["overlayTask"].opacity=zoom
      @sprites["overlayTask"].zoom_x=zoom / 255
      @sprites["overlayTask"].zoom_y=zoom / 255
      @sprites["overlayTask"].ox=((Graphics.width / 4)-14)*((255-zoom)/-255) * 1/(zoom/255) if zoom !=0
      @sprites["overlayTask"].oy=39*((255-zoom)/-255) * 1/(zoom/255) if zoom !=0
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
    if taskstatus >= taskstatus2
      oldstep =currentStep%4
      hardtask = isHardTask(oldstep)
      $game_variables[PBOX_VARIABLES[0]]+=1
      $game_variables[PBOX_VARIABLES[4]]=0 # Reset Substep
      update_icons(true)
      if hardtask
        pbSEPlay("Battle effect critical",80)
        Kernel.pbMessage(_INTL("Hard Task Completed and you've got a reward."))
        Kernel.pbReceiveItem([:REDSHARD,:YELLOWSHARD,:BLUESHARD,:GREENSHARD][oldstep],boxLevel)
      else
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Task Completed"))
      end
      if $game_variables[PBOX_VARIABLES[0]] > 3
        animateTaskPane(255,0)
        close_box
        pbSEPlay("Item3",100,80)
        if isMillenial?
          Kernel.pbMessage(_INTL("{1} Box Completed. Here's your rewards",boxName(true)))
        else
          Kernel.pbMessage(_INTL("Box Completed. Here's your rewards"))
        end
        multiamt = 1
        if pbIsMillenialDate?
          Kernel.pbMessage(_INTL("As you're on a special date, you will be getting double rewards."))
          multiamt = 2
        end
        for i in boxItems
          if i.is_a?(Array)
            item=i[0]
            amt=i[1]
          else
            item=i
            amt=1
          end
          Kernel.pbReceiveItem(item,amt*multiamt)
        end
        oldstreak = $game_variables[PBOX_VARIABLES[2]]
        $game_variables[PBOX_VARIABLES[2]]+=1
        $game_variables[PBOX_VARIABLES[2]]=0 if oldstreak == 65535
        stage=boxName() rescue ""
        if oldstreak == 65535
          pbSEPlay("Battle effect message")
          Kernel.pbMessage(_INTL("Extraodinary! You've maxed out the Pokémon Box. You'll get a special prize alongside a new {1} Pokémon Box.",stage))
          Kernel.pbReceiveItem(:MASTERBALL,5*multiamt)
        elsif $game_variables[PBOX_VARIABLES[2]] >= stage.length
          pbSEPlay("Battle effect message")
          Kernel.pbMessage(_INTL("Spectacular! Keep completing out {1} Pokémon Boxes.",stage))
        else
          pbSEPlay("Battle effect message")
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
    imageposAMT=[]
    x = 116 - ([(boxItems.length - 1),4].min * 24)
    idx=0
    for i in boxItems
      idx+=1
      if idx == 1 || idx == boxItems.length
        y = 70
      else
        y = 54
      end
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]
      else
        item=i
        amt=1
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),@sprites["machine"].x+x.ceil+offsetX,@sprites["machine"].y+y+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,@sprites["machine"].x+32+x.ceil,@sprites["machine"].y+y+20,2,Color.new(12,12,12),nil])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",@sprites["machine"].x+x.ceil,@sprites["machine"].y+y,0,0,-1,-1])
      end
      x+=(96.0/[(boxItems.length - 1),4].max)*2
    end
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    pbDrawTextPositions(@sprites["overlayItems"].bitmap,imageposAMT)
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}_closed",currentStage(false),stageSuffix))
  end
  
  # Updates the icons in the Pokemon Box container itself
  def update_icons(nohardmarkers=false)
#icon_{1}",@icons[0]
    @sprites["task0"].visible= true
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[0],getTaskLabel(0,nohardmarkers)))
    @sprites["task1"].visible= true
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[1],getTaskLabel(1,nohardmarkers)))
    @sprites["task2"].visible= true
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[2],getTaskLabel(2,nohardmarkers)))
    @sprites["task3"].visible= true
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[3],getTaskLabel(3,nohardmarkers)))
  end
  
  def changeBoxTask
    maxtimes = ($game_variables[PBOX_VARIABLES[1]].length/4).floor - 1
    availabletimes = maxtimes - $game_variables[PBOX_VARIABLES[4]]
    if $game_variables[PBOX_VARIABLES[4]]>=maxtimes
      Kernel.pbMessage(_INTL("You can't change this task any longer."))
    elsif Kernel.pbConfirmMessage(_INTL("Are you sure you want to change this task? You can change it {1} times. Any progress done on this one will be lost.",availabletimes))
      $game_variables[PBOX_VARIABLES[4]]+=1
      refreshTask
    end
  end
  
  def showTaskInfo
    Kernel.pbMessage(_INTL("\\l[2]{1}",$PokemonGlobal.pokeboxDescriptions[ $game_variables[PBOX_VARIABLES[1]][currentStep][0] ]))
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
        changeBoxTask
      end
      # Left Mouse Key
      if Input.triggerex?(Input::LeftMouseKey)
        mousepos=Mouse::getMousePos(true)
        # Only if Mouse Position can be found
        if mousepos
          # Task Pane
          taskrect=[4,196,(Graphics.width/2)-8,78]
          if contains2(taskrect,mousepos[0],mousepos[1])
            showTaskInfo
          end
          # Time Pane (Not yet added)
          taskrect2=[4,294,(Graphics.width/2)-8,78]
          if contains2(taskrect2,mousepos[0],mousepos[1])
            Kernel.pbMessage(_INTL("Keep an eye on the time. If the time expires, your win streak resets and you'll start over with a classic box."))
          end
          # Box itself
          boxrect=[@sprites["machine"].x,@sprites["machine"].y,280,140]
          if contains2(boxrect,mousepos[0],mousepos[1])
            pbPlayDecisionSE()
            scene=PokemonBoxSummaryScene.new
            screen=PokemonBoxSummary.new(scene)
            pbFadeOutIn(99999) { 
              screen.pbStartScreen
            }
          end
        end
      end
     # End Left Mouse Key
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

  def contains2(rect,x,y)
    return x>=rect[0] && x<rect[0]+rect[2] &&
           y>=rect[1] && y<rect[1]+rect[3]
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

#===============================================================================
# Pokémon Box summary screen
#===============================================================================
class PokemonBoxSummaryScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_menu",@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokémon Box"),
       2,-18,256,64,@viewport)
    if (!isDarkMode?)
      base=Color.new(12,12,12)
      shadow=Color.new(242,242,242)
    else
      base=Color.new(242,242,242)
      shadow=Color.new(12,12,12)
    end
    @sprites["header"].baseColor=base
    @sprites["header"].shadowColor=nil #shadow
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @box=PokemonBoxScene.new
    @maxpages=(@box.stages.length / 8.0).ceil - 1
    @page=((@box.currentStage+1) / 8.0).ceil - 1
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = Graphics.width/2 - 14
    @sprites["uparrow"].y = 16
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = Graphics.width/2 - 14
    @sprites["downarrow"].y = Graphics.height - 32
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = @page != @maxpages
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawPokemonBoxSummaryContents
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawPokemonBoxSummaryContents
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"].visible = @page != @maxpages
    @overlay=@sprites["overlay"].bitmap
    @overlay.clear
    offset=8*@page
    for item in 0+offset...[@box.stages.length,8+offset].min
      x=[4,324,4,324,4,324,4,324][item%8]
      y=[36,36,126,126,216,216,306,306][item%8]
      pbDrawBoxContents(x,y,item)
    end
  end

  def pbDrawBoxContents(x,y,stage)
    filename=stage.to_s
    filename=(@box.maxStages-1).to_s + "_elite" if stage==@box.maxStages
    filename=(@box.maxStages-1).to_s + "_legendary" if stage==@box.maxStages + 1
    filename=(@box.maxStages-1).to_s + "_mythical" if stage==@box.maxStages + 2
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
      hardBase=Color.new(248,56,32)
      hardShadow=Color.new(224,152,144)
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      hardBase=Color.new(224,152,144)
      hardShadow=Color.new(248,56,32)
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    # Box
    imagepos=[
      ["Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_menuwrapper",x,y,0,0,-1,-1],
    ]
    imageposAMT=[]
    lockedimagepos=[]
    # Items
    itemx = 182 - ([(@box.stages[stage][1].length - 1),3].min * 24)
    for i in @box.stages[stage][1]
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]
      else
        item=i
        amt=1
      end
      @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
      offsetX=(48 - @animbitmap.bitmap.width) / 2
      offsetY=(48 - @animbitmap.bitmap.height) / 2
      @animbitmap.dispose
      imagepos.push([pbItemIconFile( getID(PBItems,item)),x+itemx.ceil+offsetX,y+13+offsetY,0,0,-1,-1])
      if amt>1
        imageposAMT.push([amt.to_s,x+32+itemx.ceil,y+33,2,Color.new(12,12,12),nil])
        imagepos.push(["Graphics/UI/Pokemon Box/icon_amount",x+itemx.ceil,y+13,0,0,-1,-1])
      end
      itemx+=(96.0/[(@box.stages[stage][1].length - 1),3].max)*1.5
    end
    # Box Name
    if @box.currentStage == stage
      textpos=[
    #    [_INTL("{1}",@box.stages[stage][0]),x+59,y+4,2,hardBase,hardShadow]
      ]
      imagepos.push(["Graphics/UI/Pokemon Box/overlay_menubox_" + filename,x+10,y+13,0,0,-1,-1])
    else
      textpos=[
        [_INTL("{1}",@box.stages[stage][0]),x+59,y+4,2,baseColor,shadowColor]
      ]
      imagepos.push(["Graphics/UI/Pokemon Box/overlay_menubox_" + filename + "_closed",x+10,y+13,0,0,-1,-1])
      lockedimagepos.push(["Graphics/UI/Pokemon Box/overlay_menuwrapper_locked",x+33,y+9,0,0,-1,-1]) if @box.currentStage<stage
    end
    pbDrawImagePositions(@overlay,imagepos)
    pbSetSmallFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@overlay,imageposAMT)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@overlay,textpos)
    pbDrawImagePositions(@overlay,lockedimagepos)

  end

  def pbPokemonBoxSummaryScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::DOWN) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page+1)%(@maxpages+1)
        pbDrawPokemonBoxSummaryContents
      end
      if Input.trigger?(Input::UP) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page-1)%(@maxpages+1)
        pbDrawPokemonBoxSummaryContents
      end
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
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

class PokemonBoxSummary # Not PokemonBox as it conflicts with another class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen()
    @scene.pbStartScene
    @scene.pbPokemonBoxSummaryScreen
    @scene.pbEndScene
  end
end