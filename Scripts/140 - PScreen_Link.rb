class LinkBattleButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    @button=AnimatedBitmap.new("Graphics/Pictures/"+getAccentFolder+"/linkButton")
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,self.bitmap.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,self.bitmap.width/2,62,2,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
    icon=sprintf("Graphics/Pictures/link"+@name)
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
#- Scene_LinkBattle
#-------------------------------------------------------------------------------
# By Qora Qore Telecommunities
# Based on  Scene_Pokegear
#===============================================================================
class Scene_LinkBattle
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdLink=-1
    @cmdLinkG=-1
    @cmdLinkP=-1
    @cmdLinkS=-1
    commands[@cmdLink=commands.length]=_INTL("Local Battle")
    commands[@cmdLinkG=commands.length]=_INTL("Versus Q.Qore")
    commands[@cmdLinkP=commands.length]=_INTL("Versus Prograda")
    commands[@cmdLinkS=commands.length]=_INTL("Marketplace")
    
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/"+getAccentFolder+"/linkButton")
    @sprites={}
    @sprites["background"] = IconSprite.new(0,0)
    @sprites["background"].setBitmap("Graphics/Pictures/linkbg")
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    for i in 0...commands.length
      x=118+64
      y=196 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=LinkBattleButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
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
    if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
      pbPlayCancelSE()
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::X) # Help
      @QQSR="\\l[9]\\c[8]\\w[TrophyWindow]"
      @QQSR+="Choose any of the three modes present. Local Battles is you vs. an opponent with random Pokemon while the other uses communication with another player."
      @QQSR+="\\nFor local play, you can select the difficulty you want to use."
      @QQSR+="\\nThere's no time limit and no Pokemon limitations in any of the game modes"
      @QQSR+="\\nPokemon levels for local play depends on your Pokemon's levels."
      @QQSR+="\\nThe winner will be awarded with Battle Link points. Winning your first Link Battle will award the Battle Linker trophy."
      Kernel.pbMessage(@QQSR)
    end
    if Input.trigger?(Input::Y) # Local Statistics
      @QQSR="\\c[8]\\w[TrophyWindow]Current Link Battle Balance: \\v[1002] Points"
      @QQSR+="\\nNumber of won Link Battles: \\v[1001]"
      Kernel.pbMessage(@QQSR)
    end
    if Input.trigger?(Input::Z) # Global Leaderboard warn for non-corendo
      worksOnCorendo2(['VR Corendo','Bsisbina Clients','Jinnybell HSPA','Emerald Emulator','Yorkbook Digital Professional','Yorkbook Xe'])
    end
    if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
      if @cmdLink>=0 && @sprites["command_window"].index==@cmdLink
        if $game_player.pbHasDependentEvents?
          Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]It can't be used when you have someone with you."))
          return false
        end
        if $game_switches[172]
          Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]It can't be used during a Museum Mission!"))
          return false
        end
        # Actual Event
        commands=[_INTL("Very Easy (50 Points)"),
                  _INTL("Easy (100 Points)"),
                  _INTL("Medium (150 Points)"),
                  _INTL("Hard (200 Points)"),
                  _INTL("Nightmare (300 Points)"),
                  _INTL("Cancel")]
        command=Kernel.pbMessageLB(
            _INTL("\\c[8]\\w[TrophyWindow]Choose a difficulty you want to use on your battle."),commands,-1)
        if command>=0 && command < 5
          # Begin Battle
          $game_variables[1003] = command+1
          trainer=["Very Easy","Easy","Medium","Hard","Nightmare"][command]
          trainer2=["Whoa!!! How did you beat me",
                    "You must be a strong trainer",
                    "I must get stronger next time",
                    "What else should I say",
                    "I can't stand this death"][rand(5)]
          point=[50,100,150,200,300][command]
          double= Kernel.pbConfirmMessageLB(_INTL("\\c[8]\\w[TrophyWindow]The battle is normally single. However, you can do a double battle. Do you want to do it so?"))
          $PokemonGlobal.nextBattleBack="000"
          if pbTrainerBattle(:LINKER,trainer,_I(trainer2),double,0,true,0)
            Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]You seem to be a strong player. Get your prize."))
            $game_variables[1001] += 1
            $game_variables[1002] += point
            Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]\\me[EvolutionSuccess_1]Obtained {1} Link Points!\\wtnp[30]",point)) if $PokemonSystem.vrtrophynotif==0 rescue false
            Kernel.pbReceiveTrophy(:TLINKER)
            Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]You can use these to purchase various items."))
          else
            Kernel.pbMessage(_INTL("\\c[8]\\w[TrophyWindow]You seem to have weaker species. Better luck next time"))
          end
          # End Battle
          $game_variables[1003] = 0
        end
    
      end
      if @cmdLinkG>=0 && @sprites["command_window"].index==@cmdLinkG
      worksOnCorendo2(['VR Corendo','Bsisbina Clients','Jinnybell HSPA','Emerald Emulator','Yorkbook Digital Professional','Yorkbook Xe'])
      end
      if @cmdLinkP>=0 && @sprites["command_window"].index==@cmdLinkP
      worksOnCorendo2(['VR Corendo','Bsisbina Clients','Jinnybell HSPA'])
      end
      if @cmdLinkS>=0 && @sprites["command_window"].index==@cmdLinkS
          items=[PBItems::POKEBALL,
                 PBItems::POTION,
                 PBItems::GREATBALL,
                 PBItems::SUPERPOTION,
                 PBItems::ULTRABALL,
                 PBItems::HYPERPOTION,
                 PBItems::PARKBALL,
                 PBItems::FULLHEAL,
                 PBItems::GENIEBALL,
                 PBItems::MAXPOTION,
                 PBItems::FULLRESTORE,
                 PBItems::TERRAINEXTENDER,
                 PBItems::BEASTBALL,
                 PBItems::RODOFSPARROW,
                 PBItems::RARECANDY,
                 PBItems::VICIOUSCANDY,
                 PBItems::RELICFLOWER]
          prices=[50,
                  100,
                  150,
                  200,
                  250,
                  300,
                  350,
                  400,
                  500,
                  600,
                  700,
                  800,
                  1000,
                  1500,
                  2000,
                  4000,
                  8000]
        loop do
          commands=[
                  _INTL("Poké Ball (50 Points)"),
                  _INTL("Potion (100 Points)"),
                  _INTL("Great Ball (150 Points)"),
                  _INTL("Super Potion (200 Points)"),
                  _INTL("Ultra Ball (250 Points)"),
                  _INTL("Hyper Potion (300 Points)"),
                  _INTL("Park Ball (350 Points)"),
                  _INTL("Full Heal (400 Points)"),
                  _INTL("Genie Ball (500 Points)"),
                  _INTL("Max Potion (600 Points)"),
                  _INTL("Full Restore (700 Points)"),
                  _INTL("Terrain Extender (800 Points)"),
                  _INTL("Beast Ball (1000 Points)"),
                  _INTL("Rod of Sparrow (1500 Points)"),
                  _INTL("Rare Candy (2000 Points)"),
                  _INTL("Vicious Candy (4000 Points)"),
                  _INTL("Relic Flower (8000 Points)"),
                  _INTL("Cancel")]
          command=Kernel.pbMessageLB(
              _INTL("\\g[1]\\c[8]\\w[TrophyWindow]Which item would you like to buy?"),commands,-1)
          if command < 0 || command>=commands.length-1
            pbPlayCancelSE()
            break
          else
            itemname=  items[command]
            itemname2= PBItems.getName(itemname)
            itemprice= prices[command]
            if Kernel.pbConfirmMessageLB(_INTL("\\g[1]\\c[8]\\w[TrophyWindow]Would you like to buy {1} {2}? It will cost {3} Link Points", (command==4) ? "an" : "a" ,itemname2,itemprice))
              if $game_variables[1002] < itemprice
                Kernel.pbMessage(_INTL("\\g[1]\\c[8]\\w[TrophyWindow]You don't have enough points to buy that."))
                break
              else
                $game_variables[1002] -= itemprice
                $PokemonBag.pbStoreItem(itemname)
                Kernel.pbMessage(_INTL("\\g[1]\\c[8]\\w[TrophyWindow]\\me[EvolutionSuccess_1]Spent {1} Link Points and earned one {2}",itemprice,itemname2))
                break
              end
            else
              break
            end
          end
        end
      end
      return
    end
  end
end
