class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options,x,y,width,height)
    @options=options
    @nameBaseColor=Color.new(24*8,15*8,0)
    @nameShadowColor=Color.new(31*8,22*8,10*8)
    @selBaseColor=Color.new(31*8,6*8,3*8)
    @selShadowColor=Color.new(31*8,17*8,16*8)
    @optvalues=[]
    @mustUpdateOptions=false
    for i in 0...@options.length
      @optvalues[i]=0
    end
    super(x,y,width,height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i,value)
    @optvalues[i]=value
    refresh
  end

  def itemCount
    return @options.length+1
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    optionname=(index==@options.length) ? _INTL("Cancel") : @options[index].name
    optionwidth=(rect.width*9/20)
    pbDrawShadowText(self.contents,rect.x,rect.y,optionwidth,rect.height,optionname,
       @nameBaseColor,@nameShadowColor)
#    self.contents.draw_text(rect.x,rect.y,optionwidth,rect.height,optionname)
    return if index==@options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length>1
        totalwidth=0
        for value in @options[index].values
          totalwidth+=self.contents.text_size(value).width
        end
        spacing=(optionwidth-totalwidth)/(@options[index].values.length-1)
        spacing=0 if spacing<0
        xpos=optionwidth+rect.x
        ivalue=0
        for value in @options[index].values
          pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
             (ivalue==self[index]) ? @selBaseColor : self.baseColor,
             (ivalue==self[index]) ? @selShadowColor : self.shadowColor
          )
#          self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
          xpos+=self.contents.text_size(value).width
          xpos+=spacing
          ivalue+=1
        end
      else
        pbDrawShadowText(self.contents,rect.x+optionwidth,rect.y,optionwidth,rect.height,
           optionname,self.baseColor,self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value=sprintf("Type %d/%d",@options[index].optstart+self[index],
         @options[index].optend-@options[index].optstart+1)
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    elsif @options[index].is_a?(SliderOption)
      value=sprintf(" %d",@options[index].optend)
      sliderlength=optionwidth-self.contents.text_size(value).width
      xpos=optionwidth+rect.x
      self.contents.fill_rect(xpos,rect.y-2+rect.height/2,
         optionwidth-self.contents.text_size(value).width,4,self.baseColor)
      self.contents.fill_rect(
         xpos+(sliderlength-8)*(@options[index].optstart+self[index])/@options[index].optend,
         rect.y-8+rect.height/2,
         8,16,@selBaseColor)
      
      value=sprintf("%d",@options[index].optstart+self[index])
      xpos+=optionwidth-self.contents.text_size(value).width
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    else
      value=@options[index].values[self[index]]
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
#      self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
    end
  end

  def update
    dorefresh=false
    oldindex=self.index
    @mustUpdateOptions=false
    super
    dorefresh=self.index!=oldindex
    if self.active && self.index<@options.length
      if Input.repeat?(Input::LEFT)
        pbPlayDecisionSE()
        self[self.index]=@options[self.index].prev(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
      elsif Input.repeat?(Input::RIGHT)
        pbPlayDecisionSE()
        self[self.index]=@options[self.index].next(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
      end
    end
    refresh if dorefresh
  end
end



module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end



class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)            
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)             
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name,optstart,optend,getProc,setProc)
    @name=name
    @optstart=optstart
    @optend=optend
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+@optstart
    index+=1
    if index>@optend
      index=@optstart
    end
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=1
    if index<@optstart
      index=@optend
    end
    return index-@optstart
  end
end



class SliderOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name,optstart,optend,optinterval,getProc,setProc)
    @name=name
    @optstart=optstart
    @optend=optend
    @optinterval=optinterval
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+@optstart
    index+=@optinterval
    if index>@optend
      index=@optend
    end
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=@optinterval
    if index<@optstart
      index=@optstart
    end
    return index-@optstart
  end
end

