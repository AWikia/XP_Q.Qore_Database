#===============================================================================
# Pokédex menu screen
# * For choosing which region list to view.  Only appears when there is more
#   than one viable region list to choose from, and if DEXDEPENDSONLOCATION is
#   false.
# * Adapted from the Pokégear menu script by Maruno.
#===============================================================================
class Window_DexesList < Window_CommandPokemon
  def initialize(commands,width,seen,owned)
    @seen=seen
    @owned=owned
    super(commands,width)
    @selarrow=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/selarrowaccent")
    self.windowskin=nil
  end

  def drawItem(index,count,rect)
    super(index,count,rect)
    if index>=0 && index<@seen.length
      pbDrawShadowText(self.contents,rect.x+236,rect.y,64,rect.height,
         @seen[index],self.baseColor,self.shadowColor,1)
      pbDrawShadowText(self.contents,rect.x+332,rect.y,64,rect.height,
         @owned[index],self.baseColor,self.shadowColor,1)
    end
  end
end



class Scene_PokedexMenuScene
  def pbStartScene(menu_index = 0)
    @menu_index = menu_index
  end

  def pbPokedexMenuScreen
    commands=[]; seen=[]; owned=[]
    dexnames=pbDexNames
    for i in 0...$PokemonGlobal.pokedexViable.length
      index=$PokemonGlobal.pokedexViable[i]
      if dexnames[index]==nil
        commands.push(_INTL("Pokédex"))
      else
        if dexnames[index].is_a?(Array)
          commands.push(dexnames[index][0] + " " + _INTL("Pokédex"))
        else
          commands.push(dexnames[index] + " " + _INTL("Pokédex"))
        end
      end
      index=-1 if index>=$PokemonGlobal.pokedexUnlocked.length-1
      seen.push($Trainer.pokedexSeen(index).to_s)
      owned.push($Trainer.pokedexOwned(index).to_s)
    end
    commands.push(_INTL("Exit"))
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Pokedex/bg_menu",@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokédex"),
       2,-18,384,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["commands"] = Window_DexesList.new(commands,Graphics.width,seen,owned)
    @sprites["commands"].index = @menu_index
    @sprites["commands"].x = 106
    @sprites["commands"].y = 72
    @sprites["commands"].z = 99999
    @sprites["commands"].width = Graphics.width-188 # 84
    @sprites["commands"].height = 320
    @sprites["commands"].windowskin=nil
    if (!isDarkMode?)
      @sprites["commands"].baseColor=Color.new(20,20,20)
      @sprites["commands"].shadowColor=Color.new(239,173,173)
    else
      @sprites["commands"].baseColor=Color.new(242,242,242)
      @sprites["commands"].shadowColor=Color.new(195,49,49)
    end    
    @sprites["headings"]=Window_AdvancedTextPokemon.newWithSize(
       _INTL("SEEN<r>OBTAINED"),350,16,208,64,@viewport)
    if (!isDarkMode?)
      @sprites["headings"].baseColor=Color.new(20,20,20)
      @sprites["headings"].shadowColor=Color.new(228,122,122)
    else
      @sprites["headings"].baseColor=Color.new(242,242,242)
      @sprites["headings"].shadowColor=Color.new(151,39,39)
    end
    @sprites["headings"].windowskin=nil
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B) || 
        (Input.trigger?(Input::C) && @sprites["commands"].index == @sprites["commands"].itemCount-1)
        pbPlayCancelSE() if Input.trigger?(Input::B)
        break
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
    if @sprites["commands"].active
      update_command
      return
    end
  end

  def update_command
    if Input.trigger?(Input::B)
      return
    end
    if Input.trigger?(Input::C)
      case @sprites["commands"].index
      when @sprites["commands"].itemCount-1
        pbPlayDecisionSE()
        return
      else
        pbPlayDecisionSE()
        $PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[@sprites["commands"].index]
        $PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
        oldsprites=pbFadeOutAndHide(@sprites)#
           scene=PokemonPokedexScene.new
           screen=PokemonPokedex.new(scene)
           screen.pbStartScreen
        pbFadeInAndShow(@sprites,oldsprites)#
      end
      return
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class Scene_PokedexMenu
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPokedexMenuScreen
    @scene.pbEndScene
  end
end

