class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    fembutton=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/pokegearButtonf"))
    if $Trainer.isFemale? && fembutton
      @button=AnimatedBitmap.new("Graphics/Pictures/"+getDarkModeFolder+"/pokegearButtonf")
    else
      @button=AnimatedBitmap.new("Graphics/Pictures/"+getDarkModeFolder+"/pokegearButton")
    end
    @button2=AnimatedBitmap.new("Graphics/Pictures/"+getAccentFolder+"/linkgearSelection")
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @button2.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    self.bitmap.blt(0,0,@button2.bitmap,Rect.new(0,0,@button2.width,@button2.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,self.bitmap.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,self.bitmap.width/2,62,2,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
    icon=sprintf("Graphics/Pictures/pokegear"+@name)
    imagepos=[         # Icon is put on both unselected and selected buttons
       [icon,18,10,0,0,-1,-1],
       [icon,18,62,0,0,-1,-1]
    ]
    pbDrawImagePositions(self.bitmap,imagepos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    super
  end
end



#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
# Modified by Qora Qore Telecommunities
#===============================================================================
class Scene_PokegearScene
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def pbStartScene(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def pbPokegearScreen
    commands=[]
    @sprites={}
# OPTIONS - If you change these, you should also change update_command below.
    @cmdMap=-1
    @cmdPhone=-1
    @cmdJukebox=-1
    @cmdLink=-1
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
    commands[@cmdLink=commands.length]=_INTL("Link Battle") if $game_switches[12]

    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/"+getDarkModeFolder+"/pokegearButton")
    femback=pbResolveBitmap(sprintf("Graphics/Pictures/"+getDarkModeFolder+"/pokegearbgf"))
    forcedark = true
    if $Trainer && $Trainer.isFemale? && femback
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/pokegearbgf",@viewport)
      forcedark = false
    else
      addBackgroundPlane(@sprites,"background",getDarkModeFolder+"/pokegearbg",@viewport)
    end
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pokégear"),
       2,-18,128,64,@viewport)
    @sprites["header"].baseColor=(isDarkMode? || forcedark) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].shadowColor=nil #(!isDarkMode? && !forcedark) ? Color.new(248,248,248) : Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    for i in 0...commands.length
      x=118+64
      y=196 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=PokegearButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
    end
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
    end
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
    end
    pbUpdateSpriteHash(@sprites)
    #update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end
  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::C)
      if @cmdMap>=0 && @sprites["command_window"].index==@cmdMap
        pbPlayDecisionSE()
        pbShowMap(-1,false)
      end
      if @cmdPhone>=0 && @sprites["command_window"].index==@cmdPhone
        pbPlayDecisionSE()
        pbFadeOutIn(99999) {
           PokemonPhoneScene.new.start
        }
      end
      if @cmdJukebox>=0 && @sprites["command_window"].index==@cmdJukebox
        pbPlayDecisionSE()

        scene=Scene_JukeboxScene.new
        screen=Scene_Jukebox.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
        }
      end
      if @cmdLink>=0 && @sprites["command_window"].index==@cmdLink
        pbPlayDecisionSE()
        scene=Scene_LinkBattleScene.new
        screen=Scene_LinkBattle.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
        }
      end

      return
    end
  end
end


  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  

class Scene_Pokegear
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPokegearScreen
    @scene.pbEndScene
  end
end