class PokemonDataCopy
  attr_accessor :dataOldHash
  attr_accessor :dataNewHash
  attr_accessor :dataTime
  attr_accessor :data

  def crc32(x)
    return Zlib::crc32(x)
  end

  def readfile(filename)
    File.open(filename, "rb"){|f|
       f.read
    }
  end

  def writefile(str,filename)
    File.open(filename, "wb"){|f|
       f.write(str)
    }
  end

  def filetime(filename)
    File.open(filename, "r"){|f|
       f.mtime
    }
  end

  def initialize(data,datasave)
    @datafile=data
    @datasave=datasave
    @data=readfile(@datafile)
    @dataOldHash=crc32(@data)
    @dataTime=filetime(@datafile)
  end

  def changed?
    ts=readfile(@datafile)
    tsDate=filetime(@datafile)
    tsHash=crc32(ts)
    return tsHash!=@dataNewHash && tsHash!=@dataOldHash && tsDate > @dataTime
  end

  def save(newtilesets)
    newdata=Marshal.dump(newtilesets)
    if !changed?
      @data=newdata
      @dataNewHash=crc32(newdata)
      writefile(newdata,@datafile)
    else
      @dataOldHash=crc32(@data)
      @dataNewHash=crc32(newdata)
      @dataTime=filetime(@datafile)
      @data=newdata
      writefile(newdata,@datafile)
    end
    save_data(self,@datasave)
  end
end



class PokemonDataWrapper
  attr_reader :data

  def initialize(file,savefile,prompt)
    @savefile=savefile
    @file=file
    if pbRgssExists?(@savefile)
      @ts=load_data(@savefile)
      if !@ts.changed? || prompt.call==true
        @data=Marshal.load(StringInput.new(@ts.data))
      else
        @ts=PokemonDataCopy.new(@file,@savefile)
        @data=load_data(@file)
      end
    else
      @ts=PokemonDataCopy.new(@file,@savefile)
      @data=load_data(@file)
    end
  end

  def save
    @ts.save(@data)
  end
end



def pbMapTree
  mapinfos=pbLoadRxData("Data/MapInfos")
  maplevels=[]
  retarray=[]
  for i in mapinfos.keys
    info=mapinfos[i]
    level=-1
    while info
      info=mapinfos[info.parent_id]
      level+=1
    end
    if level>=0
      info=mapinfos[i]
      maplevels.push([i,level,info.parent_id,info.order])
    end
  end
  maplevels.sort!{|a,b|
     next a[1]<=>b[1] if a[1]!=b[1] # level
     next a[2]<=>b[2] if a[2]!=b[2] # parent ID
     next a[3]<=>b[3] # order
  }
  stack=[]
  stack.push(0,0)
  while stack.length>0
    parent = stack[stack.length-1]
    index = stack[stack.length-2]
    if index>=maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel=maplevels[index]
    stack[stack.length-2]+=1
    if maplevel[2]!=parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0],mapinfos[maplevel[0]].name,maplevel[1]])
    for i in index+1...maplevels.length
      if maplevels[i][2]==maplevel[0]
        stack.push(i)
        stack.push(maplevel[0])
        break
      end
    end
  end
  return retarray
end

def pbExtractText
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("All text in the game was extracted and saved to intl.txt.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("After translating, choose \"Compile Text.\""))
  Kernel.pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Successfully compiled text and saved it to intl.dat."))
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the LANGUAGES array in the Settings script."))
    rescue RuntimeError
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Failed to compile text:  {1}",$!.message))
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
end



class CommandList
  def initialize
    @commandHash={}
    @commands=[]
  end

  def getCommand(index)
    for key in @commandHash.keys
      return key if @commandHash[key]==index
    end
    return nil
  end

  def add(key,value)
    @commandHash[key]=@commands.length
    @commands.push(value)
  end

  def list
    @commands.clone
  end
end



def pbDefaultMap()
  return $game_map.map_id if $game_map
  return $data_system.edit_map_id if $data_system
  return 0
end

def pbWarpToMap()
  mapid=pbListScreen(_INTL("Warp to Map"),MapLister.new(pbDefaultMap()))
  if mapid>0
    map=Game_Map.new
    map.setup(mapid)
    success=false
    x=0
    y=0
    100.times do
      x=rand(map.width)
      y=rand(map.height)
      next if !map.passableStrict?(x,y,$game_player)
      blocked=false
      for event in map.events.values
        if event.x == x && event.y == y && !event.through
          blocked=true if self != $game_player || event.character_name != ""
        end
      end
      next if blocked
      success=true
      break
    end
    if !success
      x=rand(map.width)
      y=rand(map.height)
    end
    return [mapid,x,y]
  end
  return nil
end

