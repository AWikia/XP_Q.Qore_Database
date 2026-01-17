#===============================================================================
# Pokémon Box main screen
#===============================================================================
class PokemonBoxScene
  attr_accessor :stages
  attr_accessor :items
  attr_accessor :icons
  attr_accessor :milestoneDay

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def initialize
    heal=[:AWAKENING,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL]
    heal=heal[$Trainer.publicID($Trainer.id)%heal.length]
    heal2=[:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:CHERIBERRY,:ASPEARBERRY]
    heal2=heal2[$Trainer.secretID($Trainer.id)%heal2.length]
    # 0 = Name
    # 1 = Rewards
    # 2 = Dueation (In days)
    # 3 = Amount Multiplier
    # 4 = Difficulty (0 = Beginner, 1 = Intermediate, 2 = Advanced, 3 = Expert, 4 = Master)
    # 5 = Item to be appended when Berry Planting is absent (nil to not add, can be array of two items too)
    @stages = [
    ["Tutorial",[:ORANBERRY,:SITRUSBERRY],13,0.5,0,nil],
    ["Classic",[:POTION,:POKEBALL],10,1,1,:SITRUSBERRY],
    ["Bronze",[:SUPERPOTION,:GREATBALL,heal],7,2.5,1,heal2],
    ["Silver",[:HYPERPOTION,:ULTRABALL,:FULLHEAL,:NORMALGEM],5,7,2,:PERSIMBERRY],
    ["Gold",[:MEGAPOTION,:PARKBALL,[:FULLHEAL,2],:NORMALGEM,:RARECANDY],5,16,2,:PERSIMBERRY],
    # Platinum Mileston
    ["Platinum",[:FULLRESTORE,:PARKBALL,:SUPERBOOSTER,[:NORMALGEM,2],:VICIOUSCANDY],3,20,3,:ENIGMABERRY],
    # Legendary Milestone
    ["Legendary",[:SACREDASH,:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:VICIOUSCANDY],3,25,3,:ENIGMABERRY],
    # Legendary Milestone
    ["Mythical",[[:SACREDASH,2],:MASTERBALL,[:SUPERBOOSTER,2],:BOTANICSMOKE,:LOADEDDICE,[:VICIOUSCANDY,2]],3,30,3,:ENIGMABERRY],
    # Demon Milestone
    ["Demon",[[:SACREDASH,3],:MASTERBALL,[:SUPERBOOSTER,3],[:BOTANICSMOKE,2],:LOADEDDICE,[:VICIOUSCANDY,3]],3,40,4,[:ENIGMABERRY,2]]
    ]
    if $Trainer && $Trainer.isFemale?
      @icons=["voltorb","staryu","pikachu","slowpoke"]
    else
      @icons=["magnemite","shellder","pikachu","psyduck"]
    end
    @milestoneDay=pbIsMillenialDate?
  end

  def pbStartScene(expired=false)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    # Viewport for the Task Pane
    @viewportTask=Viewport.new(14,196,(Graphics.width / 2)-28,82)
    @viewportTask.z=99999
    @sprites["machine"]=IconSprite.new((Graphics.width/4)-140,44,@viewport)
    @sprites["bg"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
#    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_0",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    @sprites["bgM"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
    @sprites["bgM"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_milestone"))
    @sprites["bgM"].opacity= 96
    @sprites["bgM"].visible=@milestoneDay
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    # Task Progress
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132,44,@viewportTask)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress_small"))
    @sprites["progress"].visible=false
    @sprites["progress_icon"]=IconSprite.new((Graphics.width/4)+70,30,@viewportTask)
    @sprites["progress_icon"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/icon_magnemite"))
    @sprites["progress_icon"].visible=false
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132+14,334,@viewport)
    @sprites["progresstime"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress"))
    @sprites["bg"].z = 1
    @sprites["bgM"].z = 2
    @sprites["machine"].z = 3
    @sprites["progress"].z = 3
    @sprites["progress_icon"].z = 4
    @sprites["progresstime"].z = 4
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("{1} Pokémon Box - Win Streak: {2}",boxName, currentStreak),
       2,-18,400,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayTask"]=BitmapSprite.new((Graphics.width / 2)-28,82,@viewportTask)
    @sprites["overlayTask"].z = 4
    @sprites["overlayTime"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlayTime"].z = 4
    @sprites["overlayItems"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayItems"].z = 4
    @sprites["task0"]=IconSprite.new(@sprites["machine"].x+12,@sprites["machine"].y+70,@viewport)
    @sprites["task0"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[0]))
    @sprites["task0"].z = 4
    @sprites["task1"]=IconSprite.new(@sprites["machine"].x+76,@sprites["machine"].y+70,@viewport)
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[1]))
    @sprites["task1"].z = 4
    @sprites["task2"]=IconSprite.new(@sprites["machine"].x+140,@sprites["machine"].y+70,@viewport)
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[2]))
    @sprites["task2"].z = 4
    @sprites["task3"]=IconSprite.new(@sprites["machine"].x+204,@sprites["machine"].y+70,@viewport)
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}",@icons[3]))
    @sprites["task3"].z = 4
    expiredbox = pbTimeEventValid(PBOX_VARIABLES[3]) || expired
    welcome=$game_variables[PBOX_VARIABLES[1]] == 0
    if welcome
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
        stage=@stages[0][0]
        Kernel.pbMessage(_INTL("You ran out of time on this box. Start a new {1} box and try again.",stage))
        $game_variables[PBOX_VARIABLES[2]]=0
        initializeBox
    end
    if welcome
        Kernel.pbMessage(_INTL("Welcome to Pokémon Box where you can complete out tasks by finishing battles."))
        Kernel.pbMessage(_INTL("Finish out four tasks and you'll be getting rewards for your journey and a new Box."))
        Kernel.pbMessage(_INTL("Good Luck!"))
    end
    pbPokemonBoxAdvance
  end
  
  def maxStages
    return @stages.length-4 rescue 4 # 4 Items are Milestone Challenges
  end
  
  def currentStreak
    return $game_variables[PBOX_VARIABLES[2]]
  end
  
  def currentChapter
    return [((currentStreak-1)/10000).floor,0].max
  end
  
  def currentBoxDif # Like currentChapter but is 0 on Level 0 boxes and increases by 1 on milestone days
    return 0 if boxLevel==0
    return 1 + currentChapter if @milestoneDay
    return currentChapter
  end

  def currentStreak2
    return currentStreak - (10000*currentChapter) + 2 if currentChapter>1
    return currentStreak - (10000*currentChapter)
  end

  def currentStage(includeElite=true) # If includeElite is set to false, then currentStage does not increase on Milestone Boxes
    result = [currentStreak2,(maxStages-1)].min
    if includeElite
      result+=1 if isMillenial?
      result+=1 if isMillenial2?
      result+=1 if isMillenial3?
      result+=1 if isMillenial4?
    end
    return result
  end
  
  def getStageNumber(idx=-1)
    return (idx == -1) ? currentStage : idx
  end
  
  def stageSuffix
    return "_demon" if isMillenial4?
    return "_mythical" if isMillenial3?
    return "_legendary" if isMillenial2?
    return "_elite" if isMillenial?
    return ""
  end
  
  def boxName(includeElite=false)
    return @stages[currentStage(includeElite)][0] rescue "Tutorial"
  end
  
  def boxItems(idx=-1)
    if $game_switches[218] && @stages[getStageNumber(idx)][3]>=1
      return @stages[getStageNumber(idx)][1] + [[:GOLDBAR,@stages[getStageNumber(idx)][3].round]] rescue [:ORANBERRY,:SITRUSBERRY]
    elsif !class_exists?(:BerryPlantSprite) && @stages[getStageNumber(idx)][5]
      return @stages[getStageNumber(idx)][1] + [@stages[getStageNumber(idx)][5]] rescue [:ORANBERRY,:SITRUSBERRY]
    else
      return @stages[getStageNumber(idx)][1] rescue [:ORANBERRY,:SITRUSBERRY]
    end
  end
  
  def boxDuration
    return [@stages[currentStage][2]/(1 + (0.5*currentBoxDif) ),3].max rescue 13
  end
  
  def boxMulti
    @stages[currentStage][3] + (4*currentBoxDif) rescue 0.5
  end
  
  # 0 = Junior and Basic
  # 1 = Classic and Bronze
  # 2 = Silver and Gold
  # 3 = Milestone Gold
  # 4 = Mega Milestone Gold
  def boxLevel
    return @stages[currentStage][4] rescue 0
  end

  # Mlienial Streak Counts:
  # * 10, 20, 30, 40, 50 and anything divisible by 100 starting from 100
  def isMillenial?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%10 == 0
  end
  
  def isMillenial2?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%100 == 0
  end

  def isMillenial3?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%1000 == 0
  end

  def isMillenial4?
    id = currentStreak2.to_i
    id2 = currentStreak.to_i
    return false if id < maxStages # First Gold and below can never be milestone
    return id2%10000 == 0
  end

  def addIncr(num)
    return 0 # rand( ((($game_variables[PBOX_VARIABLES[2]] / 10).floor / 40) * num).floor )
  end

  def stepID
    return $game_variables[PBOX_VARIABLES[0]]
  end
  
  def currentStep
    return stepID + (4*$game_variables[PBOX_VARIABLES[4]])
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

  def getTaskHue(idx,nohardmarkers=false)
    if isHardTask(idx) && !nohardmarkers
      return [0,295,210,0][taskLevel(idx)]
    elsif $game_variables[PBOX_VARIABLES[0]]>idx
      return 0
    end
    return 0
  end

  
  def randIncr(num)
    id = currentStreak2.to_i
    if boxLevel==3       # Milenial Box, prefer Larger amounts
      return [rand(num),rand(num)].max
    elsif boxLevel==2    # Silver and Gold Boxes, don't prefer anything
      return rand(num)
    elsif boxLevel==1    # Classic and Bronze Boxes, prefer smaller amounts
      return [rand(num),rand(num)].min
    elsif boxLevel==0    # Tutorial Box, prefer even smaller amounts
      return [rand(num),rand(num),rand(num),rand(num)].min
    else                 # Mega Milenial Box, prefer even Larger amounts
      return [rand(num),rand(num),rand(num),rand(num)].max
    end
  end
  
  def valueFromTo(min=1,max=2,scaleup=0,padding=1)
    multi=boxMulti
    multi2=1 + ([($Trainer.numbadges / 2).floor,6].min * scaleup)
    min=min.to_f
    max=max.to_f
    result=(min*multi) + randIncr((max-min)*(multi*multi2)) + addIncr(min)
    return [(result/padding).round*padding,padding].max.round
  end

  def valueFromToMiddle(min=1,max=2,scaleup=0,padding=1)
    multi=boxMulti
    multi2=1 + ([($Trainer.numbadges / 2).floor,6].min * scaleup)
    min=min.to_f
    max=max.to_f
    result=(min*multi) + ((max-min)*(multi*multi2))
    return [result * 0.5,
            result * 0.7,
            result * 0.9]
  end
  
  def taskVals(num=0)
    return [valueFromTo(200,600,6,10),   # Gain Experience
            valueFromTo(1,1.5),          # Level Up Pokemon
            valueFromTo(2.5,5),          # Defeat Pokemon
            valueFromTo(0.5,1),          # Catch Pokemon
            valueFromTo(2,4),            # Activate Abilites
            valueFromTo(2,4),            # Activate Held Items
            valueFromTo(3,6),            # Use Physical Moves
            valueFromTo(3,6),            # Use Special Moves
            valueFromTo(1,2),            # Use Status Moves
            valueFromTo(0.2,0.35),       # Use Battle Items
            valueFromTo(1,2),            # Defear Trainers
            valueFromTo(3,7),            # Lapse Turns
            valueFromTo(0.4,0.65),       # Use Medicine Items
            valueFromTo(1,2),            # UNUSED!
            valueFromTo(80,240,1.5,10),  # Deal Damage
            valueFromTo(0.5,1),          # Land Critical Hits
            valueFromTo(2,4),            # Use STAB Moves
            valueFromTo(1,2),            # Defeat Pokemon Instantly
            valueFromTo(0.4,0.65),       # Use Berries
            valueFromTo(0.5,1),          # UNUSED!
            valueFromTo(3,7),            # Increase Stats
            valueFromTo(0.4,0.65),       # Revive Pokemon
            valueFromTo(1,2),            # Use Healing Moves
            valueFromTo(0.09,0.27),      # Use One-hit KO Moves 
            valueFromTo(1,2),            # Use Hi Priority Moves
            valueFromTo(3,7),            # Decrease Stats
            valueFromTo(1,1.5),          # Inflict Conditions            
            valueFromTo(1,2),            # Use Moves with Effects
            valueFromTo(0.4,0.65),       # Use Copycat Moves
            valueFromTo(20,60,1.5,10),   # Take Recoil Damage
            valueFromTo(40,120,1.5,10),  # Recover HP
            valueFromTo(1.5,3),          # Land Super Effective
            valueFromTo(1,2),            # Use Multi-hit Moves
            valueFromTo(0.5,1),          # Defeat Best Trainers
            valueFromTo(0.2,0.4),        # Use Sleeping Moves
            valueFromTo(600,1400,1,10),  # Gain Money
            valueFromTo(1.5,3),          # Land Not Very Effective
            valueFromTo(1,2),            # Use Mutli-Target Moves
            valueFromTo(3,6),            # Activate Win Streak
            valueFromTo(0.5,1),          # Change Forms
            valueFromTo(20,30,0,5),      # Gain Levelup Stats
            valueFromTo(3,6),            # Gain Effort Values
            valueFromTo(0.5,1),          # Learn Moves in Battle
            valueFromTo(1,2),            # Break the Mold
            valueFromTo(1,2),            # Use Lo Priority Moves
            valueFromTo(1,2),            # Defeat Skilled Pokemon
            valueFromTo(5,10,0,5),       # Restore PP
            valueFromTo(1,2),            # Use Sound-based Moves
            valueFromTo(0.4,0.65),       # Supercharge Pokemon
            valueFromTo(0.4,0.65),       # Use Transform
            valueFromTo(0.5,0.8),        # Use any Item
            valueFromTo(2,4),            # Use Perfect Moves
            valueFromTo(1,2),            # Use Variable Moves
            valueFromTo(0.3,0.5),        # Create Substitutes
            valueFromTo(1,2),            # Use Shadow Moves
            valueFromTo(0.5,1),          # Defeat Full Trainers
            valueFromTo(1,2),            # Defeat same-color Pokemon
            valueFromTo(0.4,0.65),       # Confuse or Infatuate
            valueFromTo(0.06,0.15),      # Collect Lucky Bags
            valueFromTo(0.06,0.15),      # Use Elder Special Moves
            valueFromTo(200,600,6,10),   # Gain Experience/TB
            valueFromTo(1,1.5),          # Level Up Pokemon/TB
            valueFromTo(2.5,5),          # Defeat Pokemon/TB
            valueFromTo(80,240,1.5,10),  # Deal Damage/TB
            valueFromTo(1.5,3),          # Land Super Effective/TB
            valueFromTo(1.5,3),          # Land Not Very Effective/TB
            valueFromTo(3,6),            # Use Physical Moves/TB
            valueFromTo(3,6),            # Use Special Moves/TB
            valueFromTo(1,2),            # Use Status Moves/TB
            valueFromTo(20,30,0,5),      # Gain Levelup Stats/TB
            valueFromTo(3,6),            # Gain Effort Values/TB
            valueFromTo(3,6),            # Use Normal Moves
            valueFromTo(3,6),            # Use Normal Moves/TB
            valueFromTo(3,6),            # Use G-F-W Moves
            valueFromTo(3,6),            # Use G-F-W/TB
            valueFromTo(0.2,0.4),        # Catch Skilled Pokemon
            valueFromTo(0.5,1),          # Defeat Skilled Pokemon Inst.
            valueFromTo(0.2,0.4),        # Defeat Full Skilled Trainers
            ][num]

  end

  def taskLevel(idx=-1) # idx is used to identify if the current active task is hard
    return 0 if (currentStep%4 != idx && idx != -1)
    vals = [valueFromToMiddle(200,600,6,10),   # Gain Experience
            valueFromToMiddle(1,1.5),          # Level Up Pokemon
            valueFromToMiddle(2.5,5),          # Defeat Pokemon
            valueFromToMiddle(0.5,1),          # Catch Pokemon
            valueFromToMiddle(2,4),            # Activate Abilites
            valueFromToMiddle(2,4),            # Activate Held Items
            valueFromToMiddle(3,6),            # Use Physical Moves
            valueFromToMiddle(3,6),            # Use Special Moves
            valueFromToMiddle(1,2),            # Use Status Moves
            valueFromToMiddle(0.2,0.35),       # Use Battle Items
            valueFromToMiddle(1,2),            # Defear Trainers
            valueFromToMiddle(3,7),            # Lapse Turns
            valueFromToMiddle(0.4,0.65),       # Use Medicine Items
            valueFromToMiddle(1,2),            # UNUSED!
            valueFromToMiddle(80,240,1.5,10),  # Deal Damage
            valueFromToMiddle(0.5,1),          # Land Critical Hits
            valueFromToMiddle(2,4),            # Use STAB Moves
            valueFromToMiddle(1,2),            # Defeat Pokemon Instantly
            valueFromToMiddle(0.4,0.65),       # Use Berries
            valueFromToMiddle(0.5,1),          # UNUSED!
            valueFromToMiddle(3,7),            # Increase Stats
            valueFromToMiddle(0.4,0.65),       # Revive Pokemon
            valueFromToMiddle(1,2),            # Use Healing Moves
            valueFromToMiddle(0.09,0.27),      # Use One-hit KO Moves 
            valueFromToMiddle(1,2),            # Use Hi Priority Moves
            valueFromToMiddle(3,7),            # Decrease Stats
            valueFromToMiddle(1,1.5),          # Inflict Conditions            
            valueFromToMiddle(1,2),            # Use Moves with Effects
            valueFromToMiddle(0.4,0.65),       # Use Copycat Moves
            valueFromToMiddle(20,60,1.5,10),   # Take Recoil Damage
            valueFromToMiddle(40,120,1.5,10),  # Recover HP
            valueFromToMiddle(1.5,3),          # Land Super Effective
            valueFromToMiddle(1,2),            # Use Multi-hit Moves
            valueFromToMiddle(0.5,1),          # Defeat Best Trainers
            valueFromToMiddle(0.2,0.4),        # Use Sleeping Moves
            valueFromToMiddle(600,1400,1,10),  # Gain Money
            valueFromToMiddle(1.5,3),          # Land Not Very Effective
            valueFromToMiddle(1,2),            # Use Mutli-Target Moves
            valueFromToMiddle(3,6),            # Activate Win Streak
            valueFromToMiddle(0.5,1),          # Change Forms
            valueFromToMiddle(20,30,0,5),      # Gain Levelup Stats
            valueFromToMiddle(3,6),            # Gain Effort Values
            valueFromToMiddle(0.5,1),          # Learn Moves in Battle
            valueFromToMiddle(1,2),            # Break the Mold
            valueFromToMiddle(1,2),            # Use Lo Priority Moves
            valueFromToMiddle(1,2),            # Defeat Skilled Pokemon
            valueFromToMiddle(5,10,0,5),       # Restore PP
            valueFromToMiddle(1,2),            # Use Sound-based Moves
            valueFromToMiddle(0.4,0.65),       # Supercharge Pokemon
            valueFromToMiddle(0.4,0.65),       # Use Transform
            valueFromToMiddle(0.5,0.8),        # Use any Item
            valueFromToMiddle(2,4),            # Use Perfect Moves
            valueFromToMiddle(1,2),            # Use Variable Moves
            valueFromToMiddle(0.3,0.5),        # Create Substitutes
            valueFromToMiddle(1,2),            # Use Shadow Moves
            valueFromToMiddle(0.5,1),          # Defeat Full Trainers
            valueFromToMiddle(1,2),            # Defeat same-color Pokemon
            valueFromToMiddle(0.4,0.65),       # Confuse or Infatuate
            valueFromToMiddle(0.06,0.15),      # Collect Lucky Bags
            valueFromToMiddle(0.06,0.15),      # Use Elder Special Moves
            valueFromToMiddle(200,600,6,10),   # Gain Experience/TB
            valueFromToMiddle(1,1.5),          # Level Up Pokemon/TB
            valueFromToMiddle(2.5,5),          # Defeat Pokemon/TB
            valueFromToMiddle(80,240,1.5,10),  # Deal Damage/TB
            valueFromToMiddle(1.5,3),          # Land Super Effective/TB
            valueFromToMiddle(1.5,3),          # Land Not Very Effective/TB
            valueFromToMiddle(3,6),            # Use Physical Moves/TB
            valueFromToMiddle(3,6),            # Use Special Moves/TB
            valueFromToMiddle(1,2),            # Use Status Moves/TB
            valueFromToMiddle(20,30,0,5),      # Gain Levelup Stats/TB
            valueFromToMiddle(3,6),            # Gain Effort Values/TB
            valueFromToMiddle(3,6),            # Use Normal Moves
            valueFromToMiddle(3,6),            # Use Normal Moves/TB
            valueFromToMiddle(3,6),            # Use G-F-W Moves
            valueFromToMiddle(3,6),            # Use G-F-W/TB
            valueFromToMiddle(0.2,0.4),        # Catch Skilled Pokemon
            valueFromToMiddle(0.5,1),          # Defeat Skilled Pokemon Inst.
            valueFromToMiddle(0.2,0.4),        # Defeat Full Skilled Trainers

            ][taskID]
    if taskstatus2 > vals[2] && (boxLevel>1 || currentBoxDif>0)     # Ultra Hard Task
      return 3
    elsif taskstatus2 > vals[1] && (boxLevel>1 || currentBoxDif>0)  # Super Hard Task
      return 2
    elsif taskstatus2 > vals[0] && (boxLevel>0 || currentBoxDif>0)  # Hard Task
      return 1
    else                                                            # Normal Task
      return 0
    end
  end


  

  def isHardTask(idx=-1) # idx is used to identify if the current active task is hard
    return taskLevel(idx) > 0
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
    # Tasks that will be excluded from the boxes
    tasksToExclude=[]
    tasksToExclude.push(19) # Not applicable
    $game_variables[PBOX_VARIABLES[6]] = [] if  !$game_variables[PBOX_VARIABLES[6]].is_a?(Array)
    data = $game_variables[PBOX_VARIABLES[6]]
    # Level 4 and above boxes cannot contain these
    tasksToExclude.push(3,4,5,12,15,16,18,20,22,25,26,27,30,32,35,37,45,46,47,50,51,52,56) if boxLevel>3
    if data==[] || ((data.inject { |sum, n| sum + n }) / data.length)< 50
      # Level 3 and above boxes cannot contain these
      tasksToExclude.push(0,1,2,6,7,8,14,31,36,40,41,71,73) if boxLevel>2
      # No box can contain these
      tasksToExclude.push(60,61,62,63,64,65,66,67,68,69,70,72,74)
    else
      # Level 2 and above boxes cannot contain these
      tasksToExclude.push(0,1,2,6,7,8,14,31,36,40,41,71,73) if boxLevel>1
      # Only Level 2 boxes can contain these
      tasksToExclude.push(60,61,62,63,64,65,66,67,68,69,70,72,74) if boxLevel!=2
    end
    # Level 2 and below boxes cannot contain these
    tasksToExclude.push(76,77) if boxLevel<3 && currentBoxDif==0
    # Level 1 and below boxes cannot contain these
    tasksToExclude.push(9,13,20,21,22,23,25,26,32,34,39,45,46,47,48,49,56,57,58,59,75) if boxLevel<2  && currentBoxDif==0
    # Level 0 and below boxes cannot contain these
    tasksToExclude.push(3,5,19,24,27,28,29,30,33,35,37,40,41,42,43,44,52,53,54,55,73) if boxLevel<1  && currentBoxDif==0
    # List of items that will enable the supercharge task
    supercharger=false
    mRINGS = [:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM,:DYNAMAXBAND] 
    for i in mRINGS
      next if !hasConst?(PBItems,i)
      if $PokemonBag.pbQuantity(i)>0
        supercharger=true
        break
      end
    end
    tasksToExclude.push(48) if !supercharger # Never when not having it
    tasksToExclude.push(13) if !$PokemonGlobal.upperKingdom
    # Disable "Use Elder Special Moves" when Elder Special Move tutorial isn't done
    tasksToExclude.push(59) if !$game_switches[174]
    # Disable "Use Shadow Moves" when shadow type isn't defined
    tasksToExclude.push(54) if !hasConst?(PBTypes,:SHADOW)
    tasksToExclude.push(3,10,19,23,29,33,34,35,38,42,48,54,55,58,59,60,61,62,63,64,65,66,67,68,69,70,72,74,75,76,77) if $flint_brockopolis_active
    # Group 0
    task0 = [0,1,2,14,20,25,30,35,40,45,60,61,62,63,69]
    task0.delete_if {|element| tasksToExclude.include?(element) }
    # Group 1
    task1 = [3,4,5,15,21,26,31,36,41,46,64,65,70,75]
    task1.delete_if {|element| tasksToExclude.include?(element) }
    # Group 2
    task2 = [6,7,8,16,22,27,32,37,42,47,66,67,68,71,72,73,74]
    task2.delete_if {|element| tasksToExclude.include?(element) }
    # Group 3
    task3 = [9,10,11,17,23,28,33,38,43,48,76]
    task3 = [] if boxLevel>2 # Handled elsewhere
    task3.delete_if {|element| tasksToExclude.include?(element) }
    # Universal Tasks 0
    taskU0=[12,18,29,34,50,51,52,56,57] # 19 is not applicable in Q.Qore
    taskU0=[] if boxLevel>2 # Handled elsewhere
    taskU0.delete_if {|element| tasksToExclude.include?(element) }
    # Universal Tasks 1
    taskU1=[13,24,39,44,49,53,54,55,58,59,77]
    taskU1=[] if boxLevel>2 # Handled Elsewhere
    taskU1.delete_if {|element| tasksToExclude.include?(element) }
    # Universal Tasks for Millenial/Elite/Level 3 Boxes
    if boxLevel>2
      taskU0_1 = [9,10,11,12,13,17,18,23,24,28,29,33,34,38,39,43,44,48,49,50,51,52,53,54,55,56,57,58,59,76,77]
      taskU0_1.delete_if {|element| tasksToExclude.include?(element) }
      taskU0_1.shuffle! # Required for the 
      j=0
      for i in taskU0_1 # 13 and 19 are not applicable in Q.Qore
        if j%2==0
          taskU0.push(i)
        else
          taskU1.push(i)
        end
        j+=1
      end
    end
    # Set Up Tasks
    if boxLevel<2
      choices0= task0 | task1 | task2 | task3 | taskU0 | taskU1
      choices1=choices0
      choices0.shuffle!
      choices1.shuffle!
      choices1Offset=12
    else
      choices0= task0 | task1 | task2 | taskU0
      choices1=task3 | taskU1
      choices0.shuffle!
      choices1.shuffle!
      choices1Offset=0
    end
    length0=choices0.length
    length1=choices1.length
    $game_variables[PBOX_VARIABLES[0]]=0
    $game_variables[PBOX_VARIABLES[4]]=0
    $game_variables[PBOX_VARIABLES[1]] = [
      # Task #0
      [choices0[0%length0],$PokemonGlobal.pokebox[choices0[0%length0]],taskVals(choices0[0%length0])],
      [choices0[4%length0],$PokemonGlobal.pokebox[choices0[4%length0]],taskVals(choices0[4%length0])],
      [choices0[8%length0],$PokemonGlobal.pokebox[choices0[8%length0]],taskVals(choices0[8%length0])],
      [choices1[(choices1Offset+0)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+0)%length1]],taskVals(choices1[(choices1Offset+0)%length1])],
      # Task #1
      [choices0[1%length0],$PokemonGlobal.pokebox[choices0[1%length0]],taskVals(choices0[1%length0])],
      [choices0[5%length0],$PokemonGlobal.pokebox[choices0[5%length0]],taskVals(choices0[5%length0])],
      [choices0[9%length0],$PokemonGlobal.pokebox[choices0[9%length0]],taskVals(choices0[9%length0])],
      [choices1[(choices1Offset+1)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+1)%length1]],taskVals(choices1[(choices1Offset+1)%length1])],      
      # Task #2
      [choices0[2%length0],$PokemonGlobal.pokebox[choices0[2%length0]],taskVals(choices0[2%length0])],
      [choices0[6%length0],$PokemonGlobal.pokebox[choices0[6%length0]],taskVals(choices0[6%length0])],
      [choices0[10%length0],$PokemonGlobal.pokebox[choices0[10%length0]],taskVals(choices0[10%length0])],
      [choices1[(choices1Offset+2)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+2)%length1]],taskVals(choices1[(choices1Offset+2)%length1])],      
      # Task #3
      [choices0[3%length0],$PokemonGlobal.pokebox[choices0[3%length0]],taskVals(choices0[3%length0])],
      [choices0[7%length0],$PokemonGlobal.pokebox[choices0[7%length0]],taskVals(choices0[7%length0])],
      [choices0[11%length0],$PokemonGlobal.pokebox[choices0[11%length0]],taskVals(choices0[11%length0])],
      [choices1[(choices1Offset+3)%length1],$PokemonGlobal.pokebox[choices1[(choices1Offset+3)%length1]],taskVals(choices1[(choices1Offset+3)%length1])]      
                                          ]
    pbTimeEvent(PBOX_VARIABLES[3],boxDuration*86400)
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
    # Draw Task Icons
    progress.push(["Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_progress_small",@sprites["progress"].x,@sprites["progress"].y,0,0,-1,-1])
    progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_small",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*1.98).floor,-1])
    progress.push(["Graphics/UI/Pokemon Box/icons",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*$game_variables[PBOX_VARIABLES[1]][currentStep][0],34,34])
    progress.push(["Graphics/UI/Pokemon Box/icon_"+@icons[stepID],@sprites["progress_icon"].x,@sprites["progress_icon"].y,0,0,-1,-1])
    progress.push(["Graphics/UI/Pokemon Box/icon_markings",@sprites["progress_icon"].x+26,@sprites["progress_icon"].y+10,0,36*taskLevel(-1),36,36])
    # Draw Time Left graphics
    progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
      progressTime.push(["Graphics/UI/Pokemon Box/icon_clock",@sprites["progresstime"].x-28,@sprites["progresstime"].y-6,0,0,-1,-1])
    x = 116 - ([(boxItems.length - 1),4].min * 24)
    multiamt = 1
    multiamt = 2 if @milestoneDay && boxLevel>0
    for i in boxItems
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
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
      hardBase=[Color.new(248,32,244),
                Color.new(32,118,248),
                Color.new(248,56,32)]
      hardShadow=[Color.new(224,144,222),
                  Color.new(144,176,224),
                  Color.new(224,152,144)]
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      hardBase=[Color.new(224,144,222),
                Color.new(144,176,224),
                Color.new(224,152,144)]
      hardShadow=[Color.new(248,32,244),
                  Color.new(32,118,248),
                  Color.new(248,56,32)]
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end

    numberbase=(isHardTask()) ? hardBase[taskLevel() - 1] : baseColor
    numbershadow=(isHardTask()) ? hardShadow[taskLevel() - 1] : shadowColor

    textpos=[
       [_INTL("{1}/{2}",[taskstatus,taskstatus2].min,taskstatus2),(Graphics.width/4)-39+15,40,2,base2,shadow2,true],
    ]
    pbDrawShadowText(@sprites["overlayTask"].bitmap,0,0,(Graphics.width / 2)-28,38,taskname,numberbase,numbershadow,1)
    textposTime=[
       [_INTL("Time Remaning"),(Graphics.width/4),294,2,baseColor,shadowColor],
       [_INTL("{1}",pbTimeEventRemainingTime(PBOX_VARIABLES[3])),(Graphics.width/4)+15,330,2,base2,shadow2,true],
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
    @sprites["header"].text=_INTL("{1} Pokémon Box - Win Streak: {2}",boxName, currentStreak)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/bg_{1}{2}",currentStage(false),stageSuffix))
    #@sprites["bgM"].visible=@milestoneDay
    @sprites["machine"].setBitmap(_INTL("Graphics/UI/Pokemon Box/overlay_box_{1}{2}",currentStage(false),stageSuffix))
    update_icons
    if showMillenialMessage
      if isMillenial?
        Kernel.pbMessage(_INTL("{1} Milestone Ahead!",boxName(true)))
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
      oldtasklevel = taskLevel(oldstep)
      $game_variables[PBOX_VARIABLES[0]]+=1
      $game_variables[PBOX_VARIABLES[4]]=0 # Reset Substep
      update_icons(true)
      if oldtasklevel == 3
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Ultra Hard Task Completed and you've got rewards."))
        quantity = (boxLevel+(4*currentBoxDif))*2
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
        quantity2 = (boxLevel+(4*currentBoxDif)) - 1
        Kernel.pbReceiveItem(:EXPCANDYS,quantity2)
      elsif oldtasklevel == 2
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Super Hard Task Completed and you've got rewards."))
        quantity = (boxLevel+(4*currentBoxDif))*2
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
        quantity2 = (boxLevel+(4*currentBoxDif)) - 1
        Kernel.pbReceiveItem(:EXPCANDYXS,quantity2)
      elsif oldtasklevel == 1
        pbSEPlay("Battle effect critical")
        Kernel.pbMessage(_INTL("Hard Task Completed and you've got a reward."))
        quantity = (boxLevel+(4*currentBoxDif))
        item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][oldstep]
        Kernel.pbReceiveItem(item,quantity)
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
        multiamt = 2 if @milestoneDay && boxLevel>0
        for i in boxItems
          if i.is_a?(Array)
            item=i[0]
            amt=i[1]*multiamt
          else
            item=i
            amt=1*multiamt
          end
          Kernel.pbReceiveItem(item,amt)
        end
        oldstreak = currentStreak
        oldstage  = currentStage
        $game_variables[PBOX_VARIABLES[2]]+=1
        $game_variables[PBOX_VARIABLES[2]]=0 if oldstreak == 65535
        stage=boxName() rescue ""
        if oldstreak == 65535
          pbSEPlay("Battle effect message")
          Kernel.pbMessage(_INTL("Extraodinary! You've maxed out the Pokémon Box. You'll get a special prize."))
          Kernel.pbReceiveItem(:MASTERBALL,5*multiamt)
        end
            scene=PokemonBoxSummaryScene.new
            screen=PokemonBoxSummary.new(scene)
            pbFadeOutIn(99999) { 
              screen.pbStartScreen(oldstage,currentStage)
            }
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
    multiamt = 1
    multiamt = 2 if @milestoneDay && boxLevel>0
    for i in boxItems
      idx+=1
      if idx == 1 || idx == boxItems.length
        y = 70
      else
        y = 54
      end
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
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
    @sprites["task0"].bitmap.hue_change(getTaskHue(0,nohardmarkers))
    @sprites["task1"].visible= true
    @sprites["task1"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[1],getTaskLabel(1,nohardmarkers)))
    @sprites["task1"].bitmap.hue_change(getTaskHue(1,nohardmarkers))
    @sprites["task2"].visible= true
    @sprites["task2"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[2],getTaskLabel(2,nohardmarkers)))
    @sprites["task2"].bitmap.hue_change(getTaskHue(2,nohardmarkers))
    @sprites["task3"].visible= true
    @sprites["task3"].setBitmap(_INTL("Graphics/UI/Pokemon Box/icon_{1}{2}",@icons[3],getTaskLabel(3,nohardmarkers)))
    @sprites["task3"].bitmap.hue_change(getTaskHue(3,nohardmarkers))
  end
  
  def changeBoxTask
    maxtimes = ($game_variables[PBOX_VARIABLES[1]].length/4).floor - 1
    availabletimes = maxtimes - $game_variables[PBOX_VARIABLES[4]]
    extratext = (taskstatus==0) ? "" : _INTL(" Any progress done on this one will be lost.")
    if $game_variables[PBOX_VARIABLES[4]]>=maxtimes
      Kernel.pbMessage(_INTL("You can't change this task any longer."))
    elsif Kernel.pbConfirmMessage(_INTL("Are you sure you want to change this task? You can change it {1} times.{2}",availabletimes,extratext))
      $game_variables[PBOX_VARIABLES[4]]+=1
      refreshTask
    end
  end
  
  def showTaskInfo
    Kernel.pbMessage(_INTL("\\l[2]{1}",$PokemonGlobal.pokeboxDescriptions[ $game_variables[PBOX_VARIABLES[1]][currentStep][0] ]))
    if taskLevel() == 3
      quantity = (boxLevel+(4*currentBoxDif))*2
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      quantity2 = (boxLevel+(4*currentBoxDif)) - 1
      itemname2 = (quantity2>1) ? PBItems.getNamePlural(PBItems::EXPCANDYS) : PBItems.getName(PBItems::EXPCANDYS)
      Kernel.pbMessage(_INTL("Completing this Ultra Hard task gives you {1} {2} and {3} {4}.", quantity, itemname, quantity2, itemname2))
    elsif taskLevel() == 2
      quantity = (boxLevel+(4*currentBoxDif))*2
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      quantity2 = (boxLevel+(4*currentBoxDif)) - 1
      itemname2 = (quantity2>1) ? PBItems.getNamePlural(PBItems::EXPCANDYXS) : PBItems.getName(PBItems::EXPCANDYXS)
      Kernel.pbMessage(_INTL("Completing this Super Hard task gives you {1} {2} and {3} {4}.", quantity, itemname, quantity2, itemname2))
    elsif taskLevel() == 1
      quantity = (boxLevel+(4*currentBoxDif))
      item     = [PBItems::REDSHARD,PBItems::YELLOWSHARD,PBItems::BLUESHARD,PBItems::GREENSHARD][currentStep%4]
      itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
      Kernel.pbMessage(_INTL("Completing this Hard task gives you {1} {2}.", quantity, itemname))
    end
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
          taskrect=[4,196,(Graphics.width/2)-8,82]
          if contains2(taskrect,mousepos[0],mousepos[1])
            showTaskInfo
          end
          # Time Pane
          taskrect2=[4,290,(Graphics.width/2)-8,82]
          if contains2(taskrect2,mousepos[0],mousepos[1])
            Kernel.pbMessage(_INTL("Keep an eye on the time. If the time expires, your win streak resets and you'll start over with a {1} box.",@stages[0][0]))
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

  def pbStartScene(oldlevel=-1,newlevel=-1) # OLd level = Last stage | New level = Current Stage
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Pokemon Box/bg_menu",@viewport)
    @sprites["bgM"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
    @sprites["bgM"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokemon Box/overlay_milestone_full"))
    @sprites["bgM"].opacity= 96
    @sprites["bgM"].visible=$PokemonBox.milestoneDay
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
    elite=$PokemonBox.currentStage(false) != $PokemonBox.currentStage
    @currentStage=( (oldlevel != -1) && (newlevel>oldlevel) && !elite) ? oldlevel : $PokemonBox.currentStage
    @maxpages=($PokemonBox.stages.length / 8.0).ceil - 1
    @page=((@currentStage+1) / 8.0).ceil - 1
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
    for item in 0...8
      x=[4,324,4,324,4,324,4,324][item%8]
      y=[36,36,126,126,216,216,306,306][item%8]
      @sprites["boxname#{item}"]=Window_AdvancedTextPokemon.newWithSize("",x-3,y-13,128,64,@viewport)
      @sprites["boxname#{item}"].windowskin=nil
      @sprites["boxname#{item}"].z=2
      @sprites["box#{item}"]=IconSprite.new(x+10,y+13,@viewport)
      @sprites["box#{item}"].setBitmap("")
      @sprites["box#{item}"].visible=false
      @sprites["box#{item}"].z=3
      @sprites["padlock#{item}"]=IconSprite.new(x+33,y+9,@viewport)
      @sprites["padlock#{item}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menuwrapper_locked")
      @sprites["padlock#{item}"].visible=false
      @sprites["padlock#{item}"].z=4
    end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawPokemonBoxSummaryContents
    pbFadeInAndShow(@sprites) { update }
    if (oldlevel != -1) && (newlevel>oldlevel) && !elite
      # Close previous level
      pbSEPlay("King's Shield")
      @sprites["boxname#{oldlevel%8}"].text="<ac>"+$PokemonBox.stages[oldlevel][0]+"</ac>"
      @sprites["box#{oldlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + oldlevel.to_s + "_closed")
      @sprites["padlock#{oldlevel%8}"].visible=false
      40.times do
        Graphics.update
      end
      # Switch to new page, if needed
      oldpage=@page
      newpage=((newlevel+1) / 8.0).ceil - 1
      @page=[oldpage,newpage].max
      pbDrawPokemonBoxSummaryContents if @page != oldpage # Redraw contents
      # Unlock new box
      pbSEPlay("Battle effect message")
      @sprites["padlock#{newlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menuwrapper_locked_2")
      20.times do
        Graphics.update
      end
      opa=255
      20.times do
        Graphics.update
        opa-=255/20
        @sprites["padlock#{newlevel%8}"].opacity=opa
      end
      @sprites["boxname#{newlevel%8}"].text=""
      @sprites["box#{newlevel%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + newlevel.to_s)
      @sprites["padlock#{newlevel%8}"].visible=false
      40.times do
        Graphics.update
      end
    elsif (oldlevel != -1) && (newlevel != -1) && (newlevel >= $PokemonBox.stages.length-5)
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("Spectacular! Keep completing out {1} Pokémon Boxes.",$PokemonBox.boxName()))
    elsif (oldlevel != -1) && (oldlevel>newlevel) && !elite
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("You made it! Let's start over from the {1} Pokémon Box.",$PokemonBox.boxName()))
    elsif (oldlevel != -1) && (oldlevel==newlevel) && !elite
      pbSEPlay("Battle effect message")
      Kernel.pbMessage(_INTL("Awesome! Let's continue with another {1} Pokémon Box.",$PokemonBox.boxName()))
    end
  end

  def pbDrawPokemonBoxSummaryContents
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"].visible = @page != @maxpages
    @overlay=@sprites["overlay"].bitmap
    @overlay.clear
    offset=8*@page
    for item in 0+offset...8+offset
      x=[4,324,4,324,4,324,4,324][item%8]
      y=[36,36,126,126,216,216,306,306][item%8]
      pbDrawBoxContents(x,y,item)
    end
  end

  def pbDrawBoxContents(x,y,stage)
    if stage >= $PokemonBox.stages.length
      @sprites["boxname#{stage%8}"].text=""
      @sprites["box#{stage%8}"].setBitmap("")
      @sprites["padlock#{stage%8}"].visible=false
      return
    end
    filename=stage.to_s
    filename=($PokemonBox.maxStages-1).to_s + "_elite" if stage==$PokemonBox.maxStages
    filename=($PokemonBox.maxStages-1).to_s + "_legendary" if stage==$PokemonBox.maxStages + 1
    filename=($PokemonBox.maxStages-1).to_s + "_mythical" if stage==$PokemonBox.maxStages + 2
    filename=($PokemonBox.maxStages-1).to_s + "_demon" if stage==$PokemonBox.maxStages + 3
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
    boxitems=$PokemonBox.boxItems(stage)
    # Items
    itemx = 182 - ([(boxitems.length - 1),3].min * 24)
    multiamt = 1
    multiamt = 2 if $PokemonBox.milestoneDay && $PokemonBox.stages[stage][4]>0
    for i in boxitems
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]*multiamt
      else
        item=i
        amt=1*multiamt
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
      itemx+=(96.0/[(boxitems.length - 1),3].max)*1.5
    end
    # Box Name
    @sprites["box#{stage%8}"].visible=true
    if @currentStage == stage
      @sprites["boxname#{stage%8}"].text=""
      @sprites["box#{stage%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + filename)
      @sprites["padlock#{stage%8}"].visible=false
    else
      @sprites["boxname#{stage%8}"].text="<ac>"+$PokemonBox.stages[stage][0]+"</ac>"
      @sprites["box#{stage%8}"].setBitmap("Graphics/UI/Pokemon Box/overlay_menubox_" + filename + "_closed")
      @sprites["padlock#{stage%8}"].visible=@currentStage<stage
    end
    pbDrawImagePositions(@overlay,imagepos)
    pbSetSmallFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@overlay,imageposAMT)

  end

  def pbPokemonBoxSummaryScreen(oldlevel=-1,newlevel=-1)
    briefmode=(oldlevel != -1) && (newlevel != -1)
    loop do
      Graphics.update
      Input.update
      self.update
      break if briefmode
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

  def pbStartScreen(oldlevel=-1,newlevel=-1)
    @scene.pbStartScene(oldlevel,newlevel)
    @scene.pbPokemonBoxSummaryScreen(oldlevel,newlevel)
    @scene.pbEndScene
  end
end