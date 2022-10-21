def pbEachNaturalMove(pokemon)
  movelist=pokemon.getMoveList
  for i in movelist
    yield i[1],i[0]
  end
end

def pbHasRelearnableMove?(pokemon)
  return pbGetRelearnableMoves(pokemon).length>0
end

def pbGetRelearnableMoves(pokemon)
  return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
  moves=[]
  pbEachNaturalMove(pokemon){|move,level|
     if level<=pokemon.level && !pokemon.hasMove?(move)
       moves.push(move) if !moves.include?(move)
     end
  }
  tmoves=[]
  if pokemon.firstmoves
    for i in pokemon.firstmoves
      tmoves.push(i) if !pokemon.hasMove?(i) && !moves.include?(i)
    end
  end
  moves=tmoves+moves
  return moves|[] # remove duplicates
end



################################################################################
# Scene class for handling appearance of the screen
################################################################################
class MoveRelearnerScene
  VISIBLEMOVES = 4

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

# Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon,moves)
    @pokemon=pokemon
    @moves=moves
    moveCommands=[]
    moves.each{|i| moveCommands.push(PBMoves.getName(i)) }
    # Create sprite hash
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    addBackgroundPlane(@sprites,"bg",getDarkModeFolder+"/reminderbg",@viewport)
    @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=288
    @sprites["pokeicon"].y=44
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/"+getAccentFolder+"/reminderSel")
    @sprites["background"].y=78
    @sprites["background"].src_rect=Rect.new(0,72,258,72)
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Teach which move to {1}?", @pokemon.name),
       2,-18,512,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["commands"]=Window_CommandPokemon.new(moveCommands,32)
    @sprites["commands"].x=Graphics.width
    @sprites["commands"].height=32*(VISIBLEMOVES+1)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    @typebitmap=AnimatedBitmap.new("Graphics/Global Pictures/types")
    pbDrawMoveList
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawMoveList
    if (!isDarkMode?)
      baseColor=Color.new(88,88,80)
      shadowColor=Color.new(168,184,184)
    else
      baseColor=Color.new(248,248,240)
      shadowColor=Color.new(72,88,88)
    end
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    textpos=[]
    imagepos=[]
    type1rect=Rect.new(64*$PokemonSystem.colortige,@pokemon.type1*28,64,28)
    type2rect=Rect.new(64*$PokemonSystem.colortige,@pokemon.type2*28,64,28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(400,70,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(366,70,@typebitmap.bitmap,type1rect)
      overlay.blt(436,70,@typebitmap.bitmap,type2rect)
    end
    textpos=[
#       [_INTL("Teach which move?"),16,8,0,baseColor,shadowColor]
    ]

    yPos=82
    dark = (isDarkMode?) ? [2,0] : [0,1]
    for i in 0...VISIBLEMOVES
      moveobject=@moves[@sprites["commands"].top_item+i]
      if moveobject
        movedata=PBMoveData.new(moveobject)
        if movedata
          imagepos.push(["Graphics/Global Pictures/types",12,yPos+2,64*$PokemonSystem.colortige,
          movedata.type*28,64,28])
          textpos.push([PBMoves.getName(moveobject),80,yPos,0,
             typeColors[movedata.type][dark[0]],typeColors[movedata.type][dark[1]]])
          if movedata.totalpp>0
            textpos.push([_INTL("PP"),112,yPos+32,0,
               baseColor,shadowColor])
            textpos.push([_ISPRINTF("{1:d}/{2:d}",
               movedata.totalpp,movedata.totalpp),230,yPos+32,1,
               baseColor,shadowColor])
          end
        else
          textpos.push(["-",80,yPos,0,baseColor,shadowColor])
          textpos.push(["--",228,yPos+32,1,baseColor,shadowColor])
        end
      end
      yPos+=64
    end
    imagepos.push(["Graphics/Pictures/"+getAccentFolder+"/reminderSel",
       0,78+(@sprites["commands"].index-@sprites["commands"].top_item)*64,
       0,0,258,72])
    selmovedata=PBMoveData.new(@moves[@sprites["commands"].index])
    basedamage=selmovedata.basedamage
    category=selmovedata.category
    accuracy=selmovedata.accuracy
    textpos.push([_INTL("Category"),272,114,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([_INTL("Power"),272,146,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          468+64,146,2,baseColor,shadowColor])
    textpos.push([_INTL("Accuracy"),272,178,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([accuracy==0 ? "---" : sprintf("%d",accuracy),
          468+64,178,2,baseColor,shadowColor])
    pbDrawTextPositions(overlay,textpos)
    imagepos.push(["Graphics/Pictures/category",436+64,116,64*$PokemonSystem.colortige,category*28,64,28])
    if @sprites["commands"].index<@moves.length-1
      imagepos.push(["Graphics/Pictures/"+getDarkModeFolder+"/reminderButtons",48,350,0,0,76,32])
    end
    if @sprites["commands"].index>0
      imagepos.push(["Graphics/Pictures/"+getDarkModeFolder+"/reminderButtons",134,350,76,0,76,32])
    end
    pbDrawImagePositions(overlay,imagepos)
    drawTextEx(overlay,272,210,238+64,5,
       pbGetMessage(MessageTypes::MoveDescriptions,@moves[@sprites["commands"].index]),
       baseColor,shadowColor)
  end

# Processes the scene
  def pbChooseMove
    oldcmd=-1
    pbActivateWindow(@sprites,"commands"){
       loop do
         oldcmd=@sprites["commands"].index
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["commands"].index!=oldcmd
           @sprites["background"].x=0
           @sprites["background"].y=78+(@sprites["commands"].index-@sprites["commands"].top_item)*64
           pbDrawMoveList
         end
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C)
           return @moves[@sprites["commands"].index]
         end
       end
    }
  end

# End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @typebitmap.dispose
    @viewport.dispose # Dispose the viewport
  end
end



# Screen class for handling game logic
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    moves=pbGetRelearnableMoves(pokemon)
    @scene.pbStartScene(pokemon,moves)
    loop do
      move=@scene.pbChooseMove
      if move<=0
        if @scene.pbConfirm(
          _INTL("Give up trying to teach a new move to {1}?",pokemon.name))
          @scene.pbEndScene
          return false
        end
      else
        if @scene.pbConfirm(_INTL("Teach {1}?",PBMoves.getName(move)))
          if pbLearnMove(pokemon,move)
            @scene.pbEndScene
            return true
          end
        end
      end
    end
  end
end



def pbRelearnMoveScreen(pokemon)
  retval=true
  pbFadeOutIn(99999){
     scene=MoveRelearnerScene.new
     screen=MoveRelearnerScreen.new(scene)
     retval=screen.pbStartScreen(pokemon)
  }
  return retval
end