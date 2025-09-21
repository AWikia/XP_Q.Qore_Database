=begin
-  def pbChooseNewEnemy(index,party)
Use this method to choose a new Pokémon for the enemy
The enemy's party is guaranteed to have at least one 
choosable member.
index - Index to the battler to be replaced (use e.g. @battle.battlers[index] to 
access the battler)
party - Enemy's party

- def pbWildBattleSuccess
This method is called when the player wins a wild Pokémon battle.
This method can change the battle's music for example.

- def pbTrainerBattleSuccess
This method is called when the player wins a Trainer battle.
This method can change the battle's music for example.

- def pbFainted(pkmn)
This method is called whenever a Pokémon faints.
pkmn - PokeBattle_Battler object indicating the Pokémon that fainted

- def pbChooseEnemyCommand(index)
Use this method to choose a command for the enemy.
index - Index of enemy battler (use e.g. @battle.battlers[index] to 
access the battler)

- def pbCommandMenu(index)
Use this method to display the list of commands and choose
a command for the player.
index - Index of battler (use e.g. @battle.battlers[index] to 
access the battler)
Return values:
0 - Fight
1 - Pokémon
2 - Bag
3 - Run
=end

#===============================================================================
# Command menu (Fight/Pokémon/Bag/Run)
#===============================================================================
class CommandMenuDisplay
  attr_accessor :mode

  def initialize(viewport=nil,bg="",dark=true)
    @display=nil
    if PokeBattle_SceneConstants::USECOMMANDBOX
      @display=IconSprite.new(0,Graphics.height-96,viewport)
      @display.setBitmap("Graphics/UI/Battle/overlay_command")
    end
    @window=Window_CommandPokemon.newWithSize([],
       Graphics.width-240,Graphics.height-96,240,96,viewport)
    @window.columns=2
    @window.columnSpacing=4
    @window.ignore_input=true
    @msgbox=Window_UnformattedTextPokemon.newWithSize(
       "",16,Graphics.height-96+2,220+64,96,viewport)
    if dark
      @msgbox.baseColor=PokeBattle_SceneConstants::MESSAGEBASECOLOR
      @msgbox.shadowColor=PokeBattle_SceneConstants::MESSAGESHADOWCOLOR
    else
      @msgbox.baseColor=PokeBattle_SceneConstants::MESSAGEBASECOLORL
      @msgbox.shadowColor=PokeBattle_SceneConstants::MESSAGESHADOWCOLORL
    end
    @msgbox.windowskin=nil
    @title=""
    @buttons=nil
    if PokeBattle_SceneConstants::USECOMMANDBOX
      @window.opacity=0
      @window.x=Graphics.width
      @buttons=CommandMenuButtons.new(self.index,self.mode,viewport)
    end
  end

  def x; @window.x; end
  def x=(value)
    @window.x=value
    @msgbox.x=value
    @display.x=value if @display
    @buttons.x=value if @buttons
  end

  def y; @window.y; end
  def y=(value)
    @window.y=value
    @msgbox.y=value
    @display.y=value if @display
    @buttons.y=value if @buttons
  end

  def z; @window.z; end
  def z=(value)
    @window.z=value
    @msgbox.z=value
    @display.z=value if @display
    @buttons.z=value+1 if @buttons
  end

  def ox; @window.ox; end
  def ox=(value)
    @window.ox=value
    @msgbox.ox=value
    @display.ox=value if @display
    @buttons.ox=value if @buttons
  end

  def oy; @window.oy; end
  def oy=(value)
    @window.oy=value
    @msgbox.oy=value
    @display.oy=value if @display
    @buttons.oy=value if @buttons
  end

  def visible; @window.visible; end
  def visible=(value)
    @window.visible=value
    @msgbox.visible=value
    @display.visible=value if @display
    @buttons.visible=value if @buttons
  end

  def color; @window.color; end
  def color=(value)
    @window.color=value
    @msgbox.color=value
    @display.color=value if @display
    @buttons.color=value if @buttons
  end

  def disposed?
    return @msgbox.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?
    @msgbox.dispose
    @window.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
  end

  def index; @window.index; end
  def index=(value); @window.index=value; end

  def setTexts(value)
    @msgbox.text=value[0]
    commands=[]
    for i in 1..4
      commands.push(value[i]) if value[i] && value[i]!=nil
    end
    @window.commands=commands
  end

  def refresh
    @msgbox.refresh
    @window.refresh
    @buttons.refresh(self.index,self.mode) if @buttons
  end
  
  def update
    @msgbox.update
    @window.update
    @display.update if @display
    @buttons.update(self.index,self.mode) if @buttons
  end
end



class CommandMenuButtons < BitmapSprite
  def initialize(index=0,mode=0,viewport=nil)
    super(320,96,viewport)
    self.x=Graphics.width-320 # Change
    self.y=Graphics.height-96
    @mode=mode
    @buttonbitmap=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/cursor_command"))
    refresh(index,mode)
  end

  def dispose
    @buttonbitmap.dispose
    super
  end

  def update(index=0,mode=0)
    refresh(index,mode)
  end

  def refresh(index,mode=0)
    self.bitmap.clear
    @mode=mode
    cmdarray=[0,2,1,3]
    case @mode
    when 1
      cmdarray=[0,2,1,4] # Use "Call"
    when 2
      cmdarray=[5,7,6,3] # Safari Zone battle
    when 3
      cmdarray=[0,8,1,3] # Bug Catching Contest
    when 4
      cmdarray=[0,2,1,9] # Use "Cancel"
    end
    for i in 0...4
      next if i==index
      x=((i%2)==0) ? 0 : 126 + 30
      y=((i/2)==0) ? 6 : 48
      self.bitmap.blt(x,y,@buttonbitmap.bitmap,Rect.new(0,cmdarray[i]*46,130+30,46))
    end
    for i in 0...4
      next if i!=index
      x=((i%2)==0) ? 0 : 126 + 30
      y=((i/2)==0) ? 6 : 48
      self.bitmap.blt(x,y,@buttonbitmap.bitmap,Rect.new(130+30,cmdarray[i]*46,130+30,46))
    end
  end
end



#===============================================================================
# Fight menu (choose a move)
#===============================================================================
class FightMenuDisplay
  attr_reader :battler
  attr_reader :index
  attr_accessor :megaButton

  def initialize(battler,viewport=nil,bg="bg",dark=true)
    @display=nil
    if PokeBattle_SceneConstants::USEFIGHTBOX
      @display=IconSprite.new(0,Graphics.height-96,viewport)
      @display.setBitmap("Graphics/UI/Battle/overlay_fight")
    end
    @window=Window_CommandPokemon.newWithSize([],0,Graphics.height-96,320,96,viewport)
    @window.columns=2
    @window.columnSpacing=4
    @window.ignore_input=true
    pbSetNarrowFont(@window.contents)
    @info=Window_AdvancedTextPokemon.newWithSize(
       "",320,Graphics.height-96,Graphics.width-320,96,viewport)
    pbSetNarrowFont(@info.contents)
    if dark
      @ctag=shadowctag(PokeBattle_SceneConstants::MENUBASECOLOR,
                       PokeBattle_SceneConstants::MENUSHADOWCOLOR)
    else
      @ctag=shadowctag(PokeBattle_SceneConstants::MENUBASECOLORL,
                       PokeBattle_SceneConstants::MENUSHADOWCOLORL)
    end
    @buttons=nil
    @battler=battler
    @index=0
    @megaButton=0 # 0=don't show, 1=show, 2=pressed
    if PokeBattle_SceneConstants::USEFIGHTBOX
      @window.opacity=0
      @window.x=Graphics.width
      @info.opacity=0
      @info.x=Graphics.width+Graphics.width-96
      @buttons=FightMenuButtons.new(self.index,nil,viewport)
    end
    refresh
  end

  def x; @window.x; end
  def x=(value)
    @window.x=value
    @info.x=value
    @display.x=value if @display
    @buttons.x=value if @buttons
  end

  def y; @window.y; end
  def y=(value)
    @window.y=value
    @info.y=value
    @display.y=value if @display
    @buttons.y=value if @buttons
  end

  def z; @window.z; end
  def z=(value)
    @window.z=value
    @info.z=value
    @display.z=value if @display
    @buttons.z=value+1 if @buttons
  end

  def ox; @window.ox; end
  def ox=(value)
    @window.ox=value
    @info.ox=value
    @display.ox=value if @display
    @buttons.ox=value if @buttons
  end

  def oy; @window.oy; end
  def oy=(value)
    @window.oy=value
    @info.oy=value
    @display.oy=value if @display
    @buttons.oy=value if @buttons
  end

  def visible; @window.visible; end
  def visible=(value)
    @window.visible=value
    @info.visible=value
    @display.visible=value if @display
    @buttons.visible=value if @buttons
  end

  def color; @window.color; end
  def color=(value)
    @window.color=value
    @info.color=value
    @display.color=value if @display
    @buttons.color=value if @buttons
  end

  def disposed?
    return @info.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?
    @info.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
    @window.dispose
  end

  def battler=(value)
    @battler=value
    refresh
  end

  def setIndex(value)
    if @battler && @battler.moves[value].id!=0
      @index=value
      @window.index=value
      refresh
      return true
    end
    return false
  end

  def refresh
    return if !@battler
    commands=[]
    for i in 0...4
      break if @battler.moves[i].id==0
      commands.push(@battler.moves[i].name)
    end
    @window.commands=commands
    selmove=@battler.moves[@index]
    movetype=PBTypes.getName(selmove.type)
    if selmove.totalpp==0
      @info.text=_ISPRINTF("{1:s}PP: ---<br>TYPE/{2:s}",@ctag,movetype)
    else
      @info.text=_ISPRINTF("{1:s}PP: {2: 2d}/{3: 2d}<br>TYPE/{4:s}",
         @ctag,selmove.pp,selmove.totalpp,movetype)
    end
    @buttons.refresh(self.index,@battler ? @battler.moves : nil,@megaButton) if @buttons
  end

  def update
    @info.update
    @window.update
    @display.update if @display
    if @buttons
      moves=@battler ? @battler.moves : nil
      @buttons.update(self.index,moves,@megaButton)
    end
  end
end



class FightMenuButtons < BitmapSprite
  UPPERGAP=46

  def initialize(index=0,moves=nil,viewport=nil)
    super(Graphics.width,96+UPPERGAP,viewport)
    self.x=0
    self.y=Graphics.height-96-UPPERGAP
    pbSetNarrowFont(self.bitmap)
    @buttonbitmap=AnimatedBitmap.new("Graphics/UI/Battle/cursor_fight")
    @catbitmap=AnimatedBitmap.new("Graphics/UI/category")
    @typebitmap=AnimatedBitmap.new("Graphics/UI/types")
    @megaevobitmap=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/cursor_mega"))
    refresh(index,moves,0)
  end

  def dispose
    @buttonbitmap.dispose
    @catbitmap.dispose
    @typebitmap.dispose
    @megaevobitmap.dispose
    super
  end

  def update(index=0,moves=nil,megaButton=0)
    refresh(index,moves,megaButton)
  end

  def refresh(index,moves,megaButton)
    return if !moves
    self.bitmap.clear
    moveboxes=_INTL("Graphics/UI/Battle/cursor_fight")
    textpos=[]
    for i in 0...4
      next if i==index
      next if moves[i].id==0
      x=((i%2)==0) ? 4 : 192
      y=((i/2)==0) ? 6 : 48
      y+=UPPERGAP
      self.bitmap.blt(x,y,@buttonbitmap.bitmap,Rect.new(0,moves[i].type*46,192,46))
      textpos.push([_INTL("{1}",moves[i].name),x+96,y+4,2,
         Color.new(242,242,242),Color.new(12,12,12),1])
    end
    if $isDarkMessage
      ppcolors=[
         PokeBattle_SceneConstants::PPTEXTBASECOLOR,PokeBattle_SceneConstants::PPTEXTSHADOWCOLOR,
         PokeBattle_SceneConstants::PPTEXTBASECOLOR,PokeBattle_SceneConstants::PPTEXTSHADOWCOLOR,
         PokeBattle_SceneConstants::PPTEXTBASECOLORYELLOW,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORYELLOW,
         PokeBattle_SceneConstants::PPTEXTBASECOLORORANGE,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORORANGE,
         PokeBattle_SceneConstants::PPTEXTBASECOLORRED,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORRED
      ]
      textbase = PokeBattle_SceneConstants::MENUBASECOLOR
      textshadow = PokeBattle_SceneConstants::MENUSHADOWCOLOR
    else
      ppcolors=[
         PokeBattle_SceneConstants::PPTEXTBASECOLORL,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORL,
         PokeBattle_SceneConstants::PPTEXTBASECOLORL,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORL,
         PokeBattle_SceneConstants::PPTEXTBASECOLORYELLOW,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORYELLOW,
         PokeBattle_SceneConstants::PPTEXTBASECOLORORANGE,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORORANGE,
         PokeBattle_SceneConstants::PPTEXTBASECOLORRED,PokeBattle_SceneConstants::PPTEXTSHADOWCOLORRED
      ]
      textbase = PokeBattle_SceneConstants::MENUBASECOLORL
      textshadow = PokeBattle_SceneConstants::MENUSHADOWCOLORL
    end
    for i in 0...4
      next if i!=index
      next if moves[i].id==0
      x=((i%2)==0) ? 4 : 192
      y=((i/2)==0) ? 6 : 48
      mbasedmg=moves[i].basedamage
      if mbasedmg==1
        mbasedmg="???"
      elsif mbasedmg==0
        mbasedmg="---"
      end
      maccuracy=moves[i].accuracy
      if maccuracy==0
        maccuracy="---"
      end
      y+=UPPERGAP
      
      self.bitmap.blt(x,y,@buttonbitmap.bitmap,Rect.new(192,moves[i].type*46,192,46))
      self.bitmap.blt(416+108,20+UPPERGAP,@catbitmap.bitmap,Rect.new(64*0,moves[i].category*28,64,28))
      self.bitmap.blt(416,20+UPPERGAP,@typebitmap.bitmap,Rect.new(64*0,moves[i].type*28,64,28))
      textpos.push([_INTL("{1}",moves[i].name),x+96,y+4,2,
         @typebitmap.bitmap.get_pixel(2,(moves[i].type*28)+2),@typebitmap.bitmap.get_pixel(2,(moves[i].type*28)+27),1])
      if moves[i].totalpp>0
        ppfraction=(4.0*moves[i].pp/moves[i].totalpp).ceil
        textpos.push([_INTL("PP: {1}/{2}",moves[i].pp,moves[i].totalpp),
           448,50+UPPERGAP,2,ppcolors[(4-ppfraction)*2],ppcolors[(4-ppfraction)*2+1]])
        textpos.push([_INTL("P: {1} A: {2}",mbasedmg,maccuracy),
           448+108,50+UPPERGAP,2,textbase,textshadow])
      else
        textpos.push([_INTL("P: {1} A: {2}",mbasedmg,maccuracy),
           448+108,50+UPPERGAP,2,textbase,textshadow])
      end
    end
    pbDrawTextPositions(self.bitmap,textpos)
    if megaButton>0
      self.bitmap.blt(146,0,@megaevobitmap.bitmap,Rect.new(0,(megaButton-1)*46,96,46))
    end
  end
end



#===============================================================================
# Data box for safari battles
#===============================================================================
class SafariDataBox < SpriteWrapper
  attr_accessor :selected
  attr_reader :appearing

  def initialize(battle,viewport=nil)
    super(viewport)
    @selected=0
    @battle=battle
    @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_safari")
    @spriteX=PokeBattle_SceneConstants::SAFARIBOX_X
    @spriteY=PokeBattle_SceneConstants::SAFARIBOX_Y
    @appearing=false
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    self.bitmap=@contents
    self.visible=false
    self.z=50
    refresh
  end

  def appear
    refresh
    self.visible=true
    self.opacity=255
    self.x=@spriteX+240
    self.y=@spriteY
    @appearing=true
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    pbSetSystemFont(self.bitmap)
    pbSetSmallFont2(self.bitmap)
    textpos=[]
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR2
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR2
    outline=Color.new(248,248,216)
    textpos.push([_INTL("Safari Balls"),42,8,false,base])
    textpos.push([_INTL("Left: {1}",@battle.ballcount),42,38,false,base])
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    super
    if @appearing
      self.x-=12
      self.x=@spriteX if self.x<@spriteX
      @appearing=false if self.x<=@spriteX
      self.y=@spriteY
      return
    end
    self.x=@spriteX
    self.y=@spriteY
  end
end

