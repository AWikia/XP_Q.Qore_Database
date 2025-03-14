class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options,x,y,width,height)
    @options=options
    if (!isDarkMode?)  # Light Mode
      @nameBaseColor=Color.new(176,104,0)
      @nameShadowColor=Color.new(240,168,72)
      @selBaseColor=Color.new(232,32,8)
      @selShadowColor=Color.new(240,128,140)
    else                                          # Dark mode
      @nameBaseColor=Color.new(248,192,88)
      @nameShadowColor=Color.new(128,80,8)
      @selBaseColor=Color.new(255,160,152)
      @selShadowColor=Color.new(200,32,16)
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
       (index == self.index) ? @nameBaseColor : self.baseColor,(index == self.index) ? @nameShadowColor : self.shadowColor)
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


####################
#
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
  ['Skin26','Skin26_1','Skin26_2','Skin26_3','Skin26_4','!Skin26_5'][QQORECHANNEL],
  "Skin27",
  "Skin28",
  "Skin29",
  ['Skin30','Skin30_1','Skin30_2','Skin30_3'][pbGetSeason],
  "!Skin31",
  "!Skin32",
  (pbGetCountry() == 0x7A rescue nil) ? "!Skin33" : "!Skin33_1",
  "!Skin34",
  "!Skin35",
  ['Skin36','Skin36_1','Skin36_2','Skin36_3','Skin36_4','!Skin36_5'][QQORECHANNEL],
  ['Skin37','Skin37_1','Skin37_2','Skin37_3','Skin37_4','!Skin37_5'][QQORECHANNEL],

]

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
  ['Choice26','Choice26_1','Choice26_2','Choice26_3','Choice26_4','!Choice26_5'][QQORECHANNEL],
  "Choice27",
  "Choice28",
  "Choice29",
  ['Choice30','Choice30_1','Choice30_2','Choice30_3'][pbGetSeason],
  "!Choice31",
  "!Choice32",
  (pbGetCountry() == 0x7A rescue nil) ? "!Choice33" : "!Choice33_1",
  "!Choice34",
  "!Choice35",
  ['Choice36','Choice36_1','Choice36_2','Choice36_3','Choice36_4','!Choice36_5'][QQORECHANNEL],
  ['Choice37','Choice37_1','Choice37_2','Choice37_3','Choice37_4','!Choice37_5'][QQORECHANNEL],
]

  $SpeechFramesNames=[
  # Q.Qore
  MessageConfig::TextSkinDisplayName, # Default: speech hgss 1
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
  "Season-Aware",
  "Pikachu and Eevee",
  "Blue-mix",
  (pbGetCountry() == 0x7A rescue nil) ? "Light Red and Green" : "Light Red and Blue",
  "Four Seasons",
  "Pokémon Quadruplet",
  "Retro Channel-Aware",
  "Light Channel-Aware",
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
  [MessageConfig::FontNameBold]
]

$VersionStylesNames=[
  "Standard",
  "Bold"
]


def pbSettingToTextSpeed(speed)
  return 2 if speed==0
  return 1 if speed==1
  return -2 if speed==2
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
    return pbSettingToTextSpeed($PokemonSystem ? $PokemonSystem.textspeed2 : nil)
  end

  def pbGetSystemTextSpeed
    return $PokemonSystem ? $PokemonSystem.textspeed2 : ((Graphics.frame_rate>40) ? 2 :  3)
  end
end