def pbDebugMenu(inloadscreen=false,mode=0)
  if inloadscreen
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
      addBackgroundOrColoredPlane(sprites,"title",getDarkModeFolder+"/Settings/bg",
         Color.new(12,12,12),viewport)
    title=["Diagnostic Tools","Field Options","Battle Options","Pokémon Options","Item Options","Player Options","PBS Editors","Other Editors","Files Options"][mode]
    sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
       2,-18,576,64,viewport)      
    sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].windowskin=nil
  commands=CommandList.new
  if mode==0 # Diagnostic Tools
    commands.add("corendo",_INTL("Game ROM Initialization Check")) # For Compatibility with Corendo
    commands.add("corendo2",_INTL("Control Configuration Check")) # For Compatibility with Corendo
    commands.add("corendo3",_INTL("Game RAM Initialization Check")) # For Compatibility with Corendo
    commands.add("corendo4",_INTL("Audio Initialization Check")) # For Compatibility with Corendo
  end
  if mode==1  # Field Options
    commands.add("warp",_INTL("Warp to Map")) if !inloadscreen
    commands.add("usepc",_INTL("Use PC")) if !inloadscreen
    commands.add("switches",_INTL("Switches")) if !inloadscreen
    commands.add("variables",_INTL("Variables")) if !inloadscreen
    commands.add("refreshmap",_INTL("Refresh Map")) if !inloadscreen
    commands.add("daycare",_INTL("Day Care Options...")) if !inloadscreen
    commands.add("games",_INTL("Mini Games")) if !inloadscreen # Κορα Κορε addition
  end
  if mode==2  # Battle Options
    commands.add("testwildbattle",_INTL("Test Wild Battle")) if !inloadscreen
    commands.add("testdoublewildbattle",_INTL("Test Double Wild Battle")) if !inloadscreen
    commands.add("testtrainerbattle",_INTL("Test Trainer Battle")) if !inloadscreen
    commands.add("testdoubletrainerbattle",_INTL("Test Double Trainer Battle")) if !inloadscreen
    commands.add("roamerstatus",_INTL("Roaming Pokémon Status")) if !inloadscreen
    commands.add("roam",_INTL("Advance Roaming")) if !inloadscreen
    commands.add("resettrainers",_INTL("Reset Trainers")) if !inloadscreen
    commands.add("togglelogging",_INTL("Toggle Battle Logging"))
    commands.add("godhandmode",_INTL("Use Intensive Battle Difficulty"))
  end
  if mode==3 # Pokémon Options
    commands.add("healparty",_INTL("Heal Party")) if !inloadscreen
    commands.add("addpokemon",_INTL("Add Pokémon")) if !inloadscreen
    commands.add("fillboxes",_INTL("Fill Storage Boxes")) if !inloadscreen
    commands.add("clearboxes",_INTL("Clear Storage Boxes")) if !inloadscreen
    commands.add("demoparty",_INTL("Give Demo Party")) if !inloadscreen
    commands.add("demoparty2",_INTL("Give Joicon Party")) if !inloadscreen
    commands.add("quickhatch",_INTL("Quick Hatch")) if !inloadscreen
    commands.add("relicstone",_INTL("Relic Stone")) if !inloadscreen
    commands.add("purifychamber",_INTL("Purify Chamber")) if !inloadscreen
  end
  if mode==4 # Item Options
    commands.add("additem",_INTL("Add Item")) if !inloadscreen
    commands.add("fillbag",_INTL("Fill Bag")) if !inloadscreen
    commands.add("clearbag",_INTL("Empty Bag")) if !inloadscreen
  end
  if mode==5 # Player Options
    commands.add("setmoney",_INTL("Set Money")) if !inloadscreen
    commands.add("setcoins",_INTL("Set Coins")) if !inloadscreen
    commands.add("setbadges",_INTL("Set Badges")) if !inloadscreen
    commands.add("toggleshoes",_INTL("Toggle Running Shoes Ownership")) if !inloadscreen
    commands.add("togglepokedex",_INTL("Toggle Pokédex Ownership")) if !inloadscreen
    commands.add("dexlists",_INTL("Dex List Accessibility")) if !inloadscreen
    commands.add("togglepokegear",_INTL("Toggle Pokégear Ownership")) if !inloadscreen
    commands.add("readyrematches",_INTL("Ready Phone Rematches")) if !inloadscreen
    commands.add("setplayer",_INTL("Set Player Character")) if !inloadscreen
    commands.add("changeoutfit",_INTL("Change Player Outfit")) if !inloadscreen
    commands.add("renameplayer",_INTL("Rename Player")) if !inloadscreen
    commands.add("randomid",_INTL("Randomise Player's ID")) if !inloadscreen
  end
  if mode==6 # PBS Editors
    commands.add("mapconnections",_INTL("Map Connections"))
    commands.add("setencounters",_INTL("Set Encounters")) 
    commands.add("edittrainers",_INTL("Edit Trainers")) # Taken from Editor
    commands.add("trainertypes",_INTL("Edit Trainer Types"))
    commands.add("setmetadata",_INTL("Set Metadata")) 
    commands.add("edititems",_INTL("Edit Items")) # Taken from Editor 
    commands.add("editpokemon",_INTL("Edit Pokémon")) # Taken from Editor 
    commands.add("spriteposition",_INTL("Reposition Sprites"))  if !inloadscreen # Taken from Editor 
    commands.add("spriteposition2",_INTL("Auto-Position All Sprites")) # Taken from Editor 
    commands.add("editdexes",_INTL("Edit Regional Dexes")) # Taken from Editor 
  end
  if mode==7 # Other Editors
    commands.add("animeditor",_INTL("Animation Editor"))
    commands.add("animorganizer",_INTL("Animation Organizer"))
    commands.add("terraintags",_INTL("Set Terrain Tags"))
    commands.add("debugconsole",_INTL("Debug Console"))
  end
  if mode==8 # Files Options
    commands.add("compiledata",_INTL("Compile Data"))
    commands.add("extracttext",_INTL("Extract Text"))
    commands.add("compiletext",_INTL("Compile Text"))
    commands.add("mysterygift",_INTL("Manage Mystery Gifts")) if !inloadscreen
  end
  sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.width=Graphics.width
  cmdwindow.height=Graphics.height - 32 # if cmdwindow.height>(Graphics.height - 32)
  cmdwindow.x=0
  cmdwindow.y=32
  cmdwindow.visible=true
  pbFadeInAndShow(sprites)
  ret=-1
  loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd=="corendo" # Compat mode with Corendo
      pbFadeOutIn(99999) { pbDebugScreen2(0) }
    elsif cmd=="corendo2" # Compat mode with Corendo
      pbFadeOutIn(99999) { pbDebugScreen2(1) }
    elsif cmd=="corendo3" # Compat mode with Corendo
      pbFadeOutIn(99999) { pbDebugScreen2(2) }
    elsif cmd=="corendo4" # Compat mode with Corendo
      pbFadeOutIn(99999) { pbDebugScreen2(3) }
    elsif cmd=="switches"
      pbFadeOutIn(99999) { pbDebugScreen(0) }
    elsif cmd=="variables"
      pbFadeOutIn(99999) { pbDebugScreen(1) }
    elsif cmd=="refreshmap"
      $game_map.need_refresh = true
      Kernel.pbMessage(_INTL("The map will refresh."))
    elsif cmd=="warp"
      map=pbWarpToMap()
      if map
        pbFadeOutAndHide(sprites)
        pbDisposeSpriteHash(sprites)
        viewport.dispose
        if $scene.is_a?(Scene_Map)
          $game_temp.player_new_map_id=map[0]
          $game_temp.player_new_x=map[1]
          $game_temp.player_new_y=map[2]
          $game_temp.player_new_direction=2
          $scene.transfer_player
          $game_map.refresh
        else
          Kernel.pbCancelVehicles
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1],map[2])
          $game_player.turn_down
          $game_map.update
          $game_map.autoplay
          $game_map.refresh
        end
        return
      end
    elsif cmd=="healparty"
      for i in $Trainer.party
        i.heal
      end
      Kernel.pbMessage(_INTL("Your Pokémon were healed."))
    elsif cmd=="additem"
      item=pbListScreen(_INTL("Add Item"),ItemLister.new(0))
      if item && item>0
        params=ChooseNumberParams.new
        params.setRange(1,BAGMAXPERSLOT)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty=Kernel.pbMessageChooseNumber(
           _INTL("Choose the number of items."),params
        )
        if qty>0
          if qty==1
            Kernel.pbReceiveItem(item)
          else
            Kernel.pbMessage(_INTL("The item was added."))
            $PokemonBag.pbStoreItem(item,qty)
          end
        end
      end
    elsif cmd=="fillbag"
      params=ChooseNumberParams.new
      params.setRange(1,BAGMAXPERSLOT)
      params.setInitialValue(1)
      params.setCancelValue(0)
      qty=Kernel.pbMessageChooseNumber(
         _INTL("Choose the number of items."),params
      )
      if qty>0
        itemconsts=[]
        for i in PBItems.constants
          itemconsts.push(PBItems.const_get(i))
        end
        itemconsts.sort!{|a,b| a<=>b}
        for i in itemconsts
          $PokemonBag.pbStoreItem(i,qty)
        end
        Kernel.pbMessage(_INTL("The Bag was filled with {1} of each item.",qty))
      end
    elsif cmd=="clearbag"
      $PokemonBag.clear
      Kernel.pbMessage(_INTL("The Bag was cleared."))
    elsif cmd=="addpokemon"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          pbAddPokemon(species,level)
        end
      end
    elsif cmd=="fillboxes"
      $Trainer.formseen=[] if !$Trainer.formseen
      $Trainer.formlastseen=[] if !$Trainer.formlastseen
      added=0; completed=true
      commands2=[]
      for j in 1..PBSpecies.maxValue
        commands2.push(j)
      end
      commands2=getQoreDexList(commands2)
      for i in 1..PBSpecies.maxValue
        if added>=STORAGEBOXES*30
          completed=false; break
        end
        cname=getConstantName(PBSpecies,i) rescue nil
        next if !cname
        pkmn=PokeBattle_Pokemon.new(i,50,$Trainer)
