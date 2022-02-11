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
    $newmech= $PokemonSystem.mechanics
    $TEST=($debugmode==1) ? true : false
    $DEBUG=($debugmode==1) ? true : false
    $REGIONALCOMBO=1030
    $USENEWBATTLEMECHANICS=($newmech==1) ? true : false
    $inbattle=false # Initialization
    value=$PokemonSystem.textspeed
    if value==3 
      Graphics.frame_rate=50
    elsif value==2
      Graphics.frame_rate=40
    elsif value==1
      Graphics.frame_rate=30
    else
      Graphics.frame_rate=24
    end
end

def getBorders # Edit this to add more borders
  return [
        "border",
        "border_1",
        "border_2",
        ['border_3','border_3_beta','border_3_dev','border_3_canary'][QQORECHANNEL],
        getAccentFolder+"/border_4"
      ]
end
            
def pbCallTitle #:nodoc:
  qoreInitials
  title=['QoreTitle','QoreTitle_1','QoreTitle_2','QoreTitle_3'][QQORECHANNEL]
  title='QoreTitle' if !pbResolveBitmap(_INTL("Graphics/Titles/{1}", title))
#  Win32API.SyncTitle
  if ($DEBUG || $TEST)
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
  if ($DEBUG || $TEST)
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