#####################
#
# Stores game options
# Default options are at the top of script section SpriteWindow.

  $SpeechFrames=[
  # Q.Qore
  MessageConfig::TextSkinName, # Default: speech hgss 1
  "QChoice2",
  "QChoice3",
  "QChoice4",
  "QChoice5",
  "QChoice6",
  "QChoice7",
  "QChoice8",
  "speech ug 4",
  # Blandy Blush Sada
  "speech web",
  # GSC Style
  "speech pl 18",
  "speech pl 18_dark",
  # HGSS Style
  "speech hgss 1",
  "speech hgss 2",
  "speech hgss 3",
  "speech hgss 4",
  "speech hgss 5",
  "speech hgss 6",
  "speech hgss 7",
  "speech hgss 13",
  "speech hgss 17",
  # DP Style
  "speech dp 3",
  "speech dp 18",
  # Other
  "001-Blue01",
  "Window"
]
# 2 more colors
=begin
  "color25",
  "color26"
=end

# Old Skin Frames
=begin
  "Graphics/Windowskins/choice 2",
  "Graphics/Windowskins/choice 3",
  "Graphics/Windowskins/choice 4",
  "Graphics/Windowskins/choice 5",
  "Graphics/Windowskins/choice 6",
  "Graphics/Windowskins/choice 7",
  "Graphics/Windowskins/choice 8",
  "Graphics/Windowskins/choice 9",
  "Graphics/Windowskins/choice 10",
  "Graphics/Windowskins/choice 11",
  "Graphics/Windowskins/choice 12",
  "Graphics/Windowskins/choice 13",
  "Graphics/Windowskins/choice 14",
  "Graphics/Windowskins/choice 15",
  "Graphics/Windowskins/choice 16",
  "Graphics/Windowskins/choice 17",
  "Graphics/Windowskins/choice 18",
  "Graphics/Windowskins/choice 19",
  "Graphics/Windowskins/choice 20",
  "Graphics/Windowskins/choice 21",
  "Graphics/Windowskins/choice 22",
  "Graphics/Windowskins/choice 23",
  "Graphics/Windowskins/choice 24",
  "Graphics/Windowskins/choice 25",
  "Graphics/Windowskins/choice 26",
  "Graphics/Windowskins/choice 27",
  "Graphics/Windowskins/choice 28"

  
  "Graphics/Windowskins/"+MessageConfig::ChoiceSkinName, # Default: choice 1
  "Graphics/Windowskins/chat2",
  "Graphics/Windowskins/chat3",
  "Graphics/Windowskins/chat4",
  "Graphics/Windowskins/chat5",
  "Graphics/Windowskins/chat6",
  "Graphics/Windowskins/chat7",
  "Graphics/Windowskins/chat8",
  "Graphics/Windowskins/chat9",
  "Graphics/Windowskins/chat10",
  "Graphics/Windowskins/chat11",
  "Graphics/Windowskins/chat12",
  "Graphics/Windowskins/chat13"  
  "color2",
  "color3",
  "color4",
  "color5",
  "color6",
  "color7",
  "color8",
  "color9",
  "color10",
  "color11",
  "color12",
  "color13",
  "color14",
  "color15",
  "color16",
  "color17",
  "color18",
  "color19",
  "color20",
  "color21",
  "color22",
  "color23",
  "color24"

=end

$TextFrames=[
  # Q.Qore
  "Graphics/Windowskins/"+MessageConfig::ChoiceSkinName, # Default: choice 1
  "Graphics/Windowskins/QChoice2c",
  "Graphics/Windowskins/QChoice3c",
  "Graphics/Windowskins/QChoice4c",
  "Graphics/Windowskins/QChoice5c",
  "Graphics/Windowskins/QChoice6c",
  "Graphics/Windowskins/QChoice7c",
  "Graphics/Windowskins/QChoice8c",
  "Graphics/Windowskins/choice ug 3",
  # Blandy Blush Sada
  "Graphics/Windowskins/choice web",
  # GSC Style
  "Graphics/Windowskins/choice 2",
  "Graphics/Windowskins/choice 2_dark",
  # HGSS Style
  "Graphics/Windowskins/choice hgss 1",
  "Graphics/Windowskins/choice hgss 2",
  "Graphics/Windowskins/choice hgss 3",
  "Graphics/Windowskins/choice hgss 4",
  "Graphics/Windowskins/choice hgss 5",
  "Graphics/Windowskins/choice hgss 6",
  "Graphics/Windowskins/choice hgss 7",
  "Graphics/Windowskins/choice hgss 13",
  "Graphics/Windowskins/choice 23",
  # DP Style
  "Graphics/Windowskins/choice dp 3",
  "Graphics/Windowskins/choice dp 18",
  # Others
  "Graphics/Windowskins/001-Blue01",
  "Graphics/Windowskins/Window"
]

