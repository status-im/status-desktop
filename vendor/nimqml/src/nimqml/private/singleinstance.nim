proc setup*(self: SingleInstance, uniqueName: string) =
  ## Setup a new SingleInstance
  self.vptr = dos_singleinstance_create(uniqueName)

proc delete*(self: SingleInstance) =
  ## Delete the given SingleInstance
  if self.vptr.isNil:
    return
  dos_singleinstance_delete(self.vptr)
  self.vptr.resetToNil

proc newSingleInstance*(uniqueName: string): SingleInstance =
  new(result, delete)
  result.setup(uniqueName)

proc secondInstance*(self: SingleInstance): bool =
  return not dos_singleinstance_isfirst(self.vptr)