#===============================================================================
# Data box for Pokemon Box
#===============================================================================
class PokemonTaskDataBox < SpriteWrapper
  attr_accessor :selected
  attr_accessor :appearing
  attr_accessor :disappearing
  attr_reader :animatingHP

  def initialize(oldamount=0,maxamount=0,taskname="Task",image="image.png",viewport=nil)
    super(viewport)
    @frame=0
    @showhp=false
    @appearing=false
    @disappearing=false
    @disappeared=false
    @animatingHP=false
    @dark=false
    @starthp=0
    @currenthp=0
    @endhp=0
    @spritebaseX=16
    @taskname=taskname
    @oldamount=oldamount
    @maxamount=maxamount
    # Considers each icon to be 34x34
    if image.is_a?(Array)
      @imagename=image[0]
      @imageindex=image[1]
    else
      @imagename=image
      @imageindex=0      
    end
    @currentStep=PokemonBoxScene.new.currentStep
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_task")
        @spriteX=PokeBattle_SceneConstants::FOEBOX_X
        @spriteY=PokeBattle_SceneConstants::FOEBOX_Y
				@showhp=true
        @dark=true
    @hpbar=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/overlay_progress"))
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    if @dark
      @numberbitmap=AnimatedBitmap.new(_INTL("Graphics/UI/icon_numbers_white"))
    else
      @numberbitmap=AnimatedBitmap.new(_INTL("Graphics/UI/icon_numbers"))
    end
    self.bitmap=@contents
    self.visible=false
    self.z=50
    refresh
  end

  def dispose
    @hpbar.dispose
    @databox.dispose
    @numberbitmap.dispose
    @contents.dispose
    super
  end


  def hp
    return @animatingHP ? @currenthp : @oldamount  end
  
  def maxstatus
    return @maxamount
  end

  def animateHP(oldhp,newhp)
    @starthp=oldhp
    @currenthp=oldhp
    @endhp=newhp
    @animatingHP=true
  end

  def pbDrawNumber(number,btmp,startX,startY,align=0)
    n = (number==-1) ? [10] : number.to_i.digits   # -1 means draw the / character
    charWidth  = @numberbitmap.width/11
    charHeight = @numberbitmap.height
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,@numberbitmap.bitmap,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end


  
  def appear
    refresh
    self.visible=true
    self.opacity=255
    self.x=@spriteX-320
    self.y=@spriteY
    @disappeared=false
    @appearing=true
  end

  def disappear
#    refresh
    self.visible=true
    self.opacity=255
    self.x=@spriteX
    self.y=@spriteY
    @disappeared=true
    @disappearing=true
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    if @dark
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    outline=Color.new(7,16,39)
    else
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR2
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR2
    outline=Color.new(248,248,216)
    end
    pbSetSystemFont(self.bitmap)
    pbSetSmallFont2(self.bitmap)
    textpos=[
       [@taskname,@spritebaseX+38,6,false,base]
    ]
    imagepos=[]
    imagepos.push([@imagename,18,24,0,34*@imageindex,34,34])
    pbDrawTextPositions(self.bitmap,textpos)
    pbSetSmallFont(self.bitmap)
    @extra = 162
    if @showhp
      pbDrawNumber(self.hp,self.bitmap,@spritebaseX+84,54,1)
      pbDrawNumber(-1,self.bitmap,@spritebaseX+84,54)   # / char
      pbDrawNumber(maxstatus,self.bitmap,@spritebaseX+100,54,0)
    end
    textpos=[]
    pbDrawTextPositions(self.bitmap,textpos)
    pbDrawImagePositions(self.bitmap,imagepos)

    # Draw HP bar
    hpgauge = (maxstatus==0) ? 0 : self.hp*@hpbar.bitmap.width/maxstatus
    hpgauge = 2 if hpgauge<2 && self.hp>0
    hpzone = 0
    hpGaugeX=PokeBattle_SceneConstants::HPGAUGE_X-66
    hpGaugeY=PokeBattle_SceneConstants::HPGAUGE_Y
    if @animatingHP && self.hp>0   # fill with black (shows what the HP used to be)
      self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,
         @starthp*@hpbar.bitmap.width/maxstatus,@hpbar.bitmap.height,Color.new(12,12,12))
    end
    self.bitmap.blt(@spritebaseX+hpGaugeX,hpGaugeY,@hpbar.bitmap,
       Rect.new(0,hpzone*@hpbar.bitmap.height,hpgauge,@hpbar.bitmap.height))

  end

  def update
    super
   # @frame+=1
    @frame = (@frame+1)%24
    if @animatingHP
      if @currenthp<@endhp
        @currenthp+=[1,(maxstatus/162).floor].max
        @currenthp=@endhp if @currenthp>@endhp
      elsif @currenthp>@endhp
        @currenthp-=[1,(maxstatus/162).floor].max
        @currenthp=@endhp if @currenthp<@endhp
      end
      pbPlayCursorSE()
      refresh
      @animatingHP=false if @currenthp==@endhp
    end
    # Move data box onto the screen
    if @appearing
        self.x+=12
        self.x=@spriteX if self.x>@spriteX
        @appearing=false if self.x>=@spriteX
      self.y=@spriteY
      return
    elsif @disappearing
        self.x-=12
        self.x=@spriteX-320 if self.x<@spriteX-320
        @disappearing=false if self.x<=@spriteX-320
      self.y=@spriteY
      return
    end
    if @disappeared
      self.x=@spriteX-320
      self.y=@spriteY-320
    else
      self.x=@spriteX
      self.y=@spriteY
    end
  end
end


#===============================================================================
# Data box for regular battles (both single and double)
#===============================================================================
class PokemonDataBox < SpriteWrapper
  attr_reader :battler
  attr_accessor :selected
  attr_accessor :appearing
  attr_reader :animatingHP
  attr_reader :animatingEXP

  def initialize(battler,doublebattle,viewport=nil)
    super(viewport)
    @explevel=0
    @battler=battler
    @selected=0
    @frame=0
    @showhp=false
    @showexp=false
    @appearing=false
    @animatingHP=false
    @dark=false
    @starthp=0
    @currenthp=0
    @endhp=0
    @expflash=0
    if (@battler.index&1)==0 # if player's Pokémon
      @spritebaseX=34
    else
      @spritebaseX=16
    end
    $inbattle=true
    if doublebattle
      $dbattle=true
      case @battler.index
      when 0
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_thin")
        @spriteX=PokeBattle_SceneConstants::PLAYERBOXD1_X
        @spriteY=PokeBattle_SceneConstants::PLAYERBOXD1_Y
      when 1 
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_thin_foe")
        @spriteX=PokeBattle_SceneConstants::FOEBOXD1_X
        @spriteY=PokeBattle_SceneConstants::FOEBOXD1_Y
        @dark=true
      when 2 
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_thin_alt")
        @spriteX=PokeBattle_SceneConstants::PLAYERBOXD2_X
        @spriteY=PokeBattle_SceneConstants::PLAYERBOXD2_Y
        @dark=true
      when 3 
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_thin_foe_alt")
        @spriteX=PokeBattle_SceneConstants::FOEBOXD2_X
        @spriteY=PokeBattle_SceneConstants::FOEBOXD2_Y
      end
    else
      $dbattle=false
      case @battler.index
      when 0
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_normal")
        @spriteX=PokeBattle_SceneConstants::PLAYERBOX_X
        @spriteY=PokeBattle_SceneConstants::PLAYERBOX_Y
        @showhp=true
        @showexp=true
      when 1 
        @databox=AnimatedBitmap.new("Graphics/UI/Battle/databox_normal_foe")
        @spriteX=PokeBattle_SceneConstants::FOEBOX_X
        @spriteY=PokeBattle_SceneConstants::FOEBOX_Y
				@showhp=true
        @dark=true
      end
    end
    @statuses=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/icon_statuses"))
    @hpbar=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/overlay_hp"))
    @expbar=AnimatedBitmap.new(_INTL("Graphics/UI/Battle/overlay_exp"))
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    if @dark
      @numberbitmap=AnimatedBitmap.new(_INTL("Graphics/UI/icon_numbers_white"))
    else
      @numberbitmap=AnimatedBitmap.new(_INTL("Graphics/UI/icon_numbers"))
    end
    self.bitmap=@contents
    self.visible=false
    self.z=50
    refreshExpLevel
    refresh
  end

  def dispose
    @statuses.dispose
    @hpbar.dispose
    @expbar.dispose
    @databox.dispose
    @numberbitmap.dispose
    @contents.dispose
    super
  end

  def refreshExpLevel
    if !@battler.pokemon
      @explevel=0
    else
      growthrate=@battler.pokemon.growthrate
      startexp=PBExperience.pbGetStartExperience(@battler.pokemon.level,growthrate)
      endexp=PBExperience.pbGetStartExperience(@battler.pokemon.level+1,growthrate)
      if startexp==endexp
        @explevel=0
      else
        @explevel=(@battler.pokemon.exp-startexp)*PokeBattle_SceneConstants::EXPGAUGESIZE/(endexp-startexp)
      end
    end
  end

  def exp
    return @animatingEXP ? @currentexp : @explevel
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp,newhp)
    @starthp=oldhp
    @currenthp=oldhp
    @endhp=newhp
    @animatingHP=true
  end

  def animateEXP(oldexp,newexp)
    @currentexp=oldexp
    @endexp=newexp
    @animatingEXP=true
  end

  def pbDrawNumber(number,btmp,startX,startY,align=0)
    n = (number==-1) ? [10] : number.to_i.digits   # -1 means draw the / character
    charWidth  = @numberbitmap.width/11
    charHeight = @numberbitmap.height
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,@numberbitmap.bitmap,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end


  
  def appear
    refreshExpLevel
    refresh
    self.visible=true
    self.opacity=255
    if (@battler.index&1)==0 # if player's Pokémon
      self.x=@spriteX+320
    else
      self.x=@spriteX-320
    end
    self.y=@spriteY
    @appearing=true
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    if @dark
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    outline=Color.new(7,16,39)
    else
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR2
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR2
    outline=Color.new(248,248,216)
    end
    pokename=@battler.name
    pbSetSystemFont(self.bitmap)
    pbSetSmallFont2(self.bitmap)
    textpos=[
       [pokename,@spritebaseX+8,6,false,base]
    ]
    imagepos=[]
    genderX=self.bitmap.text_size(pokename).width
    genderX+=@spritebaseX+14
    case @battler.displayGender
    when 0 # Male
 #     textpos.push([_INTL("♂"),genderX,6,false,outline,Color.new(48,96,216),1])
      if @dark
        imagepos.push(["Graphics/UI/Dark Mode/gender_male",genderX,14,0,0,-1,-1])
      else
        imagepos.push(["Graphics/UI/gender_male",genderX,14,0,0,-1,-1])
      end
    when 1 # Female
 #     textpos.push([_INTL("♀"),genderX,6,false,outline,Color.new(248,88,40),1])
      if @dark
        imagepos.push(["Graphics/UI/Dark Mode/gender_female",genderX,14,0,0,-1,-1])
      else
        imagepos.push(["Graphics/UI/gender_female",genderX,14,0,0,-1,-1])
      end
    when 2 # Genderless
 #     textpos.push([_INTL("♀"),genderX,6,false,outline,Color.new(248,88,40),1])
      if @dark
        imagepos.push(["Graphics/UI/Dark Mode/gender_transgender",genderX,14,0,0,-1,-1])
      else
        imagepos.push(["Graphics/UI/gender_transgender",genderX,14,0,0,-1,-1])
      end
    end
    pbDrawTextPositions(self.bitmap,textpos)
    pbSetSmallFont(self.bitmap)
    @extra1 = 138
#    @extra1 = 120 if (@battler.index&1)==0 # If player's Pokémon
    if @dark
    imagepos.push(["Graphics/UI/overlay_lv_white",@spritebaseX+@extra1,16,0,0,-1,-1]) # -self.bitmap.text_size(@battler.level.to_s).width
    else
    imagepos.push(["Graphics/UI/overlay_lv",@spritebaseX+@extra1,16,0,0,-1,-1]) #
    end
    textpos=[
   #    [_INTL("{1}",@battler.level),@spritebaseX+202,8,true,base,shadow]
    ]
    @extra = 162
#    @extra = 162 if (@battler.index&1)==0 # If player's Pokémon
    pbDrawNumber(@battler.level,self.bitmap,@spritebaseX+@extra,16)
    if @showhp
 #     hpstring=_ISPRINTF("{1: 2d}/{2: 2d}",self.hp,@battler.totalhp)
 #     textpos.push([hpstring,@spritebaseX+8,48,false,base,shadow]) # Was 188
      pbDrawNumber(self.hp,self.bitmap,@spritebaseX+84,54,1)
      pbDrawNumber(-1,self.bitmap,@spritebaseX+84,54)   # / char
      pbDrawNumber(@battler.totalhp,self.bitmap,@spritebaseX+100,54,0)
    end
    pbDrawTextPositions(self.bitmap,textpos)
    if @battler.isShiny?
      shinyX=206
      shinyX=-6 if (@battler.index&1)==0 # If player's Pokémon
      imagepos.push(["Graphics/UI/shiny.png",@spritebaseX+shinyX,36,0,0,-1,-1])
    end
    if @battler.isMega?
      imagepos.push(["Graphics/UI/Battle/icon_mega.png",@spritebaseX+8,34,0,0,-1,-1])
    elsif @battler.isPrimal?
      if isConst?(@battler.pokemon.species,PBSpecies,:KYOGRE)
        imagepos.push(["Graphics/UI/Battle/icon_primal_Kyogre.png",@spritebaseX+120,4,0,0,-1,-1])
      elsif isConst?(@battler.pokemon.species,PBSpecies,:GROUDON)
        imagepos.push(["Graphics/UI/Battle/icon_primal_Groudon.png",@spritebaseX+120,4,0,0,-1,-1])
      end
    end
    if @battler.owned && (@battler.index&1)==1
      imagepos.push(["Graphics/UI/Battle/icon_own.png",@spritebaseX+8,36,0,0,-1,-1])
    end
    pbDrawImagePositions(self.bitmap,imagepos)
    if @battler.status>0
      self.bitmap.blt(@spritebaseX+24,36,@statuses.bitmap,
         Rect.new(0,(@battler.status-1)*16,44,16))
    end
    # Draw HP bar
    hpgauge = (@battler.totalhp==0) ? 0 : self.hp*@hpbar.bitmap.width/@battler.totalhp
    hpgauge = 2 if hpgauge<2 && self.hp>0
    hpzone = 0
    hpzone = 1 if self.hp<=(@battler.totalhp/2).floor
    hpzone = 2 if self.hp<=(@battler.totalhp/4).floor
    hpGaugeX=PokeBattle_SceneConstants::HPGAUGE_X
    hpGaugeY=PokeBattle_SceneConstants::HPGAUGE_Y
    if @animatingHP && self.hp>0   # fill with black (shows what the HP used to be)
      self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,
         @starthp*@hpbar.bitmap.width/@battler.totalhp,@hpbar.bitmap.height/3,Color.new(12,12,12))
    end
    self.bitmap.blt(@spritebaseX+hpGaugeX,hpGaugeY,@hpbar.bitmap,
       Rect.new(0,hpzone*@hpbar.bitmap.height/3,hpgauge,@hpbar.bitmap.height/3))

    if @showexp
      # fill with EXP color
      expGaugeX=PokeBattle_SceneConstants::EXPGAUGE_X
      expGaugeY=PokeBattle_SceneConstants::EXPGAUGE_Y
      self.bitmap.blt(@spritebaseX+expGaugeX,expGaugeY,@expbar.bitmap,
         Rect.new(0,0,self.exp,@expbar.bitmap.height))
    end
  end

  def update
    super
   # @frame+=1
    @frame = (@frame+1)%24
    if @animatingHP
      if @currenthp<@endhp
        @currenthp+=[1,(@battler.totalhp/PokeBattle_SceneConstants::HPGAUGESIZE).floor].max
        @currenthp=@endhp if @currenthp>@endhp
      elsif @currenthp>@endhp
        @currenthp-=[1,(@battler.totalhp/PokeBattle_SceneConstants::HPGAUGESIZE).floor].max
        @currenthp=@endhp if @currenthp<@endhp
      end
      @animatingHP=false if @currenthp==@endhp
      refresh
    end
    if @animatingEXP
      if !@showexp
        @currentexp=@endexp
      elsif @currentexp<@endexp   # Gaining Exp
        if @endexp>=PokeBattle_SceneConstants::EXPGAUGESIZE ||
           @endexp-@currentexp>=PokeBattle_SceneConstants::EXPGAUGESIZE/4
          @currentexp+=4
        else
          @currentexp+=2
        end
        @currentexp=@endexp if @currentexp>@endexp
      elsif @currentexp>@endexp   # Losing Exp
        if @endexp==0 ||
           @currentexp-@endexp>=PokeBattle_SceneConstants::EXPGAUGESIZE/4
          @currentexp-=4
        elsif @currentexp>@endexp
          @currentexp-=2
        end
        @currentexp=@endexp if @currentexp<@endexp
      end
      refresh
      if @currentexp==@endexp
        if @currentexp==PokeBattle_SceneConstants::EXPGAUGESIZE
          if @expflash==0
            pbMEPlay("Levelup")
            self.flash(Color.new(222,222,222),8) # Was 64,200,248
            @expflash=8
          else
            @expflash-=1
            if @expflash==0
              @animatingEXP=false
              refreshExpLevel
            end
          end
        else
          @animatingEXP=false
        end
      end
    end
    # Move data box onto the screen
    if @appearing
      if (@battler.index&1)==0 # if player's Pokémon
        self.x-=12
        self.x=@spriteX if self.x<@spriteX
        @appearing=false if self.x<=@spriteX
      else
        self.x+=12
        self.x=@spriteX if self.x>@spriteX
        @appearing=false if self.x>=@spriteX
      end
      self.y=@spriteY
      return
    end
    self.x=@spriteX
    self.y=@spriteY
    # Data box bobbing while Pokémon is selected
    if @selected==1 || @selected==2   # Choosing commands/targeted or damaged
      if (@frame/6).floor==1
        self.y = @spriteY-2
      elsif (@frame/6).floor==3
        self.y = @spriteY+2
      end
    end
