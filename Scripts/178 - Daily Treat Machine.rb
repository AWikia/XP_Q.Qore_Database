class DailyTreatMachineScene
  attr_accessor :items
  attr_accessor :id

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport2=Viewport.new(62,37,Graphics.width-124,Graphics.height-160)
    @viewport2.z=99999
    @sprites["background2"]=IconSprite.new(0,0,@viewport)
    level = pbGetCardLevel
    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Treat Machine/bg_"+level.to_s,@viewport)
    @sprites["background2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Treat Machine/bg_machine"))
    @sprites["bg"].z = 1
    @sprites["background2"].z = 2
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Daily Treat Machine"),
       2,-18,320,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width - 104,Graphics.height - 104,@viewport2)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @items=[
            [:POTION,1],[:SUPERPOTION,1],
            [:GREATBALL,1],[:POKEBALL,1],
            [:ANTIDOTE,1],[:AWAKENING,1],
            [:BURNHEAL,1],[:ICEHEAL,1],
            [:PARALYZEHEAL,1],[:NORMALGEM,1]
            ]
    if level>=1
      @items.push(
              [:HYPERPOTION,1],[:ULTRABALL,1],
              [:REVIVE,1],[:FULLHEAL,1],
              [:RARECANDY,1],[:ABILITYCAPSULE,1],
              [:ELECTRICGEM,1],[:GRASSGEM,1],
              [:FIREGEM,1],[:WATERGEM,1]
              )
    end
    if level>=2
      @items.push(
              [:MEGAPOTION,1],[:PARKBALL,1],
              [:REPEL,1],[:SUPERREPEL,1],
              [:BELLBOX,1],[:KEYBOX,1],
              [:ETHER,1],[:ELIXIR,1],
              [:QUICKBALL,1],[:REPEATBALL,1]
              )
    end
    if level>=3
      @items.push(
              [:MAXPOTION,1],[:MAXREVIVE,1],
              [:MAXREPEL,1],[:MAXETHER,1],
              [:MAXELIXIR,1],[:NORMALBOX,1],
              [:GRASSBOX,1],[:FIREBOX,1],
              [:WATERBOX,1],[:ELECTRICBOX,1]
              )
    end
    if level>=4
      @items.push(
              [:VICIOUSCANDY,1],[:GENIEBALL,1],
              [:MEGAPOTION,2],[:MAXPOTION,2],
              [:FULLHEAL,2],[:MAXREVIVE,2],
              [:ULTRABALL,2],[:PARKBALL,2],
              [:BELLBOX,2],[:KEYBOX,2]
              )
    end
    if level>=5
      @items.push(
              [:BOTANICSMOKE,1],[:RARECANDY,2],
              [:MEGAPOTION,3],[:MAXPOTION,3],
              [:FULLHEAL,3],[:MAXREVIVE,3],
              [:ULTRABALL,3],[:PARKBALL,3],
              [:MAXPOTION,4],[:FULLHEAL,4]
              )
    end
    pbTreatMachine
    pbFadeInAndShow(@sprites) { update }
  end

  def pbTreatMachine
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
       [_INTL("Amazing! Press \"C\" to start the machine to get a reward"),258,0,2,baseColor,shadowColor],
    ]
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbDailuMachineStart
    pbSEPlay("DTM_start")
    frame=0
    until frame==20 # 60 frames per seconds
      Graphics.update
      Input.update
      @sprites["background2"].flash(Color.new(222,222,222,frame*12),20)
      frame+=1
    end
    until frame==0 # 60 frames per seconds
      Graphics.update
      Input.update
      @sprites["background2"].flash(Color.new(222,222,222,frame*12),20)
      frame-=1
    end
    @sprites["background2"].flash(Color.new(0,0,0,0),40)
    item=@items[@id%@items.length]
    Kernel.pbReceiveItem(item[0],item[1])
  end
  
  def pbDailyTreatMachineScreen
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::A)
        @QQSR="\\l[6]"
        @QQSR+=_INTL("Press Enter to start the machine. Can only be used once per day so load the game every day.")
        @QQSR+=_INTL("\\nDifferent rewards are gained each day so come back every day.")
        @QQSR+=_INTL("\\nMachine upgrades as you progress with your adventure.")
        @QQSR+=_INTL("\\nShould you have a Heart Scale, use one to get a second reward")
        Kernel.pbMessage(@QQSR)
      end
      if Input.trigger?(Input::C)
        heartscale=false
        pbSetLotteryNumber(1)
        @id=$game_variables[1].to_i
        pbDailuMachineStart          
        if $PokemonBag.pbQuantity(:HEARTSCALE)>0 && !heartscale
          if Kernel.pbConfirmMessage(_INTL("Would you like to use a Heart Scale to get a second reward?"))
            heartscale=true
            $PokemonBag.pbDeleteItem(:HEARTSCALE)
            @id+=$Trainer.publicID($Trainer.id)
            pbDailuMachineStart
          end
        end
        Kernel.pbMessage(_INTL("Load the game tomorrow for your next reward."))
        $game_variables[DTM_VARIABLE]=[pbGetTimeNow.mon, pbGetTimeNow.day]
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



class DailyTreatMachine
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbDailyTreatMachineScreen
    @scene.pbEndScene
  end
end