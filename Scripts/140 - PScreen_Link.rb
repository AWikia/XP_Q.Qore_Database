class LinkBattleButton < SpriteWrapper
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
    icon=sprintf("Graphics/UI/Link Battle/icon_"+@name)
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
class Scene_LinkBattleScene
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def pbStartScene(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def pbLinkScreen
    @sprites={}
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdLink=-1
    @cmdLinkG=-1
    @cmdLinkP=-1
    @cmdLinkS=-1
    @cmdLinkHelp=-1
    @cmdLinkLB=-1
    commands[@cmdLink=commands.length]=_INTL("Local Battle")
    commands[@cmdLinkG=commands.length]=_INTL("Remote Battle")
    commands[@cmdLinkS=commands.length]=_INTL("Marketplace")
    commands[@cmdLinkHelp=commands.length]=_INTL("Help")
    commands[@cmdLinkLB=commands.length]=_INTL("Leaderboard")
    
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/pokegearButton")
    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Link Battle/bg_f"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Link Battle/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Link Battle/bg",@viewport)
    end

    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Link Battle"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
# Bottom
    textpos=[
       [_INTL("Balance: {1} Points",$game_variables[1002]),18,354,0,@sprites["header"].baseColor],
       [_INTL("Won Link Battles: {1}",$game_variables[1001]),Graphics.width-16,354,1,@sprites["header"].baseColor]
    ]
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
# Bottom End
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    for i in 0...commands.length
      x=118+64
      y=190 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=LinkBattleButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
    end
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
  
  def update_stats
