proc setup(self: StatusSoundManager) =
  discard

proc delete*(self: StatusSoundManager) =
  discard

proc newStatusSoundManager*(): StatusSoundManager =
  new(result, delete)
  result.setup()

proc playSound*(self: StatusSoundManager, soundUrl: string) =
  dos_soundmanager_play_sound(soundUrl)

proc setPlayerVolume*(self: StatusSoundManager, volume: int) =
  dos_soundmanager_set_player_volume(volume)

proc stopPlayer*(self: StatusSoundManager) =
  dos_soundmanager_stop_player()