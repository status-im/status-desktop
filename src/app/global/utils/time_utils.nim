import times

proc addTimestampToURL*(url: string): string =
  if url.len == 0:
    return ""

  let timestamp = epochTime()

  if '?' in url:
    return url & "&timestamp=" & $timestamp
  else:
    return url & "?timestamp=" & $timestamp
