class PokemonBattleStatsScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(frommap=false)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new(((Graphics.width-512)/2)+16,40,480,Graphics.height-40)
    @viewport2.z=99999
    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/About/bg_f"))
    @sprites["bg"]=IconSprite.new(0,0,@viewport) # Avoid issues with animations
#    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Battle Stats/bg",@viewport)
    @sprites["bg"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Battle Stats/bg"))
    @sprites["background2"]=IconSprite.new(0,0,@viewport)
    @sprites["background2"].z = 2
    @sprites["background2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Battle Stats/mapheader_bg"))
    if !frommap
      @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Battle Stats"),
         2,-18,128,64,@viewport)
      @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
      @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
      @sprites["header"].windowskin=nil
      @sprites["background2"].visible=false
    else
      @sprites["background2"].visible=true
    end
    @maxpages=($PokemonGlobal.pokebox.length / 10.0).ceil - 1
    @page=0
    @sprites["overlay"]=BitmapSprite.new(480,Graphics.height - 40,@viewport2)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = Graphics.width/2 - 14
    @sprites["uparrow"].y = 16
    @sprites["uparrow"].z = 3
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/"+getAccentFolder+"/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = Graphics.width/2 - 14
    @sprites["downarrow"].y = Graphics.height - 32
    @sprites["downarrow"].z = 3
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = @page != @maxpages
    pbDisplayBattleStats
    pbFadeInAndShow(@sprites,nil,frommap) { update }  if !frommap
    Graphics.transition(0) if frommap
  end

  def pbDisplayBattleStats
    @sprites["uparrow"].visible = @page != 0
    @sprites["downarrow"].visible = @page != @maxpages
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    imagepos=[]
    textPositions=[
       [_INTL("Battle Statistics for {1}:",$Trainer.name),240,0,2,baseColor,shadowColor],
    ]
    y=32
    offset=10*@page
    maxitems=$PokemonGlobal.pokebox.length
    cellbitmap=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Battle Stats/overlay_cell")
    srcrect=Rect.new(0,0,480,28)
    for i in 0+offset...[10+offset,maxitems].min
      taskname=_INTL("{1}: ",$PokemonGlobal.pokeboxNames3[i])
      textPositions.push([_INTL("{1} ",$PokemonGlobal.pokebox[i]),480,y,1,baseColor,shadowColor])
      overlay.blt(0,y+2,cellbitmap.bitmap,srcrect)
      pbDrawShadowText(@sprites["overlay"].bitmap,6,y,380,32,taskname,baseColor,nil)
      y+=30
    end
    cellbitmap.dispose
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbBattleStats(frommap=false)
    action=0
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        action=0
        break
      end
      if Input.trigger?(Input::DOWN) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page+1)%(@maxpages+1)
        pbDisplayBattleStats
      end
      if Input.trigger?(Input::UP) && @maxpages>0
        pbPlayCursorSE()
        @page=(@page-1)%(@maxpages+1)
        pbDisplayBattleStats
      end
      if Input.trigger?(Input::L) && frommap
        pbPlayCursorSE()
        action=-1
        break
      end
    end
    return action
  end

  def pbEndScene(frommap=false)
    pbFadeOutAndHide(@sprites,frommap) { update }  if !frommap
    Graphics.freeze if frommap
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonBattleStats
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(frommap=false)
    @scene.pbStartScene(frommap)
    ret=@scene.pbBattleStats(frommap)
    @scene.pbEndScene(frommap)
    return ret
  end
end