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

def qoreInitials
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    $debugmode=$PokemonSystem.debugmode
    if ($debugmode==1)
      $DEBUG=true
    end
    $INTERNAL=$DEBUG
    $REGIONALCOMBO=1024
    $inbattle=false # Initialization
    $fusionfinder=false
    $JBIndex0= 0
    $JBIndex1= 1
    Graphics.frame_rate=40
end

def getBorders # Edit this along with getBorderNames to add more borders
  return [
        "Borders/border",
        "Borders/border_1",
        "Borders/border_2",
        getDarkModeFolder+"/Borders/"+['border_3','border_3_beta','border_3_dev','border_3_canary','border_3_internal','border_3_upgradewizard'][QQORECHANNEL],
        getAccentFolder+"/border_4",
        getDarkModeFolder+"/Borders/border_5",
        getDarkModeFolder+"/Borders/border_6",
        "Borders/border_7",
        getDarkModeFolder+"/Borders/border_8",
        "Borders/border_9",
        getDarkModeFolder+"/Borders/"+['border_10','border_10_1','border_10_2','border_10_3'][pbGetSeason],
        getDarkModeFolder+"/Borders/"+['border_11','border_11_1','border_11_2','border_11_3'][pbGetSeason],
        getDarkModeFolder+"/Borders/border_12",
        getDarkModeFolder+"/Borders/border_13",
        getDarkModeFolder+"/Borders/border_14",
        getDarkModeFolder+"/Borders/border_15",
        getDarkModeFolder+"/Borders/border_16",
        getDarkModeFolder+"/Borders/border_17",
        getDarkModeFolder+"/Borders/border_18",
      ]
end

def getBorderNames # Edit this along with getBorders to add more borders
  return [
        "Classic",
        "Original",
        "Modern",
        "Channel-Aware",
        "Accent-Aware",
        "Green Theme-Aware",
        "Purple Theme-Aware",
        "Pride",
        "Old Script",
        "Pokémon Scarlet",
        "Season-Aware",
        "Corporate Season-Aware",
        "Plain",
        "Retro",
        "Green",
        "Blue",
        "Orange",
        "Purple",
        "Yellow",
      ]
end


def pbCallTitle #:nodoc:
  qoreInitials
  channelvar= QQORECHANNELVARIANT.to_s
  title=['QoreTitle_0_'+channelvar,'QoreTitle_1_'+channelvar,'QoreTitle_2_'+channelvar,'QoreTitle_3_'+channelvar,'QoreTitle_4_'+channelvar,'QoreTitle_5_'+channelvar][QQORECHANNEL]
  title=['QoreTitle','QoreTitle_1','QoreTitle_2','QoreTitle_3','QoreTitle_4','QoreTitle_5'][QQORECHANNEL]  if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title)) || (QQORECHANNELVARIANT < 1)
  title='QoreTitle' if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title))
#  Win32API.SyncTitle
  if $DEBUG
    if QQORECHANNEL == 3
      return Scene_Intro.new(['canary_disclaimer','intro1'], title) 
    else
      return Scene_Intro.new(['intro1'], title) 
    end  
#    return Scene_DebugIntro.new
  else
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    if QQORECHANNEL == 3
      return Scene_Intro.new(['canary_disclaimer','intro1'], title) 
    else
      return Scene_Intro.new(['intro1'], title) 
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
    if pbGetVersion() < 10240
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
