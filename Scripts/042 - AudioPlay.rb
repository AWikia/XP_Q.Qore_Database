def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    pitch=$3.to_i
    return RPG::AudioFile.new(file,volume,pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    return RPG::AudioFile.new(file,volume,100)
  else
    return RPG::AudioFile.new(str,100,100)
  end
end

# Converts an object to an audio file. 
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str,volume=nil,pitch=nil)
  if str.is_a?(String)
    str=pbStringToAudioFile(str)
    str.volume=100
    str.volume=volume if volume
    str.pitch=100
    str.pitch=pitch if pitch
  end
  if str.is_a?(RPG::AudioFile)
    if volume || pitch
      return RPG::AudioFile.new(str.name,
                                volume||str.volume||100,
                                pitch||str.pitch||100)
    else
      return str
    end
  end
  return str
end

################################################################################

# Plays a BGM file.
# param -- Either a string showing the filename 
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGMPlay(param,volume=nil,pitch=nil)
  return if !param
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgm_play")
      $game_system.bgm_play(param)
      return
    elsif (RPG.const_defined?(:BGM) rescue false)
      b=RPG::BGM.new(param.name,param.volume,param.pitch-0)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    param.pitch-=5
    Audio.bgm_play(canonicalize("Audio/BGM/"+param.name),param.volume,param.pitch-0)
  end
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x=0.0); pbBGMStop(x);end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgm_fade")
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgm_stop")
    $game_system.bgm_stop
    return
  elsif (RPG.const_defined?(:BGM) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGM.fade((timeInSeconds*1000).floor) : RPG::BGM.stop
      return
    rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgm_fade((timeInSeconds*1000).floor) : Audio.bgm_stop
end

################################################################################

# Plays an ME file.
# param -- Either a string showing the filename 
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param,volume=nil,pitch=nil)
  return if !param
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("me_play")
      $game_system.me_play(param)
      return
    elsif (RPG.const_defined?(:ME) rescue false)
      b=RPG::ME.new(param.name,param.volume,param.pitch-0)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.me_play(canonicalize("Audio/ME/"+param.name),param.volume,param.pitch-0)
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x=0.0); pbMEStop(x);end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  elsif (RPG.const_defined?(:ME) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::ME.fade((timeInSeconds*1000).floor) : RPG::ME.stop
      return
    rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.me_fade((timeInSeconds*1000).floor) : Audio.me_stop
end

################################################################################

# Plays a BGS file.
# param -- Either a string showing the filename 
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param,volume=nil,pitch=nil)
  return if !param
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgs_play")
      $game_system.bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b=RPG::BGS.new(param.name,param.volume,param.pitch-0)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgs_play(canonicalize("Audio/BGS/"+param.name),param.volume,param.pitch-0)
  end
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x=0.0); pbBGSStop(x);end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgs_fade")
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgs_play")
    $game_system.bgs_play(nil)
    return
  elsif (RPG.const_defined?(:BGS) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGS.fade((timeInSeconds*1000).floor) : RPG::BGS.stop
      return
    rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgs_fade((timeInSeconds*1000).floor) : Audio.bgs_stop
end

################################################################################

# Plays an SE file.
# param -- Either a string showing the filename 
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                  volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbSEPlay(param,volume=nil,pitch=nil)
  return if !param
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param)
      return
    elsif (RPG.const_defined?(:SE) rescue false)
      b=RPG::SE.new(param.name,param.volume,param.pitch-0)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.se_play(canonicalize("Audio/SE/"+param.name),param.volume,param.pitch-0)
  end
end

# Stops SE playback.
def pbSEFade(x=0.0); pbSEStop(x);end

# Stops SE playback.
def pbSEStop(timeInSeconds=0.0)
  if $game_system
    $game_system.se_stop
  elsif (RPG.const_defined?(:SE) rescue false)
    RPG::SE.stop rescue nil
  else
    Audio.se_stop
  end
end