# QQC Edit
    fdexno = commands2.index(i)
# QQC End
        $PokemonStorage[(fdexno)/$PokemonStorage.maxPokemon(0),
                        (fdexno)%$PokemonStorage.maxPokemon(0)]=pkmn
        $Trainer.seen[i]=true
        $Trainer.owned[i]=true
        $Trainer.formlastseen[i]=[] if !$Trainer.formlastseen[i]
        $Trainer.formlastseen[i]=[0,0] if $Trainer.formlastseen[i]==[]
        $Trainer.formseen[i]=[[],[]] if !$Trainer.formseen[i]
        for j in 0..63
          $Trainer.formseen[i][0][j]=true
          $Trainer.formseen[i][1][j]=true
        end
        added+=1
      end
      Kernel.pbMessage(_INTL("Boxes were filled with one Pokémon of each species."))
      if !completed
        Kernel.pbMessage(_INTL("Note: The number of storage spaces ({1} boxes of 30) is less than the number of species.",STORAGEBOXES))
      end
    elsif cmd=="clearboxes"
      for i in 0...$PokemonStorage.maxBoxes
        for j in 0...$PokemonStorage.maxPokemon(i)
          $PokemonStorage[i,j]=nil
        end
      end
      Kernel.pbMessage(_INTL("The Boxes were cleared."))
    elsif cmd=="usepc"
      pbPokeCenterPC
    elsif cmd=="setplayer"
        Kernel.pbMessage(_INTL("This command no longer works. You must go to your info and Press the X button in order to switch between versions"))
