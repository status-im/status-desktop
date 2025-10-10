import stew/shims/strformat


type AddressPerChain* = ref object of RootObj
    chainId*: int
    address*: string

proc `$`*(self: AddressPerChain): string =
  result = fmt"""AddressPerChain[
    chainId: {self.chainId},
    address: {self.address}
    ]"""