################################################################################

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE()
  if $data_system && $data_system.respond_to?("cursor_se") &&
     $data_system.cursor_se && $data_system.cursor_se.name!=""
    pbSEPlay($data_system.cursor_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[0] && $data_system.sounds[0].name!=""
    pbSEPlay($data_system.sounds[0])
  elsif FileTest.audio_exist?("Audio/SE/GUI sel cursor")
    pbSEPlay("GUI sel cursor",100)
  end
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE()
  if $data_system && $data_system.respond_to?("decision_se") &&
     $data_system.decision_se && $data_system.decision_se.name!=""
    pbSEPlay($data_system.decision_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[1] && $data_system.sounds[1].name!=""
    pbSEPlay($data_system.sounds[1])
  elsif FileTest.audio_exist?("Audio/SE/GUI sel decision")
    pbSEPlay("GUI sel decision",100)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE()
  if $data_system && $data_system.respond_to?("cancel_se") &&
     $data_system.cancel_se && $data_system.cancel_se.name!=""
    pbSEPlay($data_system.cancel_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[2] && $data_system.sounds[2].name!=""
    pbSEPlay($data_system.sounds[2])
  elsif FileTest.audio_exist?("Audio/SE/GUI sel cancel")
    pbSEPlay("GUI sel cancel",100)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE()
  if $data_system && $data_system.respond_to?("buzzer_se") &&
     $data_system.buzzer_se && $data_system.buzzer_se.name!=""
    pbSEPlay($data_system.buzzer_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[3] && $data_system.sounds[3].name!=""
    pbSEPlay($data_system.sounds[3])
  elsif FileTest.audio_exist?("Audio/SE/GUI sel buzzer")
    pbSEPlay("GUI sel buzzer",100)
  end
end

# Plays a sound effect that plays when changing between certain things.
def pbPlayEquipSE()
  if $data_system && $data_system.respond_to?("equip_se") &&
     $data_system.equip_se && $data_system.equip_se.name!=""
    pbSEPlay($data_system.equip_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[4] && $data_system.sounds[4].name!=""
    pbSEPlay($data_system.sounds[4])
  elsif FileTest.audio_exist?("Audio/SE/GUI party switch")
    pbSEPlay("GUI party switch",100)
  end
end

# Plays a sound effect that plays when saving a save file.
def pbPlaySaveSE()
  if $data_system && $data_system.respond_to?("save_se") &&
     $data_system.save_se && $data_system.save_se.name!=""
    pbSEPlay($data_system.save_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[6] && $data_system.sounds[6].name!=""
    pbSEPlay($data_system.sounds[6])
  elsif FileTest.audio_exist?("Audio/SE/Save choice")
    pbSEPlay("Save choice",100)
  end
end

# Plays a sound effect that plays when loading a save file.
def pbPlayLoadSE()
  if $data_system && $data_system.respond_to?("load_se") &&
     $data_system.load_se && $data_system.load_se.name!=""
    pbSEPlay($data_system.load_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[7] && $data_system.sounds[7].name!=""
    pbSEPlay($data_system.sounds[7])
  elsif FileTest.audio_exist?("Audio/SE/Load")
    pbSEPlay("Load",100)
  end
end

# Plays a sound effect that plays when starting a battle.
def pbPlayBattleStartSE()
  if $data_system && $data_system.respond_to?("battle_start_se") &&
     $data_system.battle_start_se && $data_system.battle_start_se.name!=""
    pbSEPlay($data_system.battle_start_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[8] && $data_system.sounds[8].name!=""
    pbSEPlay($data_system.sounds[8])
  elsif FileTest.audio_exist?("Audio/SE/Battle start")
    pbSEPlay("Battle start",100)
  end
end

# Plays a sound effect that plays when escaping from a battle.
def pbPlayEscapeSE()
  if $data_system && $data_system.respond_to?("escape_se") &&
     $data_system.escape_se && $data_system.escape_se.name!=""
    pbSEPlay($data_system.escape_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[9] && $data_system.sounds[9].name!=""
    pbSEPlay($data_system.sounds[9])
  elsif FileTest.audio_exist?("Audio/SE/flee")
    pbSEPlay("flee",100)
  end
end

# Plays a sound effect that plays when an non-opposing Pokemon faints.
def pbPlayActorCollapseSE()
  if $data_system && $data_system.respond_to?("actor_collapse_se") &&
     $data_system.actor_collapse_se && $data_system.actor_collapse_se.name!=""
    pbSEPlay($data_system.actor_collapse_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[10] && $data_system.sounds[10].name!=""
    pbSEPlay($data_system.sounds[10])
  elsif FileTest.audio_exist?("Audio/SE/faint_atk")
    pbSEPlay("faint_atk",100)
  elsif FileTest.audio_exist?("Audio/SE/faint")
    pbSEPlay("faint",100)
  end
end

# Plays a sound effect that plays when an opposing Pokemon faints.
def pbPlayEnemyCollapseSE()
  if $data_system && $data_system.respond_to?("enemy_collapse_se") &&
     $data_system.enemy_collapse_se && $data_system.enemy_collapse_se.name!=""
    pbSEPlay($data_system.enemy_collapse_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[11] && $data_system.sounds[11].name!=""
    pbSEPlay($data_system.sounds[11])
  elsif FileTest.audio_exist?("Audio/SE/faint_opp")
    pbSEPlay("faint_opp",100)
  elsif FileTest.audio_exist?("Audio/SE/faint")
    pbSEPlay("faint",100)
  end
end

# Plays a sound effect that plays when a Pokemon evades or misses a move.
def pbPlayMissSE()
  if FileTest.audio_exist?("Audio/SE/protection") # @FIXME: Use "GUI battle invalid action" instead
    pbSEPlay("protection",100)
  end
end