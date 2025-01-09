import std/macros

# Macro that simplifies checking and updating values in a model
# IMPORTANT:
# The model's items need to be in a `seq` called `items`
# A `seq[string]` named `roles` needs to exist
# The index of the item being checked must be named `ind`
macro updateRole*(propertyName: untyped, roleName: untyped): untyped =
  quote:
    if self.items[ind].`propertyName` != `propertyName`:
      self.items[ind].`propertyName` = `propertyName`
      roles.add(ModelRole.`roleName`.int)

# Same thing as updateRole where you have a value to set that is not the same **exact** name as the propertyName
# Eg: updateRoleWithValue(name, Name, item.name)
macro updateRoleWithValue*(
    propertyName: untyped, roleName: untyped, value: untyped
): untyped =
  quote:
    if self.items[ind].`propertyName` != `value`:
      self.items[ind].`propertyName` = `value`
      roles.add(ModelRole.`roleName`.int)
