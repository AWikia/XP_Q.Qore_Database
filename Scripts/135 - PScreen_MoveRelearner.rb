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
    addBackgroundPlane(@sprites,"bg","reminderbg",@viewport)
    @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=288
    @sprites["pokeicon"].y=44
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/reminderSel")
    @sprites["background"].y=78
    @sprites["background"].src_rect=Rect.new(0,72,258,72)
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
       [_INTL("Teach which move?"),16,8,0,Color.new(88,88,80),Color.new(168,184,184)]
    ]
    yPos=82
    for i in 0...VISIBLEMOVES
      moveobject=@moves[@sprites["commands"].top_item+i]
      if moveobject
        movedata=PBMoveData.new(moveobject)
        if movedata
          imagepos.push(["Graphics/Global Pictures/types",12,yPos+2,64*$PokemonSystem.colortige,
          movedata.type*28,64,28])
=begin
       How to add more entries:
        * You must define your new type
        * You must make a new array in the typeColors array that must be below
          * the last type it is defined. The first Color of the new sub-array
          * is the base color, whereas the second one is the shadow color
        * You may use a color set used by an existing type such as for the Glimse
          * type re-using the color set used by the shadow color
        * Have fun with the colors!!! --Qore Qore Telecommunities
=end
    typeColors=[
          # Ordinal Types
            [Color.new(168,168,120),Color.new(112,88,72)],     # Normal
            [Color.new(192,48,40),Color.new(72,64,56)],        # Fighting
            [Color.new(168,144,240),Color.new(112,88,152)],    # Flying
            [Color.new(160,64,160),Color.new(72,56,80)],       # Poison
            [Color.new(224,192,104),Color.new(136,104,48)],    # Ground
            [Color.new(184,160,56),Color.new(136,104,48)],     # Rock
            [Color.new(168,184,32),Color.new(120,144,16)],     # Bug
            [Color.new(112,88,152),Color.new(72,56,80)],       # Ghost
            [Color.new(184,184,208),Color.new(128,120,112)],   # Steel
            [Color.new(104,160,144),Color.new(32,104,96)],     # ΡΩΤΙΜΑΤΙΚΑ
            [Color.new(240,128,48),Color.new(192,48,40)],      # Fire
            [Color.new(104,144,240),Color.new(128,120,112)],   # Water
            [Color.new(120,200,80),Color.new(88,128,64)],      # Grass
            [Color.new(248,208,48),Color.new(184,160,56)],     # Electric
            [Color.new(248,88,136),Color.new(144,96,96)],      # Psychic
            [Color.new(152,216,216),Color.new(144,144,160)],   # Ice
            [Color.new(112,56,248),Color.new(72,56,144)],      # Dragon
            [Color.new(112,88,72),Color.new(72,64,56)],        # Dark
            [Color.new(255,101,213),Color.new(237,85,181)],    # Fairy
          # Shadow and FLINT Types
            [Color.new(255,170,0),Color.new(234,136,0)],       # Magic
            [Color.new(73,73,73),Color.new(15,15,15)],         # Doom
            [Color.new(242,26,147),Color.new(207,35,89)],      # Jelly
            [Color.new(112,16,208),Color.new(80,16,144)],      # Shadow
            [Color.new(202,202,220),Color.new(161,154,147)],   # Sharpener
            [Color.new(230,0,0),Color.new(167,0,0)],           # Lava
            [Color.new(117,184,32),Color.new(77,144,16)],      # Wind
            [Color.new(108,72,112),Color.new(89,58,89)],       # Lick
            [Color.new(128,60,160),Color.new(64,56,80)],       # Bolt
            [Color.new(243,134,25),Color.new(208,126,11)],     # Herb
            [Color.new(105,221,201),Color.new(77,179,157)],    # Chlorophyll
            [Color.new(71,179,255),Color.new(54,129,179)],     # Gust
            [Color.new(240,160,48),Color.new(192,73,40)],      # Sun
            [Color.new(101,92,115),Color.new(74,69,78)],       # Moon
            [Color.new(236,100,175),Color.new(140,100,110)],   # Mind
            [Color.new(255,134,202),Color.new(255,121,163)],   # Heart
            [Color.new(87,173,235),Color.new(59,111,163)],     # Blizzard
            [Color.new(101,202,51),Color.new(94,108,65)],      # Gas
            [Color.new(55,55,72),Color.new(28,28,36)],         # Glimse
            [Color.new(184,56,59),Color.new(136,48,65)],       # Robot
            ]
          textpos.push([PBMoves.getName(moveobject),80,yPos,0,
             typeColors[movedata.type][0],typeColors[movedata.type][1]])
          if movedata.totalpp>0
            textpos.push([_INTL("PP"),112,yPos+32,0,
               Color.new(64,64,64),Color.new(176,176,176)])
            textpos.push([_ISPRINTF("{1:d}/{2:d}",
               movedata.totalpp,movedata.totalpp),230,yPos+32,1,
               Color.new(64,64,64),Color.new(176,176,176)])
          end
        else
          textpos.push(["-",80,yPos,0,Color.new(64,64,64),Color.new(176,176,176)])
          textpos.push(["--",228,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
        end
      end
      yPos+=64
    end
    imagepos.push(["Graphics/Pictures/reminderSel",
       0,78+(@sprites["commands"].index-@sprites["commands"].top_item)*64,
       0,0,258,72])
    selmovedata=PBMoveData.new(@moves[@sprites["commands"].index])
    basedamage=selmovedata.basedamage
    category=selmovedata.category
    accuracy=selmovedata.accuracy
    textpos.push([_INTL("Category"),272,114,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([_INTL("Power"),272,146,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          468+64,146,2,Color.new(64,64,64),Color.new(176,176,176)])
    textpos.push([_INTL("Accuracy"),272,178,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([accuracy==0 ? "---" : sprintf("%d",accuracy),
          468+64,178,2,Color.new(64,64,64),Color.new(176,176,176)])
    pbDrawTextPositions(overlay,textpos)
    imagepos.push(["Graphics/Pictures/category",436+64,116,0,category*28,64,28])
    if @sprites["commands"].index<@moves.length-1
      imagepos.push(["Graphics/Pictures/reminderButtons",48,350,0,0,76,32])
    end
    if @sprites["commands"].index>0
      imagepos.push(["Graphics/Pictures/reminderButtons",134,350,76,0,76,32])
    end
    pbDrawImagePositions(overlay,imagepos)
    drawTextEx(overlay,272,210,238+64,5,
       pbGetMessage(MessageTypes::MoveDescriptions,@moves[@sprites["commands"].index]),
       Color.new(64,64,64),Color.new(176,176,176))
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
         if Input.trigger?(Input::B) || Input.triggerex?(Input::RightMouseKey)
           return 0
         end
         if Input.trigger?(Input::C) || Input.triggerex?(Input::LeftMouseKey)
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
