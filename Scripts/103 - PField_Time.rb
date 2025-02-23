#===============================================================================
# Day and night system
#===============================================================================
def pbGetTimeNow
  return Time.now
end



module PBDayNight
=begin
# Old Tones
  HourlyTones=[ # Lunar
     Tone.new(-142.5,-142.5,-72.5,78),     # Midnight
     Tone.new(-135.5,-135.5,-74,  78),
     Tone.new(-127.5,-127.5,-75.5,78),
     Tone.new(-127.5,-127.5,-75.5,78),
     Tone.new(-119,  -96.3, -95.3,55.3),
     Tone.new(-51,   -73.7, -123.7,32.7),
     Tone.new(17,    -51,   -152, 10),      # 6AM
     Tone.new(14.2,  -42.5, -135,  10),
     Tone.new(11.3,  -34,   -118,  10),
     Tone.new(8.5,   -25.5, -101,  10),
     Tone.new(5.7,   -17,   -84,  10),
     Tone.new(2.8,   -8.5,  -67,  10),
     Tone.new(0,     0,     -50,    10),      # Noon
     Tone.new(0,     0,     -50,    10),
     Tone.new(0,     0,     -50,    10),
     Tone.new(0,     0,     -50,    10),
     Tone.new(-3,    -7,    -52,   10),
     Tone.new(-10,   -18,   -55,   10),
     Tone.new(-36,   -75,   -63,  10),      # 6PM
     Tone.new(-72,   -136,  -84,  13),
     Tone.new(-88.5, -133,  -81,  44),
     Tone.new(-108.5,-129,  -78,  78),
     Tone.new(-127.5,-127.5,-75.5,78),
     Tone.new(-142.5,-142.5,-72.5,78)
  ]
HourlyTones2=[ # Linear
     Tone.new(-132.5,-162.5,8.5,88),     # Midnight
     Tone.new(-125.5,-155.5,6,  88),
     Tone.new(-117.5,-147.5,5.5,88),
     Tone.new(-117.5,-147.5,5.5,88),
     Tone.new(-109,  -116.3, -15.3,65.3),
     Tone.new(-41,   -93.7, -43.7,42.7),
     Tone.new(27,    -71,   -72, 20),      # 6AM
     Tone.new(24.2,  -62.5, -55,  20),
     Tone.new(21.3,  -54,   -38,  20),
     Tone.new(18.5,   -45.5, -21,  20),
     Tone.new(15.7,   -37,   -4,  20),
     Tone.new(12.8,   -28.5,  13,  20),
     Tone.new(10,     -20,     30,    20),      # Noon
     Tone.new(10,     -20,     30,    20),
     Tone.new(10,     -20,     30,    20),
     Tone.new(10,     -20,     30,    20),
     Tone.new(7,    -27,    28,   20),
     Tone.new(0,   -38,   25,   20),
     Tone.new(-26,   -95,   17,  20),      # 6PM
     Tone.new(-62,   -156,  -4,  23),
     Tone.new(-78.5, -153,  -1,  54),
     Tone.new(-98.5,-149,  3,  88),
     Tone.new(-117.5,-147.5,5.5,88),
     Tone.new(-132.5,-162.5,8.5,88)
  ]
  HourlyTones3=[ # Classic
     Tone.new(-142.5,-142.5,-22.5,68),     # Midnight
     Tone.new(-135.5,-135.5,-24,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-119,  -96.3, -45.3,45.3),
     Tone.new(-51,   -73.7, -73.7,22.7),
     Tone.new(17,    -51,   -102, 0),      # 6AM
     Tone.new(14.2,  -42.5, -85,  0),
     Tone.new(11.3,  -34,   -68,  0),
     Tone.new(8.5,   -25.5, -51,  0),
     Tone.new(5.7,   -17,   -34,  0),
     Tone.new(2.8,   -8.5,  -17,  0),
     Tone.new(0,     0,     0,    0),      # Noon
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(-3,    -7,    -2,   0),
     Tone.new(-10,   -18,   -5,   0),
     Tone.new(-36,   -75,   -13,  0),      # 6PM
     Tone.new(-72,   -136,  -34,  3),
     Tone.new(-88.5, -133,  -31,  34),
     Tone.new(-108.5,-129,  -28,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-142.5,-142.5,-22.5,68)
  ]
  HourlyTones4=[ # Cubic
     Tone.new(-142.5,-162.5,-72.5,78),     # Midnight
     Tone.new(-135.5,-155.5,-74,  78),
     Tone.new(-127.5,-147.5,-75.5,78),
     Tone.new(-127.5,-147.5,-75.5,78),
     Tone.new(-119,  -116.3, -95.3,55.3),
     Tone.new(-51,   -93.7, -123.7,32.7),
     Tone.new(17,    -71,   -152, 10),      # 6AM
     Tone.new(14.2,  -62.5, -135,  10),
     Tone.new(11.3,  -54,   -118,  10),
     Tone.new(8.5,   -45.5, -101,  10),
     Tone.new(5.7,   -17,   -84,  10),
     Tone.new(2.8,   -28.5,  -67,  10),
     Tone.new(0,     -20,     -50,    10),      # Noon
     Tone.new(0,     -20,     -50,    10),
     Tone.new(0,     -20,     -50,    10),
     Tone.new(0,     -20,     -50,    10),
     Tone.new(-3,    -27,    -52,   10),
     Tone.new(-10,   -38,   -55,   10),
     Tone.new(-36,   -95,   -63,  10),      # 6PM
     Tone.new(-72,   -156,  -84,  13),
     Tone.new(-88.5, -153,  -81,  44),
     Tone.new(-108.5,-149,  -78,  78),
     Tone.new(-127.5,-147.5,-75.5,78),
     Tone.new(-142.5,-162.5,-72.5,68)
  ]