# Bottom
    @sprites["overlay"].bitmap.clear
    textpos=[
       [_INTL("Balance: {1} Points",$game_variables[1002]),18,354,0,@sprites["header"].baseColor],
       [_INTL("Won Link Battles: {1}",$game_variables[1001]),Graphics.width-16,354,1,@sprites["header"].baseColor]
    ]
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
# Bottom End
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
      if @cmdLink>=0 && @sprites["command_window"].index==@cmdLink
        if $game_player.pbHasDependentEvents?
          Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
          return false
        end
        if $game_switches[172]
          Kernel.pbMessage(_INTL("It can't be used during a Museum Mission!"))
          return false
        end
        # Actual Event
        commands=[_INTL("Very Easy (50 Points)"),
                  _INTL("Easy (100 Points)"),
                  _INTL("Medium (150 Points)"),
                  _INTL("Hard (200 Points)"),
                  _INTL("Nightmare (300 Points)"),
                  _INTL("Intensive (500 Points)"),
                  _INTL("Cancel")]
        command=Kernel.pbMessage(
            _INTL("Choose a difficulty you want to use on your battle."),commands,-1)
        if command>=0 && command < 6
          # Begin Battle
          $game_variables[1003] = command+1
          trainer=["Very Easy","Easy","Medium","Hard","Nightmare","Nightmare"][command]
          trainer2=["Whoa!!! How did you beat me",
                    "You must be a strong trainer",
                    "I must get stronger next time",
                    "What else should I say",
                    "I can't stand this death"][rand(5)]
          point=[50,100,150,200,300][command]
          double= Kernel.pbConfirmMessage(_INTL("The battle is normally single. However, you can do a double battle. Do you want to do it so?"))
          $PokemonGlobal.nextBattleBack="000"
          cpuname = ['Nic','Karla','Jimmy','Britney','Duncan','Kelli','Todd','Nina','Ross','Heidi','Steven','Miriam','Darrell','Teresa','Reed','Aubrey','Chris','Kelly','Brad','Naomi','Dwight','Abby','Randy','Denise','Andy','Tamara','Joey','Linda','Eric','Faith','Mark','Mari','Maggie','Ash','Dion','Jude','Terell','Kris','Talon','Lonny','Jess','Chase','Keili','Lindy','Turdy','Krissa','Dodie','Flora'][rand(48)]
          pbSet(1004,cpuname)
          if pbTrainerBattle(:LINKER,trainer,_I(trainer2),double,0,true,0)
            Kernel.pbMessage(_INTL("You won against {1} as you seem to be a strong player. Get your prize.",cpuname))
            $game_variables[1001] += 1
            $game_variables[1002] += point
            update_stats
            Kernel.pbMessage(_INTL("\\me[EvolutionSuccess_1]Obtained {1} Link Points!\\wtnp[30]",point)) if $PokemonSystem.vrtrophynotif==0 rescue false
            Kernel.pbReceiveTrophy(:TLINKER)
            Kernel.pbMessage(_INTL("You can use these to purchase various items."))
          else
            Kernel.pbMessage(_INTL("You lost against {1} as you seem to have weaker species. Better luck next time",cpuname))
            end
          # End Battle
          $game_variables[1003] = 0
        end
    
      end
      if @cmdLinkG>=0 && @sprites["command_window"].index==@cmdLinkG
      worksOnCorendo(['VR Corendo','Bsisbina Clients','Jinnybell HSPA','Emerald Emulator','Yorkbook Digital Professional','Yorkbook Xe'])
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
                 PBItems::BOTANICSMOKE,
                 PBItems::BEASTBALL,
                 PBItems::RODOFSPARROW,
                 PBItems::RARECANDY,
                 PBItems::WHITEFLAG,
                 PBItems::BELLBOX,
                 PBItems::VICIOUSCANDY,
                 PBItems::KEYBOX,
                 PBItems::RELICFLOWER,
                 PBItems::SACREDASH,
                 'RB']
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
                  900,
                  1000,
                  1500,
                  2000,
                  2500,
                  3000,
                  4000,
                  5000,
                  6000,
                  7000,
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
                  _INTL("Botanic Smoke (900 Points)"),
                  _INTL("Beast Ball (1000 Points)"),
                  _INTL("Rod of Sparrow (1500 Points)"),
                  _INTL("Rare Candy (2000 Points)"),
                  _INTL("White Flag (2500 Points)"),
                  _INTL("Bell Box (3000 Points)"),
                  _INTL("Vicious Candy (4000 Points)"),
                  _INTL("Key Box (5000 Points)"),
                  _INTL("Relic Flower (6000 Points)"),
                  _INTL("Sacred Ash (7000 Points)"),
                  _INTL("Remote Box (8000 Points)"),
                  _INTL("Cancel")]
          command=Kernel.pbMessage(
              _INTL("\\g[1]Which item would you like to buy?"),commands,-1)
          if command < 0 || command>=commands.length-1
            pbPlayCancelSE()
            break
          else
            itemname=  items[command]
            if itemname == 'RB'
              itemname2='Remote Box'
            else
              itemname2= PBItems.getName(itemname)
            end
            itemprice= prices[command]
            if Kernel.pbConfirmMessage(_INTL("\\g[1]Would you like to buy {1} {2}? It will cost {3} Link Points", (command==4) ? "an" : "a" ,itemname2,itemprice))
              if $game_variables[1002] < itemprice
                Kernel.pbMessage(_INTL("\\g[1]You don't have enough points to buy that."))
                break
              else
                if itemname == 'RB'
                  species = [PBSpecies::DITTO,PBSpecies::BASCULIN,PBSpecies::DISCORD,PBSpecies::LUVDISC,PBSpecies::SQUAWKABILLY,PBSpecies::PLUNUM,PBSpecies::MILCERY]
