class PokemonMenu_Scene
  def pbShowCommands(commands)
    ret=-1
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.index=$PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands=commands
    cmdwindow.x=Graphics.width-cmdwindow.width
    cmdwindow.y=0
    cmdwindow.visible=true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        ret=-1
        break
      end
      if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
        pbPlayDecisionSE()
        ret=cmdwindow.index
        $PokemonTemp.menuLastChoice=ret
        break
      end
    end
    return ret
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text,Graphics.height)
    @sprites["infowindow"].text=text
    @sprites["infowindow"].visible=true
    @infostate=true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text=text
    @sprites["helpwindow"].visible=true
    @helpstate=true
    pbBottomLeft(@sprites["helpwindow"])
  end

  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["cmdwindow"]=Window_CommandPokemon.new([])
=begin
    @sprites["cmdwindow"].setSkin("Graphics/Windowskins/choice dp")
    @sprites["cmdwindow"].baseColor=Color.new(88,88,80)
    @sprites["cmdwindow"].shadowColor=Color.new(168,184,184)
=end
    @sprites["infowindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible=false
=begin
    @sprites["infowindow"].setSkin("Graphics/Windowskins/choice dp")
    @sprites["infowindow"].baseColor=Color.new(88,88,80)
    @sprites["infowindow"].shadowColor=Color.new(168,184,184)
=end
    @sprites["infowindow"].z=601
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].z=601
=begin
    @sprites["helpwindow"].setSkin("Graphics/Windowskins/choice dp")
    @sprites["helpwindow"].baseColor=Color.new(88,88,80)
    @sprites["helpwindow"].shadowColor=Color.new(168,184,184)