=begin
$VersionStyles=[
  [MessageConfig::FontName], # Default font style - Power Green/"Pokemon Emerald"
   ["Karla"],
   ["Consolas"], # As Courier Prime in Corendo
   ["Walt Disney Script"],
   ["American Typewriter"], # As Tinos/Liberation Serif in Corendo
   ["Bubble Witch Saga"],
   ["Power Green"],
   ["Power Red and Blue"],
   ["Power Red and Green"],
   ["Power Clear"],
   ["Arial Narrow"], # As Roboto in Corendo
   ["Liberation Sans Narrow"]
]
=end

$VersionStyles=[
  [MessageConfig::FontName], # Default font style - Power Green/"Pokemon Emerald"
  [MessageConfig::FontName]
]

#$BORDERS=[
#      "border",
#      "border_1"
#]

def pbSettingToTextSpeed(speed)
  return 1 if speed==0
  return 1 if speed==1
  return 1 if speed==2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed
  return ((Graphics.frame_rate>40) ? -2 : 1)
end



module MessageConfig
  def self.pbDefaultSystemFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::ChoiceSkinName)||""
    else
      return pbResolveBitmap($TextFrames[$PokemonSystem.textskin])||""
    end
  end

  def self.pbDefaultSpeechFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::TextSkinName)||""
    else
      return pbResolveBitmap("Graphics/Windowskins/"+$SpeechFrames[$PokemonSystem.textskin])||""
    end
  end

  def self.pbDefaultSystemFontName
    if !$PokemonSystem
      return MessageConfig.pbTryFonts(MessageConfig::FontName,"Arial Narrow","Arial")
    else
      return MessageConfig.pbTryFonts($VersionStyles[$PokemonSystem.font][0],"Arial Narrow","Arial")
    end
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed($PokemonSystem ? $PokemonSystem.textspeed : nil)
  end

  def pbGetSystemTextSpeed
    return $PokemonSystem ? $PokemonSystem.textspeed : ((Graphics.frame_rate>40) ? 2 :  3)
  end
end



