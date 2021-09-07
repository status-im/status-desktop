import json

import ./settings
import ../types/[setting]

proc getRecentGifs*(): JsonNode =
  return settings.getSetting[JsonNode](Setting.Gifs_Recent, %*{})

proc getFavoriteGifs*(): JsonNode =
  return settings.getSetting[JsonNode](Setting.Gifs_Favorite, %*{})

proc setFavoriteGifs*(items: JsonNode) =
  discard settings.saveSetting(Setting.Gifs_Favorite, items)

proc setRecentGifs*(items: JsonNode) =
  discard settings.saveSetting(Setting.Gifs_Recent, items)