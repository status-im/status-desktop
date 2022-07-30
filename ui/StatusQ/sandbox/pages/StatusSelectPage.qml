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

    StatusSelect {
        id: select
        label: "Some label"
        model: commmonModel

        selectMenu.delegate: StatusMenuItemDelegate {
            statusPopupMenu: select
            action: StatusMenuItem {
                iconSettings.name: "filled-account"
                text: name
                onTriggered: {
                    selectedItem.text = name
                }
            }
        }

        selectedItemComponent: Item {
            id: selectedItem
            anchors.fill: parent
            property string text: ""

            StatusBaseText {
                text: selectedItem.text
                anchors.centerIn: parent
                color: Theme.palette.directColor1
            }
        }
    }
}

