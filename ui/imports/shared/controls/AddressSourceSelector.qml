import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

Item {
    id: root
    property var sources: []
    property var selectedSource: sources.length ? sources[0] : null
    property int dropdownWidth: 220
    height: select.height

    StatusSelect {
        id: select
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.sources
        selectedItemComponent: Item {
            anchors.fill: parent
            StatusBaseText {
                id: selectedTextField
                text: !!root.selectedSource ? root.selectedSource.text : qsTr("Invalid source")
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                verticalAlignment: Text.AlignVCenter
                height: 24
                color: Theme.palette.directColor1
            }
        }
        selectMenu.delegate: StatusMenuItemDelegate {
            statusPopupMenu: select
            action: StatusMenuItem {
                text: root.sources[index].text
                onTriggered: function () {
                    root.selectedSource = root.sources[index]
                }
            }
        }
    }
}
