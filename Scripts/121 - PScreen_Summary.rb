class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport=nil,fifthmove=false)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/"+getAccentFolder+"/summarymovesel")
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
    self.y-=76 if @fifthmove
    self.y+=20 if @fifthmove && self.index==4
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
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    typescart=
    @sprites={}
    @typebitmap=AnimatedBitmap.new("Graphics/Global Pictures/types")
    @compatbitmap=AnimatedBitmap.new("Graphics/Global Pictures/compatibilities")
    @colorbitmap=AnimatedBitmap.new("Graphics/Global Pictures/colors")
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["header-bg"]=IconSprite.new(0,0,@viewport)
    @sprites["header"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    # mirror=true in past
    @sprites["pokemon"].mirror=$PokemonSystem.mgraphic==0 rescue false
    @sprites["pokemon"].color=Color.new(0,0,0,0)
    pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,180)
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=52
    @sprites["pokeicon"].mirror=false
    @sprites["pokeicon"].visible=false
    @sprites["itemicon2"] = ItemIconSprite.new(243,222,@pokemon.item,@viewport)
    @sprites["itemicon2"].blankzero = true
    
    @sprites["movepresel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible=false
    @sprites["movepresel"].preselected=true
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible=false
    @page=0
    drawPageOne(@pokemon)
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
    @typebitmap=AnimatedBitmap.new("Graphics/Global Pictures/types")
    @compatbitmap=AnimatedBitmap.new("Graphics/Global Pictures/compatibilities")
    @colorbitmap=AnimatedBitmap.new("Graphics/Global Pictures/colors")
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["header-bg"]=IconSprite.new(0,0,@viewport)
    @sprites["header"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=52
    @sprites["pokeicon"].mirror=false
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport,moveToLearn>0)
    @sprites["movesel"].visible=false
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    drawSelectedMove(@pokemon,moveToLearn,@pokemon.moves[0].id)
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
    totaltext=""
    oldfontname=bitmap.font.name
    oldfontsize=bitmap.font.size
    oldfontcolor=bitmap.font.color
    bitmap.font.size=24
    bitmap.font.name="Arial"
    PokemonStorage::MARKINGCHARS.each{|item| totaltext+=item }
    totalsize=bitmap.text_size(totaltext)
    realX=x+(width/2)-(totalsize.width/2)
    realY=y+(height/2)-(totalsize.height/2)
    i=0
    PokemonStorage::MARKINGCHARS.each{|item|
       marked=(markings&(1<<i))!=0
       bitmap.font.color=(marked) ? Color.new(72,64,56) : Color.new(184,184,160)
       itemwidth=bitmap.text_size(item).width
       bitmap.draw_text(realX,realY,itemwidth+2,totalsize.height,item)
       realX+=itemwidth
       i+=1
    }
    bitmap.font.name=oldfontname
    bitmap.font.size=oldfontsize
    bitmap.font.color=oldfontcolor
  end

  def drawPageOne(pokemon)
    if pokemon.isEgg?
      drawPageOneEgg(pokemon)
      return
    end
    $summarysizex = 80
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary1")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")
#    @sprites["header"].setBitmap("Graphics/Pictures/header1")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    growthrate=pokemon.growthrate
    startexp=PBExperience.pbGetStartExperience(pokemon.level,growthrate)
    endexp=PBExperience.pbGetStartExperience(pokemon.level+1,growthrate)
    finexp=PBExperience.pbGetStartExperience(PBExperience::MAXLEVEL,growthrate)
    if (pokemon.isShadow? rescue false)
      imagepos.push(["Graphics/Pictures/"+getDarkModeFolder+"/summaryShadow",352,240,0,0,-1,-1])
      shadowfract=pokemon.heartgauge*1.0/PokeBattle_Pokemon::HEARTGAUGESIZE
      if ($PokemonSystem.threecolorbar==1 rescue false)
        imagepos.push(["Graphics/Pictures/summaryShadowBar_threecolorbar",370,280,0,0,(shadowfract*248).floor,-1])
      else
        imagepos.push(["Graphics/Pictures/summaryShadowBar",370,280,0,0,(shadowfract*248).floor,-1])
      end
    elsif pokemon.level<PBExperience::MAXLEVEL
      shadowfract1=(finexp-pokemon.exp)*100/(finexp)
      if ($PokemonSystem.threecolorbar==1 rescue false)
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar_threecolorbar",370,280,0,0,(shadowfract1*2.48).floor,-1])
      else
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar",370,280,0,0,(shadowfract1*2.48).floor,-1])
      end
      shadowfract2=(endexp-pokemon.exp)*100/(endexp - startexp)
      if ($PokemonSystem.threecolorbar==1 rescue false)
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar_threecolorbar",370,344,0,0,(shadowfract2*2.48).floor,-1])
      else
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar",370,344,0,0,(shadowfract2*2.48).floor,-1])
      end
    end
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    pbSetSystemFont(overlay)
    numberbase=(pokemon.isShiny?) ? Color.new(248,56,32) : base
    numbershadow=(pokemon.isShiny?) ? Color.new(224,152,144) : shadow
    publicID=pokemon.publicID
    speciesname=PBSpecies.getName(pokemon.species)
    pokename=@pokemon.name
    fdexno = getDexNumber(pokemon.species) # If none of the following conditions are met, it is Generation I-V Pokemon
    # Find Color
    colourd=pokemon.color
    textpos=[
 #      [_INTL("Pokémon Information"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_ISPRINTF("Dex No."),366,16,0,base2,nil,0],
       [_INTL("{1}",fdexno),563,16,2,numberbase,numbershadow],
       [_INTL("Species"),366,48,0,shadow2,nil,0],
       [speciesname,563,48,2,base,shadow],
       [_INTL("Color"),366,80,0,base2,nil,0],
       [_INTL("Compats"),366,112,0,shadow2,nil,0],
       [_INTL("Type"),366,144,0,base2,nil,0],
       [_INTL("OT"),366,176,0,shadow2,nil,0],
       [_INTL("ID No."),366,208,0,base2,nil,0],
    ]
    if (pokemon.isShadow? rescue false)
      textpos.push([_INTL("Heart Gauge"),366,240,0,shadow2,nil,0])
      heartmessage=[_INTL("The door to its heart is open! Undo the final lock!"),
                    _INTL("The door to its heart is almost fully open."),
                    _INTL("The door to its heart is nearly open."),
                    _INTL("The door to its heart is opening wider."),
                    _INTL("The door to its heart is opening up."),
                    _INTL("The door to its heart is tightly shut.")
                    ][pokemon.heartStage]
      memo=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),heartmessage)
      drawFormattedTextEx(overlay,366,304,276,memo)
    else
      textpos.push([_INTL("Exp. Points"),366,240,0,shadow2,nil,0])
      textpos.push([_INTL("{1}",pokemon.exp.to_s_formatted),616,240,1,base,shadow])
      textpos.push([_INTL("To Next Lv."),366,304,0,shadow2,nil,0])
      textpos.push([_INTL("{1}",(endexp-pokemon.exp).to_s_formatted),616,304,1,base,shadow])
    end
    idno=(pokemon.ot=="") ? "?????" : sprintf("%05d",publicID)
    textpos.push([idno,563,208,2,base,shadow])
    if pokemon.ot==""
      textpos.push([_INTL("Rental"),563,176,2,base,shadow])
    else
      ownerbase=base
      ownershadow=shadow
      if pokemon.otgender==0 # male OT
        if (!isDarkMode?)
          ownerbase=Color.new(24,112,216)
          ownershadow=Color.new(136,168,208)
        else
          ownerbase=Color.new(136,168,208)
          ownershadow=Color.new(24,112,216)
        end
      elsif pokemon.otgender==1 # female OT
        if (!isDarkMode?)
          ownerbase=Color.new(248,56,32)
          ownershadow=Color.new(224,152,144)
        else
          ownerbase=Color.new(224,152,144)
          ownershadow=Color.new(248,56,32)
        end
      end
      textpos.push([pokemon.ot,563,176,2,ownerbase,ownershadow])
    end
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
    colorrect=Rect.new(64*$PokemonSystem.colortige,colourd*28,64,28)
    type1rect=Rect.new(64*$PokemonSystem.colortige,pokemon.type1*28,64,28)
    type2rect=Rect.new(64*$PokemonSystem.colortige,pokemon.type2*28,64,28)
    compat1rect=Rect.new(64*$PokemonSystem.colortige,(pokemon.egroup1-1)*28,64,28)
    compat2rect=Rect.new(64*$PokemonSystem.colortige,(pokemon.egroup2-1)*28,64,28)
    overlay.blt(532,82,@colorbitmap.bitmap,colorrect)
    if pokemon.egroup1==pokemon.egroup2
      overlay.blt(532,114,@compatbitmap.bitmap,compat1rect)
    else
      overlay.blt(498,114,@compatbitmap.bitmap,compat1rect)
      overlay.blt(564,114,@compatbitmap.bitmap,compat2rect)
    end
    if pokemon.type1==pokemon.type2
      overlay.blt(532,146,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(498,146,@typebitmap.bitmap,type1rect)
      overlay.blt(564,146,@typebitmap.bitmap,type2rect)
    end
   # if pokemon.level<PBExperience::MAXLEVEL
     # overlay.fill_rect(362,372,(pokemon.exp-startexp)*128/(endexp-startexp),2,Color.new(72,120,160))
     # overlay.fill_rect(362,374,(pokemon.exp-startexp)*128/(endexp-startexp),4,Color.new(24,144,248))
   # end

   end

  def drawPageOneEgg(pokemon)
    $summarysizex = 80
    @sprites["itemicon2"].visible = false
    @sprites["itemicon2"].item = @pokemon.item
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summaryEgg")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")
#    @sprites["header"].setBitmap("Graphics/Pictures/headerB1")
    imagepos=[]
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Egg Steps Start
     dexdata=pbOpenDexData
     pbDexDataOffset(dexdata,pokemon.species,21)
     maxesteps=dexdata.fgetw
     dexdata.close
    shadowfract=pokemon.eggsteps*1.0/maxesteps # Egg Steps TMP
      if ($PokemonSystem.threecolorbar==1 rescue false)
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar_threecolorbar",370,244,0,0,(shadowfract*248).floor,-1])
      else
        imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/summaryEggBar",370,244,0,0,(shadowfract*248).floor,-1])
      end
    # Egg Steps End
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    pbSetSystemFont(overlay)
    textpos=[
 #      [_INTL("Trainer Information"),26,8,0,base,shadow,1],
       [pokemon.name,46,62,0,base,shadow],
    ]
    if pokemon.isRB?
      textpos.push([_INTL("Remote Box Battery"),360,204,0,shadow2,nil,0])
    else
      textpos.push([_INTL("The Egg Watch"),360,204,0,shadow2,nil,0])
    end
    pbDrawTextPositions(overlay,textpos)
    memo=""
    if pokemon.timeReceived
      month=pbGetAbbrevMonthName(pokemon.timeReceived.mon)
      date=pokemon.timeReceived.day
      year=pokemon.timeReceived.year
      memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
    end
    mapname=pbGetMapNameFromId(pokemon.obtainMap)
    if (pokemon.obtainText rescue false) && pokemon.obtainText!=""
      mapname=pokemon.obtainText
    end
    if (!isDarkMode?)
      redbase = 'F83820'
      redshadow = 'E09890'
    else
      redbase = 'EBBCB7'
      redshadow = 'DF2007'
    end
    if mapname && mapname!=""
      memo+=_INTL("<c3={1},{2}>A mysterious Pokémon Egg received from <c3={3},{4}>{5}<c3={1},{2}>.\n",colorToRgb32(base),colorToRgb32(shadow),redbase,redshadow,mapname)
    end
    memo+=_INTL("<c3={1},{2}>\n",colorToRgb32(base),colorToRgb32(shadow))
    if pokemon.isRB?
      eggstate=_INTL("It looks like the Remote Box's battery is in its prime.")
      eggstate=_INTL("Remote Box's battery is currently in a good condition.") if shadowfract*100 < 76
      eggstate=_INTL("Remote Box's battery is close to run out. It may be close to open!") if shadowfract*100 < 51
      eggstate=_INTL("Remote Box's battery is about to run out! It will open soon!") if shadowfract*100 < 26
    else
      eggstate=_INTL("It looks like this Egg will take a long time to hatch.")
      eggstate=_INTL("What will hatch from this? It doesn't seem close to hatching.") if pokemon.eggsteps<10200
      eggstate=_INTL("It appears to move occasionally. It may be close to hatching.") if pokemon.eggsteps<2550
      eggstate=_INTL("Sounds can be heard coming from inside! It will hatch soon!") if pokemon.eggsteps<1275
    end
    eggstatemsg=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),eggstate)
    drawFormattedTextEx(overlay,360,268,272,eggstatemsg)
    drawFormattedTextEx(overlay,360,78,276,memo)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
  end

  def drawPageTwo(pokemon)
    $summarysizex = 80
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary2")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header2")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    pbSetSystemFont(overlay)
    naturename=PBNatures.getName(pokemon.nature)
    pokename=@pokemon.name
    textpos=[
  #     [_INTL("Trainer Information"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
    ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    if (!isDarkMode?)
      redbase = 'F83820'
      redshadow = 'E09890'
    else
      redbase = 'EBBCB7'
      redshadow = 'DF2007'
    end
    memo=""
    shownature=(!(pokemon.isShadow? rescue false)) || pokemon.heartStage<=3
    if shownature
      memo+=_INTL("<c3={1},{2}>{3}<c3={4},{5}> nature.\n",redbase,redshadow,naturename,colorToRgb32(base),colorToRgb32(shadow))
    end
    if pokemon.timeReceived
      month=pbGetAbbrevMonthName(pokemon.timeReceived.mon)
      date=pokemon.timeReceived.day
      year=pokemon.timeReceived.year
      memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
    end
    mapname=pbGetMapNameFromId(pokemon.obtainMap)
    if (pokemon.obtainText rescue false) && pokemon.obtainText!=""
      mapname=pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=sprintf("<c3=%s,%s>%s\n",redbase,redshadow,mapname)
    else
      memo+=_INTL("<c3={1},{2}>Unkown area\n",redbase,redshadow) # Faraway place
    end
    if pokemon.obtainMode
      mettext=[_INTL("Met at Lv. {1}.",pokemon.obtainLevel),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.",pokemon.obtainLevel),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.",pokemon.obtainLevel),
               _INTL("Remote Box received.")
               ][pokemon.obtainMode]
      memo+=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),mettext)
      if pokemon.obtainMode==1 # hatched
        if pokemon.timeEggHatched
          month=pbGetAbbrevMonthName(pokemon.timeEggHatched.mon)
          date=pokemon.timeEggHatched.day
          year=pokemon.timeEggHatched.year
          memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
        end
        mapname=pbGetMapNameFromId(pokemon.hatchedMap)
        if mapname && mapname!=""
          memo+=sprintf("<c3=%s,%s>%s\n",redbase,redshadow,mapname)
        else
          memo+=_INTL("<c3={1},{2}>Unknown area\n",redbase,redshadow)
        end
        memo+=_INTL("<c3={1},{2}>Egg hatched.\n",colorToRgb32(base),colorToRgb32(shadow))
      elsif pokemon.obtainMode==5 # Box opened
        if pokemon.timeEggHatched
          month=pbGetAbbrevMonthName(pokemon.timeEggHatched.mon)
          date=pokemon.timeEggHatched.day
          year=pokemon.timeEggHatched.year
          memo+=_INTL("<c3={1},{2}>{3} {4}, {5}\n",colorToRgb32(base),colorToRgb32(shadow),month,date,year)
        end
        mapname=pbGetMapNameFromId(pokemon.hatchedMap)
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
      tiebreaker=pokemon.personalID%6
      for i in 0...6
        if pokemon.iv[i]==pokemon.iv[bestiv]
          bestiv=i if i>=tiebreaker && bestiv<tiebreaker
        elsif pokemon.iv[i]>pokemon.iv[bestiv]
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
                      ][bestiv*5+pokemon.iv[bestiv]%5]
      memo+=sprintf("<c3=%s,%s>%s\n",colorToRgb32(base),colorToRgb32(shadow),characteristic)
    end
    drawFormattedTextEx(overlay,360,78,276,memo)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
  end

  def drawPageThree(pokemon)
    $summarysizex = 40
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary3")
#      @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#      @sprites["header"].setBitmap("Graphics/Pictures/header3")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    nat = (pokemon.mint!=-1) ? pokemon.mint : pokemon.nature
    statshadows=[]
    for i in 0...5; statshadows[i]=nil; end
    if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
