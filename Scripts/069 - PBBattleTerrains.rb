# These are in-battle terrain effects caused by moves like Electric Terrain.
begin
  module PBBattleTerrains
    ELECTRIC    = 1
    GRASSY      = 2
    MISTY       = 3
    PSYCHIC     = 4
    VOLCANIC    = 5
    LOVELY      = 6
    CINAMENT    = 7 # Its move name lacks "Terrain"
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end