=begin
    # Data box bobbing while Pokémon is selected # Was 10
    if ((@frame/9).floor&1)==1 && @selected==1   # Choosing commands for this Pokémon
      self.y=@spriteY+2
    elsif ((@frame/9).floor&1)==1 && @selected==2   # When targeted or damaged
      self.y=@spriteY+2
    end
=end
  end
end



#===============================================================================
# Shows the enemy trainer(s)'s Pokémon being thrown out.  It appears at coords
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
#===============================================================================
class PokeballSendOutAnimation
  SPRITESTEPS=10
  STARTZOOM=0.125

  def initialize(sprite,spritehash,pkmn,illusionpoke,doublebattle)
    @illusionpoke=illusionpoke
    @disposed=false
    @ballused=pkmn.pokemon ? pkmn.pokemon.ballused : 0
    if @illusionpoke
      @ballused=@illusionpoke.ballused || 0
    end
    @PokemonBattlerSprite=sprite
    @PokemonBattlerSprite.visible=false
    @PokemonBattlerSprite.tone=Tone.new(248,248,248,248)
    @pokeballsprite=IconSprite.new(0,0,sprite.viewport)
    @pokeballsprite.setBitmap(sprintf("Graphics/Battle animations/ball_%02d",@ballused))
    if doublebattle
      @spritex=PokeBattle_SceneConstants::FOEBATTLERD1_X if pkmn.index==1
      @spritex=PokeBattle_SceneConstants::FOEBATTLERD2_X if pkmn.index==3
    else
      @spritex=PokeBattle_SceneConstants::FOEBATTLER_X
    end
    @spritey=0
    if @illusionpoke
      @endspritey=adjustBattleSpriteY(sprite,@illusionpoke.species,pkmn.index)
    else
      @endspritey=adjustBattleSpriteY(sprite,pkmn.species,pkmn.index)
    end
    if doublebattle
      @spritey=PokeBattle_SceneConstants::FOEBATTLERD1_Y if pkmn.index==1
      @spritey=PokeBattle_SceneConstants::FOEBATTLERD2_Y if pkmn.index==3
      @endspritey+=PokeBattle_SceneConstants::FOEBATTLERD1_Y if pkmn.index==1
      @endspritey+=PokeBattle_SceneConstants::FOEBATTLERD2_Y if pkmn.index==3
    else
      @spritey=PokeBattle_SceneConstants::FOEBATTLER_Y
      @endspritey+=PokeBattle_SceneConstants::FOEBATTLER_Y
    end
    @spritehash=spritehash
    @pokeballsprite.x=@spritex-@pokeballsprite.bitmap.width/2
    @pokeballsprite.y=@spritey-@pokeballsprite.bitmap.height/2-4
    @pokeballsprite.z=@PokemonBattlerSprite.z+1
    @pkmn=pkmn
    @shadowX=@spritex
    @shadowY=@spritey
    if @spritehash["shadow#{@pkmn.index}"] && @spritehash["shadow#{@pkmn.index}"].bitmap!=nil
      @shadowX-=@spritehash["shadow#{@pkmn.index}"].bitmap.width/2
      @shadowY-=@spritehash["shadow#{@pkmn.index}"].bitmap.height/2
    end
    @shadowVisible=showShadow?(pkmn.species)
    if @illusionpoke
      @shadowVisible=showShadow?(@illusionpoke.species)
    end
    @stepspritey=(@spritey-@endspritey)
    @zoomstep=(1.0-STARTZOOM)/SPRITESTEPS
    @animdone=false
    @frame=0
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?
    @pokeballsprite.dispose
    @disposed=true
  end

  def update
    return if disposed?
    @pokeballsprite.update
    @frame+=1
    if @frame==2
      pbSEPlay("recall")
    end
    if @frame==4
      @PokemonBattlerSprite.visible=true
      @PokemonBattlerSprite.zoom_x=STARTZOOM
      @PokemonBattlerSprite.zoom_y=STARTZOOM
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,@spritey)
      if @illusionpoke
        pbPlayCry(@illusionpoke)
      else
        pbPlayCry(@pkmn.pokemon ? @pkmn.pokemon : @pkmn.species)
      end
      @pokeballsprite.setBitmap(sprintf("Graphics/Battle animations/ball_%02d_open",@ballused))
    end
    if @frame==8
      @pokeballsprite.visible=false
    end
    if @frame>8 && @frame<=16
      color=Color.new(248,248,248,256-(16-@frame)*32)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>16 && @frame<=24
      color=Color.new(248,248,248,(24-@frame)*32)
      tone=(24-@frame)*32
      @PokemonBattlerSprite.tone=Tone.new(tone,tone,tone,tone)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>5 && @PokemonBattlerSprite.zoom_x<1.0
      @PokemonBattlerSprite.zoom_x+=@zoomstep
      @PokemonBattlerSprite.zoom_y+=@zoomstep
      @PokemonBattlerSprite.zoom_x=1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y=1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      currentY=@spritey-(@stepspritey*@PokemonBattlerSprite.zoom_y)
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,currentY)
      @PokemonBattlerSprite.y=currentY
    end
    if @PokemonBattlerSprite.tone.gray<=0 && @PokemonBattlerSprite.zoom_x>=1.0
      @animdone=true
      if @spritehash["shadow#{@pkmn.index}"]
        @spritehash["shadow#{@pkmn.index}"].x=@shadowX
        @spritehash["shadow#{@pkmn.index}"].y=@shadowY
        @spritehash["shadow#{@pkmn.index}"].visible=@shadowVisible
      end
    end
  end
end



#===============================================================================
# Shows the player's (or partner's) Pokémon being thrown out.  It appears at
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
#===============================================================================
class PokeballPlayerSendOutAnimation
#  Ball curve: 8,52; 22,44; 52, 96
#  Player: Color.new(16*8,23*8,30*8)
  SPRITESTEPS=10
  STARTZOOM=0.125

  def initialize(sprite,spritehash,pkmn,illusionpoke,doublebattle)
    @illusionpoke=illusionpoke
    @disposed=false
    @PokemonBattlerSprite=sprite
    @pkmn=pkmn
    @PokemonBattlerSprite.visible=false
    @PokemonBattlerSprite.tone=Tone.new(248,248,248,248)
    @spritehash=spritehash
    if doublebattle
      @spritex=PokeBattle_SceneConstants::PLAYERBATTLERD1_X if pkmn.index==0
      @spritex=PokeBattle_SceneConstants::PLAYERBATTLERD2_X if pkmn.index==2
    else
      @spritex=PokeBattle_SceneConstants::PLAYERBATTLER_X
    end
    @spritey=0
    if @illusionpoke
      @endspritey=adjustBattleSpriteY(sprite,@illusionpoke.species,pkmn.index)
    else
      @endspritey=adjustBattleSpriteY(sprite,pkmn.species,pkmn.index)
    end
    if doublebattle
      @spritey+=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y if pkmn.index==0
      @spritey+=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y if pkmn.index==2
      @endspritey+=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y if pkmn.index==0
      @endspritey+=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y if pkmn.index==2
    else
      @spritey+=PokeBattle_SceneConstants::PLAYERBATTLER_Y
      @endspritey+=PokeBattle_SceneConstants::PLAYERBATTLER_Y
    end
    @animdone=false
    @frame=0
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?
    @disposed=true
  end

  def update
    return if disposed?
    @frame+=1
    if @frame==4
      @PokemonBattlerSprite.visible=true
      @PokemonBattlerSprite.zoom_x=STARTZOOM
      @PokemonBattlerSprite.zoom_y=STARTZOOM
      pbSEPlay("recall")
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,@spritey)
      if @illusionpoke
        pbPlayCry(@illusionpoke)
      else
        pbPlayCry(@pkmn.pokemon ? @pkmn.pokemon : @pkmn.species)
      end
    end
    if @frame>8 && @frame<=16
      color=Color.new(248,248,248,256-(16-@frame)*32)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>16 && @frame<=24
      color=Color.new(248,248,248,(24-@frame)*32)
      tone=(24-@frame)*32
      @PokemonBattlerSprite.tone=Tone.new(tone,tone,tone,tone)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>5 && @PokemonBattlerSprite.zoom_x<1.0
      @PokemonBattlerSprite.zoom_x+=0.1
      @PokemonBattlerSprite.zoom_y+=0.1
      @PokemonBattlerSprite.zoom_x=1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y=1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,0)
      @PokemonBattlerSprite.y=@spritey+(@endspritey-@spritey)*@PokemonBattlerSprite.zoom_y
    end
    if @PokemonBattlerSprite.tone.gray<=0 && @PokemonBattlerSprite.zoom_x>=1.0
      @animdone=true
    end
  end
end



#===============================================================================
# Shows the enemy trainer(s) and the enemy party lineup sliding off screen.
# Doesn't show the ball thrown or the Pokémon.
#===============================================================================
class TrainerFadeAnimation
  def initialize(sprites)
    @frame=0
    @sprites=sprites
    @animdone=false
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone
    @frame+=1
    @sprites["trainer"].x+=8
    @sprites["trainer2"].x+=8 if @sprites["trainer2"]
    @sprites["partybarfoe"].x+=8
    @sprites["partybarfoe"].opacity-=12
    for i in 0...6
      @sprites["enemy#{i}"].opacity-=12
      @sprites["enemy#{i}"].x+=8 if @frame>=i*4
    end
    @animdone=true if @sprites["trainer"].x>=Graphics.width &&
       (!@sprites["trainer2"] || @sprites["trainer2"].x>=Graphics.width)
  end
end



#===============================================================================
# Shows the player (and partner) and the player party lineup sliding off screen.
# Shows the player's/partner's throwing animation (if they have one).
# Doesn't show the ball thrown or the Pokémon.
#===============================================================================
class PlayerFadeAnimation
  def initialize(sprites)
    @frame=0
    @sprites=sprites
    @animdone=false
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone
    @frame+=1
    @sprites["player"].x-=8
    @sprites["playerB"].x-=8 if @sprites["playerB"]
    @sprites["partybarplayer"].x-=8
    @sprites["partybarplayer"].opacity-=12
    for i in 0...6
      if @sprites["player#{i}"]
        @sprites["player#{i}"].opacity-=12 
        @sprites["player#{i}"].x-=8 if @frame>=i*4
      end
    end
    pa=@sprites["player"]
    pb=@sprites["playerB"]
    pawidth=128
    pbwidth=128
    if (pa && pa.bitmap && !pa.bitmap.disposed?)
      if pa.bitmap.height<pa.bitmap.width
        numframes=pa.bitmap.width/pa.bitmap.height # Number of frames
        pawidth=pa.bitmap.width/numframes # Width per frame
        @sprites["player"].src_rect.x=pawidth*1 if @frame>0
        @sprites["player"].src_rect.x=pawidth*2 if @frame>8
        @sprites["player"].src_rect.x=pawidth*3 if @frame>12
        @sprites["player"].src_rect.x=pawidth*4 if @frame>16
        @sprites["player"].src_rect.width=pawidth
      else
        pawidth=pa.bitmap.width
        @sprites["player"].src_rect.x=0
        @sprites["player"].src_rect.width=pawidth
      end
    end
    if (pb && pb.bitmap && !pb.bitmap.disposed?)
      if pb.bitmap.height<pb.bitmap.width
        numframes=pb.bitmap.width/pb.bitmap.height # Number of frames
        pbwidth=pb.bitmap.width/numframes # Width per frame
        @sprites["playerB"].src_rect.x=pbwidth*1 if @frame>0
        @sprites["playerB"].src_rect.x=pbwidth*2 if @frame>8
        @sprites["playerB"].src_rect.x=pbwidth*3 if @frame>12
        @sprites["playerB"].src_rect.x=pbwidth*4 if @frame>16
        @sprites["playerB"].src_rect.width=pbwidth
      else
        pbwidth=pb.bitmap.width
        @sprites["playerB"].src_rect.x=0
        @sprites["playerB"].src_rect.width=pbwidth
      end
    end
    if pb
      @animdone=true if pb.x<=-pbwidth
    else
      @animdone=true if pa.x<=-pawidth
    end
  end
end