=begin
      limit=0
      for i in 0...8
        meta=pbGetMetadata(0,MetadataPlayerA+i)
        if !meta
          limit=i
          break
        end
      end
      if limit<=1
        Kernel.pbMessage(_INTL("There is only one player defined."))
      else
        params=ChooseNumberParams.new
        params.setRange(0,limit-1)
        params.setDefaultValue($PokemonGlobal.playerID)
        newid=Kernel.pbMessageChooseNumber(
           _INTL("Choose the new player character."),params)
        if newid!=$PokemonGlobal.playerID
          pbChangePlayer(newid)
          Kernel.pbMessage(_INTL("The player character was changed."))
        end
      end
=end
    elsif cmd=="renameplayer"
      trname=pbEnterPlayerName("Your name?",0,12,$Trainer.name)
      if trname==""
        trainertype=pbGetPlayerTrainerType
        gender=pbGetTrainerTypeGender(trainertype) 
        trname=pbSuggestTrainerName(gender)
      end
      $Trainer.name=trname
      Kernel.pbMessage(_INTL("The player's name was changed to {1}.",$Trainer.name))
    elsif cmd=="randomid"
      $Trainer.id=rand(256)
      $Trainer.id|=rand(256)<<8
      $Trainer.id|=rand(256)<<16
      $Trainer.id|=rand(256)<<24
      Kernel.pbMessage(_INTL("The player's ID was changed to {1} ({2}).",$Trainer.publicID,$Trainer.id))
    elsif cmd=="changeoutfit"
      oldoutfit=$Trainer.outfit
      params=ChooseNumberParams.new
      params.setRange(0,99)
      params.setDefaultValue(oldoutfit)
      $Trainer.outfit=Kernel.pbMessageChooseNumber(_INTL("Set the player's outfit."),params)
      Kernel.pbMessage(_INTL("Player's outfit was changed.")) if $Trainer.outfit!=oldoutfit
    elsif cmd=="setmoney"
      params=ChooseNumberParams.new
      params.setRange(0,MAXMONEY)
      params.setDefaultValue($Trainer.money)
      $Trainer.money=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's money."),params)
      Kernel.pbMessage(_INTL("You now have ${1}.",$Trainer.money.to_s_formatted))
    elsif cmd=="setcoins"
      params=ChooseNumberParams.new
      params.setRange(0,MAXCOINS)
      params.setDefaultValue($PokemonGlobal.coins)
      $PokemonGlobal.coins=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's Coin amount."),params)
      Kernel.pbMessage(_INTL("You now have {1} Coins.",$PokemonGlobal.coins.to_s_formatted))
    elsif cmd=="setbadges"
      badgecmd=0
      loop do
        badgecmds=[]
        for i in 0...32
          badgecmds.push(_INTL("{1} Badge {2}",$Trainer.badges[i] ? "[Y]" : "[  ]",i+1))
        end
        badgecmd=Kernel.pbShowCommands(nil,badgecmds,-1,badgecmd)
        break if badgecmd<0
        $Trainer.badges[badgecmd]=!$Trainer.badges[badgecmd]
      end
    elsif cmd=="demoparty"
      pbCreatePokemon
      Kernel.pbMessage(_INTL("Filled party with demo Pokémon."))
    elsif cmd=="demoparty2"
      pbCreatePokemon2
      Kernel.pbMessage(_INTL("Filled party with 6 Joicons."))
    elsif cmd=="toggleshoes"
      $PokemonGlobal.runningShoes=!$PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Gave Running Shoes.")) if $PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Lost Running Shoes.")) if !$PokemonGlobal.runningShoes
    elsif cmd=="togglepokegear"
      $Trainer.pokegear=!$Trainer.pokegear
      Kernel.pbMessage(_INTL("Gave Pokégear.")) if $Trainer.pokegear
      Kernel.pbMessage(_INTL("Lost Pokégear.")) if !$Trainer.pokegear
    elsif cmd=="togglepokedex"
      $Trainer.pokedex=!$Trainer.pokedex
      Kernel.pbMessage(_INTL("Gave Pokédex.")) if $Trainer.pokedex
      Kernel.pbMessage(_INTL("Lost Pokédex.")) if !$Trainer.pokedex
    elsif cmd=="dexlists"
      dexescmd=0
      loop do
        dexescmds=[]
        d=pbDexNames
        for i in 0...d.length
          name=d[i]
          name=name[0] if name.is_a?(Array)
          dexindex=i
          unlocked=$PokemonGlobal.pokedexUnlocked[dexindex]
          dexescmds.push(_INTL("{1} {2}",unlocked ? "[Y]" : "[  ]",name))
        end
        dexescmd=Kernel.pbShowCommands(nil,dexescmds,-1,dexescmd)
        break if dexescmd<0
        dexindex=dexescmd
        if $PokemonGlobal.pokedexUnlocked[dexindex]
          pbLockDex(dexindex)
        else
          pbUnlockDex(dexindex)
        end
      end
    elsif cmd=="readyrematches"
      if !$PokemonGlobal.phoneNumbers || $PokemonGlobal.phoneNumbers.length==0
        Kernel.pbMessage(_INTL("There are no trainers in the Phone."))
      else
        for i in $PokemonGlobal.phoneNumbers
          if i.length==8 # A trainer with an event
            i[4]=2
            pbSetReadyToBattle(i)
          end
        end
        Kernel.pbMessage(_INTL("All trainers in the Phone are now ready to rebattle."))
      end
    elsif cmd=="mysterygift"
      pbManageMysteryGifts
    elsif cmd=="daycare"
      daycarecmd=0
      loop do
        daycarecmds=[
           _INTL("Summary"),
           _INTL("Deposit Pokemon"),
           _INTL("Withdraw Pokemon"),
           _INTL("Generate egg"),
           _INTL("Collect egg"),
           _INTL("Dispose egg")
        ]
        daycarecmd=Kernel.pbShowCommands(nil,daycarecmds,-1,daycarecmd)
        break if daycarecmd<0
        case daycarecmd
        when 0 # Summary
          if $PokemonGlobal.daycare
            num=pbDayCareDeposited
            Kernel.pbMessage(_INTL("{1} Pokemon are in the Day Care.",num))
            if num>0
              txt=""
              for i in 0...num
                next if !$PokemonGlobal.daycare[i][0]
                pkmn=$PokemonGlobal.daycare[i][0]
                initlevel=$PokemonGlobal.daycare[i][1]
                gender=[_INTL("\\b<fn=Power Clear>♂</fn>\\c[0]"),_INTL("\\r<fn=Power Clear>♀</fn>\\c[0]"),_INTL("genderless")][pkmn.gender]
                txt+=_INTL("{1}) {2} ({3}), Lv.{4} (deposited at Lv.{5})",
                   i,pkmn.name,gender,pkmn.level,initlevel)
                txt+="\n" if i<num-1
              end
              Kernel.pbMessage(txt)
            end
            if $PokemonGlobal.daycareEgg==1
              Kernel.pbMessage(_INTL("An egg is waiting to be picked up."))
            elsif pbDayCareDeposited==2
              if pbDayCareGetCompat==0
                Kernel.pbMessage(_INTL("The deposited Pokemon can't breed."))
              else
                Kernel.pbMessage(_INTL("The deposited Pokemon can breed."))
              end
            end
          end
        when 1 # Deposit Pokemon
          if pbEggGenerated?
            Kernel.pbMessage(_INTL("Egg is available, can't deposit Pokemon."))
          elsif pbDayCareDeposited==2
            Kernel.pbMessage(_INTL("Two Pokemon are deposited already."))
          elsif $Trainer.party.length==0
            Kernel.pbMessage(_INTL("Party is empty, can't desposit Pokemon."))
          else
            pbChooseNonEggPokemon(1,3)
            if pbGet(1)>=0
              pbDayCareDeposit(pbGet(1))
              Kernel.pbMessage(_INTL("Deposited {1}.",pbGet(3)))
            end
          end
        when 2 # Withdraw Pokemon
          if pbEggGenerated?
            Kernel.pbMessage(_INTL("Egg is available, can't withdraw Pokemon."))
          elsif pbDayCareDeposited==0
            Kernel.pbMessage(_INTL("No Pokemon are in the Day Care."))
          elsif $Trainer.party.length>=6
            Kernel.pbMessage(_INTL("Party is full, can't withdraw Pokemon."))
          else
            pbDayCareChoose(_INTL("Which one do you want back?"),1)
            if pbGet(1)>=0
              pbDayCareGetDeposited(pbGet(1),3,4)
              pbDayCareWithdraw(pbGet(1))
              Kernel.pbMessage(_INTL("Withdrew {1}.",pbGet(3)))
            end
          end
        when 3 # Generate egg
          if $PokemonGlobal.daycareEgg==1
            Kernel.pbMessage(_INTL("An egg is already waiting."))
          elsif pbDayCareDeposited!=2
            Kernel.pbMessage(_INTL("There aren't 2 Pokemon in the Day Care."))
          elsif pbDayCareGetCompat==0
            Kernel.pbMessage(_INTL("The Pokemon in the Day Care can't breed."))
          else
            $PokemonGlobal.daycareEgg=1
            Kernel.pbMessage(_INTL("An egg is now waiting in the Day Care."))
          end
        when 4 # Collect egg
          if $PokemonGlobal.daycareEgg!=1
            Kernel.pbMessage(_INTL("There is no egg available."))
          elsif $Trainer.party.length>=6
            Kernel.pbMessage(_INTL("Party is full, can't collect the egg."))
          else
            pbDayCareGenerateEgg
            $PokemonGlobal.daycareEgg=0
            $PokemonGlobal.daycareEggSteps=0
            Kernel.pbMessage(_INTL("Collected the {1} egg.",
               PBSpecies.getName($Trainer.party[$Trainer.party.length-1].species)))
          end
        when 5 # Dispose egg
          if $PokemonGlobal.daycareEgg!=1
            Kernel.pbMessage(_INTL("There is no egg available."))
          else
            $PokemonGlobal.daycareEgg=0
            $PokemonGlobal.daycareEggSteps=0
            Kernel.pbMessage(_INTL("Disposed of the egg."))
          end
        end
      end
    elsif cmd=="quickhatch"
      for pokemon in $Trainer.party
        pokemon.eggsteps=1 if pokemon.isEgg?
      end
      Kernel.pbMessage(_INTL("All eggs on your party now require one step to hatch."))
    elsif cmd=="roamerstatus"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        text="\\l[8]"
        for i in 0...RoamingSpecies.length
          poke=RoamingSpecies[i]
          if $game_switches[poke[2]]
            status=$PokemonGlobal.roamPokemon[i]
            if status==true
              if $PokemonGlobal.roamPokemonCaught[i]
                text+=_INTL("{1} (Lv.{2}) caught.",
                   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1])
              else
                text+=_INTL("{1} (Lv.{2}) defeated.",
                   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1])
              end
            else
              curmap=$PokemonGlobal.roamPosition[i]
              if curmap
                mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
                text+=_INTL("{1} (Lv.{2}) roaming on map {3} ({4}){5}",
                   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],curmap,
                   mapinfos[curmap].name,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
              else
                text+=_INTL("{1} (Lv.{2}) roaming (map not set).",
                   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1])
              end
            end
          else
            text+=_INTL("{1} (Lv.{2}) not roaming (switch {3} is off).",
               PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
          end
          text+="\n" if i<RoamingSpecies.length-1
        end
        Kernel.pbMessage(text)
      end
    elsif cmd=="roam"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        pbRoamPokemon(true)
        $PokemonGlobal.roamedAlready=false
        Kernel.pbMessage(_INTL("Pokémon have roamed."))
      end
    elsif cmd=="games"
      gamecmd=0
      loop do 
        gamecmds=[
           _INTL("Slot Machine"),
           _INTL("Voltorb Flip"),
           _INTL("Underground Mining"),
           _INTL("Type Quiz"),
           _INTL("Type Quiz (Hard)")
        ]
        gamecmd=Kernel.pbShowCommands(nil,gamecmds,-1,gamecmd)
        break if gamecmd<0
        case gamecmd
        when 0 # VoltorbFlip
          pbSlotMachine
        when 1 # Slot Machine
          commands=[_INTL("Easy"),
                    _INTL("Medium"),
                    _INTL("Hard"),
                    _INTL("Cancel")]
          command=Kernel.pbMessage(
              _INTL("Choose a difficulty."),commands,-1)
          if command>=0 && command < 3
            pbVoltorbFlip(command)
          end
        when 2 # Mining
          pbMiningGame
        when 3 # Type Quiz
          TypeQuiz.scene(25)
        when 4 # Type Quiz
          TypeQuiz.scene(25,true)

        end
      end
    elsif cmd=="edititems"
      pbFadeOutIn(99999) { pbItemEditor }
    elsif cmd=="editpokemon"
      pbFadeOutIn(99999) { pbPokemonEditor }
    elsif cmd=="spriteposition"
      pbFadeOutIn(99999) {
         sp=SpritePositioner.new
         sps=SpritePositionerScreen.new(sp)
         sps.pbStart
      }
    elsif cmd=="spriteposition2"
      if Kernel.pbConfirmMessage(_INTL("Are you sure you want to reposition all sprites?"))
        msgwindow=Kernel.pbCreateMessageWindow
        Kernel.pbMessageDisplay(msgwindow,_INTL("Repositioning all sprites. Please wait."),false)
        Graphics.update
        pbAutoPositionAll()
        Kernel.pbMessage(_INTL("Pokémon have positioned."))
        Kernel.pbDisposeMessageWindow(msgwindow)
      end
    elsif cmd=="editdexes"
      pbFadeOutIn(99999) { pbRegionalNumbersEditor }
    elsif cmd=="setencounters"
      encdata=load_data("Data/encounters.dat")
      oldencdata=Marshal.dump(encdata)
      mapedited=false
      map=pbDefaultMap()
      loop do
        map=pbListScreen(_INTL("Set Encounters"),MapLister.new(map))
        break if map<=0
        mapedited=true if map==pbDefaultMap()
        pbEncounterEditorMap(encdata,map)
      end
      save_data(encdata,"Data/encounters.dat")
      pbSaveEncounterData()
      pbClearData()
    elsif cmd=="setmetadata"
      pbMetadataScreen(pbDefaultMap())
      pbClearData()
    elsif cmd=="terraintags"
      pbFadeOutIn(99999) { pbTilesetScreen }
    elsif cmd=="trainertypes"
      pbFadeOutIn(99999) { pbTrainerTypeEditor }
    elsif cmd=="edittrainers"
      pbFadeOutIn(99999) { pbTrainerBattleEditor }
    elsif cmd=="resettrainers"
      if $game_map
        for event in $game_map.events.values
          if event.name[/Trainer\(\d+\)/]
            $game_self_switches[[$game_map.map_id,event.id,"A"]]=false
            $game_self_switches[[$game_map.map_id,event.id,"B"]]=false
          end
        end
        $game_map.need_refresh=true
        Kernel.pbMessage(_INTL("All Trainers on this map were reset."))
      else
        Kernel.pbMessage(_INTL("This command can't be used here."))
      end
    elsif cmd=="testwildbattle"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          $game_switches[40]=true
          pbWildBattle(species,level)
          $game_switches[40]=false
        end
      end
    elsif cmd=="testdoublewildbattle"
      Kernel.pbMessage(_INTL("Choose the first Pokémon."))
      species1=pbChooseSpeciesOrdered(1)
      if species1!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level1=Kernel.pbMessageChooseNumber(
           _INTL("Set the first Pokémon's level."),params)
        if level1>0
          Kernel.pbMessage(_INTL("Choose the second Pokémon."))
          species2=pbChooseSpeciesOrdered(1)
          if species2!=0
            params=ChooseNumberParams.new
            params.setRange(1,PBExperience::MAXLEVEL)
            params.setInitialValue(5)
            params.setCancelValue(0)
            level2=Kernel.pbMessageChooseNumber(
               _INTL("Set the second Pokémon's level."),params)
            if level2>0
              $game_switches[40]=true
              pbDoubleWildBattle(species1,level1,species2,level2)
              $game_switches[40]=false
            end
          end
        end
      end
    elsif cmd=="testtrainerbattle"
      battle=pbListScreen(_INTL("Single Trainer"),TrainerBattleLister.new(0,false))
      if battle
        trainerdata=battle[1]
        pbTrainerBattle(trainerdata[0],trainerdata[1],"...",false,trainerdata[4],true)
      end
    elsif cmd=="testdoubletrainerbattle"
      battle1=pbListScreen(_INTL("Double Trainer 1"),TrainerBattleLister.new(0,false))
      if battle1
        battle2=pbListScreen(_INTL("Double Trainer 2"),TrainerBattleLister.new(0,false))
        if battle2
          trainerdata1=battle1[1]
          trainerdata2=battle2[1]
          pbDoubleTrainerBattle(trainerdata1[0],trainerdata1[1],trainerdata1[4],"...",
                                trainerdata2[0],trainerdata2[1],trainerdata2[4],"...",
                                true)
        end
      end
    elsif cmd=="relicstone"
      pbRelicStone()
    elsif cmd=="purifychamber"
      pbPurifyChamber()
    elsif cmd=="extracttext"
      if $CORENDO
        worksOnCorendo(['RGSS Player'])
        return -1
      end
      pbExtractText
    elsif cmd=="compiletext"
      if $CORENDO
        worksOnCorendo(['RGSS Player'])
        return -1
      end
      pbCompileTextUI
    elsif cmd=="compiledata"
      if $CORENDO
        worksOnCorendo(['RGSS Player'])
        return -1
      end
      msgwindow=Kernel.pbCreateMessageWindow
      pbCompileAllData(true) {|msg| Kernel.pbMessageDisplay(msgwindow,msg,false) }
      Kernel.pbMessageDisplay(msgwindow,_INTL("All game data was compiled."))
      Kernel.pbDisposeMessageWindow(msgwindow)
    elsif cmd=="mapconnections"
      pbFadeOutIn(99999) { pbEditorScreen }
    elsif cmd=="animeditor"
      pbFadeOutIn(99999) { pbAnimationEditor(inloadscreen) }
    elsif cmd=="animorganizer"
      pbFadeOutIn(99999) { pbAnimationsOrganiser }
    elsif cmd=="debugconsole"
      Console::setup_console
    elsif cmd=="togglelogging"
      $INTERNAL=!$INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will be made in the Data folder and the debug console.")) if $INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
    elsif cmd=="godhandmode"
      $PokemonSystem.battledif=4
      Kernel.pbMessage(_INTL("Battle difficulty has been set to Intensive."))
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



class SpriteWindow_DebugRight < Window_DrawableCommand
  attr_reader :mode

  def initialize(additional_reduce=0)
    super(0, additional_reduce, Graphics.width, Graphics.height-additional_reduce)
  end

  def shadowtext(x,y,w,h,t,align=0)
    width=self.contents.text_size(t).width
    if align==2
      x+=(w-width)
    elsif align==1
      x+=(w/2)-(width/2)
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,
       $AEditorTextBase,$AEditorTextShadow) # Color.new(12*8,12*8,12*8),Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,count,rect)
    pbSetNarrowFont(self.contents)
    if @mode == 0
      name = $data_system.switches[index+1]
      status = $game_switches[index+1] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[index+1]
      status = $game_variables[index+1].to_s
    end
    if name == nil
      name = ''
    end
    id_text = sprintf("%04d:", index+1)
    width = self.contents.text_size(id_text).width
    rect=drawCursor(index,rect)
    totalWidth=rect.width
    idWidth=totalWidth*15/100
    nameWidth=totalWidth*65/100
    statusWidth=totalWidth*20/100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x+idWidth, rect.y, nameWidth, rect.height, name)
    self.shadowtext(rect.x+idWidth+nameWidth, rect.y, statusWidth, rect.height, status, 2)
  end

  def itemCount
    return (@mode==0) ? $data_system.switches.size-1 : $data_system.variables.size-1
  end

  def mode=(mode)
    @mode = mode
    refresh
  end
