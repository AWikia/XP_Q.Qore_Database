class Scene_DebugSectionScene
  def pbDebugSecMenu(inloadscreen=false)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    # Dark Mode
    updateWindowSkin
    # Dark Mode End
    commands=CommandList.new
        addBackgroundOrColoredPlane(@sprites,"title",getDarkModeFolder+"/Settings/bg",
           Color.new(12,12,12),@viewport)
      title="Debug Menu"    
      @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
         2,-18,576,64,@viewport)      
      @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
      @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
      @sprites["header"].windowskin=nil
    commands.add("diagnostic",_INTL("Diagnostic tools..."))
    commands.add("field",_INTL("Field options...")) if !inloadscreen
    commands.add("battle",_INTL("Battle options...")) if !inloadscreen
    commands.add("pokemon",_INTL("Pokémon options...")) if !inloadscreen
    commands.add("item",_INTL("Item options...")) if !inloadscreen
    commands.add("player",_INTL("Player options...")) if !inloadscreen
    commands.add("pbs",_INTL("PBS editors..."))
    commands.add("other",_INTL("Other editors..."))
    commands.add("files",_INTL("Files options..."))
    @sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.width=Graphics.width
    cmdwindow.height=Graphics.height-32
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
      if cmd=="diagnostic"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,0)
        }
      elsif cmd=="field"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,1)
        }
      elsif cmd=="battle"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,2)
        }
      elsif cmd=="pokemon"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,3)
        }
      elsif cmd=="item"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,4)
        }
      elsif cmd=="player"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,5)
        }
      elsif cmd=="pbs"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,6)
        }        
      elsif cmd=="other"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,7)
        }        
      elsif cmd=="files"
        pbFadeOutIn(99999) { 
           pbDebugMenu(inloadscreen,8)
        }
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
end


class Scene_DebugSection
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(inloadscreen=false)
    @scene.pbDebugSecMenu(inloadscreen)
    @scene.pbEndScene
  end
end
