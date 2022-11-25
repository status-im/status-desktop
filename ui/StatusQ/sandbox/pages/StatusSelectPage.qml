import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import Sandbox 0.1

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
        font.pixelSize: 16
        color: Theme.palette.dangerColor1
        text: "This component should no longer be used.<br />Please, use `StatusComboBox` instead."
        textFormat: Text.MarkdownText
    }

    StatusSelect {
        id: select
        label: "Some label"
        model: commmonModel

        menuDelegate: StatusMenuItem {
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

