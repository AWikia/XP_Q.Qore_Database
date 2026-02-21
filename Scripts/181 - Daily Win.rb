class DailyWinScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new((Graphics.width/2)+14,40,(Graphics.width / 2)-28,Graphics.height-40)
    @viewport2.z=99999
    # Viewport for the Task Pane
    @viewportTask=Viewport.new(14,196,(Graphics.width / 2)-28,82)
    @viewportTask.z=99999
    femback=pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Daily Win/bg_f"))
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Win/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Win/bg",@viewport)
    end
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Daily Win"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    # Icons
    @sprites["progress"]=IconSprite.new((Graphics.width/4)-132,44,@viewportTask)
    @sprites["progress"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Win/overlay_progress_small"))
    @sprites["progress"].visible=false
    @sprites["progress_icon"]=IconSprite.new((Graphics.width/4)+70,30,@viewportTask)
    @sprites["progress_icon"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Win/icon_magnemite"))
    @sprites["progress_icon"].visible=false
    @sprites["progresstime"]=IconSprite.new((Graphics.width/4)-132+14,334,@viewport)
    @sprites["progresstime"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Win/overlay_progress"))
    @sprites["bg"].z = 1
    @sprites["progress"].z = 3
    @sprites["progress_icon"].z = 4
    @sprites["progresstime"].z = 4
    # Overlays
    @sprites["overlay"]=BitmapSprite.new((Graphics.width/2 - 28),Graphics.height - 40,@viewport2)
    @sprites["overlayTask"]=BitmapSprite.new((Graphics.width / 2)-28,82,@viewportTask)
    @sprites["overlayTask"].z = 4
    @sprites["overlayTime"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlayTime"].z = 4
    @sprites["overlayItems"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)    
    @sprites["overlayItems"].z = 4
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["overlayTask"].bitmap)
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbSetSmallFont(@sprites["overlayItems"].bitmap)
    if $game_variables[DWIN_VARIABLES[1]] == 0
      pbTimeEvent(DWIN_VARIABLES[1],1)
    end
    if $Trainer.numbadges>3
      @rewards=[
        :POKEDOLL,
        :BOTANICSMOKE,
        [:SITRUSBERRY,4],
        [:LEPPABERRY,4],
        [:LUMBERRY,4],
        [:HYPERPOTION,3],
        [:ULTRABALL,3],
        [:NORMALGEM,3],
        [:FULLHEAL,2],
        [[:GRASSGEM,:FIREGEM,:WATERGEM][$game_variables[14]],2],
        [[:FIGHTINGGEM,:PSYCHICGEM,:DARKGEM][$game_variables[14]],2],
      ]
    else
      @rewards=[
        :POKEDOLL,
        [:SITRUSBERRY,3],
        [:LUMBERRY,3],
        [:SUPERPOTION,3],
        [:GREATBALL,3],
        [:NORMALGEM,2],
        [:FULLHEAL,2],
      ]
    end
    @rewards.push([:GOLDBAR,25]) if $game_switches[218]
    @rewardclaim=false
    pbDisplayDailyWin
    pbFadeInAndShow(@sprites) { update }
    pbDailyWinRewards
  end

  def pbDisplayDailyWin
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["overlayTask"].bitmap.clear
    @sprites["overlayTime"].bitmap.clear
    @sprites["overlayItems"].bitmap.clear
    if (!isDarkMode?)
      baseColor=MessageConfig::DARKTEXTBASE
      shadowColor=MessageConfig::DARKTEXTSHADOW
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      baseColor=MessageConfig::LIGHTTEXTBASE
      shadowColor=MessageConfig::LIGHTTEXTSHADOW
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    textPositions=[
       [_INTL("How to use:"),(Graphics.width/4)-14,0,2,baseColor,shadowColor],
    ]
    text = _INTL("Win Standard Trainer Battles daily to get a stamp.")
    text2 = _INTL("Only one stamp can be awarded each day.")
    text3 = _INTL("Collect all 7 stamps to get a chest of rewards.")
    text4 = _INTL("Event resets if you have a long inactivity in the game.")
    drawTextEx(overlay,0,32,(Graphics.width/2)-28,2,text,baseColor,shadowColor)
    drawTextEx(overlay,0,112,(Graphics.width/2)-28,2,text2,baseColor,shadowColor)
    drawTextEx(overlay,0,192,(Graphics.width/2)-28,2,text3,baseColor,shadowColor)
    drawTextEx(overlay,0,272,(Graphics.width/2)-28,2,text4,baseColor,shadowColor)
    pbDrawTextPositions(overlay,textPositions)
    # Show the Item Pane
    imagepos=[]
    imageposAMT=[]
    itemlength=@rewards.length
    itemlength2=(itemlength.to_f / 2.0).round
    multiamt = 1
    basex=(Graphics.width/4)-140
    basey=58
    id=0
    for i in 0...2
      x = 116 - ([(itemlength2 - 1),5].min * 24)
      for j in 0...itemlength2
        next if !@rewards[id]
        if @rewards[id].is_a?(Array)
          item=@rewards[id][0]
          amt=@rewards[id][1]
        else
          item=@rewards[id]
          amt=1
        end
        @animbitmap=AnimatedBitmap.new( pbItemIconFile( getID(PBItems,item)) )
        offsetX=(48 - @animbitmap.bitmap.width) / 2
        offsetY=(48 - @animbitmap.bitmap.height) / 2
        @animbitmap.dispose
        imagepos.push([pbItemIconFile( getID(PBItems,item)),basex+x.ceil+offsetX,basey+14+offsetY,0,0,-1,-1])
        if amt>1
          imageposAMT.push([amt.to_s,basex+32+x.ceil,basey+34,2,Color.new(242,242,242),Color.new(12,12,12),true])
          imagepos.push(["Graphics/UI/Daily Win/icon_amount",basex+x.ceil,basey+14,0,0,-1,-1])
        end
        x+=(120.0/[(itemlength2 - 1),5].max)*2
        id+=1
      end
      itemlength2=itemlength-itemlength2 if i==0
      basey+=48
    end
    pbDrawImagePositions(@sprites["overlayItems"].bitmap,imagepos)
    pbDrawTextPositions(@sprites["overlayItems"].bitmap,imageposAMT)
    # Show the Task Pane
    progress=[]
    shadowfract=$game_variables[DWIN_VARIABLES[0]]*100/7
    variant=($Trainer && $Trainer.isFemale?) ? 1 : 0
    suffix=($Trainer && $Trainer.isFemale?) ? "_f" : ""
    progress.push(["Graphics/UI/"+getDarkModeFolder+"/Daily Win/overlay_progress_small",@sprites["progress"].x,@sprites["progress"].y,0,0,-1,-1])
    progress.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar_small",@sprites["progress"].x+8,@sprites["progress"].y+4,0,0,(shadowfract*1.98).floor,-1])
    progress.push(["Graphics/UI/Daily WIn/icon_stamps",@sprites["progress"].x-28,@sprites["progress"].y-6,0,34*variant,34,34])
    progress.push(["Graphics/UI/Daily Win/icon_chest"+suffix,@sprites["progress_icon"].x,@sprites["progress_icon"].y,0,0,-1,-1])
    textpos=[
       [_INTL("{1}/7",[$game_variables[DWIN_VARIABLES[0]],7].min),(Graphics.width/4)-39+15,40,2,base2,shadow2,true],
    ]
    pbDrawShadowText(@sprites["overlayTask"].bitmap,0,0,(Graphics.width / 2)-28,38,"Collect Daily Stamps",baseColor,shadowColor,1)
    pbDrawImagePositions(@sprites["overlayTask"].bitmap,progress)
    pbDrawTextPositions(@sprites["overlayTask"].bitmap,textpos)
    # Show the Time Pane
    progressTime=[]
    value=$game_variables[DWIN_VARIABLES[1]]
    remtime = 86400
    shadowfract2=[(value[1]-(pbGetTimeNow.to_f - value[0]))*100/remtime,0].max
    progressTime.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",@sprites["progresstime"].x+8,@sprites["progresstime"].y+4,0,0,(shadowfract2*2.48).floor,-1])
    progressTime.push(["Graphics/UI/Daily Win/icon_clock",@sprites["progresstime"].x-28,@sprites["progresstime"].y-6,0,0,-1,-1])
    if shadowfract2==0
      timelabel=_INTL("Ready to claim")
    else
      timelabel=pbTimeEventRemainingTime(DWIN_VARIABLES[1])
    end
    textposTime=[
       [_INTL("Daily Win Chest Rewards"),(Graphics.width/4),40,2,baseColor,shadowColor],
       [_INTL("Next Daily Stamp"),(Graphics.width/4),294,2,baseColor,shadowColor],
       [_INTL("{1}",timelabel),(Graphics.width/4)+15,330,2,base2,shadow2,true],
    ]
    pbSetSystemFont(@sprites["overlayTime"].bitmap)
    pbDrawImagePositions(@sprites["overlayTime"].bitmap,progressTime)
    pbDrawTextPositions(@sprites["overlayTime"].bitmap,textposTime)
  end
  
  def pbDailyWinRewards
    if $game_variables[DWIN_VARIABLES[0]]>6
      pbSEPlay("Item3",100,80)
      Kernel.pbMessage(_INTL("All Daily Stamps collected. Here's your rewards"))
      for i in @rewards
        if i.is_a?(Array)
          item=i[0]
          amt=i[1]
        else
          item=i
          amt=1
        end
        Kernel.pbReceiveItem(item,amt)
      end
      Kernel.pbMessage(_INTL("Earn 7 more daily stamps to earn them again."))
      $game_variables[DWIN_VARIABLES[0]]=0
      $game_variables[DWIN_VARIABLES[2]]=0
      @rewardclaim=true
    end
  end

  def pbDailyWinScreen
    loop do
      Graphics.update
      Input.update
      self.update
      break if @rewardclaim
      if Input.trigger?(Input::B)
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



class DailyWin
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbDailyWinScreen
    @scene.pbEndScene
  end
end