#===============================================================================
# Shows the player's Poké Ball being thrown to capture a Pokémon.
#===============================================================================
def pokeballThrow(ball,shakes,critical,targetBattler,scene,battler,burst=-1,showplayer=false)
  balltype=pbGetBallType(ball)
  animtrainer=false
  if showplayer && @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
    animtrainer=true
  end
  oldvisible=@sprites["shadow#{targetBattler}"].visible
  @sprites["shadow#{targetBattler}"].visible=false
  ball=sprintf("Graphics/Battle animations/ball_%02d",balltype)
  ballopen=sprintf("Graphics/Battle animations/ball_%02d_open",balltype)
  # sprites
  spritePoke=@sprites["pokemon#{targetBattler}"]
  spriteBall=IconSprite.new(0,0,@viewport)
  spriteBall.visible=false
  spritePlayer=@sprites["player"] if animtrainer
  # pictures
  pictureBall=PictureEx.new(spritePoke.z+1)
  picturePoke=PictureEx.new(spritePoke.z)
  dims=[spritePoke.x,spritePoke.y]
  center=getSpriteCenter(@sprites["pokemon#{targetBattler}"])
  if @battle.doublebattle
    ballendy=PokeBattle_SceneConstants::FOEBATTLERD1_Y-4 if targetBattler==1
    ballendy=PokeBattle_SceneConstants::FOEBATTLERD2_Y-4 if targetBattler==3
  else
    ballendy=PokeBattle_SceneConstants::FOEBATTLER_Y-4
  end
  if animtrainer
    picturePlayer=PictureEx.new(spritePoke.z+2)
    playerpos=[@sprites["player"].x,@sprites["player"].y]
  end
  # starting positions
  pictureBall.moveVisible(1,true)
  pictureBall.moveName(1,ball)
  pictureBall.moveOrigin(1,PictureOrigin::Center)
  if animtrainer
    pictureBall.moveXY(0,1,64,256)
  else
    pictureBall.moveXY(0,1,10,180)
  end
  picturePoke.moveVisible(1,true)
  picturePoke.moveOrigin(1,PictureOrigin::Center)
  picturePoke.moveXY(0,1,center[0],center[1])
  if animtrainer
    picturePlayer.moveVisible(1,true)
    picturePlayer.moveName(1,spritePlayer.name)
    picturePlayer.moveOrigin(1,PictureOrigin::TopLeft)
    picturePlayer.moveXY(0,1,playerpos[0],playerpos[1])
  end
  # directives
  picturePoke.moveSE(1,"Audio/SE/throw")
  if animtrainer
    pictureBall.moveCurve(30,1,64,256,30+Graphics.width/2,10,center[0],center[1])
    pictureBall.moveAngle(30,1,-720)
  else
    pictureBall.moveCurve(30,1,150,70,30+Graphics.width/2,10,center[0],center[1])
    pictureBall.moveAngle(30,1,-1080)
  end
  pictureBall.moveAngle(0,pictureBall.totalDuration,0)
  delay=pictureBall.totalDuration+4
  picturePoke.moveTone(10,delay,Tone.new(0,-224,-224,0))
  delay=picturePoke.totalDuration
  picturePoke.moveSE(delay,"Audio/SE/recall")
  pictureBall.moveName(delay+4,ballopen)
  if animtrainer
    picturePlayer.moveSrc(1,@sprites["player"].bitmap.height,0)
    picturePlayer.moveXY(0,1,playerpos[0]-14,playerpos[1])
    picturePlayer.moveSrc(4,@sprites["player"].bitmap.height*2,0)
    picturePlayer.moveXY(0,4,playerpos[0]-12,playerpos[1])
    picturePlayer.moveSrc(8,@sprites["player"].bitmap.height*3,0)
    picturePlayer.moveXY(0,8,playerpos[0]+20,playerpos[1])
    picturePlayer.moveSrc(16,@sprites["player"].bitmap.height*4,0)
    picturePlayer.moveXY(0,16,playerpos[0]+16,playerpos[1])
    picturePlayer.moveSrc(40,0,0)
    picturePlayer.moveXY(0,40,playerpos[0],playerpos[1])
  end
  loop do
    pictureBall.update
    picturePoke.update
    picturePlayer.update if animtrainer
    setPictureIconSprite(spriteBall,pictureBall)
    setPictureSprite(spritePoke,picturePoke)
    setPictureIconSprite(spritePlayer,picturePlayer) if animtrainer
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate
    break if !pictureBall.running? && !picturePoke.running?
  end
  # Burst animation here
  if burst>=0 && scene.battle.battlescene
    scene.pbCommonAnimation("BallBurst#{burst}",battler,nil)
  end
  pictureBall.clearProcesses
  picturePoke.clearProcesses
  delay=0
  picturePoke.moveZoom(15,delay,0)
  picturePoke.moveXY(15,delay,center[0],center[1])
  picturePoke.moveSE(delay+10,"Audio/SE/jumptoball")
  picturePoke.moveVisible(delay+15,false)
  pictureBall.moveName(picturePoke.totalDuration+2,ball)
  delay=pictureBall.totalDuration+6
  if critical
    pictureBall.moveSE(delay,"Audio/SE/ballshake")
    pictureBall.moveXY(2,delay,center[0]+4,center[1])
    pictureBall.moveXY(4,pictureBall.totalDuration,center[0]-4,center[1])
    pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/ballshake")
    pictureBall.moveXY(4,pictureBall.totalDuration,center[0]+4,center[1])
    pictureBall.moveXY(4,pictureBall.totalDuration,center[0]-4,center[1])
    pictureBall.moveXY(2,pictureBall.totalDuration,center[0],center[1])
    delay=pictureBall.totalDuration+4
  end
  pictureBall.moveXY(10,delay,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(5,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])/2))
  pictureBall.moveXY(5,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(3,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])/4))
  pictureBall.moveXY(3,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(1,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])/8))
  pictureBall.moveXY(1,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  picturePoke.moveXY(0,pictureBall.totalDuration,center[0],ballendy)
  delay=pictureBall.totalDuration+18# if shakes==0
  [shakes,3].min.times do
    pictureBall.moveSE(delay,"Audio/SE/ballshake")
    pictureBall.moveXY(3,delay,center[0]-8,ballendy)
    pictureBall.moveAngle(3,delay,20) # positive means counterclockwise
    delay=pictureBall.totalDuration
    pictureBall.moveXY(6,delay,center[0]+8,ballendy)
    pictureBall.moveAngle(6,delay,-20) # negative means clockwise
    delay=pictureBall.totalDuration
    pictureBall.moveXY(3,delay,center[0],ballendy)
    pictureBall.moveAngle(3,delay,0)
    delay=pictureBall.totalDuration+18
  end
  if shakes<4
    picturePoke.moveSE(delay,"Audio/SE/recall")
    pictureBall.moveName(delay,ballopen)
    pictureBall.moveVisible(delay+10,false)
    picturePoke.moveVisible(delay,true)
    picturePoke.moveZoom(15,delay,100)
    picturePoke.moveXY(15,delay,center[0],center[1])
    picturePoke.moveTone(0,delay,Tone.new(248,248,248,248))
    picturePoke.moveTone(24,delay,Tone.new(0,0,0,0))
    delay=picturePoke.totalDuration
  end
  pictureBall.moveXY(0,delay,center[0],ballendy)
  picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
  picturePoke.moveXY(0,picturePoke.totalDuration,dims[0],dims[1])
  loop do
    pictureBall.update
    picturePoke.update
    setPictureIconSprite(spriteBall,pictureBall)
    setPictureSprite(spritePoke,picturePoke)
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate
    break if !pictureBall.running? && !picturePoke.running?
  end
  if shakes<4
    @sprites["shadow#{targetBattler}"].visible=oldvisible
    spriteBall.dispose
  else
    spriteBall.tone=Tone.new(-64,-64,-64,128)
    pbSEPlay("balldrop",100,150)
    @sprites["capture"]=spriteBall
    spritePoke.visible=false
  end
end



#===============================================================================
# Battle scene (the visuals of the battle)
#===============================================================================
class PokeBattle_Scene
  attr_accessor :abortable
  attr_reader :viewport
  attr_reader :sprites
  BLANK      = 0
  MESSAGEBOX = 1
  COMMANDBOX = 2
  FIGHTBOX   = 3

  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @pkmnwindows=[nil,nil,nil,nil]
    @sprites={}
    @battlestart=true
    @messagemode=false
    @abortable=false
    @aborted=false
  end

  def pbUpdate
    partyAnimationUpdate
    @sprites["battlebg"].update if @sprites["battlebg"].respond_to?("update")
  end

  def pbGraphicsUpdate
    partyAnimationUpdate
    @sprites["battlebg"].update if @sprites["battlebg"].respond_to?("update")
    Graphics.update
  end

  def pbInputUpdate
    Input.update
    if (Input.trigger?(Input::B)) && @abortable && !@aborted
      @aborted=true
      @battle.pbAbort
    end
  end

  def pbShowWindow(windowtype)
    @sprites["messagebox"].visible = (windowtype==MESSAGEBOX ||
                                  #    windowtype==COMMANDBOX ||
                                  #    windowtype==FIGHTBOX ||
                                      windowtype==BLANK )
    @sprites["messagewindow"].visible = (windowtype==MESSAGEBOX)
    @sprites["commandwindow"].visible = (windowtype==COMMANDBOX)
    @sprites["fightwindow"].visible = (windowtype==FIGHTBOX)
  end

  def pbSetMessageMode(mode,dark=true)
    @messagemode=mode
    msgwindow=@sprites["messagewindow"]
    if mode # Within Pokémon command
      if dark
        msgwindow.baseColor=PokeBattle_SceneConstants::MENUBASECOLOR
        msgwindow.shadowColor=PokeBattle_SceneConstants::MENUSHADOWCOLOR
      else
        msgwindow.baseColor=PokeBattle_SceneConstants::MENUBASECOLORL
        msgwindow.shadowColor=PokeBattle_SceneConstants::MENUSHADOWCOLORL
      end
      msgwindow.opacity=255
      msgwindow.x=16
      msgwindow.width=Graphics.width
      msgwindow.height=96
      msgwindow.y=Graphics.height-msgwindow.height+2
    else
      if dark
        msgwindow.baseColor=PokeBattle_SceneConstants::MESSAGEBASECOLOR
        msgwindow.shadowColor=PokeBattle_SceneConstants::MESSAGESHADOWCOLOR
      else
        msgwindow.baseColor=PokeBattle_SceneConstants::MESSAGEBASECOLORL
        msgwindow.shadowColor=PokeBattle_SceneConstants::MESSAGESHADOWCOLORL
      end
      msgwindow.opacity=0
      msgwindow.x=16
      msgwindow.width=Graphics.width-32
      msgwindow.height=96
      msgwindow.y=Graphics.height-msgwindow.height+2
    end
  end

  def pbWaitMessage
    if @briefmessage
      pbShowWindow(MESSAGEBOX)
      cw=@sprites["messagewindow"]
      40.times do
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate(cw)
      end
      cw.text=""
      cw.visible=false
      @briefmessage=false
    end
  end

  def pbDisplay(msg,brief=false)
    pbDisplayMessage(msg,brief)
  end

  def pbDisplayMessage(msg,brief=false)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    cw=@sprites["messagewindow"]
    cw.text=msg
    i=0
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      if i==40
        cw.text=""
        cw.visible=false
        return
      end
      if Input.trigger?(Input::C) || @abortable
        if cw.pausing?
          pbPlayDecisionSE() if !@abortable
          cw.resume
        end
      end
      if !cw.busy?
        if brief
          @briefmessage=true
          return
        end
        i+=1
      end
    end
  end

  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    if @messagemode
      @switchscreen.pbDisplay(msg)
      return
    end
    cw=@sprites["messagewindow"]
    cw.text=_ISPRINTF("{1:s}\1",msg)
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      if Input.trigger?(Input::C) || @abortable
        if cw.busy?
          pbPlayDecisionSE() if cw.pausing? && !@abortable
          cw.resume
        elsif !inPartyAnimation?
          cw.text=""
          pbPlayDecisionSE()
          cw.visible=false if @messagemode
          return
        end
      end
      cw.update
    end
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg,[_INTL("Yes"),_INTL("No")],1)==0
  end

  def pbShowCommands(msg,commands,defaultValue)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    dw=@sprites["messagewindow"]
    dw.text=msg
    cw = Window_CommandPokemon.new(commands)
    cw.x=Graphics.width-cw.width
    cw.y=Graphics.height-cw.height-dw.height
    cw.index=0
    cw.viewport=@viewport
    pbRefresh
    loop do
      cw.visible=!dw.busy?
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      dw.update
      if Input.trigger?(Input::B) && defaultValue>=0
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return defaultValue
        end
      end
      if Input.trigger?(Input::C)
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return cw.index
        end
      end
    end
  end

  def pbFrameUpdate(cw=nil)
    cw.update if cw
    for i in 0...4
      if @sprites["battlebox#{i}"]
        @sprites["battlebox#{i}"].update
      end
      if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].update
      end
    end
  end

  def pbRefresh
    for i in 0...4
      if @sprites["battlebox#{i}"]
        @sprites["battlebox#{i}"].refresh
      end
    end
  end

  def pbAddSprite(id,x,y,filename,viewport)
    sprite=IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbAddPlane(id,filename,viewport)
    sprite=AnimatedPlane.new(viewport)
    if filename
      sprite.setBitmap(filename)
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  def pbBeginCommandPhase
    # Called whenever a new round begins.
    @battlestart=false
  end

  def pbShowOpponent(index)
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[index].trainertype)
      else
        trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
      end
    else
      trainerfile="Graphics/Characters/trfront"
    end
    pbAddSprite("trainer",Graphics.width,PokeBattle_SceneConstants::FOETRAINER_Y,
       trainerfile,@viewport)
    if @sprites["trainer"].bitmap
      @sprites["trainer"].y-=@sprites["trainer"].bitmap.height
      @sprites["trainer"].z=8
    end
    20.times do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      @sprites["trainer"].x-=6
    end
  end

  def pbHideOpponent
    20.times do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      @sprites["trainer"].x+=6
    end
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.width)
    @sprites["helpwindow"].y=0
    @sprites["helpwindow"].x=0
    @sprites["helpwindow"].text=text
    @sprites["helpwindow"].visible=true
  end

  def pbHideHelp
    @sprites["helpwindow"].visible=false
  end

  def pbGetBackdrop
    environ=@battle.environment
    backdrop="Field"
    if environ==PBEnvironment::Cave
      backdrop="Cave"
    elsif environ==PBEnvironment::MovingWater || environ==PBEnvironment::StillWater
      backdrop="Water"
    elsif environ==PBEnvironment::Underwater
      backdrop="Underwater"
    elsif environ==PBEnvironment::Rock
      backdrop="Mountain"
    else
      if !$game_map || !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        backdrop="IndoorA"
      end
    end
    if $game_map
      back=pbGetMetadata($game_map.map_id,MetadataBattleBack)
      if back && back!=""
        backdrop=back
      end
    end
    if $PokemonGlobal && $PokemonGlobal.nextBattleBack
      backdrop=$PokemonGlobal.nextBattleBack
    end
    return backdrop
  end
  
  def pbBackdrop
    # Choose backdrop
    backdrop=pbGetBackdrop
    if !pbResolveBitmap(sprintf("Graphics/Battle Backs/Backgrounds/" +backdrop))
      backdrop="000"
    end
    environ=@battle.environment
    # Choose bases
    base=""
    trialname="Standard"
    if environ==PBEnvironment::Grass || environ==PBEnvironment::TallGrass
      trialname="Grass"
    elsif environ==PBEnvironment::Boardwalk
      trialname="Boardwalk"
    elsif environ==PBEnvironment::Sand
      trialname="Sand"
    elsif $PokemonGlobal.surfing || environ==PBEnvironment::Underwater
      trialname="Water"
    end
    if pbResolveBitmap(sprintf("Graphics/Battle Backs/Bases/" +trialname)) # +backdrop used to be as well
      base=trialname
    end
    # Choose time of day
    time=""
    if ($PokemonSystem.enableshading==1 rescue false) && $PokemonSystem
      trialname=""
      timenow=pbGetTimeNow
      if PBDayNight.isNight?(timenow)
        trialname="_night"
      elsif PBDayNight.isEvening?(timenow)
        trialname="_eve"
      end
      if pbResolveBitmap(sprintf("Graphics/Battle Backs/Backgrounds/"+backdrop+trialname))
        time=trialname
      end
    end
    # Apply graphics
=begin
    battlebg="Graphics/Battle Backs/battlebg"+backdrop+time
    enemybase="Graphics/Battle Backs/enemybase"+base#+backdrop+time
    playerbase="Graphics/Battle Backs/playerbase"+base#+backdrop+time
=end
    battlebg="Graphics/Battle Backs/Backgrounds/"+backdrop+time
    enemybase="Graphics/Battle Backs/Bases/"+base
    playerbase="Graphics/Battle Backs/Bases/"+base+"_back"
    pbAddPlane("battlebg",battlebg,@viewport)
    pbAddSprite("battlebg2",0,0,battlebg,@viewport) # CLR
    pbAddSprite("playerbase",
       PokeBattle_SceneConstants::PLAYERBASEX,
       PokeBattle_SceneConstants::PLAYERBASEY,playerbase,@viewport)
    @sprites["playerbase"].x-=@sprites["playerbase"].bitmap.width/2 if @sprites["playerbase"].bitmap!=nil
    @sprites["playerbase"].y-=@sprites["playerbase"].bitmap.height if @sprites["playerbase"].bitmap!=nil
    pbAddSprite("enemybase",
       PokeBattle_SceneConstants::FOEBASEX,
       PokeBattle_SceneConstants::FOEBASEY,enemybase,@viewport)
    @sprites["enemybase"].x-=@sprites["enemybase"].bitmap.width/2 if @sprites["enemybase"].bitmap!=nil
    @sprites["enemybase"].y-=@sprites["enemybase"].bitmap.height/2 if @sprites["enemybase"].bitmap!=nil
    @sprites["battlebg2"].visible=false # CLR
    @sprites["battlebg"].z=0
    @sprites["playerbase"].z=1
    @sprites["enemybase"].z=1
  end

  # Returns whether the party line-ups are currently appearing on-screen
  def inPartyAnimation?
    return @enablePartyAnim && @partyAnimPhase<3
  end

  # Shows the party line-ups appearing on-screen
  def partyAnimationRestart(doublePreviewTop)
  @doublePreviewTop=doublePreviewTop
  yvalue=114
  yvalue-=72 if doublePreviewTop
  pbAddSprite("partybarfoe",-400,yvalue,"Graphics/UI/Battle/overlay_lineup",@viewport)
  @sprites["partybarfoe"].visible=true
  @partyAnimPhase=0
end 

def partyAnimationFade
  frame=0
  while(frame<24)
    if @partyAnimPhase!=3
      pbGraphicsUpdate
      next
    end
    frame+=1
    @sprites["partybarfoe"].x+=8
    @sprites["partybarfoe"].opacity-=12
    for i in 0...6
      partyI = i
      @sprites["enemy#{partyI}"].opacity-=12
      @sprites["enemy#{partyI}"].x+=8 if frame>=i*4
    end
    pbGraphicsUpdate
  end
  for i in 0...6
    partyI = i
    pbDisposeSprite(@sprites,"player#{partyI}")
  end
  pbDisposeSprite(@sprites,"partybarfoe")
