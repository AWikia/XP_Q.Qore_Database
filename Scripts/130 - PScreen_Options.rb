class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options,x,y,width,height)
    @options=options
    if (!isDarkMode?)  # Light Mode
      @nameBaseColor=Color.new(24*8,15*8,0)
      @nameShadowColor=Color.new(31*8,22*8,10*8)
      @selBaseColor=Color.new(31*8,6*8,3*8)
      @selShadowColor=Color.new(31*8,17*8,16*8)
    else                                          # Dark mode
      @nameBaseColor=Color.new(29*8,22*8,9*8)
      @nameShadowColor=Color.new(15*8,9*8,0)
      @selBaseColor=Color.new(31*8,18*8,17*8)
      @selShadowColor=Color.new(24*8,3*8,1*8)
    end
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
  "Skin1",
  "Skin2",
  "Skin3",
  "Skin4",
  "Skin5",
  "Skin6",
  "Skin7",
  # Blandy Blush Sada
  "Skin8",
  # GSC Style
  "Skin9",
  # HGSS Style
  "Skin10",
  "Skin11",
  "Skin12",
  "Skin13",
  "Skin14",
  "Skin15",
  "Skin16",
  "Skin17",
  "Skin18",
  # DP Style
  "Skin19",
  "Skin20",
  # Other
  "Skin21",
  "Skin22"
]
# 2 more colors
=begin
  "color25",
  "color26"
=end