class PokemonSystem
  attr_accessor :textspeed2 #  FIXME: Rename me back to textspeed once Qortex Essentials Ennea gets replaced
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
  attr_accessor :jbtempo
  attr_accessor :doublebattles
  attr_accessor :bordercrop
  attr_accessor :bordergraphic
  attr_accessor :cryclassic
  attr_accessor :newsix
  attr_accessor :vrtrophynotif
  attr_accessor :temps
  attr_accessor :accentcolor
  attr_accessor :darkmode
  attr_accessor :darkmodestart
  attr_accessor :darkmodeend
  attr_accessor :threecolorbar
  attr_accessor :enableshading
  attr_accessor :textskincolors
  attr_accessor :battledif
  attr_accessor :customshiny
  attr_accessor :battlecolor
  attr_accessor :autosave
  
  def initialize
    @textspeed2       = 1   # Text speed (0=slow, 1=normal, 2=fast)
    @debugmode        = 0   # Debug Mode
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
    @jbtempo          = 100 # Volume of sound effects
    @bgmvolume        = 100 # Volume of background music and ME
    @sevolume         = 100 # Volume of sound effects
    @textinput        = 0   # Text input mode (0=cursor, 1=keyboard)
    @night            = 2   # Night Style (0=Vanilla, 1=Cool, 2=Warm, 3=Crossover)
    @doublebattles    = 0   # Battle Mode (0=Single Wild Battles, 1=Double Wild Battles) - Ignored while you're with someone
    @bordercrop       = 1   # Border Cropping in Full Screen Mode
    @bordergraphic    = 4   # Screen Border Graphic (0=Qora Qore, 1=Pokemon Yellow, 2=Qora Qore V2, 3=Qora Qore V3 Channel-Aware, 4=Qora Qore V3 Accent-Aware)
    @cryclassic       = 1   # Cry Style (0 = Classic, 1 = Modern)
    @newsix           = 1   # Cry Style (0 = Classic, 1 = Modern)
    @vrtrophynotif    = 0   # Notifications for collected trophy (0 = On, 1 = Off)
    @temps            = 0   # Temperature Display (0 = Celsius, 1 = Fahrenheit)
    @accentcolor      = 16  # Accent Color
    @darkmode         = 0   # Theme Mode (0 = Light, 1 = Dark)
    @darkmodestart    = 19  # Scheduled Dark Mode Start
    @darkmodeend      = 7   # Scheduled Dark Mode End
    @threecolorbar    = 0   # Three Color Progress Bar
    @enableshading    = 1   # Outdoor Map Shading
    @textskincolors   = 0   # Text Skin Color Scheme (0=Standard, 1=Colors, 2=CMYK, 3=Vintage)
    @battledif        = 0   # Battle Difficulty
    @customshiny      = 0   # Customized Shinies
    @battlecolor      = 0   # Battle Message Box Color (0-4  = Color 1-5)
    @autosave         = 0   # Autosave (0 = Off, 1 = On)
end

  def textspeed2 # FIXME: Rename me back to textspeed once Qortex Essentials Ennea gets replaced
    return (!@textspeed2) ? 1 : @textspeed2
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

  def night
    return (!@night) ? 2 : @night
  end

  def bordergraphic
    return (!@bordergraphic) ? 4 : @bordergraphic
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

  def battledif
    return (!@battledif) ? 0 : @battledif
  end    

  def customshiny
    return (!@customshiny) ? 0 : @customshiny
  end    

  def battlecolor
    return (!@battlecolor) ? 0 : @battlecolor
  end    

  def autosave
    return (!@autosave) ? 0 : @autosave
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
       NumberOption.new(_INTL("Selects Color"),1,$TextFrames.length,
          proc { $PokemonSystem.frame },
          proc {|value|
             $PokemonSystem.frame=value
             MessageConfig.pbSetSystemFrame($TextFrames[value]) 
          }
       ),
