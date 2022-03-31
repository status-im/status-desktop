import strformat
import ./model

type
  GeneratedWalletItem* = object
    name: string
    iconName: string
    generatedModel: Model
    derivedfrom: string

proc initGeneratedWalletItem*(
  name: string,
  iconName: string,
  generatedModel: Model,
  derivedfrom: string
): GeneratedWalletItem =
  result.name = name
  result.iconName = iconName
  result.generatedModel = generatedModel
  result.derivedfrom = derivedfrom

proc `$`*(self: GeneratedWalletItem): string =
  result = fmt"""GeneratedWalletItem(
    name: {self.name},
    iconName: {self.iconName},
    generatedModel: {self.generatedModel},
    derivedfrom: {self.derivedfrom}
    ]"""

proc getName*(self: GeneratedWalletItem): string =
  return self.name

proc getIconName*(self: GeneratedWalletItem): string =
  return self.iconName

proc getGeneratedModel*(self: GeneratedWalletItem): Model =
  return self.generatedModel

proc getDerivedfrom*(self: GeneratedWalletItem): string =
  return self.derivedfrom