end
	def partyAnimationUpdate
    return if !inPartyAnimation?
    ballmovedist=16 # How far a ball moves each frame
    # Bar slides on
    if @partyAnimPhase==0
      @sprites["partybarfoe"].x+=16
      @sprites["partybarplayer"].x-=16 if @sprites["partybarplayer"]
      if @sprites["partybarfoe"].x+@sprites["partybarfoe"].bitmap.width>=PokeBattle_SceneConstants::FOEPARTYBAR_X
        @sprites["partybarfoe"].x=PokeBattle_SceneConstants::FOEPARTYBAR_X-@sprites["partybarfoe"].bitmap.width
        @sprites["partybarplayer"].x=PokeBattle_SceneConstants::PLAYERPARTYBAR_X if @sprites["partybarplayer"]
        @partyAnimPhase=1
      end
      return
    end
    # Set up all balls ready to slide on
    if @partyAnimPhase==1
      @xposplayer=PokeBattle_SceneConstants::PLAYERPARTYBALL1_X
      counter=0
      # Make sure the ball starts off-screen
      while @xposplayer<Graphics.width
        counter+=1; @xposplayer+=ballmovedist
      end
      @xposenemy=PokeBattle_SceneConstants::FOEPARTYBALL1_X-counter*ballmovedist
      for i in 0...6
        # Choose the ball's graphic (player's side)
        ballgraphic="Graphics/UI/Battle/icon_ball_empty"
        if i<@battle.party1.length && @battle.party1[i]
          if @battle.party1[i].hp<=0 || @battle.party1[i].isEgg?
            ballgraphic="Graphics/UI/Battle/icon_ball_faint"
          elsif @battle.party1[i].status>0
            ballgraphic="Graphics/UI/Battle/icon_ball_status"
          else
            ballgraphic="Graphics/UI/Battle/icon_ball"
          end
        end
        pbAddSprite("player#{i}",
           @xposplayer+i*ballmovedist*6,PokeBattle_SceneConstants::PLAYERPARTYBALL1_Y,
           ballgraphic,@viewport)
        @sprites["player#{i}"].z=41
        # Choose the ball's graphic (opponent's side)
        ballgraphic="Graphics/UI/Battle/icon_ball_empty"
        enemyindex=i
        if @battle.doublebattle && i>=3
          enemyindex=(i%3)+@battle.pbSecondPartyBegin(1)
        end
        if enemyindex<@battle.party2.length && @battle.party2[enemyindex]
          if @battle.party2[enemyindex].hp<=0 || @battle.party2[enemyindex].isEgg?
            ballgraphic="Graphics/UI/Battle/icon_ball_faint"
          elsif @battle.party2[enemyindex].status>0
            ballgraphic="Graphics/UI/Battle/icon_ball_status"
          else
            ballgraphic="Graphics/UI/Battle/icon_ball"
          end
        end
        pbAddSprite("enemy#{i}",
           @xposenemy-i*ballmovedist*6,PokeBattle_SceneConstants::FOEPARTYBALL1_Y,
					 ballgraphic,@viewport)
				@sprites["enemy#{i}"].y-=72 if @doublePreviewTop
        @sprites["enemy#{i}"].z=41
      end
      @partyAnimPhase=2
    end
    # Balls slide on
    if @partyAnimPhase==2
      for i in 0...6
        if @sprites["enemy#{i}"].x<PokeBattle_SceneConstants::FOEPARTYBALL1_X-i*PokeBattle_SceneConstants::FOEPARTYBALL_GAP
          @sprites["enemy#{i}"].x+=ballmovedist
          @sprites["player#{i}"].x-=ballmovedist if @sprites["partybarplayer"]
          if @sprites["enemy#{i}"].x>=PokeBattle_SceneConstants::FOEPARTYBALL1_X-i*PokeBattle_SceneConstants::FOEPARTYBALL_GAP
            @sprites["enemy#{i}"].x=PokeBattle_SceneConstants::FOEPARTYBALL1_X-i*PokeBattle_SceneConstants::FOEPARTYBALL_GAP
            @sprites["player#{i}"].x=PokeBattle_SceneConstants::PLAYERPARTYBALL1_X+i*PokeBattle_SceneConstants::PLAYERPARTYBALL_GAP
            if i==5
              @partyAnimPhase=3
            end
          end
        end
      end
    end
  end

  def pbStartBattle(battle)
    # Called whenever the battle begins
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @showingplayer=true
    @showingenemy=true
    @sprites.clear
    @viewport=Viewport.new(0,Graphics.height/2,Graphics.width,0)
    @viewport.z=99999
    @traineryoffset=(Graphics.height-320) # Adjust player's side for screen size
    @foeyoffset=(@traineryoffset*3/4).floor  # Adjust foe's side for screen size
    pbBackdrop
    pbAddSprite("partybarfoe",
       PokeBattle_SceneConstants::FOEPARTYBAR_X,
       PokeBattle_SceneConstants::FOEPARTYBAR_Y,
       "Graphics/UI/Battle/overlay_lineup",@viewport)
    pbAddSprite("partybarplayer",
       PokeBattle_SceneConstants::PLAYERPARTYBAR_X,
       PokeBattle_SceneConstants::PLAYERPARTYBAR_Y,
       "Graphics/UI/Battle/overlay_lineup",@viewport)
    @sprites["partybarfoe"].x-=@sprites["partybarfoe"].bitmap.width
    @sprites["partybarplayer"].mirror=true
    @sprites["partybarfoe"].z=40
    @sprites["partybarplayer"].z=40
    @sprites["partybarfoe"].visible=false
    @sprites["partybarplayer"].visible=false
    if @battle.player.is_a?(Array)
      trainerfile=pbPlayerSpriteBackFile(@battle.player[0].trainertype)
      pbAddSprite("player",
           PokeBattle_SceneConstants::PLAYERTRAINERD1_X,
           PokeBattle_SceneConstants::PLAYERTRAINERD1_Y,trainerfile,@viewport)
      trainerfile=pbTrainerSpriteBackFile(@battle.player[1].trainertype)
      pbAddSprite("playerB",
           PokeBattle_SceneConstants::PLAYERTRAINERD2_X,
           PokeBattle_SceneConstants::PLAYERTRAINERD2_Y,trainerfile,@viewport)
      if @sprites["player"].bitmap
        if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
          @sprites["player"].src_rect.x=0
          @sprites["player"].src_rect.width=@sprites["player"].bitmap.width/5
        end
        @sprites["player"].x-=(@sprites["player"].src_rect.width/2)
        @sprites["player"].y-=@sprites["player"].bitmap.height
        @sprites["player"].z=30
      end
      if @sprites["playerB"].bitmap
        if @sprites["playerB"].bitmap.width>@sprites["playerB"].bitmap.height
          @sprites["playerB"].src_rect.x=0
          @sprites["playerB"].src_rect.width=@sprites["playerB"].bitmap.width/5
        end
        @sprites["playerB"].x-=(@sprites["playerB"].src_rect.width/2)
        @sprites["playerB"].y-=@sprites["playerB"].bitmap.height
        @sprites["playerB"].z=31
      end
    else
      trainerfile=pbPlayerSpriteBackFile(@battle.player.trainertype)
      pbAddSprite("player",
           PokeBattle_SceneConstants::PLAYERTRAINER_X,
           PokeBattle_SceneConstants::PLAYERTRAINER_Y,trainerfile,@viewport)
      if @sprites["player"].bitmap
        if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
          @sprites["player"].src_rect.x=0
          @sprites["player"].src_rect.width=@sprites["player"].bitmap.width/5
        end
        @sprites["player"].x-=(@sprites["player"].src_rect.width/2)
        @sprites["player"].y-=@sprites["player"].bitmap.height
        @sprites["player"].z=30
      end
    end
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[1].trainertype)
        pbAddSprite("trainer2",
           PokeBattle_SceneConstants::FOETRAINERD2_X,
           PokeBattle_SceneConstants::FOETRAINERD2_Y,trainerfile,@viewport)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[0].trainertype)
        pbAddSprite("trainer",
           PokeBattle_SceneConstants::FOETRAINERD1_X,
           PokeBattle_SceneConstants::FOETRAINERD1_Y,trainerfile,@viewport)
      else
        trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
        pbAddSprite("trainer",
           PokeBattle_SceneConstants::FOETRAINER_X,
           PokeBattle_SceneConstants::FOETRAINER_Y,trainerfile,@viewport)
      end
    else
      trainerfile="Graphics/Characters/trfront"
      pbAddSprite("trainer",
           PokeBattle_SceneConstants::FOETRAINER_X,
           PokeBattle_SceneConstants::FOETRAINER_Y,trainerfile,@viewport)
    end
    if @sprites["trainer"].bitmap
      @sprites["trainer"].x-=(@sprites["trainer"].bitmap.width/2)
      @sprites["trainer"].y-=@sprites["trainer"].bitmap.height
      @sprites["trainer"].z=7
    end
    if @sprites["trainer2"] && @sprites["trainer2"].bitmap
      @sprites["trainer2"].x-=(@sprites["trainer2"].bitmap.width/2)
      @sprites["trainer2"].y-=@sprites["trainer2"].bitmap.height
      @sprites["trainer2"].z=8
    end
    @sprites["shadow0"]=IconSprite.new(0,0,@viewport)
    @sprites["shadow0"].z=3
    pbAddSprite("shadow1",0,0,"Graphics/UI/Battle/battler_shadow",@viewport)
    @sprites["shadow1"].z=3
    @sprites["shadow1"].visible=false
    @sprites["pokemon0"]=PokemonBattlerSprite.new(battle.doublebattle,0,@viewport)
    @sprites["pokemon0"].z=16
    @sprites["pokemon1"]=PokemonBattlerSprite.new(battle.doublebattle,1,@viewport)
    @sprites["pokemon1"].z=21
    if battle.doublebattle
      @sprites["shadow2"]=IconSprite.new(0,0,@viewport)
      @sprites["shadow2"].z=3
      pbAddSprite("shadow3",0,0,"Graphics/UI/Battle/battler_shadow",@viewport)
      @sprites["shadow3"].z=3
      @sprites["shadow3"].visible=false
      @sprites["pokemon2"]=PokemonBattlerSprite.new(battle.doublebattle,2,@viewport)
      @sprites["pokemon2"].z=26
      @sprites["pokemon3"]=PokemonBattlerSprite.new(battle.doublebattle,3,@viewport)
      @sprites["pokemon3"].z=11
    end
    @sprites["battlebox0"]=PokemonDataBox.new(battle.battlers[0],battle.doublebattle,@viewport)
    @sprites["battlebox1"]=PokemonDataBox.new(battle.battlers[1],battle.doublebattle,@viewport)
    if battle.doublebattle
      @sprites["battlebox2"]=PokemonDataBox.new(battle.battlers[2],battle.doublebattle,@viewport)
      @sprites["battlebox3"]=PokemonDataBox.new(battle.battlers[3],battle.doublebattle,@viewport)
    end
    # "cord" variable definition
    # * Array 0 = Center
    # * Array 1 = Upper Left
    # * Array 2 = Upper
    # * Array 3 = Upper Right
    # * Array 4 = Right
    # * Array 5 = Bottom Right
    # * Array 6 = Bottom
    # * Array 7 = Bottom Left
    # * Array 8 = Left
    # * Array Item 0 = X Pos Start
    # * Array Item 1 = X Pos Offset
    # * Array Item 2 = Y Pos Start
    # * Array Item 3 = Y Pos Offset
    cord = [
             [2,0,2,0], # Center
             [4,0,4,0], # Upper Left
             [2,0,4,0], # Upper
             [4,2,4,0], # Upper Right
             [4,2,2,0], # Right
             [4,2,4,2], # Bottom Right
             [2,0,4,2], # Bottom
             [4,0,4,2], # Bottom Left
             [4,0,2,0]  # Left
           ][($PokemonSystem.battlecolor rescue 0)]
    x = (@sprites["battlebg2"].bitmap.width/cord[0]) + (@sprites["battlebg2"].bitmap.width/cord[1] rescue 0)
    y = (@sprites["battlebg2"].bitmap.height/cord[2]) + (@sprites["battlebg2"].bitmap.height/cord[3] rescue 0)
    clr = @sprites["battlebg2"].bitmap.get_pixel(x, y)
    pbAddSprite("backgroundbox",0,Graphics.height-96,"Graphics/UI/Battle/overlay_background",@viewport)
    @sprites["backgroundbox"].z=89
    @sprites["backgroundbox"].bitmap.fill_rect(0,0,@sprites["backgroundbox"].bitmap.width,@sprites["backgroundbox"].bitmap.height,clr)
    $isDarkMessage=isDarkColor(clr)
    pbAddSprite("messagebox",0,Graphics.height-96,"Graphics/UI/Battle/overlay_message",@viewport)
    @sprites["messagebox"].z=90
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].z=90
    @sprites["messagewindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["messagewindow"].letterbyletter=true
    @sprites["messagewindow"].viewport=@viewport
    @sprites["messagewindow"].z=100
    @sprites["commandwindow"]=CommandMenuDisplay.new(@viewport,pbGetBackdrop,$isDarkMessage)
    @sprites["commandwindow"].z=100
    @sprites["fightwindow"]=FightMenuDisplay.new(nil,@viewport,pbGetBackdrop,$isDarkMessage)
    @sprites["fightwindow"].z=100
    pbShowWindow(MESSAGEBOX)
    pbSetMessageMode(false,$isDarkMessage)
    trainersprite1=@sprites["trainer"]
    trainersprite2=@sprites["trainer2"]
    if !@battle.opponent
      @sprites["trainer"].visible=false
      if @battle.party2.length>=1
        if @battle.party2.length==1
          species=@battle.party2[0].species
          @sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
          @sprites["pokemon1"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon1"].x=PokeBattle_SceneConstants::FOEBATTLER_X
          @sprites["pokemon1"].x-=@sprites["pokemon1"].width/2
          @sprites["pokemon1"].y=PokeBattle_SceneConstants::FOEBATTLER_Y
          @sprites["pokemon1"].y+=adjustBattleSpriteY(@sprites["pokemon1"],species,1)
          @sprites["pokemon1"].visible=true
          @sprites["shadow1"].x=PokeBattle_SceneConstants::FOEBATTLER_X
          @sprites["shadow1"].y=PokeBattle_SceneConstants::FOEBATTLER_Y
          @sprites["shadow1"].x-=@sprites["shadow1"].bitmap.width/2 if @sprites["shadow1"].bitmap!=nil
          @sprites["shadow1"].y-=@sprites["shadow1"].bitmap.height/2 if @sprites["shadow1"].bitmap!=nil
          @sprites["shadow1"].visible=showShadow?(species)
          trainersprite1=@sprites["pokemon1"]
        elsif @battle.party2.length==2
          species=@battle.party2[0].species
          @sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
          @sprites["pokemon1"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon1"].x=PokeBattle_SceneConstants::FOEBATTLERD1_X
          @sprites["pokemon1"].x-=@sprites["pokemon1"].width/2
          @sprites["pokemon1"].y=PokeBattle_SceneConstants::FOEBATTLERD1_Y
          @sprites["pokemon1"].y+=adjustBattleSpriteY(@sprites["pokemon1"],species,1)
          @sprites["pokemon1"].visible=true
          @sprites["shadow1"].x=PokeBattle_SceneConstants::FOEBATTLERD1_X
          @sprites["shadow1"].y=PokeBattle_SceneConstants::FOEBATTLERD1_Y
          @sprites["shadow1"].x-=@sprites["shadow1"].bitmap.width/2 if @sprites["shadow1"].bitmap!=nil
          @sprites["shadow1"].y-=@sprites["shadow1"].bitmap.height/2 if @sprites["shadow1"].bitmap!=nil
          @sprites["shadow1"].visible=showShadow?(species)
          trainersprite1=@sprites["pokemon1"]
          species=@battle.party2[1].species
          @sprites["pokemon3"].setPokemonBitmap(@battle.party2[1],false)
          @sprites["pokemon3"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon3"].x=PokeBattle_SceneConstants::FOEBATTLERD2_X
          @sprites["pokemon3"].x-=@sprites["pokemon3"].width/2
          @sprites["pokemon3"].y=PokeBattle_SceneConstants::FOEBATTLERD2_Y
          @sprites["pokemon3"].y+=adjustBattleSpriteY(@sprites["pokemon3"],species,3)
          @sprites["pokemon3"].visible=true
          @sprites["shadow3"].x=PokeBattle_SceneConstants::FOEBATTLERD2_X
          @sprites["shadow3"].y=PokeBattle_SceneConstants::FOEBATTLERD2_Y
          @sprites["shadow3"].x-=@sprites["shadow3"].bitmap.width/2 if @sprites["shadow3"].bitmap!=nil
          @sprites["shadow3"].y-=@sprites["shadow3"].bitmap.height/2 if @sprites["shadow3"].bitmap!=nil
          @sprites["shadow3"].visible=showShadow?(species)
          trainersprite2=@sprites["pokemon3"]
        end
      end
    end
    #################
    # Move trainers/bases/etc. off-screen
    oldx=[]
    oldx[0]=@sprites["playerbase"].x; @sprites["playerbase"].x+=Graphics.width
    oldx[1]=@sprites["player"].x; @sprites["player"].x+=Graphics.width
    if @sprites["playerB"]
      oldx[2]=@sprites["playerB"].x; @sprites["playerB"].x+=Graphics.width
    end
    oldx[3]=@sprites["enemybase"].x; @sprites["enemybase"].x-=Graphics.width
    oldx[4]=trainersprite1.x; trainersprite1.x-=Graphics.width
    if trainersprite2
      oldx[5]=trainersprite2.x; trainersprite2.x-=Graphics.width
    end
    oldx[6]=@sprites["shadow1"].x; @sprites["shadow1"].x-=Graphics.width
    if @sprites["shadow3"]
      oldx[7]=@sprites["shadow3"].x; @sprites["shadow3"].x-=Graphics.width
    end
    @sprites["partybarfoe"].x-=PokeBattle_SceneConstants::FOEPARTYBAR_X
    @sprites["partybarplayer"].x+=Graphics.width-PokeBattle_SceneConstants::PLAYERPARTYBAR_X
    #################
    appearspeed=12
    (1+Graphics.width/appearspeed).times do
      tobreak=true
      if @viewport.rect.y>0
        @viewport.rect.y-=appearspeed/2
        @viewport.rect.y=0 if @viewport.rect.y<0
        @viewport.rect.height+=appearspeed
        @viewport.rect.height=Graphics.height if @viewport.rect.height>Graphics.height
        tobreak=false
      end
      if !tobreak
        for i in @sprites
          i[1].ox=@viewport.rect.x
          i[1].oy=@viewport.rect.y
        end
      end
      if @sprites["playerbase"].x>oldx[0]
        @sprites["playerbase"].x-=appearspeed; tobreak=false
        @sprites["playerbase"].x=oldx[0] if @sprites["playerbase"].x<oldx[0]
      end
      if @sprites["player"].x>oldx[1]
        @sprites["player"].x-=appearspeed; tobreak=false
        @sprites["player"].x=oldx[1] if @sprites["player"].x<oldx[1]
      end
      if @sprites["playerB"] && @sprites["playerB"].x>oldx[2]
        @sprites["playerB"].x-=appearspeed; tobreak=false
        @sprites["playerB"].x=oldx[2] if @sprites["playerB"].x<oldx[2]
      end
      if @sprites["enemybase"].x<oldx[3]
        @sprites["enemybase"].x+=appearspeed; tobreak=false
        @sprites["enemybase"].x=oldx[3] if @sprites["enemybase"].x>oldx[3]
      end
      if trainersprite1.x<oldx[4]
        trainersprite1.x+=appearspeed; tobreak=false
        trainersprite1.x=oldx[4] if trainersprite1.x>oldx[4]
      end
      if trainersprite2 && trainersprite2.x<oldx[5]
        trainersprite2.x+=appearspeed; tobreak=false
        trainersprite2.x=oldx[5] if trainersprite2.x>oldx[5]
      end
      if @sprites["shadow1"].x<oldx[6]
        @sprites["shadow1"].x+=appearspeed; tobreak=false
        @sprites["shadow1"].x=oldx[6] if @sprites["shadow1"].x>oldx[6]
      end
      if @sprites["shadow3"] && @sprites["shadow3"].x<oldx[7]
        @sprites["shadow3"].x+=appearspeed; tobreak=false
        @sprites["shadow3"].x=oldx[7] if @sprites["shadow3"].x>oldx[7]
      end
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if tobreak
    end
    #################
    if @battle.opponent
      @enablePartyAnim=true
      @partyAnimPhase=0
      @sprites["partybarfoe"].visible=true
      @sprites["partybarplayer"].visible=true
    else
      pbPlayCry(@battle.party2[0])                             # Play cry for wild Pokémon
      pbPlayCry(@battle.party2[1]) if @battle.party2.length==2 # Play cry for 2nd wild Pokémon
      @sprites["battlebox1"].appear
      @sprites["battlebox3"].appear if @battle.party2.length==2 
      appearing=true
      begin
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        @sprites["pokemon1"].tone.red+=8 if @sprites["pokemon1"].tone.red<0
        @sprites["pokemon1"].tone.blue+=8 if @sprites["pokemon1"].tone.blue<0
        @sprites["pokemon1"].tone.green+=8 if @sprites["pokemon1"].tone.green<0
        @sprites["pokemon1"].tone.gray+=8 if @sprites["pokemon1"].tone.gray<0
        appearing=@sprites["battlebox1"].appearing
        if @battle.party2.length==2 
          @sprites["pokemon3"].tone.red+=8 if @sprites["pokemon3"].tone.red<0
          @sprites["pokemon3"].tone.blue+=8 if @sprites["pokemon3"].tone.blue<0
          @sprites["pokemon3"].tone.green+=8 if @sprites["pokemon3"].tone.green<0
          @sprites["pokemon3"].tone.gray+=8 if @sprites["pokemon3"].tone.gray<0
          appearing=(appearing || @sprites["battlebox3"].appearing)
        end
      end while appearing
      # Show shiny animation for wild Pokémon
      if @battle.battlers[1].isShiny? && @battle.battlescene
        pbCommonAnimation("Shiny",@battle.battlers[1],nil)
      end
      if @battle.party2.length==2
        if @battle.battlers[3].isShiny? && @battle.battlescene
          pbCommonAnimation("Shiny",@battle.battlers[3],nil)
        end
      end
      # Show UB animation for wild Pokemon
      if isUltraBeast?(@battle.battlers[1]) && @battle.battlescene
        pbCommonAnimation("UB",@battle.battlers[1],nil)
      end
      if @battle.party2.length==2
        if isUltraBeast?(@battle.battlers[3]) && @battle.battlescene
          pbCommonAnimation("UB",@battle.battlers[3],nil)
        end
      end
=begin
      # Show Alolan animation for wild Pokemon
      if isAlolan?(@battle.battlers[1]) && @battle.battlescene
        pbCommonAnimation("Alolan",@battle.battlers[1],nil)
      end
      if @battle.party2.length==2
        if isAlolan?(@battle.battlers[3]) && @battle.battlescene
          pbCommonAnimation("Alolan",@battle.battlers[3],nil)
        end
      end
      # Show Galarian animation for wild Pokemon
      if isGalarian?(@battle.battlers[1]) && @battle.battlescene
        pbCommonAnimation("Galarian",@battle.battlers[1],nil)
      end
      if @battle.party2.length==2
        if isGalarian?(@battle.battlers[3]) && @battle.battlescene
          pbCommonAnimation("Galarian",@battle.battlers[3],nil)
        end
      end
=end
    end
  end
  
  def pbCreatePopUp(oldamount=0,newamount=0,maxamount=0,taskname="Task",image="image.png")
    if oldamount != newamount
      sprite=PokemonTaskDataBox.new(oldamount,maxamount,taskname,image,@viewport)
      sprite.appear
      while sprite.appearing
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        sprite.update
      end
      sprite.animateHP(oldamount,[newamount,maxamount].min)
      while sprite.animatingHP
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        sprite.update
      end
      40.times do
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
      end
      sprite.disappear
      while sprite.disappearing
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        sprite.update
      end
      sprite.dispose
    end
  end
  
  def pbCheckEvents
    # Pokemon Box
    if $PokemonBag.pbQuantity(:POKEMONBOX)>0 # Avoid crashes as the first one 
      currentStep=PokemonBoxScene.new.currentStep
      oldtaskstatus=$game_variables[PBOX_VARIABLES[5]]
      step = $game_variables[PBOX_VARIABLES[1]][currentStep][0]
      taskstatus=$PokemonGlobal.pokebox[step] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
      taskstatus2=$game_variables[PBOX_VARIABLES[1]][currentStep][2]
      pbCreatePopUp($game_variables[PBOX_VARIABLES[5]],taskstatus,taskstatus2,_INTL("Pokémon Box"),["Graphics/UI/Pokemon Box/icons",step])
    end
    # End
  end

  def pbEndBattle(result)
    pbCheckEvents
    @abortable=false
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end

  def pbRecall(battlerindex)
    @briefmessage=false
    if @battle.pbIsOpposing?(battlerindex)
      origin=PokeBattle_SceneConstants::FOEBATTLER_Y
      if @battle.doublebattle
        origin=PokeBattle_SceneConstants::FOEBATTLERD1_Y if battlerindex==1
        origin=PokeBattle_SceneConstants::FOEBATTLERD2_Y if battlerindex==3
      end
      @sprites["shadow#{battlerindex}"].visible=false
    else
      origin=PokeBattle_SceneConstants::PLAYERBATTLER_Y
      if @battle.doublebattle
        origin=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y if battlerindex==0
        origin=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y if battlerindex==2
      end
    end
    spritePoke=@sprites["pokemon#{battlerindex}"]
    picturePoke=PictureEx.new(spritePoke.z)
    dims=[spritePoke.x,spritePoke.y]
    center=getSpriteCenter(spritePoke)
    # starting positions
    picturePoke.moveVisible(1,true)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    picturePoke.moveXY(0,1,center[0],center[1])
    # directives
    picturePoke.moveTone(10,1,Tone.new(248,248,248,248))
    delay=picturePoke.totalDuration
    picturePoke.moveSE(delay,"Audio/SE/recall")
    picturePoke.moveZoom(15,delay,0)
    picturePoke.moveXY(15,delay,center[0],origin)
    picturePoke.moveVisible(picturePoke.totalDuration,false)
    picturePoke.moveTone(0,picturePoke.totalDuration,Tone.new(0,0,0,0))
    picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
    loop do
      picturePoke.update
      setPictureSprite(spritePoke,picturePoke)
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if !picturePoke.running?
    end
  end

  def pbTrainerSendOut(battlerindex,pkmn)
    illusionpoke=@battle.battlers[battlerindex].effects[PBEffects::Illusion]
    @briefmessage=false
    fadeanim=nil
    while inPartyAnimation?; end
    if @showingenemy
      fadeanim=TrainerFadeAnimation.new(@sprites)
    end
    frame=0
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn,false)
    if illusionpoke
      @sprites["pokemon#{battlerindex}"].setPokemonBitmap(illusionpoke,false)
    end
    sendout=PokeballSendOutAnimation.new(@sprites["pokemon#{battlerindex}"],
       @sprites,@battle.battlers[battlerindex],illusionpoke,@battle.doublebattle)
    loop do
      fadeanim.update if fadeanim
      frame+=1    
      if frame==1
        @sprites["battlebox#{battlerindex}"].appear
      end
      if frame>=10
        sendout.update
      end
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if (!fadeanim || fadeanim.animdone?) && sendout.animdone? &&
         !@sprites["battlebox#{battlerindex}"].appearing
    end
    if @battle.battlers[battlerindex].isShiny? && @battle.battlescene
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
    if isUltraBeast?(@battle.battlers[battlerindex]) && @battle.battlescene
      pbCommonAnimation("UB",@battle.battlers[battlerindex],nil)
    end
=begin
    if isAlolan?(@battle.battlers[battlerindex]) && @battle.battlescene
      pbCommonAnimation("Alolan",@battle.battlers[battlerindex],nil)
    end
=end
    sendout.dispose
    if @showingenemy
      @showingenemy=false
      pbDisposeSprite(@sprites,"trainer")
      pbDisposeSprite(@sprites,"partybarfoe")
      for i in 0...6
        pbDisposeSprite(@sprites,"enemy#{i}")
      end
    end
    pbRefresh
  end

  def pbSendOut(battlerindex,pkmn) # Player sending out Pokémon
    while inPartyAnimation?; end
    illusionpoke=@battle.battlers[battlerindex].effects[PBEffects::Illusion]
    balltype=pkmn.ballused
    balltype=illusionpoke.ballused if illusionpoke
    ballbitmap=sprintf("Graphics/Battle animations/ball_%02d",balltype)
    pictureBall=PictureEx.new(32)
    delay=1
    pictureBall.moveVisible(delay,true)
    pictureBall.moveName(delay,ballbitmap)
    pictureBall.moveOrigin(delay,PictureOrigin::Center)
    # Setting the ball's movement path
    path=[[0,   146], [10,  134], [21,  122], [30,  112], 
          [39,  104], [46,   99], [53,   95], [61,   93], 
          [68,   93], [75,   96], [82,  102], [89,  111], 
          [94,  121], [100, 134], [106, 150], [111, 166], 
          [116, 183], [120, 199], [124, 216], [127, 238]]
    spriteBall=IconSprite.new(0,0,@viewport)
    spriteBall.visible=false
    angle=0
    multiplier=1.0
    if @battle.doublebattle
      multiplier=(battlerindex==0) ? 0.7 : 1.3
    end
    for coord in path
      delay=pictureBall.totalDuration
      pictureBall.moveAngle(0,delay,angle)
      pictureBall.moveXY(1,delay,coord[0]*multiplier,coord[1])
      angle+=40
      angle%=360
    end
    pictureBall.adjustPosition(0,@traineryoffset)
    @sprites["battlebox#{battlerindex}"].visible=false
    @briefmessage=false
    fadeanim=nil
    if @showingplayer
      fadeanim=PlayerFadeAnimation.new(@sprites)
    end
    frame=0
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn,true)
    if illusionpoke
      @sprites["pokemon#{battlerindex}"].setPokemonBitmap(illusionpoke,true)
    end
    sendout=PokeballPlayerSendOutAnimation.new(@sprites["pokemon#{battlerindex}"],
       @sprites,@battle.battlers[battlerindex],illusionpoke,@battle.doublebattle)
    loop do
      fadeanim.update if fadeanim
      frame+=1
      if frame>1 && !pictureBall.running? && !@sprites["battlebox#{battlerindex}"].appearing
        @sprites["battlebox#{battlerindex}"].appear
      end
      if frame>=3 && !pictureBall.running?
        sendout.update
      end
      if (frame>=10 || !fadeanim) && pictureBall.running?
        pictureBall.update
        setPictureIconSprite(spriteBall,pictureBall)
      end
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if (!fadeanim || fadeanim.animdone?) && sendout.animdone? &&
         !@sprites["battlebox#{battlerindex}"].appearing
    end
    spriteBall.dispose
    sendout.dispose
    if @battle.battlers[battlerindex].isShiny? && @battle.battlescene
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
=begin
    if isAlolan?(@battle.battlers[battlerindex]) && @battle.battlescene
      pbCommonAnimation("Alolan",@battle.battlers[battlerindex],nil)
    end
    if isGalarian?(@battle.battlers[battlerindex]) && @battle.battlescene
      pbCommonAnimation("Galarian",@battle.battlers[battlerindex],nil)
    end
=end
    if isUltraBeast?(@battle.battlers[battlerindex]) && @battle.battlescene
      pbCommonAnimation("UB",@battle.battlers[battlerindex],nil)
    end
    if @showingplayer
      @showingplayer=false
      pbDisposeSprite(@sprites,"player")
      pbDisposeSprite(@sprites,"partybarplayer")
      for i in 0...6
        pbDisposeSprite(@sprites,"player#{i}")
      end
    end
    pbRefresh
  end

  def pbTrainerWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbMoveString(move)
    ret=_INTL("{1}",move.name)
    typename=PBTypes.getName(move.type)
    if move.id>0
      ret+=_INTL(" ({1}) PP: {2}/{3}",typename,move.pp,move.totalpp)
    end
    return ret
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
    pbGraphicsUpdate
  end

  def pbSafariStart
    @briefmessage=false
    @sprites["battlebox0"]=SafariDataBox.new(@battle,@viewport)
    @sprites["battlebox0"].appear
    loop do
      @sprites["battlebox0"].update
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if !@sprites["battlebox0"].appearing
    end
    pbRefresh
  end

  def pbResetCommandIndices
    @lastcmd=[0,0,0,0]
  end

  def pbResetMoveIndex(index)
    @lastmove[index]=0
  end

  def pbSafariCommandMenu(index)
    pbCommandMenuEx(index,[
       _INTL("What will {1} throw?",@battle.pbPlayer.name),
       _INTL("Ball"),
       _INTL("Bait"),
       _INTL("Rock"),
       _INTL("Run")
    ],2)
  end

# Use this method to display the list of commands.
# Return values: 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  def pbCommandMenu(index)
    shadowTrainer=(hasConst?(PBTypes,:SHADOW) && @battle.opponent)
    shadowTrainer=false # Comment this out to enable the use of Call
    cantrun = @battle.choices[0][0] > 0
    ret=pbCommandMenuEx(index,[
       _INTL("What will {1} do?",@battle.battlers[index].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       cantrun ? _INTL("Cancel") : shadowTrainer ? _INTL("Call") : _INTL("Run")
    ],(cantrun ? 4 : shadowTrainer ? 1 : 0))
    ret=-1 if ret==3 && cantrun         # Convert "Run" to "Cancel"
    ret=4  if ret==3 && shadowTrainer   # Convert "Run" to "Call"
    return ret
  end

  def pbCommandMenuEx(index,texts,mode=0)      # Mode: 0 - regular battle
    pbShowWindow(COMMANDBOX)                   #       1 - Shadow Pokémon battle
    cw=@sprites["commandwindow"]               #       2 - Safari Zone
    cw.setTexts(texts)                         #       3 - Bug Catching Contest
    cw.index=@lastcmd[index]                   #       4 - regular battle - cancel
    cw.mode=mode
    pbSelectBattler(index)
    pbRefresh
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE()
        cw.index-=1
      elsif Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE()
        cw.index+=1
      elsif Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE()
        cw.index-=2
      elsif Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE()
        cw.index+=2
      end
      if Input.trigger?(Input::C)   # Confirm choice
        pbPlayDecisionSE()
        ret=cw.index
        @lastcmd[index]=ret
        return ret
      elsif (Input.trigger?(Input::B)) && index==2 && @lastcmd[0]!=2 # Cancel
        pbPlayDecisionSE()
        return -1
      end
    end 
  end

# Use this method to display the list of moves for a Pokémon
  def pbFightMenu(index)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex].id!=0
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.megaButton=0
    cw.megaButton=1 if @battle.pbCanMegaEvolve?(index)
    pbSelectBattler(index)
    pbRefresh
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE() if cw.setIndex(cw.index-1)
      elsif Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+1)
      elsif Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE() if cw.setIndex(cw.index-2)
      elsif Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+2)
      end
      if Input.trigger?(Input::C)  # Confirm choice
        ret=cw.index
        pbPlayDecisionSE() 
        @lastmove[index]=ret
        return ret
      elsif Input.trigger?(Input::A)   # Use Mega Evolution
        if @battle.pbCanMegaEvolve?(index)
          @battle.pbRegisterMegaEvolution(index)
          cw.megaButton=2
          pbPlayDecisionSE()
        end
      elsif Input.trigger?(Input::B)   # Cancel fight menu
        @lastmove[index]=cw.index
        pbPlayCancelSE()
        return -1
      end
    end
  end