class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :debugmode
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :battlemode
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :border
  attr_accessor :runstyle
  attr_accessor :bgmvolume
  attr_accessor :sevolume
  attr_accessor :textinput
  attr_accessor :night
  attr_accessor :colortige
  attr_accessor :jbvol
  attr_accessor :jbtempo
  attr_accessor :outfit
  attr_accessor :doublebattles
  attr_accessor :mgraphic
  attr_accessor :bordercrop
  attr_accessor :bordergraphic
  attr_accessor :charset2
  attr_accessor :dsampling
  attr_accessor :cryclassic
  attr_accessor :newsix
  attr_accessor :vrtrophynotif
  attr_accessor :temps
  attr_accessor :mechanics
  
  def initialize
    @textspeed        = 2   # Frames Per Second (0=24, 1=30, 2=40, 3=50)
    @debugmode        = 0   # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene      = 0   # Battle effects (animations) (0=on, 1=off)
    @battlestyle      = 0   # Battle style (0=switch, 1=set)
    @battlemode       = 1   # Battle style (0=switch, 1=set)
    @frame            = 0   # Default window frame (see also $TextFrames)
    @textskin         = 0   # Speech frame
    @font             = 0   # Font (see also $VersionStyles)
    @screensize       = 0   # 0=half size, 1=full size, 2=double size and was ((DEFAULTSCREENZOOM.floor).to_i)
    @border           = 0   # Screen border (0=off, 1=on)
    @language         = 0   # Language (see also LANGUAGES in script PokemonSystem)
    @runstyle         = 0   # Run key functionality (0=hold to run, 1=toggle auto-run)
    @jbvol            = 100 # Volume of background music and ME
    @jbtempo          = 100 # Volume of sound effects
    @bgmvolume        = 100 # Volume of background music and ME
    @sevolume         = 100 # Volume of sound effects
    @textinput        = 0   # Text input mode (0=cursor, 1=keyboard)
    @night            = 2   # Night Style (0=Vanilla, 1=Cool, 2=Warm, 3=Crossover)
    @colortige        = 1   # Cartidge Style (0=GenIV with Color text, 1=GenIV unmodded, 2=GenIV with Dark Text, 3=Creamy white with light colored text/based on GenIV style)
    @outfit           = 0   # Player's Appearance
    @doublebattles    = 0   # Battle Mode (0=Single Wild Battles, 1=Double Wild Battles) - Ignored while you're with someone
    @mgraphic         = 0   # Mirrored Graphics in some places
    @bordercrop       = 1   # Border Cropping in Full Screen Mode
    @bordergraphic    = 2   # Screen Border Graphic
    @charset2         = 0   # Charset (0 = Latin, 1 = Greek, 2 = Cyrrilic (Not added yet))
    @dsampling        = 0   # Charset (0 = Latin, 1 = Greek, 2 = Cyrrilic (Not added yet))
    @cryclassic       = 1   # Cry Style (0 = Classic, 1 = Modern)
    @newsix           = 1   # Cry Style (0 = Classic, 1 = Modern)
    @vrtrophynotif    = 0   # Notifications for collected trophy (0 = On, 1 = Off)
    @temps            = 0   # Temperature Display (0 = Celsius, 1 = Fahrenheit)
    @mechanics        = 1   # Battle Mechanics
end
  
  def language
    return (!@language) ? 0 : @language
  end

  def battlemode
    return (!@battlemode) ? 0 : @battlemode
  end
  
  def debugmode
    return (!@debugmode) ? 0 : @debugmode
  end
  
  def textskin
    return (!@textskin) ? 0 : @textskin
  end

  def border
    return (!@border) ? 0 : @border
  end

  def runstyle
    return (!@runstyle) ? 0 : @runstyle
  end

  def bgmvolume
    return (!@bgmvolume) ? 100 : @bgmvolume
  end

  def jbvol # Unused
    return (!@jbvol) ? 100 : @jbvol
  end
  
  def jbtempo
    return (!@jbtempo) ? 100 : @jbtempo
  end
  
  def sevolume
    return (!@sevolume) ? 100 : @sevolume
  end

  def textinput
    return (!@textinput) ? 0 : @textinput
  end

  def doublebattles
    return (!@doublebattles) ? 0 : @doublebattles
  end

  
  def mgraphic # Unused
    return (!@mgraphic) ? 0 : @mgraphic
  end
  
  def night
    return (!@night) ? 2 : @night
  end

  def colortige
    return (!@colortige) ? 0 : @colortige
  end

  def outfit
    return (!@outfit) ? 0 : @outfit
  end

  def bordergraphic
    return (!@bordergraphic) ? 0 : @bordergraphic
  end

  def charset2
    return (!@charset2) ? 0 : @charset2
  end

  def dsampling # Unused
    return (!@dsampling) ? 0 : @dsampling
  end

  def cryclassic
    return (!@cryclassic) ? 1 : @cryclassic
  end    

  def newsix
    return (!@newsix) ? 1 : @newsix
  end  

  def vrtrophynotif
    return (!@vrtrophynotif) ? 0 : @vrtrophynotif
  end    

  def temps
    return (!@temps) ? 0 : @temps
  end    

  def mechanics
    return (!@mechanics) ? 1 : @mechanics
  end    

  
  def tilemap; return MAPVIEWMODE; end

