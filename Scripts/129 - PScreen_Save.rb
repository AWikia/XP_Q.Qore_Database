class PokemonSaveScene
  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @bgbitmap=AnimatedBitmap.new("Graphics/UI/Load/panels")
    title=['bg','bg_beta','bg_dev','bg_canary','bg_internal','bg_upgradewizard'][QQORECHANNEL]
    if pbResolveBitmap(_INTL("Graphics/UI/"+getDarkModeFolder+"/Load/{1}",title))
      addBackgroundOrColoredPlane(@sprites,"background",getDarkModeFolder+"/Load/"+title,
         Color.new(242,242,242),@viewport)
    elsif pbResolveBitmap(sprintf("Graphics/UI/"+getDarkModeFolder+"/Load/bg"))
      addBackgroundOrColoredPlane(@sprites,"background",getDarkModeFolder+"/Load/bg",
         Color.new(242,242,242),@viewport)
    else  # Hotfixing Prograda
      addBackgroundOrColoredPlane(@sprites,"background",getDarkModeFolder+"/Load/bg_empty",
         Color.new(242,242,242),@viewport)
    end
      addBackgroundOrColoredPlane(@sprites,"partybg_title",getDarkModeFolder+"/party_bg",
         Color.new(12,12,12),@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    title=RTP.getGameIniValue("Game", "Game") # QQC Edit 
    title=RTP.getGameIniValue("Game","Title") if title==""
    title="RGSS Game" if title==""
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Save Game - {1}",title),
        2,-18,576,64,@viewport)      
    @sprites["header"].baseColor=(isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].shadowColor=nil #(!isDarkMode?) ? Color.new(242,242,242) : Color.new(12,12,12)
    @sprites["header"].windowskin=nil
    @sprites["header"].z=2
    # Player's Data
    
    panelrect=Rect.new(0,0,408,222)
    x = (24*2)+64
    y = 50
    @sprites["overlay"].bitmap.blt(x,y,@bgbitmap.bitmap,panelrect)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textpos=[]
    textpos.push([_INTL("Save"),(16*2)+x,(5*2)+y,y,Color.new(232,232,232),Color.new(136,136,136)])
    textpos.push([_INTL("Badges:"),(16*2)+x,(56*2)+y,0,Color.new(232,232,232),Color.new(136,136,136)])
    textpos.push([$Trainer.numbadges.to_s,(103*2)+x,(56*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)])
    textpos.push([_INTL("Pokédex:"),(16*2)+x,(72*2)+y,0,Color.new(232,232,232),Color.new(136,136,136)])
    textpos.push([$Trainer.pokedexOwned.to_s+"/"+$Trainer.pokedexSeen.to_s,(103*2)+x,(72*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)]) if $Trainer.pokedex
    textpos.push(["-//-",(103*2)+x,(72*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)]) if !$Trainer.pokedex
    textpos.push([_INTL("Time:"),(16*2)+x,(88*2)+y,0,Color.new(232,232,232),Color.new(136,136,136)])
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    if hour>0
      textpos.push([_INTL("{1}h {2}m",hour,min),(103*2)+x,(88*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)])
    else
      textpos.push([_INTL("{1}m",min),(103*2)+y,(88*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)])
    end
    if $Trainer.isMale?
      textpos.push([$Trainer.name,(56*2)+x,(32*2)+y,0,Color.new(56,160,248),Color.new(56,104,168)])
    else
      textpos.push([$Trainer.name,(56*2)+x,(32*2)+y,0,Color.new(240,72,88),Color.new(160,64,64)])
    end
    mapname=$game_map.name
    mapname.gsub!(/\\PN/,$Trainer.name)
    textpos.push([mapname,(193*2)+x,(5*2)+y,1,Color.new(232,232,232),Color.new(136,136,136)])
    
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    
    # Graphics
    if !$Trainer || !$Trainer.party
    else
      meta=pbGetMetadata(0,MetadataPlayerA+$Trainer.metaID)
      if meta
        filename=pbGetPlayerCharset(meta,1,$Trainer)
        @sprites["player"]=TrainerWalkingCharSprite.new(filename,@viewport)
        @sprites["player"].animspeed=101
        charwidth=@sprites["player"].bitmap.width
        charheight=@sprites["player"].bitmap.height
        @sprites["player"].x = (56*2)+64 - charwidth/8
        @sprites["player"].y = (56*2)+16 - charheight/8 + 4
        @sprites["player"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
      end
      for i in 0...$Trainer.party.length
        @sprites["party#{i}"]=PokemonBoxIcon.new($Trainer.party[i],@viewport)
        @sprites["party#{i}"].z=99998
        @sprites["party#{i}"].x=((151*2)+64)+33*2*(i&1)
        @sprites["party#{i}"].y=36*2+25*2*(i/2)+4+16
      end
    end
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndScreen
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @bgbitmap.dispose
    @viewport.dispose
  end
end



def pbEmergencySave
  oldscene=$scene
  $scene=nil
#  Kernel.pbMessage(_INTL("The script is taking too long. The game will restart. If this happens constantly, this may be due to the weak processor or RAM"))
    Kernel.pbMessage(_INTL("Qora Qore must be restared due to a script hang. If this happens constantly, this may be due to the weak processor or RAM"))
  return if !$Trainer
  if safeExists?(RTP.getSaveFileName("Game.rxdata"))
    File.open(RTP.getSaveFileName("Game.rxdata"),  'rb') {|r|
       File.open(RTP.getSaveFileName("Game.rxdata.bak"), 'wb') {|w|
          while s = r.read(4096)
            w.write s
          end
       }
    }
  end
  if pbSave
    Kernel.pbMessage(_INTL("\\me[]The game was saved.\\me[Save]\\wtnp[30]"))
  else
    Kernel.pbMessage(_INTL("\\me[]Save failed.\\wtnp[30]"))
  end
  $scene=oldscene
end

def pbSave(safesave=false)
  $Trainer.metaID=$PokemonGlobal.playerID
  begin
    File.open(RTP.getSaveFileName("Game.rxdata"),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
    }
    Graphics.frame_reset
  rescue
    return false
  end
  return true
end



class PokemonSave
  def initialize(scene)
    @scene=scene
  end

  def pbDisplay(text,brief=false)
    @scene.pbDisplay(text,brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret=false
    @scene.pbStartScreen
    if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
      if safeExists?(RTP.getSaveFileName("Game.rxdata"))
        confirm=""
        if $PokemonTemp.begunNewGame
          Kernel.pbMessage(_INTL("ATTENTION!"))
          Kernel.pbMessage(_INTL("There is a different game file that is already saved."))
          Kernel.pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
          if !Kernel.pbConfirmMessageSerious(
             _INTL("Are you sure you want to save now and overwrite the other save file?"))
              pbPlaySaveSE()
             @scene.pbEndScreen
            return false
          end
#        else
#          if !Kernel.pbConfirmMessage(
#             _INTL("There is already a saved file. Is it OK to overwrite it?"))
#            @scene.pbEndScreen
#            return false
#          end
        end
      end
      $PokemonTemp.begunNewGame=false
      pbPlaySaveSE()
      if pbSave
        Kernel.pbMessage(_INTL("\\me[]{1} saved the game.\\me[Save]\\wtnp[30]",$Trainer.name))
        ret=true
      else
        Kernel.pbMessage(_INTL("\\me[]Save failed.\\wtnp[30]"))
        ret=false
      end
    else
      pbPlaySaveSE()
    end
    @scene.pbEndScreen
    return ret
  end
end