# Use this method to display the inventory
# The return value is the item chosen, or 0 if the choice was canceled.
  def pbItemMenu(index)
    ret=0
    pocket=0
    retindex=-1
    pkmnid=-1
    endscene=true
    oldsprites=pbFadeOutAndHide(@sprites)
    itemscene=PokemonBag_Scene.new
    itemscene.pbStartScene($PokemonBag)
    loop do
      item=itemscene.pbChooseItem
      break if item==0
      usetype=$ItemData[item][ITEMBATTLEUSE]
      cmdUse=-1
      commands=[]
      if usetype==0
        commands[commands.length]=_INTL("Cancel")
      else
        commands[cmdUse=commands.length]=_INTL("Use")
        commands[commands.length]=_INTL("Cancel")
      end
      itemname=PBItems.getName(item)
      command=itemscene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdUse>=0 && command==cmdUse
        if usetype==1 || usetype==3
          modparty=[]
          for i in 0...6
            modparty.push(@battle.party1[@battle.party1order[i]])
          end
          pkmnlist=PokemonScreen_Scene.new
          pkmnscreen=PokemonScreen.new(pkmnlist,modparty)
          itemscene.pbEndScene
          pkmnscreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.doublebattle)
          activecmd=pkmnscreen.pbChoosePokemon
          pkmnid=@battle.party1order[activecmd]
          if activecmd>=0 && pkmnid>=0 && ItemHandlers.hasBattleUseOnPokemon(item)
            pkmnlist.pbEndScene
              pocket=$ItemData[item][ITEMPOCKET]
            ret=item
            retindex=pkmnid
            endscene=false
            break
          end
          pkmnlist.pbEndScene
          itemscene.pbStartScene($PokemonBag)
        elsif usetype==2 || usetype==4
          if ItemHandlers.hasBattleUseOnBattler(item)
              pocket=$ItemData[item][ITEMPOCKET]
            ret=item
            retindex=index
            break
          end
        end
      end
    end
    pbConsumeItemInBattle($PokemonBag,ret) if ret>0
    if ret>0
      $PokemonGlobal.pokebox[9]+=1 if pocket == 7
      $PokemonGlobal.pokebox[12]+=1 if pocket == 2
      $PokemonGlobal.pokebox[18]+=1 if pocket == 5
    end
    itemscene.pbEndScene if endscene
    pbFadeInAndShow(@sprites,oldsprites)
    return [ret,retindex]
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.  The function
# should not allow HM moves to be forgotten.
  def pbForgetMove(pokemon,moveToLearn)
    ret=-1
    pbFadeOutIn(99999){
       scene=PokemonSummaryScene.new
       screen=PokemonSummary.new(scene)
       ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
    }
    return ret
  end