end



class PokemonOptionScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

=begin
There are different modes:
0 - General Settings
1 - Sound Settings
2 - Battle Settings
3 - Display Settings
=end

=begin
# Old Settings
       SliderOption.new(_INTL("Jukebox BGM Volume"),0,100,5,
          proc { $PokemonSystem.jbvol },
          proc {|value|
               $PokemonSystem.jbvol=value
          }
       ),
       EnumOption.new(_INTL("Frames Per Second"),[_INTL("24"),_INTL("30"),_INTL("40"),_INTL("50")],
          proc { $PokemonSystem.textspeed },
          proc {|value|
             $PokemonSystem.textspeed=value 
             if value==3 
                 Graphics.frame_rate=50
             elsif value==2
                Graphics.frame_rate=40
              elsif value==1
                Graphics.frame_rate=30
              else
                Graphics.frame_rate=24
              end
              #MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value)) 
          }
       ),
       NumberOption.new(_INTL("Selects Color"),1,$TextFrames.length,
          proc { $PokemonSystem.frame },
          proc {|value|
             $PokemonSystem.frame=value
             MessageConfig.pbSetSystemFrame($TextFrames[value]) 
          }
       ),
       NumberOption.new(_INTL("Font Style"),1,$VersionStyles.length,
          proc { $PokemonSystem.font },
          proc {|value|
             $PokemonSystem.font=value
             MessageConfig.pbSetSystemFontName($VersionStyles[value])
          }
       ),
       EnumOption.new(_INTL("Generation VIII Icons"),[_INTL("Original"),_INTL("Downsampled")],
          proc { $PokemonSystem.dsampling },
          proc {|value| $PokemonSystem.dsampling=value }
       ),
       EnumOption.new(_INTL("Mirrored Graphics"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.mgraphic },
         proc {|value| $PokemonSystem.mgraphic = value }
       ),
    if $Trainer && false
      @PokemonOptions+=[ # Outfit style (Only when not in title screen)
        NumberOption.new(_INTL("Outfit Style"),1,4,
          proc { $PokemonSystem.outfit },
          proc {|value| 
             $PokemonSystem.outfit=value
             $Trainer.outfit=$PokemonSystem.outfit
          }
        )
      ]
    end
=end

 def pbStartScene(inloadscreen=false,mode=0)
    @sprites={}
    title=["General Settings", "Sound Settings", "Battle Settings", "Display Settings"]
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       title[mode],0,0,Graphics.width,64,@viewport)
  #  @sprites["title"].setSkin("Graphics/Windowskins/goldskin")
#    @sprites["title"].baseColor=Color.new(88,88,80)
#    @sprites["title"].shadowColor=Color.new(168,184,184)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    @sprites["textbox"].text=_INTL("Text Skin {1}.",1+$PokemonSystem.textskin)
    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
