type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj

# Since nim doesn't support using concepts in second level nested types we 
# define delegate interfaces within access interface.