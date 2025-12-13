################################################################################
# General purpose utilities
################################################################################
def _pbNextComb(comb,length)
  i=comb.length-1
  begin
    valid=true
    for j in i...comb.length
      if j==i
        comb[j]+=1
      else
        comb[j]=comb[i]+(j-i)
      end
      if comb[j]>=length
        valid=false
        break
      end
    end
    return true if valid
    i-=1
  end while i>=0
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array,num)
  return if array.length<num || num<=0
  if array.length==num
    yield array
    return
  elsif num==1
    for x in array
      yield [x]
    end
    return
  end
  currentComb=[]
  arr=[]
  for i in 0...num
    currentComb[i]=i
  end
  begin
    for i in 0...num
      arr[i]=array[currentComb[i]]
    end
    yield arr
  end while _pbNextComb(currentComb,array.length)
end

def pbGetCDID()
  sendString=proc{|x|
     mciSendString=Win32API.new('winmm','mciSendString','%w(p,p,l,l)','l') 
     next "" if !mciSendString
     buffer="\0"*2000
     x=mciSendString.call(x,buffer,2000,0)
     if x==0
       next buffer.gsub(/\0/,"")
     else
       next ""
     end
  }
  sendString.call("open cdaudio shareable")
  ret=""
  if sendString.call("status cdaudio media present")=="true"
    ret=sendString.call("info cdaudio identity")
    if ret==""
      ret=sendString.call("info cdaudio info identity")
    end
  end
  sendString.call("close cdaudio")
  return ret
end

# Gets the path of the user's "My Documents" folder.
def pbGetMyDocumentsFolder()
  csidl_personal=0x0005
  shGetSpecialFolderLocation=Win32API.new("shell32.dll","SHGetSpecialFolderLocation","llp","i")
  shGetPathFromIDList=Win32API.new("shell32.dll","SHGetPathFromIDList","lp","i")
  if !shGetSpecialFolderLocation || !shGetPathFromIDList
    return "."
  end
  idl=[0].pack("V")
  ret=shGetSpecialFolderLocation.call(0,csidl_personal,idl)
  return "." if ret!=0
  path="\0"*512
  ret=shGetPathFromIDList.call(idl.unpack("V")[0],path)
  return "." if ret==0
  return path.gsub(/\0/,"")
end

# Returns a country ID
# http://msdn.microsoft.com/en-us/library/dd374073%28VS.85%29.aspx?
def pbGetCountry()
  getUserGeoID=Win32API.new("kernel32","GetUserGeoID","l","i") rescue nil
  if getUserGeoID
    return getUserGeoID.call(16)
  end
  return 0
end

def pbIsSouthernHemisphere()
  return [0x09, 0x0A, 0x0B, 0x0C, 0x13, 0x1A, 0x1E, 0x20,
          0x26, 0x2B, 0x2C, 0x2E, 0x32, 0x33, 0x42, 0x45,
          0x4E, 0x50, 0x57, 0x6F, 0x81, 0x85, 0x92, 0x95,
          0x9C, 0xA0, 0xA5, 0xA8, 0xAE, 0xB4, 0xB7, 0xB9,
          0xBB, 0xC2, 0xCC, 0xD0, 0xD1, 0xD8, 0xE7, 0xE9,
          0xEC, 0xEF, 0xF0, 0xF6, 0xFE, 0x103, 0x104, 0x107,
          0x108, 0x12B, 0x130, 0x131, 0x132, 0x135, 0x137,
          0x138, 0x139, 0x13A, 0x13B, 0x13E, 0x13F, 0x145,
          0x147, 0x149, 0x14B, 0x14E, 0x14F, 0x150, 0x151,
          0x153, 0x154, 0x155, 0x156, 0x157, 0x15A, 0x15B,
          0x15C, 0x160, 0x51A4, 0x52D6, 0x66AE, 0x69EA, 0x7AA4, 
          0xA5F4, 0xB9EF, 0xB9F3, 0x6F60E7, 0x9BCE09,
          0x9A55D42].include?(pbGetCountry())
end

# Returns a language ID
def pbGetLanguage()
  getUserDefaultLangID=Win32API.new("kernel32","GetUserDefaultLangID","","i") rescue nil
  ret=0
  if getUserDefaultLangID
    ret=getUserDefaultLangID.call()&0x3FF
  end
  if ret==0 # Unknown
    ret=MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
       "Control Panel\\Desktop\\ResourceLocale","",0)
    ret=MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
       "Control Panel\\International","Locale","0").to_i(16) if ret==0
    ret=ret&0x3FF
    return 0 if ret==0  # Unknown
  end
  return 1 if ret==0x11 # Japanese
  return 2 if ret==0x09 # English
  return 3 if ret==0x0C # French
  return 4 if ret==0x10 # Italian
  return 5 if ret==0x07 # German
  return 7 if ret==0x0A # Spanish
  return 8 if ret==0x12 # Korean
  return 2 # Use 'English' by default
end

# Converts a Celsius temperature to Fahrenheit.
def toFahrenheit(celsius)
  return (celsius*9.0/5.0).round+32
end


# Converts a Fahrenheit temperature to Celsius.
def toCelsius(fahrenheit)
  return ((fahrenheit-32)*5.0/9.0).round
end

################################################################################
# Qortex Essentials utilities
################################################################################
# Returns the build number. For Evelution, it should return 22621
def pbGetVersion()
  ver=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
     "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
"CurrentBuild","") rescue nil
  if ver
    return ver.to_i
  end
  return 99999
end

def pbIsDarkSystemTheme?()
  ver=MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
     "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
"AppsUseLightTheme","") rescue nil
  if ver
    return (ver.to_i === 0)
  end
  return false
end

# Used only on some cases
def worksOnCorendo(clients=[])
  if clients.length==0
    Kernel.pbMessage(_INTL("This feature does not work anywhere"))
  else
    message = _INTL("\\l[{1}]This feature only works on the following clients:", 2+clients.length)
      for i in 1..clients.length
          message+=  _INTL("\\n- {1}", clients[i-1])
      end
      message+=  _INTL("\\nIn this client, it does nothing")
      Kernel.pbMessage(message)
  end
end

# About Q.Qore (Classic Version)
def qortexAbout
  @QQSR="\\l[4]"
  @QQSR+="Q.Qore Channel:" + RTP.getGameIniValue("Qortex", "Channel")
  @QQSR+="\\nQ.Qore Release:" + RTP.getGameIniValue("Qortex", "Release")
  @QQSR+="\\nQ.Qore Semester:" + RTP.getGameIniValue("Qortex", "Semester")
  @QQSR+="\\nQ.Qore Version:" + RTP.getGameIniValue("Qortex", "Version") 
  Kernel.pbMessage(@QQSR)
end

# Memorize
=begin
  Use of "qorePartyMemorise" script will require new Pokemon to be added
=end
def qorePartyReset
  $Trainer.party=$game_variables[172]
end

def qorePartyMemorize
  pbSet(172,$Trainer.party)
  $Trainer.party=[]
end

# Returns the Adjusted National Pokedex Ordering done in Q.Qore (With Q.Qore
# Pokemon to the top and the Regular Species after them
def getQoreDexList(dexlist)
  return dexlist[649..848] | dexlist[921..940] | dexlist[1029..1048] | dexlist[1130..1139] | dexlist[1148..1247] | dexlist[1358..1367] | dexlist[1385..1564] | dexlist[0..648] | dexlist[849..920] | dexlist[941..1028] | dexlist[1049..1129] | dexlist[1140..1147] | dexlist[1248..1357] | dexlist[1368..1384] | dexlist[1565..3999]
end
  
def getDexNumber(indexNumber=0)
    fdexno = indexNumber.to_s
    return "????" if fdexno.to_i > PBSpecies.maxValue
    if indexNumber > 649 and indexNumber < 850 # Κορα Κορε Generation I
      fnum = (indexNumber - 649).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 921 and indexNumber < 942 # Κορα Κορε Generation I (P2)
      fnum = (indexNumber - 721).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 1029 and indexNumber < 1050  # Κορα Κορε Generation I (P3)
      fnum = (indexNumber - 809).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 1130 and indexNumber < 1141 # Κορα Κορε Generation I (P4)
      fnum = (indexNumber - 890).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 1148 and indexNumber < 1249 # Κορα Κορε Generation I (P5)
      fnum = (indexNumber - 898).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 1358 and indexNumber < 1369 # Κορα Κορε Generation I (P6)
      fnum = (indexNumber - 1008).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum
    elsif indexNumber > 1385 and indexNumber < 1566 # Κορα Κορε Generation II
      fnum = (indexNumber - 1025).to_s
      while (fnum.length < 3)
        fnum = "0" + fnum
      end
      fdexno = "Q" + fnum

    elsif indexNumber < 650 # Generation I-V
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 849 and indexNumber < 922 # Generation VI
      fdexno = (indexNumber - 200).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 941 and indexNumber < 1030 # Generation VII
      fdexno = (indexNumber - 220).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 1049 and indexNumber < 1131 # Generation VIII A
      fdexno = (indexNumber - 240).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 1140 and indexNumber < 1149 # Generation VIII B
      fdexno = (indexNumber - 250).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 1248 and indexNumber < 1359 # Generation VIII C + IX A
      fdexno = (indexNumber - 350).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 1368 and indexNumber < 1386 # Generation IX B
      fdexno = (indexNumber - 360).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    elsif indexNumber > 1565 # Generation IX C
      fdexno = (indexNumber - 540).to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
      fdexno = fdexno + ""
    end
    return fdexno
end

# Returns if Dark Mode is active
def isDarkMode?
  if $PokemonSystem
    if (($PokemonSystem.darkmode==1 rescue false))  # Dark Mode
      return true
    end
    if (($PokemonSystem.darkmode==2 rescue false))  # Automatic Mode
      return (PBDayNight.isNight? rescue false)
    end
    if (($PokemonSystem.darkmode==3 rescue false))  # Custom Mode
      return (PBDayNight.isDark? rescue false)
    end
    if (($PokemonSystem.darkmode==4 rescue false))  # From System Theme Mode
      return pbIsDarkSystemTheme?
    end
    return false                                    # Light Mode
  else
    return false
  end
end

# Returns the Dark Mode Folder
def getDarkModeFolder
  if $PokemonSystem
    return isDarkMode? ? "Dark Mode" : ""
  else
    return ""
  end
end



# Returns the Accent Color Folder
def getAccentFolder
  if $PokemonSystem
    if (($PokemonSystem.accentcolor!=24 rescue false)) # Accent Color 19 is hardcoded to be the channel-aware ones
      return "Accents/Accent Color " + $PokemonSystem.accentcolor.to_s
    elsif ($PokemonSystem.accentcolor<getAccentNames.length rescue false)
      return "Accents/Accent Color " + $PokemonSystem.accentcolor.to_s + ["/Stable","/Beta","/Dev","/Canary","/Internal","/Upgrade Wizard"][QQORECHANNEL]
    else
      return "Accents/Accent Color " + "16"
    end
  else
    return "Accents/Accent Color " + "16"
  end
end

# Returns the Accent Colors
def getAccentNames
  return [_INTL("Light Yellow"), _INTL("Yellow"), _INTL("Dark Yellow"),
          _INTL("Light Orange"), _INTL("Orange"), _INTL("Dark Orange"),
          _INTL("Light Red"), _INTL("Red"), _INTL("Dark Red"),
          _INTL("Light Pink"), _INTL("Pink"), _INTL("Dark Pink"),
          _INTL("Light Purple"), _INTL("Purple"), _INTL("Dark Purple"),
          _INTL("Light Blue"), _INTL("Blue"), _INTL("Dark Blue"), 
          _INTL("Light Green"), _INTL("Green"), _INTL("Dark Green"), 
          _INTL("Light Gray"), _INTL("Gray"), _INTL("Dark Gray"),
          _INTL("Channel-Aware")]
end

# Returns the Active Accent Color
def getAccentName
  if $PokemonSystem 
    return getAccentNames[$PokemonSystem.accentcolor]
  else
    return _INTL("Blue")
  end
end

# Makes Pokedexes adapt to the current settings
def pbCheckPokedexes
  numRegions = 0
  pbRgssOpen("Data/regionals.dat","rb"){|f| numRegions = f.fgetw }
  if numRegions+1 > $PokemonGlobal.pokedexUnlocked.length
    # Lock Dex that was previously National
    pbLockDex($PokemonGlobal.pokedexUnlocked.length-1)
    oldindex=$PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1].to_i
    $PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1]    = 0
    # Update Dexes (Inserts new entries)
    for i in 0...numRegions+1     # National Dex isn't a region, but is included
      next if $PokemonGlobal.pokedexIndex[i]
      $PokemonGlobal.pokedexIndex[i]    = 0
      $PokemonGlobal.pokedexUnlocked[i] = false
    end
    # Unlock National Dex
    pbUnlockDex(-1)
    $PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1] = oldindex
  elsif numRegions+1 < $PokemonGlobal.pokedexUnlocked.length
    # Lock Dex that was previously National
    pbLockDex($PokemonGlobal.pokedexUnlocked.length-1)
    oldindex=$PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1].to_i
    $PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1]    = 0
    # Update Dexes
    $PokemonGlobal.pokedexIndex[numRegions..$PokemonGlobal.pokedexIndex.length-1] = nil
    $PokemonGlobal.pokedexUnlocked[numRegions+1..$PokemonGlobal.pokedexUnlocked.length-1] = nil
    # Unlock National Dex
    pbUnlockDex(-1)
    $PokemonGlobal.pokedexIndex[$PokemonGlobal.pokedexUnlocked.length-1] = oldindex
  end
end

def pbHasItem?(item)
  return $PokemonBag.pbQuantity(item)>0
end

