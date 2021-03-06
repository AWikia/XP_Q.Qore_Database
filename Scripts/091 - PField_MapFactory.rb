#===============================================================================
# Map Factory (allows multiple maps to be loaded at once and connected)
#===============================================================================
module MapFactoryHelper
  @@MapConnections=nil
  @@MapDims=nil

  def self.clear
    @@MapConnections=nil
    @@MapDims=nil
  end

# Returns the X or Y coordinate of an edge on the map with id.
# Considers the special strings "N","W","E","S"
  def self.getMapEdge(id,edge)
    return 0 if edge=="N" || edge=="W"
    dims=getMapDims(id) # Get dimensions
    return dims[0] if edge=="E"
    return dims[1] if edge=="S"
    return dims[0] # real dimension (use width)
  end

# Gets the height and width of the map with id
  def self.getMapDims(id)
    # Create cache if doesn't exist
    if !@@MapDims
      @@MapDims=[]
    end
    # Add map to cache if can't be found
    if !@@MapDims[id]
      begin
        map = pbLoadRxData(sprintf("Data/Map%03d", id))
        @@MapDims[id]=[map.width,map.height]
      rescue
        @@MapDims[id]=[0,0]
      end
    end
    # Return map in cache
    return @@MapDims[id]
  end

  def self.getMapConnections
    if !@@MapConnections
      @@MapConnections=[]
      begin
        conns=load_data("Data/connections.dat")
      rescue
        conns=[]
      end
      for i in 0...conns.length
        conn=conns[i]
        v=getMapEdge(conn[0],conn[1])
        dims=getMapDims(conn[0])
        next if dims[0]==0 || dims[1]==0
        if conn[1]=="N" || conn[1]=="S"
          conn[1]=conn[2]
          conn[2]=v
        elsif conn[1]=="E" || conn[1]=="W"
          conn[1]=v
        end
        v=getMapEdge(conn[3],conn[4])
        dims=getMapDims(conn[3])
        next if dims[0]==0 || dims[1]==0
        if conn[4]=="N" || conn[4]=="S"
          conn[4]=conn[5]
          conn[5]=v
        elsif conn[4]=="E" || conn[4]=="W"
          conn[4]=v
        end
        @@MapConnections.push(conn)
      end
    end
    return @@MapConnections
  end

  def self.hasConnections?(id)
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      return true if conn[0]==id || conn[3]==id
    end
    return false
  end

  def self.mapInRange?(map)
    dispx=map.display_x
    dispy=map.display_y
    return false if dispx>=map.width*Game_Map.realResX+768
    return false if dispy>=map.height*Game_Map.realResY+768
    return false if dispx<=-(Graphics.width*Game_Map::XSUBPIXEL+768)
    return false if dispy<=-(Graphics.height*Game_Map::YSUBPIXEL+768)
    return true
  end

  def self.mapInRangeById?(id,dispx,dispy)
    dims=MapFactoryHelper.getMapDims(id)
    return false if dispx>=dims[0]*Game_Map.realResX+768
    return false if dispy>=dims[1]*Game_Map.realResY+768
    return false if dispx<=-(Graphics.width*Game_Map::XSUBPIXEL+768)
    return false if dispy<=-(Graphics.height*Game_Map::XSUBPIXEL+768)
    return true
  end
end



class Game_Map
  def updateTileset
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
  end
end



def updateTilesets
  maps=$MapFactory.maps
  for map in maps
    map.updateTileset if map
  end
end



class PokemonMapFactory
  attr_reader :maps

  def initialize(id)
    @fixup=false
    @maps=[]
    @mapChanged=false # transient instance variable
    setup(id)
  end

  def map
    @mapIndex=0 if !@mapIndex || @mapIndex<0
    if !@maps[@mapIndex]
      if @maps.length==0
        raise "No maps in save file... (mapIndex=#{@mapIndex})"
      else
        for i in 0...@maps.length
          if @maps[i]
            echo("Using next map, may be incorrect (mapIndex=#{@mapIndex}, length=#{@maps.length})")
            return @maps[i]
          end
          raise "No maps in save file... (all maps empty; mapIndex=#{@mapIndex})"
        end
      end
    else
      return @maps[@mapIndex]
    end
  end

# Clears all maps and sets up the current map with id.  This function also sets
# the positions of neighboring maps and notifies the game system of a map change.
  def setup(id)
    @maps.clear
    @maps[0]=Game_Map.new
    @mapIndex=0
    oldID=(!$game_map) ? 0 : $game_map.map_id
    if oldID!=0 && oldID!=@maps[0]
      setMapChanging(id,@maps[0])
    end
    $game_map=@maps[0]
    @maps[0].setup(id)
    setMapsInRange
    setMapChanged(oldID)
  end

  def hasMap?(id)
    for map in @maps
      return true if map.map_id==id
    end
    return false
  end

  def getMapIndex(id)
    for i in 0...@maps.length
      return i if @maps[i].map_id==id
    end
    return -1
  end

  def setMapChanging(newID,newMap)
    Events.onMapChanging.trigger(self,newID,newMap)
  end

  def setMapChanged(prevMap)
    Events.onMapChange.trigger(self,prevMap)
    @mapChanged=true
  end

  def setSceneStarted(scene)
    Events.onMapSceneChange.trigger(self,scene,@mapChanged)
    @mapChanged=false
  end