# Unlockables
                  if $game_switches && $game_switches[67]
                    species+=[PBSpecies::UNOWN]
                  end
                  if completedTrophies
                    species+=[PBSpecies::MICROSOFT,PBSpecies::FABRIC,PBSpecies::COPILOT,PBSpecies::DEVHOME,PBSpecies::FABPILHOME]
                  end
                  if completedTechnicalDiscs
                    species+=[PBSpecies::ROTOM]
                  end
                  if Kernel.pbTechnicalDiscScore > 24
                    species+=[PBSpecies::WATTREL]
                  end
                  if Kernel.pbTechnicalDiscScore > 49
                    species+=[PBSpecies::FRIKIPAIDEIA,PBSpecies::SINISTEA,PBSpecies::POLTEAGEIST]
                  end
                  if $game_switches && $game_variables &&
                     $game_switches[12] && $game_switches[70] && 
                     $game_switches[76] && completedTrophies &&
                     completedTechnicalDiscs && $game_variables[13]>99
                    species+=[PBSpecies::ALCREMIE,PBSpecies::TELEMOBIL]
                  end
                  if $game_variables && $game_variables[1001] > 0
                    species+=[PBSpecies::FLABEBE]
                  end
                  if $game_variables && $game_variables[1001] > 49
                    species+=[PBSpecies::DURALUDON]
                  end
                  if $game_variables && $game_variables[1001] > 99
                    species+=[PBSpecies::BASCULEGION]
                  end
                  if $game_variables && $game_variables[1001] > 149
                    species+=[PBSpecies::INDEEDEE]
                  end
                  if $game_variables && $game_variables[1001] > 199
                    species+=[PBSpecies::MEOWSTIC]
                  end
                  if $game_variables && $game_variables[1001] > 299
                    species+=[PBSpecies::TATSUGIRI]
                  end
                  if $game_variables && $game_variables[1001] > 399
                    species+=[PBSpecies::HUNTAIL,PBSpecies::GOREBYSS]
                  end
                  if $game_variables && $game_variables[1001] > 499
                    species+=[PBSpecies::DFADOM]
                  end
                  if $game_variables && $game_variables[1001] > 599
                    species+=[PBSpecies::WISHIWASHI]
                  end
                  if $game_variables && $game_variables[1001] > 699
                    species+=[PBSpecies::MORPEKO]
                  end
                  if $game_variables && $game_variables[1001] > 799
                    species+=[PBSpecies::MAGEARNA]
                  end
                  if $game_variables && $game_variables[1001] > 899
                    species+=[PBSpecies::BOOMERAN]
                  end
                  if $game_variables && $game_variables[1001] > 999
                    species+=[PBSpecies::TELEMOBILEGION]
                  end
                  if (pbGetTimeNow.mon == 4 && pbGetTimeNow.day == 1)
                    species+=[PBSpecies::BLINKY,PBSpecies::INKY,PBSpecies::CLYDE,PBSpecies::PINKY,PBSpecies::SUE,PBSpecies::FUNKY,PBSpecies::SPUNKY,PBSpecies::ORSON]
                  else
                    species+=[PBSpecies::BLUEGHOST]
                  end
# End Unlockables
                  pokemon = species[rand(species.length)]
                  if pbGenerateRemoteBox(pokemon,_I("Link Battle Marketplace"))
                    $game_variables[1002] -= itemprice
                    update_stats
                  else
                    Kernel.pbMessage(_INTL("\\g[1]You don't have enough space to store the box. Make room and come again."))
                    break
                  end
                else
                  $game_variables[1002] -= itemprice
                  update_stats
                  $PokemonBag.pbStoreItem(itemname)
                end
                Kernel.pbMessage(_INTL("\\g[1]\\me[EvolutionSuccess_1]Spent {1} Link Points and earned one {2}",itemprice,itemname2))
                break
              end
            else
              break
            end
          end
        end
      end
      if @cmdLink>=0 && @sprites["command_window"].index==@cmdLinkHelp
        @QQSR="\\l[10]"
        @QQSR+="Choose any of the three modes present. Local Battles is you vs. an opponent with random Pokemon while the other uses communication with another player."
        @QQSR+="\\nFor local play, you can select the difficulty you want to use."
        @QQSR+="\\nThere's no time limit and no Pokemon limitations in any of the game modes"
        @QQSR+="\\nPokemon levels for local play depends on your Pokemon's levels."
        @QQSR+="\\nThe winner will be awarded with Battle Link points. Winning your first Link Battle will award the Battle Linker trophy."
        Kernel.pbMessage(@QQSR)
      end
      if @cmdLink>=0 && @sprites["command_window"].index==@cmdLinkLB
        worksOnCorendo(['VR Corendo','Bsisbina Clients','Jinnybell HSPA','Emerald Emulator','Yorkbook Digital Professional','Yorkbook Xe'])
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

class Scene_LinkBattle
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbLinkScreen
    @scene.pbEndScene
  end
end