=end
  HourlyTones=[ # Lunar (0  0  -50 10)
    Tone.new(-70, -90, -45, 65),   # Night           # Midnight
    Tone.new(-70, -90, -45, 65),   # Night
    Tone.new(-70, -90, -45, 65),   # Night
    Tone.new(-70, -90, -45, 65),   # Night
    Tone.new(-60, -70, -55, 60),   # Night
    Tone.new(-40, -50, -85, 60),   # Day/morning
    Tone.new(-40, -50, -85, 60),   # Day/morning     # 6AM
    Tone.new(-40, -50, -85, 60),   # Day/morning
    Tone.new(-40, -50, -85, 60),   # Day/morning
    Tone.new(-20, -25, -65, 30),   # Day/morning
    Tone.new(  0,   0, -50, 10),   # Day
    Tone.new(  0,   0, -50, 10),   # Day
    Tone.new(  0,   0, -50, 10),   # Day             # Noon
    Tone.new(  0,   0, -50, 10),   # Day
    Tone.new(  0,   0, -50, 10),   # Day/afternoon
    Tone.new(  0,   0, -50, 10),   # Day/afternoon
    Tone.new(  0,   0, -50, 10),   # Day/afternoon
    Tone.new(  0,   0, -50, 10),   # Day/afternoon
    Tone.new( -5, -30, -70, 10),   # Day/evening     # 6PM 
    Tone.new(-15, -60, -60, 30),   # Day/evening
    Tone.new(-15, -60, -60, 30),   # Day/evening
    Tone.new(-40, -75, -45, 50),   # Night
    Tone.new(-70, -90, -35, 65),   # Night
    Tone.new(-70, -90, -35, 65)    # Night
  ]
  HourlyTones2=[ # Linear (10 -20 30 20)
    Tone.new(-60,-110,  45, 75),   # Night           # Midnight
    Tone.new(-60,-110,  45, 75),   # Night
    Tone.new(-60,-110,  45, 75),   # Night
    Tone.new(-60,-110,  45, 75),   # Night
    Tone.new(-50, -90,  25, 70),   # Night
    Tone.new(-30, -70,  -5, 70),   # Day/morning
    Tone.new(-30, -70,  -5, 70),   # Day/morning     # 6AM
    Tone.new(-30, -70,  -5, 70),   # Day/morning
    Tone.new(-30, -70,  -5, 70),   # Day/morning
    Tone.new(-10, -45,  15, 40),   # Day/morning
    Tone.new( 10, -20,  30, 20),   # Day
    Tone.new( 10, -20,  30, 20),   # Day
    Tone.new( 10, -20,  30, 20),   # Day             # Noon
    Tone.new( 10, -20,  30, 20),   # Day
    Tone.new( 10, -20,  30, 20),   # Day/afternoon
    Tone.new( 10, -20,  30, 20),   # Day/afternoon
    Tone.new( 10, -20,  30, 20),   # Day/afternoon
    Tone.new( 10, -20,  30, 20),   # Day/afternoon
    Tone.new(  5, -50,  10, 20),   # Day/evening     # 6PM 
    Tone.new( -5, -80,  20, 40),   # Day/evening
    Tone.new( -5, -80,  20, 40),   # Day/evening
    Tone.new(-30, -95,  35, 60),   # Night
    Tone.new(-60,-110,  45, 75),   # Night
    Tone.new(-60,-110,  45, 75)    # Night
  ]
  HourlyTones3=[ # Classic
    Tone.new(-70, -90,  15, 55),   # Night           # Midnight
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-60, -70,  -5, 50),   # Night
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-40, -50, -35, 50),   # Day/morning     # 6AM
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-20, -25, -15, 20),   # Day/morning
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day             # Noon
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new( -5, -30, -20,  0),   # Day/evening     # 6PM 
    Tone.new(-15, -60, -10, 20),   # Day/evening
    Tone.new(-15, -60, -10, 20),   # Day/evening
    Tone.new(-40, -75,   5, 40),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55)    # Night
  ]
  HourlyTones4=[ # Cubic (5 -10 -10 15) - (0 -20 -50 10)
    Tone.new(-65,-100,   5, 70),   # Night           # Midnight
    Tone.new(-65,-100,   5, 70),   # Night
    Tone.new(-65,-100,   5, 70),   # Night
    Tone.new(-65,-100,   5, 70),   # Night
    Tone.new(-55, -80, -15, 65),   # Night
    Tone.new(-35, -60, -45, 65),   # Day/morning
    Tone.new(-35, -60, -45, 65),   # Day/morning     # 6AM
    Tone.new(-35, -60, -45, 65),   # Day/morning
    Tone.new(-35, -60, -45, 65),   # Day/morning
    Tone.new(-15, -35, -25, 35),   # Day/morning
    Tone.new(  5, -10, -10, 15),   # Day
    Tone.new(  5, -10, -10, 15),   # Day
    Tone.new(  5, -10, -10, 15),   # Day             # Noon
    Tone.new(  5, -10, -10, 15),   # Day
    Tone.new(  5, -10, -10, 15),   # Day/afternoon
    Tone.new(  5, -10, -10, 15),   # Day/afternoon
    Tone.new(  5, -10, -10, 15),   # Day/afternoon
    Tone.new(  5, -10, -10, 15),   # Day/afternoon
    Tone.new(  0, -40, -30, 15),   # Day/evening     # 6PM 
    Tone.new(-10, -70, -20, 35),   # Day/evening
    Tone.new(-10, -70, -20, 35),   # Day/evening
    Tone.new(-35, -85,  -5, 55),   # Night
    Tone.new(-65,-100,   5, 70),   # Night
    Tone.new(-65,-100,   5, 70)    # Night
  ]
  HourlyTonesIE=[ # Classic
     Tone.new(-142.5,-142.5,-22.5,68),     # Midnight
     Tone.new(-135.5,-135.5,-24,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-119,  -96.3, -45.3,45.3),
     Tone.new(-51,   -73.7, -73.7,22.7),
     Tone.new(17,    -51,   -102, 0),      # 6AM
     Tone.new(14.2,  -42.5, -85,  0),
     Tone.new(11.3,  -34,   -68,  0),
     Tone.new(8.5,   -25.5, -51,  0),
     Tone.new(5.7,   -17,   -34,  0),
     Tone.new(2.8,   -8.5,  -17,  0),
     Tone.new(0,     0,     0,    0),      # Noon
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(-3,    -7,    -2,   0),
     Tone.new(-10,   -18,   -5,   0),
     Tone.new(-36,   -75,   -13,  0),      # 6PM
     Tone.new(-72,   -136,  -34,  3),
     Tone.new(-88.5, -133,  -31,  34),
     Tone.new(-108.5,-129,  -28,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-142.5,-142.5,-22.5,68)
  ]
  @cachedTone=nil
  @dayNightToneLastUpdate=nil
  @oneOverSixty=1/60.0

