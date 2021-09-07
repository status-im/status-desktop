type
  QSettingsFormat* {.pure.} = enum
    NativeFormat = 0
    IniFormat

proc setup(self: QSettings, fileName: string, format: int) =
  self.vptr = dos_qsettings_create(fileName, format)

proc delete*(self: QSettings) =
  dos_qsettings_delete(self.vptr)
  self.vptr.resetToNil  

proc newQSettings*(fileName: string, 
  format: QSettingsFormat = QSettingsFormat.NativeFormat): QSettings =
  ## Available values for format are:
  ## 0 - QSettings::NativeFormat
  ## 1 - QSettings::IniFormat
  ## any other value will be converted to 0 (QSettings::NativeFormat)
  new(result, delete)
  result.setup(fileName, format.int)

proc value*(self: QSettings, key: string, defaultValue: QVariant = newQVariant()): 
  QVariant =
  newQVariant(dos_qsettings_value(self.vptr, key, defaultValue.vptr), Ownership.Take)

proc setValue*(self: QSettings, key: string, value: QVariant) =
  dos_qsettings_set_value(self.vptr, key, value.vptr)

proc remove*(self: QSettings, key: string) =
  dos_qsettings_remove(self.vptr, key)