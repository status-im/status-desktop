## tips and tricks

### seeing output of macros

```nimrod=
import macros

expandmacros:
  #code
```

then during compilation it will display what the expanded code looks like

### Getting notified for QML properties changing

Each QML property has an `onChange` attached to it automatically.

For example, if you a property named `name`, it will have an `onNameChanged`. It follows the pattern: `on` + Property + `Change`.

Eg:
```
property int index: 0

onIndexChanged: {
    console.log('Index changed', index)
}
```

## Async
```nimrod
import chronos

proc someFunction*(someParameter:int): Future[string] {.async.}=
  result = "Something"
  

var myResult = waitFor someFunction(1)

# If inside some async function
var myResult = await someFunction(6464435)

# to discard the result,
asyncCheck someFunction(2332)

```

`nim-chronos` API is compatible with https://nim-lang.org/docs/asyncdispatch.html so this page can be used to complement nim-chronos lack of documentation. ([Wiki](https://github.com/status-im/nim-chronos/wiki/AsyncDispatch-comparison))

## Updating data on a QAbstractListModel
While adding/removing values from a list is easy, updating the values of a list requires some extra manipulation:
```
proc updateRecord(idx: int, newValue: string) =
    self.myList[idx] = newValue;
    var topLeft = self.createIndex(idx,0,nil)
    var bottomRight = self.createIndex(idx,0,nil)
    self.dataChanged(topLeft, bottomRight, @[RoleNames.SomeRole.int, RoleNames.AnotherRole.int, RoleNames.SomeOtherRole.int])
```

If more than one record is being updated at once, change the `topLeft`'s and `bottomRight`'s `self.createIndex` first parameter to indicate the initial row number and the final row number that were affected. 

To refresh the whole table, I think you can use `0` as the first parameter for `createIndex` for both `topLeft` and `bottomRight`. 

The final attribute of `dataChanged` is a non-empty sequence of RoleNames containing the attributes that were updated

## Error Handling and Custom Errors

### Raising Custom errors

```nim
type
  CustomError* = object of Exception # CatchableError/Defect

try:
  raise newException(CustomError, "Some error message")
except CustomError as e:
  echo e.msg
```

### Raising Custom Errors with custom data (and parent Error)

```nim
type
  CustomError* = object of Exception
     customField*: string

type CustomErrorRef = ref CustomError

try:
  raise CustomErrorRef(msg: "Some error message", customField: "Some custom error data", parent: (ref ValueError)(msg: "foo bar"))
except CustomError as e:
  echo e.msg & ": " & e.customField
  echo "Original: " & e.parent.msg
```

### Implementing custom Error helpers with default values

```nim
type
  CustomError* = object of Exception
    customField*: string

type CustomErrorRef = ref CustomError

proc newCustomError*(customData: string): CustomErrorRef =
  result = CustomErrorRef(msg: "This is some custom error message", customField: customData, parent: (ref ValueError)(msg: "Value error"))
```