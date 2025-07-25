import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core

import "../demoapp/data"

GridLayout {
    id: root
    columns: 1
    rowSpacing: 150

    GridLayout {
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        rows: 4
        columns: 2
        rowSpacing: 170
        columnSpacing: 150
        z: 100
        StatusListPicker {
            id: languagePicker
            z: 100
            inputList: Models.languagePickerModel
            placeholderSearchText: qsTr("Search Languages")
            menuAlignment: StatusListPicker.MenuAlignment.Left
        }

        StatusListPicker {
            id: languagePicker2
            z: 100
            inputList: Models.languageNoImagePickerModel
            placeholderSearchText: qsTr("Search Languages")
            menuAlignment: StatusListPicker.MenuAlignment.Center
            multiSelection: true
        }

        StatusListPicker {
            id: currencyPicker
            inputList: Models.currencyPickerModel
            placeholderSearchText: qsTr("Search Currencies")
            multiSelection: true
        }

        StatusListPicker {
            id: currencyPicker2
            inputList: Models.currencyPickerModel2
            placeholderSearchText: qsTr("Search Currencies")
            multiSelection: true
            printSymbol: true
            enableSelectableItem: false
        }
    }

    StatusBaseText {
        id: pageDesc
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        height: 100
        width: 500
        text: "4 different configurations for the `StatusListPicker` component:\n
    * Single selection. \n
    * Multiple selection without images.\n
    * Multiple selection.\n
    * Multiple selection and displayed name is the symbol + shortName\n"
        color: Theme.palette.baseColor1
        font.pixelSize: Theme.primaryTextFontSize
    }

    // Outsite area
    StatusMouseArea {
        height: root.height
        width: root.width
        onClicked: {
            languagePicker.close()
            languagePicker2.close()
            currencyPicker.close()
            currencyPicker2.close()
        }
    }
}
