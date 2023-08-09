begin
  module PBEffects
    # These effects apply to a battler
    AquaRing           = 0
    Attract            = 1
    BatonPass          = 2
    Bide               = 3
    BideDamage         = 4
    BideTarget         = 5
    Charge             = 6
    ChoiceBand         = 7
    Confusion          = 8
    Counter            = 9
    CounterTarget      = 10
    Curse              = 11
    DefenseCurl        = 12
    DestinyBond        = 13
    Disable            = 14
    DisableMove        = 15
    Electrify          = 16
    Embargo            = 17
    Encore             = 18
    EncoreIndex        = 19
    EncoreMove         = 20
    Endure             = 21
    FirstPledge        = 22
    FlashFire          = 23
    Flinch             = 24
    FocusEnergy        = 25
    FollowMe           = 26
    Foresight          = 27
    FuryCutter         = 28
    FutureSight        = 29
    FutureSightMove    = 30
    FutureSightUser    = 31
    FutureSightUserPos = 32
    GastroAcid         = 33
    Grudge             = 34
    HealBlock          = 35
    HealingWish        = 36
    HelpingHand        = 37
    HyperBeam          = 38
    Illusion           = 39
    Imprison           = 40
    Ingrain            = 41
    KingsShield        = 42
    LeechSeed          = 43
    LifeOrb            = 44
    LockOn             = 45
    LockOnPos          = 46
    LunarDance         = 47
    MagicCoat          = 48
    MagnetRise         = 49
    MeanLook           = 50
    MeFirst            = 51
    Metronome          = 52
    MicleBerry         = 53
    Minimize           = 54
    MiracleEye         = 55
    MirrorCoat         = 56
    MirrorCoatTarget   = 57
    MoveNext           = 58
    MudSport           = 59
    MultiTurn          = 60 # Trapping move
    MultiTurnAttack    = 61
    MultiTurnUser      = 62
    Nightmare          = 63
    Outrage            = 64
    ParentalBond       = 65
    PerishSong         = 66
    PerishSongUser     = 67
    PickupItem         = 68
    PickupUse          = 69
    Pinch              = 70 # Battle Palace only
    Powder             = 71
    PowerTrick         = 72
    Protect            = 73
    ProtectNegation    = 74
    ProtectRate        = 75
    Pursuit            = 76
    Quash              = 77
    Rage               = 78
    Revenge            = 79
    Roar               = 80
    Rollout            = 81
    Roost              = 82
    SkipTurn           = 83 # For when using Poké Balls/Poké Dolls
    SkyDrop            = 84
    SmackDown          = 85
    Snatch             = 86
    SpikyShield        = 87
    Stockpile          = 88
    StockpileDef       = 89
    StockpileSpDef     = 90
    Substitute         = 91
    Taunt              = 92
    Telekinesis        = 93
    Torment            = 94
    Toxic              = 95
    Transform          = 96
    Truant             = 97
    TwoTurnAttack      = 98
    Type3              = 99
    Unburden           = 100
    Uproar             = 101
    Uturn              = 102
    WaterSport         = 103
    WeightChange       = 104
    Wish               = 105
    WishAmount         = 106
    WishMaker          = 107
    Yawn               = 108
    BanefulBunker      = 109 # Changed
    ShellTrap          = 110 # Changed
    LaserFocus         = 111
    TemporaryMoldBreaker = 112
    Disguise           = 113
    LastMoveFailed     = 114
    ThroatChop         = 115
    DoomElist          = 116
    Khleri             = 117
    Splicern           = 118
    TransformProtection = 119
    GulpMissile        =  120
    IceFace            = 121
    Octolock           = 122
    Obstruct           = 123
    UltraBurst         = 124 # Used for Necrozma
    UBForm             = 125 # Used for Necrozma
    TarShot            = 126
    TransformBlock     = 127 # Used for Placten Card
    NoRetreat          = 128
    JawLock            = 129
    MagicDelta         = 130
    LongGrass          = 131
    SilveryBliss       = 132
    Sixtopia           = 133
    SixtopiaP          = 134
    Eternamax          = 135 # Used for Eternatus
    BurningJelousy     = 136
    LashOut            = 137
    DarkTunnel         = 138
    Type1              = 139
    Type2              = 140
    Mimicry            = 141
    NeutralTrap        = 142
    Brainymedia        = 143
    CudChew            = 144
    SilkTrap           = 145
    GlaiveRush         = 146
    GlaiveRushPos      = 147
    Commander          = 148 # Used only on a species with Commander
    CommanderAlly      = 149 # Used only on Dondozo currently
    ShedTail           = 150
    DolphininoForm     = 151 # Used omly on Dolphinino
    
    ############################################################################
    # These effects apply to a side
    CraftyShield       = 0
    EchoedVoiceCounter = 1
    EchoedVoiceUsed    = 2
    LastRoundFainted   = 3
    LightScreen        = 4
    LuckyChant         = 5
    MatBlock           = 6
    Mist               = 7
    QuickGuard         = 8
    Rainbow            = 9
    Reflect            = 10
    Round              = 11
    Safeguard          = 12
    SeaOfFire          = 13
    Spikes             = 14
    StealthRock        = 15
    StickyWeb          = 16
    Swamp              = 17
    Tailwind           = 18
    ToxicSpikes        = 19
    WideGuard          = 20
    AuroraVeil         = 21 # changed added
    CrateBuster        = 22
    Electromania       = 23
    Brainologic        = 24
    Fierymania         = 25
    ToxicSwamp         = 26
    RevelationPowder   = 27
    Trampoline         = 28
    
    ############################################################################
    # These effects apply to the battle (i.e. both sides)
    ElectricTerrain = 0
    FairyLock       = 1
    FusionBolt      = 2
    FusionFlare     = 3
    GrassyTerrain   = 4
    Gravity         = 5
    IonDeluge       = 6
    MagicRoom       = 7
    MistyTerrain    = 8
    MudSportField   = 9
    TrickRoom       = 10
    WaterSportField = 11
    WonderRoom      = 12
    MagicStorm      = 13
    PsychicTerrain  = 14 # Changed
    Cinament        = 15
    VolcanicTerrain = 16
    NeutralizingGas = 17  # Used for Gen8 Neutralizing Gas ability
    LovelyTerrain   = 18
    Torchwood       = 19
    GlimmyGalaxy     = 20
    ############################################################################
    # These effects apply to the usage of a move
    SkipAccuracyCheck = 0
    SpecialUsage      = 1
    PassedTrying      = 2
    TotalDamage       = 3
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end