# Old Skin Frames
=begin
  "choice 2",
  "choice 3",
  "choice 4",
  "choice 5",
  "choice 6",
  "choice 7",
  "choice 8",
  "choice 9",
  "choice 10",
  "choice 11",
  "choice 12",
  "choice 13",
  "choice 14",
  "choice 15",
  "choice 16",
  "choice 17",
  "choice 18",
  "choice 19",
  "/choice 20",
  "choice 21",
  "choice 22",
  "choice 23",
  "choice 24",
  "choice 25",
  "choice 26",
  "choice 27",
  "choice 28"

  
  MessageConfig::ChoiceSkinName, # Default: choice 1
  "chat2",
  "chat3",
  "chat4",
  "chat5",
  "chat6",
  "chat7",
  "chat8",
  "chat9",
  "chat10",
  "chat11",
  "chat12",
  "chat13"  
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
  MessageConfig::ChoiceSkinName, # Default: choice 1
  "Choice1",
  "Choice2",
  "Choice3",
  "Choice4",
  "Choice5",
  "Choice6",
  "Choice7",
  # Blandy Blush Sada
  "Choice8",
  # GSC Style
  "Choice9",
  # HGSS Style
  "Choice10",
  "Choice11",
  "Choice12",
  "Choice13",
  "Choice14",
  "Choice15",
  "Choice16",
  "Choice17",
  "Choice18",
  # DP Style
  "Choice19",
  "Choice20",
  # Other
  "Skin21",
  "Skin22"
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
      return pbResolveBitmap("Graphics/Windowskins/"+getDarkModeFolder+"/"+MessageConfig::ChoiceSkinName)||""
    else
      return pbResolveBitmap("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.textskin])||""
    end
  end

  def self.pbDefaultSpeechFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+getDarkModeFolder+"/"+MessageConfig::TextSkinName)||""
    else
      return pbResolveBitmap("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.textskin])||""
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
  attr_accessor :accentcolor
  attr_accessor :darkmode
  attr_accessor :threecolorbar
  
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
    @colortige        = 1   # Cartidge Style (0=GenIV with Color text, 1=GenIV with Light Text, 2=GenIV with Dark Text, 3=Creamy white with light colored text/based on GenIV style, 4=FRLG Style)
    @outfit           = 0   # Player's Appearance
    @doublebattles    = 0   # Battle Mode (0=Single Wild Battles, 1=Double Wild Battles) - Ignored while you're with someone
    @mgraphic         = 0   # Mirrored Graphics in some places
    @bordercrop       = 1   # Border Cropping in Full Screen Mode
    @bordergraphic    = 4   # Screen Border Graphic (0=Qora Qore, 1=Pokemon Yellow, 2=Qora Qore V2, 3=Qora Qore V3 Channel-Aware, 4=Qora Qore V3 Accent-Aware)
    @charset2         = 0   # Charset (0 = Latin, 1 = Greek, 2 = Cyrrilic (Not added yet))
    @dsampling        = 0   # Charset (0 = Latin, 1 = Greek, 2 = Cyrrilic (Not added yet))
    @cryclassic       = 1   # Cry Style (0 = Classic, 1 = Modern)
    @newsix           = 1   # Cry Style (0 = Classic, 1 = Modern)
    @vrtrophynotif    = 0   # Notifications for collected trophy (0 = On, 1 = Off)
    @temps            = 0   # Temperature Display (0 = Celsius, 1 = Fahrenheit)
    @mechanics        = 1   # Battle Mechanics
    @accentcolor      = 0   # Accent Color
    @darkmode         = 0   # Theme Mode (0 = Light, 1 = Dark)
    @threecolorbar    = 0   # Three Color Progress Bar
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
    return (!@bordergraphic) ? 4 : @bordergraphic
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

  def accentcolor
    return (!@accentcolor) ? 0 : @accentcolor
  end    

  def darkmode
    return (!@darkmode) ? 0 : @darkmode
  end    

  def threecolorbar
    return (!@threecolorbar) ? 0 : @threecolorbar
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
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    @sprites["textbox"].text=_INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
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
        EnumOption.new(_INTL("Debug Mode (Requires Restart)"),[_INTL("Off"),_INTL("On")],
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
        EnumOption.new(_INTL("Progress Bar Display"),[_INTL("2-colored"),_INTL("3-colored")],
          proc { $PokemonSystem.threecolorbar },
          proc {|value| $PokemonSystem.threecolorbar = value }
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
       SliderOption.new(_INTL("Jukebox BGM Speed"),0,200,5,
          proc { $PokemonSystem.jbtempo },
          proc {|value|
               $PokemonSystem.jbtempo=value
               if value<5
                 $PokemonSystem.jbtempo=5
              end
          }
       ),
        EnumOption.new(_INTL("Pokémon Cry Style"),[_INTL("Classic"),_INTL("Modern")],
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
        EnumOption.new(_INTL("Wild Pokémon Battle Style"),[_INTL("Single"),_INTL("Double")],
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
        EnumOption.new(_INTL("Generation VI Pokémon Graphic Style"),[_INTL("Classic"),_INTL("Modern")],
          proc { $PokemonSystem.newsix },
          proc {|value| $PokemonSystem.newsix = value }
        )
      ]
    end
    if mode==3
      @PokemonOptions+=[
        EnumOption.new(_INTL("System Theme"),[_INTL("Light"),_INTL("Dark"),_INTL("Automatic")],
           proc { $PokemonSystem.darkmode },
           proc {|value|
             $PokemonSystem.darkmode=value
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           }
        ),
         NumberOption.new(_INTL("Text Skin"),1,$SpeechFrames.length,
           proc { $PokemonSystem.textskin },
           proc {|value| 
              $PokemonSystem.textskin=value
              MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[value])
              MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[value])
           }
         ),
         NumberOption.new(_INTL("Accent Color"),1,9,
           proc { $PokemonSystem.accentcolor },
           proc {|value| 
             $PokemonSystem.accentcolor = value 
             $BORDERS=getBorders
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           }
         ),
         NumberOption.new(_INTL("Pokémon Type Icon Style"),1,5,
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
               $BORDERS=getBorders
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
    oldAccent   = $PokemonSystem.accentcolor   # Speech
    oldmode = $PokemonSystem.darkmode
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
             @sprites["textbox"].text  = _INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
             oldTextSkin = $PokemonSystem.textskin
           end
           if $PokemonSystem.frame!=oldSystemSkin
             @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
             @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
             oldSystemSkin = $PokemonSystem.frame
           end
           if $PokemonSystem.accentcolor!=oldAccent
             @sprites["textbox"].width = @sprites["textbox"].width  # Necessary evil
             @sprites["textbox"].text  = _INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
            oldAccent   = $PokemonSystem.accentcolor   # Speech
          end
          if $PokemonSystem.darkmode != oldmode
              MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.textskin])
              MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.textskin])
             @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
             @sprites["textbox"].width = @sprites["textbox"].width  # Necessary evil
             @sprites["textbox"].text  = _INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
              oldmode = $PokemonSystem.darkmode
          end
=begin
           if $PokemonSystem.font!=oldFont
             pbSetSystemFont(@sprites["textbox"].contents)
             @sprites["textbox"].text=_INTL("Text Skin {1}.\n{2} Accent Color.",1+$PokemonSystem.textskin,getAccentName)
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
