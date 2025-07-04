################################################################################
# "Daily Slot Machine" mini-game
# By Qora Qore Telecommunities
# Based on Slot Machine minigame by Maruno
#-------------------------------------------------------------------------------
# Run with:      pbDailySlotMachine(1)
# - The number is either 0 (easy), 1 (default) or 2 (hard).
################################################################################
class DailySlotMachineReel < BitmapSprite
  attr_accessor :reel
  attr_accessor :toppos
  attr_accessor :spinning
  attr_accessor :stopping
  attr_accessor :slipping
  SCROLLSPEED = 16 # Must be a divisor of 48
  ICONSPOOL = [[0,0,0,0,1,1,2,2,3,3,3,4,4,4,5,5,6,6,7], # 0 - Easy
               [0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7],     # 1 - Medium (default)
               [0,0,1,1,1,2,2,2,3,3,4,4,5,6,7]          # 2 - Hard
              ]
  SLIPPING = [0,0,0,0,0,0,1,1,1,2,2,3]

  def initialize(x,y,difficulty=1)
    @viewport=Viewport.new(x+64,y,64,144)
    @viewport.z=99999
    super(64+64,144,@viewport)
    @reel=[]
    for i in 0...ICONSPOOL[difficulty].length
      @reel.push(ICONSPOOL[difficulty][i])
    end
    @reel.shuffle!
    @toppos=0
    @spinning=false
    @stopping=false
    @slipping=0
    @index=rand(@reel.length)
    if difficulty>1
      @images=AnimatedBitmap.new(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/imagesElite"))
    else
      @images=AnimatedBitmap.new(_INTL("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/images"))
    end
    @shading=AnimatedBitmap.new(_INTL("Graphics/UI/Daily Slot Machine/ReelOverlay"))
    update
  end

  def startSpinning
    @spinning=true
  end

  def stopSpinning(noslipping=false)
    @stopping=true
    @slipping=SLIPPING[rand(SLIPPING.length)]
    @slipping=0 if noslipping
  end

  def showing
    array=[]
    for i in 0...3
      num=@index-i
      num+=@reel.length if num<0
      array.push(@reel[num])
    end
    return array   # [0] = top, [1] = middle, [2] = bottom
  end

  def update
    self.bitmap.clear
    if @toppos==0 && @stopping && @slipping==0
      @spinning=@stopping=false
    end
    if @spinning
      @toppos+=SCROLLSPEED
      if @toppos>0
        @toppos-=48
        @index=(@index+1)%@reel.length
        @slipping-=1 if @slipping>0
      end
    end
    for i in 0...4
      num=@index-i
      num+=@reel.length if num<0
      self.bitmap.blt(0,@toppos+i*48,@images.bitmap,Rect.new(@reel[num]*64,0,64,48))
    end
    self.bitmap.blt(0,0,@shading.bitmap,Rect.new(0,0,64,144))
  end
end



class DailySlotMachineScore < BitmapSprite
  attr_reader :score

  def initialize(x,y,score=0)
    @viewport=Viewport.new(x,y,70,22)
    @viewport.z=99999
    super(70,22,@viewport)
    @numbers=AnimatedBitmap.new(_INTL("Graphics/UI/Daily Slot Machine/numbers"))
    self.score=score
  end

  def score=(value)
    @score=value
    @score=MAXCOINS if @score>MAXCOINS
    refresh
  end

  def refresh
    self.bitmap.clear
    for i in 0...5
      digit=(@score/(10**i))%10 # Least significant digit first
      self.bitmap.blt(14*(4-i),0,@numbers.bitmap,Rect.new(digit*14,0,14,22))
    end
  end
end



class DailySlotMachineScene
  attr_accessor :gameRunning
  attr_accessor :gameEnd
  attr_accessor :wager
  attr_accessor :replay

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbPayout(difficulty)
    @replay=false
    item=0
    bonus=0
    # Get reel pictures
    reel=@sprites["reel"].showing
    combinations=[reel[1]] # Center
    for i in 0...combinations.length
      case combinations[i]
      when 0
        item=[getID(PBItems,:SUPERPOTION),getID(PBItems,:SUPERPOTION),getID(PBItems,:MEGAPOTION)][difficulty]
      when 1
        item=[getID(PBItems,:GREATBALL),getID(PBItems,:GREATBALL),getID(PBItems,:PARKBALL)][difficulty]
      when 2
        item=[getID(PBItems,:ANTIDOTE),getID(PBItems,:ANTIDOTE),getID(PBItems,:FULLHEAL)][difficulty]
      when 3
        item=[getID(PBItems,:REVIVE),getID(PBItems,:REVIVE),getID(PBItems,:MAXREVIVE)][difficulty]
      when 4
        item=[getID(PBItems,:RARECANDY),getID(PBItems,:RARECANDY),getID(PBItems,:VICIOUSCANDY)][difficulty]
      when 5 # Blue 777
        bonus=2 if bonus<2
      when 6 # Red 777
        bonus=1 if bonus<1
      when 7
        item=[getID(PBItems,:NORMALGEM),getID(PBItems,:NORMALGEM),getID(PBItems,:NORMALBOX)][difficulty]
      else
        item=getID(PBItems,:ORANBERRY)
      end
    end
    frame=0
    if bonus>0
      pbMEPlay("SlotsBigWin")
    else
      pbMEPlay("SlotsWin")
    end
    # Show winning animation
    until frame==180 # 60 frames per seconds
      Graphics.update
      Input.update
      update
      @sprites["window2"].bitmap.clear if @sprites["window2"].bitmap
      @sprites["window1"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/win"))
      @sprites["window1"].src_rect.set(152*((frame/5)%4),0,152,208)
      if bonus>0
        @sprites["window2"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/bonus"))
        @sprites["window2"].src_rect.set(152*(bonus-1),0,152,208)
      end
      @sprites["light1"].visible=true
      @sprites["light1"].src_rect.set(0,26*((frame/5)%4),96,26)
      @sprites["row"].visible=(frame%10<5)
      frame+=1
    end
    @sprites["light1"].visible=false
    @sprites["window1"].src_rect.set(0,0,152,208)
    # Pay out
    if bonus>0
	  items= [
	  [getID(PBItems,:SUPERPOTION),getID(PBItems,:GREATBALL),getID(PBItems,:ANTIDOTE),getID(PBItems,:REVIVE),getID(PBItems,:RARECANDY),getID(PBItems,:NORMALGEM)],
	  [getID(PBItems,:SUPERPOTION),getID(PBItems,:GREATBALL),getID(PBItems,:ANTIDOTE),getID(PBItems,:REVIVE),getID(PBItems,:RARECANDY),getID(PBItems,:NORMALGEM)],
	  [getID(PBItems,:MEGAPOTION),getID(PBItems,:PARKBALL),getID(PBItems,:FULLHEAL),getID(PBItems,:MAXREVIVE),getID(PBItems,:VICIOUSCANDY),getID(PBItems,:NORMALBOX)]
	    ][difficulty]
	  for item in items
	    Kernel.pbReceiveItem(item,bonus)
	  end
    else
	  Kernel.pbReceiveItem(item)
    end
    20.times do
      Graphics.update
      Input.update
      update
    end
    @wager=0
  end

  def pbStartScene(difficulty)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    if difficulty>1
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Slot Machine/bgElite",@viewport)
	  @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Daily Slot Machine - Elite Challenge"),
       2,-18,384,64,@viewport)
    else
      addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/Daily Slot Machine/bg",@viewport)
	  @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Daily Slot Machine"),
       2,-18,384,64,@viewport)
    end
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["reel"]=DailySlotMachineReel.new(144,112,difficulty)

      @sprites["button"]=IconSprite.new(68+80+64,260,@viewport)
      if difficulty>1
        @sprites["button"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/buttonf"))
      else
        @sprites["button"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/button"))        
      end
      @sprites["button"].visible=false

  
      @sprites["row"]=IconSprite.new(82+64,170,@viewport)
      @sprites["row"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/line1"))
      @sprites["row"].visible=false

    @sprites["light1"]=IconSprite.new(128+64,32,@viewport)
    @sprites["light1"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Daily Slot Machine/lights"))
    @sprites["light1"].visible=false
    @sprites["window1"]=IconSprite.new(278+64,96,@viewport)
    @sprites["window1"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/insert"))
    @sprites["window1"].src_rect.set(0,0,152,208)
    @sprites["window2"]=IconSprite.new(278+64,96,@viewport)
    @sprites["credit"]=DailySlotMachineScore.new(318+64,66,$PokemonGlobal.coins)
    @wager=0
    update
    pbFadeInAndShow(@sprites)
  end

  def pbMain(difficulty)
    frame=0
    ret=false
    loop do
      Graphics.update
      Input.update
      update
      @sprites["window1"].bitmap.clear if @sprites["window1"].bitmap
      @sprites["window2"].bitmap.clear if @sprites["window2"].bitmap
      if $PokemonGlobal.coins==0
        Kernel.pbMessage(_INTL("You've run out of Coins.\nGame over!"))
        break
      elsif @gameRunning # Reels are spinning
        @sprites["window1"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/stop"))
        @sprites["window1"].src_rect.set(152*((frame/10)%4),0,152,208)
        if Input.trigger?(Input::C)
          pbSEPlay("SlotsStop")
          if @sprites["reel"].spinning
            @sprites["reel"].stopSpinning(@replay)
            @sprites["button"].visible=true
          end
        end
        if !@sprites["reel"].spinning
          @gameEnd=true
          @gameRunning=false
        end
      elsif @gameEnd # Reels have been stopped
        pbPayout(difficulty)
        @gameEnd=false
        ret=true
        break
      else # Awaiting coins for the next spin
        @sprites["window1"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/insert"))
        @sprites["window1"].src_rect.set(152*((frame/15)%2),0,152,208)
        if @wager>0
          @sprites["window2"].setBitmap(sprintf("Graphics/UI/Daily Slot Machine/press"))
          @sprites["window2"].src_rect.set(152*((frame/15)%2),0,152,208)
        end
        if Input.trigger?(Input::DOWN) && @wager<1 && @sprites["credit"].score>0
          pbSEPlay("SlotsCoin")
          @wager+=1
          @sprites["credit"].score-=[3,3,30][difficulty]
          if @wager>=1
            @sprites["row"].visible=true
          end
        elsif @wager>=1 || (@wager>0 && @sprites["credit"].score==0) ||
              ((Input.trigger?(Input::C)) && @wager>0)
          @sprites["reel"].startSpinning
          frame=0
          @gameRunning=true
        elsif (Input.trigger?(Input::B)) && @wager==0
          ret=false
          break
        end
      end
      frame=(frame+1)%120
    end
    $PokemonGlobal.coins=@sprites["credit"].score
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class DailySlotMachine
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(difficulty)
	ret=false
    @scene.pbStartScene(difficulty)
    ret=@scene.pbMain(difficulty)
    @scene.pbEndScene
    return ret
  end
end



def pbDailySlotMachine(difficulty=1) # Difficulty of 2 = Elite Challenge
  ret=false
  if hasConst?(PBItems,:COINCASE) && $PokemonBag.pbQuantity(:COINCASE)<=0
    Kernel.pbMessage(_INTL("It's a Slot Machine."))
  elsif $PokemonGlobal.coins<[3,3,30][difficulty]
    Kernel.pbMessage(_INTL("You don't have enough Coins to play!"))
  else
    scene=DailySlotMachineScene.new
    screen=DailySlotMachine.new(scene)
    pbFadeOutIn(99999) {
       ret=screen.pbStartScreen(difficulty)
    }
  end
  return ret
end