# Called whenever a Pokémon needs one of its moves chosen. Used for Ether.
  def pbChooseMove(pokemon,message)
    ret=-1
    pbFadeOutIn(99999){
       scene=PokemonSummaryScene.new
       screen=PokemonSummary.new(scene)
       ret=screen.pbStartChooseMoveScreen([pokemon],0,message)
    }
    return ret
  end

  def pbNameEntry(helptext,pokemon)
    return pbEnterPokemonName(helptext,0,12,"",pokemon)
  end

  def pbSelectBattler(index,selectmode=1)
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      sprite=@sprites["battlebox#{i}"]
      sprite.selected=(i==index) ? selectmode : 0
      sprite=@sprites["pokemon#{i}"]
      sprite.selected=(i==index) ? selectmode : 0
    end
  end

  def pbFirstTarget(index,targettype)
    case targettype
    when PBTargets::SingleNonUser
      for i in 0...4
        if i!=index && !@battle.battlers[i].isFainted? && 
           @battle.battlers[index].pbIsOpposing?(i)
          return i
        end  
      end
    when PBTargets::UserOrPartner
      return index
    end
    return -1
  end

  def pbUpdateSelected(index)
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      if i==index
        @sprites["battlebox#{i}"].selected=2
        @sprites["pokemon#{i}"].selected=2
      else
        @sprites["battlebox#{i}"].selected=0
        @sprites["pokemon#{i}"].selected=0
      end
      @sprites["battlebox#{i}"].update
      @sprites["pokemon#{i}"].update
    end
  end

# Use this method to make the player choose a target 
# for certain moves in double battles.
  def pbChooseTarget(index,targettype)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex].id!=0
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    
    curwindow=pbFirstTarget(index,targettype)
    if curwindow==-1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow>=0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            case targettype
            when PBTargets::SingleNonUser
              case curwindow
              when 0; newcurwindow=2
              when 1; newcurwindow=0
              when 2; newcurwindow=3
              when 3; newcurwindow=1
              end
            when PBTargets::UserOrPartner
              newcurwindow=(curwindow+2)%4
            end
            curwindow=newcurwindow
            next if targettype==PBTargets::SingleNonUser && curwindow==index
            break if !@battle.battlers[curwindow].isFainted?
          end
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do 
            case targettype
            when PBTargets::SingleNonUser
              case curwindow
              when 0; newcurwindow=1
              when 1; newcurwindow=3
              when 2; newcurwindow=0
              when 3; newcurwindow=2
              end
            when PBTargets::UserOrPartner
              newcurwindow=(curwindow+2)%4
            end
            curwindow=newcurwindow
            next if targettype==PBTargets::SingleNonUser && curwindow==index
            break if !@battle.battlers[curwindow].isFainted?
          end
        end
      end
    end
  end

  def pbSwitch(index,lax,cancancel)
    party=@battle.pbParty(index)
    partypos=@battle.party1order
    ret=-1
    # Fade out and hide all sprites
    visiblesprites=pbFadeOutAndHide(@sprites)
    pbShowWindow(BLANK)
    pbSetMessageMode(true,$isDarkMessage)
    modparty=[]
    for i in 0...6
      modparty.push(party[partypos[i]])
    end
    scene=PokemonScreen_Scene.new
    @switchscreen=PokemonScreen.new(scene,modparty)
    @switchscreen.pbStartScene(_INTL("Choose a Pokémon."),
       @battle.doublebattle && !@battle.fullparty1)
    loop do
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      activecmd=@switchscreen.pbChoosePokemon
      if cancancel && activecmd==-1
        ret=-1
        break
      end
      if activecmd>=0
        commands=[]
        cmdShift=-1
        cmdSummary=-1
        pkmnindex=partypos[activecmd]
        commands[cmdShift=commands.length]=_INTL("Switch In") if !party[pkmnindex].isEgg?
        commands[cmdSummary=commands.length]=_INTL("Summary")
        commands[commands.length]=_INTL("Cancel")
        command=scene.pbShowCommands(_INTL("Do what with {1}?",party[pkmnindex].name),commands)
        if cmdShift>=0 && command==cmdShift
          canswitch=lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) :
             @battle.pbCanSwitch?(index,pkmnindex,true)
          if canswitch
            ret=pkmnindex
            break
          end
        elsif cmdSummary>=0 && command==cmdSummary
          scene.pbSummary(activecmd)
        end
      end
    end
    @switchscreen.pbEndScene
    @switchscreen=nil
    pbShowWindow(BLANK)
    pbSetMessageMode(false,$isDarkMessage)
    # back to main battle screen
    pbFadeInAndShow(@sprites,visiblesprites)
    return ret
  end

  def pbRevive(index)
    party=@battle.pbParty(index)
    partypos=@battle.party1order
    ret=-1
    # Fade out and hide all sprites
    visiblesprites=pbFadeOutAndHide(@sprites)
    pbShowWindow(BLANK)
    pbSetMessageMode(true,$isDarkMessage)
    modparty=[]
    for i in 0...6
      modparty.push(party[partypos[i]])
    end
    scene=PokemonScreen_Scene.new
    @switchscreen=PokemonScreen.new(scene,modparty)
    @switchscreen.pbStartScene(_INTL("Choose a Pokémon."),
       @battle.doublebattle && !@battle.fullparty1)
    loop do
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      activecmd=@switchscreen.pbChoosePokemon
      if activecmd>=0
        pkmnindex=partypos[activecmd]
        canswitch=@battle.pbCanRevive?(index,pkmnindex,true)
        if canswitch
          ret=pkmnindex
          $PokemonGlobal.pokebox[21]+=1 # Intentionally as this is used for reviving
          break
        end
      end
    end
    @switchscreen.pbEndScene
    @switchscreen=nil
    pbShowWindow(BLANK)
    pbSetMessageMode(false,$isDarkMessage)
    # back to main battle screen
    pbFadeInAndShow(@sprites,visiblesprites)
    return ret
  end

  
  def pbDamageAnimation(pkmn,effectiveness)
    pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    shadowsprite=@sprites["shadow#{pkmn.index}"]
    sprite=@sprites["battlebox#{pkmn.index}"]
    oldshadowvisible=shadowsprite.visible
    oldvisible=sprite.visible
    sprite.selected=3
    @briefmessage=false
    6.times do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
    end
    case effectiveness
    when 0
      pbSEPlay("Battle damage normal")
    when 1
      pbSEPlay("Battle damage weak")
    when 2
      pbSEPlay("Battle damage super")
    end
    8.times do
      pkmnsprite.visible=!pkmnsprite.visible
      if oldshadowvisible
        shadowsprite.visible=!shadowsprite.visible
      end
      4.times do
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        sprite.update
      end
    end
    sprite.selected=0
    sprite.visible=oldvisible
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp,anim=false)
    @briefmessage=false
    hpchange=pkmn.hp-oldhp
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[HP change] #{pkmn.pbThis} lost #{hpchange} HP (#{oldhp}=>#{pkmn.hp})")
    else
      PBDebug.log("[HP change] #{pkmn.pbThis} gained #{hpchange} HP (#{oldhp}=>#{pkmn.hp})")
    end
    if anim && @battle.battlescene
      if pkmn.hp>oldhp
        pbCommonAnimation("HealthUp",pkmn,nil)
      elsif pkmn.hp<oldhp
        pbCommonAnimation("HealthDown",pkmn,nil)
      end
    end
    sprite=@sprites["battlebox#{pkmn.index}"]
    sprite.animateHP(oldhp,pkmn.hp)
    while sprite.animatingHP
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      sprite.update
    end
  end

# This method is called whenever a Pokémon faints.
  def pbFainted(pkmn)
    frames=pbCryFrameLength(pkmn.pokemon)
    pbPlayCry(pkmn.pokemon)
    frames.times do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
    end
    @sprites["shadow#{pkmn.index}"].visible=false
    pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    ycoord=0
    if @battle.doublebattle
      ycoord=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y if pkmn.index==0
      ycoord=PokeBattle_SceneConstants::FOEBATTLERD1_Y if pkmn.index==1
      ycoord=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y if pkmn.index==2
      ycoord=PokeBattle_SceneConstants::FOEBATTLERD2_Y if pkmn.index==3
    else
      if @battle.pbIsOpposing?(pkmn.index)
        ycoord=PokeBattle_SceneConstants::FOEBATTLER_Y
      else
        ycoord=PokeBattle_SceneConstants::PLAYERBATTLER_Y
      end
    end
    if @battle.pbIsOpposing?(pkmn.index)
      pbPlayEnemyCollapseSE()
    else
      pbPlayActorCollapseSE()
    end
    loop do
      pkmnsprite.y+=8
      if pkmnsprite.y-pkmnsprite.oy+pkmnsprite.src_rect.height>=ycoord
        pkmnsprite.src_rect.height=ycoord-pkmnsprite.y+pkmnsprite.oy
      end
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if pkmnsprite.y>=ycoord
    end
    pkmnsprite.visible=false
    8.times do
      @sprites["battlebox#{pkmn.index}"].opacity-=32
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
    end
    @sprites["battlebox#{pkmn.index}"].visible=false
    pkmn.pbResetForm
  end

