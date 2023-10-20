class PokemonOutdatedSystemScreenScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new(62,97,Graphics.width-124,Graphics.height-160)
    @viewport2.z=99999
    @sprites["background2"]=IconSprite.new(0,0,@viewport)
    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/About/bg_f"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/About/bg_f",@viewport)
      @sprites["background2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/About/bg_f_blank"))
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/About/bg",@viewport)
      @sprites["background2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/About/bg_blank"))
    end
    @sprites["bg"].z = 1
    @sprites["background2"].z = 2
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Unsupported Operating System"),
       2,-18,320,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width - 104,Graphics.height - 104,@viewport2)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDisplaySysReqScreen
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDisplaySysReqScreen
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
       [_INTL("Qora Qore is no longer supported in this machine!"),258,0,2,baseColor,shadowColor],
       [_INTL("In order to continue exploring the latest development"),0,64,0,baseColor,shadowColor],
       [_INTL("done to Qore Qore, you must upgrade your Operating"),0,96,0,baseColor,shadowColor],
       [_INTL("System to at least Windows 10 Build 10240 or higher "),0,128,0,baseColor,shadowColor],
       [_INTL("as Microsoft no longer supports your currently running"),0,160,0,baseColor,shadowColor],
       [_INTL("Operating System with security updates."),0,192,0,baseColor,shadowColor],
    ]
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbSysReqScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        break
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



class PokemonOutdatedSystemScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbSysReqScreen
    @scene.pbEndScene
  end
end