#===============================================================================
# Pokédex main screen
#===============================================================================
class Window_CommandPokemonWhiteArrow < Window_CommandPokemon
  def drawCursor(index,rect)
    selarrow=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/selarrowaccent")
    if self.index==index
      pbCopyBitmap(self.contents,selarrow.bitmap,rect.x,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end
end



class Window_Pokedex < Window_DrawableCommand
  def initialize(x,y,width,height)
    if pbGetPokedexRegion==-1 # Using national Pokédex
    @pokeballOwned=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_own")
    @pokeballSeen=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_seen")
    else
#    @pokeballOwned=AnimatedBitmap.new("Graphics/UI/pokedexOwnedREGION")
#    @pokeballSeen=AnimatedBitmap.new("Graphics/UI/pokedexSeenREGION")
    @pokeballOwned=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_own")
    @pokeballSeen=AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_seen")
    end

    @commands=[]
    super(x,y,width,height)
    self.windowskin=nil
#    self.baseColor=MessageConfig::DARKTEXTBASE
#    self.shadowColor=MessageConfig::DARKTEXTSHADOW
#    self.baseColor=Color.new(77,38,115)

    if (!isDarkMode?)
      self.baseColor=Color.new(20,20,20)
    else
      self.baseColor=Color.new(242,242,242)
    end
    self.shadowColor=Color.new(0,0,0,0)

  end

  def drawCursor(index,rect)
    if pbGetPokedexRegion==-1 # Using national Pokédex
    selarrow=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/pokedexSel")
    else
    selarrow=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/pokedexSel")
#    selarrow=AnimatedBitmap.new("Graphics/UI/pokedexSelREGION")
    end
    if self.index==index
      pbCopyBitmap(self.contents,selarrow.bitmap,rect.x,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end

  def commands=(value)
    @commands=value
    refresh
  end

  def dispose
    @pokeballOwned.dispose
    @pokeballSeen.dispose
#    @icon.dispose
    super
  end

  def species
    return @commands.length==0 ? 0 : @commands[self.index][0]
  end

  def itemCount
    return @commands.length
  end

  def drawItem(index,count,rect)
    return if index >= self.top_row + self.page_item_max
    rect=drawCursor(index,rect)
    indexNumber=@commands[index][4]
    indexNumber-=1 if DEXINDEXOFFSETS.include?(pbGetPokedexRegion)
    species=@commands[index][0]
#    @icon=PokemonSpeciesIconSprite.new(species)
#    @icon.zoom_x=0.5
#    @icon.zoom_y=0.5
    if pbGetPokedexRegion == -1
      fdexno = getDexNumber(indexNumber)
    else
      fdexno = indexNumber.to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
    end
    rectange=Rect.new(0,0,64,64)
    
    if $Trainer.seen[species]
      if $Trainer.owned[species]
        #pbCopyBitmap2(self.contents,@icon.bitmap,rect.x-24,rect.y-16) # @pokeballOwned
        pbCopyBitmap(self.contents,@pokeballOwned.bitmap,rect.x-6,rect.y+8)
      else
        pbCopyBitmap(self.contents,@pokeballSeen.bitmap,rect.x-6,rect.y+8)
      end
      text=_INTL("{1}{2} {3}",(@commands[index][5]) ? fdexno : fdexno," ",@commands[index][1])
    else
      text=_INTL("{1}  ----------",(@commands[index][5]) ? fdexno : fdexno)
    end
    pbDrawShadowText(self.contents,rect.x+34,rect.y+6,rect.width,rect.height,text,
       self.baseColor,self.shadowColor)
    overlapCursor=drawCursor(index-1,itemRect(index-1))
  end
end


class Window_ComplexCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands,width=nil)
    @starting=true
    @commands=commands
    dims=[]
    getAutoDims(commands,dims,width)
    super(0,0,dims[0],dims[1])
    @selarrow=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/selarrowaccent")
    @starting=false
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def indexToCommand(index)
    curindex=0
    i=0; loop do break unless i<@commands.length
      return [i/2,-1] if index==curindex
      curindex+=1
      return [i/2,index-curindex] if index-curindex<commands[i+1].length
      curindex+=commands[i+1].length
      i+=2
    end
    return [-1,-1]
  end

  def getText(array,index)
    cmd=indexToCommand(index)
    return "" if cmd[0]==-1
    return array[cmd[0]*2] if cmd[1]<0
    return array[cmd[0]*2+1][cmd[1]]
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length  
    self.index=self.index
  end

  def width=(value)
    super
    if !@starting
      self.index=self.index
    end
  end

  def height=(value)
    super
    if !@starting
      self.index=self.index
    end
  end

  def resizeToFit(commands)
    dims=[]
    getAutoDims(commands,dims)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    mx=0
    i=0; loop do break unless i<@commands.length
      mx+=1+@commands[i+1].length
      i+=2
    end
    return mx
  end

  def drawItem(index,count,rect)
    command=indexToCommand(index)
    return if command[0]<0
    text=getText(@commands,index)
    if command[1]<0
      pbDrawShadowText(self.contents,rect.x+32,rect.y,rect.width,rect.height,text,
         self.baseColor,self.shadowColor)
    else
      rect=drawCursor(index,rect)
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,text,
         self.baseColor,self.shadowColor)
    end
  end
end



class PokemonPokedexScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def setIconBitmap(species)
    gender=($Trainer.formlastseen[species][0] rescue 0)
    form=($Trainer.formlastseen[species][1] rescue 0)
    @sprites["icon"].setSpeciesBitmapDex(species,(gender==1),form,false,false,false,false,false)
    pbPositionPokemonSprite(@sprites["icon"],116-32,164-64+7)
  end

# Gets the region used for displaying Pokédex entries.  Species will be listed
# according to the given region's numbering and the returned region can have
# any value defined in the town map data file.  It is currently set to the
# return value of pbGetCurrentRegion, and thus will change according to the
# current map's MapPosition metadata setting.
  def pbGetPokedexRegion
    if DEXDEPENDSONLOCATION
      region=pbGetCurrentRegion
      region=-1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
      return region
    else
      return $PokemonGlobal.pokedexDex # National Dex -1, regional dexes 0 etc.
    end
  end

# Determines which index of the array $PokemonGlobal.pokedexIndex to save the
# "last viewed species" in.  All regional dexes come first in order, then the
# National Dex at the end.
  def pbGetSavePositionIndex
    index=pbGetPokedexRegion
    if index==-1 # National Dex
      index=$PokemonGlobal.pokedexUnlocked.length-1 # National Dex index comes
    end                                             # after regional Dex indices
    return index
  end

  def pbStartScene
    @dummypokemon=PokeBattle_Pokemon.new(1,1)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
