class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport=nil,fifthmove=false)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/UI/"+getAccentFolder+"/summarymovesel")
    @frame=0
    @index=0
    @fifthmove=fifthmove
    @preselected=false
    @preselected=false
    @updating=false
    @spriteVisible=true
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index=value
    refresh
  end

  def preselected=(value)
    @preselected=value
    refresh
  end

  def visible=(value)
    super
    @spriteVisible=value if !@updating
  end

  def refresh
    w=@movesel.width
    h=@movesel.height/2
    self.x=368
    self.y=92+(self.index*64)
    self.y-=54 if @fifthmove
    self.y+=10 if @fifthmove && self.index==4
    self.bitmap=@movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating=true
    super
    @movesel.update
    @updating=false
    refresh
  end
end



class PokemonSummaryScene
  def pbPokerus(pkmn)
    return pkmn.pokerusStage
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbShowPokedex(species)
    pbFadeOutIn(99999){
       scene=PokemonPokedexScene.new
       screen=PokemonPokedex.new(scene)
       screen.pbStartSceneSingle(species)
    }
  end

  def pbStartScene(party,partyindex)
    $summarysizex = 80
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 0
    @typebitmap = AnimatedBitmap.new("Graphics/UI/Types")
    @compatbitmap = AnimatedBitmap.new("Graphics/UI/compatibilities")
    @colorbitmap = AnimatedBitmap.new("Graphics/UI/colors")
    @markingbitmap = AnimatedBitmap.new("Graphics/UI/"+getDarkModeFolder+"/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Summary"),
       2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].mirror = true
    @sprites["pokemon"].color=Color.new(0,0,0,0)
    pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,144)
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x = 46
    @sprites["pokeicon"].y = 54
    @sprites["pokeicon"].mirror = false
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(40,318,@pokemon.item,@viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["movepresel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party,partyindex,moveToLearn)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    @sprites={}
    @page=3
    @typebitmap=AnimatedBitmap.new("Graphics/UI/Types")
    @compatbitmap=AnimatedBitmap.new("Graphics/UI/compatibilities")
    @colorbitmap=AnimatedBitmap.new("Graphics/UI/colors")
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Summary"),
       2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=46
    @sprites["pokeicon"].y=56
    @sprites["pokeicon"].mirror=false
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport,moveToLearn>0)
    @sprites["movesel"].visible=false
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    drawSelectedMove(moveToLearn,@pokemon.moves[0].id)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @colorbitmap.dispose
    @compatbitmap.dispose
    @viewport.dispose
  end

  def drawMarkings(bitmap,x,y,width,height,markings)
    markings = @pokemon.markings if !markings
    markrect = Rect.new(0,0,16,16)
    for i in 0...6
      markrect.x = i*16
      markrect.y = (markings&(1<<i)!=0) ? 16 : 0
      bitmap.blt(x+i*16,y,@markingbitmap.bitmap,markrect)
    end
  end
  
  def drawPage(page)
    # Draw Icons
    @sprites["itemicon"].item = @pokemon.item
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    imagepos=[]
    if !@pokemon.egg?
      if pbPokerus(@pokemon)==1 || @pokemon.hp==0 || @pokemon.status>0
        status=6 if pbPokerus(@pokemon)==1
        status=@pokemon.status-1 if @pokemon.status>0
        status=5 if @pokemon.hp==0
        imagepos.push(["Graphics/UI/statuses",264,100,0,16*status,44,16])
      end
      if @pokemon.isShiny?
        imagepos.push([sprintf("Graphics/UI/shiny"),2,134,0,0,-1,-1])
      end
      if pbPokerus(@pokemon)==2
        imagepos.push([sprintf("Graphics/UI/Summary/icon_pokerus"),176,100,0,0,-1,-1])
      end
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Battle animations/ball_%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,64,2,18,28,28])
    pbDrawImagePositions(overlay,imagepos)
    # Draw Text
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
    pokename=@pokemon.name
    textpos=[
       [pokename,46,62,0,base,shadow],
       [_INTL("Item"),76,316,0,base,shadow],
    ]
    textpos.push([@pokemon.level.to_s,46,92,0,base,shadow]) if !@pokemon.egg?
    if @pokemon.hasItem?
      textpos.push([PBItems.getName(@pokemon.item),16,346,0,base,shadow])
    else
      textpos.push([_INTL("None"),16,346,0,baseT,shadowT])
    end
    gendericon=[]
    if @pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/UI/"+getDarkModeFolder+"/gender_male",316,68,0,0,-1,-1])
    elsif @pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/UI/"+getDarkModeFolder+"/gender_female",316,68,0,0,-1,-1])
    elsif @pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/UI/"+getDarkModeFolder+"/gender_transgender",316,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos) 
    # Draw Markings
    drawMarkings(overlay,79,291,72,20,@pokemon.markings)
    # Draw actual contents
    case page
    when 0
      drawPageOne # Pokemon Information
    when 1
      drawPageTwo # Trainer Information
    when 2
      drawPageThree # Pokemon Statistics
    when 3
      drawPageFour # Personal Values
    when 4
      drawPageFive # Battle Information
    when 5
      drawPageSix # Pokemon Moves
    when 6
      drawPageSeven # Ribbons
    when 7
      drawPageEight # Family Tree
    when 8
      drawPageNine # Advanced Information
    end
    pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,144)
  end

  def drawPageOne
    if @pokemon.isEgg?
      drawPageOneEgg
      return
    end
    @sprites["header"].text="Pokémon Information"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_1")
    imagepos=[]
    growthrate=@pokemon.growthrate
    startexp=PBExperience.pbGetStartExperience(@pokemon.level,growthrate)
    endexp=PBExperience.pbGetStartExperience(@pokemon.level+1,growthrate)
    finexp=PBExperience.pbGetStartExperience(PBExperience::MAXLEVEL,growthrate)
    if (@pokemon.isShadow? rescue false)
      imagepos.push(["Graphics/UI/"+getDarkModeFolder+"/Summary/overlay_shadow",346,254,0,0,-1,-1])
      shadowfract=@pokemon.heartgauge*1.0/PokeBattle_Pokemon::HEARTGAUGESIZE
      imagepos.push(["Graphics/UI/Summary/overlay_shadowbar",370,291,0,0,(shadowfract*248).floor,-1])
    else
      shadowfract1=(@pokemon.exp)*100/(finexp)
      imagepos.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",370,291,0,0,(shadowfract1*2.48).floor,-1])
      if @pokemon.level<PBExperience::MAXLEVEL
        shadowfract2=(@pokemon.exp-startexp)*100/(endexp - startexp)
        imagepos.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",370,351,0,0,(shadowfract2*2.48).floor,-1])
      end
    end
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      hardBase=Color.new(248,56,32)
      hardShadow=Color.new(224,152,144)
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      hardBase=Color.new(224,152,144)
      hardShadow=Color.new(248,56,32)
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    
    pbSetSystemFont(overlay)
    numberbase=(@pokemon.isShiny?) ? hardBase : base
    numbershadow=(@pokemon.isShiny?) ? hardShadow : shadow
    publicID=@pokemon.publicID
    speciesname=PBSpecies.getName(@pokemon.species)
    fdexno = getDexNumber(@pokemon.species) # If none of the following conditions are met, it is Generation I-V Pokemon
    # Find Color
    colourd=@pokemon.color
    textpos=[
 #      [_INTL("Pokémon Information"),26,8,0,base,shadow,1],
       [_ISPRINTF("Dex No."),366,44,0,base2,nil,0],
       [_INTL("{1}",fdexno),563,44,2,numberbase,numbershadow],
       [_INTL("Species"),366,74,0,base2,nil,0],
       [speciesname,563,74,2,base,shadow],
       [_INTL("Color"),366,104,0,base2,nil,0],
       [_INTL("Egg Groups"),366,134,0,base2,nil,0],
       [_INTL("Type"),366,164,0,base2,nil,0],
       [_INTL("OT"),366,194,0,base2,nil,0],
       [_INTL("ID No."),366,224,0,base2,nil,0],
    ]
    if (@pokemon.isShadow? rescue false)
      textpos.push([_INTL("Heart Gauge"),366,254,0,base2,nil,0])
      heartmessage=[_INTL("The door to its heart is open! Undo the final lock!"),
                    _INTL("The door to its heart is almost fully open."),
                    _INTL("The door to its heart is nearly open."),
                    _INTL("The door to its heart is opening wider."),
                    _INTL("The door to its heart is opening up."),
                    _INTL("The door to its heart is tightly shut.")
                    ][@pokemon.heartStage]
      memo=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),heartmessage)
      drawFormattedTextEx(overlay,366,314,276,memo,nil,nil,30)
    else
      textpos.push([_INTL("Exp. Points"),366,254,0,base2,nil,0])
      textpos.push([_INTL("{1}",@pokemon.exp.to_s_formatted),495,283,2,base2,shadow2,1])
      textpos.push([_INTL("To Next Lv."),366,314,0,base2,nil,0])
      textpos.push([_INTL("{1}",(endexp-@pokemon.exp).to_s_formatted),495,343,2,base2,shadow2,1])
    end
    idno=(@pokemon.ot=="") ? "?????" : sprintf("%05d",publicID)
    textpos.push([idno,563,224,2,base,shadow])
    if @pokemon.ot==""
      textpos.push([_INTL("Rental"),563,194,2,base,shadow])
    else
      ownerbase=base
      ownershadow=shadow
      if @pokemon.otgender==0 # male OT
        if (!isDarkMode?)
          ownerbase=Color.new(24,112,216)
          ownershadow=Color.new(136,168,208)
        else
          ownerbase=Color.new(136,168,208)
          ownershadow=Color.new(24,112,216)
        end
      elsif @pokemon.otgender==1 # female OT
        if (!isDarkMode?)
          ownerbase=Color.new(248,56,32)
          ownershadow=Color.new(224,152,144)
        else
          ownerbase=Color.new(224,152,144)
          ownershadow=Color.new(248,56,32)
        end
      end
      textpos.push([@pokemon.ot,563,194,2,ownerbase,ownershadow])
    end
    pbDrawTextPositions(overlay,textpos)
    colorrect=Rect.new(64*0,colourd*28,64,28)
    type1rect=Rect.new(64*0,@pokemon.type1*28,64,28)
    type2rect=Rect.new(64*0,@pokemon.type2*28,64,28)
    compat1rect=Rect.new(64*0,(@pokemon.egroup1-1)*28,64,28)
    compat2rect=Rect.new(64*0,(@pokemon.egroup2-1)*28,64,28)
    overlay.blt(532,104,@colorbitmap.bitmap,colorrect)
    if @pokemon.egroup1==@pokemon.egroup2
      overlay.blt(532,134,@compatbitmap.bitmap,compat1rect)
    else
      overlay.blt(498,134,@compatbitmap.bitmap,compat1rect)
      overlay.blt(564,134,@compatbitmap.bitmap,compat2rect)
    end
    if @pokemon.type1==@pokemon.type2
      overlay.blt(532,164,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(498,164,@typebitmap.bitmap,type1rect)
      overlay.blt(564,164,@typebitmap.bitmap,type2rect)
    end
   # if @pokemon.level<PBExperience::MAXLEVEL
     # overlay.fill_rect(362,372,(@pokemon.exp-startexp)*128/(endexp-startexp),2,Color.new(72,120,160))
     # overlay.fill_rect(362,374,(@pokemon.exp-startexp)*128/(endexp-startexp),4,Color.new(24,144,248))
   # end

   end

  def drawPageOneEgg
    @sprites["header"].text="Trainer Information"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_egg")
    imagepos=[]
#    ballused=@pokemon.ballused ? @pokemon.ballused : 0
#    ballimage=sprintf("Graphics/UI/Summary/icon_ball_%02d",@pokemon.ballused)
#    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Egg Steps Start
     dexdata=pbOpenDexData
     pbDexDataOffset(dexdata,@pokemon.species,21)
     maxesteps=dexdata.fgetw
     dexdata.close
    shadowfract=@pokemon.eggsteps*1.0/maxesteps # Egg Steps TMP
      imagepos.push(["Graphics/UI/"+getAccentFolder+"/summaryEggBar",370,261,0,0,(shadowfract*248).floor,-1])
    # Egg Steps End
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
    textpos=[
 #      [_INTL("Trainer Information"),26,8,0,base,shadow,1],
    ]
    if @pokemon.isRB?
      textpos.push([_INTL("Remote Box Battery"),366,224,0,base2,nil,0])
    else
      textpos.push([_INTL("The Egg Watch"),366,224,0,base2,nil,0])
    end
    pbDrawTextPositions(overlay,textpos)
    memo=""
    if @pokemon.timeReceived
      month=pbGetAbbrevMonthName(@pokemon.timeReceived.mon)
      date=@pokemon.timeReceived.day
      year=@pokemon.timeReceived.year
      memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
    end
    mapname=pbGetMapNameFromId(@pokemon.obtainMap)
    if (@pokemon.obtainText rescue false) && @pokemon.obtainText!=""
      mapname=@pokemon.obtainText
    end
    if (!isDarkMode?)
      redbase = 'F83820'
      redshadow = 'E09890'
    else
      redbase = 'EBBCB7'
      redshadow = 'DF2007'
    end
    if mapname && mapname!=""
      if @pokemon.isRB?
        memo+=_INTL("<c3={1},{2}>A magnetic Remote Box received from <c3={3},{4}>{5}<c3={1},{2}>.\n",colorToRgb32(base),colorToRgb32(shadow),redbase,redshadow,mapname)
      else
        memo+=_INTL("<c3={1},{2}>A mysterious Pokémon Egg received from <c3={3},{4}>{5}<c3={1},{2}>.\n",colorToRgb32(base),colorToRgb32(shadow),redbase,redshadow,mapname)
      end
    end
#    memo+=_INTL("<c3={1},{2}>\n",colorToRgb32(base),colorToRgb32(shadow))
    if @pokemon.isRB?
      eggstate=_INTL("It looks like the Remote Box's battery is in its prime.")
      eggstate=_INTL("Remote Box's battery is currently in a good condition.") if shadowfract*100 < 76
      eggstate=_INTL("Remote Box's battery is close to run out. It may be close to open!") if shadowfract*100 < 51
      eggstate=_INTL("Remote Box's battery is about to run out! It will open soon!") if shadowfract*100 < 26
    else
      eggstate=_INTL("It looks like this Egg will take a long time to hatch.")
      eggstate=_INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.eggsteps<10200
      eggstate=_INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.eggsteps<2550
      eggstate=_INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.eggsteps<1275
    end
    eggstatemsg=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),eggstate)
    drawFormattedTextEx(overlay,360,282,272,eggstatemsg,nil,nil,30)
    drawFormattedTextEx(overlay,360,44,276,memo,nil,nil,30)
