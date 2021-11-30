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
    width: 400
    height: 400

    property var store
    property string error: ""
    property string keyValidationError: ""
    property string communityKey: ""

    function validate() {
        keyValidationError = "";

        if (keyInput.text.trim() === "") {
            //% "You need to enter a key"
            keyValidationError = qsTrId("you-need-to-enter-a-key");
        }

        return !keyValidationError;
    }

    //% "Access existing community"
    header.title: qsTrId("access-existing-community")

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

        StyledTextArea {
            id: keyInput
            //% "Community private key"
            label: qsTrId("community-key")
            placeholderText: "0x0..."
            customHeight: 110
        }

        StatusBaseText {
            id: infoText1
            //% "Entering a community key will grant you the ownership of that community. Please be responsible with it and don’t share the key with people you don’t trust."
            text: qsTrId("entering-a-community-key-will-grant-you-the-ownership-of-that-community--please-be-responsible-with-it-and-don-t-share-the-key-with-people-you-don-t-trust-")
            anchors.top: keyInput.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }
    }

    rightButtons: [
        StatusQControls.StatusButton {
            //% "Import"
            text: qsTrId("import")
            onClicked: {
                if (!validate()) {
                    return;
                }

                communityKey = keyInput.text.trim();
                if (!communityKey.startsWith("0x")) {
                    communityKey = "0x" + communityKey;
                }


                root.error = root.store.chatsModelInst.communities.importCommunity(communityKey, Utils.uuid())
                if (!!root.error) {
                    creatingError.text = error;
                    return creatingError.open();
                }

                root.close();
            }

            MessageDialog {
                id: creatingError
                //% "Error importing the community"
                title: qsTrId("error-importing-the-community")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }
        }
    ]
}