# Returns true if it's day.
  def self.isDay?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[5,4,6,7][pbGetSeason] && time.hour<[20,21,20,19][pbGetSeason])
  end

# Returns true if it's night.
  def self.isNight?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[20,21,20,19][pbGetSeason] || time.hour<[5,4,6,7][pbGetSeason])
  end

# Returns true if it's morning.
  def self.isMorning?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[5,4,6,7][pbGetSeason] && time.hour<[10,9,10,11][pbGetSeason])
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[14,15,14,13][pbGetSeason] && time.hour<[17,19,18,17][pbGetSeason])
  end

# Returns true if it's the evening.
  def self.isEvening?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[17,19,18,17][pbGetSeason] && time.hour<[20,21,20,19][pbGetSeason])
  end

# Returns true if it's the proper time for Rainbow Alcremie.
  def self.isRainbow?(time=nil)
    time=pbGetTimeNow if !time
    return (time.hour>=[19,20,19,18][pbGetSeason] && time.hour<[20,21,20,19][pbGetSeason])
  end
  
# Returns true if it's the proper time for Dark Mode when System Theme is set to Cusotm.
  def self.isDark?(time=nil)
    time=pbGetTimeNow if !time
    if ($PokemonSystem.darkmodestart==$PokemonSystem.darkmodeend rescue false)
      return true
    elsif ($PokemonSystem.darkmodestart>$PokemonSystem.darkmodeend rescue false)
      return (time.hour>=($PokemonSystem.darkmodestart rescue 0) || time.hour<($PokemonSystem.darkmodeend rescue 0)) # Was 20 and 6
    else
      return (time.hour>=($PokemonSystem.darkmodestart rescue 0) && time.hour<($PokemonSystem.darkmodeend rescue 0)) # Was 20 and 6
    end
  end



# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time=pbGetDayNightMinutes
    time=(24*60)-time if time>(12*60)
    shade=255*time/(12*60)
  end

# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone()
    @cachedTone=Tone.new(0,0,0) if !@cachedTone
    return @cachedTone if ($PokemonSystem.enableshading==0 rescue false)
    if !@dayNightToneLastUpdate || @dayNightToneLastUpdate!=Graphics.frame_count       
      getToneInternal()
      @dayNightToneLastUpdate=Graphics.frame_count
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now=pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal()
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes=pbGetDayNightMinutes
    hour=realMinutes/60
    minute=realMinutes%60
    if ($PokemonSystem.night==3 rescue false)
      tone=PBDayNight::HourlyTones4[hour] # Cubic
      nexthourtone=PBDayNight::HourlyTones4[(hour+1)%24]
    elsif ($PokemonSystem.night==2 rescue false)
      tone=PBDayNight::HourlyTones[hour] # Lunar
      nexthourtone=PBDayNight::HourlyTones[(hour+1)%24]
    elsif ($PokemonSystem.night==1 rescue false)
        tone=PBDayNight::HourlyTones2[hour] # Linear
        nexthourtone=PBDayNight::HourlyTones2[(hour+1)%24]
    else
        tone=PBDayNight::HourlyTones3[hour] # Classic
        nexthourtone=PBDayNight::HourlyTones3[(hour+1)%24]
    end
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    @cachedTone.red=((nexthourtone.red-tone.red)*minute*@oneOverSixty)+tone.red
    @cachedTone.green=((nexthourtone.green-tone.green)*minute*@oneOverSixty)+tone.green
    @cachedTone.blue=((nexthourtone.blue-tone.blue)*minute*@oneOverSixty)+tone.blue
    @cachedTone.gray=((nexthourtone.gray-tone.gray)*minute*@oneOverSixty)+tone.gray
  end
end



def pbDayNightTint(object)
  if !$scene.is_a?(Scene_Map)
    return
  else
    r = 0
    g = 0
    b = 0
    w = 0
    if ($PokemonGlobal.inFuture rescue false) # Future Maps
      r = 34
      g = 34
      b = 68
      w = 42
    end
    if ($PokemonGlobal.inPast rescue false) #  Past Maps
      r = -34
      g = -34
      b = -68
      w = 170
    end
    if $game_map && pbGetMetadata($game_map.map_id,MetadataPseudoDarkMap) # Pseudo-dark Maps
      r+= -110
      g+= -114
      b+= -118
      w+= 60
    end
    if ($PokemonSystem.enableshading==1 rescue false) && $game_map && pbGetMetadata($game_map.map_id,MetadataOutdoor)
      tone=PBDayNight.getTone()
      object.tone.set(tone.red+r,tone.green+g,tone.blue+b,tone.gray+w)
    else
      object.tone.set(r,g,b,w)  
    end
  end  
end




