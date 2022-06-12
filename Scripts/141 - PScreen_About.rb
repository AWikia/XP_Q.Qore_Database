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

    femback=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/aboutbg"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/aboutbgf",@viewport)
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/aboutbg",@viewport)
    end
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("About Qora Qore"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=Color.new(248,248,248)
    @sprites["header"].shadowColor=Color.new(0,0,0)
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
      baseColor=Color.new(88,88,80)
      shadowColor=Color.new(168,184,184)
    else
      baseColor=Color.new(248,248,240)
      shadowColor=Color.new(72,88,88)
    end
    textPositions=[
       [_INTL("Qora Qore " + RTP2.getGameIniValue("Qortex", "Channel")),0,0,0,baseColor,shadowColor],
       [_INTL("Version " + RTP2.getGameIniValue("Qortex", "Release") + " (Release " + RTP2.getGameIniValue("Qortex", "Version") + ")"),0,32,0,baseColor,shadowColor],
       [_INTL("The Qora Qore project was started in December 2013 and"),0,96,0,baseColor,shadowColor],
       [_INTL("it is now a community-oriented project as a service."),0,128,0,baseColor,shadowColor],
       [_INTL("Work based upon the " + RTP2.getGameIniValue("Qortex", "Semester") + " codebase."),0,192,0,baseColor,shadowColor],
    ]
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbAboutScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        break
      end
    end 
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