#    drawFormattedTextEx(overlay,360,222,276,memo2,nil,nil,30)
  end

  def drawPageTwo
    @sprites["header"].text="Trainer Information"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_2")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
    naturename=PBNatures.getName(@pokemon.nature)
    mintname=PBNatures.getName(@pokemon.mint) if @pokemon.mint!=-1
    textpos=[
  #     [_INTL("Trainer Information"),26,8,0,base,shadow,1],
    ]
    pbDrawTextPositions(overlay,textpos)
    if (!isDarkMode?)
      redbase = 'F83820'
      redshadow = 'E09890'
    else
      redbase = 'EBBCB7'
      redshadow = 'DF2007'
    end
    memo=""
    shownature=(!(@pokemon.isShadow? rescue false)) || @pokemon.heartStage<=3
    if shownature
      memo+=_INTL("<c3={1},{2}>{3}<c3={4},{5}> nature.\n",redbase,redshadow,naturename,colorToRgb32(base),colorToRgb32(shadow))
      memo+=_INTL("<c3={1},{2}>{3}<c3={4},{5}> mint.\n",redbase,redshadow,mintname,colorToRgb32(base),colorToRgb32(shadow)) if mintname
    end
    if @pokemon.timeReceived
      month=pbGetAbbrevMonthName(@pokemon.timeReceived.mon)
      date=@pokemon.timeReceived.day
      year=@pokemon.timeReceived.year
      memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
    end
    mapname=pbGetMapNameFromId(@pokemon.obtainMap)
    if (@pokemon.obtainText rescue false) && @pokemon.obtainText!=""
      mapname=@pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=sprintf("<c3=%s,%s>%s\n",redbase,redshadow,mapname)
    else
      memo+=_INTL("<c3={1},{2}>Unkown area\n",redbase,redshadow) # Faraway place
    end
    if @pokemon.obtainMode
      mettext=[_INTL("Met at Lv. {1}.",@pokemon.obtainLevel),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.",@pokemon.obtainLevel),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.",@pokemon.obtainLevel),
               _INTL("Remote Box received.")
               ][@pokemon.obtainMode]
      memo+=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),mettext)
      if @pokemon.obtainMode==1 # hatched
        if @pokemon.timeEggHatched
          month=pbGetAbbrevMonthName(@pokemon.timeEggHatched.mon)
          date=@pokemon.timeEggHatched.day
          year=@pokemon.timeEggHatched.year
          memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
        end
        mapname=pbGetMapNameFromId(@pokemon.hatchedMap)
        if mapname && mapname!=""
          memo+=sprintf("<c3=%s,%s>%s\n",redbase,redshadow,mapname)
        else
          memo+=_INTL("<c3={1},{2}>Unknown area\n",redbase,redshadow)
        end
        memo+=_INTL("<c3={1},{2}>Egg hatched.\n",colorToRgb32(base),colorToRgb32(shadow))
      elsif @pokemon.obtainMode==5 # Box opened
        if @pokemon.timeEggHatched
          month=pbGetAbbrevMonthName(@pokemon.timeEggHatched.mon)
          date=@pokemon.timeEggHatched.day
          year=@pokemon.timeEggHatched.year
          memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
        end
        mapname=pbGetMapNameFromId(@pokemon.hatchedMap)
        if mapname && mapname!=""
          memo+=sprintf("<c3=%s,%s>%s\n",redbase,redshadow,mapname)
        else
          memo+=_INTL("<c3={1},{2}>Unknown area\n",redbase,redshadow)
        end
        memo+=_INTL("<c3={1},{2}>Remote Box opened.\n",colorToRgb32(base),colorToRgb32(shadow))
      else
        memo+=_INTL("<c3={1},{2}>\n",colorToRgb32(base),colorToRgb32(shadow))
      end
    end
    if shownature
      bestiv=0
      tiebreaker=@pokemon.personalID%6
      for i in 0...6
        if @pokemon.iv[i]==@pokemon.iv[bestiv]
          bestiv=i if i>=tiebreaker && bestiv<tiebreaker
        elsif @pokemon.iv[i]>@pokemon.iv[bestiv]
          bestiv=i
        end
      end
      characteristic=[_INTL("Loves to eat."),
                      _INTL("Often dozes off."),
                      _INTL("Often scatters things."),
                      _INTL("Scatters things often."),
                      _INTL("Likes to relax."),
                      _INTL("Proud of its power."),
                      _INTL("Likes to thrash about."),
                      _INTL("A little quick tempered."),
                      _INTL("Likes to fight."),
                      _INTL("Quick tempered."),
                      _INTL("Sturdy body."),
                      _INTL("Capable of taking hits."),
                      _INTL("Highly persistent."),
                      _INTL("Good endurance."),
                      _INTL("Good perseverance."),
                      _INTL("Likes to run."),
                      _INTL("Alert to sounds."),
                      _INTL("Impetuous and silly."),
                      _INTL("Somewhat of a clown."),
                      _INTL("Quick to flee."),
                      _INTL("Highly curious."),
                      _INTL("Mischievous."),
                      _INTL("Thoroughly cunning."),
                      _INTL("Often lost in thought."),
                      _INTL("Very finicky."),
                      _INTL("Strong willed."),
                      _INTL("Somewhat vain."),
                      _INTL("Strongly defiant."),
                      _INTL("Hates to lose."),
                      _INTL("Somewhat stubborn.")
                      ][bestiv*5+@pokemon.iv[bestiv]%5]
      memo+=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),characteristic)
    end
    drawFormattedTextEx(overlay,360,44,276,memo,nil,nil,30)
  end

  def drawPageThree
    @sprites["header"].text="Pokémon Statistics"
    $summarysizex = 40
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_3")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    nat = (@pokemon.mint!=-1) ? @pokemon.mint : @pokemon.nature
    statshadows=[]
    for i in 0...5; statshadows[i]=nil; end
    if !(@pokemon.isShadow? rescue false) || @pokemon.heartStage<=3
