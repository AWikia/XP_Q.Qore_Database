=begin
BUTTON REFERENCES:
A = A
B = X
C = C
X = V
Y = Y
Z = Z
L/PGup = L
R/PGdw = R
Arrows = Arrows
Functions = F(1|2|3|4|5|6|7|8|9|10|11|12)
=end

def timebombed
  return false
end


class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def qoreInitials(minimal=false)
    if !minimal
      $PokemonSystem = PokemonSystem.new if !$PokemonSystem
      $debugmode=$PokemonSystem.debugmode
      if ($debugmode==1)
        $DEBUG=true
      end
      $INTERNAL=$DEBUG
    end
    $REGIONALCOMBO=1024
    # Initialization
    $inbattle=false # 
    $fusionfinder=false
    $JBIndex0= 0 # Jukebox Page one index
    $JBIndex1= 1
    Graphics.frame_rate=40
end

def getBorders # Edit this along with getBorderNames to add more borders
  return [
        "Borders/border",
        getDarkModeFolder+"/Borders/border_1",
        "Borders/border_2",
        getDarkModeFolder+"/Borders/border_3"+['','_beta','_dev','_canary','_internal','_upgradewizard'][QQORECHANNEL],
        getAccentFolder+"/border_4",
        getDarkModeFolder+"/Borders/border_5",
        getDarkModeFolder+"/Borders/border_6",
        "Borders/border_7",
        getDarkModeFolder+"/Borders/border_8",
        "Borders/border_9",
        getDarkModeFolder+"/Borders/border_10"+['','_1','_2','_3'][pbGetSeason],
        getDarkModeFolder+"/Borders/border_11"+['','_1','_2','_3'][pbGetSeason],
        getDarkModeFolder+"/Borders/border_12",
        getDarkModeFolder+"/Borders/border_13",
        getDarkModeFolder+"/Borders/border_14",
        getDarkModeFolder+"/Borders/border_15",
        getDarkModeFolder+"/Borders/border_16",
        getDarkModeFolder+"/Borders/border_17",
        getDarkModeFolder+"/Borders/border_18",
        getDarkModeFolder+"/Borders/border_19",
        "Borders/border_20",
      ]
end

def getBorderNames # Edit this along with getBorders to add more borders
  return [
        _INTL("Classic"),
        _INTL("Original"),
        _INTL("Modern"),
        _INTL("Channel-Aware"),
        _INTL("Accent-Aware"),
        _INTL("Green Theme-Aware"),
        _INTL("Purple Theme-Aware"),
        _INTL("Pride"),
        _INTL("Old Script"),
        _INTL("Pokémon Scarlet"),
        _INTL("Season-Aware"),
        _INTL("Corporate Season-Aware"),
        _INTL("Plain"),
        _INTL("Retro"),
        _INTL("Green"),
        _INTL("Blue"),
        _INTL("Orange"),
        _INTL("Purple"),
        _INTL("Yellow"),
        _INTL("Esmeralda"),
        _INTL("Retro Pokémon Scarlet"),
      ]
end


def pbCallTitle(minimal=false) #:nodoc:
  qoreInitials(minimal)
  channelvar= QQORECHANNELVARIANT.to_s
  title=['QoreTitle_0_'+channelvar,
         'QoreTitle_1_'+channelvar,
         'QoreTitle_2_'+channelvar,
         'QoreTitle_3_'+channelvar,
         'QoreTitle_4_'+channelvar,
         'QoreTitle_5_'+channelvar][QQORECHANNEL]
  title=['QoreTitle',
         'QoreTitle_1',
         'QoreTitle_2',
         'QoreTitle_3',
         'QoreTitle_4',
         'QoreTitle_5'][QQORECHANNEL]  if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title)) || (QQORECHANNELVARIANT < 1)
  title='QoreTitle' if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title))
  title='QoreTitle_empty' if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title))
#  Win32API.SyncTitle
  if minimal
    return Scene_Intro.new([],title)
  elsif $DEBUG
    if QQORECHANNEL == 3
      return Scene_Intro.new(['canary_disclaimer','intro1','intro2','intro3'], title) 
    else
      return Scene_Intro.new(['intro1','intro2','intro3'], title) 
    end  
#    return Scene_DebugIntro.new
  else
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    if QQORECHANNEL == 3
      return Scene_Intro.new(['canary_disclaimer','intro1','intro2','intro3'], title) 
    else
      return Scene_Intro.new(['intro1','intro2','intro3'], title) 
    end  
  end
end

def mainFunction #:nodoc:
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug #:nodoc:
  begin
    getCurrentProcess=Win32API.new("kernel32.dll","GetCurrentProcess","","l")
    setPriorityClass=Win32API.new("kernel32.dll","SetPriorityClass",%w(l i),"")
    setPriorityClass.call(getCurrentProcess.call(),32768) # "Above normal" priority class
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $game_system        = Game_System.new
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    $oldAccent   = $PokemonSystem.accentcolor
    $BORDERS=getBorders
    setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic]) # Sets image file for the border
# Don't load Q.Qore in Windows 8.1 and below
    if pbGetVersion() < 10586
        data_system = pbLoadRxData("Data/System")
        pbBGMPlay(data_system.title_bgm)
        scene=PokemonOutdatedSystemScreenScene.new
        screen=PokemonOutdatedSystemScreen.new(scene)
        pbFadeOutIn(99999) { 
           screen.pbStartScreen
        }
      return
    end
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(20)
  rescue Hangup
    pbEmergencySave
    raise
  end
end

loop do
  retval=mainFunction
  if retval==0 # failed
    loop do
      Graphics.update
    end
  elsif retval==1 # ended successfully
    break
  end
end
