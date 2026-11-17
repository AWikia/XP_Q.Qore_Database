=begin
DLL = "RichPresenceXP"
ID = "709858080208453685"

class DiscordAPI
  def initialize
    # API references
    @func_discord_initialize = Win32API.new(DLL, "DiscordInit", 'p', 'v')
    @func_discord_shutdown = Win32API.new(DLL, "Shutdown", 'v', 'v')
    @func_discord_update = Win32API.new(DLL, "UpdatePresence", 'ppiippppii', 'v')
    
    # Presence variables
    @state = ""
    @details = ""
    @timestamp_start = 0
    @timestamp_end = 0
    @large_image = ""
    @small_image = ""
    @large_image_text = ""
    @small_image_text = ""
    @party_size = 0
    @party_max = 0
  end
  
  # API calls
  def init(id)
    @func_discord_initialize.call(id)
  end
  
  def shutdown
    @func_discord_shutdown.call
  end
  
  def update
    @func_discord_update.call(@state,@details,@timestamp_start,@timestamp_end,@large_image,@small_image,@large_image_text,@small_image_text,@party_size,@party_max)
  end
  
  # Variable modifier methods
  def state=(val)
    break if val.class != String
    @state = val
  end
  
  def details=(val)
    break if val.class != String
    @details = val
  end
  
  def timestamp_start=(val)
    break if val.class != Int
    @timestamp_start = val
  end
  
  def timestamp_end=(val)
    break if val.class != Int
    @timestamp_end = val
  end
  
  def large_image=(val)
    break if val.class != String
    @large_image = val
  end
  
  def small_image=(val)
    break if val.class != String
    @small_image = val
  end
  
  def large_image_text=(val)
    break if val.class != String
    @large_image_text = val
  end
  
  def small_image_text=(val)
    break if val.class != String
    @small_image_text = val
  end
  
  def party_size=(val)
    break if val.class != Int
    @party_size = val
  end
  
  def party_max=(val)
    break if val.class != Int
    @party_max = val
  end
end

$DiscordRPC = DiscordAPI.new
$DiscordRPC.init(ID)
=end