#      natup=(pokemon.nature/5).floor
#      natdn=(pokemon.nature%5).floor
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
    abilityname=PBAbilities.getName(pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,pokemon.ability)
    pokename=@pokemon.name
    textpos=[
      # [_INTL("Pokémon Statistics"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_INTL("HP"),420,76-64,2,base2,nil,0],
       [sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),548,76-64,2,base,shadow],
       [_INTL("Attack"),376,120-64,0,shadow2,statshadows[0],0],
       [sprintf("%d",pokemon.attack),548,120-64,2,base,shadow],
       [_INTL("Defense"),376,152-64,0,base2,statshadows[1],0],
       [sprintf("%d",pokemon.defense),548,152-64,2,base,shadow],
       [_INTL("Sp. Atk"),376,184-64,0,shadow2,statshadows[3],0],
       [sprintf("%d",pokemon.spatk),548,184-64,2,base,shadow],
       [_INTL("Sp. Def"),376,216-64,0,base2,statshadows[4],0],
       [sprintf("%d",pokemon.spdef),548,216-64,2,base,shadow],
       [_INTL("Speed"),376,248-64,0,shadow2,statshadows[2],0],
       [sprintf("%d",pokemon.speed),548,248-64,2,base,shadow],
       [_INTL("Ability"),288,284-64,0,shadow2,nil,0],
       [abilityname,426,284-64,0,base,shadow],
      ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    drawTextEx(overlay,224,316-64,410,4,abilitydesc,base,shadow)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
    if pokemon.hp>0
      hpcolors=[
         Color.new(24,192,32),Color.new(0,144,0),     # Green
         Color.new(248,184,0),Color.new(184,112,0),   # Orange
         Color.new(240,80,32),Color.new(168,48,56)    # Red
      ]
      hpzone=0
      hpzone=1 if pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone=2 if pokemon.hp<=(@pokemon.totalhp/4).floor
      overlay.fill_rect(488,110-64,pokemon.hp*96/pokemon.totalhp,2,hpcolors[hpzone*2+1])
      overlay.fill_rect(488,112-64,pokemon.hp*96/pokemon.totalhp,4,hpcolors[hpzone*2])
    end
  end

