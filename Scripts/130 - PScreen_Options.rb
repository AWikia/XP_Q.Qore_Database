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
      if @options[index].listdisplay.is_a?(Array)
        value=sprintf("%s",@options[index].listdisplay[self[index]])
      else
        value=sprintf("Option %d/%d",@options[index].optstart+self[index],
           @options[index].optend-@options[index].optstart+1)
      end
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
  
  def help
    return @help
  end
end



class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc,help="No Description")            
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
    @help=help
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

  def initialize(name,options,getProc,setProc,help="No Description")             
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
    @help=help
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
  attr_reader :listdisplay # Optional. If it is an array, it will replace the Type X/X with the X item from the given array

  def initialize(name,optstart,optend,getProc,setProc,listdisplay=nil,help="No Description")
    @name=name
    @optstart=optstart
    @optend=optend
    @getProc=getProc
    @setProc=setProc
    @listdisplay=listdisplay
    @help=help
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

  def initialize(name,optstart,optend,optinterval,getProc,setProc,help="No Description")
    @name=name
    @optstart=optstart
    @optend=optend
    @optinterval=optinterval
    @getProc=getProc
    @setProc=setProc
    @help=help
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
  "Skin22",
  "Skin23",
  "Skin24",
  "Skin25",
  ['Skin26','Skin26_1','Skin26_2','Skin26_3','Skin26_4','Skin26_5'][QQORECHANNEL],
  "Skin27",
  "Skin28",
  "Skin29",
  ['Skin30','Skin30_1','Skin30_2','Skin30_3'][pbGetSeason]

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
  "Skin22",
  "Skin23",
  "Skin24",
  "Skin25",
  ['Choice26','Choice26_1','Choice26_2','Choice26_3','Choice26_4','Choice26_5'][QQORECHANNEL],
  "Choice27",
  "Choice28",
  "Choice29",
  ['Choice30','Choice30_1','Choice30_2','Choice30_3'][pbGetSeason]
]

  $SpeechFramesNames=[
  # Q.Qore
  "Purple", # Default: speech hgss 1
  "Red",
  "Blue",
  "Orange",
  "Green",
  "Gray",
  "Blue-Gray",
  "Underground",
  # Blandy Blush Sada
  "Candy",
  # GSC Style
  "Retro",
  # HGSS Style
  "HeartGold",
  "SoulSilver",
  "Light Red",
  "Light Blue",
  "Light Green",
  "Light Orange",
  "Light Purple",
  "Dark Forest",
  "Air Mail",
  # DP Style
  "Dark Blue",
  "Poké Ball",
  # Other
  "RPG Maker XP",
  "RPG Maker VX",
  "RPG Maker VX Ace",
  "RPG Maker MV",
  "RPG Maker MZ",
  "Channel-Aware",
  "Green-Gray",
  "Pink",
  "Turquoise",
  "Season-Aware"
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
  attr_accessor :darkmodestart
  attr_accessor :darkmodeend
  attr_accessor :threecolorbar
  attr_accessor :enableshading
  attr_accessor :textskincolors
  
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
    @accentcolor      = 16  # Accent Color
    @darkmode         = 0   # Theme Mode (0 = Light, 1 = Dark)
    @darkmodestart    = 19  # Scheduled Dark Mode Start
    @darkmodeend      = 7   # Scheduled Dark Mode End
    @threecolorbar    = 0   # Three Color Progress Bar
    @enableshading    = 1   # Outdoor Map Shading
    @textskincolors   = 0   # Text Skin Color Scheme (0=Standard, 1=Colors, 2=CMYK, 3=Vintage)
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
    return (!@accentcolor) ? 16 : @accentcolor
  end    

  def darkmode
    return (!@darkmode) ? 0 : @darkmode
  end    

  def darkmodestart
    return (!@darkmodestart) ? 19 : @darkmodestart
  end    

  def darkmodeend
    return (!@darkmodeend) ? 7 : @darkmodeend
  end    

  
  def threecolorbar
    return (!@threecolorbar) ? 0 : @threecolorbar
  end    

  def enableshading
    return (!@enableshading) ? 1 : @enableshading
  end    

  
  def textskincolors
    return (!@textskincolors) ? 0 : @textskincolors
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
        EnumOption.new(_INTL("Input Language"),[_INTL("Latin"),_INTL("Greek"),_INTL("Cyrillic")],
          proc { $PokemonSystem.charset2 },
          proc {|value| $PokemonSystem.charset2 = value },
          "Sets the charset in the naming dialog (Cursor Mode). Choice between Latin, Greek and Cyrillic."
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
    title=["General Settings", "Sound Settings", "Battle Settings", "Display Settings","Personalization Settings"]
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
      addBackgroundOrColoredPlane(@sprites,"title",getDarkModeFolder+"/settingsbg_1",
         Color.new(0,0,0),@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title[mode]),
       2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
# ------------------------------------------------------------------------------
# Options
# ------------------------------------------------------------------------------
    @PokemonOptions=[]
    if mode==0
      @PokemonOptions+=[
        EnumOption.new(_INTL("Debug Mode (Requires Restart)"),[_INTL("Off"),_INTL("On")],
           proc { $PokemonSystem.debugmode },
           proc {|value|
             $PokemonSystem.debugmode=value
           },
           "Enables or Disables Debugging features. Requires restart for this to apply."
        ),
        EnumOption.new(_INTL("Running Key"),[_INTL("Hold"),_INTL("Toggle")],
           proc { $PokemonSystem.runstyle },
           proc {|value|
              if $PokemonSystem.runstyle!=value
                $PokemonSystem.runstyle=value
                $PokemonGlobal.runtoggle=false if $PokemonGlobal
              end
           },
           "Sets the way running is activated (Hold requires the Z button to be held in order to run)."
        ),
        EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
          proc { $PokemonSystem.textinput },
          proc {|value| $PokemonSystem.textinput = value },
          "Sets the way you type text. Choice between Cursor as in the official games or Keyboard."
        ),
        EnumOption.new(_INTL("Temperature Display"),[_INTL("Celsius"),_INTL("Fahrenheit")],
          proc { $PokemonSystem.temps },
          proc {|value| $PokemonSystem.temps = value },
          "Sets the way Temperature is shown on the Advanced Information section of the Summary Screen. Choice between Celsius and Fahrenheit."
        ),
        EnumOption.new(_INTL("Progress Bar Display"),[_INTL("2-colored"),_INTL("3-colored")],
          proc { $PokemonSystem.threecolorbar },
          proc {|value| $PokemonSystem.threecolorbar = value },
          "Sets the amount of colors to be shown in Progress bars found in Summary Screens. Choice between 2 and 3 -colored"
        ),
        EnumOption.new(_INTL("Trophy Notifications"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.vrtrophynotif },
           proc {|value| $PokemonSystem.vrtrophynotif=value },
          "When set to off, no notifications about an awarded trophy will appear."
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
          },
          "Controls BGM playback volume."
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
          },
          "Controls SFX playback volume."
       ),
       SliderOption.new(_INTL("Jukebox BGM Speed"),0,200,5,
          proc { $PokemonSystem.jbtempo },
          proc {|value|
               $PokemonSystem.jbtempo=value
               if value<5
                 $PokemonSystem.jbtempo=5
              end
          },
          "Controls pitch on playback casted by the Jukebox Pokégear feature."
       ),
        EnumOption.new(_INTL("Pokémon Cry Sounds"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.cryclassic },
          proc {|value| $PokemonSystem.cryclassic = value },
          "When set to off, no sound is heard from Pokémon. When set to Prograda, its Pokémon name will be heard."
        )
      ]
    end
    if mode==2
      @PokemonOptions+=[
        EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.battlescene },
           proc {|value| $PokemonSystem.battlescene=value },
           "When set to Off, no battle animations will be shown"
        ),
        EnumOption.new(_INTL("Wild Pokémon Battle Style"),[_INTL("Single"),_INTL("Double")],
        # During join with stat trainers, all wild battles are in double battle regardless of this setting
        # If the user has only one Pokemon, all wild battles are in single battle regardless of this setting
           proc { $PokemonSystem.doublebattles },
           proc {|value| $PokemonSystem.doublebattles=value },
          "When set to double, all wild battles will be forced to double when you're not with someone."
        ),
        EnumOption.new(_INTL("Battle Style"),[_INTL("Switch"),_INTL("Set")],
           proc { $PokemonSystem.battlestyle },
           proc {|value| $PokemonSystem.battlestyle=value },
           "When set to Switch, it allows you to switch to another Pokémon on trainer battles when defating a Pokémon. When set to Set, it won’t prompt you to switch to another Pokémon."
        ),
        EnumOption.new(_INTL("Battle Mechanics (Requires Restart)"),[_INTL("Generation V"),_INTL("NextGen")],
           proc { $PokemonSystem.mechanics },
           proc {|value|
             $PokemonSystem.mechanics=value
           },
           "When set to Generation V, it uses mechanics found in Generation V games. When set to NextGen, it uses mechanics found in the latest Pokémon Games."
        ),
        EnumOption.new(_INTL("Generation VI Pokémon Graphic Style"),[_INTL("Classic"),_INTL("Modern")],
          proc { $PokemonSystem.newsix },
          proc {|value| $PokemonSystem.newsix = value },
        "This is inteded as a transition point between the Original Gen6 and the revamped Gen6 sprites. Set this to off to disable them."
        ),
      ]
    end
    if mode==3
      @PokemonOptions+=[
        NumberOption.new(_INTL("Night Style"),1,4,
          proc { $PokemonSystem.night },
          proc {|value| $PokemonSystem.night = value },
          ["Classic Tint", "Linear Tint", "Lunar Tint", "Cubic Tint"],
           "Sets the styling of Day/Night tinting. 0 is Classic, 1 is Linear, 2 is Lunar (Default) and 3 is Cubic. Tintings come from Essentials 17."
          ),
         EnumOption.new(_INTL("Outdoor Map Shading"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.enableshading },
          proc {|value| $PokemonSystem.enableshading = value },
          "When set to on, all outdoor maps will be tinted according to the time of day. Disabling this will neither affect the darkening on pseudo-dark maps nor the Auto Dark Mode."
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
            },
           "When set to on, it shows a decorative border"
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
            },
            ["Normal", "Large", "Xtra Large", "Xtra² Large", "Full-Screen"],
            "Sets screen size. Choice between 4 sizes and Full Screen (The fifth size)"
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
           },
          "When set to on, border will be cropped, enabling larger graphics on Full Screen mode with screen border enabled"
         )
      ]
    end
    if mode==4
      @PokemonOptions+=[
        EnumOption.new(_INTL("System Theme"),[_INTL("Light"),_INTL("Dark"),_INTL("Auto"),_INTL("Custom")],
           proc { $PokemonSystem.darkmode },
           proc {|value|
             $PokemonSystem.darkmode=value
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           },
           "Sets the theme of Windowskins, the UI and other elements in the game. By default, it is set to Light but can be set to Dark to make those Dark or to either Auto or Custom."
        ),
       SliderOption.new(_INTL("Scheduled Dark Mode Start"),0,23,1,
          proc { $PokemonSystem.darkmodestart },
          proc {|value|
             if $PokemonSystem.darkmodestart!=value
               $PokemonSystem.darkmodestart=value
               setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
             end
          },
          "Sets the hour that will enable the Dark Mode when System Theme is set to Custom."
       ),
       SliderOption.new(_INTL("Scheduled Dark Mode End"),0,23,1,
          proc { $PokemonSystem.darkmodeend },
          proc {|value|
             if $PokemonSystem.darkmodeend!=value
               $PokemonSystem.darkmodeend=value
               setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
             end
          },
          "Sets the hour that will disable the Dark Mode when System Theme is set to Custom."
       ),
         NumberOption.new(_INTL("Text Skin"),1,$SpeechFrames.length,
           proc { $PokemonSystem.textskin },
           proc {|value| 
              $PokemonSystem.textskin=value
              MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[value])
              MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[value])
              @sprites["header"].windowskin=nil
           },
           $SpeechFramesNames,
          "Sets the windowskin graphics to be used in the game."
         ),
         NumberOption.new(_INTL("Text Skin Color Scheme"),0,3,
           proc { $PokemonSystem.textskincolors },
           proc {|value| 
              $PokemonSystem.textskincolors=value
           },
           ["Standard", "Colors", "CMYK", "Vintage"],
          "Sets the colors to be used in Windowskins."
         ),

         NumberOption.new(_INTL("Accent Color"),1,getAccentNames.length,
           proc { $PokemonSystem.accentcolor },
           proc {|value| 
             $PokemonSystem.accentcolor = value 
             $BORDERS=getBorders
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           },
           getAccentNames,
          "Sets the color of all accent-aware elements. Forty-Eight options exist. More than one color may be used to constuct an accent color. Blue is the default color."
         ),
         NumberOption.new(_INTL("Pokémon Type Icon Style"),1,5,
           proc { $PokemonSystem.colortige },
           proc {|value| $PokemonSystem.colortige = value },
           ["Colored Text", "Light Text", "Dark Text", "Minimal", "Retro"],
           "Sets style of All Icon graphics"
         ),
         NumberOption.new(_INTL("Screen Border Graphic"),1,$BORDERS.length,
            proc { $PokemonSystem.bordergraphic },
            proc {|value|
               $PokemonSystem.bordergraphic=value
               $BORDERS=getBorders
               setScreenBorderName($BORDERS[value]) # Sets image file for the border
            },
            getBorderNames,
           "On RGSS XP, it sets the decorative border graphic. On VR Corendo, it sets the pillarboxed area graphic."
         )
      ]
    end
    @PokemonOptions=pbAddOnOptions(@PokemonOptions)
    @sprites["option"]=Window_PokemonOption.new(@PokemonOptions,0,
       32,Graphics.width,
       Graphics.height-32-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"][i]=(@PokemonOptions[i].get || 0)
    end
    @sprites["textbox"].text=_INTL("Use the arrow keys to navigate to the menu. Press Shift or Z to show help on the selected option ")
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
    oldmode = isDarkMode?
    #    oldFont       = $PokemonSystem.font
    pbActivateWindow(@sprites,"option"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if (Input.trigger?(Input::A) ) && @sprites["option"].index != @PokemonOptions.length
            Kernel.pbMessage(_INTL("\\l[3]{1}",@PokemonOptions[@sprites["option"].index].help))
         end
         if @sprites["option"].mustUpdateOptions
           # Set the values of each option
           for i in 0...@PokemonOptions.length
             @PokemonOptions[i].set(@sprites["option"][i])
           end
           if $PokemonSystem.textskin!=oldTextSkin
             @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
             @sprites["textbox"].width = @sprites["textbox"].width  # Necessary evil
             oldTextSkin = $PokemonSystem.textskin
           end
           if $PokemonSystem.frame!=oldSystemSkin
             @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
             oldSystemSkin = $PokemonSystem.frame
           end
           if $PokemonSystem.accentcolor!=oldAccent
            oldAccent   = $PokemonSystem.accentcolor   # Speech
          end
          if isDarkMode? != oldmode
              MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.textskin])
              MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.textskin])
             @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
             @sprites["textbox"].width = @sprites["textbox"].width  # Necessary evil
             oldmode = isDarkMode?
          end
=begin
           if $PokemonSystem.font!=oldFont
             pbSetSystemFont(@sprites["textbox"].contents)
             oldFont = $PokemonSystem.font
           end
=end
         end
        @sprites["header"].windowskin=nil if @sprites["header"].windowskin!=nil
         if Input.trigger?(Input::B)
           break
         elsif (Input.trigger?(Input::C)) && 
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