# Daily Treat Machine
def pbCheckDTM
  # Daily Treat Machine
  if $PokemonBag.pbQuantity(:COINCASE)>0 && $PokemonBag.pbQuantity(:DAILYTREATMACHINE)==0
    $PokemonBag.pbStoreItem(:DAILYTREATMACHINE,1)
  end
  if $PokemonBag.pbQuantity(:DAILYTREATMACHINE)>0 && 
     pbTimeEventValid(DTM_VARIABLES[1],false,86400)
        scene=DailyTreatMachineScene.new
        screen=DailyTreatMachine.new(scene)
        pbFadeOutIn(99999) { 
           screen.pbStartScreen
        }
  end
  # Pokemon Box
  if $PokemonBag.pbQuantity(:PCSTORAGEBOX)>0 && $PokemonBag.pbQuantity(:POKEMONBOX)==0
    $PokemonBag.pbStoreItem(:POKEMONBOX,1)
  end
  expiredbox= pbTimeEventValid(PBOX_VARIABLES[3])
  if $game_variables[PBOX_VARIABLES[1]] == 0 || expiredbox
       scene=PokemonBoxScene.new
       screen=PokemonBoxEvent.new(scene)
       pbFadeOutIn(99999) { 
          screen.pbStartScreen(expiredbox)
       }
  end
end

def pbReturnBonusEvent
  $PokemonGlobal.lastSavedTime  = Time.now if !$PokemonGlobal.lastSavedTime
  oldtime = ((Time.now - $PokemonGlobal.lastSavedTime) / 86400).floor
  if oldtime > 9
    multi = [(oldtime/10).floor,3].min # x1 on 10-19 days, x2 on 20-29 days, x3 on 30+ days
    money = 5000*multi
    $Trainer.money+=money
    Kernel.pbMessage(_INTL("\\f[introOak]\\rSannse:Welcome back \\PN! Here's ${1} that were found during your vactaion.",money))
    amtGem=3*multi
    amtPotion=2*multi
    amtBall=1*multi
    amtBallName=amtBall == 1 ? "Ball" : "Balls"
    $PokemonBag.pbStoreItem(PBItems::RETURNBONUSGEM,amtGem)
    $PokemonBag.pbStoreItem(PBItems::RETURNBONUSPOTION,amtPotion)
    $PokemonBag.pbStoreItem(PBItems::RETURNBONUSBALL,amtBall)
    Kernel.pbMessage(_INTL("\\f[introElm]\\bRappy:And so I did found {1} Gems, {2} Potions and {3} {4} during your vacation too.",amtGem,amtPotion,amtBall,amtBallName))
    Kernel.pbMessage(_INTL("\\f[introOak]\\rSannse:Good Luck with these rewards!"))
  end
end

# Returns true if the current Date is special
def pbIsMillenialDate?
  time=pbGetTimeNow if !time
  curdate=[time.mon,time.day]  # 0 = Month | 1 = Day
  country=pbGetCountry() rescue nil
  return true if curdate == [12,31] # Must be true on Qora Qore's anniversary
  # Regular Countries plus "Serbia and Monternego"
  dates={
    0x2       => [[11,1]],                             # Antigua and Barduba
    0x3       => [[8,19]],                             # Afghanistan
    0x4       => [[7,5],[11,1]],                       # Algeria
    0x5       => [[5,28]],                             # Azerbaijan
    0x6       => [[11,28]],                            # Albania
    0x7       => [[5,28],[9,21]],                      # Armenia
    0x8       => [[9,8]],                              # Andorra
    0x9       => [[11,11]],                            # Angola
    0xA       => [[4,17]],                             # American Samoa
    0xB       => [[5,25],[7,9]],                       # Argentina
    0xC       => [[1,26]],                             # Australia
    0xE       => [[10,26]],                            # Austria
    0x11      => [[12,16]],                            # Bahrain
    0x12      => [[11,30]],                            # Barbados
    0x13      => [[9,30]],                             # Botswana
    0x15      => [[7,21]],                             # Belgium
    0x16      => [[7,10]],                             # The Bahamas
    0x17      => [[3,26],[12,16]],                     # Bangladesh
    0x18      => [[9,21]],                             # Belize
    0x19      => [[3,1],[11,25]],                      # Bosnia and Herzegovina
    0x1A      => [[8,6]],                              # Bolivia
    0x1C      => [[8,1]],                              # Benin
    0x1D      => [[7,3]],                              # Belarus
    0x1E      => [[7,7]],                              # Solomon Islands
    0x20      => [[9,7]],                              # Brazil
    0x22      => [[12,17]],                            # Bhutan
    0x23      => [[3,3]],                              # Bulgaria
    0x25      => [[2,23]],                             # Brunei
    0x26      => [[7,1]],                              # Burundi
    0x27      => [[7,1]],                              # Canada
    0x28      => [[11,9]],                             # Cambodia
    0x29      => [[8,11]],                             # Chad
    0x2A      => [[2,4]],                              # Sri Lanka
    0x2B      => [[8,15]],                             # Congo
    0x2C      => [[7,30]],                             # Congo (DRC)
    0x2D      => [[10,1]],                             # China
    0x2E      => [[9,18]],                             # Chile
    0x31      => [[5,20]],                             # Cameroon
    0x32      => [[7,6]],                              # Comoros
    0x33      => [[7,20]],                             # Colombia
    0x36      => [[9,15]],                             # Costa Rica
    0x37      => [[12,1]],                             # Central African Republic
    0x38      => [[1,1],[10,10]],                      # Cuba
    0x39      => [[7,5]],                              # Cabo Verde
    0x3B      => [[10,1]],                             # Cyprus
    0x3D      => [[6,5]],                              # Denmark
    0x3E      => [[6,27]],                             # Djibouti
    0x3F      => [[11,3]],                             # Dominica
    0x41      => [[2,27]],                             # Dominican Republic
    0x42      => [[8,10]],                             # Ecuador
    0x43      => [[7,23]],                             # Egypt
    0x44      => [[3,17]],                             # Ireland
    0x45      => [[10,12]],                            # Equatorial Guinea
    0x46      => [[2,24]],                             # Estonia
    0x47      => [[5,24]],                             # Eritrea
    0x48      => [[9,15]],                             # El Salvador
    0x49      => [[5,28]],                             # Ethiopia
    0x4B      => [[10,28]],                            # Czech Republic
    0x4D      => [[12,6]],                             # Finland
    0x4E      => [[10,10]],                            # Fiji
    0x50      => [[11,3]],                             # Micronesia
    0x51      => [[7,29]],                             # Faroe Islands
    0x54      => [[7,14]],                             # France
    0x56      => [[7,25]],                             # Gambia
    0x57      => [[8,17]],                             # Gabon
    0x58      => [[5,26]],                             # Georgia
    0x59      => [[3,6]],                              # Ghana
    0x5A      => [[9,10]],                             # Gibealtar
    0x5B      => [[2,7]],                              # Grenada
    0x5D      => [[6,21]],                             # Greenland
    0x5E      => [[10,3]],                             # Germany
    0x62      => [[3,25],[10,28]],                     # Greece
    0x63      => [[9,15]],                             # Guatemala
    0x64      => [[10,2]],                             # Guinea
    0x65      => [[2,23],[5,26]],                      # Guyana
    0x67      => [[1,1]],                              # Haiti
    0x68      => [[7,1],[10,1]],                       # Hong Kong SAR
    0x6A      => [[9,15]],                             # Honduras
    0x6C      => [[5,30]],                             # Croatia
    0x6D      => [[3,15],[8,20],[10,23]],              # Hungury
    0x6E      => [[6,17]],                             # Iceland
    0x6F      => [[8,17]],                             # Indonesia
    0x71      => [[1,26],[8,15],[10,2]],               # India
    0x74      => [[2,11],[4,1]],                       # Iran
    0x76      => [[6,2]],                              # Italy
    0x77      => [[8,7]],                              # Côte d'Ivoire
    0x79      => [[10,3]],                             # Iraq
    0x7A      => [[2,11]],                             # Japan
    0x7C      => [[8,6]],                              # Jamaica
    0x7E      => [[5,25]],                             # Jordan
    0x81      => [[12,12]],                            # Kenya
    0x82      => [[8,31]],                             # Kyrgyzstan
    0x83      => [[8,15],[9,9],[10,10]],               # North Korea
    0x85      => [[7,12]],                             # Kiribati
    0x86      => [[3,1],[8,15],[10,3]],                # Korea
    0x88      => [[2,25]],                             # Kurdistan
    0x89      => [[12,16]],                            # Kazakhstan
    0x8A      => [[12,2]],                             # Laos
    0x8B      => [[11,22]],                            # Lebanon
    0x8C      => [[11,18]],                            # Latvia
    0x8D      => [[2,16]],                             # Lithuania
    0x8E      => [[7,26]],                             # Liberia
    0x8F      => [[8,29]],                             # Slovakia
    0x91      => [[8,15]],                             # Liechtenstein
    0x92      => [[10,4]],                             # Lesotho
    0x93      => [[6,23]],                             # Luxembourg
    0x94      => [[12,24]],                            # Libya
    0x95      => [[6,26]],                             # Madagascar
    0x97      => [[10,1],[12,20]],                     # Macao SAR
    0x98      => [[8,27]],                             # Moldova
    0x9A      => [[11,26],[12,29]],                    # Mongolia
    0x9C      => [[7,6]],                              # Malawi
    0x9D      => [[9,22]],                             # Mali
    0x9E      => [[11,19]],                            # Monaco
    0x9F      => [[11,18]],                            # Morocco
    0xA0      => [[3,12]],                             # Mauritius
    0xA2      => [[11,28]],                            # Mauritania
    0xA3      => [[3,31],[6,7],[9,8],[9,21],[12,13]],  # Malta
    0xA4      => [[11,20]],                            # Oman
    0xA6      => [[9,16]],                             # Mexico
    0xA7      => [[8,31],[9,16]],                      # Malaysia
    0xA8      => [[6,25]],                             # Mozambique
    0xAD      => [[12,18]],                            # Niger
    0xAE      => [[7,30]],                             # Vanuatu
    0xAF      => [[10,1]],                             # Nigeria
    0xB0      => [[4,27],[5,5]],                       # Netherlands
    0xB1      => [[5,17]],                             # Norway
    0xB2      => [[9,19]],                             # Nepal
    0xB4      => [[1,31]],                             # Nauru
    0xB5      => [[11,25]],                            # Suriname
    0xB6      => [[9,15]],                             # Nicaragua
    0xB7      => [[2,6]],                              # New Zealand
    0xB8      => [[11,15]],                            # Palestinian Authority
    0xB9      => [[5,14]],                             # Paraguay
    0xBB      => [[7,28]],                             # Peru
    0xBE      => [[3,23],[8,14]],                      # Pakistan
    0xBF      => [[5,3],[11,11]],                      # Poland
    0xC0      => [[11,3],[11,28]],                     # Panama
    0xC1      => [[6,10]],                             # Portugal
    0xC2      => [[9,16]],                             # Papua New Guinea
    0xC3      => [[7,9],[10,1]],                       # Palau
    0xC4      => [[9,24]],                             # Guinea-Bissau
    0xC5      => [[12,18]],                            # Qatar
    0xC6      => [[12,20]],                            # Réunion
    0xC7      => [[5,1]],                              # Marshall Islands
    0xC8      => [[12,1]],                             # Romania
    0xC9      => [[7,12]],                             # Philippines
    0xCA      => [[7,25],[9,23]],                      # Puerto Rico
    0xCB      => [[6,12],[11,4]],                      # Russia
    0xCC      => [[7,1]],                              # Rwanda
    0xCD      => [[9,23]],                             # Saudi Arabia
    0xCF      => [[9,19]],                             # Saint Kitts and Nevis
    0xD0      => [[6,18],[6,29]],                      # Seychelles
    0xD1      => [[4,27]],                             # South Africa
    0xD2      => [[4,4]],                              # Senegal
    0xD4      => [[6,25]],                             # Slovenia
    0xD5      => [[4,27]],                             # Sierra Leone
    0xD6      => [[9,3]],                              # San Marino
    0xD7      => [[8,9]],                              # Singapore
    0xD8      => [[7,1]],                              # Somalia
    0xD9      => [[10,12]],                            # Spain
    0xDA      => [[2,22]],                             # Saint Lucia
    0xDB      => [[1,1]],                              # Sudan
    0xDD      => [[6,6]],                              # Sweden
    0xDE      => [[4,17]],                             # Syria
    0xDF      => [[8,1]],                              # Switzerland
    0xE0      => [[12,2]],                             # United Arab Emirates
    0xE1      => [[8,31]],                             # Trinidad and Tobago
    0xE3      => [[12,5]],                             # Thailand
    0xE4      => [[9,9]],                              # Tajikistan
    0xE7      => [[6,4],[11,4]],                       # Tonga
    0xE8      => [[4,27]],                             # Togo
    0xE9      => [[7,12]],                             # São Tomé and Príncipe
    0xEA      => [[3,20]],                             # Tunisia
    0xEB      => [[10,29]],                            # Türkiye
    0xEC      => [[10,1]],                             # Tuvalu
    0xED      => [[1,1],[10,1]],                       # Taiwan
    0xEE      => [[9,27]],                             # Turkmenistan
    0xEF      => [[12,9]],                             # Tanzania
    0xF0      => [[10,9]],                             # Uganda
    0xF1      => [[7,15],[8,24]],                      # Ukraine
    0xF4      => [[7,4]],                              # United States
    0xF5      => [[12,11]],                            # Burkina Faso
    0xF6      => [[8,25]],                             # Uruguay
    0xF7      => [[9,1]],                              # Uzbekistan
    0xF8      => [[10,27]],                            # Saint Vincent and the Grenadines
    0xF9      => [[7,5]],                              # Venezuela
    0xFB      => [[9,2]],                              # Vietnam
    0xFC      => [[3,31]],                             # U.S. Virgin Islands
    0xFD      => [[2,11]],                             # Vatican City
    0xFE      => [[3,21]],                             # Namibia
    0x103     => [[7,1]],                              # Samoa
    0x104     => [[9,6]],                              # Swaziland
    0x105     => [[5,22]],                             # Yemen
    0x107     => [[10,24]],                            # Zambia
    0x108     => [[4,18]],                             # Zimbabwe
    0x10D     => [[2,15],[5,21],[7,13]],               # Serbia and Montenegro
    0x10E     => [[5,21],[7,13]],                      # Montenegro
    0x10F     => [[2,15]],                             # Serbia
    0x111     => [[7,2]],                              # Curaçao
    0x114     => [[7,9]],                              # South Sudan
    0x12C     => [[5,30]],                             # Anguilla
    0x138     => [[8,4]],                              # Cook Islands
    0x13B     => [[6,14]],                             # Falkland Islands
    0x13D     => [[6,10]],                             # French Guiana
    0x13E     => [[6,29]],                             # French Polynesia
    0x141     => [[9,27]],                             # Guadeloupe
    0x142     => [[7,21]],                             # Guam
    0x144     => [[5,9]],                              # Guernsey
    0x148     => [[5,9]],                              # Jersey
    0x14A     => [[5,22]],                             # Martinique
    0x14B     => [[4,27]],                             # Mayotte
    0x14E     => [[9,24]],                             # New Caledonia
    0x14F     => [[10,19]],                            # Niue
    0x150     => [[6,8]],                              # Norfolk Island
    0x151     => [[1,8]],                              # Northern Mariana Islands
    0x15D     => [[8,30]],                             # Turks and Caicos Islands
    0x15F     => [[7,1]],                              # British Virgin Islands
    0x3B16    => [[7,5]],                              # Isle of Man
    0x4CA2    => [[8,2],[9,8]],                        # North Macedonia
    0x78F7    => [[11,11]],                            # Sint Maarten	
    0x6F60E7  => [[5,20]],                             # Timor-Leste
    0x974941  => [[2,17]],                             # Kosovo
    0x9906F5  => [[6,9]]                               # Åland Islands
  }
  # Special Counries like Southern Europe
  dates2 = {
    # Northern Africa
    0xA5F7    => dates[0x4] | dates[0x43] | dates[0x94] | dates[0x9F] | dates[0xDB] | dates[0xEA],
    # Eastern Africa
    0xB9F3    => dates[0x26] | dates[0x32] | dates[0x3F] | dates[0x47] | dates[0x49] | dates[0x81] | dates[0x95] | dates[0x9C] | dates[0xA0] | dates[0xA2] | dates[0xA8] | dates[0xC6] | dates[0xCC] | dates[0xD0] | dates[0xD8] | dates[0xEF] | dates[0xF0] | dates[0x107] | dates[0x108] | dates[0x114] | dates[0x14B],
    # Middle Africa
    0xA5F4    => dates[0x9] | dates[0x29] | dates[0x2B] | dates[0x2C] | dates[0x31] | dates[0x37] | dates[0x45] | dates[0x57],
    # Southern Africa
    0x99324B  => dates[0x13] | dates[0x92] | dates[0xD1] | dates[0xFE],
    # Western Africa
    0xA5F3    => dates[0x1C] | dates[0x39] | dates[0x56] | dates[0x59] | dates[0x64] | dates[0x77] | dates[0x8E] | dates[0x9D] | dates[0xA2] | dates[0xAD] | dates[0xAF] | dates[0xC4] | dates[0xD2] | dates[0xD5] | dates[0xE8] | dates[0xF5],
    # Caribbean
    0x993248  => dates[0x2] | dates[0x12] | dates[0x16] | dates[0x38] | dates[0x3F] | dates[0x41] | dates[0x5B] | dates[0x67] | dates[0x7C] | dates[0xCA] | dates[0xCF] | dates[0xDA] | dates[0xE1] | dates[0xF8] | dates[0xFC] | dates[0x111] | dates[0x12C] | dates[0x141] | dates[0x14A] | dates[0x15D] | dates[0x15F],
    # Central America
    0x69CA    => dates[0x18] | dates[0x36] | dates[0x48] | dates[0x63] | dates[0x6A] | dates[0xA6] | dates[0xB6] | dates[0xC0],
    # South America
    0x7AA4    => dates[0xB] | dates[0x1A] | dates[0x20] | dates[0x2E] | dates[0x33] | dates[0x42] | dates[0x65] | dates[0xB5] | dates[0xB9] | dates[0xBB] | dates[0xF6] | dates[0xF9] | dates[0x13B] | dates[0x13D],
    # Northern America
    0x5C1D    => dates[0x27] | dates[0x5D] | dates[0xF4],
    # Central Asia
    0xB9E6    => dates[0x82] | dates[0x89] | dates[0xE4] | dates[0xEE] | dates[0xF7],
    # Eastern Asia
    0xB9F0    => dates[0x2D] | dates[0x68] | dates[0x7A] | dates[0x83] | dates[0x86] | dates[0x97] | dates[0x9A],
    # South-Eastern Asia
    0xb9BF    => dates[0x28] | dates[0x6F] | dates[0x8A] | dates[0xA7] | dates[0xC9] | dates[0xD7] | dates[0xE3] | dates[0xFB] | dates[0x6F60E7],
    # Southern Asia
    0xB9FE    => dates[0x3] | dates[0x17] | dates[0x22] | dates[0x2A] | dates[0x71] | dates[0x74] | dates[0xB2] | dates[0xBE],
    # Middle East
    0xB9FB    => dates[0x5] | dates[0x7] | dates[0x11] | dates[0x3B] | dates[0x58] | dates[0x79] | dates[0x7E] | dates[0x8B] | dates[0xA4] | dates[0xB8] | dates[0xC5] | dates[0xCD] | dates[0xDE] | dates[0xE0] | dates[0xEB] | dates[0x105],
    # Eastern Europe
    0xB9F9    => dates[0x1D] | dates[0x23] | dates[0x4B] | dates[0x6D] | dates[0x8F] | dates[0x98] | dates[0xBF] | dates[0xC8] | dates[0xCB] | dates[0xF1],
    # Northern Europe
    0x99324A  => dates[0x3D] | dates[0x44] | dates[0x46] | dates[0x4D] | dates[0x51] | dates[0x6E] | dates[0x8C] | dates[0x8D] | dates[0xB1] | dates[0xDD] | dates[0x144] | dates[0x148] | dates[0x9906F5],
    # Southern Europe
    0xB9FA    => dates[0x6] | dates[0x8] | dates[0x19] | dates[0x5A] | dates[0x62] | dates[0x6C] | dates[0x76] | dates[0xA3] | dates[0xC1] | dates[0xD4] | dates[0xD6] | dates[0xD9] | dates[0x10E] | dates[0x10F] | dates[0x4CA2],
    # Western Europe
    0x9BCE08  => dates[0xE] | dates[0x15] | dates[0x54] | dates[0x5E] | dates[0x91] | dates[0x93] | dates[0x9E] | dates[0xB0] | dates[0xDF],
    # Australia and New Zealand
    0x9BCE09  => dates[0xC] | dates[0xB7] | dates[0x150],
    # Melanesia
    0x51A4    => dates[0x1E] | dates[0x4E] | dates[0xAE] | dates[0xC2] | dates[0x14E],
    # Micronesia
    0x52D6    => dates[0x50] | dates[0x85] | dates[0xC3] | dates[0xC7] | dates[0x142] | dates[0x151],
    # Polynesia
    0x66AE   => dates[0xA] | dates[0xE7] | dates[0xEC] | dates[0x103] | dates[0x138] | dates[0x13E] | dates[0x14F]
}
  if dates.key?(country)
    return dates[country].include?(curdate)
  elsif dates2.key?(country)
    return dates2[country].include?(curdate)
  end
  return false
