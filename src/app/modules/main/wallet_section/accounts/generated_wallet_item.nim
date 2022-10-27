import strformat
import ./model

type
  GeneratedWalletItem* = object
    name: string
    iconName: string
    generatedModel: Model
    derivedfrom: string
    keyUid: string
    migratedToKeycard: bool

proc initGeneratedWalletItem*(
  name: string,
  iconName: string,
  generatedModel: Model,
  derivedfrom: string,
  keyUid: string,
  migratedToKeycard: bool
): GeneratedWalletItem =
  result.name = name
  result.iconName = iconName
  result.generatedModel = generatedModel
  result.derivedfrom = derivedfrom
  result.keyUid = keyUid
  result.migratedToKeycard = migratedToKeycard

proc `$`*(self: GeneratedWalletItem): string =
  result = fmt"""GeneratedWalletItem(
    name: {self.name},
    iconName: {self.iconName},
    generatedModel: {self.generatedModel},
    derivedfrom: {self.derivedfrom},
    keyUid: {self.keyUid},
    migratedToKeycard: {self.migratedToKeycard}
    ]"""

proc getName*(self: GeneratedWalletItem): string =
  return self.name

proc getIconName*(self: GeneratedWalletItem): string =
  return self.iconName

proc getGeneratedModel*(self: GeneratedWalletItem): Model =
  return self.generatedModel

proc getDerivedfrom*(self: GeneratedWalletItem): string =
  return self.derivedfrom

proc getKeyUid*(self: GeneratedWalletItem): string =
  return self.keyUid

proc getMigratedToKeycard*(self: GeneratedWalletItem): bool =
  return self.migratedToKeycard