#      natup=(@pokemon.nature/5).floor
#      natdn=(@pokemon.nature%5).floor
      natup=(nat/5).floor
      natdn=(nat%5).floor
      if (!isDarkMode?)
        if (natup == 1 || natup == 4)
          statshadows[natup]=Color.new(183,143,119) if natup!=natdn
        else
          statshadows[natup]=Color.new(136,96,72) if natup!=natdn
        end
        if (natdn == 1 || natdn == 4)
          statshadows[natdn]=Color.new(103,159,191) if natup!=natdn
        else
          statshadows[natdn]=Color.new(64,120,152) if natup!=natdn
        end
      else
        statshadows[natup]=Color.new(183,143,119) if natup!=natdn
        statshadows[natdn]=Color.new(103,159,191) if natup!=natdn
      end
    end
    pbSetSystemFont(overlay)
    abilityname=PBAbilities.getName(@pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,@pokemon.ability)
    textpos=[
      # [_INTL("Pokémon Statistics"),26,8,0,base,shadow,1],
       [_INTL("HP"),366,44,0,base2,nil,0],
       [sprintf("%3d/%3d",@pokemon.hp,@pokemon.totalhp),563,44,2,base,shadow],
       [_INTL("Attack"),366,82,0,base2,statshadows[0],0],
       [sprintf("%d",@pokemon.attack),563,82,2,base,shadow],
       [_INTL("Defense"),366,112,0,base2,statshadows[1],0],
       [sprintf("%d",@pokemon.defense),563,112,2,base,shadow],
       [_INTL("Sp. Atk"),366,142,0,base2,statshadows[3],0],
       [sprintf("%d",@pokemon.spatk),563,142,2,base,shadow],
       [_INTL("Sp. Def"),366,172,0,base2,statshadows[4],0],
       [sprintf("%d",@pokemon.spdef),563,172,2,base,shadow],
       [_INTL("Speed"),366,202,0,base2,statshadows[2],0],
       [sprintf("%d",@pokemon.speed),563,202,2,base,shadow],
       [_INTL("Ability"),288-64,230,0,base2,nil,0],
       [abilityname,426-64,230,0,base,shadow],
      ]
    pbDrawTextPositions(overlay,textpos)