# Similar to Game_Player#passable?, but supports map connections
  def isPassableFromEdge?(x,y)
    return true if $game_map.valid?(x,y)
    newmap=getNewMap(x,y)
    return false if !newmap
    return isPassable?(newmap[0].map_id,newmap[1],newmap[2])
  end

  def isPassableStrict?(mapID,x,y,thisEvent=nil)
    thisEvent=$game_player if !thisEvent
    map=getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x,y)
    return true if thisEvent.through
    if thisEvent==$game_player
      return false unless (($DEBUG || $TEST) && Input.press?(Input::CTRL)) || 
         map.passableStrict?(x,y,0,thisEvent)
    else
      return false unless map.passableStrict?(x,y,0,thisEvent)
    end
    for event in map.events.values
      if event!=thisEvent && event.x == x and event.y == y
        return false if !event.through && (event.character_name!="")
      end
    end
    return true
  end

  def isPassable?(mapID,x,y,thisEvent=nil)
    thisEvent=$game_player if !thisEvent
    map=getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x,y)
    return true if thisEvent.through
    if thisEvent==$game_player
      return false unless (($DEBUG || $TEST) && Input.press?(Input::CTRL)) || 
         map.passable?(x,y,0,thisEvent)
    else
      return false unless map.passable?(x,y,0,thisEvent)
    end
    for event in map.events.values
      if event.x == x and event.y == y
        return false if !event.through && (event.character_name!="")
      end
    end
    if thisEvent.is_a?(Game_Player)
      if thisEvent.x == x and thisEvent.y == y
        return false if !thisEvent.through && thisEvent.character_name != ""
      end
    end
    return true
  end

  def getMap(id)
    for map in @maps
      if map.map_id==id
        return map
      end
    end
    map=Game_Map.new
    map.setup(id)
    @maps.push(map)
    return map
  end

  def getMapNoAdd(id)
    for map in @maps
      if map.map_id==id
        return map
      end
    end
    map=Game_Map.new
    map.setup(id)
    return map
  end

  def updateMaps(scene)
    updateMapsInternal()
    if @mapChanged
      $MapFactory.setSceneStarted(scene)
    end
  end

  def updateMapsInternal # :internal:
    return if $game_player.moving?
    if !MapFactoryHelper.hasConnections?($game_map.map_id)
      return if @maps.length==1
      for i in 0...@maps.length
        @maps[i]=nil if $game_map.map_id!=@maps[i].map_id
      end
      @maps.compact!
      @mapIndex=getMapIndex($game_map.map_id)
      return
    end
    setMapsInRange
    deleted=false
    for i in 0...@maps.length
      if !MapFactoryHelper.mapInRange?(@maps[i])
        @maps[i]=nil
        deleted=true 
      end
    end
    if deleted
      @maps.compact!
      @mapIndex=getMapIndex($game_map.map_id)
    end
  end

  def areConnected?(mapID1,mapID2)
    return true if mapID1==mapID2
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if (conn[0]==mapID1 && conn[3]==mapID2) ||
         (conn[0]==mapID2 && conn[3]==mapID1)
        return true
      end
    end
    return false
  end

  def getNewMap(playerX,playerY)
    id=$game_map.map_id
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      next if conn[0]!=id && conn[3]!=id
      mapidB=nil
      newx=0
      newy=0
      if conn[0]==id
        mapidB=conn[3]
        mapB=MapFactoryHelper.getMapDims(conn[3])
        newx=(conn[4]-conn[1]) + playerX
        newy=(conn[5]-conn[2]) + playerY
      else
        mapidB=conn[0]
        mapB=MapFactoryHelper.getMapDims(conn[0])
        newx=(conn[1]-conn[4]) + playerX
        newy=(conn[2]-conn[5]) + playerY
      end
      if (newx>=0 && newx<mapB[0] && newy>=0 && newy<mapB[1])
        return [getMap(mapidB),newx,newy]
      end
    end
    return nil
  end

  def setCurrentMap
    return if $game_player.moving?
    return if $game_map.valid?($game_player.x,$game_player.y)
    newmap=getNewMap($game_player.x,$game_player.y)
    if newmap
      oldmap=$game_map.map_id
      if oldmap!=0 && oldmap!=newmap[0].map_id
        setMapChanging(newmap[0].map_id,newmap[0])
      end
      $game_map=newmap[0]
      @mapIndex=getMapIndex($game_map.map_id)
      $game_player.moveto(newmap[1],newmap[2])
      $game_map.update
      pbAutoplayOnTransition
      $game_map.refresh
      setMapChanged(oldmap)
    end
  end

  def getTerrainTag(mapid,x,y,countBridge=false)
    map=getMapNoAdd(mapid)
    return map.terrain_tag(x,y,countBridge)
  end

  def getFacingTerrainTag(dir=nil,event=nil)
    tile=getFacingTile(dir,event)
    return 0 if !tile
    return getTerrainTag(tile[0],tile[1],tile[2])
  end

  def getRelativePos(thisMapID,thisX,thisY,otherMapID,otherX,otherY)
    if thisMapID==otherMapID
      # Both events share the same map
      return [otherX-thisX,otherY-thisY]
    end
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==thisMapID && conn[1]==otherMapID
        posX=(thisX+conn[4]-conn[1])+otherX
        posY=(thisY+conn[5]-conn[2])+otherY
        return [posX,posY]
      elsif conn[1]==thisMapID && conn[0]==otherMapID
        posX=(thisX+conn[1]-conn[4])+otherX
        posY=(thisY+conn[2]-conn[5])+otherY
        return [posX,posY]
      end
    end
    return [0,0]
  end

