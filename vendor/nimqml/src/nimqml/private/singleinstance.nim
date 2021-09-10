proc setup*(self: SingleInstance, uniqueName: string, eventStr: string) =
  ## Setup a new SingleInstance
  self.vptr = dos_singleinstance_create(uniqueName, eventStr)

proc delete*(self: SingleInstance) =
  ## Delete the given SingleInstance
  if self.vptr.isNil:
    return
  dos_singleinstance_delete(self.vptr)
  self.vptr.resetToNil

proc newSingleInstance*(uniqueName: string, eventStr: string): SingleInstance =
  new(result, delete)
  result.setup(uniqueName, eventStr)

proc secondInstance*(self: SingleInstance): bool =
  return not dos_singleinstance_isfirst(self.vptr)