#    drawTextEx(overlay,224,256,410,4,abilitydesc,base,shadow,30)
    drawFormattedTextEx(overlay,224,256,410,abilitydesc,base,shadow,30)
    # Draw HP bar
    if @pokemon.hp>0
      hpzone = 0
      hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
      imagepos = [
         ["Graphics/UI/Summary/overlay_hp",488,74,0,hpzone*6,@pokemon.hp*96/@pokemon.totalhp,6]
      ]
      pbDrawImagePositions(overlay,imagepos)
    end
  end

def drawPageFour
    @sprites["header"].text="Personal Values"
    $summarysizex = 40
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_4")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    nat = (@pokemon.mint!=-1) ? @pokemon.mint : @pokemon.nature
    statshadows=[]
    for i in 0...5; statshadows[i]=nil end
    if !(@pokemon.isShadow? rescue false) || @pokemon.heartStage<=3
#      natup=(@pokemon.nature/5).floor
#      natdn=(@pokemon.nature%5).floor
      natup=(nat/5).floor
      natdn=(nat%5).floor
      if (!isDarkMode?)
        if (natup == 1 || natup == 4)
          statshadows[natup]=Color.new(183,143,119) if natup!=natdn
        else
          statshadows[natup]=Color.new(136,96,72) if natup!=natdn
        end
        if (natdn == 1 || natdn == 4)
          statshadows[natdn]=Color.new(103,159,191) if natup!=natdn
        else
          statshadows[natdn]=Color.new(64,120,152) if natup!=natdn
        end
      else
        statshadows[natup]=Color.new(183,143,119) if natup!=natdn
        statshadows[natdn]=Color.new(103,159,191) if natup!=natdn
      end
    end
    pbSetSystemFont(overlay)
    abilityname=PBAbilities.getName(@pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,@pokemon.ability)
    textpos=[
    #   [_INTL("Personal Values"),26,8,0,base,shadow,1],
       [_INTL("HP"),366,52,0,base2,nil,0],
       [sprintf("EV: %d",@pokemon.ev[0]),528,52,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[0]),596,52,2,base,shadow],
       [_INTL("Attack"),366,82,0,base2,statshadows[0],0],
       [sprintf("EV: %d",@pokemon.ev[1]),528,82,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[1]),596,82,2,base,shadow],
       [_INTL("Defense"),366,112,0,base2,statshadows[1],0],
       [sprintf("EV: %d",@pokemon.ev[2]),528,112,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[2]),596,112,2,base,shadow],
       [_INTL("Sp. Atk"),366,142,0,base2,statshadows[3],0],
       [sprintf("EV: %d",@pokemon.ev[4]),528,142,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[4]),596,142,2,base,shadow],
       [_INTL("Sp. Def"),366,172,0,base2,statshadows[4],0],
       [sprintf("EV: %d",@pokemon.ev[5]),528,172,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[5]),596,172,2,base,shadow],
       [_INTL("Speed"),366,202,0,base2,statshadows[2],0],
       [sprintf("EV: %d",@pokemon.ev[3]),528,202,2,base,shadow],
       [sprintf("IV: %d",@pokemon.iv[3]),596,202,2,base,shadow],
       [_INTL("Ability"),288-64,230,0,base2,nil,0],
       [abilityname,426-64,230,0,base,shadow],
      ]
    pbDrawTextPositions(overlay,textpos)
