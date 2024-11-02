begin
  class PokeBattle_ActiveSide
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::CraftyShield]       = false
      @effects[PBEffects::EchoedVoiceCounter] = 0
      @effects[PBEffects::EchoedVoiceUsed]    = false
      @effects[PBEffects::LastRoundFainted]   = -1
      @effects[PBEffects::LightScreen]        = 0
      @effects[PBEffects::LuckyChant]         = 0
      @effects[PBEffects::MatBlock]           = false
      @effects[PBEffects::Mist]               = 0
      @effects[PBEffects::QuickGuard]         = false
      @effects[PBEffects::Rainbow]            = 0
      @effects[PBEffects::Reflect]            = 0
      @effects[PBEffects::Round]              = 0
      @effects[PBEffects::Safeguard]          = 0
      @effects[PBEffects::SeaOfFire]          = 0
      @effects[PBEffects::Spikes]             = 0
      @effects[PBEffects::StealthRock]        = false
      @effects[PBEffects::StickyWeb]          = false
      @effects[PBEffects::Swamp]              = 0
      @effects[PBEffects::Tailwind]           = 0
      @effects[PBEffects::ToxicSpikes]        = 0
      @effects[PBEffects::WideGuard]          = false
      @effects[PBEffects::AuroraVeil]         = 0 # changed added
      @effects[PBEffects::CrateBuster]        = 0
      @effects[PBEffects::Electromania]       = 0
      @effects[PBEffects::Fierymania]         = 0
      @effects[PBEffects::ToxicSwamp]         = 0
      @effects[PBEffects::Brainologic]        = 0
      @effects[PBEffects::RevelationPowder]   = 0
      @effects[PBEffects::Trampoline]         = false
    end
  end



  class PokeBattle_ActiveField
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::FairyLock]       = 0
      @effects[PBEffects::FusionBolt]      = false
      @effects[PBEffects::FusionFlare]     = false
      @effects[PBEffects::Gravity]         = 0
      @effects[PBEffects::IonDeluge]       = false
      @effects[PBEffects::MagicStorm]      = false
      @effects[PBEffects::MagicRoom]       = 0
      @effects[PBEffects::MudSportField]   = 0
      @effects[PBEffects::TrickRoom]       = 0
      @effects[PBEffects::WaterSportField] = 0
      @effects[PBEffects::WonderRoom]      = 0
      @effects[PBEffects::NeutralizingGas] = false
      @effects[PBEffects::GlimmyGalaxy]      = 0
      @effects[PBEffects::Torchwood] = false
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end