# Use this method to choose a command for the enemy.
  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party,faintedonly=false)
    if faintedonly
      @battle.pbDefaultChooseNewEnemyToRevive(index,party)
    else
      @battle.pbDefaultChooseNewEnemy(index,party)
    end
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
    pbBGSStop()
    pbBGMPlay(pbGetWildVictoryME())
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
    pbBGSStop()
    pbBGMPlay(pbGetTrainerVictoryME(@battle.opponent))
  end

  def pbEXPBar(pokemon,battler,startexp,endexp,tempexp1,tempexp2)
    if battler
      @sprites["battlebox#{battler.index}"].refreshExpLevel
      exprange=(endexp-startexp)
      startexplevel=0
      endexplevel=0
      if exprange!=0
        startexplevel=(tempexp1-startexp)*PokeBattle_SceneConstants::EXPGAUGESIZE/exprange
        endexplevel=(tempexp2-startexp)*PokeBattle_SceneConstants::EXPGAUGESIZE/exprange
      end
      @sprites["battlebox#{battler.index}"].animateEXP(startexplevel,endexplevel)
      while @sprites["battlebox#{battler.index}"].animatingEXP
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
        @sprites["battlebox#{battler.index}"].update
      end
    end
  end

  def pbShowPokedex(species)
    pbFadeOutIn(99999){
       scene=PokemonPokedexScene.new
       screen=PokemonPokedex.new(scene)
       screen.pbDexEntry2(species)
    }
  end

  def pbChangeSpecies(attacker,species)
    pkmn=@sprites["pokemon#{attacker.index}"]
    shadow=@sprites["shadow#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    pkmn.setPokemonBitmapSpecies(attacker.pokemon,species,back)
    pkmn.x=-pkmn.bitmap.width/2
    pkmn.y=adjustBattleSpriteY(pkmn,species,attacker.index)
    if @battle.doublebattle
      case attacker.index
      when 0
        pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLERD1_X
        pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y
      when 1
        pkmn.x+=PokeBattle_SceneConstants::FOEBATTLERD1_X
        pkmn.y+=PokeBattle_SceneConstants::FOEBATTLERD1_Y
      when 2
        pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLERD2_X
        pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y
      when 3
        pkmn.x+=PokeBattle_SceneConstants::FOEBATTLERD2_X
        pkmn.y+=PokeBattle_SceneConstants::FOEBATTLERD2_Y
      end
    else
      pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLER_X if attacker.index==0
      pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLER_Y if attacker.index==0
      pkmn.x+=PokeBattle_SceneConstants::FOEBATTLER_X if attacker.index==1
      pkmn.y+=PokeBattle_SceneConstants::FOEBATTLER_Y if attacker.index==1
    end
    if shadow && !back
      shadow.visible=showShadow?(species)
    end
  end

  def pbChangePokemon(attacker,pokemon)
    pkmn=@sprites["pokemon#{attacker.index}"]
    shadow=@sprites["shadow#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    pkmn.setPokemonBitmap(pokemon,back)
    pkmn.x=-pkmn.bitmap.width/2
    pkmn.y=adjustBattleSpriteY(pkmn,pokemon.species,attacker.index)
    if @battle.doublebattle
      case attacker.index
      when 0
        pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLERD1_X
        pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLERD1_Y
      when 1
        pkmn.x+=PokeBattle_SceneConstants::FOEBATTLERD1_X
        pkmn.y+=PokeBattle_SceneConstants::FOEBATTLERD1_Y
      when 2
        pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLERD2_X
        pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLERD2_Y
      when 3
        pkmn.x+=PokeBattle_SceneConstants::FOEBATTLERD2_X
        pkmn.y+=PokeBattle_SceneConstants::FOEBATTLERD2_Y
      end
    else
      pkmn.x+=PokeBattle_SceneConstants::PLAYERBATTLER_X if attacker.index==0
      pkmn.y+=PokeBattle_SceneConstants::PLAYERBATTLER_Y if attacker.index==0
      pkmn.x+=PokeBattle_SceneConstants::FOEBATTLER_X if attacker.index==1
      pkmn.y+=PokeBattle_SceneConstants::FOEBATTLER_Y if attacker.index==1
    end
    if shadow && !back
      shadow.visible=showShadow?(pokemon.species)
    end
  end

  def pbSaveShadows
    shadows=[]
    for i in 0...4
      s=@sprites["shadow#{i}"]
      shadows[i]=s ? s.visible : false
      s.visible=false if s
    end
    yield
    for i in 0...4
      s=@sprites["shadow#{i}"]
      s.visible=shadows[i] if s
    end
  end

  def pbFindAnimation(moveid,userIndex,hitnum)
    begin
      move2anim=load_data("Data/move2anim.dat")
      noflip=false
      if (userIndex&1)==0   # On player's side
        anim=move2anim[0][moveid]
      else                  # On opposing side
        anim=move2anim[1][moveid]
        noflip=true if anim
        anim=move2anim[0][moveid] if !anim
      end
      return [anim+hitnum,noflip] if anim
      # Actual animation not found, get the default animation for the move's type
      move=PBMoveData.new(moveid)
      type=move.type
      typedefaultanim=[[:NORMAL,:TACKLE],
                       [:FIGHTING,:COMETPUNCH],
                       [:FLYING,:GUST],
                       [:POISON,:SLUDGE],
                       [:GROUND,:SANDATTACK], # Initially as Mud-Slap
                       [:ROCK,:ROCKTHROW],
                       [:BUG,:TWINEEDLE],
                       [:GHOST,:NIGHTSHADE],
                       [:STEEL,:GYROBALL],
                       [:FIRE,:EMBER],
                       [:WATER,:WATERGUN],
                       [:GRASS,:RAZORLEAF],
                       [:ELECTRIC,:THUNDERSHOCK],
                       [:PSYCHIC,:CONFUSION],
                       [:ICE,:ICEBALL],
                       [:DRAGON,:DRAGONRAGE],
                       [:DARK,:PURSUIT],
                       [:FAIRY,:FAIRYWIND],
                       [:MAGIC,:MAGICHAND],
                       [:DOOM,:DOOMTACKLE],
                       [:JELLY,:JELLYKICK],
                       [:SHARPENER,:SHARPTACKLE], # Intiailly as Wrapped Tackle
                       [:LAVA,:LAVACORN],
                       [:WIND,:WINDATTACK],
                       [:LICK,:LICK],
                       [:BOLT,:WINDBOLT],
                       [:HERB,:HERBSLAM], # Initially as Herbal Punch
                       [:CHLOROPHYLL,:CHLOROPHYLL],
                       [:GUST,:GUSTATTACK],
                       [:SUN,:SUNNYTACKLE],  # Initially as Fire Punch, then Sunny Punch
                       [:MOON,:MOONCROCKET],  # Initially as Moonlight
                       [:MIND,:MINDBLOW],
                       [:HEART,:HEARTGLOW], # Initially as Charm,then Heart Stamp
                       [:BLIZZARD,:ICEPUNCH],
                       [:GAS,:ACID],
                       [:GLIMSE,:GLIMSEATTACK]]  # Initially as Nightmare
      for i in typedefaultanim
        if isConst?(type,PBTypes,i[0]) && hasConst?(PBMoves,i[1])
          noflip=false
          if (userIndex&1)==0   # On player's side
            anim=move2anim[0][getConst(PBMoves,i[1])]
          else                  # On opposing side
            anim=move2anim[1][getConst(PBMoves,i[1])]
            noflip=true if anim
            anim=move2anim[0][getConst(PBMoves,i[1])] if !anim
          end
          return [anim,noflip] if anim
          break
        end
      end
      # Default animation for the move's type not found, use Tackle's animation
      if hasConst?(PBMoves,:TACKLE)
        anim=move2anim[0][getConst(PBMoves,:TACKLE)]
        return [anim,false] if anim
      end
    rescue
      return nil
    end
    return nil
  end

  def pbCommonAnimation(animname,user,target,hitnum=0)
    animations=load_data("Data/PkmnAnimations.rxdata")
    for i in 0...animations.length
      if animations[i] && animations[i].name=="Common:"+animname
        pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
        return
      end
    end
  end

  def pbAnimation(moveid,user,target,hitnum=0)
    animid=pbFindAnimation(moveid,user.index,hitnum)
    return if !animid
    anim=animid[0]
    animations=load_data("Data/PkmnAnimations.rxdata")
    pbSaveShadows {
       if animid[1] # On opposing side and using OppMove animation
         pbAnimationCore(animations[anim],target,user,true)
       else         # On player's side, and/or using Move animation
         pbAnimationCore(animations[anim],user,target)
       end
    }
    if PBMoveData.new(moveid).function==0x69 && user && target # Transform
      # Change form to transformed version
      pbChangePokemon(user,target.pokemon)
    end
  end

  def pbAnimationCore(animation,user,target,oppmove=false)
    return if !animation
    @briefmessage=false
    usersprite=(user) ? @sprites["pokemon#{user.index}"] : nil
    targetsprite=(target) ? @sprites["pokemon#{target.index}"] : nil
    olduserx=usersprite ? usersprite.x : 0
    oldusery=usersprite ? usersprite.y : 0
    oldtargetx=targetsprite ? targetsprite.x : 0
    oldtargety=targetsprite ? targetsprite.y : 0
    if !targetsprite
      target=user if !target
      animplayer=PBAnimationPlayerX.new(animation,user,target,self,oppmove)
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery+(userheight/2),
         olduserx+(userwidth/2),oldusery+(userheight/2))
    else
      animplayer=PBAnimationPlayerX.new(animation,user,target,self,oppmove)
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      targetwidth=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.width
      targetheight=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery+(userheight/2),
         oldtargetx+(targetwidth/2),oldtargety+(targetheight/2))
    end
    animplayer.start
    while animplayer.playing?
      animplayer.update
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
    end
    usersprite.ox=0 if usersprite
    usersprite.oy=0 if usersprite
    usersprite.x=olduserx if usersprite
    usersprite.y=oldusery if usersprite
    targetsprite.ox=0 if targetsprite
    targetsprite.oy=0 if targetsprite
    targetsprite.x=oldtargetx if targetsprite
    targetsprite.y=oldtargety if targetsprite
    animplayer.dispose
  end

  def pbLevelUp(pokemon,battler,oldtotalhp,oldattack,olddefense,oldspeed,
                oldspatk,oldspdef)
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       pokemon.totalhp-oldtotalhp,
       pokemon.attack-oldattack,
       pokemon.defense-olddefense,
       pokemon.spatk-oldspatk,
       pokemon.spdef-oldspdef,
       pokemon.speed-oldspeed))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  end

  def pbThrowAndDeflect(ball,targetBattler)
    @briefmessage=false
    balltype=pbGetBallType(ball)
    ball=sprintf("Graphics/Battle animations/ball_%02d",balltype)
    # sprite
    spriteBall=IconSprite.new(0,0,@viewport)
    spriteBall.visible=false
    # picture
    pictureBall=PictureEx.new(@sprites["pokemon#{targetBattler}"].z+1)
    center=getSpriteCenter(@sprites["pokemon#{targetBattler}"])
    # starting positions
    pictureBall.moveVisible(1,true)
    pictureBall.moveName(1,ball)
    pictureBall.moveOrigin(1,PictureOrigin::Center)
    pictureBall.moveXY(0,1,10,180)
    # directives
    pictureBall.moveSE(1,"Audio/SE/throw")
    pictureBall.moveCurve(30,1,150,70,30+Graphics.width/2,10,center[0],center[1])
    pictureBall.moveAngle(30,1,-1080)
    pictureBall.moveAngle(0,pictureBall.totalDuration,0)
    delay=pictureBall.totalDuration
    pictureBall.moveSE(delay,"Audio/SE/balldrop")
    pictureBall.moveXY(20,delay,0,Graphics.height)
    loop do
      pictureBall.update
      setPictureIconSprite(spriteBall,pictureBall)
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if !pictureBall.running?
    end
    spriteBall.dispose
  end

  def pbThrow(ball,shakes,critical,targetBattler,showplayer=false)
    @briefmessage=false
    burst=-1
    animations=load_data("Data/PkmnAnimations.rxdata")
    for i in 0...2
      t=(i==0) ? ball : 0
      for j in 0...animations.length
        if animations[j]
          if animations[j].name=="Common:BallBurst#{t}"
            burst=t if burst<0
            break
          end
        end
      end
      break if burst>=0
    end
    pokeballThrow(ball,shakes,critical,targetBattler,self,@battle.battlers[targetBattler],burst,showplayer)
  end

  def pbThrowSuccess
    if !@battle.opponent
      @briefmessage=false
      pbBGSStop()
      pbMEPlay("CaptureSuccess")
      pbBGMPlay("CaptureSuccess2")
      frames=(3.5*Graphics.frame_rate).to_i
      frames.times do
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
      end
    end
  end

  def pbHideCaptureBall
    if @sprites["capture"]
      loop do
        break if @sprites["capture"].opacity<=0
        @sprites["capture"].opacity-=12
        pbGraphicsUpdate
        pbInputUpdate
        pbFrameUpdate
      end
    end
  end

  def pbThrowBait
    @briefmessage=false
    ball=sprintf("Graphics/Battle animations/safari_bait")
    armanim=false
    if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
      armanim=true
    end
    # sprites
    spritePoke=@sprites["pokemon1"]
    spritePlayer=@sprites["player"]
    spriteBall=IconSprite.new(0,0,@viewport)
    spriteBall.visible=false
    # pictures
    pictureBall=PictureEx.new(spritePoke.z+1)
    picturePoke=PictureEx.new(spritePoke.z)
    picturePlayer=PictureEx.new(spritePoke.z+2)
    dims=[spritePoke.x,spritePoke.y]
    pokecenter=getSpriteCenter(@sprites["pokemon1"])
    playerpos=[@sprites["player"].x,@sprites["player"].y]
    ballendy=PokeBattle_SceneConstants::FOEBATTLER_Y-4
    # starting positions
    pictureBall.moveVisible(1,true)
    pictureBall.moveName(1,ball)
    pictureBall.moveOrigin(1,PictureOrigin::Center)
    pictureBall.moveXY(0,1,64,256)
    picturePoke.moveVisible(1,true)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    picturePoke.moveXY(0,1,pokecenter[0],pokecenter[1])
    picturePlayer.moveVisible(1,true)
    picturePlayer.moveName(1,@sprites["player"].name)
    picturePlayer.moveOrigin(1,PictureOrigin::TopLeft)
    picturePlayer.moveXY(0,1,playerpos[0],playerpos[1])
    # directives
    picturePoke.moveSE(1,"Audio/SE/throw")
    pictureBall.moveCurve(30,1,64,256,Graphics.width/2,48,
                          PokeBattle_SceneConstants::FOEBATTLER_X-48,
                          PokeBattle_SceneConstants::FOEBATTLER_Y)
    pictureBall.moveAngle(30,1,-720)
    pictureBall.moveAngle(0,pictureBall.totalDuration,0)
    if armanim
      picturePlayer.moveSrc(1,@sprites["player"].bitmap.height,0)
      picturePlayer.moveXY(0,1,playerpos[0]-14,playerpos[1])
      picturePlayer.moveSrc(4,@sprites["player"].bitmap.height*2,0)
      picturePlayer.moveXY(0,4,playerpos[0]-12,playerpos[1])
      picturePlayer.moveSrc(8,@sprites["player"].bitmap.height*3,0)
      picturePlayer.moveXY(0,8,playerpos[0]+20,playerpos[1])
      picturePlayer.moveSrc(16,@sprites["player"].bitmap.height*4,0)
      picturePlayer.moveXY(0,16,playerpos[0]+16,playerpos[1])
      picturePlayer.moveSrc(40,0,0)
      picturePlayer.moveXY(0,40,playerpos[0],playerpos[1])
    end
    # Show Pokémon jumping before eating the bait
    picturePoke.moveSE(50,"Audio/SE/jump")
    picturePoke.moveXY(8,50,pokecenter[0],pokecenter[1]-8)
    picturePoke.moveXY(8,58,pokecenter[0],pokecenter[1])
    pictureBall.moveVisible(66,false)
    picturePoke.moveSE(66,"Audio/SE/jump")
    picturePoke.moveXY(8,66,pokecenter[0],pokecenter[1]-8)
    picturePoke.moveXY(8,74,pokecenter[0],pokecenter[1])
    # TODO: Show Pokémon eating the bait (pivots at the bottom right corner)
    picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
    picturePoke.moveXY(0,picturePoke.totalDuration,dims[0],dims[1])
    loop do
      pictureBall.update
      picturePoke.update
      picturePlayer.update
      setPictureIconSprite(spriteBall,pictureBall)
      setPictureSprite(spritePoke,picturePoke)
      setPictureIconSprite(spritePlayer,picturePlayer)
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if !pictureBall.running? && !picturePoke.running? && !picturePlayer.running?
    end
    spriteBall.dispose
  end

  def pbThrowRock
    @briefmessage=false
    ball=sprintf("Graphics/Battle animations/safari_rock")
    anger=sprintf("Graphics/Battle animations/safari_anger")
    armanim=false
    if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
      armanim=true
    end
    # sprites
    spritePoke=@sprites["pokemon1"]
    spritePlayer=@sprites["player"]
    spriteBall=IconSprite.new(0,0,@viewport)
    spriteBall.visible=false
    spriteAnger=IconSprite.new(0,0,@viewport)
    spriteAnger.visible=false
    # pictures
    pictureBall=PictureEx.new(spritePoke.z+1)
    picturePoke=PictureEx.new(spritePoke.z)
    picturePlayer=PictureEx.new(spritePoke.z+2)
    pictureAnger=PictureEx.new(spritePoke.z+1)
    dims=[spritePoke.x,spritePoke.y]
    pokecenter=getSpriteCenter(@sprites["pokemon1"])
    playerpos=[@sprites["player"].x,@sprites["player"].y]
    ballendy=PokeBattle_SceneConstants::FOEBATTLER_Y-4
    # starting positions
    pictureBall.moveVisible(1,true)
    pictureBall.moveName(1,ball)
    pictureBall.moveOrigin(1,PictureOrigin::Center)
    pictureBall.moveXY(0,1,64,256)
    picturePoke.moveVisible(1,true)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    picturePoke.moveXY(0,1,pokecenter[0],pokecenter[1])
    picturePlayer.moveVisible(1,true)
    picturePlayer.moveName(1,@sprites["player"].name)
    picturePlayer.moveOrigin(1,PictureOrigin::TopLeft)
    picturePlayer.moveXY(0,1,playerpos[0],playerpos[1])
    pictureAnger.moveVisible(1,false)
    pictureAnger.moveName(1,anger)
    pictureAnger.moveXY(0,1,pokecenter[0]-56,pokecenter[1]-48)
    pictureAnger.moveOrigin(1,PictureOrigin::Center)
    pictureAnger.moveZoom(0,1,100)
    # directives
    picturePoke.moveSE(1,"Audio/SE/throw")
    pictureBall.moveCurve(30,1,64,256,Graphics.width/2,48,pokecenter[0],pokecenter[1])
    pictureBall.moveAngle(30,1,-720)
    pictureBall.moveAngle(0,pictureBall.totalDuration,0)
    pictureBall.moveSE(30,"Audio/SE/notverydamage")
    if armanim
      picturePlayer.moveSrc(1,@sprites["player"].bitmap.height,0)
      picturePlayer.moveXY(0,1,playerpos[0]-14,playerpos[1])
      picturePlayer.moveSrc(4,@sprites["player"].bitmap.height*2,0)
      picturePlayer.moveXY(0,4,playerpos[0]-12,playerpos[1])
      picturePlayer.moveSrc(8,@sprites["player"].bitmap.height*3,0)
      picturePlayer.moveXY(0,8,playerpos[0]+20,playerpos[1])
      picturePlayer.moveSrc(16,@sprites["player"].bitmap.height*4,0)
      picturePlayer.moveXY(0,16,playerpos[0]+16,playerpos[1])
      picturePlayer.moveSrc(40,0,0)
      picturePlayer.moveXY(0,40,playerpos[0],playerpos[1])
    end
    pictureBall.moveVisible(40,false)
    # Show Pokémon being angry
    pictureAnger.moveSE(48,"Audio/SE/jump")
    pictureAnger.moveVisible(48,true)
    pictureAnger.moveZoom(8,48,130)
    pictureAnger.moveZoom(8,56,100)
    pictureAnger.moveXY(0,64,pokecenter[0]+56,pokecenter[1]-64)
    pictureAnger.moveSE(64,"Audio/SE/jump")
    pictureAnger.moveZoom(8,64,130)
    pictureAnger.moveZoom(8,72,100)
    pictureAnger.moveVisible(80,false)
    picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
    picturePoke.moveXY(0,picturePoke.totalDuration,dims[0],dims[1])
    loop do
      pictureBall.update
      picturePoke.update
      picturePlayer.update
      pictureAnger.update
      setPictureIconSprite(spriteBall,pictureBall)
      setPictureSprite(spritePoke,picturePoke)
      setPictureIconSprite(spritePlayer,picturePlayer)
      setPictureIconSprite(spriteAnger,pictureAnger)
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate
      break if !pictureBall.running? && !picturePoke.running? &&
               !picturePlayer.running? && !pictureAnger.running?
    end
    spriteBall.dispose
  end
end