#    drawTextEx(overlay,224,256,410,4,abilitydesc,base,shadow,30)
    drawFormattedTextEx(overlay,224,256,410,abilitydesc,base,shadow,30)
  end

def drawPageFive
    @sprites["header"].text="Battle Information"
    $summarysizex = 40
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_5")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    hiddenpower=pbHiddenPower(@pokemon.iv)
    colourd=@pokemon.favcolor
    colorrect=Rect.new(64*0,colourd*28,64,28)
    type1rect=Rect.new(64*0,hiddenpower[0]*28,64,28)
    type2rect=Rect.new(64*0,@pokemon.favtype*28,64,28)
    overlay.blt(532,82,@typebitmap.bitmap,type1rect)
    overlay.blt(532,112,@colorbitmap.bitmap,colorrect)
    overlay.blt(532,142,@typebitmap.bitmap,type2rect)
    pbSetSystemFont(overlay)
    abilityname=PBAbilities.getName(@pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,@pokemon.ability)
    textpos=[
  #     [_INTL("Battle Information"),26,8,0,base,shadow,1],
       [_INTL("H.P. Damage"),366,52,0,base2,nil,0],
       [sprintf("%d",hiddenpower[1]),563,52,2,base,shadow],
       [_INTL("H.P. Type"),366,82,0,base2,nil,0],
       [_INTL("Favor. Color"),366,112,0,base2,nil,0],
       [_INTL("Favor. Type"),366,142,0,base2,nil,0],
       [_INTL("Recoil Damage"),366,172,0,base2,nil,0],
       [sprintf("%d",@pokemon.recoildamage),563,172,2,base,shadow],
       [_INTL("Critical Hits"),366,202,0,base2,nil,0],
       [sprintf("%d",@pokemon.criticalhits),563,202,2,base,shadow],
       [_INTL("Ability"),288-64,230,0,base2,nil,0],
       [abilityname,426-64,230,0,base,shadow],
      ]
      
    pbDrawTextPositions(overlay,textpos)
#    drawTextEx(overlay,224,256,410,4,abilitydesc,base,shadow,30)
    drawFormattedTextEx(overlay,224,256,410,abilitydesc,base,shadow,30)
  end
  
  def drawPageSix
    @sprites["header"].text="Pokémon Moveset"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_6")
    @sprites["pokemon"].visible=true
    @sprites["pokeicon"].visible=false
    @sprites["itemicon"].visible=true
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
      ppBase   = [base,                   # More than 1/2 of total PP
                  Color.new(248,192,0),   # 1/2 of total PP or less
                  Color.new(248,136,32),  # 1/4 of total PP or less
                  Color.new(248,72,72)]   # Zero PP
      ppShadow = [shadow,                 # More than 1/2 of total PP
                  Color.new(144,104,0),   # 1/2 of total PP or less
                  Color.new(144,72,24),   # 1/4 of total PP or less
                  Color.new(136,48,48)]   # Zero PP
    pbSetSystemFont(overlay)
    textpos=[
  #     [_INTL("Pokémon Moveset"),26,8,0,base,shadow,1],
    ]
    pbDrawTextPositions(overlay,textpos)
    imagepos=[]
    yPos=98
    dark = (isDarkMode?) ? [2,0] : [1,0]
    for i in 0...@pokemon.moves.length
      if @pokemon.moves[i].id>0
        imagepos.push(["Graphics/UI/Types",376,yPos+2,64*0,
           @pokemon.moves[i].type*28,64,28])
        textpos.push([PBMoves.getName(@pokemon.moves[i].id),444,yPos,0,
           base,shadow])
        if @pokemon.moves[i].totalpp>0
          textpos.push([_ISPRINTF("PP"),470,yPos+32,0,
             base,shadow])
          ppfraction = 0
          if @pokemon.moves[i].pp==0;                             ppfraction = 3
          elsif @pokemon.moves[i].pp*4<=@pokemon.moves[i].totalpp; ppfraction = 2
          elsif @pokemon.moves[i].pp*2<=@pokemon.moves[i].totalpp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",@pokemon.moves[i].pp,@pokemon.moves[i].totalpp),
             588,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",444,yPos,0,base,shadow])
        textpos.push(["--",570,yPos+32,1,base,shadow])
      end
      yPos+=64
    end
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
  end

  def drawSelectedMove(moveToLearn,moveid)
    overlay=@sprites["overlay"].bitmap
    @sprites["pokemon"].visible=false if @sprites["pokemon"]
    @sprites["pokeicon"].setBitmap(pbPokemonIconFile(@pokemon))
    @sprites["pokeicon"].src_rect=Rect.new(0,0,64,64)
    @sprites["pokeicon"].x=46
    @sprites["pokeicon"].y=56
    @sprites["pokeicon"].visible=true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    movedata=PBMoveData.new(moveid)
    basedamage=movedata.basedamage
    type=movedata.type
    category=movedata.category
    accuracy=movedata.accuracy
    drawMoveSelection(moveToLearn)
    pbSetSystemFont(overlay)
    move=moveid
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    textpos=[
       [basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          340,158,1,base,shadow],
       [accuracy==0 ? "---" : sprintf("%d",accuracy),
          340,188,1,base,shadow] # Was 280
    ]
    pbDrawTextPositions(overlay,textpos)
    imagepos=[["Graphics/UI/category",290,130,64*0,category*28,64,28]] # Was 230
    pbDrawImagePositions(overlay,imagepos)
    movedesc=pbGetMessage(MessageTypes::MoveDescriptions,moveid)
