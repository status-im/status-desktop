import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

Column {
    spacing: 20

    ListModel {
        id: commmonModel
        ListElement {
            name: "Pascal"
        }
        ListElement {
            name: "Khushboo"
        }
        ListElement {
            name: "Alexandra"
        }
        ListElement {
            name: "Eric"
        }
    }

    StatusBaseText {
        font.pixelSize: Theme.fontSize16
        color: Theme.palette.dangerColor1
        text: "This component should no longer be used.<br />Please, use `StatusComboBox` instead."
        textFormat: Text.MarkdownText
    }

    StatusSelect {
        id: select
        label: "Some label"
        model: commmonModel

        menuDelegate: StatusAction {
            assetSettings.name: "filled-account"
            text: name
            onTriggered: {
                selectedItem.text = name
            }
        }

        selectedItemComponent: StatusBaseText {
            id: selectedItem
            Layout.alignment: Qt.AlignCenter
            color: Theme.palette.directColor1
        }
    }
}

