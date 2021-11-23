def migrate # Q-Qore => IE
  drive=ENV["HOMEDRIVE"]
  if !drive
    drive="C:\\"
  end
  home=["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  migrated=""+drive+ENV[home]+"\\Saved Games\\Time Capsule"
  if !safeExists?(migrated)
    Dir.mkdir(migrated)
  end
  migrated+="\\migratedQQ.txt"
  p=pbGetPokemon(235)
  if safeExists?(migrated)
    master=IO.read(migrated)
    master=pbMysteryGiftDecrypt(master)
    master.push(p)
  else
    master=[p]
  end
  string=pbMysteryGiftEncrypt(master)
  File.open(_INTL(migrated),"wb"){|f|
     f.write(string)
  }
  Kernel.pbReceiveTrophy(:TMIGRATOR)
  if ($DEBUG || $TEST)
    pbRemovePokemonAt(pbGet(235))
  else
    pbRemovePokemonAt(pbGet(235))
  end
end


def migrate2 # IE => Q-Qore
  drive=ENV["HOMEDRIVE"]
  if !drive
    drive="C:\\"
  end
  home=["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  migrated=""+drive+ENV[home]+"\\Saved Games\\Time Capsule"
  if !safeExists?(migrated)
    Dir.mkdir(migrated)
  end
  migrated+="\\migratedQV.txt"
  p=pbGetPokemon(235)
  if safeExists?(migrated)
    master=IO.read(migrated)
    master=pbMysteryGiftDecrypt(master)
    master.push(p)
  else
    master=[p]
  end
  string=pbMysteryGiftEncrypt(master)
  File.open(_INTL(migrated),"wb"){|f|
     f.write(string)
  }
  Kernel.pbReceiveTrophy(:TMIGRATOR)
  if ($DEBUG || $TEST)
    pbRemovePokemonAt(pbGet(235))
    else
    pbRemovePokemonAt(pbGet(235))
  end
end
