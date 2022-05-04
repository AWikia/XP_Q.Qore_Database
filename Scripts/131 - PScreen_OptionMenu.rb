def pbOptionSecMenu
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  @sprites={}
  # Dark Mode
  MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.textskin])
  MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.textskin])
  # Dark Mode End
  commands=CommandList.new
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Settings"),0,0,Graphics.width,64,viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].text=_INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
    @sprites["textbox"].letterbyletter=false
  commands.add("general",_INTL("General Settings")) # For settings that do not fit in the below categories
  commands.add("sound",_INTL("Sound Settings")) # For settings which affect Music and Sound
  commands.add("battle",_INTL("Battle Settings")) # For settings which affect Battle or Pokemon Battlers
  commands.add("display",_INTL("Display Settings")) # For settings which affect Graphic and Screen Display

  @sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=@sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.width=Graphics.width
  cmdwindow.height=Graphics.height-@sprites["title"].height-@sprites["textbox"].height
  cmdwindow.x=0
  cmdwindow.y=@sprites["title"].height
  cmdwindow.visible=true
  pbFadeInAndShow(@sprites)
  ret=-1
  loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        ret=-1
        break
      end
      if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
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
    end
  end
  pbFadeOutAndHide(@sprites)
  pbDisposeSpriteHash(@sprites)
  viewport.dispose
end

class Scene_OptionSection
  def main
    Graphics.transition(15)
    pbOptionSecMenu
    $scene=Scene_Map.new
    $game_map.refresh
    Graphics.freeze
  end
end