#   @sprites["pokedex"]=Window_Pokedex.new(214,18,268,332) # 384
    @sprites["pokedex"]=Window_Pokedex.new(282,14,332,384)
    @sprites["pokedex"].viewport=@viewport
    @sprites["dexentry"]=IconSprite.new(0,0,@viewport)
    @sprites["dexentry2"]=IconSprite.new(0,0,@viewport)
    @sprites["dexentry2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokedex/overlay_info_2"))
  if pbGetPokedexRegion==-1 # Using national Pokédex
    @sprites["dexentry"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokedex/bg_info"))
  else
#    @sprites["dexentry"].setBitmap(_INTL("Graphics/UI/pokedexEntryREGION"))
    @sprites["dexentry"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokedex/bg_info"))
  end
    @sprites["dexentry"].visible=false
    @sprites["dexentry2"].visible=false
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay"].x=0
    @sprites["overlay"].y=0
    @sprites["overlay"].visible=false
    @sprites["searchtitle"]=Window_UnformattedTextPokemon.newWithSize("",2,-18,Graphics.width,64,@viewport)
    @sprites["searchtitle"].windowskin=nil
    @sprites["searchtitle"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["searchtitle"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["searchtitle"].text=_ISPRINTF("Search Mode")
    @sprites["searchtitle"].visible=false
    @sprites["searchlist"]=Window_ComplexCommandPokemon.newEmpty(-6,32,284,352,@viewport)
    if (!isDarkMode?)
      @sprites["searchlist"].baseColor=MessageConfig::DARKTEXTBASE
      @sprites["searchlist"].shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      @sprites["searchlist"].baseColor=MessageConfig::LIGHTTEXTBASE
      @sprites["searchlist"].shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    @sprites["searchlist"].visible=false
    @sprites["auxlist"]=Window_CommandPokemonWhiteArrow.newEmpty(318,32,348,224,@viewport)
    if (!isDarkMode?)
      @sprites["auxlist"].baseColor=MessageConfig::DARKTEXTBASE
      @sprites["auxlist"].shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      @sprites["auxlist"].baseColor=MessageConfig::LIGHTTEXTBASE
      @sprites["auxlist"].shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    @sprites["auxlist"].visible=false
    @sprites["messagebox"]=Window_UnformattedTextPokemon.newWithSize("",316,256,328,128,@viewport)
    if (!isDarkMode?)
      @sprites["messagebox"].baseColor=MessageConfig::DARKTEXTBASE
      @sprites["messagebox"].shadowColor=MessageConfig::DARKTEXTSHADOW
    else
      @sprites["messagebox"].baseColor=MessageConfig::LIGHTTEXTBASE
      @sprites["messagebox"].shadowColor=MessageConfig::LIGHTTEXTSHADOW
    end
    @sprites["messagebox"].visible=false
    @sprites["messagebox"].letterbyletter=false
#    @sprites["dexname"]=Window_AdvancedTextPokemon.newWithSize("",2,-18,Graphics.width,64,@viewport)
#    @sprites["dexname"].windowskin=nil
#    @sprites["dexname"].baseColor=Color.new(242,242,242)
#    @sprites["dexname"].shadowColor=Color.new(12,12,12)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokédex"),
       2,-18,384,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["seen"]=Window_AdvancedTextPokemon.newWithSize("",34,299,164,64,@viewport)
    @sprites["seen"].windowskin=nil
#    @sprites["seen"].baseColor=MessageConfig::DARKTEXTBASE
#    @sprites["seen"].shadowColor=MessageConfig::DARKTEXTSHADOW
#    @sprites["seen"].baseColor=Color.new(77,38,115)
    if (!isDarkMode?)
      @sprites["seen"].baseColor=Color.new(20,20,20)
      @sprites["seen"].shadowColor=Color.new(192,168,240)
    else
      @sprites["seen"].baseColor=Color.new(242,242,242)
      @sprites["seen"].shadowColor=Color.new(119,65,221)
    end
    @sprites["owned"]=Window_AdvancedTextPokemon.newWithSize("",34,329,164,64,@viewport)
    @sprites["owned"].windowskin=nil
#    @sprites["owned"].baseColor=MessageConfig::DARKTEXTBASE
#    @sprites["owned"].shadowColor=MessageConfig::DARKTEXTSHADOW
#    @sprites["owned"].baseColor=Color.new(77,38,115)
    if (!isDarkMode?)
      @sprites["owned"].baseColor=Color.new(20,20,20)
      @sprites["owned"].shadowColor=Color.new(192,168,240)
    else
      @sprites["owned"].baseColor=Color.new(242,242,242)
      @sprites["owned"].shadowColor=Color.new(119,65,221)
    end
    if pbGetPokedexRegion==-1 # Using national Pokédex
      addBackgroundPlane(@sprites,"searchbg",_INTL(getDarkModeFolder+"/Pokedex/bg_search"),@viewport)
    else
      addBackgroundPlane(@sprites,"searchbg",_INTL(getDarkModeFolder+"/Pokedex/bg_search"),@viewport)
#      addBackgroundPlane(@sprites,"searchbg",_INTL("pokedexSearchbgREGION"),@viewport)
    end
    @sprites["searchbg"].visible=false
    @searchResults=false
=begin
# Suggestion for changing the background depending on region.  You
# can change the line below with the following:
    if pbGetPokedexRegion==-1 # Using national Pokédex
      addBackgroundPlane(@sprites,"background","pokedexbg_national",@viewport)
    elsif pbGetPokedexRegion==0 # Using first regional Pokédex
      addBackgroundPlane(@sprites,"background","pokedexbg_regional",@viewport)
    end
=end
    if pbGetPokedexRegion==-1 # Using national Pokédex
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Pokedex/bg_list",@viewport)
    else
       addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/Pokedex/bg_list",@viewport)
#      addBackgroundPlane(@sprites,"background","pokedexbgREGION",@viewport)
    end
    @sprites["slider"]=IconSprite.new(Graphics.width-40,62,@viewport)
    if pbGetPokedexRegion==-1 # Using national Pokédex
    @sprites["slider"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_slider"))
    else
    @sprites["slider"].setBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_slider"))
#    @sprites["slider"].setBitmap(sprintf("Graphics/UI/pokedexSliderREGION"))
    end
    @sprites["icon"]=PokemonSprite.new(@viewport)
    @sprites["entryicon"]=PokemonSprite.new(@viewport)
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbDexSearchCommands(commands,selitem,helptexts=nil)
    ret=-1
    auxlist=@sprites["auxlist"]
    messagebox=@sprites["messagebox"]
    auxlist.commands=commands
    auxlist.index=selitem
    messagebox.text=helptexts ? helptexts[auxlist.index] : ""
    pbActivateWindow(@sprites,"auxlist"){ 
       loop do
         Graphics.update
         Input.update
         oldindex=auxlist.index
         pbUpdate
         if auxlist.index!=oldindex && helptexts
           messagebox.text=helptexts[auxlist.index]
         end
         if Input.trigger?(Input::B)
           ret=selitem
           pbPlayCancelSE()
           break
         end
         if Input.trigger?(Input::C)
           ret=auxlist.index
           pbPlayDecisionSE()
           break
         end
       end
       @sprites["auxlist"].commands=[]
    }
    Input.update
    return ret
  end

  def pbCanAddForModeList?(mode,nationalSpecies)
    case mode
    when 0
      return true
    when 1
      return $Trainer.seen[nationalSpecies]
    when 2, 3, 4, 5
      return $Trainer.owned[nationalSpecies]
    end
  end

  def pbCanAddForModeSearch?(mode,nationalSpecies)
    case mode
    when 0, 1
      return $Trainer.seen[nationalSpecies]
    when 2, 3, 4, 5
      return $Trainer.owned[nationalSpecies]
    end
  end

=begin
  def pbGetDexList()
    dexlist=[]
    dexdata=pbOpenDexData
    region=pbGetPokedexRegion()
    regionalSpecies=pbAllRegionalSpecies(region)
    if regionalSpecies.length==1
      # If no regional species defined, use National Pokédex order
      for i in 1..PBSpecies.maxValue
        regionalSpecies.push(i)
      end
    end
    for i in 1...regionalSpecies.length
      nationalSpecies=regionalSpecies[i]
      if pbCanAddForModeList?($PokemonGlobal.pokedexMode,nationalSpecies)
        pbDexDataOffset(dexdata,nationalSpecies,33)
        height=dexdata.fgetw
        weight=dexdata.fgetw
        # Pushing national species, name, height, weight, index number
        shift=DEXINDEXOFFSETS.include?(region)
        dexlist.push([nationalSpecies,
           PBSpecies.getName(nationalSpecies),height,weight,i,shift])
      end
    end
    dexdata.close
    return dexlist
  end
=end

  def pbGetDexList()
    dexlist=[]
    dexdata=pbOpenDexData
    region=pbGetPokedexRegion()
    regionalSpecies=pbAllRegionalSpecies(region)
    if regionalSpecies.length==1
      # If no regional species defined, use national Pokédex order
      for i in 1..PBSpecies.maxValue
        regionalSpecies.push(i)
      end
    end
    for i in 1...regionalSpecies.length
      nationalSpecies=regionalSpecies[i]
      fdexno = getDexNumber(nationalSpecies)
    
      if pbCanAddForModeList?($PokemonGlobal.pokedexMode,nationalSpecies)
        pbDexDataOffset(dexdata,nationalSpecies,33)
        height=dexdata.fgetw
        weight=dexdata.fgetw
        # Pushing national species, name, height, weight, index number
        shift=DEXINDEXOFFSETS.include?(region)
        dexlist.push([nationalSpecies,
           PBSpecies.getName(nationalSpecies),height,weight,i,fdexno,shift])
      end
    end
    dexdata.close
    return dexlist
  end


  def pbRefreshDexList(index=0)
    dexlist=pbGetDexList()
    case $PokemonGlobal.pokedexMode
    when 0 # Numerical mode
      # Remove species not seen from the list
      if pbGetPokedexRegion == -1
          dexlist = getQoreDexList(dexlist)
      end
=begin
      i=0; loop do break unless i<dexlist.length
        break if $Trainer.seen[dexlist[i][0]]
        dexlist[i]=nil
        i+=1
      end
=end
      i=dexlist.length-1; loop do break unless i>=0
        break if !dexlist[i] || $Trainer.seen[dexlist[i][0]]
        dexlist[i]=nil
        i-=1
      end
      dexlist.compact!
      # Sort species in ascending order by index number, not national species
      if pbGetPokedexRegion != -1 # Not in National Mode
        dexlist.sort!{|a,b| a[4]<=>b[4]}
      end
    when 1 # Alphabetical mode
      dexlist.sort!{|a,b| a[1]==b[1] ? a[4]<=>b[4] : a[1]<=>b[1]}
    when 2 # Heaviest mode
      dexlist.sort!{|a,b| a[3]==b[3] ? a[4]<=>b[4] : b[3]<=>a[3]}
    when 3 # Lightest mode
      dexlist.sort!{|a,b| a[3]==b[3] ? a[4]<=>b[4] : a[3]<=>b[3]}
    when 4 # Tallest mode
      dexlist.sort!{|a,b| a[2]==b[2] ? a[4]<=>b[4] : b[2]<=>a[2]}
    when 5 # Smallest mode
      dexlist.sort!{|a,b| a[2]==b[2] ? a[4]<=>b[4] : a[2]<=>b[2]}
    end
    @dexname=_INTL("Pokédex")
    if $PokemonGlobal.pokedexUnlocked.length>1
      thisdex=pbDexNames[pbGetSavePositionIndex]
      if thisdex!=nil
        if thisdex.is_a?(Array)
          @dexname=thisdex[0]
        else
          @dexname=thisdex
        end
      end
    end
    if !@searchResults
      @sprites["seen"].text=_ISPRINTF("Seen:<r>{1:d}",$Trainer.pokedexSeen(pbGetPokedexRegion))
      @sprites["owned"].text=_ISPRINTF("Owned:<r>{1:d}",$Trainer.pokedexOwned(pbGetPokedexRegion))
    #  @sprites["dexname"].text=_ISPRINTF("{1:s}",@dexname)
    else
      seenno=0
      ownedno=0
      for i in dexlist
        seenno+=1 if $Trainer.seen[i[0]]
        ownedno+=1 if $Trainer.owned[i[0]]
      end
      @sprites["seen"].text=_ISPRINTF("Seen:<r>{1:d}",seenno)
      @sprites["owned"].text=_ISPRINTF("Owned:<r>{1:d}",ownedno)
   #   @sprites["dexname"].text=_ISPRINTF("{1:s} - Search results",@dexname)
    end
    @dexlist=dexlist
    @sprites["pokedex"].commands=@dexlist
    @sprites["pokedex"].index=index
    @sprites["pokedex"].refresh
    # Draw the slider
    ycoord=62
    if @sprites["pokedex"].itemCount>1
      ycoord+=236.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
    end
    @sprites["slider"].y=ycoord
    iconspecies=@sprites["pokedex"].species
    iconspecies=0 if !$Trainer.seen[iconspecies]
    setIconBitmap(iconspecies)
    if iconspecies>0
      @sprites["header"].text=_INTL("{1} - {2}",@dexname,PBSpecies.getName(iconspecies))
    else
      @sprites["header"].text=_INTL("{1}",@dexname)
    end
  end

  def pbSearchDexList(params)
    $PokemonGlobal.pokedexMode=params[4]
    dexlist=pbGetDexList()
    if pbGetPokedexRegion == -1 && params[4] == 0
      dexlist = getQoreDexList(dexlist)
    end
    dexdata=pbOpenDexData()
    if params[0]!=0 # Filter by name
      nameCommands=[
         "",_INTL("ABC"),_INTL("DEF"),_INTL("GHI"),
         _INTL("JKL"),_INTL("MNO"),_INTL("PQR"),
         _INTL("STU"),_INTL("VWX"),_INTL("YZ")
      ]
      scanNameCommand=nameCommands[params[0]].scan(/./)
      dexlist=dexlist.find_all {|item|
         next false if !$Trainer.seen[item[0]]
         firstChar=item[1][0,1]
         next scanNameCommand.any? { |v|  v==firstChar }
      }
    end
    if params[1]!=0 # Filter by color
      dexlist=dexlist.find_all {|item|
         next false if !$Trainer.seen[item[0]]
         pbDexDataOffset(dexdata,item[0],6)
         color=dexdata.fgetb
         next color==params[1]-1
      }
    end
    if params[2]!=0 || params[3]!=0 # Filter by type
      typeCommands=[-1]
      for i in 0..PBTypes.maxValue
        if !PBTypes.isPseudoType?(i)
          typeCommands.push(i) # Add type
        end
      end
      stype1=typeCommands[params[2]]
      stype2=typeCommands[params[3]]
      dexlist=dexlist.find_all {|item|
         next false if !$Trainer.owned[item[0]]
         pbDexDataOffset(dexdata,item[0],8)
         type1=dexdata.fgetb
         type2=dexdata.fgetb
         if stype1>=0 && stype2>=0
           # Find species that match both types
           next (stype1==type1 && stype2==type2) || (stype1==type2 && stype2==type1)
         elsif stype1>=0
           # Find species that match first type entered
           next type1==stype1 || type2==stype1
         else
           # Find species that match second type entered
           next type1==stype2 || type2==stype2
         end
      }
    end
    dexdata.close
    dexlist=dexlist.find_all {|item| # Remove all unseen species from the results
       next ($Trainer.seen[item[0]])
    }
    case params[4]
    when 0 # Numerical mode
      # Sort by index number, not national number
      if pbGetPokedexRegion != -1 # Not in National Mode
        dexlist.sort!{|a,b| a[4]<=>b[4]}
      end
    when 1 # Alphabetical mode
      dexlist.sort!{|a,b| a[1]<=>b[1]}
    when 2 # Heaviest mode
      dexlist.sort!{|a,b| b[3]<=>a[3]}
    when 3 # Lightest mode
      dexlist.sort!{|a,b| a[3]<=>b[3]}
    when 4 # Tallest mode
      dexlist.sort!{|a,b| b[2]<=>a[2]}
    when 5 # Smallest mode
      dexlist.sort!{|a,b| a[2]<=>b[2]}
    end
    return dexlist
  end

  def pbRefreshDexSearch(params)
    searchlist=@sprites["searchlist"]
    messagebox=@sprites["messagebox"]
    searchlist.commands=[
       _INTL("Search"),[
          _ISPRINTF("Name: {1:s}",@nameCommands[params[0]]),
          _ISPRINTF("Color: {1:s}",@colorCommands[params[1]]),
          _ISPRINTF("Type 1: {1:s}",@typeCommands[params[2]]),
          _ISPRINTF("Type 2: {1:s}",@typeCommands[params[3]]),
          _ISPRINTF("Order: {1:s}",@orderCommands[params[4]]),
          _INTL("Start Search")
       ],
       _INTL("Sort"),[
          _ISPRINTF("Order: {1:s}",@orderCommands[params[5]]),
          _INTL("Start Sort")
       ]
    ]
    helptexts=[
       _INTL("Search for Pokémon based on selected parameters."),[
          _INTL("List by the first letter in the name.\r\nSpotted Pokémon only."),
          _INTL("List by body color.\r\nSpotted Pokémon only."),
          _INTL("List by type.\r\nOwned Pokémon only."),
          _INTL("List by type.\r\nOwned Pokémon only."),
          _INTL("Select the Pokédex listing mode."),
          _INTL("Execute search."),
       ],
       _INTL("Switch Pokédex listings."),[
          _INTL("Select the Pokédex listing mode."),
          _INTL("Execute sort."),
       ]
    ]
    messagebox.text=searchlist.getText(helptexts,searchlist.index)
  end

  def pbChangeToDexEntry(species)
    @sprites["entryicon"].visible=true
    @sprites["dexentry"].visible=true
    @sprites["dexentry2"].visible=@compat
    @sprites["overlay"].visible=true
    pbDexEntryBitmaps(species)
    pbPlayCry(@dummypokemon)
  end

  def pbStartDexEntryScene(species)     # Used only when capturing a new species
    @dummypokemon=PokeBattle_Pokemon.new(species,1)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["dexentry"]=IconSprite.new(0,0,@viewport)
    @sprites["dexentry2"]=IconSprite.new(0,0,@viewport)
    @sprites["dexentry2"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokedex/overlay_info_2"))
    @sprites["dexentry"].setBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Pokedex/bg_info"))
    @sprites["dexentry"].visible=false
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay"].x=0
    @sprites["overlay"].y=0
    @sprites["overlay"].visible=false
    @sprites["entryicon"]=PokemonSprite.new(@viewport)
    pbChangeToDexEntry(species)
    pbDrawImagePositions(@sprites["overlay"].bitmap,[["Graphics/UI/"+getDarkModeFolder+"/Pokedex/overlay_info",0,0,0,0,-1,-1]])
    pbFadeInAndShow(@sprites)
  end

  def pbMiddleDexEntryScene             # Used only when capturing a new species
    pbActivateWindow(@sprites,nil){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if Input.trigger?(Input::B) || Input.trigger?(Input::C)
           break
         end
       end
    }
  end

  def pbDexEntryBitmaps(species)
    @sprites["overlay"].bitmap.clear

    if (!isDarkMode?)
      basecolor=MessageConfig::DARKTEXTBASE
      shadowcolor=MessageConfig::DARKTEXTSHADOW
      basecolor2=Color.new(20,20,20)
      basecolor3=Color.new(242,242,242)
    else
      basecolor=MessageConfig::LIGHTTEXTBASE
      shadowcolor=MessageConfig::LIGHTTEXTSHADOW
      basecolor2=Color.new(242,242,242)
      basecolor3=Color.new(242,242,242)
    end

    
    indexNumber=pbGetRegionalNumber(pbGetPokedexRegion(),species)
    indexNumber=species if indexNumber==0
    indexNumber-=1 if DEXINDEXOFFSETS.include?(pbGetPokedexRegion)
    gender=($Trainer.formlastseen[species][0] rescue 0)
    form=($Trainer.formlastseen[species][1] rescue 0)

    @dummypokemon.species=species
    @dummypokemon.setGender(gender)
    @dummypokemon.forceForm(form)
#    @compat=false
    # QQC Change Start (Number Q.Qore Pkmn with Q prefix and force Gen VI PKMN to
    # start from 650 instead of 850 or else FLINT won't load Gen VI Pkmn
    if pbGetPokedexRegion == -1
      fdexno = getDexNumber(indexNumber)
    else
      fdexno = indexNumber.to_s
      while (fdexno.length < 4)
        fdexno = "0" + fdexno
      end
    end

    # QQC Change End
    textpos=[
       [_INTL("{1}{2} {3}",fdexno," ",PBSpecies.getName(species)),
  #    372,40,0,Color.new(242,242,242),Color.new(12,12,12),1],
       372,40,0,basecolor3],
       [sprintf(_INTL("Height")),436,158,0,basecolor2],
       [sprintf(_INTL("Weight")),436,190,0,basecolor2]
    ]
    if $Trainer.owned[species]
      type1=@dummypokemon.type1
      type2=@dummypokemon.type2
      compat1=@dummypokemon.egroup1 
      compat2=@dummypokemon.egroup2
      color=@dummypokemon.color
      height=@dummypokemon.height
      weight=@dummypokemon.weight
      kind=@dummypokemon.kind
      dexentry=@dummypokemon.dexEntry
      inches=(height/0.254).round
      pounds=(weight/0.45359).round
      textpos.push([_ISPRINTF("{1:s} Pokémon",kind),372,74,0,basecolor2])
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),594,158,1,basecolor2])
        textpos.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),628,190,1,basecolor2])
      else
        textpos.push([_ISPRINTF("{1:.1f} m",height/10.0),604,158,1,basecolor2])
        textpos.push([_ISPRINTF("{1:.1f} kg",weight/10.0),616,190,1,basecolor2])
      end
      drawTextEx(@sprites["overlay"].bitmap,
         42,240,Graphics.width-(42*2),4,dexentry,basecolor2,nil,false)
