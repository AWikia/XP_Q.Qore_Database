class ChallengeButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    fembutton=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/pokegear_button_f"))
    if $Trainer.isFemale? && fembutton
      @button=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/pokegear_button_f")
    else
      @button=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/pokegear_button")
    end
    @button2=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/linkgearSelection")
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @button2.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    self.bitmap.blt(0,0,@button2.bitmap,Rect.new(0,0,@button2.width,@button2.height))
    pbSetSystemFont(self.bitmap)
    base=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    shadow=(isDarkMode?) ? Color.new(40,40,40) : Color.new(160,160,160,160)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,self.bitmap.width/2,10,2,base,shadow],
       [@name,self.bitmap.width/2,62,2,base,shadow]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
    icon=sprintf("Graphics/UI/Challenge/icon_"+@name)
    imagepos=[         # Icon is put on both unselected and selected buttons
       [icon,18,10,0,0,-1,-1],
       [icon,18,62,0,0,-1,-1]
    ]
    pbDrawImagePositions(self.bitmap,imagepos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    super
  end
end



#===============================================================================
#- Scene_Challenge
#-------------------------------------------------------------------------------
# By Qora Qore Telecommunities
# Based on  Scene_Pokegear
#===============================================================================
class Scene_ChallengeScene
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def pbStartScene(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def pbChallengeScreen
    @sprites={}
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdBegin=-1
    @cmdHelp=-1
    commands[@cmdBegin=commands.length]=_INTL("Begin Quest")
    commands[@cmdHelp=commands.length]=_INTL("Help")
    
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new(62,97,248,Graphics.height-190)
    @viewport2.z=99999
    @button=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/pokegearButton")
    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Challenge/bg_f"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Challenge/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Challenge/bg",@viewport)
    end
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay2"]=BitmapSprite.new(248,Graphics.height - 134,@viewport2)
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Challenge"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    for i in 0...commands.length
      x=342
      y=190 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=ChallengeButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
    end
    # Lottery Check
    lottery_check
    # Lottery Check end
=begin
Quests:
  Each quest must be an array with the following items:
  * 1 = Quest Type (Between Trainer, Triad, TypeQuiz, PushBag, Mining and TilePuzzle(s))
  * 2 = Quest Name
  * 3 = An array containing the parameters
    * For Trainers, three exist (Type, Name, ID)
    * For Triads, four exist (Name, Min Level, Max Level, an array of set species) 
    * For TypeQuiz, two exist (Amount, HardMode?)
    * For PushBag, one exists (Amount of turns)
    * For Mining, it must be nil
    * For TilePuzzle, two exist (PuzzleName, PuzzleMode)
    * For TilePuzzles, four exist (PuzzleName1, PuzzleMode1, two clones for 2nd)
  * 4 = An array containing two items for the condtion text (1st is upper)
  * 5 = A value containg the amount of time required to be done
    * For Mining, it must be nil
=end
    @puzzles=["Kabuto","Aerodactyl","Hooh","Mew","Omanyte",]
    @currentPuzzle = @puzzles[$game_variables[1006].to_i%@puzzles.length]
    @quests = [
      ["Trainer", 
       _INTL("Liquorice Larry Battle"), 
       [:CHAMPION, "Liquorice Larry",5],
       [_INTL("Finish it in under"), _INTL("2 min 20 sec")],
       140],
      ["Triad", 
       _INTL("Mr. Toffee Triad Duel"), 
       ["Mr. Tofee",5,9,[:DEOXYS,:MIRAPLUS,:DURATINO,:AQUOS,:ETERNATUS]],
       [_INTL("Finish it in under"), _INTL("35 sec")],
       180],
      ["TypeQuiz", 
       _INTL("Type Quiz x25"), 
       [25,true],
       [_INTL("Answer correctly at least"), _INTL("20 questions")],
       20],
      ["TypeQuiz", 
       _INTL("Type Quiz x50"), 
       [50,false],
       [_INTL("Answer correctly at least"), _INTL("40 questions")],
       40],
      ["PushBag", 
       _INTL("Push Bag x4"), 
       [4],
       [_INTL("Score at least"), _INTL("15 points")],
       15],
      ["PushBag", 
       _INTL("Push Bag x6"), 
       [6],
       [_INTL("Score at least"), _INTL("25 points")],
       25],
      ["Mining", 
       _INTL("Underground Mining"), 
       nil,
       [_INTL("Find out"), _INTL("All the items")],
       nil],
      ["TilePuzzle", 
       _INTL("Tile Puzzle Alph"), 
       [1,@currentPuzzle],
       [_INTL("Finish it in under"), _INTL("35 sec")],
       35],
      ["TilePuzzle", 
       _INTL("Tile Puzzle Alph Rotator"), 
       [2,@currentPuzzle],
       [_INTL("Finish it in under"), _INTL("1 min")],
       60],
      ["TilePuzzle", 
       _INTL("Tile Puzzle Tile Swap"), 
       [4,@currentPuzzle],
       [_INTL("Finish it in under"), _INTL("35 sec")],
       35],
      ["TilePuzzle", 
       _INTL("TilePuzzle TileSwap Rotator"), 
       [5,@currentPuzzle],
       [_INTL("Finish it in under"), _INTL("1 min")],
       60],
      ["TilePuzzle", 
       _INTL("Tile Puzzle Star Rotator"), 
       [7,@currentPuzzle],
       [_INTL("Finish it in under"), _INTL("35 sec")],
       35],
      ["TilePuzzles", 
       _INTL("Tile Puzzles"), 
       [1,"QoraQore",1,"Evelution"],
       [_INTL("Finish it in under"), _INTL("1 min 10 sec")],
       70]
    ]
    @currentQuest = @quests[$game_variables[1006].to_i%@quests.length]
    update_stats
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
    end
  end
  
  def lottery_check
    pbSetLotteryNumber(1)
    if $game_variables[1] != $game_variables[1006]
      $game_switches[1048] = false
      pbSetLotteryNumber(1006)
    end
  end
  
  def update_stats
# Bottom
    @sprites["overlay"].bitmap.clear
    textpos=[
       [_INTL("Won Challenges: {1}",$game_variables[1005]),Graphics.width-16,354,1,@sprites["header"].baseColor]
    ]
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
# Bottom End
    lottery_check
# Left
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    @sprites["overlay2"].bitmap.clear
    textPositions=[
       [_INTL("--Today's Challenge--"),124,0,2,baseColor,shadowColor],
       [_INTL("{1}", @currentQuest[1]),124,32,2,baseColor,shadowColor],
       [_INTL("--Winning Criteria--"),124,96,2,baseColor,shadowColor],
       [_INTL("{1}", @currentQuest[3][0]),124,128,2,baseColor,shadowColor],
       [_INTL("{1}",@currentQuest[3][1]),124,160,2,baseColor,shadowColor],
    ]
    pbDrawTextPositions(@sprites["overlay2"].bitmap,textPositions)
# Left End
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
    end
    pbUpdateSpriteHash(@sprites)
    #update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end
  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::C)
      if @cmdBegin>=0 && @sprites["command_window"].index==@cmdBegin
        if $game_player.pbHasDependentEvents?
          Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
          return false
        end
        if $game_switches[172]
          Kernel.pbMessage(_INTL("It can't be used during a Museum Mission!"))
          return false
        end
        update_stats
        # Actual Event
        if $game_switches[1048]
          if !Kernel.pbConfirmMessage(_INTL("You've already tried a challenge quest today. Are you sure you want to retry?"))
            return false
          end
        end
        $game_switches[1047]=true
        pass=false
        if @currentQuest[4]
          pbTimeEvent(1011,@currentQuest[4])
        else
          pbTimeEvent(1011,65536)
        end
        if @currentQuest[0] == "Triad"
          @triadCards=[]
          if !$PokemonGlobal
            $PokemonGlobal=PokemonGlobalMetadata.new
          end
          count=0
          for i in 0...$PokemonGlobal.triads.length
            item=$PokemonGlobal.triads[i]
            ItemStorageHelper.pbStoreItem(@triadCards,
               $PokemonGlobal.triads.maxSize,
               $PokemonGlobal.triads.maxPerSlot,
               item[0],item[1]
            )
            count+=item[1] # Add item count to total count
          end
          if count<5
            Kernel.pbMessage(_INTL("You can't do this challenge yet as you don't have enough triad cards."))
            return false
          end
          pass=pbTriadDuel(@currentQuest[2][0],@currentQuest[2][1],@currentQuest[2][2],["nocardgainloss"],@currentQuest[2][3])==1 &&
              !pbTimeEventValid(1011)
        elsif @currentQuest[0] == "TypeQuiz"
          pass=TypeQuiz.scene(@currentQuest[2][0],@currentQuest[2][1])>=@currentQuest[4]
        elsif @currentQuest[0] == "PushBag"
          pass=pbPunchBag(@currentQuest[2][0], false, true)>=@currentQuest[4]
        elsif @currentQuest[0] == "Mining"
          pass=pbMiningGame
        elsif @currentQuest[0] == "TilePuzzle"
          pass=pbTilePuzzle(@currentQuest[2][0],@currentQuest[2][1]) &&
              !pbTimeEventValid(1011)
        elsif @currentQuest[0] == "TilePuzzles"
          pass=pbTilePuzzle(@currentQuest[2][0],@currentQuest[2][1]) &&
               pbTilePuzzle(@currentQuest[2][2],@currentQuest[2][3]) && 
              !pbTimeEventValid(1011)
        else # Trainer
          $PokemonGlobal.nextBattleBack="Intro"
          pass=pbTrainerBattle(@currentQuest[2][0],@currentQuest[2][1],_I("Qust Completed!!!"),false,@currentQuest[2][2],true,0) && 
              !pbTimeEventValid(1011)
        end
        # Quest Ending
        if pass
          if $game_switches[1048]
            update_stats
            Kernel.pbMessage(_INTL("As you've already tried a Challenge Mission for today, you'll get a weaker price."))
            Kernel.pbReceiveItem([:SWEETCANDY,:SOURCANDY,:SPICYCANDY][rand(3)])
            Kernel.pbMessage(_INTL("And continue working hard."))
          else
            $game_variables[1005] += 1
            update_stats
            Kernel.pbMessage(_INTL("\\me[EvolutionSuccess_1]Congratulations, you've won a challenge mission. Incredible work \\PN!!"))
            Kernel.pbMessage(_INTL("As you've finished a Challenge Mission for today, you'll get a premium price."))
            Kernel.pbReceiveItem(PBItems::VICIOUSCANDY)
            Kernel.pbMessage(_INTL("And continue working hard."))
          end
        else
          update_stats
          if $game_switches[1048]
            Kernel.pbMessage(_INTL("Even though you didn't tried harder and faster, things won't matter today."))
          else
            Kernel.pbMessage(_INTL("\\me[EvolutionCancelled]Well, you need to try out harder and faster. Better luck next day."))
          end
        end
        Kernel.pbMessage(_INTL("See you tomorrow."))
        $game_switches[1047]=false
        $game_switches[1048]=true
      end
      if @cmdHelp>=0 && @sprites["command_window"].index==@cmdHelp
        @QQSR="\\l[9]"
        @QQSR+=_INTL("Only trainers who have beaten the Elite Four in its nightmare team can use this app.")
        @QQSR+=_INTL("\\nFor each day, you'll be given a random challenging task to be done in a specific amount of time or progression.")
        @QQSR+=_INTL("\\nFinishing it on the first try will award you a Vicious Candy while on subsequent ones a weaker candy")
        @QQSR+=_INTL("\\nA specific task can be given again on another day so try to practise as much as you want.")
        @QQSR+=_INTL("\\nGood Luck.")
        Kernel.pbMessage(@QQSR)
      end
      return
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  

end

class Scene_Challenge
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbChallengeScreen
    @scene.pbEndScene
  end
end