end

def pbCanAcceptEliteDSM
  time=pbGetTimeNow if !time
  id=pbGet(1).to_i
  return (id%99 === 0) ||
         (id === $Trainer.publicID($Trainer.id)) ||
         (id === $Trainer.secretID($Trainer.id)) ||
         pbIsMillenialDate?
end

# Returns the Trainer Card Level
def pbGetCardLevel
  level = 0
  if $game_switches
    if $game_switches[12]                           # E4 defeated
        level+=1
    end
    if $game_switches[70]                           # Johto Done
        level+=1
    end
    if $game_switches[76]                           # Pregame Done
        level+=1
    end
    if completedTrophies && completedTechnicalDiscs # Found every TD and Trophy
        level+=1
    end
    if $game_variables && $game_variables[13]>99    # Found every TD and Trophy
        level+=1
    end
  end
  return level
end

# Adds a Rental Season Mastery Pokemon
def pbAddRentalSMPokemon
  pbSetLotteryNumber(1)
  species=[
          :GENGAR,
          :ALAKAZAM,
          :STEELIX,
          :CLEFABLE,
          :MISMAGIUS,
          :FARIGIRAF,
          :SKARMORY,
          :GRANBULL,
          :SABLEYE,
          :CLAYDOL,
          :GARDEVOIR,
          :AGGRON,
          :DRIFBLIM,
          :BRONZONG,
          :LUCARIO,
          :ROSERADE,
          :CHANDELURE,
          :MUSHARNA,
          :KLINKLANG,
          :WHIMSICOTT,
          :TREVENANT,
          :MEOWSTIC,
          :AEGISLASH,
          :FLORGES,
          :PALOSSAND,
          :ORANGURU,
          :TOGEDEMARU,
          :COMFEY,
          :POLTEAGEIST,
          :HATTERENE,
          :COPPERAJAH,
          :ALCREMIE,
          :HOUNDSTONE,
          :RABSCA,
          :ORTHWORM,
          :DACHSBUN,
          :HAUNTRODE,
          :WIKINEWS,
          :PERILMAX,
          :ZELDA,
          :DHAUNTBUNTU,
          :CLIPCHAMP,
          :MSLAUNCHER,
          :MEDIACORP
          ]
  pbAddToPartySilent(species[pbGet(1).to_i%species.length],50)
end

def pbRecordOldValues
  # Record Pokemon Box's last task state
  if $game_variables[PBOX_VARIABLES[1]] != 0
    currentStep=PokemonBoxScene.new.currentStep
    $game_variables[PBOX_VARIABLES[5]]=$PokemonGlobal.pokebox[$game_variables[PBOX_VARIABLES[1]][currentStep][0]] - $game_variables[PBOX_VARIABLES[1]][currentStep][1]
  end
  if $game_switches[209]
    $game_variables[40][7] = pbMapTimeEventAmount
  end
end

# Starts a Tile Puzzle with the Video Graphic. If done, increments ad count by 1
def startAd
  return false if !canAcceptAds?
  if pbTilePuzzle(1,"Video")
    if $PokemonGlobal.adsWatched==0
      Kernel.pbMessage(_INTL("\\bDelio:You've just completed out an Ad Quest. Let's register ourselves to keep track on them."))
      pbPhoneRegisterNPC(21,"Delio",42)
      Kernel.pbMessage(_INTL("\\bDelio:Complete out 60 Ad Quests to get a Luxury Ball."))
    end
    $PokemonGlobal.adsWatched+=1
    if $PokemonGlobal.adsWatched%60==0
      Kernel.pbMessage(_INTL("\\bDelio:Congratulations! You've completed 60 Ad Quests. Here's your reward."))
      Kernel.pbReceiveItem(:LUXURYBALL)
      Kernel.pbMessage(_INTL("\\bDelio:You've also unlocked some more stuff in some places.")) if $PokemonGlobal.adsWatched==60
      Kernel.pbMessage(_INTL("\\bDelio:Complete 60 more for your next Luxury Ball."))
    end
    return true
  end
  return false
end

# Returns true if the Video Tile Puzzle can be started
def canAcceptAds?
  return class_exists?(:TilePuzzle)
end

def updateWindowSkin
  if ($BORDERS!=getBorders)
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$SpeechFrames[$PokemonSystem.newtextskin])
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/"+getDarkModeFolder+"/"+$TextFrames[$PokemonSystem.newtextskin])
    $BORDERS=getBorders
    setScreenBorderName($BORDERS[$PokemonSystem.bordergraphic])
  end
end

# Supplemental function
def class_exists?(class_name)
  klass = Module.const_get(class_name)
  return klass.is_a?(Class)
rescue NameError
  return false
end

################################################################################
# Mapped Timed Events
################################################################################
# (Currently assigned to Game Variable 40 and Switch 209)
# 0 = Task ID
# 1 = Initial Value of the chosen Task
# 2 = Max Value
# 3 = Max Value Rewards
# 4 = Other Values
# 5 = Other Value Rewards
# 6 = Event Name
# 7 = Last State of chosen task

def pbMapTimeEvent(taskid=0,maximumvalue=10,maximumrewards=nil,othervalues=nil,otherrewards=nil,name="My Event",mins=20,gender="b")
  gender = "\\" + gender
  taskname = $PokemonGlobal.pokeboxNames2[taskid]
  if Kernel.pbConfirmMessage(_INTL("{1}{2} minutes of {3}. Would you like to begin {4}?",gender,mins,taskname,name))
    Kernel.pbMessage(_INTL("{1}In those {2} minutes, you're forbitten from saving. Once those are over, I will call you for rewards.",gender,mins))
    $game_variables[40] = [taskid,$PokemonGlobal.pokebox[taskid],maximumvalue,maximumrewards,othervalues,otherrewards,name,0,gender]
    pbTimeEvent(41,mins*60)
    $game_switches[209] = true
    $game_variables[238] = $game_map.map_id
    $game_variables[239] = $game_player.x
    $game_variables[240] = $game_player.y
    $game_system.save_disabled = true
    return true
  else
    Kernel.pbMessage(_INTL("{1}Okay, come back at any time you wish to.",gender))
    return false
  end
end