def drawPageFour(pokemon)
    $summarysizex = 40
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary3_1")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header3_1")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    nat = (pokemon.mint!=-1) ? pokemon.mint : pokemon.nature
    statshadows=[]
    for i in 0...5; statshadows[i]=nil end
    if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
#      natup=(pokemon.nature/5).floor
#      natdn=(pokemon.nature%5).floor
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
    abilityname=PBAbilities.getName(pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,pokemon.ability)
    pokename=@pokemon.name
    textpos=[
    #   [_INTL("Effort Values"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_INTL("HP"),420,76-64,2,base,nil,0],
       [sprintf("%d",pokemon.ev[0]),548,76-64,2,base,shadow],
       [_INTL("Attack"),376,120-64,0,shadow2,statshadows[0],0],
       [sprintf("%d",pokemon.ev[1]),548,120-64,2,base,shadow],
       [_INTL("Defense"),376,152-64,0,base2,statshadows[1],0],
       [sprintf("%d",pokemon.ev[2]),548,152-64,2,base,shadow],
       [_INTL("Sp. Atk"),376,184-64,0,shadow2,statshadows[3],0],
       [sprintf("%d",pokemon.ev[4]),548,184-64,2,base,shadow],
       [_INTL("Sp. Def"),376,216-64,0,base2,statshadows[4],0],
       [sprintf("%d",pokemon.ev[5]),548,216-64,2,base,shadow],
       [_INTL("Speed"),376,248-64,0,shadow2,statshadows[2],0],
       [sprintf("%d",pokemon.ev[3]),548,248-64,2,base,shadow],
       [_INTL("Ability"),288,284-64,0,shadow2,nil,0],
       [abilityname,426,284-64,0,base,shadow],
      ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    drawTextEx(overlay,224,316-64,410,4,abilitydesc,base,shadow)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
    if pokemon.hp>0
      hpcolors=[
         Color.new(24,192,32),Color.new(0,144,0),     # Green
         Color.new(248,184,0),Color.new(184,112,0),   # Orange
         Color.new(240,80,32),Color.new(168,48,56)    # Red
      ]
      hpzone=0
      hpzone=1 if pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone=2 if pokemon.hp<=(@pokemon.totalhp/4).floor
      overlay.fill_rect(488,110-64,pokemon.hp*96/pokemon.totalhp,2,hpcolors[hpzone*2+1])
      overlay.fill_rect(488,112-64,pokemon.hp*96/pokemon.totalhp,4,hpcolors[hpzone*2])
    end
  end

def drawPageFive(pokemon)
    $summarysizex = 40
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary3_2")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header3_2")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    nat = (pokemon.mint!=-1) ? pokemon.mint : pokemon.nature
    statshadows=[]
    for i in 0...5; statshadows[i]=nil; end
      if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