#      footprintfile=pbPokemonFootprintFile(@dummypokemon)
#      if footprintfile
#        footprint=BitmapCache.load_bitmap(footprintfile)
#        @sprites["overlay"].bitmap.blt(226,136,footprint,footprint.rect)
#        footprint.dispose
#      end
    if pbGetPokedexRegion==-1 # Using national Pokédex
      pbDrawImagePositions(@sprites["overlay"].bitmap,[["Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_own",340,42,0,0,-1,-1]])
    else
      pbDrawImagePositions(@sprites["overlay"].bitmap,[["Graphics/UI/"+getDarkModeFolder+"/Pokedex/icon_own",340,42,0,0,-1,-1]])
#      pbDrawImagePositions(@sprites["overlay"].bitmap,[["Graphics/UI/pokedexOwnedREGION",340,42,0,0,-1,-1]])
    end
      typebitmap=AnimatedBitmap.new("Graphics/UI/Pokedex/icon_types")
      compatbitmap=AnimatedBitmap.new("Graphics/UI/Pokedex/icon_compatibilities")
      colorbitmap=AnimatedBitmap.new("Graphics/UI/Pokedex/icon_colors")
      comp1rect=Rect.new(96*0,(compat1 - 1)*32,96,32)
      comp2rect=Rect.new(96*0,(compat2 - 1)*32,96,32)
      type1rect=Rect.new(96*0,type1*32,96,32)
      type2rect=Rect.new(96*0,type2*32,96,32)
      colorrect=Rect.new(96*0,color*32,96,32)
      @sprites["overlay"].bitmap.blt(324,118,colorbitmap.bitmap,colorrect)
      if @compat
        @sprites["overlay"].bitmap.blt(424,118,compatbitmap.bitmap,comp1rect)
        @sprites["overlay"].bitmap.blt(524,118,compatbitmap.bitmap,comp2rect) if compat1!=compat2
      else
        @sprites["overlay"].bitmap.blt(424,118,typebitmap.bitmap,type1rect)
        @sprites["overlay"].bitmap.blt(524,118,typebitmap.bitmap,type2rect) if type1!=type2
      end
      compatbitmap.dispose
      typebitmap.dispose
      colorbitmap.dispose
    else
      textpos.push([_INTL("????? Pokémon"),372,74,0,basecolor2])
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_INTL("???'??\""),594,158,1,basecolor2])
        textpos.push([_INTL("????.? lbs."),628,190,1,basecolor2])
      else
        textpos.push([_INTL("????.? m"),604,158,1,basecolor2])
        textpos.push([_INTL("????.? kg"),616,190,1,basecolor2])
      end
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    @sprites["entryicon"].setSpeciesBitmapDex(species,(gender==1),form,false,false,false,false,false)
    pbPositionPokemonSpriteMirr(@sprites["entryicon"],104,70)
  end
  
  def pbDexEntry(index,canmove=true)
    oldsprites=pbFadeOutAndHide(@sprites)
    pbChangeToDexEntry(@dexlist[index][0]) if canmove
    pbChangeToDexEntry(index) if !canmove
    pbFadeInAndShow(@sprites)
    curindex=index
    page=1
    newpage=0
    ret=0
    pbActivateWindow(@sprites,nil){
       loop do
         Graphics.update if page==1
         Input.update
         pbUpdate
         if Input.trigger?(Input::B) ||
            ret==1
           if page==1
             pbPlayCancelSE()
             pbFadeOutAndHide(@sprites)
           end
           @sprites["entryicon"].clearBitmap
           break
         elsif (Input.trigger?(Input::UP) && canmove) || ret==8
           nextindex=-1
           i=curindex-1; loop do break unless i>=0
             if $Trainer.seen[@dexlist[i][0]]
              pbSEStop;
              pbPlayCursorSE()
#             pbFadeOutAndHide(@sprites)
              nextindex=i
             break
             end
             i-=1
           end
           if nextindex>=0
             curindex=nextindex
             newpage=page
           end
        #   pbPlayCursorSE() if newpage>1
         elsif (Input.trigger?(Input::DOWN) && canmove) || ret==2
           nextindex=-1
           for i in curindex+1...@dexlist.length
             if $Trainer.seen[@dexlist[i][0]]
               pbSEStop;
               pbPlayCursorSE()
#              pbFadeOutAndHide(@sprites)
               nextindex=i
              break
             end
           end
           if nextindex>=0
             curindex=nextindex
             newpage=page
           end
        #   pbPlayCursorSE() if newpage>1
         elsif Input.trigger?(Input::LEFT) || ret==4
           newpage=page-1 if page>1
           pbPlayCursorSE() if page>1
         elsif Input.trigger?(Input::RIGHT) || ret==6
           newpage=page+1 if page<3
           pbPlayCursorSE() if newpage>1
         elsif Input.trigger?(Input::X)
           pbPlayDecisionSE()
           @compat=!@compat
           @sprites["dexentry2"].visible=@compat
# Start
    if $Trainer.owned[@dexlist[curindex][0]]
      pbDexEntryBitmaps(@dexlist[curindex][0])
    end
# End
         elsif Input.trigger?(Input::A)
           # pbPlayCry(@dexlist[curindex][0])
           pbSEStop;
           pbPlayCry(@dummypokemon)
         end
         ret=0
         if newpage>0
           page=newpage
           newpage=0
           listlimits=0
           listlimits+=1 if curindex==0                 # At top of list
           listlimits+=2 if curindex==@dexlist.length-1 # At bottom of list
           case page
           when 1 # Show entry
             pbChangeToDexEntry(@dexlist[curindex][0])
           when 2 # Show nest
             region=-1
             if !DEXDEPENDSONLOCATION
               dexnames=pbDexNames
               if dexnames[pbGetSavePositionIndex].is_a?(Array)
                 region=dexnames[pbGetSavePositionIndex][1]
               end
             end
             scene=PokemonNestMapScene.new
             screen=PokemonNestMap.new(scene)
             ret=screen.pbStartScreen(@dexlist[curindex][0],region,listlimits)
           when 3 # Show forms
             scene=PokedexFormScene.new
             screen=PokedexForm.new(scene)
             ret=screen.pbStartScreen(@dexlist[curindex][0],listlimits)
           end
         end
       end
    }
    $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]=curindex if !@searchResults
    @sprites["pokedex"].index=curindex
    @sprites["pokedex"].refresh
    iconspecies=@sprites["pokedex"].species
    iconspecies=0 if !$Trainer.seen[iconspecies]
    setIconBitmap(iconspecies)
    if iconspecies>0
      @sprites["header"].text=_INTL("{1} - {2}",@dexname,PBSpecies.getName(iconspecies))
    else
      @sprites["header"].text=_INTL("{1}",@dexname)
    end
    # Update the slider
    ycoord=62
    if @sprites["pokedex"].itemCount>1
      ycoord+=236.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
    end
    @sprites["slider"].y=ycoord
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbDexSearch
    oldsprites=pbFadeOutAndHide(@sprites)
    params=[]
    params[0]=0
    params[1]=0
    params[2]=0
    params[3]=0
    params[4]=0
    params[5]=$PokemonGlobal.pokedexMode
    @nameCommands=[
       _INTL("Don't specify"),
       _INTL("ABC"),_INTL("DEF"),_INTL("GHI"),
       _INTL("JKL"),_INTL("MNO"),_INTL("PQR"),
       _INTL("STU"),_INTL("VWX"),_INTL("YZ")
    ]
    @typeCommands=[
       _INTL("None"),
       _INTL("Normal"),_INTL("Fighting"),_INTL("Flying"),
       _INTL("Poison"),_INTL("Ground"),_INTL("Rock"),
       _INTL("Bug"),_INTL("Ghost"),_INTL("Steel"),
       _INTL("Fire"),_INTL("Water"),_INTL("Grass"),
       _INTL("Electric"),_INTL("Psychic"),_INTL("Ice"),
       _INTL("Dragon"),_INTL("Dark"),_INTL("Fairy"),
       _INTL("Magic"),_INTL("Doom"),_INTL("Jelly"),
       _INTL("Shadow"),_INTL("Sharpener"),_INTL("Lava"),
       _INTL("Wind"),_INTL("Lick"),_INTL("Bolt"),
       _INTL("Herb"),_INTL("Chlorophyll"),_INTL("Gust"),
       _INTL("Sun"),_INTL("Moon"),_INTL("Mind"),_INTL("Heart"),
       _INTL("Blizzard"),_INTL("Gastro"),_INTL("Glimse")
    ]
    @colorCommands=[_INTL("Don't specify")]
    for i in 0..PBColors.maxValue
      j=PBColors.getName(i)
      @colorCommands.push(j) if j
    end
