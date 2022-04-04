import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1 as StatusQControls

StatusModal {
    id: root
    width: 640
    height: 400

    property var store

    function validate(communityKey) {
        return Utils.isPrivateKey(communityKey) && Utils.startsWith0x(communityKey)
    }

    header.title: qsTr("Import Community")

    onClosed: {
        root.destroy();
    }

    contentItem: Item {
        width: root.width - 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: childrenRect.height

        StatusBaseText {
            id: infoText1
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            text: qsTr("Entering a community key will grant you the ownership of that community. Please be responsible with it and don’t share the key with people you don’t trust.")
            wrapMode: Text.WordWrap
            width: parent.width
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StyledTextArea {
            id: keyInput
            label: qsTr("Community private key")
            placeholderText: "0x0..."
            customHeight: 110
            anchors.top: infoText1.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right

            onTextChanged: {
                importButton.enabled = root.validate(keyInput.text)
            }
        }
    }

    rightButtons: [
        StatusQControls.StatusButton {
            id: importButton
            enabled: false
            text: qsTr("Import")
            onClicked: {
                let communityKey = keyInput.text.trim();
                if (!communityKey.startsWith("0x")) {
                    communityKey = "0x" + communityKey;
                }

                root.store.importCommunity(communityKey);
                root.close();
            }
        }
    ]
}
