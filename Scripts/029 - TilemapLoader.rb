class TilemapLoader
  def initialize(viewport)
    @viewport=viewport
    @tilemap=nil
    @color=Color.new(0,0,0,0)
    @tone=Tone.new(0,0,0,0)
    updateClass
  end

  def updateClass
    case $PokemonSystem.tilemap
    when 1
      setClass(CustomTilemap)
    when 2
      setClass(Draw_Tilemap)
    else
      if Tilemap.method_defined?(:passages)
        setClass(CustomTilemap)
      else
        setClass($ResizeFactor==1.0 ? SynchronizedTilemap : CustomTilemap)
      end
    end
  end

  def setClass(cls)
    newtilemap=cls.new(@viewport)
    if @tilemap
      newtilemap.tileset=@tilemap.tileset
      newtilemap.map_data=@tilemap.map_data
      newtilemap.flash_data=@tilemap.flash_data
      newtilemap.priorities=@tilemap.priorities
      newtilemap.visible=@tilemap.visible
      newtilemap.ox=@tilemap.ox
      newtilemap.oy=@tilemap.oy
      for i in 0...7
        newtilemap.autotiles[i]=@tilemap.autotiles[i]
      end
      @tilemap.dispose
      @tilemap=newtilemap
      newtilemap.update if cls!=SynchronizedTilemap
    else
      @tilemap=newtilemap
    end
  end

  def tone
    @tilemap.tone rescue @tone
  end

  def tone=(value)
    @tilemap.tone=value rescue nil
  end

  def disposed?
    @tilemap && @tilemap.disposed?
  end

  def dispose
    @tilemap.dispose
  end

  def update
    @tilemap.update
  end

  def viewport
    @tilemap.viewport
  end

  def autotiles
    @tilemap.autotiles
  end

  def tileset
    @tilemap.tileset
  end

  def tileset=(v)
    @tilemap.tileset=v
  end

  def map_data
    @tilemap.map_data
  end

  def map_data=(v)
    @tilemap.map_data=v
  end

  def flash_data
    @tilemap.flash_data
  end

  def flash_data=(v)
    @tilemap.flash_data=v
  end

  def priorities
    @tilemap.priorities
  end

  def priorities=(v)
    @tilemap.priorities=v
  end

  def visible
    @tilemap.visible
  end

  def visible=(v)
    @tilemap.visible=v
  end

  def ox
    @tilemap.ox
  end

  def ox=(v)
    @tilemap.ox=v
  end

  def oy
    @tilemap.oy
  end

  def oy=(v)
    @tilemap.oy=v
  end
end