#    @colorCommands=[
#       _INTL("Don't specify"),
#       _INTL("Red"),_INTL("Blue"),_INTL("Yellow"),
#       _INTL("Green"),_INTL("Black"),_INTL("Brown"),
#       _INTL("Purple"),_INTL("Gray"),_INTL("White"),_INTL("Pink")
#    ]
    @orderCommands=[
       _INTL("Numeric Mode"),
       _INTL("A to Z Mode"),
       _INTL("Heaviest Mode"),
       _INTL("Lightest Mode"),
       _INTL("Tallest Mode"),
       _INTL("Smallest Mode")
    ]
    @orderHelp=[
       _INTL("Pokémon are listed according to their number."),
       _INTL("Spotted and owned Pokémon are listed alphabetically."),
       _INTL("Owned Pokémon are listed from heaviest to lightest."),
       _INTL("Owned Pokémon are listed from lightest to heaviest."),
       _INTL("Owned Pokémon are listed from tallest to smallest."),
       _INTL("Owned Pokémon are listed from smallest to tallest.")
    ]
    @sprites["searchlist"].index=1
    searchlist=@sprites["searchlist"]
    @sprites["messagebox"].visible=true
    @sprites["auxlist"].visible=true
    @sprites["searchlist"].visible=true
    @sprites["searchbg"].visible=true
    @sprites["searchtitle"].visible=true
    pbRefreshDexSearch(params)
    pbFadeInAndShow(@sprites)
    pbActivateWindow(@sprites,"searchlist"){
       loop do
         Graphics.update
         Input.update
         oldindex=searchlist.index
         pbUpdate
         if searchlist.index==0
           if oldindex==9 && Input.trigger?(Input::DOWN)
             searchlist.index=1
           elsif oldindex==1 && Input.trigger?(Input::UP)
             searchlist.index=9
           else
             searchlist.index=1
           end
         elsif searchlist.index==7
           if oldindex==8
             searchlist.index=6
           else
             searchlist.index=8
           end
         end
         if searchlist.index!=oldindex
           pbRefreshDexSearch(params)
         end
         if Input.trigger?(Input::C)
           pbPlayDecisionSE()
           command=searchlist.indexToCommand(searchlist.index)
           if command==[2,0]
             break
           end
           if command==[0,0]
             params[0]=pbDexSearchCommands(@nameCommands,params[0])
             pbRefreshDexSearch(params)
           elsif command==[0,1]
             params[1]=pbDexSearchCommands(@colorCommands,params[1])
             pbRefreshDexSearch(params)
           elsif command==[0,2]
             params[2]=pbDexSearchCommands(@typeCommands,params[2])
             pbRefreshDexSearch(params)
           elsif command==[0,3]
             params[3]=pbDexSearchCommands(@typeCommands,params[3])
             pbRefreshDexSearch(params)
           elsif command==[0,4]
             params[4]=pbDexSearchCommands(@orderCommands,params[4],@orderHelp)
             pbRefreshDexSearch(params)
           elsif command==[0,5]
             dexlist=pbSearchDexList(params)
             if dexlist.length==0
               Kernel.pbMessage(_INTL("No matching Pokémon were found."))
             else
               @dexlist=dexlist
               @sprites["pokedex"].commands=@dexlist
               @sprites["pokedex"].index=0
               @sprites["pokedex"].refresh
               iconspecies=@sprites["pokedex"].species
               iconspecies=0 if !$Trainer.seen[iconspecies]
               setIconBitmap(iconspecies)
               if iconspecies>0
                 @sprites["header"].text=_INTL("{1} - {1}",@dexname,PBSpecies.getName(iconspecies))
               else
                 @sprites["header"].text=_INTL("{1}",@dexname)
               end
               seenno=0
               ownedno=0
               for i in dexlist
                 seenno+=1 if $Trainer.seen[i[0]]
                 ownedno+=1 if $Trainer.owned[i[0]]
               end
               @sprites["seen"].text=_ISPRINTF("Seen:<r>{1:d}",seenno)
               @sprites["owned"].text=_ISPRINTF("Owned:<r>{1:d}",ownedno)
               @dexname=_INTL("Pokédex")
               if $PokemonGlobal.pokedexUnlocked.length>1
                 thisdex=pbDexNames[pbGetSavePositionIndex]
                 if thisdex!=nil
                   if thisdex.is_a?(Array)
                     @dexname=thisdex[0]
                   else
                     @dexname=thisdex
                   end
                 end
               end
#               @sprites["dexname"].text=_ISPRINTF("<ac>{1:s} - Search results</ac>",@dexname)
               # Update the slider
               ycoord=62
               if @sprites["pokedex"].itemCount>1
                 ycoord+=236.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
               end
               @sprites["slider"].y=ycoord
               @searchResults=true
               break
             end
           elsif command==[1,0]
             params[5]=pbDexSearchCommands(@orderCommands,params[5],@orderHelp)
             pbRefreshDexSearch(params)
           elsif command==[1,1]
             $PokemonGlobal.pokedexMode=params[5]
             $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]=0
             pbRefreshDexList
             break
           end
         elsif Input.trigger?(Input::B)
           pbPlayCancelSE()
           break
         end
       end
    }
    pbFadeOutAndHide(@sprites)
    pbFadeInAndShow(@sprites,oldsprites)
    Input.update
    return 0
  end


  
  def pbCloseSearch
    oldsprites=pbFadeOutAndHide(@sprites)
    @searchResults=false
    $PokemonGlobal.pokedexMode=0
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbPokedex
    pbActivateWindow(@sprites,"pokedex"){
       loop do
         Graphics.update
         Input.update
         oldindex=@sprites["pokedex"].index
         pbUpdate
         if oldindex!=@sprites["pokedex"].index
           $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]=@sprites["pokedex"].index if !@searchResults
           iconspecies=@sprites["pokedex"].species
           iconspecies=0 if !$Trainer.seen[iconspecies]
           setIconBitmap(iconspecies)
           if iconspecies>0
             @sprites["header"].text=_INTL("{1} - {2}",@dexname,PBSpecies.getName(iconspecies))
           else
             @sprites["header"].text=_INTL("{1}",@dexname)
           end
           # Update the slider
           ycoord=62
           if @sprites["pokedex"].itemCount>1
             ycoord+=236.0 * @sprites["pokedex"].index/(@sprites["pokedex"].itemCount-1)
           end
           @sprites["slider"].y=ycoord
         end
         if Input.trigger?(Input::B)
           pbPlayCancelSE()
           if @searchResults
             pbCloseSearch
           else
             break
           end
           elsif Input.trigger?(Input::C)
           if $Trainer.seen[@sprites["pokedex"].species]
             pbPlayDecisionSE()
             pbDexEntry(@sprites["pokedex"].index)
           end
         elsif Input.trigger?(Input::F5)
           pbPlayDecisionSE()
           pbDexSearch
         end
       end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonPokedex
  def initialize(scene)
    @scene=scene
  end
  
  def pbStartSceneSingle(species)   # For use from a Pokémon's summary screen
    region = -1
    if DEXDEPENDSONLOCATION
      region = pbGetCurrentRegion
      region = -1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
    else
      region = $PokemonGlobal.pokedexDex # National Dex -1, regional dexes 0 etc.
    end
    dexnum = pbGetRegionalNumber(region,species)
    dexnumshift = DEXINDEXOFFSETS.include?(region)
    dexlist = [[species,PBSpecies.getName(species),0,0,dexnum,dexnumshift]]
    @scene.pbDexEntry(dexlist,false)
  #  @scene.pbScene
    @scene.pbEndScene
  end


  def pbDexEntry2(species)
    @scene.pbStartDexEntryScene(species)
    @scene.pbMiddleDexEntryScene
    @scene.pbEndScene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPokedex
    @scene.pbEndScene
  end
end