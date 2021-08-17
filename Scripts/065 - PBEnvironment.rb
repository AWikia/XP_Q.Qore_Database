begin
  module PBEnvironment
    None        = 0
    Grass       = 1
    TallGrass   = 2
    MovingWater = 3
    StillWater  = 4
    Underwater  = 5
    Cave        = 6
    Rock        = 7
    Sand        = 8
    Forest      = 9
    Snow        = 10
    Volcano     = 11
    Graveyard   = 12
    Sky         = 13
    Space       = 14
    Galaxy      = 15 # FLINT Environment
    Boardwalk   = 16 # FLINT Environment
    Ring        = 17 # FLINT Environment
    Alola       = 18 # Alola Forms
    Galar       = 19 # Galarian Forms
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
