import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property alias airdropEnabled: airdropButton.enabled
    property alias retailEnabled: retailButton.enabled
    property alias remotelySelfDestructVisible: remotelySelfDestructButton.visible
    property alias burnVisible: burnButton.visible

    signal airdropClicked
    signal retailClicked
    signal remotelyDestructClicked
    signal burnClicked

    height: 61 // by design
    spacing: Style.current.padding
    contentItem: Item {
        anchors.fill: parent

        StatusModalDivider {
            width: parent.width
            anchors.top: parent.top
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: root.spacing

            StatusFlatButton {
                id: airdropButton

                icon.name: "airdrop"
                text: qsTr("Airdrop")

                onClicked: root.airdropClicked()
            }

            StatusFlatButton {
                id: retailButton

                icon.name: "token-sale"
                visible: false // TODO: Milestone 14
                text: qsTr("Retail")

                onClicked: root.retailClicked()
            }

            StatusFlatButton {
                id: remotelySelfDestructButton

                icon.name: "remotely-destruct"
                text: qsTr("Remotely destruct")
                type: StatusBaseButton.Type.Danger
                borderColor: "transparent"

                onClicked: root.remotelyDestructClicked()
            }

            StatusFlatButton {
                id: burnButton

                icon.name: "delete"
                text: qsTr("Burn")
                type: StatusBaseButton.Type.Danger
                borderColor: "transparent"

                onClicked: root.burnClicked()
            }
        }
    }
}