=end

 def pbStartScene(inloadscreen=false,mode=0)
    @sprites={}
    title=["General Settings", "Sound Settings", "Battle Settings", "Display Settings","Personalization Settings"]
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
      addBackgroundOrColoredPlane(@sprites,"title",getDarkModeFolder+"/Settings/bg_1",
         Color.new(12,12,12),@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title[mode]),
       2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
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
        EnumOption.new(_INTL("Debug Mode (Requires Restart)"),[_INTL("Automatic"),_INTL("On")],
           proc { $PokemonSystem.debugmode },
           proc {|value|
             $PokemonSystem.debugmode=value
           },
           _INTL("Enables or Disables Debugging features. Requires restart for this to apply. Has no effect during playtesting.")
        ),
       EnumOption.new(_INTL("Autosave"),[_INTL("Off"),_INTL("On")],
         proc { $PokemonSystem.autosave },
         proc {|value| $PokemonSystem.autosave = value },
        _INTL("Enables or Disables autosaving. If enabled, game will autosave when moving between certain maps.")
       ),
       EnumOption.new(_INTL("Text Speed"),[_INTL("Slow"),_INTL("Normal"),_INTL("Fast")],
          proc { $PokemonSystem.textspeed2 },
          proc {|value|
             $PokemonSystem.textspeed2=value 
              MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value)) 
          },
           _INTL("Sets the speed of text appearing in various messageboxes. Choice between Slow, Normal and Fast")
       ),
        EnumOption.new(_INTL("Running Key"),[_INTL("Hold"),_INTL("Toggle")],
           proc { $PokemonSystem.runstyle },
           proc {|value|
              if $PokemonSystem.runstyle!=value
                $PokemonSystem.runstyle=value
                $PokemonGlobal.runtoggle=false if $PokemonGlobal
              end
           },
           _INTL("Sets the way running is activated (Hold requires the Z button to be held in order to run).")
        ),
        EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
          proc { $PokemonSystem.textinput },
          proc {|value| $PokemonSystem.textinput = value },
          _INTL("Sets the way you type text. Choice between Cursor as in the official games or Keyboard.")
        ),
        EnumOption.new(_INTL("Temperature Display"),[_INTL("Celsius"),_INTL("Fahrenheit")],
          proc { $PokemonSystem.temps },
          proc {|value| $PokemonSystem.temps = value },
          _INTL("Sets the way Temperature is shown on the Advanced Information section of the Summary Screen. Choice between Celsius and Fahrenheit.")
        ),
        EnumOption.new(_INTL("Progress Bar Display"),[_INTL("2-colored"),_INTL("3-colored")],
          proc { $PokemonSystem.threecolorbar },
          proc {|value| $PokemonSystem.threecolorbar = value },
          _INTL("Sets the amount of colors to be shown in Progress bars found in Summary Screens. Choice between 2 and 3 -colored")
        ),
        EnumOption.new(_INTL("Trophy Notifications"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.vrtrophynotif },
           proc {|value| $PokemonSystem.vrtrophynotif=value },
          _INTL("When set to off, no notifications about an awarded trophy will appear.")
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
          _INTL("Controls BGM playback volume.")
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
          _INTL("Controls SFX playback volume.")
       ),
       SliderOption.new(_INTL("Jukebox BGM Speed"),0,200,5,
          proc { $PokemonSystem.jbtempo },
          proc {|value|
               $PokemonSystem.jbtempo=value
               if value<5
                 $PokemonSystem.jbtempo=5
              end
          },
          _INTL("Controls pitch on playback casted by the Jukebox Pokégear feature.")
       ),
        EnumOption.new(_INTL("Pokémon Cry Sounds"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.cryclassic },
          proc {|value| $PokemonSystem.cryclassic = value },
          _INTL("When set to off, no sound is heard from Pokémon. When set to Prograda, its Pokémon name will be heard.")
        )
      ]
    end
    if mode==2
      @PokemonOptions+=[
        EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
           proc { $PokemonSystem.battlescene },
           proc {|value| $PokemonSystem.battlescene=value },
           _INTL("When set to Off, no battle animations will be shown")
        ),
         NumberOption.new(_INTL("Battle Difficulty"),1,4,
         # Intensive can't be chosen from the settings screen and must be enabled
         # from Debug Menu for balancing reasons
           proc { $PokemonSystem.battledif },
           proc {|value| $PokemonSystem.battledif = value },
           [_INTL("Easy"), _INTL("Normal"), _INTL("Hard"), _INTL("Challenging"),_INTL("Intensive")],
           _INTL("Sets battle difficulty. In Easy and Normal difficulties, EXP will not be divided equally between each participant. In Hard and Challenging difficulties, a scaled EXP formula is applied.")
         ),
        EnumOption.new(_INTL("Wild Pokémon Battle Style"),[_INTL("Single"),_INTL("Double")],
        # During join with stat trainers, all wild battles are in double battle regardless of this setting
        # If the user has only one Pokemon, all wild battles are in single battle regardless of this setting
           proc { $PokemonSystem.doublebattles },
           proc {|value| $PokemonSystem.doublebattles=value },
          _INTL("When set to double, all wild battles will be forced to double when you're not with someone.")
        ),
        EnumOption.new(_INTL("Battle Style"),[_INTL("Switch"),_INTL("Set")],
           proc { $PokemonSystem.battlestyle },
           proc {|value| $PokemonSystem.battlestyle=value },
           _INTL("When set to Switch, it allows you to switch to another Pokémon on trainer battles when defating a Pokémon. When set to Set, it won’t prompt you to switch to another Pokémon.")
        ),
         NumberOption.new(_INTL("Battle Messagebox Color"),1,9,
           proc { $PokemonSystem.battlecolor },
           proc {|value| $PokemonSystem.battlecolor = value },
           [_INTL("Color 1 (Center)"), _INTL("Color 2 (Upper Left)"), _INTL("Color 3 (Upper)"), _INTL("Color 4 (Upper Right)"),_INTL("Color 5 (Right)"),_INTL("Color 6 (Bottom Right)"),_INTL("Color 7 (Bottom)"),_INTL("Color 8 (Bottom Left)"),_INTL("Color 9 (Left)")],
           _INTL("Sets the color used in battle messageboxes. Color 1 is the central and default color while the rest pick the central color of one of the four courners.")
         ),
        EnumOption.new(_INTL("Generation VI Pokémon Graphic Style"),[_INTL("Classic"),_INTL("Modern")],
          proc { $PokemonSystem.newsix },
          proc {|value| $PokemonSystem.newsix = value },
        _INTL("This is inteded as a transition point between the Original Gen6 and the revamped Gen6 sprites. Set this to off to disable them.")
        ),
      ]
    end
    if mode==3
      @PokemonOptions+=[
        NumberOption.new(_INTL("Night Style"),1,4,
          proc { $PokemonSystem.night },
          proc {|value| $PokemonSystem.night = value },
          [_INTL("Classic Tint"), _INTL("Linear Tint"), _INTL("Lunar Tint"), _INTL("Cubic Tint")],
           _INTL("Sets the styling of Day/Night tinting. 0 is Classic, 1 is Linear, 2 is Lunar (Default) and 3 is Cubic. Tintings come from Essentials 17.")
          ),
         EnumOption.new(_INTL("Outdoor Map Shading"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.enableshading },
          proc {|value| $PokemonSystem.enableshading = value },
          _INTL("When set to on, all outdoor maps will be tinted according to the time of day. Disabling this will neither affect the darkening on pseudo-dark maps nor the Auto Dark Mode.")
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
           _INTL("When set to on, it shows a decorative border")
          ),
         NumberOption.new(_INTL("Screen Size"),1,6,
            proc { $PokemonSystem.screensize },
            proc {|value|
               oldvalue=$PokemonSystem.screensize
               $PokemonSystem.screensize=value
               if value!=oldvalue
                 pbSetResizeFactor($PokemonSystem.screensize)
                 ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
               end
            },
            [_INTL("Normal"), _INTL("Large"), _INTL("Xtra Large"), _INTL("Xtra² Large"), _INTL("Full-Screen"), _INTL("Full-Screen (Bicubic)")],
            _INTL("Sets screen size. Choice between 4 sizes and Full Screen (The fifth and sixth sizes)")
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
          _INTL("When set to on, border will be cropped, enabling larger graphics on Full Screen mode with screen border enabled")
         )
      ]
    end
    if mode==4
      @PokemonOptions+=[
        NumberOption.new(_INTL("Game Theme"),1,5,
           proc { $PokemonSystem.darkmode },
           proc {|value|
             $PokemonSystem.darkmode=value
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           },
           [_INTL("Light"),_INTL("Dark"),_INTL("Automatic"),_INTL("Custom"),_INTL("From System Theme")],
           _INTL("Sets the theme of Windowskins, the UI and other elements in the game. By default, it is set to Light but can be set to Dark to make those Dark or to either Auto or Custom.")
        ),
       SliderOption.new(_INTL("Scheduled Dark Mode Start"),0,23,1,
          proc { $PokemonSystem.darkmodestart },
          proc {|value|
             if $PokemonSystem.darkmodestart!=value
               $PokemonSystem.darkmodestart=value
               setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
             end
          },
          _INTL("Sets the hour that will enable the Dark Mode when System Theme is set to Custom.")
       ),
       SliderOption.new(_INTL("Scheduled Dark Mode End"),0,23,1,
          proc { $PokemonSystem.darkmodeend },
          proc {|value|
             if $PokemonSystem.darkmodeend!=value
               $PokemonSystem.darkmodeend=value
               setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
             end
          },
          _INTL("Sets the hour that will disable the Dark Mode when System Theme is set to Custom.")
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
          _INTL("Sets the windowskin graphics to be used in the game.")
         ),
         NumberOption.new(_INTL("Text Skin Color Scheme"),0,3,
           proc { $PokemonSystem.textskincolors },
           proc {|value| 
              $PokemonSystem.textskincolors=value
           },
           [_INTL("Standard"), _INTL("Colors"), _INTL("CMYK"), _INTL("Vintage")],
          _INTL("Sets the colors to be used in Windowskins.")
         ),
       NumberOption.new(_INTL("Font Style"),1,$VersionStyles.length,
          proc { $PokemonSystem.font },
          proc {|value|
             $PokemonSystem.font=value
             MessageConfig.pbSetSystemFontName($VersionStyles[value])
          },
          $VersionStylesNames,
          _INTL("Sets the font used in Game.")       
       ),
         NumberOption.new(_INTL("Accent Color"),1,getAccentNames.length,
           proc { $PokemonSystem.accentcolor },
           proc {|value| 
             $PokemonSystem.accentcolor = value 
             $BORDERS=getBorders
             setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Accented Border
           },
           getAccentNames,
          _INTL("Sets the color of all accent-aware elements. Twenty-Five options exist. More than one color may be used to constuct an accent color. Blue is the default color.")
         ),
        EnumOption.new(_INTL("Custom Shiny Pokémon Sprites"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.customshiny },
          proc {|value| $PokemonSystem.customshiny = value },
        _INTL("If this is set to on, certain Pokémon will have distinct customized shiny sprites between forms instead of sharing the same shiny sprite.")
        ),
         NumberOption.new(_INTL("Screen Border Graphic"),1,$BORDERS.length,
            proc { $PokemonSystem.bordergraphic },
            proc {|value|
               $PokemonSystem.bordergraphic=value
               $BORDERS=getBorders
               setScreenBorderName($BORDERS[value]) # Sets image file for the border
            },
            getBorderNames,
           _INTL("Sets the decorative border graphic when Screen Border is on.")
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