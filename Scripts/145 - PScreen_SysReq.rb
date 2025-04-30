class PokemonSysReqScreenScene
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
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("System Requirements"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
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
       [_INTL("Recommended requirements for Q.Qore:"),258,0,2,baseColor,shadowColor],
       [_INTL("OS: "),0,32,0,baseColor,shadowColor],
       [_INTL("Windows 10 Build 10240 or higher "),519,32,1,baseColor,shadowColor],
       [_INTL("RAM: "),0,64,0,baseColor,shadowColor],
       [_INTL("2GB or higher "),519,64,1,baseColor,shadowColor],
       [_INTL("CPU: "),0,96,0,baseColor,shadowColor],
       [_INTL("Modern 2.7GHz or higher "),519,96,1,baseColor,shadowColor],
       [_INTL("Color Depth: "),0,128,0,baseColor,shadowColor],
       [_INTL("32 bits per channel "),519,128,1,baseColor,shadowColor],
       [_INTL("Disk Space: "),0,160,0,baseColor,shadowColor],
       [_INTL("4GB or higher "),519,160,1,baseColor,shadowColor],
       [_INTL("Dots per inch: "),0,192,0,baseColor,shadowColor],
       [_INTL("96 or higher "),519,192,1,baseColor,shadowColor],
    ]
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbSysReqScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
      if Input.press?(Input::CTRL) && Input.press?(Input::C)
        clip = _INTL("Recommended requirements for Q.Qore:")
        clip+= _INTL("\nOS: Windows 10 Build 10240 or higher")
        clip+= _INTL("\nRAM: 2GB or higher")
        clip+= _INTL("\nCPU: Modern 2.7GHz or higher")
        clip+= _INTL("\nColor Depth: 32 bits per channel")
        clip+= _INTL("\nDisk Space: 4GB or higher")
        clip+= _INTL("\nDots per inch: 96 or higher")
        clipcopy(clip)
        Kernel.pbMessage(_INTL("Copied System Requirements Screen Contents to the clipboard"))
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



class PokemonSysReqScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbSysReqScreen
    @scene.pbEndScene
  end
end