def pbMapTimeEventRewardGain
  gender = pbMapTimeEventGender
  pbSEPlay("Badge Awarded")
  Kernel.pbMessage(_INTL("{1}Event over. Let's see if you can get a reward.",gender))
  if pbMapTimeEventDone
    Kernel.pbMessage(_INTL("{1}You won first and you get the top prize.",gender))
  elsif pbMapTimeEventRewards.is_a?(Array)
    Kernel.pbMessage(_INTL("{1}You didn't won first and you get a weaker prize.",gender))
  else
    Kernel.pbMessage(_INTL("{1}You didn't won anything. Better luck next time.",gender))
  end
  if pbMapTimeEventRewards.is_a?(Array)
    for i in pbMapTimeEventRewards
      if i.is_a?(Array)
        item=i[0]
        amt=i[1]
      else
        item=i
        amt=1
      end
      Kernel.pbReceiveItem(item,amt)
    end
  end
  pbSEPlay("Badge Awarded 2")
  Kernel.pbMessage(_INTL("{1}Please come in again.",gender))
end

# Returns Value 0 (Task ID)
def pbMapTimeEventID
  return $game_variables[40][0]
end

# Returns Current Value Minus Value 1
def pbMapTimeEventAmount
  return $PokemonGlobal.pokebox[$game_variables[40][0]] - $game_variables[40][1]
end

# Returns Value 2 (Max Amount/1st Position Place)
def pbMapTimeEventMax
  return $game_variables[40][2]
end

# True if Current Value Minus Value 1 is equal or above Value 2
def pbMapTimeEventDone
  return pbMapTimeEventAmount >= pbMapTimeEventMax
end

# Returns Value 4
def pbMapTimeEventOthers
  return $game_variables[40][4]
end

# Returns either Value 3 or one of the Subvalues of Value 5
def pbMapTimeEventRewards
  if pbMapTimeEventDone
    if $game_switches[218]
      return $game_variables[40][3] | [[:GOLDBAR,5]]
    else
      return $game_variables[40][3]
    end
  elsif pbMapTimeEventOthers.is_a?(Array)
    for i in 0...pbMapTimeEventOthers.length
      if pbMapTimeEventAmount >= pbMapTimeEventOthers[i]
        return $game_variables[40][5][i] if $game_variables[40][5][i]
      end
    end
  end
  return nil
end

# Returns Value 6 (Event Name)
def pbMapTimeEventName
  return $game_variables[40][6]
end

# Returns Value 7 (The last saved value)
def pbMapTimeEventOldAmount
  return $game_variables[40][7]
end

# Returns Value 8
def pbMapTimeEventGender
  return $game_variables[40][8]
end



################################################################################
# Linear congruential random number generator
################################################################################
class LinearCongRandom
  def initialize(mul, add, seed=nil)
    @s1=mul
    @s2=add
    @seed=seed
    @seed=(Time.now.to_i&0xffffffff) if !@seed
    @seed=(@seed+0xFFFFFFFF)+1 if @seed<0
  end

  def self.dsSeed
    t=Time.now
    seed = (((t.mon * t.mday + t.min + t.sec)&0xFF) << 24) | (t.hour << 16) | (t.year - 2000)
    seed=(seed+0xFFFFFFFF)+1 if seed<0
    return seed
  end

  def self.pokemonRNG
    self.new(0x41c64e6d,0x6073,self.dsSeed)
  end

  def self.pokemonRNGInverse
    self.new(0xeeb9eb65,0xa3561a1,self.dsSeed)
  end

  def self.pokemonARNG
    self.new(0x6C078965,0x01,self.dsSeed)
  end

  def getNext16 # calculates @seed * @s1 + @s2
    @seed=((((@seed & 0x0000ffff) * (@s1 & 0x0000ffff)) & 0x0000ffff) | 
       (((((((@seed & 0x0000ffff) * (@s1 & 0x0000ffff)) & 0xffff0000) >> 16) + 
       ((((@seed & 0xffff0000) >> 16) * (@s1 & 0x0000ffff)) & 0x0000ffff) + 
       (((@seed & 0x0000ffff) * ((@s1 & 0xffff0000) >> 16)) & 0x0000ffff)) & 
       0x0000ffff) << 16)) + @s2
    r=(@seed>>16)
    r=(r+0xFFFFFFFF)+1 if r<0
    return r
  end

  def getNext
    r=(getNext16()<<16)|(getNext16())
    r=(r+0xFFFFFFFF)+1 if r<0
    return r
  end
end



