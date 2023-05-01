class Scene_OptionSectionScene
  def pbOptionSecMenu
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    # Dark Mode
    if (($PokemonSystem.darkmode==2 rescue false) || 
       ($PokemonSystem.darkmode==3 rescue false)) &&
       ($BORDERS!=getBorders)
      MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.textskin])
      MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.textskin])
      $BORDERS=getBorders
      setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic])
    end
    # Dark Mode End
    commands=CommandList.new
        addBackgroundOrColoredPlane(@sprites,"title",getDarkModeFolder+"/Settings/bg",
           Color.new(0,0,0),@viewport)
      title="Settings"    
      @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
         2,-18,576,64,@viewport)      
      @sprites["header"].baseColor=(isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
      @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
      @sprites["header"].windowskin=nil
  
      @sprites["textbox"]=Kernel.pbCreateMessageWindow
      @sprites["textbox"].text=_INTL("Use the arrow keys to navigate to the menu. Press C or Space to open the selected settings page")
      @sprites["textbox"].letterbyletter=false
    commands.add("general",_INTL("General Settings")) # For settings that do not fit in the below categories
    commands.add("sound",_INTL("Sound Settings")) # For settings which affect Music and Sound
    commands.add("battle",_INTL("Battle Settings")) # For settings which affect Battle or Pokemon Battlers
    commands.add("display",_INTL("Display Settings")) # For settings which affect Screen Display
    commands.add("personalization",_INTL("Personalization Settings")) # For settings which affect Graphic
  
    @sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.width=Graphics.width
    cmdwindow.height=Graphics.height-32-@sprites["textbox"].height
    cmdwindow.x=0
    cmdwindow.y=32
    cmdwindow.visible=true
    pbFadeInAndShow(@sprites)
    ret=-1
    loop do
      loop do
        cmdwindow.update
        Graphics.update
        Input.update
        @sprites["header"].windowskin=nil if @sprites["header"].windowskin!=nil
        if Input.trigger?(Input::B)
          pbPlayCancelSE()
          ret=-1
          break
        end
        if Input.trigger?(Input::C)
          pbPlayDecisionSE()
          ret=cmdwindow.index
          break
        end
      end
      break if ret==-1
      cmd=commands.getCommand(ret)
      if cmd=="general"
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen(false,0)
           pbUpdateSceneMap
        }
      elsif cmd=="sound"
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen(false,1)
           pbUpdateSceneMap
        }
      elsif cmd=="battle"
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen(false,2)
           pbUpdateSceneMap
        }
      elsif cmd=="display"
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
          screen.pbStartScreen(false,3)
          pbUpdateSceneMap
        }
      elsif cmd=="personalization"
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
          screen.pbStartScreen(false,4)
          pbUpdateSceneMap
        }
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
end


class Scene_OptionSection
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbOptionSecMenu
    @scene.pbEndScene
  end
end