# ------------------------------------------------------------------------------
# Options
# ------------------------------------------------------------------------------
    @PokemonOptions=[]
    if mode==0
      @PokemonOptions+=[
        NumberOption.new(_INTL("Night Style"),1,4,
          proc { $PokemonSystem.night },
          proc {|value| $PokemonSystem.night = value }
        ),
        EnumOption.new(_INTL("Debugger (Requires Restart)"),[_INTL("Off"),_INTL("On")],
           proc { $PokemonSystem.debugmode },
           proc {|value|
             $PokemonSystem.debugmode=value
           }
        ),
        EnumOption.new(_INTL("Running Key"),[_INTL("Hold"),_INTL("Toggle")],
           proc { $PokemonSystem.runstyle },
           proc {|value|
              if $PokemonSystem.runstyle!=value
                $PokemonSystem.runstyle=value
                $PokemonGlobal.runtoggle=false if $PokemonGlobal
              end
           }
        ),
        EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
          proc { $PokemonSystem.textinput },
          proc {|value| $PokemonSystem.textinput = value }
        ),
        EnumOption.new(_INTL("Input Language"),[_INTL("Latin"),_INTL("Greek"),_INTL("Cyrillic")],
          proc { $PokemonSystem.charset2 },
          proc {|value| $PokemonSystem.charset2 = value }
        ),
        EnumOption.new(_INTL("Temperature Display"),[_INTL("Celsius"),_INTL("Fahrenheit")],
          proc { $PokemonSystem.temps },
          proc {|value| $PokemonSystem.temps = value }
        ),
        EnumOption.new(_INTL("Trophy Notifications"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.vrtrophynotif },
           proc {|value| $PokemonSystem.vrtrophynotif=value }
        )
      ]
    end
    if mode==1
      @PokemonOptions+=[
       SliderOption.new(_INTL("BGM Volume"),0,100,5,
          proc { $PokemonSystem.bgmvolume },
          proc {|value|
             if $PokemonSystem.bgmvolume!=value
               $PokemonSystem.bgmvolume=value
               if $game_system.playing_bgm != nil && !inloadscreen
                 $game_system.playing_bgm.volume=value
                 playingBGM=$game_system.getPlayingBGM
                 $game_system.bgm_pause
                 $game_system.bgm_resume(playingBGM)
               end
             end
          }
       ),
       SliderOption.new(_INTL("SE Volume"),0,100,5,
          proc { $PokemonSystem.sevolume },
          proc {|value|
             if $PokemonSystem.sevolume!=value
               $PokemonSystem.sevolume=value
               if $game_system.playing_bgs != nil
                 $game_system.playing_bgs.volume=value
                 playingBGS=$game_system.getPlayingBGS
                 $game_system.bgs_pause
                 $game_system.bgs_resume(playingBGS)
               end
               pbPlayCursorSE()
             end
          }
       ),
       SliderOption.new(_INTL("Jukebox BGM Rate"),0,200,5,
          proc { $PokemonSystem.jbtempo },
          proc {|value|
               $PokemonSystem.jbtempo=value
               if value<5
                 $PokemonSystem.jbtempo=5
              end
          }
       ),
        EnumOption.new(_INTL("Cry Style"),[_INTL("Classic"),_INTL("Modern")],
          proc { $PokemonSystem.cryclassic },
          proc {|value| $PokemonSystem.cryclassic = value }
        )
      ]
    end
    if mode==2
      @PokemonOptions+=[
        EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.battlescene },
           proc {|value| $PokemonSystem.battlescene=value }
        ),
        EnumOption.new(_INTL("Wild Battle Mode"),[_INTL("Single"),_INTL("Double")],
        # During join with stat trainers, all wild battles are in double battle regardless of this setting
        # If the user has only one Pokemon, all wild battles are in single battle regardless of this setting
           proc { $PokemonSystem.doublebattles },
           proc {|value| $PokemonSystem.doublebattles=value }
        ),
        EnumOption.new(_INTL("Battle Style"),[_INTL("Switch"),_INTL("Set")],
           proc { $PokemonSystem.battlestyle },
           proc {|value| $PokemonSystem.battlestyle=value }
        ),
        EnumOption.new(_INTL("Battle Mechanics (Requires Restart)"),[_INTL("Generation V"),_INTL("NextGen")],
           proc { $PokemonSystem.mechanics },
           proc {|value|
             $PokemonSystem.mechanics=value
           }
        ),
        EnumOption.new(_INTL("New Generation 6 Pokemon Style"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.newsix },
          proc {|value| $PokemonSystem.newsix = value }
        )
      ]
    end
    if mode==3
      @PokemonOptions+=[
         NumberOption.new(_INTL("Text Skin"),1,$SpeechFrames.length,
           proc { $PokemonSystem.textskin },
           proc {|value| 
              $PokemonSystem.textskin=value
              MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+$SpeechFrames[value])
              MessageConfig.pbSetSystemFrame($TextFrames[value])
           }
         ),
         NumberOption.new(_INTL("Cartridge Style"),1,5,
           proc { $PokemonSystem.colortige },
           proc {|value| $PokemonSystem.colortige = value }
         ),
         EnumOption.new(_INTL("Screen Border"),[_INTL("Off"),_INTL("On")],
            proc { $PokemonSystem.border },
            proc {|value|
                oldvalue=$PokemonSystem.border
                $PokemonSystem.border=value
                if value!=oldvalue
                  pbSetResizeFactor($PokemonSystem.screensize)
                  ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
                end
            }
          ),
         NumberOption.new(_INTL("Screen Size"),1,5,
            proc { $PokemonSystem.screensize },
            proc {|value|
               oldvalue=$PokemonSystem.screensize
               $PokemonSystem.screensize=value
               if value!=oldvalue
                 pbSetResizeFactor($PokemonSystem.screensize)
                 ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
               end
            }
         ),
         EnumOption.new(_INTL("Full Screen Border Crop"),[_INTL("Off"),_INTL("On")],
            proc { $PokemonSystem.bordercrop },
            proc {|value|
              oldvalue=$PokemonSystem.bordercrop
              $PokemonSystem.bordercrop=value
              if value!=oldvalue
                pbSetResizeFactor($PokemonSystem.screensize)
                ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
              end
           }
         ),
         NumberOption.new(_INTL("Screen Border Graphic"),1,$BORDERS.length,
            proc { $PokemonSystem.bordergraphic },
            proc {|value|
               $PokemonSystem.bordergraphic=value
               setScreenBorderName($BORDERS[value]) # Sets image file for the border
            }
         )
      ]
    end
    @PokemonOptions=pbAddOnOptions(@PokemonOptions)
    @sprites["option"]=Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
