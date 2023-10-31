#===============================================================================
# * Type Quiz - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's a type quiz minigame where
# the player must know the multiplier of a certain type effectiveness in a
# certain type combination. You can use it by a normal message question or by
# a scene screen.
#
# The proportion of correct answers are made in way to every answer will have
# the same amount of being correct
#
# It is found in Sannse Lab after winning the Fairy Gym
#
# It is found here once you beat all 7 trainers, in Annuora4, a N.I. map
#
#===============================================================================
#
# To this script works, put it above main. 
#
# If you use the scene screen, put pictures of a background at 
# "Graphics/UI/Quiz/typequizbg" and a "VS" at "Graphics/UI/Quiz/typequizvs".
#
# To use the quiz in standard text message, calls the script
# 'TypeQuiz::TypeQuestion.new.messageQuestion' in a conditional branch and
# handle when the player answers correctly and incorrectly, respectively.
#
# To use the scene screen, use the script command 'TypeQuiz.scene(X)' 
# where X is the number of total questions. This method will return the number
# of question answered correctly.
#
#===============================================================================

module TypeQuiz
  # If false the last two answers merge into one, resulting in five answers
  SIXANSWERS = true
  # In scene points the right answer if the player miss
  SHOWRIGHTANSWER = true
  
  class TypeQuestion
    attr_reader   :attackType
    attr_reader   :defense1Type
    attr_reader   :defense2Type
    attr_reader   :result
    
    TYPEAVALIABLE = [:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
    ANSWERS = [ 
      _INTL("4x"),_INTL("2x"),_INTL("Normal"),_INTL("1/2")
    ]
    ANSWERS += SIXANSWERS ? 
        [_INTL("1/4"),_INTL("Immune")] : [_INTL("1/4 or immune")]
    TYPERESULTS = [ANSWERS.size-1,4,3,nil,2,nil,nil,nil,1,
        nil,nil,nil,nil,nil,nil,nil,0]  
    
    def initialize(answer=-1)
      answer=rand(ANSWERS.size) if(answer==-1)
      @result=-1#
      test=0
      while(@result!=answer)
        @attackType = getID(PBTypes,TYPEAVALIABLE[rand(TYPEAVALIABLE.size)])
        @defense1Type = getID(PBTypes,TYPEAVALIABLE[rand(TYPEAVALIABLE.size)])
        @defense2Type = getID(PBTypes,TYPEAVALIABLE[rand(TYPEAVALIABLE.size)])
        @result = TYPERESULTS[PBTypes.getCombinedEffectiveness(
          @attackType,@defense1Type,@defense2Type)]
      end  
    end
    
    def messageQuestion
      attackTypeName = PBTypes.getName(@attackType)
      defenseTypeName = PBTypes.getName(@defense1Type)
      defenseTypeName += "/"+PBTypes.getName(@defense2Type) if(
        @defense1Type!=@defense2Type)
      question=_INTL("What is the damage of an {1} move versus a {2} pokémon?",
        attackTypeName,defenseTypeName)
      return Kernel.pbMessage(question,ANSWERS,0)==result
    end  
  end
    
  class TypeQuizScene
    BGPATH = "Graphics/UI/Quiz/typequizbg"
    VSPATH = "Graphics/UI/Quiz/typequizvs"
    SCENEMUSIC = "Quizbgm" # Put "" or nil to don't change the music.
    
    WAITFRAMESQUANTITY=40*1
    MARGIN=32
    
    def update
      pbUpdateSpriteHash(@sprites)
    end
    
    def pbStartScene(questions)
      @questionsTotal=questions
      @questionsCount=0
      @questionsRight=0
      @index=0
      pbBGMPlay(SCENEMUSIC) if SCENEMUSIC && SCENEMUSIC!=nil
      @sprites={} 
      @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z=99999
      @typebitmap=AnimatedBitmap.new(_INTL("Graphics/UI/types"))
      @sprites["background"]=IconSprite.new(0,0,@viewport)
      @sprites["background"].setBitmap(BGPATH)
      @sprites["background"].x=(
        Graphics.width-@sprites["background"].bitmap.width)/2
      @sprites["background"].y=(
        Graphics.height-@sprites["background"].bitmap.height)/2    
      @sprites["vs"]=IconSprite.new(0,0,@viewport)
      @sprites["vs"].setBitmap(VSPATH)
      @sprites["vs"].x=Graphics.width*3/4-@sprites["vs"].bitmap.width/2-12
      @sprites["vs"].y=Graphics.height*3/4-@sprites["vs"].bitmap.height/2-32
      @sprites["arrow"]=IconSprite.new(MARGIN+8,0,@viewport)
      @sprites["overlay"]=BitmapSprite.new(
        Graphics.width,Graphics.height,@viewport)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      nextQuestion
      pbFadeInAndShow(@sprites) { update }
    end
    
    def nextQuestion
      @questionsCount+=1
      return if finished?
      @typeQuestion=TypeQuestion.new
      @answerLabel=""
      @sprites["arrow"].setBitmap("Graphics/UI/"+getAccentFolder+"/selarrow")
      refresh
      @index=2 # Normal effective index
      updateCursor
    end  
  
    def refresh
      leftText = ""
      centerText = ""
      rightText = ""
      overlay=@sprites["overlay"].bitmap
      overlay.clear 
      baseColor=Color.new(72,72,72)
      shadowColor=Color.new(160,160,160)
      leftText = @questionsRight.to_s # Remove to don't show player score
      centerText = @answerLabel # Remove to don't show Correct/Wrong message
      rightText += @questionsCount.to_s # Remove to don't show question count
      rightText += "/" if rightText!=""
      rightText += @questionsTotal.to_s # Remove to don't show question total
      textPositions=[
         [leftText,MARGIN,Graphics.height/2-80,false,
           baseColor,shadowColor],
         [centerText,Graphics.width/2,Graphics.height/2-80,2,
           baseColor,shadowColor],
         [rightText,Graphics.width-MARGIN,Graphics.height/2-80,true,
           baseColor,shadowColor]
      ]
      for i in 0...TypeQuestion::ANSWERS.size
        textPositions.push([TypeQuestion::ANSWERS[i],
          2*MARGIN,Graphics.height/2+i*40-40,false,baseColor,shadowColor])
      end 
      pbDrawTextPositions(overlay,textPositions)
      typeX = Graphics.width*3/4-40
      typeDefY = Graphics.height*3/4+40
      typeAtkRect=Rect.new(0,@typeQuestion.attackType*28,64,28)
      typeDef1Rect=Rect.new(0,@typeQuestion.defense1Type*28,64,28)
      typeDef2Rect=Rect.new(0,@typeQuestion.defense2Type*28,64,28)
      overlay.blt(typeX,Graphics.height/2-36,@typebitmap.bitmap,typeAtkRect)
      if @typeQuestion.defense1Type==@typeQuestion.defense2Type
        overlay.blt(typeX,typeDefY,@typebitmap.bitmap,typeDef1Rect)
      else
        overlay.blt(typeX-34,typeDefY,@typebitmap.bitmap,typeDef1Rect)
        overlay.blt(typeX+34,typeDefY,@typebitmap.bitmap,typeDef2Rect)
      end
    end
    
    def updateCursor
      @sprites["arrow"].y=Graphics.height/2+@index*40-40
    end  
  
    def pbMain
      waitFrames=0
      loop do
        Graphics.update
        Input.update
        self.update
        if finished?
          Kernel.pbMessage(_INTL("Game end! {1} correct answer(s)!",
            @questionsRight))
          return @questionsRight
        elsif waitFrames>0 # Waiting
          waitFrames-=1
        elsif @answerLabel!=""
          nextQuestion
        else  
          if Input.trigger?(Input::C)
            # Set frames to wait, after the result.
            waitFrames = WAITFRAMESQUANTITY
            if @typeQuestion.result==@index 
              @answerLabel=_INTL("Correct!")
              pbSEPlay("ItemGet") 
              @questionsRight+=1
            else
              @answerLabel=_INTL("Wrong!")
              pbSEPlay("buzzer") 
              if SHOWRIGHTANSWER
                @index=@typeQuestion.result
                @sprites["arrow"].setBitmap("Graphics/UI/"+getAccentFolder+"/selarrowwhite")
                updateCursor
                waitFrames*=2
              end
            end
            refresh
          end  
          if Input.trigger?(Input::B)
            pbSEPlay($data_system.decision_se) 
            return -1
          end
          if Input.repeat?(Input::UP)
            pbSEPlay($data_system.decision_se) 
            @index = (@index==0 ? TypeQuestion::ANSWERS.size : @index)-1
            updateCursor
          elsif Input.repeat?(Input::DOWN)
            pbSEPlay($data_system.decision_se) 
            @index = @index==(TypeQuestion::ANSWERS.size-1) ? 0 : @index+1
            updateCursor
          end
        end
      end
    end
    
    def finished?
      return @questionsCount>@questionsTotal
    end  
  
    def pbEndScene
      $game_map.autoplay if SCENEMUSIC && SCENEMUSIC!=nil
      pbFadeOutAndHide(@sprites) { update }
      pbDisposeSpriteHash(@sprites)
      @typebitmap.dispose
      @viewport.dispose
    end
  end
  
  class TypeQuizScreen
    def initialize(scene)
      @scene=scene
    end
  
    def pbStartScreen(questions=10)
      @scene.pbStartScene(questions)
      ret=@scene.pbMain
      @scene.pbEndScene
      return ret
    end
  end
  
  def self.scene(questions=10)
    ret=nil
    pbFadeOutIn(99999){
      scene = TypeQuizScene.new
      screen = TypeQuizScreen.new(scene)
      ret = screen.pbStartScreen(questions)
    }
    return ret
  end
end
