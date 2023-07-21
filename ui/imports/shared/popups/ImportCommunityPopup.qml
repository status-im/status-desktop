import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import QtQml.Models 2.14

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

StatusDialog {
    id: root
    property var store
    width: 640
    title: qsTr("Import Community")

    signal joinCommunity(string communityId, var communityDetails)
    QtObject {
        id: d
        property string importErrorMessage
        readonly property bool communityFound: (d.isPublicKey && !!d.communityDetails)
        readonly property var communityDetails: {
            return root.store.getCommunityDetails(Utils.getCompressedPk(publicKey));
        }
        readonly property string inputErrorMessage: isInputValid ? "" : qsTr("Invalid key")
        readonly property string errorMessage: importErrorMessage || inputErrorMessage
        readonly property string inputKey: keyInput.text.trim()
        readonly property bool isPrivateKey: (Utils.isPrivateKey(inputKey))
        readonly property bool isPublicKey: (publicKey !== "")
        readonly property string publicKey: {
            if (!Utils.isStatusDeepLink(inputKey)) {
                const key = Utils.dropCommunityLinkPrefix(inputKey)
                if (!Utils.isCommunityPublicKey(key))
                    return ""
                if (!Utils.isCompressedPubKey(key))
                    return key
                return Utils.changeCommunityKeyCompression(key)
            } else {
                return Utils.getCommunityDataFromSharedLink(inputKey).communityId;
            }
        }
        readonly property bool isInputValid: isPrivateKey || isPublicKey
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                id: importButton
                enabled: d.isInputValid
                loading: (d.isPublicKey && !d.communityFound)
                text: d.isPrivateKey ? qsTr("Make this an Owner Node")
                                     : qsTr("Import")
                onClicked: {
                    if (d.isPrivateKey) {
                        const communityKey = d.inputKey
                        if (!communityKey.startsWith("0x")) {
                            communityKey = "0x" + communityKey;
                        }
                        root.store.importCommunity(communityKey);
                        root.close();
                    } else if (d.communityFound) {
                        root.joinCommunity(d.publicKey, d.communityDetails);
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        StatusBaseText {
            id: infoText1
            Layout.fillWidth: true
            text: qsTr("Enter the public key of the community you wish to access, or enter the private key of a community you own. Remember to always keep any private key safe and never share a private key with anyone else.")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            id: inputLabel
            text: qsTr("Community key")
            color: Theme.palette.directColor1
            font.pixelSize: 15
        }

        StatusTextArea {
            id: keyInput
            Layout.fillWidth: true
            implicitHeight: 110
            placeholderText: "0x0..."
            wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
            onTextChanged: d.importErrorMessage = ""
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusChatInfoButton {
                visible: (d.communityFound && d.isPublicKey)
                title: !!d.communityDetails.name ? d.communityDetails.name : ""
                subTitle: !!d.communityDetails.nbMembers ? qsTr("%n member(s)", "", d.communityDetails.nbMembers) : ""
                asset.emoji: "1f918"
                asset.emojiSize: "24x24"
                asset.name: !!d.communityDetails.image ? d.communityDetails.image : ""
                asset.isImage: (asset.name !== "")
                asset.color: !!d.communityDetails.color ? d.communityDetails.color : ""
            }
            Item { Layout.fillWidth: true }
            StatusBaseText {
                id: detectionLabel
                Layout.alignment: Qt.AlignRight
                font.pixelSize: 13
                visible: keyInput.text.trim() !== ""
                text: {
                    if (d.errorMessage !== "") {
                        return d.errorMessage
                    }
                    if (d.isPrivateKey) {
                        return qsTr("Private key detected")
                    }
                    if (d.isPublicKey) {
                        return qsTr("Public key detected")
                    }
                }
                color: d.errorMessage === "" ? Theme.palette.successColor1 : Theme.palette.dangerColor1
            }
        }
    }
}