#===============================================================================
# Moon phases and Zodiac
#===============================================================================
# Calculates the phase of the moon.
# 0 - New Moon
# 1 - Waxing Crescent
# 2 - First Quarter
# 3 - Waxing Gibbous
# 4 - Full Moon
# 5 - Waning Gibbous
# 6 - Last Quarter
# 7 - Waning Crescent
def moonphase(time=nil) # in UTC
  time=pbGetTimeNow if !time
  transitions=[
     1.8456618033125,
     5.5369854099375,
     9.2283090165625,
     12.9196326231875,
     16.6109562298125,
     20.3022798364375,
     23.9936034430625,
     27.6849270496875]
  yy=time.year-((12-time.mon)/10.0).floor
  j=(365.25*(4712+yy)).floor + (((time.mon+9)%12)*30.6+0.5).floor + time.day+59
  j-=(((yy/100.0)+49).floor*0.75).floor-38 if j>2299160
  j+=(((time.hour*60)+time.min*60)+time.sec)/86400.0
  v=(j-2451550.1)/29.530588853
  v=((v-v.floor)+(v<0 ? 1 : 0))
  ag=v*29.53
  for i in 0...transitions.length
    return i if ag<=transitions[i]
  end
  return 0
end

# Calculates the zodiac sign based on the given month and day:
# 0 is Aries, 11 is Pisces. Month is 1 if January, and so on.
def zodiac(month,day)
  time=[
     3,21,4,19,   # Aries
     4,20,5,20,   # Taurus
     5,21,6,20,   # Gemini
     6,21,7,20,   # Cancer
     7,23,8,22,   # Leo
     8,23,9,22,   # Virgo 
     9,23,10,22,  # Libra
     10,23,11,21, # Scorpio
     11,22,12,21, # Sagittarius
     12,22,1,19,  # Capricorn
     1,20,2,18,   # Aquarius
     2,19,3,20    # Pisces
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+2]
  end
  return 0
end
 
# Returns the opposite of the given zodiac sign.
# 0 is Aries, 11 is Pisces.
def zodiacOpposite(sign)
  return (sign+6)%12
end

# 0 is Aries, 11 is Pisces.
def zodiacPartners(sign)
  return [(sign+4)%12,(sign+8)%12]
end

# 0 is Aries, 11 is Pisces.
def zodiacComplements(sign)
  return [(sign+1)%12,(sign+11)%12]
end

#===============================================================================
# Days of the week
#===============================================================================
def pbIsWeekday(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.wday
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")][wday] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

#===============================================================================
# Months
#===============================================================================
def pbIsMonth(monVariable,*arg)
  timenow=pbGetTimeNow
  thismon=timenow.mon
  ret=false
  for wd in arg
    ret=true if wd==thismon
  end
  if monVariable>0
    $game_variables[monVariable]=[ 
       _INTL("January"),
       _INTL("February"),
       _INTL("March"),
       _INTL("April"),
       _INTL("May"),
       _INTL("June"),
       _INTL("July"),
       _INTL("August"),
       _INTL("September"),
       _INTL("October"),
       _INTL("November"),
       _INTL("December")][thismon-1] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbGetAbbrevMonthName(month)
  return ["",
          _INTL("Jan."),
          _INTL("Feb."),
          _INTL("Mar."),
          _INTL("Apr."),
          _INTL("May"),
          _INTL("Jun."),
          _INTL("Jul."),
          _INTL("Aug."),
          _INTL("Sep."),
          _INTL("Oct."),
          _INTL("Nov."),
          _INTL("Dec.")][month]
end

#===============================================================================
# Seasons
#===============================================================================
def pbGetSeason
  if (pbIsSouthernHemisphere() rescue false) # If the user is in the Southern Herisphere
    return [2,3,0,1][(pbGetTimeNow.mon-1)%4]
  end
  return (pbGetTimeNow.mon-1)%4
end

def pbIsSeason(seasonVariable,*arg)
  thisseason=pbGetSeason
  ret=false
  for wd in arg
    ret=true if wd==thisseason
  end
  if seasonVariable>0
    $game_variables[seasonVariable]=[ 
       _INTL("Spring"),
       _INTL("Summer"),
       _INTL("Autumn"),
       _INTL("Winter")][thisseason] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsSpring; return pbIsSeason(0,0); end # Jan, May, Sep / Mar, Jul, Nov
def pbIsSummer; return pbIsSeason(0,1); end # Feb, Jun, Oct / Apr, Aug, Dec
def pbIsAutumn; return pbIsSeason(0,2); end # Mar, Jul, Nov / Jan, May, Sep
def pbIsFall; return pbIsAutumn; end
def pbIsWinter; return pbIsSeason(0,3); end # Apr, Aug, Dec / Feb, Jun, Oct

def pbGetSeasonName(season)
  return [_INTL("Spring"),
          _INTL("Summer"),
          _INTL("Autumn"),
          _INTL("Winter")][season]
  end