# Gets the distance from this event to another event.  Example: If this event's
# coordinates are (2,5) and the other event's coordinates are (5,1), returns
# the array (3,-4), because (5-2=3) and (1-5=-4).
  def getThisAndOtherEventRelativePos(thisEvent,otherEvent)
    return [0,0] if !thisEvent || !otherEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,
       otherEvent.map.map_id,otherEvent.x,otherEvent.y)
  end

  def getThisAndOtherPosRelativePos(thisEvent,otherMapID,otherX,otherY)
    return [0,0] if !thisEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,
       otherMapID,otherX,otherY)  
  end

  def getOffsetEventPos(event,xOffset,yOffset)
    event=$game_player if !event
    return nil if !event
    return getRealTilePos(event.map.map_id,event.x+xOffset,event.y+yOffset)
  end

  def getRealTilePos(mapID,x,y)
    id=mapID
    return [id,x,y] if getMapNoAdd(id).valid?(x,y)
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==id
        newX=(x+conn[4]-conn[1])
        newY=(y+conn[5]-conn[2])
        next if newX<0 || newY<0
        dims=MapFactoryHelper.getMapDims(conn[3])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[3],newX,newY]
      elsif conn[3]==id
        newX=(x+conn[1]-conn[4])
        newY=(y+conn[2]-conn[5])
        next if newX<0 || newY<0
        dims=MapFactoryHelper.getMapDims(conn[0])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[0],newX,newY]
      end
    end
    return nil
  end

  def getFacingTileFromPos(mapID,x,y,direction=0,steps=1)
    id=mapID
    case direction
    when 1; y+=steps; x-=steps
    when 2; y+=steps
    when 3; y+=steps; x+=steps
    when 4; x-=steps
    when 6; x+=steps
    when 7; y-=steps; x-=steps
    when 8; y-=steps
    when 9; y-=steps; x+=steps
    else; return [id,x,y]
    end
    return getRealTilePos(mapID,x,y)
  end

  def getFacingTile(direction=nil,event=nil,steps=1)
    event=$game_player if event==nil
    return [0,0,0] if !event
    x=event.x
    y=event.y
    id=event.map.map_id
    direction=event.direction if direction==nil
    return getFacingTileFromPos(id,x,y,direction,steps)
  end

  def setMapsInRange
    return if @fixup
    @fixup=true
    id=$game_map.map_id
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==id
        mapA=getMap(conn[0])
        newdispx=(conn[4]-conn[1]) * Game_Map.realResX + mapA.display_x
        newdispy=(conn[5]-conn[2]) * Game_Map.realResY + mapA.display_y
        if hasMap?(conn[3]) || MapFactoryHelper.mapInRangeById?(conn[3],newdispx,newdispy)
          mapB=getMap(conn[3])
          mapB.display_x=newdispx if mapB.display_x!=newdispx
          mapB.display_y=newdispy if mapB.display_y!=newdispy
        end
      elsif conn[3]==id
        mapA=getMap(conn[3])
        newdispx=(conn[1]-conn[4]) * Game_Map.realResX + mapA.display_x
        newdispy=(conn[2]-conn[5]) * Game_Map.realResY + mapA.display_y
        if hasMap?(conn[0]) || MapFactoryHelper.mapInRangeById?(conn[0],newdispx,newdispy)
          mapB=getMap(conn[0])
          mapB.display_x=newdispx if mapB.display_x!=newdispx
          mapB.display_y=newdispy if mapB.display_y!=newdispy
        end
      end
    end
    @fixup=false
  end
end
