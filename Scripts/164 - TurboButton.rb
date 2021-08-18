########################################
# Turbo Speed Script by Pia Carrot      #
# Released March 19th, 2012             #  
#########################################
# Instructions:                         #
# Though it's rather self explanatory,  # 
# this little snippet:                  #
#          if $game_switches[35]        #
# Can be changed to whatever you please,#
# even something other than a switch.   #
#                                       #
# Credits: Maruno, Pia Carrot           #
# Why Maruno? Shiny Pok駑on Reference,  #
# current Pok駑on Essentials Owner      # 
#########################################
#class Game_System
#
#  alias upd_old_speedup update
#  def update
#    if $game_switches[35]
#      Graphics.frame_rate = 56 #90
#    else
#      Graphics.frame_rate = 30 #45
#    end
#    upd_old_speedup
#  end

#end

#class MoveSelectionSprite < SpriteWrapper
  
#  alias upd_old_speedup update
#  def update
#    if $game_switches[35]
#      Graphics.frame_rate = 61 #120
#    else
#      Graphics.frame_rate = 34 #67
#    end
#    upd_old_speedup
#  end

#end

#class PokeBattle_Battler
#  def update 
#  alias upd_old_speedup update 
#
#    if $game_switches[35]
#      Graphics.frame_rate = 60 #120
#    else
#      Graphics.frame_rate = 33 #67
#    end
#    upd_old_speedup
#  end

#end

#class PokeBattle_ActiveSide
#  def update
#  alias upd_old_speedup update  
#
#    if $game_switches[35]
#      Graphics.frame_rate = 120
#    else
#      Graphics.frame_rate = 60
#    end
#    upd_old_speedup
#  end
#
#end