#    drawTextEx(overlay,4,222,366,5,movedesc,base,shadow)
    drawFormattedTextEx(overlay,16,222,344,movedesc,base,shadow,30)
  end

  def drawMoveSelection(moveToLearn)
    @sprites["header"].text="Pokémon Moveset"
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
      ppBase   = [base,                   # More than 1/2 of total PP
                  Color.new(248,192,0),   # 1/2 of total PP or less
                  Color.new(248,136,32),  # 1/4 of total PP or less
                  Color.new(248,72,72)]   # Zero PP
      ppShadow = [shadow,                 # More than 1/2 of total PP
                  Color.new(144,104,0),   # 1/2 of total PP or less
                  Color.new(144,72,24),   # 1/4 of total PP or less
                  Color.new(136,48,48)]   # Zero PP
    if moveToLearn==0
      @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_6")
    end
    if moveToLearn!=0
      @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_learnmove")
    end
    pbSetSystemFont(overlay)
    textpos=[
   #    [_INTL("Pokémon Moveset"),26,8,0,base,shadow,1],
       [_INTL("Category"),20,128,0,base2,shadow],
       [_INTL("Power"),20,158,0,base2,shadow],
       [_INTL("Accuracy"),20,188,0,base2,shadow]
    ]
    type1rect=Rect.new(64*0,@pokemon.type1*28,64,28)
    type2rect=Rect.new(64*0,@pokemon.type2*28,64,28)
    bgpane=[["Graphics/UI/"+getDarkModeFolder+"/Summary/overlay_movedetail",0,56,0,0,-1,-1]]
    pbDrawImagePositions(overlay,bgpane)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(162,82,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(128,82,@typebitmap.bitmap,type1rect)
      overlay.blt(198,82,@typebitmap.bitmap,type2rect)
    end
    imagepos=[]
    yPos=98
    yPos-=54 if moveToLearn!=0
    for i in 0...5
      moveobject=nil
      if i==4
        moveobject=PBMove.new(moveToLearn) if moveToLearn!=0
        yPos+=10
      else
        moveobject=@pokemon.moves[i]
      end
      dark = (isDarkMode?) ? [2,0] : [1,0]
      if moveobject
        if moveobject.id!=0
          imagepos.push(["Graphics/UI/Types",376,yPos+2,64*0,
             moveobject.type*28,64,28])
          textpos.push([PBMoves.getName(moveobject.id),444,yPos,0,
             base,shadow])
          if moveobject.totalpp>0
            textpos.push([_ISPRINTF("PP"),470,yPos+32,0,
               base,shadow])
          ppfraction = 0
          if moveobject.pp==0;                 ppfraction = 3
          elsif moveobject.pp*4<=moveobject.totalpp; ppfraction = 2
          elsif moveobject.pp*2<=moveobject.totalpp; ppfraction = 1
          end
            textpos.push([sprintf("%d/%d",moveobject.pp,moveobject.totalpp),
               588,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
          end
        else
          textpos.push(["-",444,yPos,0,base,shadow])
          textpos.push(["--",570,yPos+32,1,base,shadow])
        end
      end
      yPos+=64
    end
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
  end

  def drawPageSeven
    @sprites["header"].text="Pokémon Ribbons"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_7")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
    textpos=[
  #     [_INTL("Pokémon Ribbons"),26,8,0,base,shadow,1],
       [_INTL("No. of Ribbons:"),362,328,0,base,shadow],
       [@pokemon.ribbonCount.to_s,578,328,1,base,shadow],
    ]
    pbDrawTextPositions(overlay,textpos)
    imagepos=[]
    coord=0
    if @pokemon.ribbons
      for i in @pokemon.ribbons
        ribn=i-1
        imagepos.push(["Graphics/UI/Summary/ribbons",364+64*(coord%4),86+80*(coord/4).floor,
           64*(ribn%8),64*(ribn/8).floor,64,64])
        coord+=1
        break if coord>=12
      end
    end
    pbDrawImagePositions(overlay,imagepos)
  end
  
  
  SHOWFAMILYEGG = true # when true, family tree is also showed in egg screen.
  
  def drawPageEight
    @sprites["header"].text="Family Tree"
    $summarysizex = 80
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap(@pokemon.egg? ? 
          "Graphics/UI/"+getDarkModeFolder+"/Summary/bg_8_egg" : "Graphics/UI/"+getDarkModeFolder+"/Summary/bg_8")
    imagepos=[]    
    pbDrawImagePositions(overlay,imagepos)
    
    
    
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
#    itemname=@pokemon.item==0 ? _INTL("None") : PBItems.getName(@pokemon.item)

    textpos=[
  #     [_INTL("Family Tree"),26,8,0,base,shadow,1],
    ]
    gendericon2=[] 
    # Draw parents
    parentsY=[78,234]
    for i in 0...2
      parent = @pokemon.family && @pokemon.family[i] ? @pokemon.family[i] : nil
      iconParentParam = parent ? [parent.species,
          parent.gender==1,false,parent.form,false] : [0,0,false,0,false]
      iconParent=AnimatedBitmap.new(pbCheckPokemonIconFiles(iconParentParam))
      overlay.blt(370,parentsY[i],iconParent.bitmap,Rect.new(0,0,64,64))
      textpos.push([parent ? parent.name : _INTL("???"),
          456,parentsY[i],0,base,shadow])
      parentSpecieName=parent ? PBSpecies.getName(parent.species) : _INTL("???")
      textpos.push([parentSpecieName,456,32+parentsY[i],0,base,shadow])     
      if parent
        if parent.gender==0
#          textpos.push([_INTL("?"),628,32+parentsY[i],1,
#              Color.new(24,112,216),Color.new(136,168,208)])
		  gendericon2.push(["Graphics/UI/"+getDarkModeFolder+"/gender_male",614,40+parentsY[i],0,0,-1,-1])
        elsif parent.gender==1
#          textpos.push([_INTL("?"),628,32+parentsY[i],1,
#              Color.new(248,56,32),Color.new(224,152,144)])
		  gendericon2.push(["Graphics/UI/"+getDarkModeFolder+"/gender_female",614,40+parentsY[i],0,0,-1,-1])
        else
#          textpos.push([_INTL("?"),628,32+parentsY[i],1,
#              Color.new(248,56,32),Color.new(224,152,144)])
		  gendericon2.push(["Graphics/UI/"+getDarkModeFolder+"/gender_transgender",614,40+parentsY[i],0,0,-1,-1])
        end
      end    
      grandX = [492,560]
      for j in 0...2
        iconGrandParam = parent && parent[j] ? [parent[j].species,
            parent[j].gender==1,false,parent[j].form,false] : 
            [0,0,false,0,false]
        iconGrand=AnimatedBitmap.new(pbCheckPokemonIconFiles(iconGrandParam))
        overlay.blt(
            grandX[j],68+parentsY[i],iconGrand.bitmap,Rect.new(0,0,64,64))
      end
    end
	pbDrawImagePositions(overlay,gendericon2)
    pbDrawTextPositions(overlay,textpos)
  end
  
  def handleInputsEgg
    if SHOWFAMILYEGG && @pokemon.egg?
      if Input.trigger?(Input::LEFT) && (@page==0 || @page==7)
        if @page==0
          @page=7
        elsif @page==7
          @page=0
        end
#        pbPlayCursorSE()
        pbSEPlay("SumCursor")
        dorefresh=true
      end
      if Input.trigger?(Input::RIGHT) && (@page==0 || @page==7)
        if @page==0
          @page=7
        elsif @page==7
          @page=0
        end
#        pbPlayCursorSE()
        pbSEPlay("SumCursor")
        dorefresh=true
      end
    end
    if dorefresh
      drawPage(@page) if (@page==0 || @page==7)
    end
  end

  def drawPageNine
    @sprites["header"].text="Advanced Information"
    $summarysizex = 40
    overlay=@sprites["overlay"].bitmap
    @sprites["background"].setBitmap("Graphics/UI/"+getDarkModeFolder+"/Summary/bg_9")
    imagepos=[]
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=MessageConfig::DARKTEXTBASE
      shadow=MessageConfig::DARKTEXTSHADOW
	  baseT= MessageConfig::DARKTEXTBASETRANS    
	  shadowT= MessageConfig::DARKTEXTSHADOWTRANS
      base2=Color.new(12,12,12)
      shadow2=Color.new(242,242,242)
    else
      base=MessageConfig::LIGHTTEXTBASE
      shadow=MessageConfig::LIGHTTEXTSHADOW
	  baseT= MessageConfig::LIGHTTEXTBASETRANS    
	  shadowT= MessageConfig::LIGHTTEXTSHADOWTRANS
      base2=Color.new(242,242,242)
      shadow2=Color.new(12,12,12)
    end
    pbSetSystemFont(overlay)
    abilityname=PBAbilities.getName(@pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,@pokemon.ability)
    itemname=PBItems.getName(@pokemon.item)
    itemdesc=pbGetMessage(MessageTypes::ItemDescriptions,@pokemon.item)
 #   physicalstat=(@pokemon.attack+@pokemon.defense)/2.floor
    if ($PokemonSystem.temps==0 rescue false)
      physicalstat= @pokemon.temperature
      kind="°C"
    else
      physicalstat= toFahrenheit(@pokemon.temperature)
      kind="°F"
    end
    specialstat=(@pokemon.spatk+@pokemon.spdef)/2.floor
      if @pokemon.attack >= @pokemon.defense &&
          @pokemon.attack >= @pokemon.spatk &&
          @pokemon.attack >= @pokemon.spdef &&
          @pokemon.attack >= @pokemon.speed
        beststat="Attack"
      elsif @pokemon.defense >= @pokemon.spatk &&
          @pokemon.defense >= @pokemon.spdef &&
          @pokemon.defense >= @pokemon.speed
        beststat="Defense"
      elsif @pokemon.spatk >= @pokemon.spdef &&
          @pokemon.spatk >= @pokemon.speed
        beststat="Sp. Atk"
      elsif @pokemon.spdef >= @pokemon.speed
        beststat="Sp. Def"
      else
        beststat="Speed"
      end
      efforts=@pokemon.ev[0]+@pokemon.ev[1]+@pokemon.ev[2]+@pokemon.ev[3]+@pokemon.ev[4]+@pokemon.ev[5]
      stamina=(@pokemon.defense+@pokemon.spdef)/2.floor
      speciesname=PBSpecies.getName(@pokemon.species)
    textpos=[
  #     [_INTL("Advanced Information"),26,8,0,base,shadow,1],
       [_INTL("Best Stat"),366,52,0,base2,nil,0],
       [_INTL("{1}",beststat),563,52,2,base,shadow],
       [_INTL("Happiness"),366,82,0,base2,nil,0],
       [sprintf("%d",@pokemon.happiness),563,82,2,base,shadow],
       [_INTL("Temperature"),366,112,0,base2,nil,0], # Was Physical
       [_INTL("{1} {2}",physicalstat,kind),563,112,2,base,shadow],
       [_INTL("Special"),366,142,0,base2,nil,0],
       [_INTL("{1}",specialstat),563,142,2,base,shadow],
       [_INTL("Stamina"),366,172,0,base2,nil,0],
       [sprintf("%d",stamina),563,172,2,base,shadow],
       [_INTL("Effort Values"),366,202,0,base2,nil,0],
       [sprintf("%d",efforts),563,202,2,base,shadow],
       [_INTL("Item"),288-64,230,0,base2,nil,0],
       [itemname,426-64,230,0,base,shadow],
      ]
    pbDrawTextPositions(overlay,textpos)
#    drawTextEx(overlay,224,256,410,4,itemdesc,base,shadow)
    drawFormattedTextEx(overlay,224,256,410,itemdesc,base,shadow,30)
  end

  
  def pbChooseMoveToForget(moveToLearn)
    selmove=0
    ret=0
    maxmove=(moveToLearn>0) ? 4 : 3
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        ret=4
        break
      end
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        break
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=(moveToLearn>0) ? maxmove : 0
        end
        selmove=0 if selmove>maxmove
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(moveToLearn,newmove)
        ret=selmove
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        selmove=maxmove if selmove<0
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(moveToLearn,newmove)
        ret=selmove
      end
    end
    return (ret==4) ? -1 : ret
  end

  def pbMoveSelection
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    selmove=0
    oldselmove=0
    switching=false
    drawSelectedMove(0,@pokemon.moves[selmove].id)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index==@sprites["movesel"].index
        @sprites["movepresel"].z=@sprites["movesel"].z+1
      else
        @sprites["movepresel"].z=@sprites["movesel"].z
      end
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break if !switching
        @sprites["movepresel"].visible=false
        switching=false
      end
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        if selmove==4
          break if !switching
          @sprites["movepresel"].visible=false
          switching=false
        else
          if !(@pokemon.isShadow? rescue false)
            if !switching
              @sprites["movepresel"].index=selmove
              oldselmove=selmove
              @sprites["movepresel"].visible=true
              switching=true
            else
              tmpmove=@pokemon.moves[oldselmove]
              @pokemon.moves[oldselmove]=@pokemon.moves[selmove]
              @pokemon.moves[selmove]=tmpmove
              @sprites["movepresel"].visible=false
              switching=false
              drawSelectedMove(0,@pokemon.moves[selmove].id)
            end
          end
        end
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        selmove=0 if selmove<4 && selmove>=@pokemon.numMoves
        selmove=0 if selmove>=4
        selmove=4 if selmove<0
        @sprites["movesel"].index=selmove
        newmove=@pokemon.moves[selmove].id
        pbPlayCursorSE()
        drawSelectedMove(0,newmove)
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        selmove=0 if selmove>=4
        selmove=@pokemon.numMoves-1 if selmove<0
        @sprites["movesel"].index=selmove
        newmove=@pokemon.moves[selmove].id
        pbPlayCursorSE()
        drawSelectedMove(0,newmove)
      end
    end 
    @sprites["movesel"].visible=false
  end

  def pbGoToPrevious
    stopped=false
    if @page!=0 && !(SHOWFAMILYEGG && @page==7)
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex] && !@party[newindex].isEgg?
          @partyindex=newindex
          stopped=true
          break
        end
      end
      if !stopped
        newindex=@party.length
        @partyindex=newindex
        while newindex>0
          newindex-=1
          if @party[newindex] && !@party[newindex].isEgg?
            @partyindex=newindex
            break
          end
        end
      end
    else
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex]
          @partyindex=newindex
          stopped=true
          break
        end
      end
      if !stopped
        newindex=@party.length
        @partyindex=newindex
        while newindex>0
          newindex-=1
          if @party[newindex]
            @partyindex=newindex
            break
          end
        end
      end

    end
  end

  def pbGoToNext
    stopped=false
    if @page!=0 && !(SHOWFAMILYEGG && @page==7)
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex] && !@party[newindex].isEgg?
          @partyindex=newindex
          stopped=true
          break
        end
      end
      # If not stopped, go back to 1st entry
      if !stopped
        newindex=-1
        while newindex<@party.length-1
          newindex+=1
          if @party[newindex] && !@party[newindex].isEgg?
            @partyindex=newindex
            break
          end
        end
      end
    else
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex]
          @partyindex=newindex
          stopped=true
          break
        end
      end
      #EDIT
      if !stopped
        newindex=-1
        while newindex<@party.length-1
          newindex+=1
          if @party[newindex]
            @partyindex=newindex
            break
          end
        end
      end
      #EDIT
    end
  end

  def pbScene
    pbPlayCry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCry(@pokemon)
      end
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
      dorefresh=false
      if Input.trigger?(Input::C)
        if @page==0
          pbPlayCancelSE()
          break
        elsif @page==5
          pbPlayDecisionSE()
          pbMoveSelection
          dorefresh=true
          drawPageSix
        end
      end
      handleInputsEgg
      if Input.trigger?(Input::UP) # && @partyindex>0
        oldindex=@partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].color=Color.new(0,0,0,0)
          dorefresh=true
          pbSEStop
