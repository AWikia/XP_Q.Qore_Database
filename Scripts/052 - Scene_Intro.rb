class IntroEventScene < EventScene
  def initialize(pics,splash,viewport=nil)
    super(nil)
    @pics=pics
    @splash=splash
    @pic=addImage(0,0,"")
    @pic.moveOpacity(0,0,0) # fade to opacity 0 in 0 frames after waiting 0 frames
    @pic2=addImage(0,322,"") # flashing "Press Enter" picture
    @pic2.moveOpacity(0,0,0)
    @index=0
    @timer=0 # reset the timer
    data_system = pbLoadRxData("Data/System")
#    pbBGMPlay(data_system.title_bgm)
    openPic(self,nil) rescue openSplash(self,nil)
  end

  def openPic(scene,args)
    onCTrigger.clear
    @pic.name="Graphics/Titles/"+@pics[@index]
    @pic.moveOpacity(15,0,255) # fade to opacity 255 in 15 frames after waiting 0 frames
    pictureWait
    @timer=0 # reset the timer
    onUpdate.set(method(:timer)) # call timer every frame
    onCTrigger.set(method(:closePic)) # call closePic when C key is pressed
  end

  def timer(scene,args)
    @timer+=1
    if @timer>80
      @timer=0
      closePic(scene,args) # Close the picture
    end
  end

  def closePic(scene,args)
    onCTrigger.clear
    onUpdate.clear
    @pic.moveOpacity(15,0,0)
    pictureWait
    @index+=1 # Move to the next picture
    if @index>=@pics.length
      openSplash(scene,args)
    else
      openPic(scene,args)
    end
  end

  def openSplash(scene,args)
    # Play BGM
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
    # Play BGM End
    onCTrigger.clear
    onUpdate.clear
    @pic.name="Graphics/Titles/"+@splash
    @pic.moveOpacity(15,0,255)
    @pic2.name="Graphics/Titles/start"
    @pic2.moveOpacity(15,0,255)
    pictureWait
    onUpdate.set(method(:splashUpdate))  # call splashUpdate every frame
    onCTrigger.set(method(:closeSplash)) # call closeSplash when C key is pressed
    onBTrigger.set(method(:quitGame)) # call closeSplash when C key is pressed
  end

  def splashUpdate(scene,args)
    @timer+=1
    @timer=0 if @timer>=80
    if @timer>=32
      @pic2.moveOpacity(0,0,8*(@timer-32))
    else
      @pic2.moveOpacity(0,0,255-(8*@timer))
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::B) &&
       Input.press?(Input::CTRL)
      closeSplashDelete(scene,args)
    end
  end

  def closeSplash(scene,args)
    onCTrigger.clear
    onUpdate.clear
    # Play random cry
    cry=pbCryFile(1+rand(PBSpecies.maxValue))
    pbSEPlay(cry,80,100) if cry
    # Fade out
    @pic.moveOpacity(15,0,0)
    @pic2.moveOpacity(15,0,0)
#    pbBGMStop(1.0) # Not required any longer.
    pictureWait
    scene.dispose # Close the scene
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def closeSplashDelete(scene,args)
    onCTrigger.clear
    onUpdate.clear
    # Play random cry
    cry=pbCryFile(1+rand(PBSpecies.maxValue))
    pbSEPlay(cry,80,100) if cry
    # Fade out
    @pic.moveOpacity(15,0,0)
    @pic2.moveOpacity(15,0,0)
#    pbBGMStop(1.0) # Not required any longer.
    pictureWait
    scene.dispose # Close the scene
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartDeleteScreen
  end
end

def quitGame(scene,args)
  if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
    @pic.moveOpacity(15,0,0)
    @pic2.moveOpacity(15,0,0)
#    pbBGMStop(1.0) # Not required any longer.
    pictureWait
    scene.dispose # Close the scene
    $scene=nil
    return
  end
end

class Scene_Intro
  def initialize(pics, splash = nil)
    @pics=pics
    @splash=splash
  end

  def main
    Graphics.transition(0)
    @eventscene=IntroEventScene.new(@pics,@splash,nil)
    @eventscene.main
    Graphics.freeze
  end
end