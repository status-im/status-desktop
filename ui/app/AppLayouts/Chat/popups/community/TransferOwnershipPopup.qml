import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0

StatusDialog {
    id: root

    property string privateKey
    property var store

    title: qsTr("Transfer ownership")
    padding: Style.current.padding

    width: 480

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Style.current.padding

        StatusInput {
            id: pKeyInput

            Layout.fillWidth: true

            readonly property string elidedPkey: Utils.getElidedCommunityPK(root.privateKey)

            label: qsTr("Community private key")

            input.text: elidedPkey
            input.edit.readOnly: true
            input.edit.onActiveFocusChanged: {
                pKeyInput.input.text =  pKeyInput.input.edit.focus ? root.privateKey : elidedPkey
            }
            input.rightComponent: StatusButton {
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                anchors.verticalCenter: parent.verticalCenter
                borderColor: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Copy")
                objectName: "copyCommunityPrivateKeyButton"
                onClicked: {
                    text = qsTr("Copied")
                    root.store.copyToClipboard(root.privateKey)
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: qsTr("You should keep it safe and only share it with people you trust to take ownership of your community")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: qsTr("You can also use this key to import your community on another device")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }
    }

    footer: StatusDialogFooter {
        leftButtons: ObjectModel {
            StatusBackButton {
                onClicked: {
                    root.close()
                }
            }
        }
    }
}

