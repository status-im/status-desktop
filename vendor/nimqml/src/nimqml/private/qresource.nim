proc registerResource*(c: type QResource, filename: string) =
  dos_qresource_register(filename.cstring)