################################################################################
# JavaScript-related utilities
################################################################################
# Returns true if the given string represents a valid object in JavaScript
# Object Notation, and false otherwise.
def  pbIsJsonString(str)
  return false if (!str || str[ /^[\s]*$/ ])
  d=/(?:^|:|,)(?: ?\[)+/
  charEscapes=/\\[\"\\\/nrtubf]/ #"
  stringLiterals=/"[^"\\\n\r\x00-\x1f\x7f-\x9f]*"/ #"
  whiteSpace=/[\s]+/
  str=str.gsub(charEscapes,"@").gsub(stringLiterals,"true").gsub(whiteSpace," ")
  # prevent cases like "truetrue" or "true true" or "true[true]" or "5-2" or "5true" 
  otherLiterals=/(true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)(?! ?[0-9a-z\-\[\{\"])/ #"
  str=str.gsub(otherLiterals,"]").gsub(d,"") #"
  p str
  return str[ /^[\],:{} ]*$/ ] ? true : false
end

# Returns a Ruby object that corresponds to the given string, which is encoded in
# JavaScript Object Notation (JSON). Returns nil if the string is not valid JSON.
def pbParseJson(str)
  if !pbIsJsonString(str)
    return nil
  end
  stringRE=/(\"(\\[\"\'\\rntbf]|\\u[0-9A-Fa-f]{4,4}|[^\\\"])*\")/ #"
  strings=[]
  str=str.gsub(stringRE){
     sl=strings.length
     ss=$1
     if ss.include?("\\u")
       ss.gsub!(/\\u([0-9A-Fa-f]{4,4})/){
          codepoint=$1.to_i(16)
          if codepoint<=0x7F
            next sprintf("\\x%02X",codepoint)
          elsif codepoint<=0x7FF
            next sprintf("%s%s",
               (0xC0|((codepoint>>6)&0x1F)).chr,
               (0x80|(codepoint   &0x3F)).chr)
          else
            next sprintf("%s%s%s",
               (0xE0|((codepoint>>12)&0x0F)).chr,
               (0x80|((codepoint>>6)&0x3F)).chr,
               (0x80|(codepoint   &0x3F)).chr)
          end
       }
     end
     strings.push(eval(ss))
     next sprintf("strings[%d]",sl)
  }
  str=str.gsub(/\:/,"=>")
  str=str.gsub(/null/,"nil")
  return eval("("+str+")")
end



################################################################################
# XML-related utilities
################################################################################
# Represents XML content.
class MiniXmlContent
  attr_reader :value

  def initialize(value)
    @value=value
  end
end



# Represents an XML element.
class MiniXmlElement
  attr_accessor :name,:attributes,:children

  def initialize(name)
    @name=name
    @attributes={}
    @children=[]
  end

#  Gets the value of the attribute with the given name, or nil if it doesn't
#  exist.
  def a(name)
    self.attributes[name]
  end

#  Gets the entire text of this element.
  def value
    ret=""
    for c in @children
      ret+=c.value
    end
    return ret
  end

#  Gets the first child of this element with the given name, or nil if it
# doesn't exist.
  def e(name)
    for c in @children
      return c if c.is_a?(MiniXmlElement) && c.name==name
    end
    return nil
  end

  def eachElementNamed(name)
    for c in @children
      yield c if c.is_a?(MiniXmlElement) && c.name==name
    end
  end
end



# A small class for reading simple XML documents. Such documents must
# meet the following restrictions:
#  They may contain comments and processing instructions, but they are
#    ignored.
#  They can't contain any entity references other than 'gt', 'lt',
#    'amp', 'apos', or 'quot'.
#  They can't contain a DOCTYPE declaration or DTDs.
class MiniXmlReader
  def initialize(data)
    @root=nil
    @elements=[]
    @done=false
    @data=data
    @content=""
  end

  def createUtf8(codepoint) #:nodoc:
    raise ArgumentError.new("Illegal character") if codepoint<9 ||
       codepoint==11||codepoint==12||(codepoint>=14 && codepoint<32) ||
       codepoint==0xFFFE||codepoint==0xFFFF||(codepoint>=0xD800 && codepoint<0xE000)
    if codepoint<=0x7F
      return codepoint.chr
    elsif codepoint<=0x7FF
      str=(0xC0|((codepoint>>6)&0x1F)).chr
      str+=(0x80|(codepoint   &0x3F)).chr
      return str
    elsif codepoint<=0xFFFF
      str=(0xE0|((codepoint>>12)&0x0F)).chr
      str+=(0x80|((codepoint>>6)&0x3F)).chr
      str+=(0x80|(codepoint   &0x3F)).chr
      return str
    elsif codepoint<=0x10FFFF
      str=(0xF0|((codepoint>>18)&0x07)).chr
      str+=(0x80|((codepoint>>12)&0x3F)).chr
      str+=(0x80|((codepoint>>6)&0x3F)).chr
      str+=(0x80|(codepoint   &0x3F)).chr
      return str
    else
      raise ArgumentError.new("Illegal character")
    end
    return str
  end

  def unescape(attr) #:nodoc:
    attr=attr.gsub(/\r(\n|$|(?=[^\n]))/,"\n")
    raise ArgumentError.new("Attribute value contains '<'") if attr.include?("<")
    attr=attr.gsub(/&(lt|gt|apos|quot|amp|\#([0-9]+)|\#x([0-9a-fA-F]+));|([\n\r\t])/){
       next " " if $4=="\n"||$4=="\r"||$4=="\t"
       next "<" if $1=="lt"
       next ">" if $1=="gt"
       next "'" if $1=="apos"
       next "\"" if $1=="quot"
       next "&" if $1=="amp"
       next createUtf8($2.to_i) if $2
       next createUtf8($3.to_i(16)) if $3
    }
    return attr
  end

  def readAttributes(attribs) #:nodoc:
    ret={}
    while attribs.length>0
      if attribs[/(\s+([\w\-]+)\s*\=\s*\"([^\"]*)\")/]
        attribs=attribs[$1.length,attribs.length]
        name=$2; value=$3
        if ret[name]!=nil
          raise ArgumentError.new("Attribute already exists")
        end
        ret[name]=unescape(value)
      elsif attribs[/(\s+([\w\-]+)\s*\=\s*\'([^\']*)\')/]
        attribs=attribs[$1.length,attribs.length]
        name=$2; value=$3
        if ret[name]!=nil
          raise ArgumentError.new("Attribute already exists")
        end
        ret[name]=unescape(value)
      else
        raise ArgumentError.new("Can't parse attributes")
      end
    end
    return ret
  end

# Reads the entire contents of an XML document. Returns the root element of
# the document or raises an ArgumentError if an error occurs.
  def read
    if @data[/\A((\xef\xbb\xbf)?<\?xml\s+version\s*=\s*(\"1\.[0-9]\"|\'1\.[0-9]\')(\s+encoding\s*=\s*(\"[^\"]*\"|\'[^\']*\'))?(\s+standalone\s*=\s*(\"(yes|no)\"|\'(yes|no)\'))?\s*\?>)/]
      # Ignore XML declaration
      @data=@data[$1.length,@data.length]
    end
    while readOneElement(); end
    return @root
  end

  def readOneElement #:nodoc:
    if @data[/\A\s*\z/]
      @data=""
      if !@root
        raise ArgumentError.new("Not an XML document.")
      elsif !@done
        raise ArgumentError.new("Unexpected end of document.")
      end
      return false
    end
    if @data[/\A(\s*<([\w\-]+)((?:\s+[\w\-]+\s*\=\s*(?:\"[^\"]*\"|\'[^\']*\'))*)\s*(\/>|>))/]
      @data=@data[$1.length,@data.length]
      elementName=$2
      attributes=$3
      endtag=$4
      if @done
        raise ArgumentError.new("Element tag at end of document")
      end
      if @content.length>0 && @elements.length>0
        @elements[@elements.length-1].children.push(MiniXmlContent.new(@content))
        @content=""
      end
      element=MiniXmlElement.new(elementName)
      element.attributes=readAttributes(attributes)
      if !@root
        @root=element
      else
        @elements[@elements.length-1].children.push(element)
      end
      if endtag==">"
        @elements.push(element)
      else
        if @elements.length==0
          @done=true
        end
      end
    elsif @data[/\A(<!--([\s\S]*?)-->)/]
      # ignore comments
      if $2.include?("--")
        raise ArgumentError.new("Incorrect comment")
      end
      @data=@data[$1.length,@data.length]
    elsif @data[/\A(<\?([\w\-]+)\s+[\s\S]*?\?>)/]
      # ignore processing instructions
      @data=@data[$1.length,@data.length]
      if $2.downcase=="xml"
        raise ArgumentError.new("'xml' processing instruction not allowed")
      end
    elsif @data[/\A(<\?([\w\-]+)\?>)/]
      # ignore processing instructions
      @data=@data[$1.length,@data.length]
      if $2.downcase=="xml"
        raise ArgumentError.new("'xml' processing instruction not allowed")
      end
    elsif @data[/\A(\s*<\/([\w\-]+)>)/]
      @data=@data[$1.length,@data.length]
      elementName=$2
      if @done
        raise ArgumentError.new("End tag at end of document")
      end
      if @elements.length==0
        raise ArgumentError.new("Unexpected end tag")
      elsif @elements[@elements.length-1].name!=elementName
        raise ArgumentError.new("Incorrect end tag")
      else
        if @content.length>0
          @elements[@elements.length-1].children.push(MiniXmlContent.new(@content))
          @content=""
        end
        @elements.pop()
        if @elements.length==0
          @done=true
        end
      end
    else
      if @elements.length>0
        # Parse content
        if @data[/\A([^<&]+)/]
          content=$1
          @data=@data[content.length,@data.length]
          if content.include?("]]>")
            raise ArgumentError.new("Incorrect content")
          end
          content.gsub!(/\r(\n|\z|(?=[^\n]))/,"\n")
          @content+=content
        elsif @data[/\A(<\!\[CDATA\[([\s\S]*?)\]\]>)/]
          content=$2
          @data=@data[$1.length,@data.length]
          content.gsub!(/\r(\n|\z|(?=[^\n]))/,"\n")
          @content+=content
        elsif @data[/\A(&(lt|gt|apos|quot|amp|\#([0-9]+)|\#x([0-9a-fA-F]+));)/]
          @data=@data[$1.length,@data.length]
          content=""
          if $2=="lt"; content="<"
          elsif $2=="gt"; content=">"
          elsif $2=="apos"; content="'"
          elsif  $2=="quot"; content="\""
          elsif $2=="amp"; content="&"
          elsif $3; content=createUtf8($2.to_i)
          elsif $4; content=createUtf8($3.to_i(16))
          end
          @content+=content
        elsif !@data[/\A</]
          raise ArgumentError.new("Can't read XML content")
        end
      else
        raise ArgumentError.new("Can't parse XML")
      end
    end
    return true
  end
end



################################################################################
# Player-related utilities, random name generator
################################################################################
def pbChangePlayer(id)
  return false if id<0 || id>=8
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return false if !meta
  $Trainer.trainertype=meta[0] if $Trainer
  $game_player.character_name=meta[1]
  $game_player.character_hue=0
  $PokemonGlobal.playerID=id
  $Trainer.metaID=id if $Trainer
end

def pbGetPlayerGraphic
  id=$PokemonGlobal.playerID
  return "" if id<0 || id>=8
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return "" if !meta
  return pbPlayerSpriteFile(meta[0])
end

def pbGetPlayerTrainerType
  id=$PokemonGlobal.playerID
  return 0 if id<0 || id>=8
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return 0 if !meta
  return meta[0]
end

def pbGetTrainerTypeGender(trainertype)
  ret=2 # 2 = gender unknown
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
     if !trainertypes[trainertype]
       ret=2
     else
       ret=trainertypes[trainertype][7]
       ret=2 if !ret
     end
  }
  return ret
end

def pbTrainerName(name=nil,outfit=0)
  if $PokemonGlobal.playerID<0
    pbChangePlayer(0)
  end
  trainertype=pbGetPlayerTrainerType
  trname=name
  $Trainer=PokeBattle_Trainer.new(trname,trainertype)
  $Trainer.outfit=outfit
  if trname==nil
    trname=pbEnterPlayerName(_INTL("Your name?"),0,12)
    if trname==""
      gender=pbGetTrainerTypeGender(trainertype) 
      trname=pbSuggestTrainerName(gender)
    end
  end
  $Trainer.name=trname
  $PokemonBag=PokemonBag.new
  $PokemonTemp.begunNewGame=true
end

def pbSuggestTrainerName(gender)
  userName=pbGetUserName()
  userName=userName.gsub(/\s+.*$/,"")
  if userName.length>0 && userName.length<12
    userName[0,1]=userName[0,1].upcase
    return userName
  end
  userName=userName.gsub(/\d+$/,"")
  if userName.length>0 && userName.length<12
    userName[0,1]=userName[0,1].upcase
    return userName
  end
  owner=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
     "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
     "RegisteredOwner","")
  owner=owner.gsub(/\s+.*$/,"")
  if owner.length>0 && owner.length<12
    owner[0,1]=owner[0,1].upcase
    return owner
  end
  return getRandomNameEx(gender,nil,1,7)
end

def pbGetUserName()
  buffersize=100
  getUserName=Win32API.new('advapi32.dll','GetUserName','pp','i')
  10.times do
    size=[buffersize].pack("V")
    buffer="\0"*buffersize
    if getUserName.call(buffer,size)!=0
      return buffer.gsub(/\0/,"")
    end
    buffersize+=200
  end
  return ""
end

def getRandomNameEx(type,variable,upper,maxLength=100)
  return "" if maxLength<=0
  name=""
  50.times {
    name=""
    formats=[]
    case type
    when 0 # Names for males
      formats=%w( F5 BvE FE FE5 FEvE )
    when 1 # Names for females
      formats=%w( vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3 )
    when 2 # Neutral gender names
      formats=%w( WE WEU WEvE BvE BvEU BvEvE )
    else
      return ""
    end
    format=formats[rand(formats.length)]
    format.scan(/./) {|c|
       case c
       when "c" # consonant
         set=%w( b c d f g h j k l m n p r s t v w x z )
         name+=set[rand(set.length)]
       when "v" # vowel
         set=%w( a a a e e e i i i o o o u u u )
         name+=set[rand(set.length)]
       when "W" # beginning vowel
         set=%w( a a a e e e i i i o o o u u u au au ay ay 
            ea ea ee ee oo oo ou ou )
         name+=set[rand(set.length)]
       when "U" # ending vowel
         set=%w( a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo )
         name+=set[rand(set.length)]
       when "B" # beginning consonant
         set1=%w( b c d f g h j k l l m n n p r r s s t t v w y z )
         set2=%w(
            bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
            sm sn sp st sw th tr tw vl zh )
         name+=rand(3)>0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
       when "E" # ending consonant
         set1=%w( b c d f g h j k k l l m n n p r r s s t t v z )
         set2=%w( bb bs ch cs ds fs ft gs gg ld ls
            nd ng nk rn kt ks
            ms ns ph pt ps sk sh sp ss st rd
            rn rp rm rt rk ns th zh)
         name+=rand(3)>0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
       when "f" # consonant and vowel
         set=%w( iz us or )
         name+=set[rand(set.length)]
       when "F" # consonant and vowel
         set=%w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
            di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
         name+=set[rand(set.length)]
       when "2"
         set=%w( c f g k l p r s t )
         name+=set[rand(set.length)]
       when "3"
         set=%w( nka nda la li ndra sta cha chie )
         name+=set[rand(set.length)]
       when "4"
         set=%w( una ona ina ita ila ala ana ia iana )
         name+=set[rand(set.length)]
       when "5"
         set=%w( e e o o ius io u u ito io ius us )
         name+=set[rand(set.length)]
       when "6"
         set=%w( a a a elle ine ika ina ita ila ala ana )
         name+=set[rand(set.length)]
       end
    }
    break if name.length<=maxLength
  }
  name=name[0,maxLength]
  case upper
  when 0
    name=name.upcase
  when 1
    name[0,1]=name[0,1].upcase
  end
  if $game_variables && variable
    $game_variables[variable]=name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength=100)
  return getRandomNameEx(2,nil,nil,maxLength)
end



################################################################################
# Event timing utilities
################################################################################
def pbTimeEvent(variableNumber,secs=86400)
  if variableNumber && variableNumber>=0
    if $game_variables
      secs=0 if secs<0
      timenow=pbGetTimeNow
      $game_variables[variableNumber]=[timenow.to_f,secs]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventDays(variableNumber,days=0)
  if variableNumber && variableNumber>=0
    if $game_variables
      days=0 if days<0
      timenow=pbGetTimeNow
      time=timenow.to_f
      expiry=(days*86400.0)-((time+10800)%86400.0)
      $game_variables[variableNumber]=[time,expiry]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventValid(variableNumber,reset=true,offset=0)
  retval=false
  if variableNumber && variableNumber>=0 && $game_variables
    value=$game_variables[variableNumber]
    if value.is_a?(Array)
      timenow=pbGetTimeNow
      retval=(timenow.to_f - value[0] > value[1] - offset) # value[1] is age in seconds
      retval2=(timenow.to_f - value[0] > value[1]) # value[1] is age in seconds
      retval=false if value[1]<=0 # zero age
    end
    if retval # If event is valid, reset it
      $game_variables[variableNumber]=0 if reset && retval2 # only reset if enabled AND the actual event ended
      $game_map.refresh if $game_map
    end
  end
  return retval
end

def pbTimeEventRemainingTime(variableNumber,offset=0)
  if variableNumber && variableNumber>=0 && $game_variables
    value=$game_variables[variableNumber]
    if value.is_a?(Array)
      timenow=pbGetTimeNow
      time= [value[1] - (timenow.to_f - value[0]) - offset,0].max
      sec = time % 60
      min = time / 60 % 60
      hour = time / 60 / 60 % 24
      day = time / 60 / 60 / 24 % 7
      week = time / 60 / 60 / 24 / 7
      if week.floor>0
        units=[_INTL("w"),_INTL("d")]
        vals=[week,day,7]
      elsif day.floor>0
        units=[_INTL("d"),_INTL("h")]
        vals=[day,hour,24]
      elsif hour.floor>0
        units=[_INTL("h"),_INTL("m")]
        vals=[hour,min,60]
      else
        units=["m","s"]
        vals=[min,sec,60]
      end
      if vals[1].ceil>=vals[2]
        vals[0]+=1
        vals[1]=0
      end
      return _INTL("{1}{2} {3}{4}",vals[0].floor,units[0],vals[1].ceil,units[1])
    end
  end

end


################################################################################
# Constants utilities
################################################################################
def isConst?(val,mod,constant)
  begin
    isdef=mod.const_defined?(constant.to_sym)
    return false if !isdef
  rescue
    return false
  end
  return (val==mod.const_get(constant.to_sym))
end

def hasConst?(mod,constant)
  return false if !mod || !constant || constant==""
  return mod.const_defined?(constant.to_sym) rescue false
end

def getConst(mod,constant)
  return nil if !mod || !constant || constant==""
  return mod.const_get(constant.to_sym) rescue nil
end

def getID(mod,constant)
  return nil if !mod || !constant || constant==""
  if constant.is_a?(Symbol) || constant.is_a?(String)
    if (mod.const_defined?(constant.to_sym) rescue false)
      return mod.const_get(constant.to_sym) rescue 0
    else
      return 0
    end
  else
    return constant
  end
end



################################################################################
# Implements methods that act on arrays of items.  Each element in an item
# array is itself an array of [itemID, itemCount].
# Used by the Bag, PC item storage, and Triple Triad.
################################################################################
module ItemStorageHelper
  # Returns the quantity of the given item in the items array, maximum size per slot, and item ID
  def self.pbQuantity(items,maxsize,item)
    ret=0
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        ret+=itemslot[1]
      end
    end
    return ret
  end

  # Deletes an item from items array, maximum size per slot, item, and number of items to delete
  def self.pbDeleteItem(items,maxsize,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    ret=false
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        amount=[qty,itemslot[1]].min
        itemslot[1]-=amount
        qty-=amount
        items[i]=nil if itemslot[1]==0
        if qty==0
          ret=true
          break
        end
      end
    end
    items.compact!
    return ret
  end

  def self.pbCanStore?(items,maxsize,maxPerSlot,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize
      itemslot=items[i]
      if !itemslot
        qty-=[qty,maxPerSlot].min
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        return true if qty==0
      end
    end
    return false
  end

  def self.pbStoreItem(items,maxsize,maxPerSlot,item,qty,sorting=false)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize
      itemslot=items[i]
      if !itemslot
        items[i]=[item,[qty,maxPerSlot].min]
        qty-=items[i][1]
        if sorting
          items.sort! if POCKETAUTOSORT[$ItemData[item][ITEMPOCKET]]
        end
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        itemslot[1]=newamt
        return true if qty==0
      end
    end
    return false
  end
end



################################################################################
# General-purpose utilities with dependencies
################################################################################
# Similar to pbFadeOutIn, but pauses the music as it fades out.
# Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for pbFadeOutIn).
def pbFadeOutInWithMusic(zViewport)
  playingBGS=$game_system.getPlayingBGS
  playingBGM=$game_system.getPlayingBGM
  $game_system.bgm_pause(1.0)
  $game_system.bgs_pause(1.0)
  pos=$game_system.bgm_position
  pbFadeOutIn(zViewport) {
     yield
     $game_system.bgm_position=pos
     $game_system.bgm_resume(playingBGM)
     $game_system.bgs_resume(playingBGS)
  }
end

# Gets the wave data from a file and displays an message if an error occurs.
# Can optionally delete the wave file (this is useful if the file was a
# temporary file created by a recording).
# Requires the script AudioUtilities
# Requires the script "PokemonMessages"
def getWaveDataUI(filename,deleteFile=false)
  error=getWaveData(filename)
  if deleteFile
    begin
      File.delete(filename)
    rescue Errno::EINVAL, Errno::EACCES, Errno::ENOENT
    end
  end
  case error
  when 1
    Kernel.pbMessage(_INTL("The recorded data could not be found or saved."))
  when 2
    Kernel.pbMessage(_INTL("The recorded data was in an invalid format."))
  when 3
    Kernel.pbMessage(_INTL("The recorded data's format is not supported."))
  when 4
    Kernel.pbMessage(_INTL("There was no sound in the recording. Please ensure that a microphone is attached to the computer and is ready."))
  else
    return error
  end
  return nil
end

# Starts recording, and displays a message if the recording failed to start.
# Returns true if successful, false otherwise
# Requires the script AudioUtilities
# Requires the script "PokemonMessages"
def beginRecordUI
  code=beginRecord
  case code
  when 0; return true
  when 256+66
    Kernel.pbMessage(_INTL("All recording devices are in use. Recording is not possible now."))
    return false
  when 256+72
    Kernel.pbMessage(_INTL("No supported recording device was found. Recording is not possible."))
    return false
  else
    buffer="\0"*256
    MciErrorString.call(code,buffer,256)
    Kernel.pbMessage(_INTL("Recording failed: {1}",buffer.gsub(/\x00/,"")))
    return false    
  end
end

def pbHideVisibleObjects
  visibleObjects=[]
  ObjectSpace.each_object(Sprite){|o|
     if !o.disposed? && o.visible
       visibleObjects.push(o)
       o.visible=false
     end
  }
  ObjectSpace.each_object(Viewport){|o|
     if !pbDisposed?(o) && o.visible
       visibleObjects.push(o)
       o.visible=false
     end
  }
  ObjectSpace.each_object(Plane){|o|
     if !o.disposed? && o.visible
       visibleObjects.push(o)
       o.visible=false
     end
  }
  ObjectSpace.each_object(Tilemap){|o|
     if !o.disposed? && o.visible
       visibleObjects.push(o)
       o.visible=false
     end
  }
  ObjectSpace.each_object(Window){|o|
     if !o.disposed? && o.visible
       visibleObjects.push(o)
       o.visible=false
     end
  }
  return visibleObjects
end

def pbShowObjects(visibleObjects)
  for o in visibleObjects
    if !pbDisposed?(o)
      o.visible=true
    end
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene=$scene
  $scene=scene
  Graphics.freeze
  oldscene.disposeSpritesets
  visibleObjects=pbHideVisibleObjects
  Graphics.transition(15)
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition(15)
  Graphics.freeze
  oldscene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition(20)
  $scene=oldscene
end

# Gets the value of a variable.
def pbGet(id)
  return 0 if !id || !$game_variables
  return $game_variables[id]
end

# Sets the value of a variable.
def pbSet(id,value)
  if id && id>=0
    $game_variables[id]=value if $game_variables
    $game_map.need_refresh = true if $game_map
  end
end

# Runs a common event and waits until the common event is finished.
# Requires the script "PokemonMessages"
def pbCommonEvent(id)
  return false if id<0
  ce=$data_common_events[id]
  return false if !ce
  celist=ce.list
  interp=Interpreter.new
  interp.setup(celist,0)
  begin
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
  end while interp.running?
  return true
end

def pbExclaim(event,id=EXCLAMATION_ANIMATION_ID,tinting=false)
  if event.is_a?(Array)
    sprite=nil
    done=[]
    for i in event
      if !done.include?(i.id)
        sprite=$scene.spriteset.addUserAnimation(id,i.x,i.y,tinting)
        done.push(i.id)
      end
    end
  else
    sprite=$scene.spriteset.addUserAnimation(id,event.x,event.y,tinting)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
  if !pbFacingEachOther(event,$game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player,event)
  Kernel.pbMoveTowardPlayer(event)
end



################################################################################
# Loads Pokémon/item/trainer graphics
################################################################################
def pbPokemonBitmapFile(species, shiny, back=false)   # Unused
  if shiny
    # Load shiny bitmap
    ret=sprintf("Graphics/Pokemon/%s Shiny/%ss",back ? "Back" : "Front",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(ret)
      ret=sprintf("Graphics/Pokemon/%s Shiny/%03ds",back ? "Back" : "Front",species)
    end
    return ret
  else
    # Load normal bitmap
    ret=sprintf("Graphics/Pokemon/%s/%ss",back ? "Back" : "Front",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(ret)
      ret=sprintf("Graphics/Pokemon/%s/%03ds",back ? "Back" : "Front",species)
    end
    return ret
  end
end

def pbLoadPokemonBitmap(pokemon, back=false)
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back)
end

# Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadPokemonBitmapSpecies(pokemon,species,back=false)
  ret = nil
  if pokemon.isRB?
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.isFemale?),
       pokemon.isShiny?,(pokemon.form rescue 0),(pokemon.isShadow? rescue false)],
       'Remote Boxes')
  elsif pokemon.isEgg?
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.isFemale?),
       pokemon.isShiny?,(pokemon.form rescue 0),(pokemon.isShadow? rescue false)],
       'Eggs')
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.isFemale?),
       pokemon.isShiny?,(pokemon.form rescue 0),(pokemon.isShadow? rescue false),
      (pokemon.color rescue 0)])
    # Alter bitmap if supported
    alterBitmap = (MultipleForms.getFunction(species,"alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each {|bitmap| alterBitmap.call(pokemon,bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

# Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,back=false,egg=false,box=false)
  ret = nil
  if box
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow],'Remote Boxes')
  elsif egg
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow],'Eggs')
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow])
  end
  if bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

# Color of the Pokemon is only used to determine which Unknown Pokemon Sprite will
# used if no sprite has been added yet. It serves no purpose otherwise
# The following are not available for Icon Sprites:
# * New6, TMP Gen9, Color-awareness
def pbCheckPokemonBitmapFiles(params,extra='',suffix='',iconsprite=false)
  species=0
  back=params[1]
  factors=[]
  factors.push([5,params[5],false]) if params[5] && params[5]!=false     # shadow
  factors.push([2,params[2],false]) if params[2] && params[2]!=false     # gender
  factors.push([3,params[3],false]) if params[3] && params[3]!=false     # shiny
  factors.push([4,params[4].to_s,""]) if params[4] && params[4].to_s!="" &&
                                                      params[4].to_s!="0" # form
  factors.push([0,params[0],0])                                        # species
  tshadow=false
  tgender=false
  tshiny=false
  tform=""
  tcolor=""
  # Regular Sprites
  for i in 0...2**factors.length
    for j in 0...factors.length
      newval=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      case factors[j][0]
      when 0   # gender
        species=newval
      when 2   # gender
        tgender=newval
      when 3   # shiny
        tshiny=newval
      when 4   # form
        tform=newval
      when 5   # shadow
        tshadow=newval
      end
    end
    for j in 0...2   # Try using the species' internal name and then its ID number
      next if species==0 && j==0
      speciesText = (j==0) ? getConstantName(PBSpecies,species) : sprintf("%03d",species)
#TEMP
     if ($PokemonSystem.newsix==1 rescue false) && !iconsprite
        bitmapFileName=sprintf("Graphics/Pokemon/_New6/%s%s%s/%s%s%s%s%s",
           extra,
           back ? (extra !="" ? " Back" : "Back") : (extra !="" ? "" : "Front"),
           tshiny ? " Shiny" : "",
           speciesText,
           (tform!="" ? "_"+tform : ""),
           tgender ? "_female" : "",
           tshadow ? "_shadow" : "",
           suffix !="" ? "_"+suffix : "") rescue nil
        ret=pbResolveBitmap(bitmapFileName)
        return ret if ret
     end
  #TEMP
     if ($PokemonSystem.customshiny==1 rescue false) && !iconsprite
        bitmapFileName=sprintf("Graphics/Pokemon/_Customized Shinies/%s%s%s/%s%s%s%s%s",
           extra,
           back ? (extra !="" ? " Back" : "Back") : (extra !="" ? "" : "Front"),
           tshiny ? " Shiny" : "",
           speciesText,
           (tform!="" ? "_"+tform : ""),
           tgender ? "_female" : "",
           tshadow ? "_shadow" : "",
           suffix !="" ? "_"+suffix : "") rescue nil
        ret=pbResolveBitmap(bitmapFileName)
        return ret if ret
     end
      bitmapFileName=sprintf("Graphics/Pokemon/%s%s%s/%s%s%s%s%s",
         extra,
         back ? (extra !="" ? " Back" : "Back") : (extra !="" ? "" : "Front"),
         tshiny ? " Shiny" : "",
         speciesText,
         (tform!="" ? "_"+tform : ""),
         tgender ? "_female" : "",
         tshadow ? "_shadow" : "",
         suffix !="" ? "_"+suffix : "") rescue nil
      ret=pbResolveBitmap(bitmapFileName)
      return ret if ret
  #TEMP
      if !iconsprite
        bitmapFileName=sprintf("Graphics/Pokemon/_TMP Gen9/%s%s%s/%s%s%s%s%s",
           extra,
           back ? (extra !="" ? " Back" : "Back") : (extra !="" ? "" : "Front"),
           tshiny ? " Shiny" : "",
           speciesText,
           (tform!="" ? "_"+tform : ""),
           tgender ? "_female" : "",
           tshadow ? "_shadow" : "",
           suffix !="" ? "_"+suffix : "") rescue nil
        ret=pbResolveBitmap(bitmapFileName)
        return ret if ret
      end
  #TEMP
    end
  end
  return nil
end



def pbLoadPokemonIcon(pokemon)
  return AnimatedBitmap.new(pbPokemonIconFile(pokemon)).deanimate
end

def pbPokemonIconFile(pokemon)
  bitmapFileName=nil
  bitmapFileName=pbCheckPokemonIconFiles([pokemon.species,
                                          (pokemon.isFemale?),
                                          pokemon.isShiny?,
                                          (pokemon.form rescue 0),
                                          (pokemon.isShadow? rescue false)],
                                          pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(params,egg=false)
  species=params[0]
  tgender=params[1]
  tshiny=params[2]
  tform=params[3]
  tshadow=params[4]
  if egg
    return pbCheckPokemonBitmapFiles([species,false,tgender,tshiny,tform,tshadow,0],"Eggs","icon",true)
  else
    return pbCheckPokemonBitmapFiles([species,false,tgender,tshiny,tform,tshadow,0],"Icons","",true)
  end
end

def pbPokemonFootprintFile(pokemon)   # Used by the Pokédex
  return nil if !pokemon
  if pokemon.is_a?(Numeric)
    bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%s",getConstantName(PBSpecies,pokemon)) rescue nil
    bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%03d",pokemon) if !pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%s_%d",getConstantName(PBSpecies,pokemon.species),(pokemon.form rescue 0)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%03d_%d",pokemon.species,(pokemon.form rescue 0)) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%s",getConstantName(PBSpecies,pokemon.species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%03d",pokemon.species)
        end
      end
    end
  end
  return pbResolveBitmap(bitmapFileName)
end

=begin
def pbItemIconFile(item)
  return nil if !item
  bitmapFileName=nil
  if item==0
    bitmapFileName=sprintf("Graphics/Items/back")
  else
    bitmapFileName=sprintf("Graphics/Items/%s",getConstantName(PBItems,item)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Items/%03d",item)
    end
  end
  return bitmapFileName
end
=end
def pbItemIconFile(item)
  return nil if !item
  bitmapFileName = nil
  if item==0
    bitmapFileName = sprintf("Graphics/Items/back")
  elsif item==827 && QQORECHANNEL>0 && QQORECHANNEL<6 # Qora Qore Master
    bitmapFileName = _INTL("Graphics/Items/827_{1}",QQORECHANNEL)
  elsif item==1014 # Pokemon Box
    boxscene = PokemonBoxScene.new
    bitmapFileName = _INTL("Graphics/Items/1014_{1}{2}",boxscene.currentStage(false),boxscene.stageSuffix)
  else
    bitmapFileName = sprintf("Graphics/Items/%s",getConstantName(PBItems,item)) rescue nil
    bitmapFileName = sprintf("Graphics/Items/%03d",item) if !pbResolveBitmap(bitmapFileName)
    if !pbResolveBitmap(bitmapFileName) && pbIsMachine?(item)
      move = pbGetMachine(item)
      type = PBMoveData.new(move).type
      bitmapFileName = sprintf("Graphics/Items/machine_%s",getConstantName(PBTypes,type)) rescue nil
      bitmapFileName = sprintf("Graphics/Items/machine_%03d",type) if !pbResolveBitmap(bitmapFileName)
    end
  end
  bitmapFileName = "Graphics/Items/000" if !pbResolveBitmap(bitmapFileName)
  return bitmapFileName
end


def pbMailBackFile(item)
  return nil if !item
  bitmapFileName=sprintf("Graphics/UI/Mail/mail_%s",getConstantName(PBItems,item)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/UI/Mail/mail_%03d",item)
  end
  return bitmapFileName
end

def pbTrainerCharFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Characters/trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trchar%03d",type)
  end
  return bitmapFileName
end

def pbTrainerCharNameFile(type)
  return nil if !type
  bitmapFileName=sprintf("trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(sprintf("Graphics/Characters/"+bitmapFileName))
    bitmapFileName=sprintf("trchar%03d",type)
  end
  return bitmapFileName
end

def pbTrainerHeadFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/UI/Town Map/mapPlayer%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/UI/Town Map/mapPlayer%03d",type)
  end
  return bitmapFileName
end

def pbPlayerHeadFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/UI/Town Map/mapPlayer%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/UI/Town Map/mapPlayer%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerHeadFile(type)
    end
  end
  return bitmapFileName
end

def pbTrainerSpriteFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Trainers/%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Trainers/%03d",type)
  end
  return bitmapFileName
end

def pbTrainerSpriteBackFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Trainers/%s_back",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Trainers/%03d_back",type)
  end
  return bitmapFileName
end

def pbPlayerSpriteFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/Trainers/%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Trainers/%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerSpriteFile(type)
    end
  end
  return bitmapFileName
end

def pbPlayerSpriteBackFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/Trainers/%s_%d_back",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Trainers/%03d_%d_back",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerSpriteBackFile(type)
    end
  end
  return bitmapFileName
end



################################################################################
# Loads music and sound effects
################################################################################
def pbResolveAudioSE(file)
  return nil if !file
  if RTP.exists?("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
    return RTP.getPath("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
  end
  return nil
end

def pbCryFrameLength(pokemon,pitch=nil)
  return 0 if !pokemon
  pitch=100 if !pitch
  pitch=pitch.to_f/100
  return 0 if pitch<=0
  playtime=0.0
  if pokemon.is_a?(Numeric)
    pkmnwav=pbResolveAudioSE(pbCryFile(pokemon))
    playtime=getPlayTime(pkmnwav) if pkmnwav
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      playtime=pokemon.chatter.time
      pitch=1.0
    else
      pkmnwav=pbResolveAudioSE(pbCryFile(pokemon))
      playtime=getPlayTime(pkmnwav) if pkmnwav
    end 
  end
  playtime/=pitch # sound is lengthened the lower the pitch
  # 4 is added to provide a buffer between sounds
  return (playtime*Graphics.frame_rate).ceil+4
end

def pbPlayCry(pokemon,volume=85,pitch=nil)
  return if !pokemon
  if pokemon.is_a?(Numeric)
    pkmnwav=pbCryFile(pokemon)
    if pkmnwav
      pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,pitch ? pitch : 100)) rescue nil
    end
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      pokemon.chatter.play
    else
      pkmnwav=pbCryFile(pokemon)
      if pkmnwav
        pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,
           pitch ? pitch : (pokemon.hp*25/pokemon.totalhp)+75)) rescue nil
      end
    end
  end
end

def pbCryFile(pokemon)
  return nil if !pokemon
  return pbCryFileClassic(pokemon) if ($PokemonSystem.cryclassic==0 rescue false)
  if pokemon.is_a?(Numeric)
    filename=sprintf("Cries/%s",getConstantName(PBSpecies,pokemon,(pokemon.form rescue 0))) rescue nil
    filename=sprintf("Cries/%03d",pokemon, (pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  elsif !pokemon.isEgg?
    filename=sprintf("Cries/%s_%d",getConstantName(PBSpecies,pokemon.species,(pokemon.form rescue 0))) rescue nil
    filename=sprintf("Cries/%03d_%d",pokemon.species,(pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    if !pbResolveAudioSE(filename)
      filename=sprintf("Cries/%s",getConstantName(PBSpecies,pokemon.species,(pokemon.form rescue 0))) rescue nil
    end
    filename=sprintf("Cries/%03d",pokemon.species,(pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
    filename=sprintf("Cries/000") if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  end
  return nil
end


def pbCryFileClassic(pokemon)
=begin
  return nil if !pokemon
  if pokemon.is_a?(Numeric)
    filename=sprintf("Classic Cries/%s",getConstantName(PBSpecies,pokemon,(pokemon.form rescue 0))) rescue nil
    filename=sprintf("Classic Cries/%03d",pokemon, (pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  elsif !pokemon.isEgg?
    filename=sprintf("Classic Cries/%s_%d",getConstantName(PBSpecies,pokemon.species,(pokemon.form rescue 0))) rescue nil
    filename=sprintf("Classic Cries/%03d_%d",pokemon.species,(pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    if !pbResolveAudioSE(filename)
      filename=sprintf("Classic Cries/%s",getConstantName(PBSpecies,pokemon.species,(pokemon.form rescue 0))) rescue nil
    end
    filename=sprintf("Classic Cries/%03d",pokemon.species,(pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  end
=end
  return nil
end

def pbGetDangerBattleBGM(species,mode=0)
  if ($PokemonSystem.battledif>1 rescue false)
    return ["DangerHard","DangerHard_2"][mode]
  else
    return "Danger"
  end
end

def pbGetWildBattleBGM(species)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret=nil
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapWildBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataWildBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("002-Battle02") if !ret
  return ret
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret=nil
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapWildVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataWildVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("001-Victory01") if !ret
  ret.name="../../Audio/ME/"+ret.name
  return ret
end

def pbPlayTrainerIntroME(trainertype)
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
     if trainertypes[trainertype]
       bgm=trainertypes[trainertype][6]
       if bgm && bgm!=""
         bgm=pbStringToAudioFile(bgm)
         pbMEPlay(bgm)
         return
       end
     end
  }
end

def pbGetTrainerBattleBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  music=nil
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
     if !trainer.is_a?(Array)
       trainerarray=[trainer]
     else
       trainerarray=trainer
     end
     for i in 0...trainerarray.length
       trainertype=trainerarray[i].trainertype
       if trainertypes[trainertype]
         music=trainertypes[trainertype][4]
       end
     end
  }
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("005-Boss01") if !ret
  return ret
end

def pbGetTrainerBattleBGMFromType(trainertype)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  music=nil
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
    trainertypes=Marshal.load(f)
    if trainertypes[trainertype]
      music=trainertypes[trainertype][4]
    end
  }
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("005-Boss01") if !ret
  return ret
end

def pbGetTrainerVictoryME(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  music=nil
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
     if !trainer.is_a?(Array)
       trainerarray=[trainer]
     else
       trainerarray=trainer
     end
     for i in 0...trainerarray.length
       trainertype=trainerarray[i].trainertype
       if trainertypes[trainertype]
         music=trainertypes[trainertype][5]
       end
     end
  }
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("001-Victory01") if !ret
  ret.name="../../Audio/ME/"+ret.name
  return ret
end



################################################################################
# Creating and storing Pokémon
################################################################################
# For demonstration purposes only, not to be used in a real game.
def pbCreatePokemon
  party=[]
  species=[:PIKACHU,:PIDGEOTTO,:KADABRA,:GYARADOS,:DIGLETT,:CHANSEY]
  for id in species
    party.push(getConst(PBSpecies,id)) if hasConst?(PBSpecies,id)
  end
  # Species IDs of the Pokémon to be created
  for i in 0...party.length
    species=party[i]
    # Generate Pokémon with species and level 20
    $Trainer.party[i]=PokeBattle_Pokemon.new(species,20,$Trainer)
    $Trainer.seen[species]=true # Set this species to seen and owned
    $Trainer.owned[species]=true
    pbSeenForm($Trainer.party[i])
  end
  $Trainer.party[1].pbLearnMove(:FLY)
  $Trainer.party[2].pbLearnMove(:FLASH)
  $Trainer.party[2].pbLearnMove(:TELEPORT)
  $Trainer.party[3].pbLearnMove(:SURF)
  $Trainer.party[3].pbLearnMove(:DIVE)
  $Trainer.party[3].pbLearnMove(:WATERFALL)
  $Trainer.party[4].pbLearnMove(:DIG)
  $Trainer.party[4].pbLearnMove(:CUT)
  $Trainer.party[4].pbLearnMove(:HEADBUTT)
  $Trainer.party[4].pbLearnMove(:ROCKSMASH)
  $Trainer.party[5].pbLearnMove(:SOFTBOILED)
  $Trainer.party[5].pbLearnMove(:STRENGTH)
  $Trainer.party[5].pbLearnMove(:SWEETSCENT)
  for i in 0...party.length
    $Trainer.party[i].pbRecordFirstMoves
  end
end

def pbCreatePokemon2
  party=[]
  species=[:JOICON,:JOICON,:JOICON,:JOICON,:JOICON,:JOICON]
  for id in species
    party.push(getConst(PBSpecies,id)) if hasConst?(PBSpecies,id)
  end
  # Species IDs of the Pokémon to be created
  for i in 0...party.length
    species=party[i]
    # Generate Pokémon with species and level 5
    $Trainer.party[i]=PokeBattle_Pokemon.new(species,5,$Trainer)
    $Trainer.seen[species]=true # Set this species to seen and owned
    $Trainer.owned[species]=true
    pbSeenForm($Trainer.party[i])
  end
end


def pbBoxesFull?
  return !$Trainer || ($Trainer.party.length==6 && $PokemonStorage.full?)
end

def pbNickname(pokemon)
  speciesname=PBSpecies.getName(pokemon.species)
  if Kernel.pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?",speciesname))
    helptext=_INTL("{1}'s nickname?",speciesname)
    newname=pbEnterPokemonName(helptext,0,12,"",pokemon)
    pokemon.name=newname if newname!=""
  end
end

def pbStorePokemon(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  # changed added - https://reliccastle.com/resources/176/
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
    swap = false
  else
    if Kernel.pbConfirmMessage(_INTL("Would you like to keep {1} in your party?",pokemon.name))
      pokemon2 = pokemon
      Kernel.pbMessage(_INTL("Please select a Pokémon to swap from your party."))
      pbChoosePokemon(1,2)
      cancel = pbGet(1)
      if cancel >= 0
        swap = true
        pokemon = $Trainer.party[pbGet(1)]
        pbRemovePokemonAt(pbGet(1))
        $Trainer.party[$Trainer.party.length] = pokemon2
      end
    end    
    oldcurbox=$PokemonStorage.currentBox
    storedbox=$PokemonStorage.pbStoreCaught(pokemon)
    curboxname=$PokemonStorage[oldcurbox].name
    boxname=$PokemonStorage[storedbox].name
    pokemon.formTime=nil if pokemon.respond_to?("formTime") && pokemon.formTime
    creator=nil
    creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      Kernel.pbReceiveTrophy(:TBOXFILLER)
      if creator
        Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
      else
        Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
      end
      Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
    else
      if creator
        Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
      else
        Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
      end
      Kernel.pbMessage(_INTL("It was stored in box \"{1}.\"",boxname))
    end
    # changed added - https://reliccastle.com/resources/176/
    if swap
      Kernel.pbMessage(_INTL("{2} was added to {1}'s party!\\se[PokemonGet]",$Trainer.name,pokemon2.name))
    end
    # changed end
  end
end

def pbNicknameAndStore(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbNickname(pokemon)
  pbStorePokemon(pokemon)
end

def pbAddPokemon(pokemon,level=nil,seeform=true)
  return if !pokemon || !$Trainer 
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  speciesname=PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[PokemonGet]\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end

def pbAddToParty(pokemon,level=nil,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  speciesname=PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[PokemonGet]\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddToPartySilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

def pbAddForeignPokemon(pokemon,level=nil,ownerName=nil,nickname=nil,ownerGender=0,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID==$Trainer.id
    pokemon.trainerID=$Trainer.getForeignID
    pokemon.ot=ownerName if ownerName && ownerName!=""
    pokemon.otgender=ownerGender
  end
  # Set nickname
  pokemon.name=nickname[0,10] if nickname && nickname!=""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    Kernel.pbMessage(_INTL("{1} received a Pokémon from {2}.\\se[PokemonGet]\1",$Trainer.name,ownerName))
  else
    Kernel.pbMessage(_INTL("{1} received a Pokémon.\\se[PokemonGet]\1",$Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  return true
end

def pbGenerateEgg(pokemon,text="")
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,EGGINITIALLEVEL,$Trainer)
  end
  # Get egg steps
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,pokemon.species,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  # Set egg's details
  pokemon.name=_INTL("Egg")
  pokemon.eggsteps=eggsteps
  pokemon.obtainText=text
  pokemon.calcStats
  # Add egg to party
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

def pbGenerateRemoteBox(pokemon,text="",form=nil)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,50,$Trainer)
  end
  # Get egg steps
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,pokemon.species,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  # Set egg's details
  pokemon.name=_INTL("Remote Box")
  pokemon.eggsteps=eggsteps
  pokemon.obtainText=text
  if form
    pokemon.form=form
  end
  pokemon.calcStats
  pokemon.makeRB
  # Add egg to party
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end


def pbRemovePokemonAt(index)
  return false if index<0 || !$Trainer || index>=$Trainer.party.length
  haveAble=false
  for i in 0...$Trainer.party.length
    next if i==index
    haveAble=true if $Trainer.party[i].hp>0 && !$Trainer.party[i].isEgg?
  end
  return false if !haveAble
  $Trainer.party.delete_at(index)
  return true
end

def pbSeenForm(poke,gender=0,form=0)
  $Trainer.formseen=[] if !$Trainer.formseen
  $Trainer.formlastseen=[] if !$Trainer.formlastseen
  if poke.is_a?(String) || poke.is_a?(Symbol)
    poke=getID(PBSpecies,poke)
  end
  if poke.is_a?(PokeBattle_Pokemon)
    gender=poke.gender
    form=(poke.form rescue 0)
    species=poke.species
  else
    species=poke
  end
  return if !species || species<=0
  gender=0 if gender>1
  formnames=pbGetMessage(MessageTypes::FormNames,species)
  form=0 if !formnames || formnames==""
  $Trainer.formseen[species]=[[],[]] if !$Trainer.formseen[species]
  $Trainer.formseen[species][gender][form]=true
  $Trainer.formlastseen[species]=[] if !$Trainer.formlastseen[species]
  $Trainer.formlastseen[species]=[gender,form] if $Trainer.formlastseen[species]==[]
end



################################################################################
# Analysing Pokémon
################################################################################
# Heals all Pokémon in the party.
def pbHealAll
  return if !$Trainer
  for i in $Trainer.party
    i.heal
  end
end

# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variableNumber)
  for i in 0...$Trainer.party.length
    p=$Trainer.party[i]
    if p && !p.isEgg? && p.hp>0
      pbSet(variableNumber,i)
      return $Trainer.party[i]
    end
  end
  pbSet(variableNumber,-1)
  return nil
end

# Checks whether the player would still have an unfainted Pokémon if the
# Pokémon given by _pokemonIndex_ were removed from the party.
def pbCheckAble(pokemonIndex)
  for i in 0...$Trainer.party.length
    p=$Trainer.party[i]
    next if i==pokemonIndex
    return true if p && !p.isEgg? && p.hp>0
  end
  return false
end

# Returns true if there are no usable Pokémon in the player's party.
def pbAllFainted
  for i in $Trainer.party
    return false if !i.isEgg? && i.hp>0
  end
  return true
end

def pbBalancedLevel(party)
  return 1 if party.length==0
  # Calculate the mean of all levels
  sum=0
  party.each{|p| sum+=p.level }
  return 1 if sum==0
  average=sum.to_f/party.length.to_f
  # Calculate the standard deviation
  varianceTimesN=0
  for i in 0...party.length
    deviation=party[i].level-average
    varianceTimesN+=deviation*deviation
  end
  # Note: This is the "population" standard deviation calculation, since no
  # sample is being taken
  stdev=Math.sqrt(varianceTimesN/party.length)
  mean=0
  weights=[]
  # Skew weights according to standard deviation
  for i in 0...party.length
    weight=party[i].level.to_f/sum.to_f
    if weight<0.5
      weight-=(stdev/PBExperience::MAXLEVEL.to_f)
      weight=0.001 if weight<=0.001
    else
      weight+=(stdev/PBExperience::MAXLEVEL.to_f)
      weight=0.999 if weight>=0.999
    end
    weights.push(weight)
  end
  weightSum=0
  weights.each{|weight| weightSum+=weight }
  # Calculate the weighted mean, assigning each weight to each level's
  # contribution to the sum
  for i in 0...party.length
    mean+=party[i].level*weights[i]
  end
  mean/=weightSum
  # Round to nearest number
  mean=mean.round
  # Adjust level to minimum
  mean=1 if mean<1
  # Add 2 to the mean to challenge the player
  mean+=2
  # Adjust level to maximum
  mean=PBExperience::MAXLEVEL if mean>PBExperience::MAXLEVEL
  return mean
end

# Returns the Pokémon's size in millimeters.
def pbSize(pokemon)
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,pokemon.species,33)
  baseheight=dexdata.fgetw # Gets the base height in tenths of a meter
  dexdata.close
  hpiv=pokemon.iv[0]&15
  ativ=pokemon.iv[1]&15
  dfiv=pokemon.iv[2]&15
  spiv=pokemon.iv[3]&15
  saiv=pokemon.iv[4]&15
  sdiv=pokemon.iv[5]&15
  m=pokemon.personalID&0xFF
  n=(pokemon.personalID>>8)&0xFF
  s=(((ativ^dfiv)*hpiv)^m)*256+(((saiv^sdiv)*spiv)^n)
  xyz=[]
  if s<10
    xyz=[290,1,0]
  elsif s<110
    xyz=[300,1,10]
  elsif s<310
    xyz=[400,2,110]
  elsif s<710
    xyz=[500,4,310]
  elsif s<2710
    xyz=[600,20,710]
  elsif s<7710
    xyz=[700,50,2710]
  elsif s<17710
    xyz=[800,100,7710]
  elsif s<32710
    xyz=[900,150,17710]
  elsif s<47710
    xyz=[1000,150,32710]
  elsif s<57710
    xyz=[1100,100,47710]
  elsif s<62710
    xyz=[1200,50,57710]
  elsif s<64710
    xyz=[1300,20,62710]
  elsif s<65210
    xyz=[1400,5,64710]
  elsif s<65410
    xyz=[1500,2,65210]
  else
    xyz=[1700,1,65510]
  end
  return (((s-xyz[2])/xyz[1]+xyz[0]).floor*baseheight/10).floor
end

# Returns true if the given species can be legitimately obtained as an egg.
def pbHasEgg?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  evospecies=pbGetEvolvedFormData(species)
  compatspecies=(evospecies && evospecies[0]) ? evospecies[0][2] : species
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,compatspecies,31)
  compat1=dexdata.fgetb   # Get egg group 1 of this species
  compat2=dexdata.fgetb   # Get egg group 2 of this species
  dexdata.close
  return false if isConst?(compat1,PBEggGroups,:Ditto) ||
                  isConst?(compat1,PBEggGroups,:Undiscovered) ||
                  isConst?(compat2,PBEggGroups,:Ditto) ||
                  isConst?(compat2,PBEggGroups,:Undiscovered)
  baby=pbGetBabySpecies(species)
  return true if species==baby   # Is a basic species
  baby=pbGetBabySpecies(species,0,0)
  return true if species==baby   # Is an egg species without incense
  return false
end



################################################################################
# Look through Pokémon in storage, choose a Pokémon in the party
################################################################################
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      poke=$PokemonStorage[i][j]
      yield(poke,i) if poke
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon{|pokemon,box|
     yield(pokemon,box) if !pokemon.isEgg?
  }
end

# Choose a Pokémon/egg from the party.
# Stores result in variable _variableNumber_ and the chosen Pokémon's name in
# variable _nameVarNumber_; result is -1 if no Pokémon was chosen
def pbChoosePokemon(variableNumber,nameVarNumber,ableProc=nil, allowIneligible=false)
  chosen=0
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     screen=PokemonScreen.new(scene,$Trainer.party)
     if ableProc
       chosen=screen.pbChooseAblePokemon(ableProc,allowIneligible)      
     else
       screen.pbStartScene(_INTL("Choose a Pokémon."),false)
       chosen=screen.pbChoosePokemon
       screen.pbEndScene
     end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbChooseNonEggPokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc {|poke|
     !poke.isEgg?
  })
end

def pbChooseAblePokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc {|poke|
     !poke.isEgg? && poke.hp>0
  })
end

def pbChoosePokemonForTrade(variableNumber,nameVarNumber,wanted)
  pbChoosePokemon(variableNumber,nameVarNumber,proc {|poke|
     if wanted.is_a?(String) || wanted.is_a?(Symbol)
       wanted=getID(PBSpecies,wanted)
     end
     return !poke.isEgg? && !(poke.isShadow? rescue false) && poke.species==wanted
  })
end



################################################################################
# Checks through the party for something
################################################################################
def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species==species
  end
  return false
end

def pbHasSpecForm?(species,form) # Case for Eternal 0-6
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species==species && pokemon.form==form
  end
  return false
end

# Returns true if a Pokemon with a Flipnote ball is in the party
def pbHasFlipnoteSpecies?
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.ballused==pbGetBallType(:FLIPNOTEBALL) ||
                   pokemon.ballused==pbGetBallType(:GREATFLIPNOTEBALL) ||
                   pokemon.ballused==pbGetBallType(:ULTRAFLIPNOTEBALL)
  end
  return false
end

# Returns true if all game mascots from Generations VI - VIII are in the party
def pbHasAllLegends?
  return pbHasSpecies?(:XERNEAS) && pbHasSpecies?(:YVELTAL) &&
         pbHasSpecies?(:SOLGALEO) && pbHasSpecies?(:LUNALA) &&
         pbHasSpecies?(:ZACIAN) && pbHasSpecies?(:ZAMAZENTA)
end


def pbHasFatefulSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species==species && pokemon.obtainMode==4
  end
  return false
end

def pbHasType?(type)
  if type.is_a?(String) || type.is_a?(Symbol)
    type=getID(PBTypes,type)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.hasType?(type)
  end
  return false
end

# Checks whether any Pokémon in the party knows the given move, and returns
# the index of that Pokémon, or nil if no Pokémon has that move.
def pbCheckMove(move)
  move=getID(PBMoves,move)
  return nil if !move || move<=0
  for i in $Trainer.party
    next if i.isEgg?
    for j in i.moves
      return i if j.id==move
    end
  end
  return nil
end



################################################################################
# Regional and National Pokédexes
################################################################################
# Gets the Regional Pokédex number of the national species for the specified
# Regional Dex.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region, nationalSpecies)
  if nationalSpecies<=0 || nationalSpecies>PBSpecies.maxValue
    # Return 0 if national species is outside range
    return 0
  end
  pbRgssOpen("Data/regionals.dat","rb"){|f|
     numRegions=f.fgetw
     numDexDatas=f.fgetw
     if region>=0 && region<numRegions
       f.pos=4+region*numDexDatas*2
       f.pos+=nationalSpecies*2
       return f.fgetw
    end
  }
  return 0
end

# Gets the National Pokédex number of the specified species and region.  The
# parameter "region" is zero-based.  For example, if two regions are defined,
# they would each be specified as 0 and 1.
def pbGetNationalNumber(region, regionalSpecies)
  pbRgssOpen("Data/regionals.dat","rb"){|f|
     numRegions=f.fgetw
     numDexDatas=f.fgetw
     if region>=0 && region<numRegions
       f.pos=4+region*numDexDatas*2
       # "i" specifies the national species
       for i in 0...numDexDatas
         regionalNum=f.fgetw
         return i if regionalNum==regionalSpecies
       end
     end
  }
  return 0
end

# Gets an array of all national species within the given Regional Dex, sorted by
# Regional Dex number.  The number of items in the array should be the
# number of species in the Regional Dex plus 1, since index 0 is considered
# to be empty.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbAllRegionalSpecies(region)
  ret=[0]
  pbRgssOpen("Data/regionals.dat","rb"){|f|
     numRegions=f.fgetw
     numDexDatas=f.fgetw
     if region>=0 && region<numRegions
       f.pos=4+region*numDexDatas*2
       # "i" specifies the national species
       for i in 0...numDexDatas
         regionalNum=f.fgetw
         ret[regionalNum]=i if regionalNum!=0
       end
       # Replace unspecified regional
       # numbers with zeros
       for i in 0...ret.length
         ret[i]=0 if !ret[i]
       end
     end
  }
  return ret
end

# Gets the ID number for the current region based on the player's current
# position.  Returns the value of "defaultRegion" (optional, default is -1) if
# no region was defined in the game's metadata.  The ID numbers returned by
# this function depend on the current map's position metadata.
def pbGetCurrentRegion(defaultRegion=-1)
  mappos=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)
  if !mappos
    return defaultRegion # No region defined
  else
    return mappos[0]
  end
end

# Decides which Dex lists are able to be viewed (i.e. they are unlocked and have
# at least 1 seen species in them), and saves all viable dex region numbers
# (National Dex comes after regional dexes).
# If the Dex list shown depends on the player's location, this just decides if
# a species in the current region has been seen - doesn't look at other regions.
# Here, just used to decide whether to show the Pokédex in the Pause menu.
def pbSetViableDexes
  $PokemonGlobal.pokedexViable=[]
  if DEXDEPENDSONLOCATION
    region=pbGetCurrentRegion
    region=-1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
    if $Trainer.pokedexSeen(region)>0
      $PokemonGlobal.pokedexViable[0]=region
    end
  else
    numDexes=$PokemonGlobal.pokedexUnlocked.length
    case numDexes
    when 1          # National Dex only
      if $PokemonGlobal.pokedexUnlocked[0]
        if $Trainer.pokedexSeen>0
          $PokemonGlobal.pokedexViable.push(0)
        end
      end
    else            # Regional dexes + National Dex
      for i in 0...numDexes
        regionToCheck=(i==numDexes-1) ? -1 : i
        if $PokemonGlobal.pokedexUnlocked[i]
          if $Trainer.pokedexSeen(regionToCheck)>0
            $PokemonGlobal.pokedexViable.push(i)
          end
        end
      end
    end
  end
end

# Unlocks a Dex list.  The National Dex is -1 here (or nil argument).
def pbUnlockDex(dex=-1)
  index=dex
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index<0
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index>$PokemonGlobal.pokedexUnlocked.length-1
  $PokemonGlobal.pokedexUnlocked[index]=true
end

# Locks a Dex list.  The National Dex is -1 here (or nil argument).
def pbLockDex(dex=-1)
  index=dex
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index<0
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index>$PokemonGlobal.pokedexUnlocked.length-1
  $PokemonGlobal.pokedexUnlocked[index]=false
end



################################################################################
# Other utilities
################################################################################
def pbTextEntry(helptext,minlength,maxlength,variableNumber)
  $game_variables[variableNumber]=pbEnterText(helptext,minlength,maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move,movelist=nil)
  ret=[]
  for i in 0...6
    ret[i]=nil
    next if i>=$Trainer.party.length
    found=false
    for j in 0...4
      if !$Trainer.party[i].isEgg? && $Trainer.party[i].moves[j].id==move
        ret[i]=_INTL("LEARNED")
        found=true
      end
    end
    next if found
    species=$Trainer.party[i].species
    if !$Trainer.party[i].isEgg? && movelist && movelist.any?{|j| j==species }
      # Checked data from movelist
      ret[i]=_INTL("ABLE")
    elsif !$Trainer.party[i].isEgg? && $Trainer.party[i].isCompatibleWithMove?(move)
      # Checked data from PBS/tm.txt
      ret[i]=_INTL("ABLE")
    else
      ret[i]=_INTL("NOT ABLE")
    end
  end
  return ret
end

def pbMoveTutorChoose(move,movelist=nil,bymachine=false)
  ret=false
  if move.is_a?(String) || move.is_a?(Symbol)
    move=getID(PBMoves,move)
  end
  if movelist!=nil && movelist.is_a?(Array)
    for i in 0...movelist.length
      if movelist[i].is_a?(String) || movelist[i].is_a?(Symbol)
        movelist[i]=getID(PBSpecies,movelist[i])
      end
    end
  end
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     movename=PBMoves.getName(move)
     screen=PokemonScreen.new(scene,$Trainer.party)
     annot=pbMoveTutorAnnotations(move,movelist)
     screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
     loop do
       chosen=screen.pbChoosePokemon
       if chosen>=0
         pokemon=$Trainer.party[chosen]
         if pokemon.isEgg?
           Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
         elsif (pokemon.isShadow? rescue false)
           Kernel.pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
         elsif movelist && !movelist.any?{|j| j==pokemon.species }
           Kernel.pbMessage(_INTL("{1} and {2} are not compatible.",pokemon.name,movename))
           Kernel.pbMessage(_INTL("{1} can't be learned.",movename))
         elsif !pokemon.isCompatibleWithMove?(move)
           Kernel.pbMessage(_INTL("{1} and {2} are not compatible.",pokemon.name,movename))
           Kernel.pbMessage(_INTL("{1} can't be learned.",movename))
         else
           if pbLearnMove(pokemon,move,false,bymachine)
             ret=true
             break
           end
         end
       else
         break
       end  
     end
     screen.pbEndScene
  }
  return ret # Returns whether the move was learned by a Pokemon
end

def pbChooseMove(pokemon,variableNumber,nameVarNumber)
  return if !pokemon
  ret=-1
  pbFadeOutIn(99999){
     scene=PokemonSummaryScene.new
     screen=PokemonSummary.new(scene)
     ret=screen.pbStartForgetScreen([pokemon],0,0)
  }
  $game_variables[variableNumber]=ret
  if ret>=0
    $game_variables[nameVarNumber]=PBMoves.getName(pokemon.moves[ret].id)
  else
    $game_variables[nameVarNumber]=""
  end
  $game_map.need_refresh = true if $game_map
end

alias pbChooseMoveAdv pbChooseMove # Avoid conflicts with the pbChooseMove from party screen

# Opens the Pokémon screen
def pbPokemonScreen
  return if !$Trainer
  sscene=PokemonScreen_Scene.new
  sscreen=PokemonScreen.new(sscene,$Trainer.party)
  pbFadeOutIn(99999) { sscreen.pbPokemonScreen }
end

def pbSaveScreen
  ret=false
  scene=PokemonSaveScene.new
  screen=PokemonSave.new(scene)
  pbFadeOutIn(99999) { 
    ret=screen.pbSaveScreen
  }
  return ret
end

def pbConvertItemToItem(variable,array)
  item=pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    if isConst?(item,PBItems,array[2*i])
      pbSet(variable,getID(PBItems,array[2*i+1]))
      return
    end
  end
end

def pbConvertItemToPokemon(variable,array)
  item=pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    if isConst?(item,PBItems,array[2*i])
      pbSet(variable,getID(PBSpecies,array[2*i+1]))
      return
    end
  end
end




class PokemonGlobalMetadata
  attr_accessor :trainerRecording
end



def pbRecordTrainer
  wave=pbRecord(nil,10)
  if wave
    $PokemonGlobal.trainerRecording=wave
    return true
  end
  return false
end