=end
    @sprites["cmdwindow"].visible=false
    @sprites["cmdwindow"].z=601
    @sprites["curtain"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["curtain"].z=600
    @sprites["curtain"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @sprites["curtain"].opacity=100
    @infostate=false
    @helpstate=false
    pbPlayDecisionSE()
#    pbSEPlay("menu")
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible=false
    @sprites["infowindow"].visible=false
    @sprites["helpwindow"].visible=false
    @sprites["cmdwindow"].visible=false
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible=true
    @sprites["infowindow"].visible=@infostate
    @sprites["helpwindow"].visible=@helpstate
    @sprites["cmdwindow"].visible=true
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
  end
end



class PokemonMenu
  def initialize(scene)
    @scene=scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    @scene.pbStartScene
    endscene=true
    pbSetViableDexes
    commands=[]
    cmdPokedex  = -1
    cmdPokemon  = -1
    cmdBag      = -1
    cmdTrainer  = -1
    cmdSave     = -1
    cmdOption   = -1
    cmdPokegear = -1
    cmdLink     = -1
    cmdDebug    = -1
    cmdQuit     = -1
    cmdEndGame  = -1
    cmdAbout    = -1
    if !$Trainer
      if ($DEBUG || $TEST)
        Kernel.pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
        Kernel.pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    commands[cmdPokedex=commands.length]=_INTL("Pokédex") if $Trainer.pokedex && $PokemonGlobal.pokedexViable.length>0
    commands[cmdPokemon=commands.length]=_INTL("Pokémon") if $Trainer.party.length>0
    commands[cmdBag=commands.length]=_INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear=commands.length]=_INTL("Pokégear") if $Trainer.pokegear
    commands[cmdTrainer=commands.length]=$Trainer.name
    if pbInSafari?
      if SAFARISTEPS<=0
        @scene.pbShowInfo(_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\nBalls: {4}",Kernel.pbTrophies,Kernel.pbTrophyScore,Kernel.pbTechnicalDiscScore,pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\nSteps: {4}/{5}\nBalls: {6}",Kernel.pbTrophies,Kernel.pbTrophyScore,Kernel.pbTechnicalDiscScore,pbSafariState.steps,SAFARISTEPS,pbSafariState.ballcount))
      end
      commands[cmdQuit=commands.length]=_INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\nCaught: {4}\nLevel: {5}\nBalls: {6}",
           Kernel.pbTrophies,
           Kernel.pbTrophyScore,
           Kernel.pbTechnicalDiscScore,
           PBSpecies.getName(pbBugContestState.lastPokemon.species),
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\nCaught: None\nBalls: {4}",Kernel.pbTrophies,Kernel.pbTrophyScore,Kernel.pbTechnicalDiscScore,pbBugContestState.ballcount))
      end
      commands[cmdQuit=commands.length]=_INTL("Quit Contest")
    else
      @scene.pbShowInfo(_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\n",Kernel.pbTrophies, Kernel.pbTrophyScore, Kernel.pbTechnicalDiscScore))
      commands[cmdSave=commands.length]=_INTL("Save") if !$game_system || !$game_system.save_disabled
      commands[cmdLink=commands.length]=_INTL("Link...") if $game_switches[12]
    end
    commands[cmdOption=commands.length]=_INTL("Settings")
    commands[cmdDebug=commands.length]=_INTL("Debug") if ($DEBUG || $TEST)
    commands[cmdEndGame=commands.length]=_INTL("Quit Game")
    commands[cmdAbout=commands.length]=_INTL("About")
    loop do
      command=@scene.pbShowCommands(commands)
      if cmdPokedex>=0 && command==cmdPokedex
        if DEXDEPENDSONLOCATION
          pbFadeOutIn(99999) {
             scene=PokemonPokedexScene.new
             screen=PokemonPokedex.new(scene)
             screen.pbStartScreen
             @scene.pbRefresh
          }
        else
          if $PokemonGlobal.pokedexViable.length==1
            $PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[0]
            $PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
            pbFadeOutIn(99999) {
               scene=PokemonPokedexScene.new
               screen=PokemonPokedex.new(scene)
               screen.pbStartScreen
               @scene.pbRefresh
            }
          else
            pbLoadRpgxpScene(Scene_PokedexMenu.new)
          end
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        pbLoadRpgxpScene(Scene_Pokegear.new)
      elsif cmdLink>=0 && command==cmdLink
        pbLoadRpgxpScene(Scene_LinkBattle.new)
      elsif cmdPokemon>=0 && command==cmdPokemon
        sscene=PokemonScreen_Scene.new
        sscreen=PokemonScreen.new(sscene,$Trainer.party)
        hiddenmove=nil
        pbFadeOutIn(99999) { 
           hiddenmove=sscreen.pbPokemonScreen
           if hiddenmove
             @scene.pbEndScene
           else
             @scene.pbRefresh
           end
        }
        if hiddenmove
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        item=0
        scene=PokemonBag_Scene.new
        screen=PokemonBagScreen.new(scene,$PokemonBag)
        pbFadeOutIn(99999) { 
           item=screen.pbStartScreen 
           if item>0
             @scene.pbEndScene
           else
             @scene.pbRefresh
           end
        }
        if item>0
          Kernel.pbUseKeyItemInField(item)
          return
        end
      elsif cmdTrainer>=0 && command==cmdTrainer
        scene=PokemonTrainerCardScene.new
        screen=PokemonTrainerCard.new(scene)
        pbFadeOutIn(99999) { 
           screen.pbStartScreen
           @scene.pbRefresh
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision=1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if Kernel.pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        scene=PokemonSaveScene.new
        screen=PokemonSave.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene=false
          break
        else
          pbShowMenu
        end
      elsif cmdDebug>=0 && command==cmdDebug
        pbFadeOutIn(99999) { 
           pbDebugMenu
           @scene.pbRefresh
        }
      elsif cmdOption>=0 && command==cmdOption
        pbFadeOutIn(99999) { 
           pbOptionSecMenu           
           @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene=PokemonSaveScene.new
          screen=PokemonSave.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene=nil
          return
        else
          pbShowMenu
        end
      elsif cmdAbout>=0 && command==cmdAbout
        qortexAbout
        pbShowMenu
      else
        break
      end
    end
    @scene.pbEndScene if endscene
  end  
end