=begin
    @sprites["option"].setSkin("Graphics/Windowskins/choice dp")
    @sprites["option"].baseColor=Color.new(88,88,80)
    @sprites["option"].shadowColor=Color.new(168,184,184)
=end
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"][i]=(@PokemonOptions[i].get || 0)
    end
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbAddOnOptions(options)
    return options
  end

  def pbOptions
    oldSystemSkin = $PokemonSystem.frame      # Menu
    oldTextSkin   = $PokemonSystem.textskin   # Speech
#    oldFont       = $PokemonSystem.font
    pbActivateWindow(@sprites,"option"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["option"].mustUpdateOptions
           # Set the values of each option
           for i in 0...@PokemonOptions.length
             @PokemonOptions[i].set(@sprites["option"][i])
           end
=begin
           @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
           @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
           @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
           @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
           pbSetSystemFont(@sprites["textbox"].contents)
           @sprites["textbox"].text = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
=end
           if $PokemonSystem.textskin!=oldTextSkin
             @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
             @sprites["textbox"].width = @sprites["textbox"].width  # Necessary evil
             @sprites["textbox"].text  = _INTL("Text Skin {1}.",1+$PokemonSystem.textskin)
             oldTextSkin = $PokemonSystem.textskin
           end
           if $PokemonSystem.frame!=oldSystemSkin
             @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
             @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
             oldSystemSkin = $PokemonSystem.frame
           end
=begin
           if $PokemonSystem.font!=oldFont
             pbSetSystemFont(@sprites["textbox"].contents)
             @sprites["textbox"].text=_INTL("Text Skin {1}.",1+$PokemonSystem.textskin)
             oldFont = $PokemonSystem.font
           end
=end
         end
         if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
           break
         elsif (Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)) && 
           @sprites["option"].index==@PokemonOptions.length
           break
         end
       end
    }
  end

  def pbEndScene
    pbPlayCancelSE()
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@PokemonOptions.length
      @PokemonOptions[i].set(@sprites["option"][i])
    end
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end



class PokemonOption
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(inloadscreen=false,mode=0)
    @scene.pbStartScene(inloadscreen,mode)
    @scene.pbOptions
    @scene.pbEndScene
  end
end