#          pbPlayCursorSE()
          pbPlayCry(@pokemon)
        end
      end
      if Input.trigger?(Input::DOWN) # && @partyindex<@party.length-1
        oldindex=@partyindex
        pbGoToNext
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].color=Color.new(0,0,0,0)
          dorefresh=true
          pbSEStop
#          pbPlayCursorSE()
          pbPlayCry(@pokemon)
        end
      end
      if Input.trigger?(Input::LEFT) && !@pokemon.isEgg?
        oldpage=@page
        @page-=1
        @page=8 if @page<0
        @page=0 if @page>8
        dorefresh=true
        if @page!=oldpage # Move to next page
#          pbPlayCursorSE()
          pbSEPlay("SumCursor")
          dorefresh=true
        end
      end
      if Input.trigger?(Input::RIGHT) && !@pokemon.isEgg?
        oldpage=@page
        @page+=1
        @page=8 if @page<0
        @page=0 if @page>8
        if @page!=oldpage # Move to next page
#          pbPlayCursorSE()
          pbSEPlay("SumCursor")
          dorefresh=true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end



class PokemonSummary
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(party,partyindex)
    @scene.pbStartScene(party,partyindex)
    ret=@scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party,partyindex,moveToLearn)
    ret=-1
    @scene.pbStartForgetScene(party,partyindex,moveToLearn)
    loop do
      ret=@scene.pbChooseMoveToForget(moveToLearn)
      if ret>=0 && moveToLearn!=0 && pbIsHiddenMove?(party[partyindex].moves[ret].id) && !$DEBUG
        Kernel.pbMessage(_INTL("HM moves can't be forgotten now.")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party,partyindex,message)
    ret=-1
    @scene.pbStartForgetScene(party,partyindex,0)
    Kernel.pbMessage(message){ @scene.pbUpdate }
    loop do
      ret=@scene.pbChooseMoveToForget(0)
      if ret<0
        Kernel.pbMessage(_INTL("You must choose a move!")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end
end