end



def pbDebugSetVariable(id,diff)
  pbPlayCursorSE()
  $game_variables[id]=0 if $game_variables[id]==nil
  if $game_variables[id].is_a?(Numeric)
    $game_variables[id]=[$game_variables[id]+diff,99999999].min
    $game_variables[id]=[$game_variables[id],-99999999].max
  end
end

def pbDebugVariableScreen(id)
  # Change: Make Rival Variables use naming screen
  done = false
  for i in RIVALNAMES
    if i[1]==id
      pbSet(id,pbEnterNPCName(
        _INTL("Set variable {1}.",id),1,12,$game_variables[id].to_s,
        pbTrainerCharNameFile(getConst(PBTrainers,i[0])))
      )
      done = true
      break
    end
  end
  # End Change
  if done
  elsif $game_variables[id].is_a?(Numeric)
    value = $game_variables[id]
    params = ChooseNumberParams.new
    params.setDefaultValue(value)
    params.setMaxDigits(8)
    params.setNegativesAllowed(true)
    value = Kernel.pbMessageChooseNumber(_INTL("Set variable {1}.",id),params)
    $game_variables[id] = [value,99999999].min
    $game_variables[id] = [$game_variables[id],-99999999].max
  elsif $game_variables[id].is_a?(String)
    value = Kernel.pbMessageFreeText(_INTL("Set variable {1}.",id),
       $game_variables[id],false,256,Graphics.width)
    $game_variables[id] = value
  end
