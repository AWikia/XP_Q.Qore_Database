class PokemonTrainerCardScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    background=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/trainercardbgf"))
    if $Trainer.isFemale? && background
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/trainercardbgf",@viewport)
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/trainercardbg",@viewport)
    end
    cardexists=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/trainercardf"))
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Trainer Card"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=Color.new(248,248,248)
    @sprites["header"].shadowColor=Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["card"]=IconSprite.new(0,0,@viewport)
    if $Trainer.isFemale? && cardexists
      @sprites["card"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercardf")
    else
      @sprites["card"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercard")
    end
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["trainer"]=IconSprite.new(336,112,@viewport)
    @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
    @sprites["trainer"].x-=((@sprites["trainer"].bitmap.width-128)/2)-64
    @sprites["trainer"].y-=(@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z=2
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTrainerCardFront
    if $PokemonGlobal.trainerRecording
      $PokemonGlobal.trainerRecording.play
    end
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawTrainerCardFront
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time=_ISPRINTF("{1:02d}:{2:02d}",hour,min)
    $PokemonGlobal.startTime=pbGetTimeNow if !$PokemonGlobal.startTime
    starttime=_ISPRINTF("{1:s} {2:d}, {3:d}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    pubid=sprintf("%05d",$Trainer.publicID($Trainer.id))
    if (!isDarkMode?)
      baseColor=Color.new(88,88,80)
      shadowColor=Color.new(168,184,184)
    else
      baseColor=Color.new(248,248,240)
      shadowColor=Color.new(72,88,88)
    end
    textPositions=[
       [_INTL("Name"),34+64,64,0,baseColor,shadowColor],
       [_INTL("{1}",$Trainer.name),302+64,64,1,baseColor,shadowColor],
       [_INTL("ID No."),332+64,64,0,baseColor,shadowColor],
       [_INTL("{1}",pubid),468+64,64,1,baseColor,shadowColor],
       [_INTL("Money"),34+64,112,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money.to_s_formatted),302+64,112,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34+64,160,0,baseColor,shadowColor],
       [_ISPRINTF("{1:d}/{2:d}",$Trainer.pokedexOwned,$Trainer.pokedexSeen),302+64,160,1,baseColor,shadowColor],
       [_INTL("Time"),34+64,208,0,baseColor,shadowColor],
       [time,302+64,208,1,baseColor,shadowColor],
       [_INTL("Started"),34+64,256,0,baseColor,shadowColor],
       [starttime,302+64,256,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    x=72
    region=pbGetCurrentRegion(0) # Get the current region
    imagePositions=[]
    for i in 0...8
      if $Trainer.badges[i+region*8] && false
        imagePositions.push(["Graphics/Pictures/badges",x+64,310,i*32,region*32,32,32])
      end
      x+=48
    end
    pbDrawImagePositions(overlay,imagePositions)
  end

  def pbTrainerCard
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::X) && ($DEBUG || $TEST)
        if $game_switches[73]
          $game_switches[73]=false
          pbChangePlayer(0)
          Kernel.pbMessage(_INTL("\\f[introOak]\\rSannse:You're now playing the Boy Version"))
        else
          $game_switches[73]=true
          pbChangePlayer(1)
          Kernel.pbMessage(_INTL("\\f[introElm]\\bRappy:You're now playing the Girl Version"))
        end
        background=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/trainercardbgf"))
        if $Trainer.isFemale? && background
          @sprites["bg"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercardbgf")
        else
          @sprites["bg"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercardbg")
        end
        cardexists=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/trainercardf"))
        if $Trainer.isFemale? && cardexists
          @sprites["card"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercardf")
        else
          @sprites["card"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/trainercard")
        end
        @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
      end
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



class PokemonTrainerCard
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end
