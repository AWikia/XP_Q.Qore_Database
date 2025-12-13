class PokemonMenu_Scene
  def pbShowCommands(commands)
    ret=-1
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.index=$PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.height=Graphics.height - 32 if cmdwindow.height>(Graphics.height - 32)
    cmdwindow.commands=commands
    cmdwindow.x=Graphics.width-cmdwindow.width
    cmdwindow.y=32
    cmdwindow.visible=true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
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
    @sprites["partybg_title"] = IconSprite.new(0,0)        
    @sprites["partybg_title"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/party_bg")
    @sprites["partybg_title"].z=99998
    @sprites["partybg_title"].visible=true

    title=RTP.getGameIniValue("Game", "Game") # QQC Edit 
    title=RTP.getGameIniValue("Game","Title") if title==""
    title="RGSS Game" if title==""

    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
       2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["header"].z=99999
    @sprites["cmdwindow"]=Window_CommandPokemon.new([])
    @sprites["infowindow"]=Window_UnformattedTextPokemon.newWithSize("",0,32,32,32,@viewport)
    @sprites["infowindow"].visible=false
    @sprites["infowindow"].z=601
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,32,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].z=601
    @sprites["cmdwindow"].visible=false
    @sprites["cmdwindow"].z=601
    @sprites["curtain"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["curtain"].y=32
    @sprites["curtain"].z=600
    @sprites["curtain"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(12,12,12))
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
      if $DEBUG
        Kernel.pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
        Kernel.pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    commands[cmdPokedex=commands.length]=_INTL("Pokédex") if $Trainer.pokedex && $PokemonGlobal.pokedexViable.length>0
    commands[cmdPokemon=commands.length]=_INTL("Pokémon") if $Trainer.party.length>0
    commands[cmdBag=commands.length]=_INTL("Bag") if !pbInBugContest?
#    commands[cmdPokegear=commands.length]=_INTL("Pokégear") if $Trainer.pokegear
    commands[cmdTrainer=commands.length]=$Trainer.name
    information=_INTL("Trophies: {1}/28 ({2}%)\nTechnical Discs: {3}/100\nWin Streak:{4}\n",Kernel.pbTrophies, Kernel.pbTrophyScore, Kernel.pbTechnicalDiscScore, $game_variables[WIN_STREAK_VARIABLE])
    if pbInSafari?
      if SAFARISTEPS<=0
        information+=_INTL("Balls: {1}\n",pbSafariState.ballcount)
      else
        information+=_INTL("Steps: {1}/{2}\nBalls: {3}\n",pbSafariState.steps,SAFARISTEPS,pbSafariState.ballcount)
      end
      commands[cmdQuit=commands.length]=_INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        information+=_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}\n",
           PBSpecies.getName(pbBugContestState.lastPokemon.species),
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount)
      else
        information+=_INTL("Caught: None\nBalls: {1}\n",pbBugContestState.ballcount)
      end
      commands[cmdQuit=commands.length]=_INTL("Quit Contest")
    else
      commands[cmdSave=commands.length]=_INTL("Save") if (!$game_system || !$game_system.save_disabled) && ($game_map && !pbGetMetadata($game_map.map_id,MetadataForbidSaving))
#      commands[cmdLink=commands.length]=_INTL("Link...") if $game_switches[12]
    end
    if $game_switches[209]
      information+=_INTL("{1}: {2}/{3} ({4} left)\n",pbMapTimeEventName,pbMapTimeEventAmount,pbMapTimeEventMax,pbTimeEventRemainingTime(41))
    end
    if $game_switches[219]
      information+=_INTL("Gold Bar Collection: {1}/999 ({2} left)\n",$PokemonBag.pbQuantity(:GOLDBAR),pbTimeEventRemainingTime(43))
    end
    @scene.pbShowInfo(information)
    commands[cmdOption=commands.length]=_INTL("Settings")
    commands[cmdDebug=commands.length]=_INTL("Debug") if $DEBUG
    commands[cmdEndGame=commands.length]=_INTL("Quit Game")
    commands[cmdAbout=commands.length]=_INTL("About")
    loop do
      command=@scene.pbShowCommands(commands) if endscene
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
            scene=Scene_PokedexMenuScene.new
            screen=Scene_PokedexMenu.new(scene)
            pbFadeOutIn(99999) {
               screen.pbStartScreen
               @scene.pbRefresh
            }
          end
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        scene=Scene_PokegearScene.new
        screen=Scene_Pokegear.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           @scene.pbRefresh
        }
      elsif cmdLink>=0 && command==cmdLink
        scene=Scene_LinkBattleScene.new
        screen=Scene_LinkBattle.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           @scene.pbRefresh
        }
      elsif cmdPokemon>=0 && command==cmdPokemon
        hiddenmove=nil
        pbFadeOutIn(99999) { 
           sscene=PokemonScreen_Scene.new
           sscreen=PokemonScreen.new(sscene,$Trainer.party)
           hiddenmove=sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
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
#        @scene.pbHideMenu
        scene=PokemonSaveScene.new
        screen=PokemonSave.new(scene)
        pbFadeOutIn(99999) { 
          if screen.pbSaveScreen
            @scene.pbEndScene
            endscene=false
            break
          else
  #          pbShowMenu
          end
        }
      elsif cmdDebug>=0 && command==cmdDebug
        scene=Scene_DebugSectionScene.new
        screen=Scene_DebugSection.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           @scene.pbRefresh
        }
      elsif cmdOption>=0 && command==cmdOption
        scene=Scene_OptionSectionScene.new
        screen=Scene_OptionSection.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if $game_map && !pbGetMetadata($game_map.map_id,MetadataForbidSaving)
          if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
              scene=PokemonSaveScene.new
              screen=PokemonSave.new(scene)
            pbFadeOutIn(99999) { 
              if screen.pbSaveScreen
                @scene.pbEndScene
              end
            }
            @scene.pbEndScene
            $scene=nil
            return
          else
            pbShowMenu
          end
        else
          if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game? Any progress made since last saving will be lost"))
            @scene.pbEndScene
            $scene=nil
            return
          else
            pbShowMenu
          end
        end
      elsif cmdAbout>=0 && command==cmdAbout
        scene=PokemonAboutScreenScene.new
        screen=PokemonAboutScreen.new(scene)
        pbFadeOutIn(99999) { 
           screen.pbStartScreen
           @scene.pbRefresh
        }
      else
        break
      end
    end
    @scene.pbEndScene if endscene
  end  
end