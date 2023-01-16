#===============================================================================
# ** Scene_iPod
# ** Created by xLeD (Scene_Jukebox)
# ** Modified by Harshboy
# ** Modified again by Qora Qore Telecommunities
#-------------------------------------------------------------------------------
#  This class performs menu screen processing.
#===============================================================================
class Scene_JukeboxScene
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def pbStartScene(menu_index = 0)
    @menu_index =  menu_index
  end
  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def pbJukeboxScreen
    # Make song command window
    fadein = true
    # Makes the text window
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background2"]=IconSprite.new(0,0,@viewport)
    @sprites["background2"].visible=false
    if $Trainer && $Trainer.isFemale?
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/jukeboxbgf",@viewport)
      @sprites["background2"].setBitmap(_INTL("Graphics/Pictures/"+getDarkModeFolder+"/jukeboxbgf_2"))
    else
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/jukeboxbg",@viewport)
      @sprites["background2"].setBitmap(_INTL("Graphics/Pictures/"+getDarkModeFolder+"/jukeboxbg_2"))
    end
    @sprites["background"].z = 1
    @sprites["background2"].z = 2
    @choices=[
       _INTL("March Radio"),
       _INTL("Lullaby Radio"),
       _INTL("Oak Radio"),
       _INTL("Exit")
    ]
    @sprites["command_window"] = Window_CommandPokemon.new(@choices,324)
    @sprites["command_window"].windowskin=nil
    if (!isDarkMode?)
      @sprites["command_window"].baseColor=MessageConfig::DARKTEXTBASE
      @sprites["command_window"].shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      @sprites["command_window"].baseColor=MessageConfig::LIGHTTEXTBASE
      @sprites["command_window"].shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].height = 224
    @sprites["command_window"].width = 324
    @sprites["command_window"].x = 94+64
    @sprites["command_window"].y = 92
    @sprites["command_window"].z = 99999
    @custom=false
    @cancel=false
    @page=0
    # Execute transition
    pbFadeInAndShow(@sprites)
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if @cancel
         break
      end
      if Input.trigger?(Input::RIGHT) && @page==0
        pbPlayCursorSE()
        @page=1
        files=[_INTL("(Default)")]
        Dir.chdir("Audio/BGM/"){
           Dir.glob("*.mp3"){|f| files.push(f) }
           Dir.glob("*.MP3"){|f| files.push(f) }
           Dir.glob("*.ogg"){|f| files.push(f) }
           Dir.glob("*.OGG"){|f| files.push(f) }
           Dir.glob("*.wav"){|f| files.push(f) }
           Dir.glob("*.WAV"){|f| files.push(f) }
           Dir.glob("*.mid"){|f| files.push(f) }
           Dir.glob("*.MID"){|f| files.push(f) }
           Dir.glob("*.midi"){|f| files.push(f) }
           Dir.glob("*.MIDI"){|f| files.push(f) }
        }
        @sprites["command_window"].commands=files
        @sprites["command_window"].index=$JBIndex1
        @custom=true
        @sprites["background2"].visible=true
      end
      if Input.trigger?(Input::LEFT) && @page==1
        pbPlayCursorSE()
        @page=0
        @sprites["command_window"].commands=@choices
        @sprites["command_window"].index=$JBIndex0
        @custom=false
        @sprites["background2"].visible=false
      end
      if Input.trigger?(Input::B)
         pbPlayCancelSE()
         break
      end
    end

  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Update windows
    pbUpdateSpriteHash(@sprites)
    if @custom
      updateCustom
    else
      update_command
    end
    return
  end
  #-----------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #-----------------------------------------------------------------------------
  def updateCustom
    if Input.trigger?(Input::B)
      @cancel=true
      @custom=false
      return
    end
    $JBIndex1= @sprites["command_window"].index if @page == 1
    if Input.trigger?(Input::C)
      $PokemonMap.whiteFluteUsed=false if $PokemonMap
      $PokemonMap.blackFluteUsed=false if $PokemonMap
      if @sprites["command_window"].index==0
        $game_system.setDefaultBGM(nil)
      else
        $game_system.setDefaultBGM(
           @sprites["command_window"].commands[@sprites["command_window"].index], 
           $PokemonSystem.jbvol, $PokemonSystem.jbtempo
        )        
      end
    end
  end

  def update_command
    $JBIndex0= @sprites["command_window"].index if @page == 0
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
      case @sprites["command_window"].index
      when 0
        pbPlayDecisionSE()
        pbBGMPlay("Radio - March", 100, 100)
        $PokemonMap.whiteFluteUsed=true if $PokemonMap
        $PokemonMap.blackFluteUsed=false if $PokemonMap
      when 1
        pbPlayDecisionSE()
        pbBGMPlay("Radio - Lullaby", 100, 100)
        $PokemonMap.blackFluteUsed=true if $PokemonMap
        $PokemonMap.whiteFluteUsed=false if $PokemonMap
      when 2
        pbPlayDecisionSE()
        pbBGMPlay("Radio - Oak", 100, 100)
        $PokemonMap.whiteFluteUsed=false if $PokemonMap
        $PokemonMap.blackFluteUsed=false if $PokemonMap
      when 3
        pbPlayDecisionSE()
        @cancel=true
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


class Scene_Jukebox
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene($JBIndex0)
    @scene.pbJukeboxScreen
    @scene.pbEndScene
  end
end