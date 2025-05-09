class PokemonAboutScreenScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new(62,97,Graphics.width-124,Graphics.height-160)
    @viewport2.z=99999

    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/About/bg_f"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/About/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/About/bg",@viewport)
    end
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("About Qora Qore"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width - 104,Graphics.height - 104,@viewport2)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDisplayAboutScreen
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDisplayAboutScreen
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
       [_INTL("Qora Qore " + RTP.getGameIniValue("Qortex", "Release") + " " + RTP.getGameIniValue("Qortex", "Channel")),0,0,0,baseColor,shadowColor],
       [_INTL("Build " + RTP.getGameIniValue("Qortex", "Build") + "." + RTP.getGameIniValue("Qortex", "Delta") + " (" + RTP.getGameIniValue("Qortex", "Version") + " Release)"),0,32,0,baseColor,shadowColor],
       [_INTL("The Qora Qore project begun in December 2013 and it is"),0,96,0,baseColor,shadowColor],
       [_INTL("now a community-oriented project as a service."),0,128,0,baseColor,shadowColor],
       [_INTL("Work is based upon the " + RTP.getGameIniValue("Qortex", "Semester") + " codebase."),0,192,0,baseColor,shadowColor],
    ]
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbAboutScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
      if Input.press?(Input::CTRL) && Input.press?(Input::C)
        clip =  _INTL("Qora Qore " + RTP.getGameIniValue("Qortex", "Release") + RTP.getGameIniValue("Qortex", "Channel"))
        clip += _INTL("\nBuild " + RTP.getGameIniValue("Qortex", "Build") + "." + RTP.getGameIniValue("Qortex", "Delta") + " (" + RTP.getGameIniValue("Qortex", "Version") + " Release)")
        clip += _INTL("\nThe Qora Qore project begun in December 2013 and it is now a community-oriented project as a service.")
        clip += _INTL("\nWork is based upon the " + RTP.getGameIniValue("Qortex", "Semester") + " codebase.")
        clipcopy(clip)
        Kernel.pbMessage(_INTL("Copied About Screen Contents to the clipboard"))
      end
    end 
  end

  def clipcopy(input)
    str = input.to_s
    IO.popen('clip', 'w') { |f| f << str }
    str
  end

  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonAboutScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbAboutScreen
    @scene.pbEndScene
  end
end