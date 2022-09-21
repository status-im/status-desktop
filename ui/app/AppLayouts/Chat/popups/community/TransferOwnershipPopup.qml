import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0

StatusModal {
    id: root

    property var store
    property string privateKey
    property string communityName

    width: 640
    height: 472 - 46 //TODO remove when below functionality is implemented
    header.title: qsTr("Transfer ownership of %1 community").arg(root.communityName)
    padding: Style.current.padding

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("I acknowledge that I lose ownership of this community by leaving and not saving the community key. I acknowledge that I lose ownership of this community by leaving and not saving the community key.")
            wrapMode: Text.WordWrap
            font.pixelSize: 15
        }

        StatusInput {
            id: pKeyInput
            Layout.fillWidth: true
            Layout.preferredHeight: 81
            leftPadding: 14
            rightPadding: Style.current.halfPadding
            topPadding: 0
            bottomPadding: 0
            label: qsTr("Your Community's private key")
            minimumHeight: 56
            maximumHeight: 56
            input.text: Utils.getElidedPk(root.privateKey)
            input.edit.readOnly: true
            input.rightComponent: StatusButton {
                anchors.verticalCenter: parent.verticalCenter
                borderColor: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Copy")
                onClicked: {
                    text = qsTr("Copied")
                    root.store.copyToClipboard(root.privateKey)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            StatusBaseText {
                Layout.preferredWidth: 466
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                wrapMode: Text.WordWrap
                text: qsTr("I acknowledge that I lose ownership of this community by leaving and not saving the community key.")
            }
            Item { Layout.fillWidth: true }
            StatusSwitch {
                id: acknowledgeSwitch
                Layout.alignment: Qt.AlignVCenter
            }
        }

//TODO remove when below functionality is implemented?
        Item { Layout.fillHeight: true }
//TODO uncomment when functionality is implemented
//        StatusBaseText {
//            Layout.fillWidth: true
//            Layout.topMargin: Style.current.halfPadding
//            text: qsTr("This is the only Owner Node running this community at the moment")
//            wrapMode: Text.WordWrap
//            horizontalAlignment: Text.AlignHCenter
//            font.pixelSize: 15
//            color: Theme.palette.dangerColor1
//        }
    }

    rightButtons: [
        StatusButton {
            text: qsTr("Stop Being Community Owner Node")
            enabled: acknowledgeSwitch.checked
            type: enabled ? StatusBaseButton.Type.Danger : StatusBaseButton.Type.Normal
            onClicked: { root.close(); }
        }
    ]
}

