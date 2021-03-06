class Game_Player
  def fullPattern
    case self.direction
    when 2
      return self.pattern
    when 4
      return 4+self.pattern
    when 6
      return 8+self.pattern
    when 8
      return 12+self.pattern
    else
      return 0
    end
  end

  def setDefaultCharName(chname,pattern)
    return if pattern<0 || pattern>=16
    @defaultCharacterName=chname
    @direction=[2,4,6,8][pattern/4]
    @pattern=pattern%4
  end

  def pbCanRun?
    return false if $game_temp.in_menu
    terrain=pbGetTerrainTag
    input=($PokemonSystem.runstyle==1) ? ($PokemonGlobal && $PokemonGlobal.runtoggle) : (Input.press?(Input::A))
    return input &&
       !pbMapInterpreterRunning? && !@move_route_forcing && 
       $PokemonGlobal && $PokemonGlobal.runningShoes &&
       !$PokemonGlobal.diving && !$PokemonGlobal.surfing &&
       !$PokemonGlobal.bicycle && !PBTerrain.onlyWalk?(terrain)
  end

  def pbIsRunning?
    return !moving? && !@move_route_forcing && $PokemonGlobal && pbCanRun?
  end

  def character_name
    if !@defaultCharacterName
      @defaultCharacterName=""
    end
    if @defaultCharacterName!=""
      return @defaultCharacterName
    end
    if !moving? && !@move_route_forcing && $PokemonGlobal
      meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
      if $PokemonGlobal.playerID>=0 && meta && 
         !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing
        if meta[4] && meta[4]!="" && Input.dir4!=0 && passable?(@x,@y,Input.dir4) && pbCanRun?
          # Display running character sprite
          @character_name=pbGetPlayerCharset(meta,4)
        else
          # Display normal character sprite 
          @character_name=pbGetPlayerCharset(meta,1)
        end
      end
    end
    return @character_name
  end

  alias update_old update

  def update
    if PBTerrain.isIce?(pbGetTerrainTag)
      @move_speed = $RPGVX ? 7: 5 # Was 7 and 5, 6.5 and 4.8
    elsif !moving? && !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        @move_speed = $RPGVX ? 8 : 6 # Was 6, then 8 and 5
      elsif pbCanRun? || $PokemonGlobal.surfing || $PokemonGlobal.diving
        @move_speed = $RPGVX ? 7 : 5 # Was 7 and 5, 6.5 and 4.8
      else
        @move_speed = $RPGVX ? 5 : 4     # Was 5 and 4, then 4.5 and 3.8
      end
    end
    update_old
  end
end


=begin
class Game_Character
  alias update_old2 update

  def update
    if self.is_a?(Game_Event)
      if @dependentEvents
        for i in 0...@dependentEvents.length
          if @dependentEvents[i][0]==$game_map.map_id &&
             @dependentEvents[i][1]==self.id
            @move_speed=$game_player.move_speed
            break
          end
        end
      end
    end
    update_old2
  end
end
=end