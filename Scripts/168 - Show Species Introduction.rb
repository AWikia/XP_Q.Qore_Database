#===============================================================================
# * Show Species Introdution - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It shows a picture with the pokémon
# species in a border, show a message with the name and kind, play it cry and
# mark it as seen in pokédex. Good to make the starter selection event.
#
#===============================================================================
#
# To this script works, put it above main.
#
# To call it, use showSpeciesIntro(specie,complement) where the specie is
# the species number and complement is an optional string complement (like
# "f" or "_3") to show other sprites like the female one or the other 
# forms ones.
# Ex: 'showSpeciesIntro(4)' shows Charmander, 
# 'showSpeciesIntro(PBSpecies::CHIKORITA)' shows Chikorita and 
# 'showSpeciesIntro(422,"_1")' shows Shellos in East Sea form.
#
#===============================================================================

  def showSpeciesIntro(specie,complement="")
    name=PBSpecies.getName(specie)
    kind=pbGetMessage(MessageTypes::Kinds,specie)
    # Comment the below line so it won't show the species on pokédex as seen.
#  if $game_switches[38] # So used everywhere apart from PiXie Cave
    $Trainer.seen[specie]=true
#   end
    battlername=sprintf("Graphics/Battlers/%03d%s",specie,complement)
    bitmap=pbResolveBitmap(battlername)
    pbPlayCry(specie)
    if bitmap # to prevent crashes
      iconwindow=PictureWindow.new(bitmap)
      iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
      iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
      Kernel.pbMessage(_INTL("{1}. {2} Pokémon.",name,kind))
      iconwindow.dispose
    end
  end