end

def pbDebugScreen(mode)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
      addBackgroundOrColoredPlane(sprites,"title",getDarkModeFolder+"/Settings/bg_"+["2","3"][mode],
         Color.new(12,12,12),viewport)
    title=["Switches", "Variables"][mode]    
    sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
       2,-18,576,64,viewport)      
    sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].windowskin=nil

    
  sprites["right_window"] = SpriteWindow_DebugRight.new(32) 
  right_window=sprites["right_window"]
  right_window.mode=mode
  right_window.viewport=viewport
  right_window.active=true
  right_window.index=0
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      break
    end
    current_id = right_window.index+1
    if mode == 0
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        $game_switches[current_id] = (not $game_switches[current_id])
        right_window.refresh
      end
    elsif mode == 1
      if Input.repeat?(Input::RIGHT)
        pbDebugSetVariable(current_id,1)
        right_window.refresh
      elsif Input.repeat?(Input::LEFT)
        pbDebugSetVariable(current_id,-1)
        right_window.refresh
      elsif Input.trigger?(Input::C)
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end


def pbDebugScreen2(mode)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
      addBackgroundOrColoredPlane(sprites,"title",getDarkModeFolder+"/Settings/bg_4",
         Color.new(12,12,12),viewport)
    title=["Game ROM Initialization Check", "Control Configuration Check", "Game RAM Initialization Check", "Audio Initialization Check"][mode]    
    sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(title),
       2,-18,576,64,viewport)      
    sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    sprites["header"].windowskin=nil
  pbFadeInAndShow(sprites)
  if (mode == 0)
      worksOnCorendo(['VR Corendo'])
  elsif (mode == 1)
      worksOnCorendo(['VR Corendo','Bsibsina Clients'])
  elsif (mode == 2)
      worksOnCorendo(['VR Corendo','Jinnybell HSPA'])
  elsif (mode == 3)
      worksOnCorendo(['VR Corendo', 'Bsibsina Action Player', 'Yorkbook Digital Professional', 'Jinnybell HSPA', 'ΣΟΥΒΛ Crystal'])
  else
      worksOnCorendo
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



class Scene_Debug
  def main(inloadscreen=false,mode=0)
    Graphics.transition(15)
    pbDebugMenu(inloadscreen,mode)
    $scene=Scene_Map.new
    $game_map.refresh
    Graphics.freeze
  end
end