#      natup=(pokemon.nature/5).floor
#      natdn=(pokemon.nature%5).floor
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
    abilityname=PBAbilities.getName(pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,pokemon.ability)
    pokename=@pokemon.name
    textpos=[
  #     [_INTL("Individual Values"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_INTL("HP"),420,76-64,2,base2,nil,0],
       [sprintf("%d",pokemon.iv[0]),548,76-64,2,base,shadow],
       [_INTL("Attack"),376,120-64,0,shadow2,statshadows[0],0],
       [sprintf("%d",pokemon.iv[1]),548,120-64,2,base,shadow],
       [_INTL("Defense"),376,152-64,0,base2,statshadows[1],0],
       [sprintf("%d",pokemon.iv[2]),548,152-64,2,base,shadow],
       [_INTL("Sp. Atk"),376,184-64,0,shadow2,statshadows[3],0],
       [sprintf("%d",pokemon.iv[4]),548,184-64,2,base,shadow],
       [_INTL("Sp. Def"),376,216-64,0,base2,statshadows[4],0],
       [sprintf("%d",pokemon.iv[5]),548,216-64,2,base,shadow],
       [_INTL("Speed"),376,248-64,0,shadow2,statshadows[2],0],
       [sprintf("%d",pokemon.iv[3]),548,248-64,2,base,shadow],
       [_INTL("Ability"),288,284-64,0,shadow2,nil,0],
       [abilityname,426,284-64,0,base,shadow],
      ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    drawTextEx(overlay,224,316-64,410,4,abilitydesc,base,shadow)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
    if pokemon.hp>0
      hpcolors=[
         Color.new(24,192,32),Color.new(0,144,0),     # Green
         Color.new(248,184,0),Color.new(184,112,0),   # Orange
         Color.new(240,80,32),Color.new(168,48,56)    # Red
      ]
      hpzone=0
      hpzone=1 if pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone=2 if pokemon.hp<=(@pokemon.totalhp/4).floor
      overlay.fill_rect(488,110-64,pokemon.hp*96/pokemon.totalhp,2,hpcolors[hpzone*2+1])
      overlay.fill_rect(488,112-64,pokemon.hp*96/pokemon.totalhp,4,hpcolors[hpzone*2])
    end
  end
  
  def drawPageSix(pokemon)
    $summarysizex = 80
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary4")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header4")
    @sprites["pokemon"].visible=true
    @sprites["pokeicon"].visible=false
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
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
    pokename=@pokemon.name
    textpos=[
  #     [_INTL("Pokémon Moveset"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
    ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    imagepos=[]
    yPos=98
    for i in 0...pokemon.moves.length
      if pokemon.moves[i].id>0
        imagepos.push(["Graphics/Global Pictures/types",376,yPos+2,64*$PokemonSystem.colortige,
           pokemon.moves[i].type*28,64,28])
        textpos.push([PBMoves.getName(pokemon.moves[i].id),444,yPos,0,
           typeColors[pokemon.moves[i].type][0],typeColors[pokemon.moves[i].type][1]])
        if pokemon.moves[i].totalpp>0
          textpos.push([_ISPRINTF("PP"),470,yPos+32,0,
             base,shadow])
          ppfraction = 0
          if pokemon.moves[i].pp==0;                             ppfraction = 3
          elsif pokemon.moves[i].pp*4<=pokemon.moves[i].totalpp; ppfraction = 2
          elsif pokemon.moves[i].pp*2<=pokemon.moves[i].totalpp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",pokemon.moves[i].pp,pokemon.moves[i].totalpp),
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
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
  end

  def drawSelectedMove(pokemon,moveToLearn,moveid)
    overlay=@sprites["overlay"].bitmap
    @sprites["pokemon"].visible=false if @sprites["pokemon"]
    @sprites["pokeicon"].setBitmap(pbPokemonIconFile(pokemon))
    @sprites["pokeicon"].src_rect=Rect.new(0,0,64,64)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=52
    @sprites["pokeicon"].visible=true
    movedata=PBMoveData.new(moveid)
    basedamage=movedata.basedamage
    type=movedata.type
    category=movedata.category
    accuracy=movedata.accuracy
    drawMoveSelection(pokemon,moveToLearn)
    pbSetSystemFont(overlay)
    move=moveid
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    textpos=[
       [basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          288,154,1,base,shadow],
       [accuracy==0 ? "---" : sprintf("%d",accuracy),
          288,186,1,base,shadow] # Was 280
    ]
    pbDrawTextPositions(overlay,textpos)
    imagepos=[["Graphics/Pictures/category",238,124,64*$PokemonSystem.colortige,category*28,64,28]] # Was 230
    pbDrawImagePositions(overlay,imagepos)
    drawTextEx(overlay,4,218,302,5,
       pbGetMessage(MessageTypes::MoveDescriptions,moveid),
       base,shadow)
  end

  def drawMoveSelection(pokemon,moveToLearn)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
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
      @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary4details")
#      @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#      @sprites["header"].setBitmap("Graphics/Pictures/header4")
    end
    if moveToLearn!=0
      @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary4learning")
    end
    pbSetSystemFont(overlay)
    textpos=[
   #    [_INTL("Pokémon Moveset"),26,8,0,base,shadow,1],
       [_INTL("Category"),20,122,0,base2,shadow2],
       [_INTL("Power"),20,154,0,base2,shadow2],
       [_INTL("Accuracy"),20,186,0,base2,shadow2]
    ]
    type1rect=Rect.new(64*$PokemonSystem.colortige,pokemon.type1*28,64,28)
    type2rect=Rect.new(64*$PokemonSystem.colortige,pokemon.type2*28,64,28)
    if pokemon.type1==pokemon.type2
      overlay.blt(130,78,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(96,78,@typebitmap.bitmap,type1rect)
      overlay.blt(166,78,@typebitmap.bitmap,type2rect)
    end
    imagepos=[]
    yPos=98
    yPos-=76 if moveToLearn!=0
    for i in 0...5
      moveobject=nil
      if i==4
        moveobject=PBMove.new(moveToLearn) if moveToLearn!=0
        yPos+=20
      else
        moveobject=pokemon.moves[i]
      end
      if moveobject
        if moveobject.id!=0
          imagepos.push(["Graphics/Global Pictures/types",376,yPos+2,64*$PokemonSystem.colortige,
             moveobject.type*28,64,28])
          textpos.push([PBMoves.getName(moveobject.id),444,yPos,0,
             typeColors[moveobject.type][0],typeColors[moveobject.type][1]])
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

  def drawPageSeven(pokemon)
    $summarysizex = 80
    @sprites["itemicon2"].visible = false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary5")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header5")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    pbSetSystemFont(overlay)
    pokename=@pokemon.name
    textpos=[
  #     [_INTL("Pokémon Ribbons"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_INTL("No. of Ribbons:"),362,342,0,base,shadow],
       [pokemon.ribbonCount.to_s,578,342,1,base,shadow],
    ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    imagepos=[]
    coord=0
    if pokemon.ribbons
      for i in pokemon.ribbons
        ribn=i-1
        imagepos.push(["Graphics/Pictures/ribbons",364+64*(coord%4),86+80*(coord/4).floor,
           64*(ribn%8),64*(ribn/8).floor,64,64])
        coord+=1
        break if coord>=12
      end
    end
    pbDrawImagePositions(overlay,imagepos)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
  end

  def drawPageEight(pokemon)
    $summarysizex = 40
    @sprites["itemicon2"].visible = true
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/"+getDarkModeFolder+"/summary6_1")
#    @sprites["header-bg"].setBitmap("Graphics/Pictures/header-global")      
#    @sprites["header"].setBitmap("Graphics/Pictures/header6")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status>0
      status=6 if pbPokerus(pokemon)==1
      status=@pokemon.status-1 if @pokemon.status>0
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/summaryPokerus"),176,100,0,0,-1,-1])
    end
    ballused=@pokemon.ballused ? @pokemon.ballused : 0
    ballimage=sprintf("Graphics/Pictures/summaryball%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    pbDrawImagePositions(overlay,imagepos)
    if (!isDarkMode?)
      base=Color.new(88,88,80)
      shadow=Color.new(168,184,184)
      base2=Color.new(230,230,230)
      shadow2=Color.new(58,58,58)
    else
      base=Color.new(248,248,240)
      shadow=Color.new(72,88,88)
      base2=Color.new(230,230,230)
      shadow2=Color.new(230,230,230)
    end
    pbSetSystemFont(overlay)
    abilityname=PBAbilities.getName(pokemon.ability)
    abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,pokemon.ability)
    itemname=PBItems.getName(pokemon.item)
    itemdesc=pbGetMessage(MessageTypes::ItemDescriptions,pokemon.item)
    pokename=@pokemon.name
 #   physicalstat=(pokemon.attack+pokemon.defense)/2.floor
    if ($PokemonSystem.temps==0 rescue false)
      physicalstat= pokemon.temperature
      kind="°C"
    else
      physicalstat= toFahrenheit(pokemon.temperature)
      kind="°F"
    end
    specialstat=(pokemon.spatk+pokemon.spdef)/2.floor
      if pokemon.attack >= pokemon.defense &&
          pokemon.attack >= pokemon.spatk &&
          pokemon.attack >= pokemon.spdef &&
          pokemon.attack >= pokemon.speed
        beststat="Attack"
      elsif pokemon.defense >= pokemon.spatk &&
          pokemon.defense >= pokemon.spdef &&
          pokemon.defense >= pokemon.speed
        beststat="Defense"
      elsif pokemon.spatk >= pokemon.spdef &&
          pokemon.spatk >= pokemon.speed
        beststat="Sp. Atk"
      elsif pokemon.spdef >= pokemon.speed
        beststat="Sp. Def"
      else
        beststat="Speed"
      end
      efforts=pokemon.ev[0]+pokemon.ev[1]+pokemon.ev[2]+pokemon.ev[3]+pokemon.ev[4]+pokemon.ev[5]
      stamina=(pokemon.defense+pokemon.spdef)/2.floor
      speciesname=PBSpecies.getName(pokemon.species)
    textpos=[
  #     [_INTL("Advanced Information"),26,8,0,base,shadow,1],
       [pokename,46,62,0,base,shadow],
       [pokemon.level.to_s,46,92,0,base,shadow],
       [_INTL("Best Stat"),420,76-64,2,base2,nil,0],
       [_INTL("{1}",beststat),548,76-64,2,base,shadow],
       [_INTL("Happiness"),376,120-64,0,shadow2,nil,0],
       [sprintf("%d",pokemon.happiness),548,120-64,2,base,shadow],
       [_INTL("Temperature"),376,152-64,0,base2,nil,0], # Was Physical
       [_INTL("{1} {2}",physicalstat,kind),548,152-64,2,base,shadow],
       [_INTL("Special"),376,184-64,0,shadow2,nil,0],
       [_INTL("{1}",specialstat),548,184-64,2,base,shadow],
       [_INTL("Stamina"),376,216-64,0,base2,nil,0],
       [sprintf("%d",stamina),548,216-64,2,base,shadow],
       [_INTL("Efforts"),376,248-64,0,shadow2,nil,0],
       [sprintf("%d",efforts),548,248-64,2,base,shadow],
       [_INTL("Item"),288,284-64,0,shadow2,nil,0],
       [itemname,426,284-64,0,base,shadow],
      ]
    gendericon=[]
    if pokemon.isMale?
#      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
      gendericon.push(["Graphics/Pictures/gender_male",178,68,0,0,-1,-1])
    elsif pokemon.isFemale?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_female",178,68,0,0,-1,-1])
    elsif pokemon.isGenderless?
#      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
      gendericon.push(["Graphics/Pictures/gender_transgender",178,68,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,gendericon)
    pbDrawTextPositions(overlay,textpos)
    drawTextEx(overlay,224,316-64,410,4,itemdesc,base,shadow)
    drawMarkings(overlay,0,363,72,20,pokemon.markings)
    if pokemon.hp>0
      hpcolors=[
         Color.new(24,192,32),Color.new(0,144,0),     # Green
         Color.new(248,184,0),Color.new(184,112,0),   # Orange
         Color.new(240,80,32),Color.new(168,48,56)    # Red
      ]
      hpzone=0
      hpzone=1 if pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone=2 if pokemon.hp<=(@pokemon.totalhp/4).floor
      overlay.fill_rect(488,110-64,pokemon.hp*96/pokemon.totalhp,2,hpcolors[hpzone*2+1])
      overlay.fill_rect(488,112-64,pokemon.hp*96/pokemon.totalhp,4,hpcolors[hpzone*2])
    end
  end

  
  def pbChooseMoveToForget(moveToLearn)
    selmove=0
    ret=0
    maxmove=(moveToLearn>0) ? 4 : 3
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        ret=4
        break
      end
      if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
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
        drawSelectedMove(@pokemon,moveToLearn,newmove)
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
        drawSelectedMove(@pokemon,moveToLearn,newmove)
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
    drawSelectedMove(@pokemon,0,@pokemon.moves[selmove].id)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index==@sprites["movesel"].index
        @sprites["movepresel"].z=@sprites["movesel"].z+1
      else
        @sprites["movepresel"].z=@sprites["movesel"].z
      end
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        break if !switching
        @sprites["movepresel"].visible=false
        switching=false
      end
      if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
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
              drawSelectedMove(@pokemon,0,@pokemon.moves[selmove].id)
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
        drawSelectedMove(@pokemon,0,newmove)
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
        drawSelectedMove(@pokemon,0,newmove)
      end
    end 
    @sprites["movesel"].visible=false
  end

  def pbGoToPrevious
    stopped=false
    if @page!=0 
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
    if @page!=0
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex] && !@party[newindex].isEgg?
          @partyindex=newindex
          stopped=true
          break
        end
      end
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
      if Input.trigger?(Input::A) || Input.triggerex?(Input::CenterMouseKey)
        pbSEStop
        pbPlayCry(@pokemon)
      end
      if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
        pbPlayCancelSE()
        break
      end
      dorefresh=false
      if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
        if @page==0
          pbPlayCancelSE()
          break
        elsif @page==5
          pbPlayDecisionSE()
          pbMoveSelection
          dorefresh=true
          drawPageSix(@pokemon)
        end
      end
      if Input.trigger?(Input::UP) # && @partyindex>0
        oldindex=@partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].color=Color.new(0,0,0,0)
          @sprites["itemicon2"].item = @pokemon.item
          pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,180)
          dorefresh=true
          pbSEStop
          pbPlayCursorSE()
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
          @sprites["itemicon2"].item = @pokemon.item
          pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,180)
          dorefresh=true
          pbSEStop
          pbPlayCursorSE()
          pbPlayCry(@pokemon)
        end
      end
      if Input.trigger?(Input::LEFT) && !@pokemon.isEgg?
        oldpage=@page
        @page-=1
        @page=7 if @page<0
        @page=0 if @page>7
        dorefresh=true
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          pbSEPlay("SumCursor")
          dorefresh=true
        end
      end
      if Input.trigger?(Input::RIGHT) && !@pokemon.isEgg?
        oldpage=@page
        @page+=1
        @page=7 if @page<0
        @page=0 if @page>7
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          pbSEPlay("SumCursor")
          dorefresh=true
        end
      end
      if dorefresh
        @sprites["itemicon2"].item = @pokemon.item
        case @page
        when 0
          drawPageOne(@pokemon) # Pokemon Information
        when 1
          drawPageTwo(@pokemon) # Trainer Information
        when 2
          drawPageThree(@pokemon) # Pokemon Statistics
        when 3
          drawPageFour(@pokemon) # Effort Values
        when 4
          drawPageFive(@pokemon) # Individual Values
        when 5
          drawPageSix (@pokemon) # Pokemon Moves
        when 6
          drawPageSeven (@pokemon) # Ribbons
        when 7
          drawPageEight (@pokemon) # Advanced Information
        end
        pbPositionPokemonSprite(@sprites["pokemon"],$summarysizex,180)
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
