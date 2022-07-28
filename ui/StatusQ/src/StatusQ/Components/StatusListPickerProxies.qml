import QtQuick 2.14

/*!
  Enables StatusListPicker to work with incompatible models.
   \qml
        StatusListPicker {
            id: currencyPicker
            inputList: ListModel {
                ListElement { incompatibleA: 0 ... incomatibleZ: false }
                ListElement { incompatibleA: 1 ... incomatibleZ: false }
                ListElement { incompatibleA: 2 ... incomatibleZ: false }
            }
            proxy { // StatusListPickerProxies
                key: (model) => model.incompatibleA
                ...
                selected: (model) => model.incompatibleZ
            }
        }
   \endqml
*/
QtObject {
    property var key: (model) => model.key
    property var name: (model) => model.name
    property var shortName: (model) => model.shortName
    property var symbol: (model) => model.symbol
    property var imageSource: (model) => model.imageSource
    property var category: (model) => model.category
    property var selected: (model) => model.selected
    property var setSelected: (model, val) => model.selected = val
}
